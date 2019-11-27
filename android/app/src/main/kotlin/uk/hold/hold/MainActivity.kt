package uk.hold.hold

import android.Manifest
import androidx.appcompat.app.AlertDialog
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.api.gax.rpc.ClientStream
import com.google.api.gax.rpc.ResponseObserver
import com.google.api.gax.rpc.StreamController
import com.google.auth.oauth2.GoogleCredentials
import com.google.cloud.speech.v1.*

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.util.concurrent.atomic.AtomicBoolean


class MainActivity : FlutterActivity() {
    private val CHANNEL = "speech_recognition"

    private var mPermissionToRecord = false
    private var mAudioEmitter: AudioEmitter? = null

    private var speechChannel: MethodChannel? = null
    private var requestStream: ClientStream<StreamingRecognizeRequest>? = null

    private val mSpeechClient by lazy {
        // NOTE: The line below uses an embedded credential (res/raw/sa.json).
        //       You should not package a credential with real application.
        //       Instead, you should get a credential securely from a server.
        applicationContext.resources.openRawResource(R.raw.credential).use {
            SpeechClient.create(SpeechSettings.newBuilder()
                    .setCredentialsProvider { GoogleCredentials.fromStream(it) }
                    .build())
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        speechChannel = MethodChannel(flutterView, CHANNEL)
        speechChannel?.setMethodCallHandler { call, result ->
            if (call.method == "speech.stop" || call.method == "speech.cancel") {
                Log.i("SPEECH", "STOP")
                stopListening()
                result.success(true)
            } else if (call.method == "speech.listen") {
                startListening(call.arguments.toString())
                result.success(true)
            } else if (call.method == "speech.activate") {
                if (setupPermissions()) {
                    if (mSpeechClient.isTerminated) {
                        result.success(false)
                    } else {
                        result.success(true)
                    }
                } else {
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setupPermissions(): Boolean {
        val permission = ContextCompat.checkSelfPermission(this,
                Manifest.permission.RECORD_AUDIO)
        if (permission == PackageManager.PERMISSION_GRANTED) {
            return true
        } else {
            makeRequest()
            return false
        }
    }

    private fun makeRequest() {
        ActivityCompat.requestPermissions(this,
                arrayOf(Manifest.permission.RECORD_AUDIO),
                1111)
    }

    fun startListening(language: String?) {
        val isFirstRequest = AtomicBoolean(true)
        mAudioEmitter = AudioEmitter()

        requestStream = mSpeechClient.streamingRecognizeCallable()
                .splitCall(object : ResponseObserver<StreamingRecognizeResponse> {
                    override fun onComplete() {
                        Log.d("GVOICE", "stream closed")
                    }

                    override fun onResponse(response: StreamingRecognizeResponse?) {
                        runOnUiThread {
                            if (response!!.resultsCount > 0) {
                                if (response.getResults(0).isFinal) {
                                    speechChannel?.invokeMethod("speech.onRecognitionComplete",
                                            response.getResults(0)?.getAlternatives(0)?.transcript)
                                } else {
                                    speechChannel?.invokeMethod("speech.onSpeech",
                                            response.getResults(0)?.getAlternatives(0)?.transcript)
                                }
                            }
                        }
                    }

                    override fun onError(t: Throwable?) {
                        speechChannel?.invokeMethod("speech.onError", t)
                        Log.e("GVOICE", "an error occurred", t)
                    }

                    override fun onStart(controller: StreamController?) {

                    }

                })

        // monitor the input stream and send requests as audio data becomes available
        mAudioEmitter!!.start { bytes ->
            val builder = StreamingRecognizeRequest.newBuilder()
                    .setAudioContent(bytes)

            // if first time, include the config
            if (isFirstRequest.getAndSet(false)) {
                builder.streamingConfig = StreamingRecognitionConfig.newBuilder()
                        .setConfig(RecognitionConfig.newBuilder()
                                .setLanguageCode(language)
                                .setEncoding(RecognitionConfig.AudioEncoding.LINEAR16)
                                .setSampleRateHertz(16000)
                                .setEnableAutomaticPunctuation(true)
                                .build())
                        .setInterimResults(true)
                        .setSingleUtterance(false)
                        .build()
            }

            // send the next request
            requestStream?.send(builder.build())
        }
        speechChannel?.invokeMethod("speech.onRecognitionStarted", "")
    }

    fun stopListening() {
        mAudioEmitter?.stop()
        mAudioEmitter = null
        requestStream?.closeSend()
    }
}

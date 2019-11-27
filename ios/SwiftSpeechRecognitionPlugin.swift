import Flutter
import UIKit

public class SwiftSpeechRecognitionPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "speech_recognition", binaryMessenger: registrar.messenger())
        let instance = SwiftSpeechRecognitionPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    private var speechChannel: FlutterMethodChannel?
    private var speechRecognizer = SpeechRecognitionService()
    private var audioEngine = AudioController()

    init(channel:FlutterMethodChannel){
        speechChannel = channel
        super.init()
        audioEngine.delegate = self
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        //result("iOS " + UIDevice.current.systemVersion)
        switch (call.method) {
        case "speech.activate":
          self.activateRecognition(result: result)
        case "speech.listen":
          self.startRecognition(lang: call.arguments as! String, result: result)
        case "speech.cancel":
          self.cancelRecognition(result: result)
        case "speech.stop":
          self.stopRecognition(result: result)
        default:
          result(FlutterMethodNotImplemented)
        }
    }

    private func activateRecognition(result: @escaping FlutterResult) {
        result(true)
        self.speechChannel?.invokeMethod("speech.onCurrentLocale", arguments: "\(Locale.current.identifier)")
    }

    private func startRecognition(lang: String, result: FlutterResult) {
        print("startRecognition...")
        if audioEngine.isRunning {
            audioEngine.stopRecordAudio()
          result(false)
        } else {
            audioEngine = AudioController()
            audioEngine.languageCode = lang
            audioEngine.startRecordAudio()
            audioEngine.delegate = self
            speechChannel!.invokeMethod("speech.onRecognitionStarted", arguments: nil)
            result(true)
        }
    }

    private func cancelRecognition(result: FlutterResult?) {
//        if let recognitionTask = recognitionTask {
//            recognitionTask.cancel()
//            self.recognitionTask = nil
//            if let result = result {
//                result(false)
//            }
//        }
        if let result = result {
            result(false)
        }
    }

    private func stopRecognition(result: FlutterResult) {
        if audioEngine.isRunning {
            audioEngine.stopRecordAudio()
            result(true)
        }
        result(false)
    }
}

extension SwiftSpeechRecognitionPlugin: AudioControllerDelegate {
    public func audioControllerDidReceiveText(_ string: String!, isFinal: Bool) {
        if isFinal {
            self.speechChannel?.invokeMethod("speech.onRecognitionComplete", arguments: string)
        } else {
            self.speechChannel?.invokeMethod("speech.onSpeech", arguments: string)
        }
    }
    
    public func audioControllerDidReceiveError(_ error: Error!) {
        
    }
}

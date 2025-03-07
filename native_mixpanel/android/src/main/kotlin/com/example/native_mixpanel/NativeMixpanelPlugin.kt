package com.example.native_mixpanel

import android.content.Context
import org.json.JSONObject
import com.mixpanel.android.mpmetrics.MixpanelAPI
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class NativeMixpanelPlugin : MethodCallHandler {

    private var mixpanel: MixpanelAPI? = null
    private var personId: String? = null

    companion object {

        var ctxt: Context? = null
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            ctxt = registrar.context()
            val channel = MethodChannel(registrar.messenger(), "native_mixpanel")
            channel.setMethodCallHandler(NativeMixpanelPlugin())
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "initialize") {
            mixpanel = MixpanelAPI.getInstance(ctxt, call.arguments.toString())
            result.success("Init success..")

        } else if (call.method == "identify") {
            personId = call.arguments.toString()
            mixpanel?.identify(personId)
            result.success("Identify success..")

        } else if (call.method == "alias") {
            mixpanel?.alias(call.arguments.toString(), mixpanel?.getDistinctId())
            result.success("Alias success..")

        } else if (call.method == "setPeopleProperties") {
            if (call.arguments == null) {
                result.error("Parse Error", "Arguments required for setPeopleProperties platform call", null)
            } else {
                val json = JSONObject(call.arguments.toString())
                mixpanel?.people?.set(json)
                mixpanel?.identify(personId)
                mixpanel?.people?.identify(personId)
                result.success("Set People Properties success..")
            }
        } else if (call.method == "registerSuperProperties") {
            if (call.arguments == null) {
                result.error("Parse Error", "Arguments required for registerSuperProperties platform call", null)
            } else {
                val json = JSONObject(call.arguments.toString())
                mixpanel?.registerSuperProperties(json)
                result.success("Register Properties success..")
            }
        } else if (call.method == "reset") {
            mixpanel?.reset()
            result.success("Reset success..")
        } else if (call.method == "flush") {
            mixpanel?.flush()
            result.success("Flush success..")
        } else if (call.method == "increment") {
            if (call.arguments != null) {
                mixpanel?.people?.increment(call.arguments.toString(), 1.0)
                result.success("Increment success..")
            }
        } else {
            if (call.arguments == null) {
                mixpanel?.track(call.method)
            } else {
                val json = JSONObject(call.arguments.toString())
                mixpanel?.track(call.method, json)
            }
            result.success("Track success..")
        }
    }
}

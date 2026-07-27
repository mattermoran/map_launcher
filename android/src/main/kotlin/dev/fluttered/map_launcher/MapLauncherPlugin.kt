package dev.fluttered.map_launcher

import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import androidx.core.net.toUri



/// Flutter plugin for map_launcher on Android.
///
/// Provides two method channel calls:
/// - `launch` — opens a URL via [Intent.ACTION_VIEW]
/// - `getInstalledMaps` — detects installed map apps via [PackageManager]
class MapLauncherPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "map_launcher")
        context = flutterPluginBinding.applicationContext
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "launch" -> {
                val url = call.argument<String>("url")
                val packageName = call.argument<String>("packageName")
                if (url == null) {
                    result.error("INVALID_URL", "Missing 'url' argument", null)
                    return
                }
                try {
                    val intent = Intent(Intent.ACTION_VIEW, url.toUri())
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    if (packageName != null) {
                        intent.setPackage(packageName)
                    }
                    context.startActivity(intent)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("LAUNCH_FAILED", "Failed to launch URL: ${e.message}", null)
                }
            }

            "getInstalledMaps" -> {
                @Suppress("UNCHECKED_CAST")
                val probes = call.arguments as? Map<String, String> ?: emptyMap()
                val installed = probes.filter { (_, pkg) ->
                    context.packageManager.getLaunchIntentForPackage(pkg) != null
                }.keys.toList()
                // Same shape as iOS; Android has no way to introspect the
                // merged <queries> block, so "undeclared" is always empty.
                result.success(mapOf("installed" to installed))
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

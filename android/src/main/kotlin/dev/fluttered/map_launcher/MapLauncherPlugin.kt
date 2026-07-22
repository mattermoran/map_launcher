package dev.fluttered.map_launcher

import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import androidx.core.net.toUri

/// Map of Dart MapType enum name → Android package name.
///
/// Used to detect installed map apps via [PackageManager.getLaunchIntentForPackage].
private val mapPackages = mapOf(
    "google" to "com.google.android.apps.maps",
    "googleGo" to "com.google.android.apps.mapslite",
    "amap" to "com.autonavi.minimap",
    "baidu" to "com.baidu.BaiduMap",
    "waze" to "com.waze",
    "yandexNavi" to "ru.yandex.yandexnavi",
    "yandexMaps" to "ru.yandex.yandexmaps",
    "citymapper" to "com.citymapper.app.release",
    "mapswithme" to "com.mapswithme.maps.pro",
    "osmand" to "net.osmand",
    "osmandplus" to "net.osmand.plus",
    "doubleGis" to "ru.dublgis.dgismobile",
    "tencent" to "com.tencent.map",
    "here" to "com.here.app.maps",
    "petal" to "com.huawei.maps.app",
    "tomtomgo" to "com.tomtom.gplay.navapp",
    "tomtomgofleet" to "com.tomtom.gplay.navapp.gofleet",
    "sygicTruck" to "com.sygic.truck",
    "copilot" to "com.alk.copilot.mapviewer",
    "flitsmeister" to "nl.flitsmeister",
    "truckmeister" to "nl.flitsmeister.flux",
    "naver" to "com.nhn.android.nmap",
    "kakao" to "net.daum.android.map",
    "tmap" to "com.skt.tmap.ku",
    "mapyCz" to "cz.seznam.mapy",
    "mappls" to "com.mmi.maps",
    "moovit" to "com.tranzmate",
    "neshan" to "org.rajman.neshan.traffic.tehran.navigator",
    "airnavPro" to "com.xample.airnavigation",
    "spedionNavigation" to "de.spedion.mobile.android.spediontrucknavigation",
    "magicEarth" to "com.generalmagic.magicearth",
)

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
                val installed = mapPackages.filter { (_, packageName) ->
                    context.packageManager?.getLaunchIntentForPackage(packageName) != null
                }.map { (mapType, _) ->
                    mapOf("mapType" to mapType)
                }
                result.success(installed)
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

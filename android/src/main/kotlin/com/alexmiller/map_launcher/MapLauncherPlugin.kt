package com.alexmiller.map_launcher

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

private enum class MapType { google, googleGo, amap, baidu, waze, yandexNavi, yandexMaps, citymapper, mapswithme, osmand, doubleGis }

private class MapModel(val mapType: MapType, val mapName: String, val packageName: String) {
    fun toMap(): Map<String, String> {
        return mapOf("mapType" to mapType.name, "mapName" to mapName, "packageName" to packageName)
    }
}

class MapLauncherPlugin : FlutterPlugin, MethodCallHandler {
    private var channel: MethodChannel? = null
    private var context: Context? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "map_launcher")
        this.context = flutterPluginBinding.applicationContext
        channel?.setMethodCallHandler(this)
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val mapLauncherPlugin = MapLauncherPlugin()
            mapLauncherPlugin.channel = MethodChannel(registrar.messenger(), "map_launcher")
            mapLauncherPlugin.context = registrar.context()
            mapLauncherPlugin.channel?.setMethodCallHandler(mapLauncherPlugin)
        }
    }

    private val maps = listOf(
            MapModel(MapType.google, "Google Maps", "com.google.android.apps.maps"),
            MapModel(MapType.googleGo, "Google Maps Go", "com.google.android.apps.mapslite"),
            MapModel(MapType.amap, "Amap", "com.autonavi.minimap"),
            MapModel(MapType.baidu, "Baidu Maps", "com.baidu.BaiduMap"),
            MapModel(MapType.waze, "Waze", "com.waze"),
            MapModel(MapType.yandexNavi, "Yandex Navigator", "ru.yandex.yandexnavi"),
            MapModel(MapType.yandexMaps, "Yandex Maps", "ru.yandex.yandexmaps"),
            MapModel(MapType.citymapper, "Citymapper", "com.citymapper.app.release"),
            MapModel(MapType.mapswithme, "MAPS.ME", "com.mapswithme.maps.pro"),
            MapModel(MapType.osmand, "OsmAnd", "net.osmand"),
            MapModel(MapType.doubleGis, "2GIS", "ru.dublgis.dgismobile")
    )

    private fun getInstalledMaps(): List<MapModel> {
        val installedApps = context?.packageManager?.getInstalledApplications(0) ?: return listOf()
        return maps.filter { map -> installedApps.any { app -> app.packageName == map.packageName } }
    }


    private fun isMapAvailable(type: String): Boolean {
        val installedMaps = getInstalledMaps()
        return installedMaps.any { map -> map.mapType.name == type }
    }

    private fun launchGoogleMaps(url: String) {
        context?.let {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            intent.setPackage("com.google.android.apps.maps")
            if (intent.resolveActivity(it.packageManager) != null) {
                it.startActivity(intent)
            }
        }
    }

    private fun launchMap(mapType: MapType, url: String, result: Result) {
        when (mapType) {
          MapType.google -> launchGoogleMaps(url)
            else -> {
                context?.let {
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    val foundMap = maps.find { map -> map.mapType == mapType }
                    if (foundMap != null) {
                        intent.setPackage(foundMap.packageName)
                    }
                    it.startActivity(intent)
                }
            }
        }
        result.success(null)
    }


    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
          "getInstalledMaps" -> {
            val installedMaps = getInstalledMaps()
            result.success(installedMaps.map { map -> map.toMap() })
          }
          "showMarker", "showDirections" -> {
            val args = call.arguments as Map<*, *>

            if (!isMapAvailable(args["mapType"] as String)) {
              result.error("MAP_NOT_AVAILABLE", "Map is not installed on a device", null)
              return
            }

            val mapType = MapType.valueOf(args["mapType"] as String)
            val url = args["url"] as String

            launchMap(mapType, url, result)
          }
          "isMapAvailable" -> {
            val args = call.arguments as Map<*, *>
            result.success(isMapAvailable(args["mapType"] as String))
          }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        context = null
    }
}

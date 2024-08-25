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

private enum class MapType { google, googleGo, amap, baidu, waze, yandexNavi, yandexMaps, citymapper, osmand, osmandplus, doubleGis, tencent, here, petal, tomtomgo, copilot, sygicTruck, tomtomgofleet, flitsmeister, truckmeister, naver, kakao, tmap, mapyCz, mappls }

private class MapModel(val mapType: MapType, val mapName: String, val packageName: String, val urlPrefix: String) {
    fun toMap(): Map<String, String> {
        return mapOf("mapType" to mapType.name, "mapName" to mapName, "packageName" to packageName, "urlPrefix" to urlPrefix)
    }
}

class MapLauncherPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "map_launcher")
        this.context = flutterPluginBinding.applicationContext
        channel.setMethodCallHandler(this)
    }

    private val maps = listOf(
            MapModel(MapType.google, "Google Maps", "com.google.android.apps.maps", "geo://"),
            MapModel(MapType.googleGo, "Google Maps Go", "com.google.android.apps.mapslite", "geo://"),
            MapModel(MapType.amap, "Amap", "com.autonavi.minimap", "iosamap://"),
            MapModel(MapType.baidu, "Baidu Maps", "com.baidu.BaiduMap", "baidumap://"),
            MapModel(MapType.waze, "Waze", "com.waze", "waze://"),
            MapModel(MapType.yandexNavi, "Yandex Navigator", "ru.yandex.yandexnavi", "yandexnavi://"),
            MapModel(MapType.yandexMaps, "Yandex Maps", "ru.yandex.yandexmaps", "yandexmaps://"),
            MapModel(MapType.citymapper, "Citymapper", "com.citymapper.app.release", "citymapper://"),
            MapModel(MapType.osmand, "OsmAnd", "net.osmand", "osmandmaps://"),
            MapModel(MapType.osmandplus, "OsmAnd+", "net.osmand.plus", "osmandmaps://"),
            MapModel(MapType.doubleGis, "2GIS", "ru.dublgis.dgismobile", "dgis://"),
            MapModel(MapType.tencent, "Tencent (QQ Maps)", "com.tencent.map", "qqmap://"),
            MapModel(MapType.here, "HERE WeGo", "com.here.app.maps", "here-location://"),
            MapModel(MapType.petal, "Petal Maps", "com.huawei.maps.app", "petalmaps://"),
            MapModel(MapType.tomtomgo, "TomTom Go", "com.tomtom.gplay.navapp", "tomtomgo://"),
            MapModel(MapType.tomtomgofleet, "TomTom Go Fleet", "com.tomtom.gplay.navapp.gofleet", "tomtomgofleet://"),
            MapModel(MapType.sygicTruck, "Sygic Truck", "com.sygic.truck", "com.sygic.aura://"),
            MapModel(MapType.copilot, "CoPilot", "com.alk.copilot.mapviewer", "copilot://"),
            MapModel(MapType.flitsmeister, "Flitsmeister", "nl.flitsmeister", "flitsmeister://"),
            MapModel(MapType.truckmeister, "Truckmeister", "nl.flitsmeister.flux", "truckmeister://"),
            MapModel(MapType.naver, "Naver Map", "com.nhn.android.nmap", "nmap://"),
            MapModel(MapType.kakao, "Kakao Maps", "net.daum.android.map", "kakaomap://"),
            MapModel(MapType.tmap, "TMap", "com.skt.tmap.ku", "tmap://"),
            MapModel(MapType.mapyCz, "Mapy CZ", "cz.seznam.mapy", "https://"),
            MapModel(MapType.mappls, "Mappls MapmyIndia","com.mmi.maps","mappls://")
    )

    private fun getInstalledMaps(): List<MapModel> {
        return maps.filter { map ->
            context.packageManager?.getLaunchIntentForPackage(map.packageName) != null
        }
    }

    private fun isMapAvailable(type: String): Boolean {
        val installedMaps = getInstalledMaps()
        return installedMaps.any { map -> map.mapType.name == type }
    }

    private fun launchMap(mapType: MapType, url: String, result: Result) {
        context.let {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            val foundMap = maps.find { map -> map.mapType == mapType }
            if (foundMap != null) {
                intent.setPackage(foundMap.packageName)
            }
            it.startActivity(intent)
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
        channel.setMethodCallHandler(null)
    }
}

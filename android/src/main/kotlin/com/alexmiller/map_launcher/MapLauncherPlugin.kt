package com.alexmiller.map_launcher

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

private enum class MapType { google, amap, baidu }

private class MapModel(val mapType: MapType, val mapName: String, val packageName: String) {
  fun toMap(): Map<String, String> {
    return mapOf("mapType" to mapType.name, "mapName" to mapName, "packageName" to packageName)
  }
}

class MapLauncherPlugin(private val context: Context, private val activity: Activity, private val pm: PackageManager) : MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "map_launcher")
      val context = registrar.activeContext()
      val activity = registrar.activity()
      val pm = context.getPackageManager()

      channel.setMethodCallHandler(MapLauncherPlugin(context, activity, pm))
    }
  }

  private val maps = listOf(
    MapModel(MapType.google, "Google Maps", "com.google.android.apps.maps"),
    MapModel(MapType.amap, "Amap", "com.autonavi.minimap"),
    MapModel(MapType.baidu, "Baidu Maps", "com.baidu.BaiduMap")
  )

  private fun getInstalledMaps(): List<MapModel> {
      val installedApps = pm.getInstalledApplications(0)
      val installedMaps = maps.filter { map -> installedApps.any { app -> app.packageName == map.packageName } }
      return installedMaps
  }


  private fun isMapAvailable(type: String): Boolean {
    val installedMaps = getInstalledMaps()
    return installedMaps.any { map -> map.mapType.name == type }
  }

  private fun launchGoogleMaps(url: String) {
    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
    intent.setPackage("com.google.android.apps.maps")
    if (intent.resolveActivity(context.packageManager) != null) {
      context.startActivity(intent)
    }
  }

  private fun launchMap(mapType: MapType, url: String) {
    when (mapType) {
      MapType.google -> launchGoogleMaps(url)
      else -> {
        val intent = Intent()
        intent.data = Uri.parse(url)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
      }
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getInstalledMaps" -> {
        val installedMaps = getInstalledMaps()
        result.success(installedMaps.map { map -> map.toMap() })
      }
      "launchMap" -> {
        var args = call.arguments as Map<String, String>
        val mapType = MapType.valueOf(args["mapType"] as String)
        val url = args["url"] as String
        launchMap(mapType, url)
      }
      "isMapAvailable" -> {
        var args = call.arguments as Map<String, String>
        result.success(isMapAvailable(args["mapType"] as String))
      }
      else -> result.notImplemented()
    }
  }
}

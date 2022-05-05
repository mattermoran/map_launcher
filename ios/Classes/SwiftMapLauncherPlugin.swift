import Flutter
import UIKit
import MapKit


enum MapType: String {
  case apple
  case google
  case amap
  case baidu
  case waze
  case yandexNavi
  case yandexMaps
  case citymapper
  case mapswithme
  case osmand

  func type() -> String {
    return self.rawValue
  }
}

class Map {
  let mapName: String;
  let mapType: MapType;
  let urlPrefix: String?;


    init(mapName: String, mapType: MapType, urlPrefix: String?) {
        self.mapName = mapName
        self.mapType = mapType
        self.urlPrefix = urlPrefix
    }

    func toMap() -> [String:String] {
    return [
      "mapName": mapName,
      "mapType": mapType.type(),
    ]
  }
}

let maps: [Map] = [
    Map(mapName: "Apple Maps", mapType: MapType.apple, urlPrefix: ""),
    Map(mapName: "Google Maps", mapType: MapType.google, urlPrefix: "comgooglemaps://"),
    Map(mapName: "Amap", mapType: MapType.amap, urlPrefix: "iosamap://"),
    Map(mapName: "Baidu Maps", mapType: MapType.baidu, urlPrefix: "baidumap://"),
    Map(mapName: "Waze", mapType: MapType.waze, urlPrefix: "waze://"),
    Map(mapName: "Yandex Navigator", mapType: MapType.yandexNavi, urlPrefix: "yandexnavi://"),
    Map(mapName: "Yandex Maps", mapType: MapType.yandexMaps, urlPrefix: "yandexmaps://"),
    Map(mapName: "Citymapper", mapType: MapType.citymapper, urlPrefix: "citymapper://"),
    Map(mapName: "MAPS.ME", mapType: MapType.mapswithme, urlPrefix: "mapswithme://"),
    Map(mapName: "OsmAnd", mapType: MapType.osmand, urlPrefix: "osmandmaps://")
]

func getMapByRawMapType(type: String) -> Map {
    return maps.first(where: { $0.mapType.type() == type })!
}

func launchMap(mapType: MapType, url: String, title: String, latitude: String, longitude: String) {
    switch mapType {
    case MapType.apple:
        let coordinate = CLLocationCoordinate2DMake(Double(latitude)!, Double(longitude)!)
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.02))
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
        mapItem.name = title
        mapItem.openInMaps(launchOptions: options)
    default:
        UIApplication.shared.open(URL(string:url)!)

    }
}


func isMapAvailable(map: Map) -> Bool {
    if map.mapType == MapType.apple {
        return true
    }
    return UIApplication.shared.canOpenURL(URL(string:map.urlPrefix!)!)
}


public class SwiftMapLauncherPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "map_launcher", binaryMessenger: registrar.messenger())
    let instance = SwiftMapLauncherPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getInstalledMaps":
      result(maps.filter({ isMapAvailable(map: $0) }).map({ $0.toMap() }))
    case "launchMap":
      let args = call.arguments as! NSDictionary
      let mapType = args["mapType"] as! String
      let url = args["url"] as! String
      let title = args["title"] as! String
      let latitude = args["latitude"] as! String
      let longitude = args["longitude"] as! String

      let map = getMapByRawMapType(type: mapType)
      if (!isMapAvailable(map: map)) {
        result(FlutterError(code: "MAP_NOT_AVAILABLE", message: "Map is not installed on a device", details: nil))
        return;
      }

      launchMap(mapType: MapType(rawValue: mapType)!, url: url, title: title, latitude: latitude, longitude: longitude)
    case "isMapAvailable":
      let args = call.arguments as! NSDictionary
      let mapType = args["mapType"] as! String
      let map = getMapByRawMapType(type: mapType)
      result(isMapAvailable(map: map))
    default:
      print("method does not exist")
    }
  }
}

import Flutter
import UIKit
import MapKit


private enum MapType: String {
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
    case doubleGis
    case tencent
    case here
    case tomtomgo
    case tomtomgofleet
    case copilot
    case sygicTruck
    case naver
    case kakao
    case tmap
    case mapyCz
    case mappls

    func type() -> String {
        return self.rawValue
    }
}

private class Map {
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

private let maps: [Map] = [
    Map(mapName: "Apple Maps", mapType: MapType.apple, urlPrefix: ""),
    Map(mapName: "Google Maps", mapType: MapType.google, urlPrefix: "comgooglemaps://"),
    Map(mapName: "Amap", mapType: MapType.amap, urlPrefix: "iosamap://"),
    Map(mapName: "Baidu Maps", mapType: MapType.baidu, urlPrefix: "baidumap://"),
    Map(mapName: "Waze", mapType: MapType.waze, urlPrefix: "waze://"),
    Map(mapName: "Yandex Navigator", mapType: MapType.yandexNavi, urlPrefix: "yandexnavi://"),
    Map(mapName: "Yandex Maps", mapType: MapType.yandexMaps, urlPrefix: "yandexmaps://"),
    Map(mapName: "Citymapper", mapType: MapType.citymapper, urlPrefix: "citymapper://"),
    Map(mapName: "MAPS.ME", mapType: MapType.mapswithme, urlPrefix: "mapswithme://"),
    Map(mapName: "OsmAnd", mapType: MapType.osmand, urlPrefix: "osmandmaps://"),
    Map(mapName: "2GIS", mapType: MapType.doubleGis, urlPrefix: "dgis://"),
    Map(mapName: "Tencent (QQ Maps)", mapType: MapType.tencent, urlPrefix: "qqmap://"),
    Map(mapName: "HERE WeGo", mapType: MapType.here, urlPrefix: "here-location://"),
    Map(mapName: "TomTom Go", mapType: MapType.tomtomgo, urlPrefix: "tomtomgo://"),
    Map(mapName: "TomTom Go Fleet", mapType: MapType.tomtomgofleet, urlPrefix: "tomtomgofleet://"),
    Map(mapName: "Sygic Truck", mapType: MapType.sygicTruck, urlPrefix: "com.sygic.aura://"),
    Map(mapName: "CoPilot", mapType: MapType.copilot, urlPrefix: "copilot://"),
    Map(mapName: "Naver Map", mapType: MapType.naver, urlPrefix: "nmap://"),
    Map(mapName: "Kakao Maps", mapType: MapType.kakao, urlPrefix: "kakaomap://"),
    Map(mapName: "TMap", mapType: MapType.tmap, urlPrefix: "tmap://"),
    Map(mapName: "Mapy CZ", mapType: MapType.mapyCz, urlPrefix: "szn-mapy://"),
    Map(mapName: "Mappls MapmyIndia", mapType: MapType.mappls, urlPrefix: "mappls://")
]

private func getMapByRawMapType(type: String) -> Map? {
    return maps.first(where: { $0.mapType.type() == type })
}

private func getMapItem(latitude: String, longitude: String, name: String?) -> MKMapItem {
    let coordinate = CLLocationCoordinate2DMake(Double(latitude)!, Double(longitude)!)
    let destinationPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)

    let mapItem = MKMapItem(placemark: destinationPlacemark)
    mapItem.name = name
    return mapItem
}

private func getDirectionsMode(directionsMode: String?) -> String {
    switch directionsMode {
    case "driving":
        return MKLaunchOptionsDirectionsModeDriving
    case "walking":
        return MKLaunchOptionsDirectionsModeWalking
    case "transit":
        if #available(iOS 9.0, *) {
            return MKLaunchOptionsDirectionsModeTransit
        } else {
            return MKLaunchOptionsDirectionsModeDriving
        }
    default:
        if #available(iOS 10.0, *) {
            return MKLaunchOptionsDirectionsModeDefault
        } else {
            return MKLaunchOptionsDirectionsModeDriving
        }
    }
}

private func showMarker(mapType: MapType, url: String, title: String, latitude: String, longitude: String) {
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
        UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)

    }
}

private func showDirections(mapType: MapType, url: String, destinationTitle: String?, destinationLatitude: String, destinationLongitude: String, originTitle: String?, originLatitude: String?, originLongitude: String?, directionsMode: String?, waypoints: [[String: String?]]?) {
    switch mapType {
    case MapType.apple:

        let destinationMapItem = getMapItem(latitude: destinationLatitude, longitude: destinationLongitude, name: destinationTitle ?? "Destination");

        let hasOrigin = originLatitude != nil && originLatitude != nil
        var originMapItem: MKMapItem {
            if !hasOrigin {
                return MKMapItem.forCurrentLocation()
            }
            let origin = getMapItem(latitude: originLatitude!, longitude: originLongitude!, name: originTitle ?? "Origin")
            return origin
        }

        let waypointMapItems = waypoints == nil ? [MKMapItem]() : waypoints!.map { getMapItem(latitude: $0["latitude"]!!, longitude: $0["longitude"]!!, name: $0["title"] as? String) }

        MKMapItem.openMaps(
            with: [originMapItem] + waypointMapItems + [destinationMapItem],
            launchOptions: [MKLaunchOptionsDirectionsModeKey: getDirectionsMode(directionsMode: directionsMode)]
        )
    default:
        UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)

    }
}


private func isMapAvailable(map: Map?) -> Bool {
    // maptype is not available on iOS
    guard let map = map else {
        return false
    }
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

        case "showMarker":
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

            showMarker(mapType: MapType(rawValue: mapType)!, url: url, title: title, latitude: latitude, longitude: longitude)
            result(nil)

        case "showDirections":
            let args = call.arguments as! NSDictionary
            let mapType = args["mapType"] as! String
            let url = args["url"] as! String

            let destinationTitle = args["destinationTitle"] as? String
            let destinationLatitude = args["destinationLatitude"] as! String
            let destinationLongitude = args["destinationLongitude"] as! String

            let originTitle = args["originTitle"] as? String
            let originLatitude = args["originLatitude"] as? String
            let originLongitude = args["originLongitude"] as? String

            let directionsMode = args["directionsMode"] as? String

            let waypoints = args["waypoints"] as? [[String: String?]]

            let map = getMapByRawMapType(type: mapType)
            if (!isMapAvailable(map: map)) {
                result(FlutterError(code: "MAP_NOT_AVAILABLE", message: "Map is not installed on a device", details: nil))
                return;
            }

            showDirections(
                mapType: MapType(rawValue: mapType)!,
                url: url,
                destinationTitle: destinationTitle,
                destinationLatitude: destinationLatitude,
                destinationLongitude: destinationLongitude,
                originTitle: originTitle,
                originLatitude: originLatitude,
                originLongitude: originLongitude,
                directionsMode: directionsMode,
                waypoints: waypoints
            )
            result(nil)

        case "isMapAvailable":
            let args = call.arguments as! NSDictionary
            let mapType = args["mapType"] as! String
            let map = getMapByRawMapType(type: mapType)
            result(isMapAvailable(map: map))

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

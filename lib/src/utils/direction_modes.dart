import 'package:map_launcher/map_launcher.dart';

/// Returns directions mode code for Amap ([MapType.amap]).
String getAmapDirectionsMode(DirectionsMode? mode) {
  return switch (mode) {
    DirectionsMode.driving => '0',
    DirectionsMode.transit => '1',
    DirectionsMode.walking => '2',
    DirectionsMode.bicycling => '3',
    _ => '0',
  };
}

/// Returns directions mode code for Baidu ([MapType.baidu]).
String getBaiduDirectionsMode(DirectionsMode? mode) {
  return switch (mode) {
    DirectionsMode.driving => 'driving',
    DirectionsMode.transit => 'transit',
    DirectionsMode.walking => 'walking',
    DirectionsMode.bicycling => 'riding',
    _ => 'driving',
  };
}

/// Returns directions mode code for Maps.me ([MapType.mapswithme]).
String getMapsMeDirectionsMode(DirectionsMode mode) {
  return switch (mode) {
    DirectionsMode.driving => 'vehicle',
    DirectionsMode.transit => 'transit',
    DirectionsMode.walking => 'pedestrian',
    DirectionsMode.bicycling => 'bicycle',
  };
}

/// Returns directions mode code for Yandex Maps ([MapType.yandexMaps]).
String getYandexMapsDirectionsMode(DirectionsMode? mode) {
  return switch (mode) {
    DirectionsMode.driving => 'auto',
    DirectionsMode.transit => 'mt',
    DirectionsMode.walking => 'pd',
    DirectionsMode.bicycling => 'auto',
    _ => 'auto',
  };
}

/// Returns directions mode code for 2GIS ([MapType.doubleGis]).
String getDoubleGisDirectionsMode(DirectionsMode? mode) {
  return switch (mode) {
    DirectionsMode.driving => 'car',
    DirectionsMode.transit => 'bus',
    DirectionsMode.walking => 'pedestrian',
    _ => 'auto',
  };
}

/// Returns directions mode code for Tencent Maps ([MapType.tencent]).
String getTencentDirectionsMode(DirectionsMode? mode) {
  return switch (mode) {
    DirectionsMode.driving => 'drive',
    DirectionsMode.transit => 'bus',
    DirectionsMode.walking => 'walk',
    DirectionsMode.bicycling => 'bicycle',
    _ => 'auto',
  };
}

/// Returns directions mode code for HERE WeGo ([MapType.here]).
String getHereDirectionsMode(DirectionsMode? mode) {
  return switch (mode) {
    DirectionsMode.driving => 'd',
    DirectionsMode.transit => 'pt',
    DirectionsMode.walking => 'w',
    DirectionsMode.bicycling => 'b',
    _ => 'd',
  };
}

/// Returns directions mode code for MAPPLS ([MapType.mappls]).
String getMapplsDirectionsMode(DirectionsMode? mode) {
  return switch (mode) {
    DirectionsMode.driving => 'driving',
    DirectionsMode.walking => 'walking',
    DirectionsMode.bicycling => 'biking',
    _ => 'd',
  };
}

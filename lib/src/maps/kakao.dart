import 'dart:typed_data';
import 'package:map_launcher/src/maps/map_app.dart';
import 'package:map_launcher/src/maps/icons/kakao_icon.dart';
import 'package:map_launcher/src/models/location.dart';
import 'package:map_launcher/src/models/map_platform.dart';
import 'package:map_launcher/src/models/travel_mode.dart';
import 'package:map_launcher/src/utils/url_builder.dart';

/// KakaoMap. Mobile only, directions with origin.
class KakaoMap extends MapApp {
  /// Creates a [KakaoMap].
  const KakaoMap();

  @override
  String get id => 'kakao';

  @override
  String get name => 'Kakao Maps';

  @override
  String? get playStoreId => 'net.daum.android.map';

  @override
  String? get appStoreId => '304608425';

  @override
  String? get iosScheme => 'kakaomap://';

  @override
  Uint8List get iconBytes => kakaoIcon;

  @override
  String? markerUrl(LocationCoords coords, {int? zoom}) => null;

  @override
  String? directionsUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
  }) => null;

  @override
  String? markerSchemeUrl(
    LocationCoords coords, {
    int? zoom,
    required MapPlatform platform,
  }) => buildUrl(url: 'kakaomap://look', queryParams: {'p': coords.latlng});

  @override
  String? directionsSchemeUrl({
    required LocationCoords destination,
    LocationCoords? origin,
    List<LocationCoords>? waypoints,
    TravelMode? travelMode,
    required MapPlatform platform,
  }) => buildUrl(
    url: 'kakaomap://route',
    queryParams: {
      if (origin != null) 'sp': origin.latlng,
      'ep': destination.latlng,
    },
  );
}

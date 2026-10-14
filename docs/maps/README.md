# Map references

Each page describes what map_launcher supports, the provider's URL formats and
parameters, and any platform-specific requirements. Links point to official
documentation or, where that is unavailable, the source used for the integration.

The parameter references also cover features the plugin does not implement.
Check the support section before using them. Native-app behavior has not been
device-tested; known documentation conflicts and version limits are noted beside
the affected fields. Source-check dates are not app compatibility guarantees.

For plugin usage, see [setup](../../README.md#setup),
[extras](../../README.md#extras) and the [v7 migration guide](../../MIGRATION.md#6x--70).
The [example Android manifest](../../example/android/app/src/main/AndroidManifest.xml)
and [iOS plist](../../example/ios/Runner/Info.plist) list all showcase providers;
copy only the declarations your app needs.

## Included providers

- [Apple Maps](apple.md)
- [Google Maps](google.md)
- [Google Maps Go](google-go.md)
- [Waze](waze.md)
- [Yandex Maps](yandex-maps.md)
- [Yandex Navigator](yandex-navigator.md)
- [2GIS](2gis.md)
- [HERE WeGo](here.md)
- [Mapy.cz / Mapy.com](mapy.md)
- [Mappls / MapmyIndia](mappls.md)
- [Amap / Gaode](amap.md)
- [Baidu Maps](baidu.md)
- [Tencent / QQ Maps](tencent.md)
- [Petal Maps](petal.md)
- [Citymapper](citymapper.md)
- [MAPS.ME](maps-me.md)
- [OsmAnd](osmand.md)
- [OsmAnd+](osmand-plus.md)
- [TomTom Go](tomtom-go.md)
- [TomTom Go Fleet](tomtom-go-fleet.md)
- [CoPilot](copilot.md)
- [Sygic Truck](sygic-truck.md)
- [Flitsmeister](flitsmeister.md)
- [Naver Map](naver.md)
- [KakaoMap](kakao.md)
- [TMAP](tmap.md)
- [Moovit](moovit.md)
- [Neshan](neshan.md)
- [Air Navigation Pro](air-navigation-pro.md) — detection and store metadata only;
  no supported marker or directions action.
- [Magic Earth](magic-earth.md)

## Requested apps

These apps are not included in the plugin. See [issue #111](https://github.com/mattermoran/map_launcher/issues/111)
for requests and discussion.

- [Uber](uber.md) — ride-request links.
- [Lyft](lyft.md) — ride-request links.
- [DB Navigator](db-navigator.md) — rail journeys; no confirmed coordinate-launch API.
- [Transit](transit.md) — public-transport directions.
- [TomTom MyDrive](tomtom-mydrive.md) — discontinued mobile app, distinct from GO.
- [Lazarillo](lazarillo.md) — no published inbound routing API found.
- [Organic Maps](organic-maps.md) — marker and route links; v2 documentation differs
  from the released parser.
- [Sygic GPS Navigation](sygic.md) — consumer app, distinct from Sygic Truck.

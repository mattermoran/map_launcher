## 3.5.0
- Add Mappls MapmyIndia (@Ajaay7 & @Saksham66)

## 3.4.0
- Remove support for apps using android v1 embedding

## 3.3.1
- Remove support for Maps.me on android as it stopped working a while ago

## 3.3.0
- Add privacy manifest
- Bump flutter min version to 3.13.0
- Bump dart min version to 3.1.0

## 3.2.0
- Add Mapy.cz (@TheHumr)

## 3.1.0
- Add Naver Map, KakaoMap and TMAP (@trentcharlie & @JulyWitch)
- Add support for AGP 7.4.2 and up (@bitsydarel)

## 3.0.1
- Rename Sygic to Sygic Truck
- Remove deprecated `launchMap` method. use `showMarker` instead

## 3.0.0
BREAKING: waypoints parameter now uses `List<Waypoint>` instead of `List<Coord>``
- Add CoPilot map (@tjeffree)
- Add Go Fleet and Sygic Truck maps (@amrahmed242)
- Add Flitsmeister and Truckmeister (@robinbonnes & @frankvollebregt)
- Add waypoint labels for Apple Maps (@manafire)
- Add support for gradle 8 (@m-derakhshi)
- Fix future not completing on iOS

## 2.5.0+1
- Update screenshots

## 2.5.0
- Add support for waypoints on Apple Maps

## 2.4.0
- Bump kotlin version to 1.5.31

## 2.3.0+1
- Cleanup

## 2.3.0
- Add TomTom Go #125 (@frankvollebregt)

## 2.2.3
- Fix empty title in Google Maps

## 2.2.2
- Fix `originTitle` on `showDirections` method

## 2.2.1+2
- Add dartdoc comments
- Update `directions_url.dart` formatting
- Update broken link in the README

## 2.2.1+1
- Update README with information that title should now work in Google Maps for Android starting from v11.12

## 2.2.1
- Update Petal maps icon

## 2.2.0
- Add Petal maps #103 (@mericgerceker)

## 2.1.2
- Replace jcenter with mavenCentral #100

## 2.1.1
- Fix iOS crash when using unsupported MapTypes #83 (@bridystone)

## 2.1.0
- Add OSMAnd+ #82 (@bridystone)
- Add Here WeGo #77 (@aleksandr-m)
- Add zoom level for OSMAnd on iOS #79 (@bridystone)
- Fix deprecation compiler warning in Xcode #78 (@bridystone)
- Bump minimum iOS version to 10

## 2.0.0+1
- Fix formatting

## 2.0.0
- Stable null safety

## 2.0.0-nullsafety.0
- Migrate to null safety
- Thanks to @LDevineau-eVtech

## 1.1.3+1
- Add warning for v1.1.3


## 1.1.3
Breaking change! See [here](https://github.com/mattermoran/map_launcher/issues/60#issuecomment-771388357) for migration

- Fix Android 11 not showing installed maps #58
- Thanks to @BasPhair, @olsisaqe

## 1.1.2

- Fix Tencent Maps and 2GIS url scheme on ios #56

## 1.1.1

- Add `extraParams` option to support passing additional query parameters that might be needed like api keys etc

## 1.1.0

- Add support for Tencent (QQ Maps)

## 1.0.0

- BREAKING CHANGE: not depending on flutter_svg anymore. See README for migration
- Add support for Google Maps GO
- Under the hood changes
- Thanks to @andoni97, @Pavel-Sulimau, @grinder15 for contribution

## 0.12.2

- Add import fallback for `#import <map_launcher/map_launcher-Swift.h>`
- Thanks to @fisherjoe

## 0.12.1

- Fix default zoom level

## 0.12.0

- Add support for 2GIS

## 0.11.0

- Add waypoints for Google Maps

## 0.10.0

- Add zoom parameter

## 0.9.0

- Add showDirections method
- Update example app

## 0.8.2

- Update flutter_svg constraint </br>
  Thanks to @tuarrep and @jcsena

## 0.8.1

- Fix #31 </br>
  Thanks to @LeonidVeremchuk

## 0.8.0

- Add support for android embedding v2

## 0.7.1

- Add constraint for flutter_svg

## 0.7.0

- Replace png icons with svgs </br>
  Thanks to @shinsenter

## 0.6.0

- Add support for Maps.Me and OsmAnd </br>
  Thanks to @gsi-yoan and @gsi-alejandrogomez

## 0.5.0

- Add support for Citymapper </br>
  Thanks to @Kiruel

## 0.4.5

- Fix Google Maps title issue on iOS </br>
  Thanks to @illiashvedov

## 0.4.4

- Specify swift version in map_launcher.podspec file

## 0.4.3

- Add license

## 0.4.2

- Add code to show title in Google Maps for Android. Should work once fixed in Google Maps. Update README.

## 0.4.1

- Update README file. Remove author field from pubspec.yaml

## 0.4.0

- Added support for Yandex Maps and Yandex Navigator </br>
  Updated icons

## 0.3.2

- Fixes #1 'MKCoordinateRegionMake' is unavailable in Swift </br>
  Thanks to @diegogarciar

## 0.3.1

- Throw a PlatformException if map is not installed

## 0.3.0

- Added Waze support

## 0.2.0

- Added method to check if map is available

## 0.1.3

- Added icons for maps
- Added iOS gif to README

## 0.1.2

- Migrate to AndroidX

## 0.1.1

- Update description in pubspec.yaml

## 0.1.0

- Get available maps on iOS and Android
- Launch maps with a marker

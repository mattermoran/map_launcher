# TomTom Go Fleet

## Current support

`TomTomGoFleet` is Android-only, targeting `com.tomtom.gplay.navapp.gofleet`. It inherits GO's destination-only directions and coordinate-marker fallback. Explicit origins, all explicit modes (including driving), and nonempty waypoints are rejected. iOS identifiers are null and both iOS builders return null. There is no universal URL or text search; directions title and marker zoom are not serialized.

See [provider and inherited builders](../../lib/src/maps/tomtom.dart). A valid license from a supported business partner app is required; ordinary GO subscriptions are not established as compatible.

Source check: **2026-10-02**. Fleet handling of the fallback intents remains unverified.

## Sources and licensing

| Source | Version/date, scope and accessibility |
| --- | --- |
| [Vendor's GO Fleet Play listing](https://play.google.com/store/apps/details?id=com.tomtom.gplay.navapp.gofleet&hl=en_US) | Retrieved listing says updated 2026-06-16; Android package `com.tomtom.gplay.navapp.gofleet`. Requires a valid license from a supported business partner app. Advertises receiving destinations/waypoints and sharing location/ETA, but supplies no intent schema. |
| [TomTom/Webfleet launch announcement](https://www.tomtom.com/newsroom/press-releases/general/234209672/tomtom-and-webfleet-solutions-collaborate-on-an-integrated-mobile-solution-for-professional-drivers-and-fleet-managers/) | Primary, 2022-02-16. Android Work App integration, destinations/ETA and truck-specific routing; historical commercial product evidence, not a public deep-link reference. |
| [Webfleet selection help](https://portals.webfleet.com/s/article/WEBFLEET-Work-App-How-and-where-can-I-select-the-TomTom-GO-Fleet-as-navigation-app) | Public response is a loading/CSS-error shell. No usable protocol text obtained; not evidence of a dead product or a valid API. |
| [Android map intents](https://developer.android.com/guide/components/intents-common#Maps), [Google navigation intents](https://developers.google.com/maps/documentation/urls/android-intents#launch_turn-by-turn_navigation) | Platform/Google references only, unversioned; not a Fleet contract. |

No current public GO Fleet-owned URL/deep-link/intent specification was located; marketing does not define proprietary partner fields. GO consumer URLs, TomTom Navigation SDK, Digital Cockpit and Routing API options are separate contracts. GO Expert marketing does not establish a replacement package or compatible launch API.

## URL formats and partner integration

| Action | Syntax/fields and limits | Status/source |
| --- | --- | --- |
| Display coordinate | `geo:lat,lon?q=lat,lon(label)`; title optional. Decimal latitude then longitude. Strings query-encoded. | Inherited implementation; [Android](https://developer.android.com/guide/components/intents-common#Maps) defines generic `geo:` display, including optional zoom 1…23 and address queries. Fleet handling unverified. |
| Directions | `google.navigation:q=lat,lon` with no `?`; destination required in builder | Inherited implementation. [Google](https://developers.google.com/maps/documentation/urls/android-intents#launch_turn-by-turn_navigation) defines this for Google Maps, not Fleet. |
| Dedicated Fleet integration | Endpoints, typed fields, requiredness, defaults, coordinate system, labels/encoding, stop limits, navigation controls and callbacks unknown | [Vendor listing](https://play.google.com/store/apps/details?id=com.tomtom.gplay.navapp.gofleet&hl=en_US) confirms partner integration exists, not its wire contract. |
| Vehicle/routing configuration | Vehicle dimensions, cargo/ADR and truck routes exist in product; no public launch keys or units established | [Vendor announcement](https://www.tomtom.com/newsroom/press-releases/general/234209672/tomtom-and-webfleet-solutions-collaborate-on-an-integrated-mobile-solution-for-professional-drivers-and-fleet-managers/) |

Coordinate bounds −90…90 latitude/−180…180 longitude and GPS/WGS84 are the normal geographic expectations, not a retrieved Fleet validation contract. No Fleet datum selector, label limit, route-avoidance selector, mode enum, origin field, waypoint serialization, callback registration, authentication field or maximum URL length is established. A partner-issued license is an explicit prerequisite; no claim is made that ordinary GO subscriptions work. Google's `mode`/`avoid` options cannot establish Fleet support.

## Compatibility limits

A `geo:` request expresses display/search, not guaranteed navigation. Installed-package detection establishes neither intent acceptance nor a valid license. Partner waypoints, vehicle restrictions and ETA exchange are unimplemented features with unavailable protocol details. Route replacement, title preservation, guidance initiation and partner-app return behavior remain unresolved; dedicated Fleet integration requires a supported partner contract.

# TomTom Go Fleet external launch audit

Checked **2026-10-02** against fetched origin/master and HEAD [8aa7a6e](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131). Implementation: `TomTomGoFleet` inherits the consumer builders in `lib/src/maps/tomtom.dart`.

## Primary evidence does not publish a launch schema

| Source | Version/date, scope and accessibility |
| --- | --- |
| [Vendor's GO Fleet Play listing](https://play.google.com/store/apps/details?id=com.tomtom.gplay.navapp.gofleet&hl=en_US) | Retrieved listing says updated 2026-06-16; Android package `com.tomtom.gplay.navapp.gofleet`. Requires a valid license from a supported business partner app. Advertises receiving destinations/waypoints and sharing location/ETA, but supplies no intent schema. |
| [TomTom/Webfleet launch announcement](https://www.tomtom.com/newsroom/press-releases/general/234209672/tomtom-and-webfleet-solutions-collaborate-on-an-integrated-mobile-solution-for-professional-drivers-and-fleet-managers/) | Primary, 2022-02-16. Android Work App integration, destinations/ETA and truck-specific routing; historical commercial product evidence, not a public deep-link reference. |
| [Webfleet selection help](https://portals.webfleet.com/s/article/WEBFLEET-Work-App-How-and-where-can-I-select-the-TomTom-GO-Fleet-as-navigation-app) | Public response is a loading/CSS-error shell. No usable protocol text obtained; not evidence of a dead product or a valid API. |
| [Android map intents](https://developer.android.com/guide/components/intents-common#Maps), [Google navigation intents](https://developers.google.com/maps/documentation/urls/android-intents#launch_turn-by-turn_navigation) | Platform/Google references only, unversioned; not a Fleet contract. |

No current public GO Fleet-owned URL/deep-link/intent specification was located. An exhaustive proprietary partner field inventory cannot honestly be supplied from marketing material. GO consumer URLs, TomTom Navigation SDK, Digital Cockpit and Routing API options must not be transplanted into Fleet. Current GO Expert marketing is also not proof of a replacement package or compatible launch API.

## Implemented fallback and unknown dedicated surface

| Action | Syntax/fields and limits | Status/source |
| --- | --- | --- |
| Display coordinate | `geo:lat,lon?q=lat,lon(label)`; title optional. Decimal latitude then longitude. Strings query-encoded. | Inherited implementation; [Android](https://developer.android.com/guide/components/intents-common#Maps) defines generic `geo:` display, including optional zoom 1…23 and address queries. Fleet handling unverified. |
| Directions | `google.navigation:q=lat,lon` with no `?`; destination required in builder | Inherited implementation. [Google](https://developers.google.com/maps/documentation/urls/android-intents#launch_turn-by-turn_navigation) defines this for Google Maps, not Fleet. |
| Dedicated Fleet integration | Endpoints, typed fields, requiredness, defaults, coordinate system, labels/encoding, stop limits, navigation controls and callbacks unknown | [Vendor listing](https://play.google.com/store/apps/details?id=com.tomtom.gplay.navapp.gofleet&hl=en_US) confirms partner integration exists, not its wire contract. |
| Vehicle/routing configuration | Vehicle dimensions, cargo/ADR and truck routes exist in product; no public launch keys or units established | [Vendor announcement](https://www.tomtom.com/newsroom/press-releases/general/234209672/tomtom-and-webfleet-solutions-collaborate-on-an-integrated-mobile-solution-for-professional-drivers-and-fleet-managers/) |

Coordinate bounds −90…90 latitude/−180…180 longitude and GPS/WGS84 are the normal geographic expectations, not a retrieved Fleet validation contract. No Fleet datum selector, label limit, route-avoidance selector, mode enum, origin field, waypoint serialization, callback registration, authentication field or maximum URL length is established. A partner-issued license is an explicit prerequisite; no claim is made that ordinary GO subscriptions work. Google's `mode`/`avoid` options cannot establish Fleet support.

## Implementation findings

* **Concrete flag mismatch:** inherits acceptance of every `TravelMode`, but serializes none. No walking/transit/cycling contract was found. This should not be represented as fulfilled mode selection.
* Android-only metadata is deliberate: null `iosScheme` and App Store ID prevent consumer GO from being reported as Fleet. Directly calling the inherited builder with iOS still emits a **consumer** `tomtomgo://` URL; it is not Fleet support and needs a guard/test if raw builders promise platform validity.
* Coordinates and marker capabilities are inherited true; search, waypoints and universal links false. A `geo:` request is display/search, not a guaranteed start-navigation command. Installed-package detection does not prove that a package accepts either URI or has a valid license.
* Partner waypoints, vehicle restrictions and ETA exchange are **unimplemented product features with unavailable protocol details**, not fields that can safely be guessed. Origin, directions title and zoom are ignored.

## Tests and outstanding verification

Use asymmetric destination `(52.090737,5.121420)`, origin `(51.924420,4.477733)` and a third waypoint. Assert exact target package, `google.navigation:q=` (not `:?q=`), latitude/longitude order, encoded marker title `Depot & Café`, and rejection of modes not represented in the URL. Verify Fleet is absent from iOS discovery even with consumer GO installed, and the raw iOS-builder inconsistency separately.

No Fleet device or partner license was available for this audit. On a licensed Android device test both URIs independently, cold/warm start, existing itinerary, title preservation, arrival/navigation state and partner-app return behavior. Obtain the supported partner integration contract before adding waypoints or truck profile fields. Also test an installed but unlicensed app: a successful activity launch must not be reported as verified route delivery.

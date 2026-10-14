# TomTom Go

## Current support

`TomTomGo` supports destination-only directions on Android and iOS, and coordinate markers on Android. Explicit origins, all explicit travel modes (including driving), and nonempty waypoints are rejected. iOS marker builders return null because the known endpoint navigates rather than displays a passive pin. No universal URL or text-search action is provided; directions labels and marker zoom are not serialized.

Configuration: Android package `com.tomtom.gplay.navapp`; iOS App Store ID `884963367`, query scheme `tomtomgo`. See [provider](../../lib/src/maps/tomtom.dart), [capabilities](../../lib/src/maps/map_app.dart), and [URL encoding](../../lib/src/utils/url_builder.dart).

Source check: **2026-10-02**. Native dispatch and navigation behavior remain unverified.

## Evidence and product boundary

No current public TomTom-owned GO app launch specification was located. Do not substitute the [Maps and Navigation SDK](https://docs.tomtom.com/navigation/android/introduction/introduction), Routing API, Digital Cockpit, legacy Navigator, GO Fleet, or GO Expert feature lists for a GO app URL contract. The SDK documentation has moved from developer.tomtom.com to docs.tomtom.com; its embedded navigation APIs are not app-launch parameters.

| Source | Status/version and what it proves |
| --- | --- |
| [Original GO iOS announcement](https://discussions.tomtom.com/en/discussion/1118783/url-schemes-for-go-navigation-ios) | Historical primary forum URL; live fetch failed with connection error on check date. Not a verified current specification and not an inspected archive. |
| [Stack Overflow answer](https://stackoverflow.com/a/59425154) | Secondary, 2019-12-20; quotes that announcement and `tomtomgo://x-callback-url/navigate?destination=latitude,longitude`. |
| [Independent TomTom forum report](https://www.tomtomforums.com/threads/ios-url-scheme-for-launching-navigation-from-another-app-through-deeplinking.35034/) | Secondary, 2025-03-01; reports GO 3.9.11 on iOS 18.3.1/iPhone 12 Pro. Same URL worked with downloaded maps and GPS location on the same map. This site is not TomTom's official documentation. |
| [Android common map intents](https://developer.android.com/guide/components/intents-common#Maps) | Current platform documentation, unversioned. Defines `geo:` display/search semantics, not GO support. |
| [Google Maps Android intents](https://developers.google.com/maps/documentation/urls/android-intents#launch_turn-by-turn_navigation) | Current Google-owned app protocol, unversioned. Defines `google.navigation:q=…`; does not guarantee that TomTom implements Google's optional fields. |

## Publicly evidenced launch surface

“Unknown” means not specified by the identified GO evidence, not proven unsupported. No complete current GO-owned public action inventory was found.

| Endpoint/action | Fields, requiredness and semantics | Evidence |
| --- | --- | --- |
| iOS `tomtomgo://x-callback-url/navigate` | `destination` required by the only evidenced form: comma-separated decimal **latitude,longitude**. Signed values; no label, origin or intermediate-stop field evidenced. Physical latitude/longitude bounds are −90…90/−180…180; app rejection/clamping and explicit datum are undocumented. GPS/WGS84 is the interoperability expectation, not an explicit GO contract found here. | [2019 example](https://stackoverflow.com/a/59425154), [2025 device report](https://www.tomtomforums.com/threads/ios-url-scheme-for-launching-navigation-from-another-app-through-deeplinking.35034/) |
| Android `geo:lat,lon` | Platform map display. Optional `z` integer 1…23; `q=lat,lon(label)` or address query; canonical labeled example uses `geo:0,0`. Encode strings; spaces `%20` or `+`. These are platform fields, not confirmed GO features. | [Android](https://developer.android.com/guide/components/intents-common#Maps) |
| Android `google.navigation:q=lat,lon` | `q` destination required; no `?` after colon. Google also accepts address text, optional `mode=d` (default), `b`, `l`, `w`, and `avoid=t/h/f` combinations. **Those options are not established for GO.** | [Google](https://developers.google.com/maps/documentation/urls/android-intents#launch_turn-by-turn_navigation); repository implementation for GO |

The iOS endpoint name is not evidence that `x-success`, `x-error`, `x-cancel`, caller identity, or return callbacks work. No callback/API-key requirement, travel-mode selector, route policy, waypoint count, zoom, title limit, automatic-navigation guarantee, or URL-length limit was located for GO. Ordinary app subscription/map availability can still gate navigation; the URL is not a license activation mechanism. The secondary report's attempted `?name=` used a second `?`; its failure is **not** proof that correctly encoded `&name=` is unsupported, but neither form has a documented GO contract.

## Builder behavior and compatibility limits

Android markers use `geo:lat,lon?q=lat,lon(title)` with query-encoded titles. Android directions use `google.navigation:q=…`, deliberately without `?` after the colon. iOS directions encode `destination` in the evidenced navigate endpoint. The generic marker capability is not platform-specific; it does not override the null iOS builder.

GO acceptance of the Android intents, parenthesized label parsing, route replacement, GPS/map/subscription requirements, and preview versus active guidance remain unresolved. Correct URL generation does not establish native route delivery.

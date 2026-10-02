# TomTom Go external launch audit

Checked **2026-10-02** against [8aa7a6e](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131). `git fetch origin master` confirmed that both HEAD and origin/master resolve to that commit. It changes example discovery refresh, not these builders. Implementation: `lib/src/maps/tomtom.dart`, inherited capabilities in `map_app.dart`, encoding in `utils/url_builder.dart`.

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

## Implementation comparison

| Current behavior | Assessment |
| --- | --- |
| iOS markers and directions both call `navigate?destination=…`; markers advertised true | Concrete semantic mismatch: the marker operation is implemented as navigation, not a dedicated show-pin action. Flag is not platform-specific. |
| Android marker uses `geo:lat,lon?q=lat,lon(title)` | Generic fallback, package-targeted to `com.tomtom.gplay.navapp`; not a dedicated TomTom protocol. Title is query-encoded by `buildUrl`; zoom ignored. |
| Android directions use `google.navigation:q=…`, removing the initial `?` | Correct spelling relative to Google's protocol. Actual GO acceptance still requires device evidence; do not “fix” by restoring `?`. |
| Inherits `supportsTravelMode => true`, ignores every requested mode | Concrete capability/serialization mismatch. Walking, cycling and transit are not represented. Narrow advertised modes or implement only independently verified alternatives. |
| No universal URL, search or waypoints; origin and title ignored in directions | Implementation limitations. No GO-owned evidence makes these missing dedicated options proven bugs. |

## Discriminating checks and device gaps

Propose exact URL tests with destination `(50.71035,-1.995259)`, distinct origin `(51.5,-0.12)` and a third waypoint, rather than equal coordinates. Assert Android starts `google.navigation:q=` and not `google.navigation:?q=`; decode `destination` on iOS and `q` on Android. For marker labels use `A & B + Café (West)` and verify a single decode, then test how GO interprets parentheses. Enumerate every travel mode and distinguish request acceptance from mode actually encoded. Assert iOS marker requests cannot be claimed to provide a dedicated display action.

No current GO binary was launched in this audit. Test cold/warm starts, existing route replacement, GPS missing, subscription missing, map unavailable, and actual navigation start versus a route-preview screen. Record app/OS versions and whether the Android package accepts each intent. URL generation tests alone cannot settle these points.

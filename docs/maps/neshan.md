# Neshan external links

Checked **2026-10-02** against the Persian provider FAQ headed **«چگونه از اپلیکیشن‌ها و برنامه‌های خود، کاربران را به برنامه نشان هدایت کنیم؟ (intent link های نشان)»** on [Neshan Platform](https://platform.neshan.org/). **Availability qualification:** direct live page and `/faq/` fetches timed out in this environment; the provider-owned page's complete relevant FAQ was available through the search index. This is primary-provider text retrieved indirectly, not a successful fresh live fetch. No source revision date, minimum app version, or formal schema was exposed. No native application was tested.

Baseline: [`8aa7a6e`](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131), verified as fetched `origin/master`; [builder](../../lib/src/maps/neshan.dart), [base capabilities](../../lib/src/maps/map_app.dart).

## Platform-specific action contract

The FAQ explicitly distinguishes Android/web HTTPS links from iOS custom deep links. It says an installed app opens and otherwise users go to the web. That general prose must not be interpreted as an automatic browser fallback for an unhandled `neshan://` URL on iOS; callers still need an absent-app strategy.

Source for every field below: [provider Persian FAQ](https://platform.neshan.org/), retrieval limitation above. “Needed” refers to constructing the shown action; the page only explicitly calls iOS `vehicle` optional and does not publish formal requiredness for every other field.

| Platform / action | URL | Fields / meaning |
| --- | --- | --- |
| Android and web: point on map | `https://nshn.ir/?lat={lat}&lng={lng}` | Numeric decimal `lat` latitude and `lng` longitude needed to identify point. |
| iOS: point on map | `neshan://?ll={lat},{lng}` | **`ll`**, comma-separated latitude,longitude; no `destination` in the documented display action. |
| Android and web: route | `https://nshn.ir?origin={lat},{lng}&destination={lat},{lng}&vehicle=d` | `origin`, `destination` are comma-separated latitude,longitude pairs; both supplied in documented two-point route. `vehicle` values below. |
| iOS: route | `neshan://?origin={lat},{lng}&destination={lat},{lng}&vehicle=d` | Same coordinate pairs. iOS examples demonstrate omission of optional `vehicle`, not omission of `origin`. |

No explicit geographic ranges, CRS name, precision limit, URL length, label length, or route-distance limits are given in the deep-link FAQ. Coordinates are latitude/longitude in decimal degrees; WGS84 is a conventional interpretation, not an explicit FAQ declaration. The provider map's OpenStreetMap data attribution does not establish a different query coordinate order or an API attribution parameter. Do not import REST service headers, route geometry order, or projected SDK coordinates into these links.

### Vehicle values differ by platform

Source: [Persian FAQ](https://platform.neshan.org/). The original distinguishes **دوچرخه** (bicycle) from **موتور** (motorcycle), so these are not interchangeable.

| `vehicle` | Persian meaning | Android/web documented | iOS documented |
| --- | --- | --- | --- |
| `d` | ماشین — car | Yes; example selects it; omitted default not explicitly stated | Yes; **default** |
| `m` | موتور — motorcycle | Yes | Yes |
| `b` | دوچرخه — bicycle | Not listed | Yes |
| `p` | حمل‌ونقل عمومی — public transport | Not listed | Yes |
| `w` | پیاده‌روی — walking | Not listed | Yes |

Absence from the Android/web list means **not documented by this source**, not proof that every app version rejects the value. The general consumer app supports more travel modes than this documented external interface exposes.

### Encoding, omitted actions, and authentication

Build query values with percent encoding once; comma-separated pairs may become `%2C` in transport, but should decode to the provider's `lat,lng` form. The examples use literal commas and a dot decimal separator; locale-formatted decimal commas would be ambiguous. No text-label field is documented.

The FAQ does **not** document keyword search, place IDs, marker names, zoom, layers, waypoints/multiple destinations, route policies (toll/highway/traffic-zone avoidance), timing, immediate-navigation flags, callback/return URLs, caller `appname`, API keys, or URL attribution fields. The authenticated REST route API and SDK offer different capabilities; those parameters are not evidence of app-link support. `nshn.ir/{shortcode}` sharing links may exist in consumer workflows, but no shortcode creation/decoding contract is established by this FAQ.

## Implementation comparison

| Field / capability | Current behavior | Assessment |
| --- | --- | --- |
| Android marker | `https://nshn.ir?lat={lat}&lng={lng}` | Matches documented field names and order. Missing literal slash before `?` is not evidence of failure; empty HTTP path is normally `/`. |
| iOS marker | `neshan://?destination={lat},{lng}` | **Documented-action mismatch:** provider specifies `ll` for displaying a point. Current key belongs to routing. Whether a particular app happens to display the point is device-unverified. |
| Route | HTTPS on Android, `neshan://` on iOS; `destination` and optional `origin` | Correct platform forms and pair order. FAQ examples provide both endpoints; current-location fallback for an absent origin remains unverified. |
| Travel modes | Ignores argument, emits no `vehicle`; inherited `supportsTravelMode` returns true for all four generic modes | **Demonstrable capability/builder mismatch.** iOS omission selects default car; other requested modes are not represented. Android/web list is narrower still. |
| Waypoints | Ignored, `supportsWaypoints=false` | No launch waypoint contract found; do not assume REST waypoint support transfers. |
| Marker title / zoom | Ignored | Neither documented in FAQ; not a demonstrated bug. |
| Web methods | Both null; `hasUniversalLink=false`, despite HTTPS Android scheme-builder output | Provider documents Android/**web** HTTPS links, so standalone web support is an omitted feature. HTTPS link existence alone does not prove iOS universal-link behavior. |
| Search / callback / policy / auth | Not implemented | No corresponding launch fields established. Search flags false accurately describe builder. |

The builder's Android package is `org.rajman.neshan.traffic.tehran.navigator` and its iOS detection scheme is `neshan://`. App-store metadata is not the launch-parameter contract; do not claim this audit validates its store ID.

## Concrete follow-up tests

1. An iOS marker contract test should independently expect `ll=35.844218357081935,50.99743076230513`, and **no `destination`**. Android should expect separate `lat`/`lng`, not `ll`.
2. Distinct route fixtures: origin `(35.844218,50.997431)` and destination `(35.843066,50.988970)`. Assert exact decoded endpoint order and platform-specific base.
3. If mode support is implemented, assert iOS driving→`d`, bicycling→`b`, transit→`p`, walking→`w`. Motorcycle `m` needs a distinct product/API choice, not reuse of bicycling. Android should advertise only confirmed launch modes; test unsupported requests explicitly.
4. Keep “origin omitted” separate from a known two-point route in both unit and device tests. Do not generate an origin from destination merely to satisfy a fixture.
5. Test web fallback and iOS installed/absent behavior on real devices/browsers, then verify marker versus route screen and no-origin behavior. First re-fetch the FAQ live or obtain provider confirmation for the platform-specific mode list; indexed text may lag current deployment.

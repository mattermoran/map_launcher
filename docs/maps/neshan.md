# Neshan

Checked: **2026-10-13**. Native-device behavior has not been verified.

## Plugin behavior

The [builder](../../lib/src/maps/neshan.dart) uses HTTPS `nshn.ir` markers with `lat/lng` on Android and `neshan://?ll=lat,lng` on iOS. Routes use the same platform transports with `destination` and optional `origin`. iOS driving/walking/transit/bicycling serialize `vehicle=d/w/p/b`; Android accepts explicit driving only and returns null for the other modes. Omitted mode leaves `vehicle` absent. The global [mode capability](../../lib/src/maps/map_app.dart) cannot express this platform distinction. Title, zoom, search, waypoints and standalone web builders are not implemented. Omitted-origin fallback remains unverified.

Source: the live Persian FAQ **«چگونه از اپلیکیشن‌ها و برنامه‌های خود، کاربران را به برنامه نشان هدایت کنیم؟ (intent link های نشان)»** on [Neshan Platform](https://platform.neshan.org/). It gives no revision date, minimum app version or formal schema.

## Platform-specific action contract

The FAQ explicitly distinguishes Android/web HTTPS links from iOS custom deep links. It says an installed app opens and otherwise users go to the web. That general prose must not be interpreted as an automatic browser fallback for an unhandled `neshan://` URL on iOS; callers still need an absent-app strategy.

“Needed” refers to constructing the shown action; the FAQ only explicitly calls iOS `vehicle` optional and does not publish formal requiredness for every other field.

| Platform / action | URL | Fields / meaning |
| --- | --- | --- |
| Android and web: point on map | `https://nshn.ir/?lat={lat}&lng={lng}` | Numeric decimal `lat` latitude and `lng` longitude needed to identify point. |
| iOS: point on map | `neshan://?ll={lat},{lng}` | **`ll`**, comma-separated latitude,longitude; no `destination` in the documented display action. |
| Android and web: route | `https://nshn.ir?origin={lat},{lng}&destination={lat},{lng}&vehicle=d` | `origin`, `destination` are comma-separated latitude,longitude pairs; both supplied in documented two-point route. `vehicle` values below. |
| iOS: route | `neshan://?origin={lat},{lng}&destination={lat},{lng}&vehicle=d` | Same coordinate pairs. iOS examples demonstrate omission of optional `vehicle`, not omission of `origin`. |

No explicit geographic ranges, CRS name, precision limit, URL length, label length, or route-distance limits are given in the deep-link FAQ. Coordinates are latitude/longitude in decimal degrees; WGS84 is a conventional interpretation, not an explicit FAQ declaration. The provider map's OpenStreetMap data attribution does not establish a different query coordinate order or an API attribution parameter. Do not import REST service headers, route geometry order, or projected SDK coordinates into these links.

### Vehicle values differ by platform

The Neshan Platform FAQ distinguishes **دوچرخه** (bicycle) from **موتور** (motorcycle), so these are not interchangeable.

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

## Integration limits

Android discovery targets `org.rajman.neshan.traffic.tehran.navigator`; iOS discovery uses `neshan://`. Motorcycle `m` has no generic `TravelMode` equivalent. Nonempty waypoint requests are rejected; direct builders omit them. The FAQ's Android/web HTTPS surface is broader than the plugin's mobile-only methods, and does not establish iOS Universal Links.

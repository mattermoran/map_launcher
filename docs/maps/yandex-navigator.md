# Yandex Navigator

The plugin opens native coordinate markers and driving routes with optional coordinate origins and ordered zero-based via pairs. Omitted/driving mode is accepted; other explicit modes are rejected by capabilities and the direct builder. Search and browser builders are not exposed. Android targets `ru.yandex.yandexnavi`; iOS callers declare `yandexnavi`. `YandexNaviExtra` carries caller identity/signature but does not sign URLs; quota and exact-byte requirements below matter for production launches.

Reference check: 2026-10-13.

## Sources

- [Launch overview](https://yandex.com/dev/yandex-apps-launch/navigator): public English overview, access-key requirement and Russian documentation link.
- [Native app launch](https://yandex.ru/dev/navigator/doc/ru/): Android and iOS launch instructions; bare scheme displays current location.
- [URL format and actions](https://yandex.ru/dev/navigator/doc/ru/concepts/navigator-url-params): route, search and marker fields.
- [Launch restrictions](https://yandex.ru/dev/navigator/doc/ru/concepts/navigator-commercial-use): applies to **Navigator 2.40+**.
- [Client identification and signing](https://yandex.ru/dev/navigator/doc/ru/concepts/navigator-commercial-use-signature): precise signature process.

Examples use legacy native APIs/Python 2, without a stated protocol retirement. Old `/dev/yandex-apps-launch/navigator/doc/concepts/…html` addresses redirect to `/dev/navigator/doc/ru/…`.

## Native launch families and action fields

References: Native app launch and URL format/actions above.

The family is `yandexnavi://[action?parameters]`. Android uses `Intent.ACTION_VIEW` and package `ru.yandex.yandexnavi`; omitting a target can allow a handler chooser. iOS uses `openURL` and checks `canOpenURL`. The docs give store fallback examples, not a same-action universal HTTPS URL. Bare `yandexnavi://` shows current location and is exempt from URL-data launch counting.

| Action/field | Type and requirement | Meaning/default/range/limit |
| --- | --- | --- |
| `build_route_on_map` | Route action | Builds a driving route; no travel-mode field, avoidance, departure time, or auto-start switch listed. Do not equate opening a route with confirmed guidance start. |
| `lat_to`, `lon_to` | Required floats for destination route | Separate latitude and longitude values, respectively. Geographic decimal examples; no named datum or numeric validation bounds specified. |
| `lat_from`, `lon_from` | Optional paired floats | Explicit origin. Omit **both** for current-user-position routing; destination-only example is explicitly documented. No behavior given for only half a pair. |
| `lat_via_N`, `lon_via_N` | Optional paired floats for multi-point route | Ordered intermediate points. `N` is a zero-based integer: `0`, `1`, …; both coordinates per point. Several points supported; **no numeric maximum** stated. No stopover/pass-through distinction or optimization option. |
| `map_search` | Search action | Searches city, street, organization or other query. No viewport/nearby radius options listed. |
| `text` | Required string for search | Reserved characters must be encoded, e.g. `cash&carry` → `cash%26carry`; no length limit stated. |
| `show_point_on_map` | Marker/map action | Centers on supplied coordinate. |
| `lat`, `lon` | Required floats for marker | Latitude and longitude in separate named fields. No combined-pair ambiguity. |
| `zoom` | Optional integer | **1–18**, default **18**; 1 world/least detailed, 18 most detailed. |
| `no-balloon` | Optional integer flag | `0` default: show marker; `1`: hide marker. Despite field name, source describes marker visibility. |
| `desc` | Optional string | Balloon text; omitted value defaults to object's address. Reserved characters must be URL-encoded; no length limit stated. |

The action list does not document HTTPS equivalents, callbacks, success/error return URLs, x-callback-url, result selection callbacks, camera bearing, language, traffic toggles, truck fields, or URL length limits. “Not documented” is not proof of app rejection. Do not reuse Maps `rtext`, `rtt`, `pt`, or REST API `waypoints` here.

### Omitted origin with intermediate points remains a combination to verify

The [destination-only section](https://yandex.ru/dev/navigator/doc/ru/concepts/navigator-url-params#route-to) says to omit the origin for current-position routing. The [multi-point section](https://yandex.ru/dev/navigator/doc/ru/concepts/navigator-url-params#route-via) instructs callers to supply start, end, and intermediate coordinates; its example contains an explicit start. It does **not** explicitly forbid omission with waypoints, but it also does not explicitly demonstrate that combination. The package emits only `lat_to/lon_to` and indexed `lat_via_N/lon_via_N` when origin is null. Keep that serialization distinct from proof the app preserves all points while using GPS as origin. No empty string coordinate values are necessary in this scheme.

## Identification, quotas and signature encoding

References: Launch restrictions and client identification/signing above.

| Field/rule | Type/requiredness | Published behavior |
| --- | --- | --- |
| `client` | String identifier supplied at registration | Included in URL before calculating signature. Keep as string: sample `007` must not become `7`. One identifier can serve several caller apps. |
| `signature` | String; signed launches | RSA PKCS#1 v1.5 SHA-256 signature over **the complete source URL including `client`, excluding `signature`**; base64 output then URL-encode once. Not a key, token, or reusable request-independent signature. |
| Signing key | Registered RSA private key, not a URL field | PEM PKCS#1 delivered; conversion examples given. Never place private key bytes in `extra`, logs or a URL. |
| Unsigned data launches | 2.40+; counted per device | After **5 URL launches in 24 hours**, subsequent launches open Navigator's webpage in the mobile browser instead of the app. Count is across such launches on one device, not described as a per-caller quota. |
| Exempt launches | Bare scheme, signed URL, app icon, pre-2.40 app | These do not increase the URL counter per source. Signed launch exemption is not a guarantee that every route is otherwise valid. |

Sign the exact serialized, encoded URL that will be sent. Reordering parameters, changing spaces from `%20` to `+`, adding an extra field, or signing one coordinate format and sending another changes signed bytes. With a query-encoding API, pass raw base64 signature text so it is escaped once; passing already percent-encoded signature text risks `%` becoming `%25`. The provider's signing page demonstrates both pre-encoded complete URL assembly and APIs that encode raw query values; do not combine both encodings.

## Plugin limitations

Code: [builder](../../lib/src/maps/yandex_navi.dart), [typed extras](../../lib/src/extras/yandex_navi_extra.dart), [capabilities](../../lib/src/maps/map_app.dart), [encoding](../../lib/src/utils/url_builder.dart), [launch extras](../../lib/src/utils/launch_helper.dart).

| Capability | Current implementation | Assessment |
| --- | --- | --- |
| Marker | `lat`, `lon`, optional `zoom`, `no-balloon=0`, title → `desc` | Matches documented fields and explicit visible-marker default. No zoom range validation in provider builder. |
| Route | Destination, optional complete origin pair, contiguous zero-based via pairs | Matches names and indexing; combined omitted-origin/waypoint behavior needs native verification. |
| Modes | Omitted/driving allowed; other explicit modes rejected | Public route action is driving and has no mode selector. |
| Search | No native search builder; flags false | `map_search?text=` is documented but omitted. Generic `text` extra on `show_point_on_map` does not change action. |
| Web fallback | Marker/directions HTTPS builders return null | Consistent with no documented equivalent here; store/web fallback needs separate caller policy. |
| Typed extras | `YandexNaviExtra(client, signature)` holds nullable strings | No signature computation, pairing enforcement or final-URL signing hook. Supply raw base64 and sign exact final bytes. |
| Extra collisions | Query append at launch | Identical built-in values are retained once; conflicts exclude discovery entries or cause `MapLaunchException` on explicit launch. `no-balloon=1` conflicts with built-in `0`. |

Callers can precompute a signature for exact output; the plugin preserves existing URL bytes when adding extras. Any newly appended field must already be included in the signed source URL.

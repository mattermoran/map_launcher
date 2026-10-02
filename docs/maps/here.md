# HERE WeGo: external launch audit

Checked **2026-10-02** against [8aa7a6e](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131), fetched and verified on `origin/master`. Research only; **no native device testing**.

## Status and sources

**The HTTPS builder uses the current share-link family, but omits documented waypoints, current-location syntax, place sharing, settings, and other routing options.** Its destination-only path is outside the documented two-or-more-waypoint route grammar. App rejection has not been demonstrated.

Primary source set, all read in full; dates below are each page's explicit `updatedAt`, not inferred release dates:

- [Introduction](https://docs.here.com/wego-pro/docs/readme-here-deeplinking-api-developer-guide-dl), **2026-03-10**.
- [URL format](https://docs.here.com/wego-pro/docs/request-format-dl), **2026-06-16**.
- [Location sharing](https://docs.here.com/wego-pro/docs/share-location-dl), **2026-03-10**.
- [Place sharing](https://docs.here.com/wego-pro/docs/share-place-dl), **2026-03-10**.
- [Route sharing](https://docs.here.com/wego-pro/docs/share-route-dl), **2026-07-27**.
- [Settings sharing](https://docs.here.com/wego-pro/docs/share-settings-dl), **2026-06-17**.
- [Device activation](https://docs.here.com/wego-pro/docs/activate-device-dl), **2026-05-14**.
- [Errors](https://docs.here.com/wego-pro/docs/errors-dl), **2026-03-10**.
- [Pro deeplinking overview](https://docs.here.com/wego-pro/docs/deeplinking), **2026-05-14**; says links can directly navigate to a destination/sequence of stops. It does not introduce a separate `navigate` parameter.

The [official section index](https://docs.here.com/wego-pro/docs/here-deeplinking-api-developer-guide/llms.txt) exposed all seven action/reference pages and machine-readable `.md` variants. No page in that set was inaccessible. Although hosted under `wego-pro`, the reference describes ordinary consumer location/place/route sharing as well as explicitly licensed Pro features; **do not label the entire API Pro-only**. No secondary source is used as a parameter authority.

## Shared URL grammar and common fields

Source: [URL format](https://docs.here.com/wego-pro/docs/request-format-dl).

`https://share.here.com/{share_object}/{path_parameters}?{query_parameters}` uses HTTP **GET**. Android `ACTION_VIEW` and iOS `openURL` examples both use HTTPS; native custom-scheme action grammars such as `here-location://` are not documented in this current reference. The repository's scheme is an installation probe, not an implemented launch family.

| Field | Type/requiredness | Values/defaults/limits |
| --- | --- | --- |
| `share_object` | Required one-letter path discriminator | `l` location, `p` place, `r` route, `s` app settings, `a` Pro activation. |
| Path payload | Required according to action | Coordinates, sharing ID, route waypoints, settings category, or activation key. |
| `t` | Optional map-type string; common | `normal` default, `hybrid`, `traffic`, `satellite`, `pt`; closest supported variant if platform cannot display requested type. Reference bullet formatting around traffic/satellite is awkward, but satellite is listed. **Ignored by current WeGo mobile app.** |
| `z` | Zoom number; common | **0–20**. URL-format page calls it mandatory for location sharing; location page calls zoom optional and gives no-zoom URLs. **Conflicting primary guidance**, not an established runtime failure. **Ignored by current WeGo mobile app.** No default or explicit integer-only declaration supplied. |
| `ref` | Referrer string; no mandatory designation | Unique identifier for original link issuer. No length constraint or callback semantics. |

Coordinates in location and route payloads are **latitude,longitude in decimal degrees**. No named datum, coordinate range, precision restriction, or total URL length limit is stated in these launch pages. Do not copy REST/SDK schemas to fill those gaps. Encode titles as individual path data before combining delimiters. Query values are separately URL-encoded.

## Location and place actions

Sources: [location](https://docs.here.com/wego-pro/docs/share-location-dl) and [place](https://docs.here.com/wego-pro/docs/share-place-dl).

| Action/field | Requirement and type | Semantics/defaults |
| --- | --- | --- |
| `/l/{lat},{lon}` | Both coordinates required | Share an exact location. |
| `/l/{lat},{lon},{title}` | Optional string title | Custom bubble title; **must be URL-encoded**. No title limit stated. |
| `p` query parameter on location | Optional string enum `yes` / `no` | Display pin; default **`yes`**. Distinct from `/p/` share-object path. |
| `/p/{PLACE-IDENTIFIER}` | Required sharing ID | Obtain from WeGo website or mobile app. Opaque sharing token, not arbitrary address text or an interchangeable REST place ID. No documented token-construction algorithm. |

No free-text search launch action is listed in the current Deeplinking API. Place sharing is not equivalent to a query string search endpoint. Common map fields apply subject to mobile ignoring `t`/`z`.

## Route parameters and waypoint grammar

Source: [route sharing](https://docs.here.com/wego-pro/docs/share-route-dl).

| Field | Type/requiredness | Values/defaults/constraints |
| --- | --- | --- |
| `/r/{waypoint}/{waypoint}/…` | **Two or more** slash-separated waypoints | First departure, last destination; up to **100 total waypoints**, suggested soft limit **50** due to title lengths/device limits. These counts include endpoints. |
| Coordinate waypoint | `lat,lon` | Decimal-degree coordinates, latitude first. |
| Title | Optional third comma field | `lat,lon,title`; URL-encode custom title, including comma/slash so they do not create fields/waypoints. |
| Sharing-ID waypoint | String alternative | A place Sharing ID can be used instead of coordinates. |
| `mylocation` waypoint | String keyword alternative | Use current location **when possible**; allowed as any waypoint. This is the documented way to request current-position origin while retaining a destination, not a claim that dropping the first path segment is equivalent. |
| `m` | Optional routing-mode string | `d` driving, `w` walking, `pt` transit, `b` bicycle, `cs` car sharing, `t` taxi, `tr` truck. No default given for omission. Truck requires Pro; non-entitled devices show car route instead. |
| `a` | Optional avoidance string | Examples use comma-separated `tunnel,motorway`. The fetched reference does **not** supply a complete enum/default or semantics for other values. Do not import REST avoid-feature names. |
| Waypoint type | Optional fourth comma field | `lat,lon,title,s` stopover or `lat,lon,,p` pass-through. Default stopover; origin/destination always stopovers. See licensing ambiguity below. |

The waypoint-type section follows the “HERE WeGo Pro requirements” heading and does not explicitly repeat its entitlement rule. Treat Pro applicability as **source-layout ambiguity**, not a promise all consumer versions support pass-through. A source example for omitted type contains extra commas and the final example has a stray quote; rely on the stated four-field grammar, not these typographical artifacts.

No explicit callback, return-to-caller, completion URL, or `navigate=true` field is documented. The Pro overview says direct navigation is possible, but this route reference describes route sharing; do not promise universal automatic guidance without app-version/entitlement testing. Location unavailability for `mylocation` has no documented fallback algorithm.

## Settings, truck options and activation

Sources: [settings](https://docs.here.com/wego-pro/docs/share-settings-dl), [route Pro requirements](https://docs.here.com/wego-pro/docs/share-route-dl), [activation](https://docs.here.com/wego-pro/docs/activate-device-dl). Truck route options explicitly require Pro. Settings examples use `/s/truckparams?m=tr&…`; fields can also accompany `/r/…?m=tr`. No unspecified numeric bounds or defaults should be assumed.

| Field/action | Type, units and requirement | Values/ranges/default/interaction |
| --- | --- | --- |
| `/s/truckparams` | Settings category path | Applies shared vehicle settings. Other categories are not enumerated. |
| `m=tr` | Mode selector in examples | Truck routing context. |
| `vw` | Optional numeric total weight, **kg** | No range/default/integer restriction stated. |
| `vdh`, `vdl`, `vdw` | Optional numeric height, length, width, **cm** | No range/default/integer restriction stated. Not the meter units of some other HERE APIs. |
| `hmr` | Optional comma-separated hazardous-material names | No whitespace; no extra comma. URL examples explicitly show `harmfulToWater`, `flammable`, `explosive`, `gas`, `organic`, `corrosive`. Full spelling issue below. |
| `tcr` | Optional tunnel-category string | `A`, `B`, `C`, `D`, `E`, case-insensitive; lowercase accepted. |
| `trt` | Optional truck-type string | Examples use `tractor` and `straight`; parameter prose says “tractor and truck”. **Internal inconsistency**: do not assert `truck` and `straight` are interchangeable aliases. |
| `trlc` | Optional integer trailer count | **0–6**. No omission default specified. |
| `axc` | Optional integer total axle count | **2–13**. No omission default specified. |
| `wpax` | Optional numeric weight per axle, **kg** | When provided together with axle-group weights, **takes precedence** and group weights are disregarded. |
| `axgwsn`, `axgwtan`, `axgwtri`, `axgwqd`, `axgwqt` | Optional numeric axle-group weights, **kg** | Single, tandem, triple, quad, quint groups respectively; bounds/defaults not supplied. |
| `/a/{activation-key}` | Required Pro activation key path string | Activates a device for Pro; obtain key through Pro provisioning. Example is UUID-shaped, but reference does not formally constrain all keys to UUIDs. Not a navigation callback or public API key. |

The settings source delegates hazardous-material names to [HERE's linked Android SDK enum](https://here-dni.github.io/HERESDKforAndroidAPIReferenceNavigate/com/here/sdk/transport/HazardousMaterial.html), which lists `EXPLOSIVE`, `GAS`, `FLAMMABLE`, `COMBUSTIBLE`, `ORGANIC`, `POISON`, `RADIOACTIVE`, `CORROSIVE`, `POISONOUS_INHALATION`, `HARMFUL_TO_WATER`, `OTHER`. However, actual deep-link examples use lowercase/camelCase (`harmfulToWater`). **The complete accepted wire spelling/case cannot be resolved from that inconsistent cross-reference alone.** Only the example spellings above are directly demonstrated as URL values; verify remaining material spellings before exposing an exhaustive typed enum. This explicitly referenced enum is the limited exception to excluding unrelated SDK APIs.

[Error behavior](https://docs.here.com/wego-pro/docs/errors-dl): no special API error codes; malformed links redirect with HTTP 301 to a default map view. A redirect or successfully opened app alone does not prove correct route interpretation. Do not activate a shared/real device just to test URL formatting.

## Implementation comparison and gaps

Inspected [builder](../../lib/src/maps/here.dart), [base capabilities](../../lib/src/maps/map_app.dart), [URL builder](../../lib/src/utils/url_builder.dart), and [extra appending](../../lib/src/utils/launch_helper.dart).

| Capability | Current implementation | Assessment |
| --- | --- | --- |
| Marker | `/l/lat,lon[,encoded title]`, optional `z` | Matches location/title grammar. Omitted zoom conflicts with format page but agrees with location page; flag documentation ambiguity rather than confirmed bug. |
| Explicit-origin route | `/r/originLat,originLon,encodedOriginTitle/destLat,destLon` | Coordinate order and modes correct; blank origin title produces trailing comma. Destination title discarded despite documented optional titles. |
| No-origin route | `/r/destLat,destLon` | **Confirmed grammar mismatch** against required two-or-more points; documented alternative is `/r/mylocation/destLat,destLon`. Runtime compatibility unverified. |
| Modes | `d`, `w`, `pt`, `b`; omitted when null | All four supported values documented. Taxi/car sharing/truck omitted from public enum. Null mode default left to provider, not guaranteed driving. |
| Waypoints | Ignored; flag false | Ordinary multi-point route support (100 total/50 soft) omitted. Distinguish standard points from Pro-layout pass-through types. |
| Additional actions | No place, settings or activation builder | Documented omissions; API additions should separate privileged activation from ordinary map launch. |
| Extras | No typed HERE class; query append | Can convey absent query fields such as `a`/`ref`/truck dimensions; cannot add path waypoints or change share object. Existing fields are duplicated rather than overridden. |
| Native detection | `here-location://`, Android package `com.here.app.maps`; actual launch HTTPS | Current source documents HTTPS launch, not custom-scheme actions. Probe validity requires installed-app verification. |

HERE Routing REST APIs, geocoding/search services, embedded SDK navigation callbacks, and Pro user-service APIs are different contracts. Do not imply their tokens, transport modes or callback mechanisms are accepted by `share.here.com`.

## Concrete proposed tests (not executed)

1. Asymmetric coordinate fixtures for marker and route; titles `Café / A,B & #` must remain a single title after decoding. Verify destination title preservation separately from origin.
2. No-origin routes should follow an explicitly chosen policy: use documented `mylocation` or preserve legacy compatibility only after device evidence. Test GPS denied/unavailable and available; do not equate a fallback map with successful routing.
3. Ordered 2/3/50/100/101 total-waypoint cases, respecting endpoints; choose a length/error policy without silent truncation. Pass-through types need separate entitlement/version tests.
4. All documented modes, absent mode, `tr` entitled versus non-entitled fallback; `a=tunnel,motorway` without assuming additional avoidance tokens.
5. Zoom 0/20/21 and pin yes/no on web versus mobile, verifying mobile ignores zoom/map type as documented. This resolves behavior, not the conflicting mandatory wording.
6. Truck fixtures: centimeter/kilogram units, trailer 0/6/7, axles 1/2/13/14, `wpax` precedence. Resolve `straight` versus `truck` and hazard-material spelling using authorized device tests or provider clarification before typed validation.

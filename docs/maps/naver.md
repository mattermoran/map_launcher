# Naver Map external links

Checked **2026-10-02** against the Korean [current Maps URL Scheme guide](https://guide.ncloud-docs.com/docs/application-maps-url-scheme-vpc) and [English translation](https://guide.ncloud-docs.com/docs/en/application-maps-url-scheme-vpc). No revision date or minimum app version was exposed in the retrieved current page. The older [Maps guide](https://guide.ncloud-docs.com/docs/maps-url-scheme) belongs to the deprecated Maps API documentation, not evidence that the app scheme itself is deprecated. No native application was tested.

Implementation baseline: [`8aa7a6e`](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131), verified as fetched `origin/master`; [builder](../../lib/src/maps/naver.dart), [capability defaults](../../lib/src/maps/map_app.dart), [encoding helper](../../lib/src/utils/url_builder.dart).

## Transport, identity, and coordinates

The native form is `nmap://{action}?{parameters}&appname={caller}`. The apparent `/place` action path in the reference becomes `nmap://place`, not `nmap:///place`. Android opens it with `ACTION_VIEW`/`CATEGORY_BROWSABLE`; iOS needs `nmap` in `LSApplicationQueriesSchemes` to query installation. Provider fallback targets are Android `com.nhn.android.nmap` and App Store `311867728`. A mobile website can launch the scheme or an Android intent; these are **not** browser-rendered map URLs.

Source: [syntax and setup](https://guide.ncloud-docs.com/docs/application-maps-url-scheme-vpc).

| Field / rule | Requiredness, syntax, and limits |
| --- | --- |
| `appname` | **Required on every action**; string identifying caller: Android `applicationId`, iOS bundle ID, or mobile web page URL. Not an API key. Percent-encode when used as a query value. |
| Latitude fields | Decimal `double`, **31.43–44.35**. The restricted Korean extent is narrower than generic geographic validation. |
| Longitude fields | Decimal `double`, **122.37–132.00**. |
| Coordinate system | Guide identifies latitude/longitude in degrees and examples establish order. It does not explicitly name a CRS in the scheme table; WGS84 is the ordinary geographic interpretation, not a separately specified projection selector. |
| Strings | `query`, `name`, and route names explicitly require URL-encoded strings; encode each value once, including Korean, spaces, `&`, `#`, and caller URLs. No string-length or total URL-length limit is stated. |

The provider prints this Android browser intent template:

```text
intent://{action}?{parameters}&appname={caller};scheme=nmap;action=android.intent.action.VIEW;category=android.intent.category.BROWSABLE;package=com.nhn.android.nmap;end
```

**Source caveat:** the printed template omits the usual Android `#Intent` delimiter. Treat it as provider example text, not a verified `Intent.parseUri` serialization; verify generated intents on Android rather than copying that omission. The repository builds the native scheme instead. No standalone HTTPS map/route URL contract, API-key field, callback, return URL, or additional attribution field is specified in this guide.

## Actions and every table-defined field

Source for all rows: [current Korean action reference](https://guide.ncloud-docs.com/docs/application-maps-url-scheme-vpc#url-scheme-사용). “Optional” and defaults below follow the provider, not observed app behavior.

| Action | Fields | Meaning / defaults |
| --- | --- | --- |
| `map` | Optional `lat`, `lng`, `zoom` | Main map; omitted values retain previous app state. `zoom` is a `double` **4–20**. |
| `search` | Required string `query` | Integrated keyword search. |
| `search/bus` | Required string `query` | Bus-number search, e.g. `222`. No region selector documented. |
| `place` | Required `lat`, `lng`, string `name` | Display a marker. **No `zoom` field is listed for this action.** |
| `route/car` | Common route fields below | Car route search, not the separate navigation action. |
| `route/public` | Common route fields below | Public transport. |
| `route/walk` | Common route fields below | Walking. |
| `route/bicycle` | Common route fields below | Bicycle. |
| `navigation` | Common route fields below | Navigation route search. An explicit no-destination example opens safe-driving mode; destination-only example starts from current location. |

Source: [common route table](https://guide.ncloud-docs.com/docs/application-maps-url-scheme-vpc#경로-탐색-공통-파라미터).

| Field | Type / required | Meaning / omission |
| --- | --- | --- |
| `slat`, `slng` | `double`, optional | Origin latitude and longitude; default current location. Supply a coherent pair. |
| `sname` | Encoded string, optional | Origin name; default current location. |
| `dlat`, `dlng` | `double`, required for a route | Destination latitude and longitude. Exception: explicitly documented destination-free safe-driving `navigation`. |
| `dname` | Encoded string, optional | Destination label; default destination address. |
| `v1lat`, `v1lng`, `v1name` | Two doubles and encoded string, optional | First waypoint; default no waypoint. |
| `v2lat`, `v2lng`, `v2name` | Same | Second waypoint. |
| `v3lat`, `v3lng`, `v3name` | Same | Third waypoint. |
| `v4lat`, `v4lng`, `v4name` | Same | Fourth waypoint. |
| `v5lat`, `v5lng`, `v5name` | Same | Fifth waypoint. |

All route latitude/longitude fields use the ranges above. There are **five documented waypoint slots**, not an unlimited repeated parameter. The common table is linked from all route modes; it does not explain mode-specific waypoint restrictions, partial waypoint handling, or route-policy defaults. Do not infer guaranteed five-stop transit behavior from the shared table alone. No avoid-tolls/highways, arrival/departure time, vehicle class, route policy, or automatic return parameter is defined.

### Example-only and conflicting documentation

The current guide's car-with-waypoint example also includes `secoords`, `decoords`, and `v1ecoords`, each with a `lat,lng` pair. **These appear in a primary-source example but not its parameter table**: entrance-coordinate semantics are suggested by naming/context, not specified; requiredness, multiplicity, separators beyond one pair, and extension to `v2ecoords`–`v5ecoords` are not established. Do not turn inferred names into supported fields.

The [government-cloud copy](https://guide-gov.ncloud-docs.com/docs/naveropenapiv3-maps-url-scheme-url-scheme), indexed with update **2026-08-20**, contains a map example with `level=13&mode=3&traffic=false` despite a table listing `zoom`. Those are conflicting/example-only legacy-style fields, not substitutes for the current guide's explicit `zoom=20` example. Their ranges/defaults are not established here.

## Implementation comparison

| Contract | Current implementation | Classification |
| --- | --- | --- |
| Every URL identifies caller with `appname` | Neither marker nor route emits it | **Demonstrable contract violation**, independent of whether a particular app version tolerates omission. |
| `place` requires `name` | Only supplied when title is non-null; helper also drops blank values | **Contract violation** for absent/blank titles. |
| `place` coordinate fields | Emits `lat`, `lng` correctly | Matches field names/order; only global coordinate ranges are validated. Korean bounds are not enforced. |
| Marker zoom | Sends `zoom` to `place` | Undocumented field on this action; do not claim it works or is definitely rejected. |
| Route destination / origin / names | Emits correct `dlat`, `dlng`, optional `dname`, `slat`, `slng`, `sname` | Matches documented subset. Origin can be omitted despite class comment “with origin.” |
| Route modes | Always `route/car`; advertises driving only | Honest capability restriction, but other documented modes are omitted. Direct calls ignore a non-driving argument. |
| Waypoints | Argument ignored; `supportsWaypoints=false` | Omitted provider feature; capability accurately reflects implementation. |
| Search, bus, main map, navigation, example-only entrance coordinates | Not implemented; search flags false | Omitted actions, not evidence of provider incapability. |
| Web | Both universal URL methods return null; `hasUniversalLink=false` | Consistent with implementation; mobile web launching a native app is a different capability. |

## Concrete follow-up tests

1. Assert Android/iOS caller identity and percent-encoding independently; use a caller URL containing `?source=a&b=c` for the web case. A URL without `appname` must not pass a contract test.
2. Marker title cases: absent, empty, whitespace, and `서울 & 출구/1?#`; independently assert a required nonempty `name` policy and exact decoded value. Resolve policy before changing code.
3. Use `(37.3595953,127.1053971)` and `(37.4200267,127.1267772)` to detect latitude/longitude or origin/destination swaps. Test no origin separately.
4. Test Korean bounds exactly and just outside them, independently of `LocationCoords` global validation. Test zoom 4/20 and 3/21 only on the documented `map` action; treat `place` zoom as a device experiment.
5. If exposed, assert the four distinct action paths, ordered waypoint slots 1–5, and explicit rejection/handling of a sixth. Test transit waypoints on devices before advertising them.
6. Device matrix still needed: Android/iOS installed and absent, non-ASCII labels, navigation versus route preview, and correctly serialized Android intent fallback. None was run in this research.

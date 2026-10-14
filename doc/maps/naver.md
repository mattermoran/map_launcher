# Naver Map

The plugin opens native coordinate markers and car routes with optional coordinate origins. Supply `NaverMap(appName: ...)` or an `appname` extra containing the caller's Android application ID, iOS bundle ID or mobile page URL. This is caller identity, not an API key. The provider documents it as required, but the plugin permits discovery and launch without it for compatibility; provider acceptance has not been device-verified. Marker names fall back to coordinate text for absent/blank titles and do not send zoom. Only driving is advertised; waypoints and browser URLs are unsupported.

Reference check: 2026-10-13. The [Korean guide](https://guide.ncloud-docs.com/docs/application-maps-url-scheme-vpc) and [English translation](https://guide.ncloud-docs.com/docs/en/application-maps-url-scheme-vpc) show no minimum app version. The [older guide](https://guide.ncloud-docs.com/docs/maps-url-scheme) belongs to deprecated Maps API documentation, not a stated retirement of the app scheme. Protocol tables include unimplemented actions.

Implementation: [builder](../../lib/src/maps/naver.dart), [capabilities](../../lib/src/maps/map_app.dart), [encoding](../../lib/src/utils/url_builder.dart).

With shorthand `.naver`, use `NaverExtra(appName: 'com.example.myapp')` in
`extra`, or `providerExtras: {.naver: NaverExtra(appName: 'com.example.myapp')}`
before discovery. No custom map instance or raw parameter key is needed.

## Transport, identity, and coordinates

The native form is `nmap://{action}?{parameters}&appname={caller}`. The apparent `/place` action path in the reference becomes `nmap://place`, not `nmap:///place`. Android opens it with `ACTION_VIEW`/`CATEGORY_BROWSABLE`; iOS needs `nmap` in `LSApplicationQueriesSchemes` to query installation. Provider fallback targets are Android `com.nhn.android.nmap` and App Store `311867728`. A mobile website can launch the scheme or an Android intent; these are **not** browser-rendered map URLs.

Reference: current Korean guide, syntax/setup.

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

## Actions and parameters

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

## Plugin limitations

The plugin validates global coordinate ranges, not Naver's narrower Korean bounds.
Direct builders ignore non-driving modes and waypoints; use the request API to
check capabilities before launching. Search, bus search, the main map, navigation
and entrance-coordinate fields are not exposed. Mobile websites can launch the
native scheme, but the plugin provides no browser-rendered fallback.

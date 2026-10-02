# Mapy.com (formerly Mapy.cz): external launch audit

Checked **2026-10-02** against repository commit [8aa7a6e](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131), fetched and verified present on `origin/master`. Documentation research only; **no native device testing**.

## Status and sources

**The application supports more than destination-only links, including immediate navigation.** The current public integration surface is `https://mapy.com/fnc/v1`, not the legacy `mapy.cz/zakladni` page parameters used by this package.

Primary sources, read in full:

- [Mapy URL functions](https://developer.mapy.com/further-uses-of-mapycz/mapy-cz-url/): current page body uses Mapy.com, although the title and slug retain Mapy.cz. URL API version **v1**; no publication/update date displayed. Navigation support explicitly dates from **April 2024** app releases onward.
- [Calling the mobile application](https://developer.mapy.com/further-uses-of-mapycz/calling-the-mapy-cz-mobile-application/): Android and iOS native integration; no displayed date/version.
- [Seznam's rename announcement](https://blog.seznam.cz/en/2025/03/the-global-journey-of-the-czech-map-application-begins-mapy-cz-becomes-mapy-com/), **2025-03-26**: Mapy.cz becomes Mapy.com. Do not rename the stable library identifier merely to update the display brand.
- [Developer-service rename](https://developer.mapy.com/mapy-cz-is-now-mapy-com-what-does-this-mean-for-developers/), **2025-05-29**, effective June 1: distinct from the earlier consumer-product rename. It explicitly preserves both `mapy.cz/fnc/…` and `mapy.com/fnc/…`; domain migration is not mandatory to retain that URL API. This does not supply a detailed contract for legacy `/zakladni` fields.

No primary source was inaccessible. No secondary source is needed for the supported parameters below. The pages do not formally name a coordinate datum or state latitude/longitude validation ranges; do not import REST API validation constraints into these launch URLs. Coordinate values are geographic longitude/latitude, not projected meter coordinates. Geo URI is the separate standard lat/lon family.

## Universal URL actions and parameters

Source for all rows: [official v1 URL reference](https://developer.mapy.com/further-uses-of-mapycz/mapy-cz-url/). All three actions work on the website and launch the installed mobile app, with website fallback if it is absent. **No API key** is required. The documentation supplies bare-action examples, so no query field is mandatory merely to open an action. Meaningful marker/navigation requests still need their relevant coordinates.

| Action/field | Type and requirement | Values, default, limits and behavior |
| --- | --- | --- |
| `/showmap` | Action path | Display a map, optionally a marker. |
| `/search` | Action path | Display search results. |
| `/route` | Action path | Display planned routes; `navigate` can start mobile navigation. |
| `mapset` | Optional string; all actions | `basic` (default), `outdoor`, `winter`, `aerial`, `traffic`. |
| `center` | Optional string; showmap/search | `lon,lat`; default empty string. Map center, also marker location for showmap. |
| `zoom` | Optional number; showmap/search | Default empty string. No numeric range, integer restriction, or clamp behavior stated. This is **not** legacy `z`. |
| `marker` | Optional boolean; showmap only | `true` or `false`; default `false`. Set `true` to mark `center`. No custom title/description documented. |
| `query` | Optional string; search only | Default empty string. Search text; length limit not stated. |
| `start` | Optional string; route only | `lon,lat`; default empty string. End-only route examples are explicitly documented. The reference does **not** explicitly guarantee that every omitted-start case resolves to live GPS automatically. |
| `end` | Optional string; route only | `lon,lat`; default empty string. Required in practice to express this package's destination request, but the API permits opening an empty planner. |
| `routeType` | Optional string; route only | `car_fast` (default), `car_fast_traffic`, `car_short`, `foot_fast`, `foot_hiking`, `bike_road`, `bike_mountain`. No transit value documented for this family. |
| `waypoints` | Optional string; route only | Ordered `lon,lat;lon,lat;…`; default empty string; **maximum 15 intermediate points**. No separate stopover/pass-through option documented. |
| `navigate` | Optional boolean; route only | Default `false`. `true` immediately activates navigation in mobile apps released from **April 2024** onward; older versions only open the route, requiring manual start. No numeric minimum build supplied. |

Encode user-supplied query values once as URL query components; preserve the comma/semicolon structure after decoding. The official examples show literal coordinate delimiters, not a proprietary binary route encoding. The page specifies no maximum URL length, callbacks, x-callback-url, navigation completion return URL, avoidances, departure times, route titles, or credential parameters. These are **not documented**, not proven unsupported.

Example using only documented fields (not app-tested):

```text
https://mapy.com/fnc/v1/route?end=14.3681,50.0292&routeType=foot_hiking&waypoints=14.5377,50.0831;14.5087,50.0335&navigate=true
```

## Native/intent families

Source: [official mobile-app calling reference](https://developer.mapy.com/further-uses-of-mapycz/calling-the-mapy-cz-mobile-application/). It documents both `geo:` and Android `google.navigation:`; the Google scheme does not imply identical Google Maps parameter support.

| Family/field | Platform and requirement | Meaning and limits |
| --- | --- | --- |
| `geo:lat,lon` | Android and iOS; coordinate pair in URI | Open a location. **Latitude first**, unlike v1 URL fields. Standard geographic Geo URI convention; no Mapy-specific bounds specified. |
| `geo:lat,lon?q=…` | Android/iOS; optional search string | Search around coordinates. `geo:0,0?q=…` searches around user position or viewport center if GPS is disabled. URL-encode Unicode and reserved characters. No `z`, label, uncertainty, or altitude extension is documented here. |
| Android package `cz.seznam.mapy` | Optional intent target | Targets Mapy; without it other Geo URI handlers may be offered. Package remains unchanged despite rename. |
| iOS Geo URI targeting | No app-specific target documented | Reference explicitly says it currently cannot directly target the app this way. This is different from HTTPS app-link handling. |
| `google.navigation:q=address` | Android; required `q` text | **Searches for a place**, not a guarantee of starting navigation. `mode` and `avoid` do not work for address input. |
| `google.navigation:q=lat,lon` | Android; required coordinate `q` | **Starts navigation**. Uses latitude first. No origin or intermediate points documented for this intent. |
| `mode` | Optional; coordinate navigation only | `d` driving (default), `b` biking, `l` transit, `w` walking, as written in Mapy's reference. Last selected subtype within the selected mode is used (e.g. tourist/fastest with traffic). `l` is the documented character; do not silently replace it with another app's mode codes. Actual transit behavior merits device verification. |
| `avoid` | Explicitly unsupported | Not supported for coordinate navigation either. |

Neither native family documents callbacks, return-to-caller, navigation completion reporting, or additional route options. `szn-mapy://` is used for iOS detection by this repository but is **not a current documented action grammar in the sources above**.

## Implementation comparison and gaps

Inspected [builder](../../lib/src/maps/mapy_cz.dart), [base capabilities](../../lib/src/maps/map_app.dart), [URL encoding](../../lib/src/utils/url_builder.dart), and [extras/launch behavior](../../lib/src/utils/launch_helper.dart).

| Capability | Repository behavior | Assessment |
| --- | --- | --- |
| Brand/identity | Display name `Mapy.cz`, ID `mapyCz`, class `MapyCz`; package `cz.seznam.mapy` | Display brand is stale. Preserve stable IDs for compatibility; rename is not proof old URLs stopped working. |
| Marker | `https://mapy.cz/zakladni?source=coor&id=lon,lat`, optional `z` | Legacy website syntax, not documented by current v1 reference. Uses the same coordinate orientation as v1; current supported equivalent is showmap with `center` and `marker=true`. |
| Directions | Same legacy path, `source=rout&id=lon,lat` | Not the documented v1 route contract; actual old-link behavior unverified. |
| Origin, waypoints, mode | Builder ignores all three; `supportsWaypoints=false` | Confirmed wrapper omissions relative to v1 route fields. Inherited `supportsTravelMode` returns true even though builder ignores modes. |
| Search | No search builders; flags false | Documented v1 search and Geo URI search are unexposed. |
| Navigation | No `navigate` or Android navigation builder | Confirmed omission, **not an application limitation**. |
| Extras | Generic query append only; no typed extras | Adding `navigate=true` to `/zakladni` does not convert it into `/fnc/v1/route`. Extras cannot change an action path and duplicate existing keys rather than replacing them. |
| iOS/native | `szn-mapy://` detection only; HTTPS launch inherited | Detection scheme alone does not establish native action support. |

REST routing/geocoding, JS Panorama, and iframe embedding are separate surfaces. Do not copy their `apikey`, avoidances, routing options, or response fields into app links. Consumer app features advertised in the rename announcement likewise do not automatically introduce new URL fields.

## Concrete proposed tests (not executed)

1. Migration URL tests: `(lat=50.0292, lon=14.3681)` becomes `center=14.3681,50.0292` for showmap and `end=14.3681,50.0292` for route; assert `marker=true`, action path, and `zoom` key. Keep identity compatibility tests separate.
2. Route tests with omitted and explicit origin, asymmetric intermediate points, and 0/1/15/16 waypoints. Decide rejection policy for 16; do not truncate silently. Assert all seven documented route types independently, plus deliberate handling of unsupported v1 transit.
3. Round-trip `query=Café & tram + / #` through URL decoding; no query splitting or double encoding. Test generic extras collision behavior explicitly before claiming overrides.
4. Android device matrix: coordinate navigation versus address search, absent/present mode, all documented mode letters, app absent, location permission denied. iOS: Geo URI ambiguity versus HTTPS app opening.
5. On old and post-April-2024 mobile versions, verify `navigate=true` starts guidance rather than only previewing a route; test omitted origin with two waypoints. Record app/OS versions and GPS permission. Web cannot establish native navigation behavior.

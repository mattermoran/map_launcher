# TomTom MyDrive

**Not included in map_launcher.** [Issue 111](https://github.com/mattermoran/map_launcher/issues/111) requests MyDrive separately from TomTom GO and GO Fleet. MyDrive mobile is discontinued; those providers do not implement it.

Source check: **2026-10-02**.

## MyDrive mobile is discontinued, not renamed to GO

Primary source: [TomTom support — MyDrive mobile app discontinuation](https://help.tomtom.com/hc/en-gb/articles/20495627169554-MyDrive-mobile-app-discontinuation), labelled **“Update May 2026”**, checked on the date above.

The notice states that the mobile app was to be removed from Google Play and Apple App Store by **22 January 2025**, because it no longer met software/security standards. Existing installations “might” continue working; deletion, device reset, or a new phone prevents reinstall/update. This wording is not a guarantee of continued backend service. A [May 21, 2026 community forum reply](https://www.tomtomforums.com/threads/my-drive.35778/) additionally says the backend was switched off; **secondary-only**, not needed to establish the official discontinuation decision.

The supported route-planning alternative is **[Plan.TomTom.com](https://plan.tomtom.com)**, a mobile-friendly website that can be added to a home screen. It can synchronize routes, favourites, and addresses to compatible sat navs and/or GO Navigation. Existing MyDrive credentials continue as a renamed **TomTom account**. This does not mean the native MyDrive app became the GO app or that GO's URL scheme became MyDrive's.

**MyDrive Connect** remains a separate [Windows/macOS device-update program](https://www.tomtom.com/en_gb/navigation/mydrive-connect/), explicitly unaffected by the mobile discontinuation. Neither this desktop program nor a browser shortcut is a newly installable MyDrive mobile navigator.

## Store identity and discovery status

| Product identity | What is verified / what is not |
| --- | --- |
| TomTom MyDrive mobile | Former Android/iOS product confirmed by the official discontinuation notice. No current installable store identity should be advertised. |
| Historical Android package / Apple numerical ID | Not established by the available primary sources. Do not substitute GO's `com.tomtom.gplay.navapp` or Apple ID `884963367`. |
| Plan.TomTom.com | Verified official replacement **website**, not a package ID, custom scheme, or verified installed-app identity. |
| MyDrive Connect | Verified desktop updater, not an inbound route-launch target. |

Historical installation detection would require an archived official listing or a signed application's manifest. Package discovery alone would not make the discontinued app a supported target.

## External action/parameter inventory

Primary source beside this inventory: [discontinuation and replacement guidance](https://help.tomtom.com/hc/en-gb/articles/20495627169554-MyDrive-mobile-app-discontinuation), [MyDrive Connect product page](https://www.tomtom.com/en_gb/navigation/mydrive-connect/). These are user-support documents, not a developer URL specification.

| Action / URL | Parameters, requiredness and limitations |
| --- | --- |
| Open `https://plan.tomtom.com` | No query parameters required to open the planner. User sign-in is documented for account synchronization. A normal HTTPS browser launch is feasible. |
| Native MyDrive marker/search/route URL | **No readable primary public contract found.** Scheme/host, Android intent action/extras, and callback format are unverified. Do not invent `mydrive://` or reuse `tomtomgo://x-callback-url/navigate`. |
| Prefilled Plan route URL | No stable externally documented parameter contract established here. UI-generated/share URLs are not automatically a public arbitrary-origin/destination API. |
| MyDrive Connect launch/update | User installation/USB update flow documented, not a map-marker/route URL contract. |

For native MyDrive and prefilled Plan links, **requiredness, syntax, types, defaults, allowed values, coordinate order/datum, encoding, origin, destination, waypoints, modes, ranges, limits, callback semantics, and partner restrictions remain unknown**. There is no basis to fill a parameter table with TomTom REST fields or another app's parameters. An empty evidence set is not proof that historical/private links never existed.

No native iOS/Android link parity can be claimed. Opening the replacement website on either platform is distinct from deep linking into a native navigation session; installing a home-screen shortcut does not change this. Account sync is an authenticated cloud feature, not a synchronous callback to the calling application.

## API/SDK separation and integration decision

[TomTom developer documentation](https://developer.tomtom.com/) covers routing/search web services and embedded SDKs. API keys, REST route coordinate formats, SDK navigation methods, and device synchronization APIs are not evidence that the discontinued consumer MyDrive binary accepts those inputs. Do not derive an app scheme from them.

MyDrive is not a candidate for newly supported native navigation. A labelled generic link can open the replacement planner, but the available contract cannot implement `showMarker` or `showDirections` with supplied coordinates. It must not silently replace a selected map or equate website launch with delivery to a sat nav.

Prefilled web-planner integration requires its own supported URL specification, terms, share-link lifetime, account requirements, destination/waypoint limits and fallback rules.

Location/route data sent for cloud synchronization can reveal home, work, travel history, and device associations. Do not upload routes or inspect users' favourites as a discovery test. Publicly shared route URLs may disclose stops; redact them from logs.

Website route display, account save, cloud synchronization and device navigation are separate outcomes. Opening Plan's landing page establishes none of the later steps, and a home-screen shortcut does not restore native MyDrive availability.

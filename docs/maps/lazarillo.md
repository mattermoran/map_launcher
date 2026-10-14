# Lazarillo Accessible GPS

**Not included in map_launcher.** Requested as “Lazarillo Maps” in [issue 111](https://github.com/mattermoran/map_launcher/issues/111). No verified consumer-app inbound marker or route contract is available.

Source check: **2026-10-02**.

## Available product; inbound routing contract not established

The current consumer product is **Lazarillo Accessible GPS** (Apple spelling “Lazarillo - Accessible GPS”), not a newly verified product named “Lazarillo Maps”. The [official app page](https://lazarillo.app/theapp) and [official support/manual page](https://lazarillo.app/usersupport) link to:

| Platform | Store identity / evidence |
| --- | --- |
| Android | [`com.lazarillo`](https://play.google.com/store/apps/details?id=com.lazarillo), publisher LAZARILLO; readable listing displayed update August 3, 2026. |
| iOS | [Apple ID `1139331874`](https://apps.apple.com/us/app/lazarillo-accessible-gps/id1139331874), seller Lazarillo LLC; listing displayed version 3.5.54, November 25, 2025. An Apple numerical ID is not proof of the bundle ID or URL scheme. |
| Huawei | Official support footer links [AppGallery `C101770257`](https://appgallery.cloud.huawei.com/marketshare/app/C101770257?locale=en_US); storefront compatibility/availability was not independently device-tested. |

The official manuals (undated, read on the checked date) describe accessible exploration, category/address search, favourites, audio guidance, and walking/public-transport/car/Uber routing choices. They document registration and location permissions. **UI functionality does not establish equivalent externally callable actions.** In particular, Lazarillo opening Uber is an outbound handoff, not evidence for other apps launching a route inside Lazarillo.

The [business product page](https://lazarillo.app/business) and [home page](https://lazarillo.app/) describe indoor/outdoor mapping, facility wayfinding, website/mobile/kiosk integration, and MapVX. These are distinct from a public launch API for the consumer app; a mapped venue may require its own identifiers and partner setup.

## Public external action/parameter inventory

Contract sources: official [app description](https://lazarillo.app/theapp), [iOS and Android manuals/FAQ](https://lazarillo.app/usersupport), and store listings above. They supply no incoming URL parameter specification or authoritative public app-source repository; private or undocumented links remain possible.

| External operation | Evidence and parameters |
| --- | --- |
| Open download/store page | Ordinary HTTPS links above. Android Play query `id=com.lazarillo` identifies a store listing, not an in-app place or destination. Apple ID is a path identifier. No navigation parameters. |
| Share Lazarillo with a friend | Manual explicitly describes a generic download link selecting the recipient's store. No route payload or callback is documented. |
| Inbound marker / coordinate / search / route | No verified scheme, universal-link host/path, action, query keys, or Android intent extras. Do not invent `lazarillo://`, append `lat`/`lon` to a website link, or claim it handles `geo:` merely because it is a GPS app. |
| Import place, favourites or route | No public incoming file/intent contract found in the inspected manuals. In-app “Add with Address”/“Add with This GPS Location” are UI operations, not external API endpoints. |
| Indoor venue/business map | Commercial integration is offered, but the consumer-app inbound URL contract and arbitrary-venue permissions are not publicly specified in these sources. |

Requiredness, field types, values/defaults, coordinate order/system, encoding, ranges/limits, endpoints, waypoints, modes, callbacks, authentication and partner restrictions are **unknown for external launch**, not unsupported values inferred from the UI.

The manuals establish account registration for the consumer experience and user-granted location access. They do not establish a caller API key, OAuth scope, no-auth launch guarantee, or callback registration process. They also do not establish browser fallbacks that retain route information or parity between native iOS and Android.

## Integration options and blockers

**Store discovery/download links are integration-ready; `showMarker`/`showDirections` are blocked on a verified inbound contract.** An Android package launch may open an app's normal launcher activity, but that is an OS-level capability requiring runtime verification, not documented Lazarillo marker/directions support. iOS cannot discover arbitrary installed apps by Apple store ID.

Contact Lazarillo through the [support page](https://lazarillo.app/usersupport) before implementation. Request a versioned external contract, scheme/universal-link association, Android action/extra definitions, supported coordinate system and required names, route modes, arbitrary versus provisioned venue IDs, callback/security rules, and commercial terms. Do not promote a store link or an unverified generic geo intent into the map chooser as a working route provider.

REST APIs, embedded indoor-navigation SDKs, and business-map integration must remain separate. An embeddable map or a commercial SDK does not imply a consumer-app deep link; obtain documentation and agreement for whichever product is actually intended.

**Accessibility/privacy:** a false “route launched” result is particularly harmful for people relying on spoken guidance. Verify focus, announcements, and route endpoint—not only the foreground app. The official manual describes account-backed favourites and background/location-related permissions; do not collect the caller's GPS or create accounts merely to discover a map. Avoid logging disability-related destinations or personally identifying labels. Do not assume a car/Uber choice has the same safety implications as walking guidance.

Download, app launch and accessible endpoint transfer are separate outcomes. A store page or home-screen launch is not route delivery; any future contract must preserve the intended destination and accessible focus/announcements, rather than infer success from the foreground app.

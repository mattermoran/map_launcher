# Lazarillo Accessible GPS

Checked: **2026-10-02**. Research only; no native-device tests or sign-in. Baseline fetched and verified: [8aa7a6e](https://github.com/mattermoran/map_launcher/commit/8aa7a6e1152a80c4482003bdfaad8f850bdb6131), equal to `origin/master`. Requested as “Lazarillo Maps” in [issue 111](https://github.com/mattermoran/map_launcher/issues/111); absent from the baseline map registry.

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

Evidence scope: official [app description](https://lazarillo.app/theapp), [iOS and Android manuals/FAQ](https://lazarillo.app/usersupport), official store listings above, and searches for Lazarillo developer/deep-link/URL-scheme documentation. No authoritative public app-source repository or incoming URL parameter specification was established. This is **not a claim that the app cannot have private or undocumented links**.

| External operation | Evidence and parameters |
| --- | --- |
| Open download/store page | Ordinary HTTPS links above. Android Play query `id=com.lazarillo` identifies a store listing, not an in-app place or destination. Apple ID is a path identifier. No navigation parameters. |
| Share Lazarillo with a friend | Manual explicitly describes a generic download link selecting the recipient's store. No route payload or callback is documented. |
| Inbound marker / coordinate / search / route | No verified scheme, universal-link host/path, action, query keys, or Android intent extras. Do not invent `lazarillo://`, append `lat`/`lon` to a website link, or claim it handles `geo:` merely because it is a GPS app. |
| Import place, favourites or route | No public incoming file/intent contract found in the inspected manuals. In-app “Add with Address”/“Add with This GPS Location” are UI operations, not external API endpoints. |
| Indoor venue/business map | Commercial integration is offered, but the consumer-app inbound URL contract and arbitrary-venue permissions are not publicly specified in these sources. |

Consequently, requiredness, field types, allowed values/defaults, coordinate order/system, encoding, ranges/precision/limits, pickup/origin/destination, waypoints, transport modes, callbacks, app auth and partner restrictions are **unknown for external launch**, rather than unsupported values inferred from the UI. No launchable parameter table can responsibly be filled from the available evidence.

The manuals establish account registration for the consumer experience and user-granted location access. They do not establish a caller API key, OAuth scope, no-auth launch guarantee, or callback registration process. They also do not establish browser fallbacks that retain route information or parity between native iOS and Android.

## Integration options and blockers

**Store discovery/download links are integration-ready; `showMarker`/`showDirections` are blocked on a verified inbound contract.** An Android package launch may open an app's normal launcher activity, but that is an OS-level capability requiring runtime verification, not documented Lazarillo marker/directions support. iOS cannot discover arbitrary installed apps by Apple store ID.

Contact Lazarillo through the [support page](https://lazarillo.app/usersupport) before implementation. Request a versioned external contract, scheme/universal-link association, Android action/extra definitions, supported coordinate system and required names, route modes, arbitrary versus provisioned venue IDs, callback/security rules, and commercial terms. Do not promote a store link or an unverified generic geo intent into the map chooser as a working route provider.

REST APIs, embedded indoor-navigation SDKs, and business-map integration must remain separate. An embeddable map or a commercial SDK does not imply a consumer-app deep link; obtain documentation and agreement for whichever product is actually intended.

**Accessibility/privacy:** a false “route launched” result is particularly harmful for people relying on spoken guidance. Verify focus, announcements, and route endpoint—not only the foreground app. The official manual describes account-backed favourites and background/location-related permissions; do not collect the caller's GPS or create accounts merely to discover a map. Avoid logging disability-related destinations or personally identifying labels. Do not assume a car/Uber choice has the same safety implications as walking guidance.

## Proposed discriminating tests (not executed)

1. After obtaining a vendor-supported URL, test exact destination `59.3293,18.0686` versus reversed coordinates, and a destination remote from the user's location. Verify audible endpoint announcement and on-screen endpoint.
2. Test fresh signed-out install, signed-in install, denied location, no GPS fix, cold/warm start, and unavailable indoor venue; distinguish onboarding from successful route setup.
3. Test walking versus public transport versus car only if each receives a documented external value. Never infer mode flags from visible buttons.
4. Check Unicode and reserved-character labels (`Å & + #`), optional origin, and multiple stops only when the vendor defines them; establish ranges and limits from documentation and boundary tests.
5. Verify screen-reader focus/announcements with TalkBack and VoiceOver on real devices. Browser emulation is not native accessibility verification.
6. Verify download links separately from app launch, and app launch separately from endpoint transfer. Do not mark a test successful because a store or the Lazarillo home screen opened.

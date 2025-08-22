# app_attest_integrity

<p>
  <a href="https://apps.theodo.com">
  <img  alt="logo" src="https://raw.githubusercontent.com/bamlab/theodo_analysis/main/doc/theodo_apps_white.png" width="200"/>
  </a>
  </br>
  <p>Flutter plugin to assess app integrity with server-side verification on iOS and Android with a single, simple API.</br>
  </br>Securely sign your client data to prove that it came from a legitimate, untampered app instance, downloaded from the Play Store / App Store on a real, not rooted nor jailbroken device.</br>
  </br> Made by <a href="https://apps.theodo.com">Theodo Apps</a> ❤️💙💛.</p>
</p>

Follows the official guidelines from Apple and Google:

- **iOS:** [App Attest](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity)
- **Android:** [Google Play Integrity API (Standard)](https://developer.android.com/google/play/integrity/standard)

<br/>

## Features

- 🌱 **Unified API** across iOS and Android (when possible)
- ☁ **server-side verification** following the official guidelines from Apple and Google
- ⚡️ **Warmup** the Play Integrity server for faster first calls on Android (optional)
- 🔐 **App Attest** key creation & attestation (iOS)
- ✍️ **Sign & verify client data** with platform-backed keys
- 🧱 **Replay-attack resistant** (challenge/nonce-based)

<br/>

## Platform setup

### iOS

- Requires **iOS 14+** on a **real device** (simulator not supported).
- Ensure your bundle identifier and entitlements are correctly configured according to Apple’s documentation.

### Android

- Requires **API 21+** and a device with Google Play services.
- Link to a **Google Cloud project** and note the **Cloud Project Number** (used by the plugin).

<br/>

## Dart API

```dart
import 'package:app_attest_integrity/app_attest_integrity.dart';
import 'package:app_attest_integrity/src/model/generate_attestation_response.dart';

final integrity = AppAttestIntegrity();

// ANDROID ONLY: warm up the Integrity API backend
Future<void> androidPrepareIntegrityServer(int cloudProjectNumber);

// IOS ONLY: create an App Attest key pair & get an attestation for your server
// Return a keyID and an attestation to be sent to your server.
Future<GenerateAttestationResponse?> iOSgenerateAttestation(String challenge);

// Sign client data (JSON string). iOS requires a keyID. Android needs the
// cloud project number only if you didn't call androidPrepareIntegrityServer before.
Future<String> verify({
  required String clientData,
  String? iOSkeyID,
  int? androidCloudProjectNumber,
});
```

---

## Usage

> See also the [example app](https://github.com/bamlab/app_attest_integrity/tree/main/example/lib/main.dart).

### iOS: first-time attestation

> **Do this once per user/device:** <br/>
> "Don't reuse a key among multiple users on a device because this weakens security protections. In particular, it becomes hard to detect an attack that uses a single compromised device to serve multiple remote users running a compromised version of your app. [...] Try to limit new key generation to only [app reinstallation, device migration, restoration of a device from a backup], or to the addition of new users. Keeping the key count low on a device helps when trying to detect certain kinds of fraud." <br/> _From [Apple documentation](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity)._

```dart
final serverChallenge = await fetchServerChallenge(); // ≥16 bytes of entropy

final attestation = await integrity.iOSgenerateAttestation(serverChallenge);


await sendAttestationToServer(
    attestation: attestation.attestation,
    keyId: attestation.keyID,
);

// Persist keyID locally for future verify() calls
await saveKeyId(attestation.keyID);

```

> Your server must verify the attestation with Apple’s App Attest service and **store** the `publicKey` contained in the attestation with this user/device. See the [server documentation here](https://developer.apple.com/documentation/devicecheck/validating-apps-that-connect-to-your-server#Verify-the-attestation).

<br/>

### Android: warm up (recommended)

```dart
// Call this before needing to use `verify` to speed it up.
await AppAttestIntegrity().androidPrepareIntegrityServer(YOUR_CLOUD_PROJECT_NUMBER);
```

<br/>

### Sign client data (both platforms)

```dart
final clientData = {
  "nonce": challengeFromServer,
  "new_score": 138,
  "uid": currentUserId,
};

final signature = await AppAttestIntegrity().verify(
  clientData: json.encode(clientData),
  iOSkeyID: await loadKeyId(), // REQUIRED on iOS, ignored on Android
  // androidCloudProjectNumber: YOUR_CLOUD_PROJECT_NUMBER, // not needed if warmed up
);

// Send both the clientData and the signature to your server:
await postVerificationPayloadToServer(
  clientData: clientData,
  signature: signature,
);
```

<br/>

## Best practices

- Follow the provided [Apple](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity) and [Google](https://developer.android.com/google/play/integrity/standard) documentation.
- **Always** include a server-generated **challenge** in `clientData`.
- Enforce a **strict TTL** for nonces (e.g., 2–5 minutes).
- Tie nonces to **user/session** and invalidate after use.
- Log and **rate-limit** repeated failures.
- Be prepared for **cold starts** (Android) → call `androidPrepareIntegrityServer` early.
- On iOS, ensure `iOSgenerateAttestation()` succeeded **once** per user/device and **persist** the `keyID`.

<br/>

## Error handling

Common cases you should surface or retry:

- **Unsupported device** → surface a clear error and bypass sensitive flows.
- **No iOS keyID provided** on `verify()` → instruct to run attestation first, properly save the `keyID`.
- **Integrity token provider missing** when not providing `androidCloudProjectNumber` → call `androidPrepareIntegrityServer()` or pass the number directly.
- **Network/Timeout** → retry with backoff; do not retry attestation infinitely.
- **Clock issues** → rely on server time for TTLs and issuance time validation.

<br/>

## Security

If you discover a security issue related to this plugin's logic, **do not** open a public issue. Please contact the maintainers privately at [flutter@bam.tech](mailto:flutter@bam.tech) and allow time for a fix before disclosure.

<br/>

## Additional Information

We welcome feedback, issues, contributions, and suggestions! Feel free to contribute to the development of this package.

👉 About Theodo Apps

We are a 130 people company developing and designing universal applications with React Native and Flutter using the Lean & Agile methodology. To get more information on the solutions that would suit your needs, feel free to get in touch by email or through or contact form!

We will always answer you with pleasure 😁

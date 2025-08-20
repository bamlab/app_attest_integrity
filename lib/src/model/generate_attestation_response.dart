import 'package:flutter/foundation.dart';

@immutable
/// Response of the [AppAttestIntegrity.iOSgenerateAttestation] method.
/// It should be sent to the server, as [attestation] acts as a public key,
/// and [keyId] is useful to check the [attestation] is valid on server side.
///
/// See [this iOS official doc](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity)
/// for more details.
///
class GenerateAttestationResponse {
  /// Response of the [AppAttestIntegrity.iOSgenerateAttestation] method.
  /// It should be sent to the server, as [attestation] acts as a public key,
  /// and [keyId] is useful to check the [attestation] is valid on server side.
  ///
  /// See [this iOS official doc](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity)
  /// for more details.
  ///
  const GenerateAttestationResponse({
    required this.attestation,
    required this.keyId,
  });

  /// The attestation to be sent to the server.
  /// It acts as a public key for later integrity checks.
  ///
  /// See [this iOS official doc](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity)
  /// for more details.
  ///
  final String attestation;

  /// The keyID to be sent to the server.
  /// It is useful to check the [attestation] is valid on server side.
  ///
  /// See [this iOS official doc](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity)
  /// for more details.
  ///
  final String keyId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GenerateAttestationResponse &&
        other.attestation == attestation &&
        other.keyId == keyId;
  }

  @override
  int get hashCode => attestation.hashCode ^ keyId.hashCode;

  @override
  String toString() {
    return 'Response(attestation: $attestation, keyId: $keyId)';
  }
}

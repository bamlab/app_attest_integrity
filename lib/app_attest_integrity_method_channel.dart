import 'package:app_attest_integrity/app_attest_integrity_platform_interface.dart';
import 'package:app_attest_integrity/src/messages.g.dart';
import 'package:app_attest_integrity/src/model/generate_attestation_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Implementation of [AppAttestIntegrityPlatform] that uses method channels.
/// Is listened on iOS and Android.
class MethodChannelAppAttestIntegrity extends AppAttestIntegrityPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('app_attest_integrity');

  @override
  Future<String?> getPlatformVersion() {
    return AppAttestIntegrityApi().getPlatformVersion();
  }

  @override
  Future<void> androidPrepareIntegrityServer(int cloudProjectNumber) {
    return AppAttestIntegrityApi().androidPrepareIntegrityServer(
      cloudProjectNumber,
    );
  }

  @override
  Future<GenerateAttestationResponse?> iOSgenerateAttestation(
    String challenge,
  ) async {
    final response = await AppAttestIntegrityApi().iOSgenerateAttestation(
      challenge,
    );
    if (response == null) {
      return null;
    }
    return GenerateAttestationResponse(
      attestation: response.attestation,
      keyId: response.keyId,
    );
  }

  @override
  Future<String> verify({
    required String clientData,
    required String keyID,
    int? cloudProjectNumber,
  }) {
    return AppAttestIntegrityApi().verify(
      clientData: clientData,
      keyID: keyID,
      cloudProjectNumber: cloudProjectNumber,
    );
  }
}

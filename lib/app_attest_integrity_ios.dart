import 'package:app_attest_integrity/app_attest_integrity_platform_interface.dart';
import 'package:app_attest_integrity/src/core/crypto_utils.dart';
import 'package:app_attest_integrity/src/ios/app_attest_service_ios.dart';
import 'package:app_attest_integrity/src/model/generate_attestation_response.dart';
import 'package:flutter/services.dart';

/// Implementation of [AppAttestIntegrityPlatform] for iOS.
/// Uses FFI to communicate with native DeviceCheck framework.
class AppAttestIntegrityIos extends AppAttestIntegrityPlatform {
  final AppAttestServiceIos _service = AppAttestServiceIos();

  @override
  Future<GenerateAttestationResponse?> iOSgenerateAttestation(
    String challenge,
  ) async {
    if (!_service.isSupported) {
      throw Exception('App Attest is not supported on this device.');
    }

    try {
      final clientDataHash = CryptoUtils.sha256Hash(challenge);
      final result = await _service.generateAndAttestKey(clientDataHash);

      return GenerateAttestationResponse(
        attestation: CryptoUtils.toBase64(result.attestationBytes),
        keyId: result.keyId,
      );
    } on AppAttestException catch (e) {
      throw PlatformException(
        code: e.code.name,
        message: e.message,
        details: e.nativeError,
      );
    }
  }

  @override
  Future<String> verify({
    required String clientData,
    String? iOSkeyID,
    int? androidCloudProjectNumber,
  }) async {
    if (iOSkeyID == null) {
      throw PlatformException(
        code: 'missing_key_id',
        message: 'iOSkeyID is required for iOS verification.',
      );
    }

    try {
      final clientDataHash = CryptoUtils.sha256Hash(clientData);
      final assertionBytes = await _service.generateAssertion(
        keyId: iOSkeyID,
        clientDataHash: clientDataHash,
      );

      return CryptoUtils.toBase64(assertionBytes);
    } on AppAttestException catch (e) {
      throw PlatformException(
        code: e.code.name,
        message: e.message,
        details: e.nativeError,
      );
    }
  }
}

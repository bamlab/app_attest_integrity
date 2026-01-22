import 'package:app_attest_integrity/app_attest_integrity_platform_interface.dart';
import 'package:app_attest_integrity/src/android/play_integrity_service_android.dart';
import 'package:app_attest_integrity/src/core/crypto_utils.dart';
import 'package:app_attest_integrity/src/model/generate_attestation_response.dart';
import 'package:flutter/services.dart';

/// Implementation of [AppAttestIntegrityPlatform] for Android.
/// Uses JNI to communicate with Play Integrity API.
class AppAttestIntegrityAndroid extends AppAttestIntegrityPlatform {
  final PlayIntegrityServiceAndroid _service = PlayIntegrityServiceAndroid();
  int? _cloudProjectNumber;

  @override
  Future<void> androidPrepareIntegrityServer(int cloudProjectNumber) async {
    _cloudProjectNumber = cloudProjectNumber;

    try {
      await _service.prepareTokenProvider(cloudProjectNumber);
    } on PlayIntegrityException catch (e) {
      throw PlatformException(
        code: e.code.name,
        message: e.message,
        details: e.details,
      );
    }
  }

  @override
  Future<GenerateAttestationResponse?> iOSgenerateAttestation(
    String challenge,
  ) async {
    // Not supported on Android
    return null;
  }

  @override
  Future<String> verify({
    required String clientData,
    String? iOSkeyID,
    int? androidCloudProjectNumber,
  }) async {
    // Ensure token provider is prepared
    if (!_service.isPrepared) {
      final projectNumber = androidCloudProjectNumber ?? _cloudProjectNumber;
      if (projectNumber == null) {
        throw PlatformException(
          code: 'no_project_number',
          message:
              'cloudProjectNumber not set. Call androidPrepareIntegrityServer first or provide androidCloudProjectNumber.',
        );
      }
      await androidPrepareIntegrityServer(projectNumber);
    }

    try {
      final requestHash = CryptoUtils.sha256HashBase64(clientData);
      return await _service.requestIntegrityToken(requestHash);
    } on PlayIntegrityException catch (e) {
      throw PlatformException(
        code: e.code.name,
        message: e.message,
        details: e.details,
      );
    }
  }
}

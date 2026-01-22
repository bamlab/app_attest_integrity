import 'package:app_attest_integrity/app_attest_integrity_platform_interface.dart';
import 'package:app_attest_integrity/src/android/play_integrity_bindings.g.dart';
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

  static const int _maxRetries = 3;

  @override
  Future<String> verify({
    required String clientData,
    String? iOSkeyID,
    int? androidCloudProjectNumber,
  }) async {
    final projectNumber = androidCloudProjectNumber ?? _cloudProjectNumber;

    // Ensure token provider is prepared
    if (!_service.isPrepared) {
      if (projectNumber == null) {
        throw PlatformException(
          code: 'no_project_number',
          message:
              'cloudProjectNumber not set. Call androidPrepareIntegrityServer first or provide androidCloudProjectNumber.',
        );
      }
      await androidPrepareIntegrityServer(projectNumber);
    }

    final requestHash = CryptoUtils.sha256HashBase64(clientData);

    // Retry logic for expired token providers
    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        return await _service.requestIntegrityToken(requestHash);
      } on PlayIntegrityException catch (e) {
        final isProviderInvalid =
            e.nativeErrorCode ==
            StandardIntegrityErrorCode.INTEGRITY_TOKEN_PROVIDER_INVALID;

        // If provider is invalid and we have a project number, refresh and retry
        if (isProviderInvalid && projectNumber != null) {
          await _service.refreshTokenProvider(projectNumber);
          continue;
        }

        // Otherwise, throw the error
        throw PlatformException(
          code: e.code.name,
          message: e.message,
          details: e.details,
        );
      }
    }

    // If we exhausted all retries
    throw PlatformException(
      code: 'max_retries_exceeded',
      message: 'Failed to get integrity token after $_maxRetries attempts.',
    );
  }
}

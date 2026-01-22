// ignore_for_file: avoid-long-functions

import 'dart:async';
import 'dart:convert';

import 'package:app_attest_integrity/app_attest_integrity_platform_interface.dart';
import 'package:app_attest_integrity/src/android/play_integrity_bindings.g.dart';
import 'package:app_attest_integrity/src/model/generate_attestation_response.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:jni/jni.dart';

/// Implementation of [AppAttestIntegrityPlatform] that uses JNI.
/// Is used on Android only.
class AppAttestIntegrityJni extends AppAttestIntegrityPlatform {
  StandardIntegrityManager? _standardIntegrityManager;
  StandardIntegrityManager$StandardIntegrityTokenProvider? _tokenProvider;
  int? _cloudProjectNumber;

  StandardIntegrityManager _getManager() {
    if (_standardIntegrityManager != null) {
      return _standardIntegrityManager!;
    }

    final context = Jni.androidApplicationContext;
    _standardIntegrityManager = IntegrityManagerFactory.createStandard(context);
    return _standardIntegrityManager!;
  }

  @override
  Future<void> androidPrepareIntegrityServer(int cloudProjectNumber) async {
    _cloudProjectNumber = cloudProjectNumber;
    final completer = Completer<void>();

    final request =
        StandardIntegrityManager$PrepareIntegrityTokenRequest.builder()
            ?.setCloudProjectNumber(cloudProjectNumber)
            ?.build();

    final task = _getManager().prepareIntegrityToken(request);

    final successListener = OnSuccessListener<
        StandardIntegrityManager$StandardIntegrityTokenProvider?>.implement(
      $OnSuccessListener(
        TResult:
            const $StandardIntegrityManager$StandardIntegrityTokenProvider$NullableType$(),
        onSuccess: (provider) {
          _tokenProvider = provider;
          completer.complete();
        },
      ),
    );

    final failureListener = OnFailureListener.implement(
      $OnFailureListener(
        onFailure: (exception) {
          completer.completeError(
            PlatformException(
              code: 'prepare_failed',
              message: 'Failed to prepare integrity token',
              details: exception?.toString(),
            ),
          );
        },
      ),
    );

    task?.addOnSuccessListener(successListener);
    task?.addOnFailureListener(failureListener);

    return completer.future;
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
    final provider = _tokenProvider;

    if (provider == null) {
      final projectNumber = androidCloudProjectNumber ?? _cloudProjectNumber;
      if (projectNumber == null) {
        throw PlatformException(
          code: 'no_project_number',
          message:
              'cloudProjectNumber not set. Call androidPrepareIntegrityServer first or provide androidCloudProjectNumber.',
        );
      }

      // Prepare first if not done
      await androidPrepareIntegrityServer(projectNumber);
    }

    final completer = Completer<String>();

    // Hash the client data
    final requestHashBytes = sha256.convert(utf8.encode(clientData)).bytes;
    final requestHash = base64.encode(requestHashBytes);

    final request =
        StandardIntegrityManager$StandardIntegrityTokenRequest.builder()
            ?.setRequestHash(requestHash.toJString())
            ?.build();

    final task = _tokenProvider!.request(request);

    final successListener =
        OnSuccessListener<StandardIntegrityManager$StandardIntegrityToken?>.implement(
      $OnSuccessListener(
        TResult:
            const $StandardIntegrityManager$StandardIntegrityToken$NullableType$(),
        onSuccess: (token) {
          final tokenString = token?.token()?.toDartString(releaseOriginal: true);
          if (tokenString != null) {
            completer.complete(tokenString);
          } else {
            completer.completeError(
              PlatformException(
                code: 'token_null',
                message: 'Received null token',
              ),
            );
          }
        },
      ),
    );

    final failureListener = OnFailureListener.implement(
      $OnFailureListener(
        onFailure: (exception) {
          completer.completeError(
            PlatformException(
              code: 'verify_failed',
              message: 'Failed to generate integrity token',
              details: exception?.toString(),
            ),
          );
        },
      ),
    );

    task?.addOnSuccessListener(successListener);
    task?.addOnFailureListener(failureListener);

    return completer.future;
  }
}

import 'dart:async';

import 'package:app_attest_integrity/src/android/play_integrity_bindings.g.dart';
import 'package:jni/jni.dart';

/// Raw error from native Android APIs.
class JniNativeError {
  /// Creates a new [JniNativeError].
  JniNativeError({this.details});

  /// Error details from the native exception.
  final String? details;
}

/// Pure JNI wrapper around Android Play Integrity API.
/// Only handles type conversions and native calls.
/// No business logic, no error messages, no orchestration.
class PlayIntegrityJni {
  StandardIntegrityManager? _manager;

  /// Creates or returns the cached StandardIntegrityManager.
  StandardIntegrityManager _getManager() {
    if (_manager != null) return _manager!;

    final context = Jni.androidApplicationContext;
    _manager = IntegrityManagerFactory.createStandard(context);
    return _manager!;
  }

  /// Prepares an integrity token provider for the given cloud project number.
  /// Returns the token provider on success, throws [JniNativeError] on failure.
  Future<StandardIntegrityManager$StandardIntegrityTokenProvider>
      prepareTokenProvider(int cloudProjectNumber) {
    final completer =
        Completer<StandardIntegrityManager$StandardIntegrityTokenProvider>();

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
          if (provider != null) {
            completer.complete(provider);
          } else {
            completer.completeError(JniNativeError(details: 'Provider is null'));
          }
        },
      ),
    );

    final failureListener = OnFailureListener.implement(
      $OnFailureListener(
        onFailure: (exception) {
          completer.completeError(JniNativeError(details: exception?.toString()));
        },
      ),
    );

    task?.addOnSuccessListener(successListener);
    task?.addOnFailureListener(failureListener);

    return completer.future;
  }

  /// Requests an integrity token using the given provider and request hash.
  /// [requestHash] should be a base64 encoded hash string.
  /// Returns the token string on success, throws [JniNativeError] on failure.
  Future<String> requestToken({
    required StandardIntegrityManager$StandardIntegrityTokenProvider provider,
    required String requestHash,
  }) {
    final completer = Completer<String>();

    final request =
        StandardIntegrityManager$StandardIntegrityTokenRequest.builder()
            ?.setRequestHash(requestHash.toJString())
            ?.build();

    final task = provider.request(request);

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
            completer.completeError(JniNativeError(details: 'Token is null'));
          }
        },
      ),
    );

    final failureListener = OnFailureListener.implement(
      $OnFailureListener(
        onFailure: (exception) {
          completer.completeError(JniNativeError(details: exception?.toString()));
        },
      ),
    );

    task?.addOnSuccessListener(successListener);
    task?.addOnFailureListener(failureListener);

    return completer.future;
  }
}

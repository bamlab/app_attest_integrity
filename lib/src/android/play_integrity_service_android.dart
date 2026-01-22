import 'package:app_attest_integrity/src/android/play_integrity_bindings.g.dart';
import 'package:app_attest_integrity/src/android/play_integrity_jni.dart';

/// Error codes for Play Integrity operations.
enum PlayIntegrityErrorCode {
  /// Token provider has not been prepared yet.
  notPrepared,

  /// Failed to prepare the token provider.
  prepareFailed,

  /// Failed to request an integrity token.
  requestFailed,
}

/// Exception thrown by Play Integrity operations.
class PlayIntegrityException implements Exception {
  /// Creates a new [PlayIntegrityException].
  PlayIntegrityException({
    required this.code,
    required this.message,
    this.details,
  });

  /// The error code.
  final PlayIntegrityErrorCode code;

  /// The error message.
  final String message;

  /// Additional error details, if available.
  final String? details;

  @override
  String toString() => 'PlayIntegrityException: $message';
}

/// Service for Android Play Integrity operations.
/// Contains business logic and orchestration.
/// Uses [PlayIntegrityJni] for native interop.
class PlayIntegrityServiceAndroid {
  /// Creates a new [PlayIntegrityServiceAndroid].
  /// Optionally accepts a [PlayIntegrityJni] for testing.
  PlayIntegrityServiceAndroid({PlayIntegrityJni? jni})
    : _jni = jni ?? PlayIntegrityJni();

  final PlayIntegrityJni _jni;
  StandardIntegrityManager$StandardIntegrityTokenProvider? _tokenProvider;

  /// Returns true if a token provider has been prepared.
  bool get isPrepared => _tokenProvider != null;

  /// Prepares the integrity token provider with the given cloud project number.
  ///
  /// Must be called before [requestIntegrityToken].
  /// Throws [PlayIntegrityException] on failure.
  Future<void> prepareTokenProvider(int cloudProjectNumber) async {
    try {
      _tokenProvider = await _jni.prepareTokenProvider(cloudProjectNumber);
    } on JniNativeError catch (e) {
      throw PlayIntegrityException(
        code: PlayIntegrityErrorCode.prepareFailed,
        message: 'Failed to prepare integrity token',
        details: e.details,
      );
    }
  }

  /// Requests an integrity token with the given request hash.
  ///
  /// [requestHash] should be a base64 encoded SHA256 hash of the client data.
  /// Returns the integrity token string on success.
  /// Throws [PlayIntegrityException] on failure.
  Future<String> requestIntegrityToken(String requestHash) async {
    final provider = _tokenProvider;
    if (provider == null) {
      throw PlayIntegrityException(
        code: PlayIntegrityErrorCode.notPrepared,
        message: 'Token provider not prepared. Call prepareTokenProvider first.',
      );
    }

    try {
      return await _jni.requestToken(provider: provider, requestHash: requestHash);
    } on JniNativeError catch (e) {
      throw PlayIntegrityException(
        code: PlayIntegrityErrorCode.requestFailed,
        message: 'Failed to generate integrity token',
        details: e.details,
      );
    }
  }
}

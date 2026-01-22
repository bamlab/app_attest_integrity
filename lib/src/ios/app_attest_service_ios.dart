import 'package:app_attest_integrity/src/ios/device_check_ffi.dart';

/// Result of a successful attestation.
class AttestationResult {
  /// Creates a new [AttestationResult].
  AttestationResult({required this.keyId, required this.attestationBytes});

  /// The key identifier used for attestation.
  final String keyId;

  /// The raw attestation bytes.
  final List<int> attestationBytes;
}

/// Error codes for App Attest operations.
enum AppAttestErrorCode {
  /// Failed to generate the attestation key.
  generateKeyFailed,

  /// Failed to attest the key.
  attestKeyFailed,
}

/// Exception thrown by App Attest operations.
class AppAttestException implements Exception {
  /// Creates a new [AppAttestException].
  AppAttestException({
    required this.code,
    required this.message,
    this.nativeError,
  });

  /// The error code.
  final AppAttestErrorCode code;

  /// The error message.
  final String message;

  /// Native error details from iOS, if available.
  final Map<String, dynamic>? nativeError;

  @override
  String toString() => 'AppAttestException: $message';
}

/// Service for iOS App Attest operations.
/// Contains business logic and orchestration.
/// Uses [DeviceCheckFfi] for native interop.
class AppAttestServiceIos {
  /// Creates a new [AppAttestServiceIos].
  /// Optionally accepts a [DeviceCheckFfi] for testing.
  AppAttestServiceIos({DeviceCheckFfi? ffi})
    : _ffi = ffi ?? DeviceCheckFfi.shared();

  final DeviceCheckFfi _ffi;

  /// Returns true if App Attest is supported on this device.
  bool get isSupported => _ffi.isSupported;

  /// Generates a new attestation key and attests it with the given hash.
  ///
  /// [clientDataHash] should be the SHA256 hash of the challenge.
  /// Returns [AttestationResult] on success.
  /// Throws [AppAttestException] on failure.
  Future<AttestationResult> generateAndAttestKey(
    List<int> clientDataHash,
  ) async {
    // Step 1: Generate key
    final String keyId;
    try {
      final keyResult = await _ffi.generateKey();
      keyId = keyResult.keyId;
    } on FfiNativeError catch (e) {
      throw AppAttestException(
        code: AppAttestErrorCode.generateKeyFailed,
        message: 'Failed to generate App Attest key.',
        nativeError: _errorToMap(e),
      );
    }

    // Step 2: Attest key
    try {
      final attestResult = await _ffi.attestKey(
        keyId: keyId,
        clientDataHash: clientDataHash,
      );
      return AttestationResult(
        keyId: keyId,
        attestationBytes: attestResult.attestationBytes,
      );
    } on FfiNativeError catch (e) {
      throw AppAttestException(
        code: AppAttestErrorCode.attestKeyFailed,
        message: 'Failed to attest App Attest key.',
        nativeError: _errorToMap(e),
      );
    }
  }

  Map<String, dynamic> _errorToMap(FfiNativeError e) => {
    'domain': e.domain,
    'code': e.code,
    'desc': e.description,
  };
}

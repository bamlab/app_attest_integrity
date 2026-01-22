import 'dart:async';

import 'package:app_attest_integrity/src/ios/device_check_bindings.g.dart'
    as bindings;
import 'package:objective_c/objective_c.dart' as objc;

/// Raw result from FFI key generation.
class FfiKeyResult {
  /// Creates a new [FfiKeyResult] with the given [keyId].
  FfiKeyResult({required this.keyId});

  /// The generated key identifier.
  final String keyId;
}

/// Raw result from FFI attestation.
class FfiAttestationResult {
  /// Creates a new [FfiAttestationResult] with the given [attestationBytes].
  FfiAttestationResult({required this.attestationBytes});

  /// The raw attestation object bytes.
  final List<int> attestationBytes;
}

/// Raw error from native iOS APIs.
class FfiNativeError {
  /// Creates a new [FfiNativeError].
  FfiNativeError({this.domain, this.code, this.description});

  /// The error domain from NSError.
  final String? domain;

  /// The error code from NSError.
  final int? code;

  /// The localized description from NSError.
  final String? description;
}

/// Pure FFI wrapper around iOS DCAppAttestService.
/// Only handles type conversions and native calls.
/// No business logic, no error messages, no orchestration.
class DeviceCheckFfi {
  DeviceCheckFfi._({required bindings.DCAppAttestService service})
    : _service = service;

  /// Gets the shared App Attest service instance.
  factory DeviceCheckFfi.shared() {
    return DeviceCheckFfi._(
      service: bindings.DCAppAttestService.getSharedService(),
    );
  }

  final bindings.DCAppAttestService _service;

  /// Returns true if App Attest is supported on this device.
  bool get isSupported => _service.isSupported;

  /// Generates a new attestation key.
  /// Returns the key ID on success, throws [FfiNativeError] on failure.
  Future<FfiKeyResult> generateKey() {
    final completer = Completer<FfiKeyResult>();

    _service.generateKeyWithCompletionHandler(
      bindings.ObjCBlock_ffiVoid_NSString_NSError.listener((keyId, error) {
        if (error != null || keyId == null) {
          completer.completeError(_extractError(error));
          return;
        }
        completer.complete(FfiKeyResult(keyId: keyId.toDartString()));
      }),
    );

    return completer.future;
  }

  /// Attests a key with the given client data hash.
  /// [keyId] is the key ID from [generateKey].
  /// [clientDataHash] is the raw hash bytes.
  /// Returns attestation bytes on success, throws [FfiNativeError] on failure.
  Future<FfiAttestationResult> attestKey({
    required String keyId,
    required List<int> clientDataHash,
  }) {
    final completer = Completer<FfiAttestationResult>();

    final nsKeyId = keyId.toNSString();
    final nsDataHash = clientDataHash.toNSData();

    _service.attestKey(
      nsKeyId,
      clientDataHash: nsDataHash,
      completionHandler: bindings.ObjCBlock_ffiVoid_NSData_NSError.listener((
        attestationObject,
        error,
      ) {
        if (error != null || attestationObject == null) {
          completer.completeError(_extractError(error));
          return;
        }
        completer.complete(
          FfiAttestationResult(attestationBytes: attestationObject.toList()),
        );
      }),
    );

    return completer.future;
  }

  FfiNativeError _extractError(objc.NSError? error) {
    return FfiNativeError(
      domain: error?.domain.toString(),
      code: error?.code,
      description: error?.localizedDescription.toString(),
    );
  }
}

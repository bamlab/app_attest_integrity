// ignore_for_file: avoid-long-functions

import 'dart:async';
import 'dart:convert';

import 'package:app_attest_integrity/app_attest_integrity_platform_interface.dart';
import 'package:app_attest_integrity/src/ios/device_check_bindings.g.dart'
    as bindings;
import 'package:app_attest_integrity/src/model/generate_attestation_response.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:objective_c/objective_c.dart' as objc;

/// Implementation of [AppAttestIntegrityPlatform] that uses FFI.
/// Is used on iOS only.
class AppAttestIntegrityFfi extends AppAttestIntegrityPlatform {
  @override
  Future<GenerateAttestationResponse?> iOSgenerateAttestation(
    String challenge,
  ) async {
    final service = bindings.DCAppAttestService.getSharedService();

    if (!service.isSupported) {
      throw Exception('App Attest is not supported on this device.');
    }

    final completer = Completer<GenerateAttestationResponse?>();

    service.generateKeyWithCompletionHandler(
      bindings.ObjCBlock_ffiVoid_NSString_NSError.listener((keyId, error) {
        if (error != null || keyId == null) {
          completer.completeError(
            PlatformException(
              code: 'generate_key_failed',
              message: 'Failed to generate App Attest key.',
              details: {
                'domain': error?.domain.toString(),
                'code': error?.code,
                'desc': error?.localizedDescription.toString(),
              },
            ),
          );
          return;
        }

        final clientDataHash = sha256
            .convert(utf8.encode(challenge))
            .bytes
            .toNSData();

        service.attestKey(
          keyId,
          clientDataHash: clientDataHash,
          completionHandler: bindings.ObjCBlock_ffiVoid_NSData_NSError.listener(
            (attestationObject, attestationError) {
              if (attestationError != null || attestationObject == null) {
                completer.completeError(
                  PlatformException(
                    code: 'attest_key_failed',
                    message: 'Failed to attest App Attest key.',
                    details: {
                      'domain': attestationError?.domain.toString(),
                      'code': attestationError?.code,
                      'desc': attestationError?.localizedDescription.toString(),
                    },
                  ),
                );
                return;
              }
              completer.complete(
                GenerateAttestationResponse(
                  attestation: base64.encode(attestationObject.toList()),
                  keyId: keyId.toDartString(),
                ),
              );
            },
          ),
        );
      }),
    );

    return completer.future;
  }
}

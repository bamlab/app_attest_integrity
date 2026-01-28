import 'dart:io' show Platform;

import 'package:app_attest_integrity/src/android/app_attest_integrity_android.dart';
import 'package:app_attest_integrity/src/ios/app_attest_integrity_ios.dart';
import 'package:app_attest_integrity/src/model/generate_attestation_response.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Platform interface for the AppAttestIntegrity plugin.
/// Extend this class to implement the platform-specific logic
/// for a new platform.
abstract class AppAttestIntegrityPlatform extends PlatformInterface {
  /// Platform interface for the AppAttestIntegrity plugin.
  /// Extend this class to implement the platform-specific logic
  /// for a new platform.
  AppAttestIntegrityPlatform() : super(token: _token);

  // ignore: no-object-declaration, standard for platform interface
  static final Object _token = Object();

  static AppAttestIntegrityPlatform _instance = _createDefaultInstance();

  static AppAttestIntegrityPlatform _createDefaultInstance() {
    if (Platform.isIOS) {
      return AppAttestIntegrityIos();
    } else if (Platform.isAndroid) {
      return AppAttestIntegrityAndroid();
    }
    throw UnsupportedError(
      'AppAttestIntegrity is only supported on iOS and Android.',
    );
  }

  /// The default instance of [AppAttestIntegrityPlatform] to use.
  ///
  /// Uses FFI on iOS and JNI on Android.
  static AppAttestIntegrityPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AppAttestIntegrityPlatform] when
  /// they register themselves.
  static set instance(AppAttestIntegrityPlatform value) {
    PlatformInterface.verifyToken(value, _token);
    _instance = value;
  }

  /// {@macro androidPrepareIntegrityServer}
  Future<void> androidPrepareIntegrityServer(int cloudProjectNumber) {
    throw UnimplementedError(
      'androidPrepareIntegrityServer() has not been implemented.',
    );
  }

  /// {@macro iOSgenerateAttestation}
  Future<GenerateAttestationResponse?> iOSgenerateAttestation(
    String challenge,
  ) {
    throw UnimplementedError(
      'iOSgenerateAttestation() has not been implemented.',
    );
  }

  /// {@macro verify}
  Future<String> verify({
    required String clientData,
    String? iOSkeyID,
    int? androidCloudProjectNumber,
  }) {
    throw UnimplementedError(
      'iOSgenerateAttestation() has not been implemented.',
    );
  }
}

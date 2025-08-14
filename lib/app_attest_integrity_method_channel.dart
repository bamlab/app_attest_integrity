import 'package:app_attest_integrity/app_attest_integrity_platform_interface.dart';
import 'package:app_attest_integrity/src/messages.g.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Implementation of [AppAttestIntegrityPlatform] that uses method channels.
/// Is listened on iOS and Android.
class MethodChannelAppAttestIntegrity extends AppAttestIntegrityPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('app_attest_integrity');

  @override
  Future<String?> getPlatformVersion() {
    return AppAttestIntegrityApi().getPlatformVersion();
  }
}

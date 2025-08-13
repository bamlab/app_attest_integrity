import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_attest_integrity_platform_interface.dart';

/// An implementation of [AppAttestIntegrityPlatform] that uses method channels.
class MethodChannelAppAttestIntegrity extends AppAttestIntegrityPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('app_attest_integrity');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}

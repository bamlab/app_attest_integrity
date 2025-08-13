import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'app_attest_integrity_method_channel.dart';

abstract class AppAttestIntegrityPlatform extends PlatformInterface {
  /// Constructs a AppAttestIntegrityPlatform.
  AppAttestIntegrityPlatform() : super(token: _token);

  static final Object _token = Object();

  static AppAttestIntegrityPlatform _instance = MethodChannelAppAttestIntegrity();

  /// The default instance of [AppAttestIntegrityPlatform] to use.
  ///
  /// Defaults to [MethodChannelAppAttestIntegrity].
  static AppAttestIntegrityPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AppAttestIntegrityPlatform] when
  /// they register themselves.
  static set instance(AppAttestIntegrityPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

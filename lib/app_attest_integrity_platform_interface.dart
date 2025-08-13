import 'package:app_attest_integrity/app_attest_integrity_method_channel.dart';
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

  static AppAttestIntegrityPlatform _instance =
      MethodChannelAppAttestIntegrity();

  /// The default instance of [AppAttestIntegrityPlatform] to use.
  ///
  /// Defaults to [MethodChannelAppAttestIntegrity].
  static AppAttestIntegrityPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AppAttestIntegrityPlatform] when
  /// they register themselves.
  static set instance(AppAttestIntegrityPlatform value) {
    PlatformInterface.verifyToken(value, _token);
    _instance = value;
  }

  /// Get the platform version.
  ///
  /// This a hello world method, will be removed later.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

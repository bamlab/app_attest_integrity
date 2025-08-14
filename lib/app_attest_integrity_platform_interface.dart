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

  /// [Android only]<br/>
  /// Warm up the integrity API server.
  ///
  /// Use this method on Android when you plan to use the `verify` method
  /// in a near future.
  /// See [this android official doc](https://developer.android.com/google/play/integrity/standard) for more details.
  ///
  /// [cloudProjectNumber] is the cloud project number of your app.
  /// It can be found in the Google Play Console.
  ///
  /// This method will do nothing on iOS.
  Future<void> androidPrepareIntegrityServer(int cloudProjectNumber) {
    throw UnimplementedError(
      'androidPrepareIntegrityServer() has not been implemented.',
    );
  }
}

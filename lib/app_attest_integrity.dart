import 'package:app_attest_integrity/app_attest_integrity_platform_interface.dart';

/// This class is used to assess an app integrity.
/// Uses App attest on iOS and app Integrity on Android.
class AppAttestIntegrity {
  /// This class is used to assess an app integrity.
  /// Uses App attest on iOS and app Integrity on Android.
  const AppAttestIntegrity();

  /// Get the platform version.
  ///
  /// This a hello world method, will be removed later.
  Future<String?> getPlatformVersion() {
    return AppAttestIntegrityPlatform.instance.getPlatformVersion();
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
  Future<void> androidPrepareIntegrityServer(int cloudProjectNumber) {
    return AppAttestIntegrityPlatform.instance.androidPrepareIntegrityServer(
      cloudProjectNumber,
    );
  }
}

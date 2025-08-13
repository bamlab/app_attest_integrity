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
}

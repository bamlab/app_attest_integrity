
import 'app_attest_integrity_platform_interface.dart';

class AppAttestIntegrity {
  Future<String?> getPlatformVersion() {
    return AppAttestIntegrityPlatform.instance.getPlatformVersion();
  }
}

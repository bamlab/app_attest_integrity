import 'package:app_attest_integrity/app_attest_integrity.dart';
import 'package:app_attest_integrity/app_attest_integrity_method_channel.dart';
import 'package:app_attest_integrity/app_attest_integrity_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAppAttestIntegrityPlatform
    with MockPlatformInterfaceMixin
    implements AppAttestIntegrityPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final initialPlatform = AppAttestIntegrityPlatform.instance;

  test('$MethodChannelAppAttestIntegrity is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAppAttestIntegrity>());
  });

  test('getPlatformVersion', () async {
    const appAttestIntegrityPlugin = AppAttestIntegrity();
    final fakePlatform = MockAppAttestIntegrityPlatform();
    AppAttestIntegrityPlatform.instance = fakePlatform;

    expect(await appAttestIntegrityPlugin.getPlatformVersion(), '42');
  });
}

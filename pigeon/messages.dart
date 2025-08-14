// ignore_for_file: one_member_abstracts

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/theodo/app_attest_integrity/Messages.g.kt',
    kotlinOptions: KotlinOptions(),
    swiftOut: 'ios/Runner/Messages.g.swift',
    swiftOptions: SwiftOptions(),
    dartPackageName: 'app_attest_integrity',
  ),
)
@HostApi()
abstract class AppAttestIntegrityApi {
  String? getPlatformVersion();
}

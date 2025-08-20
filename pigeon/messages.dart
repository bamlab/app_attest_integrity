// ignore_for_file: one_member_abstracts

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/theodo/app_attest_integrity/Messages.g.kt',
    kotlinOptions: KotlinOptions(),
    swiftOut: 'ios/Classes/Messages.g.swift',
    swiftOptions: SwiftOptions(),
    dartPackageName: 'app_attest_integrity',
  ),
)
@HostApi()
abstract class AppAttestIntegrityApi {
  String? getPlatformVersion();
  @async
  void androidPrepareIntegrityServer(int cloudProjectNumber);
  @async
  GenerateAssertionResponsePigeon? iOSgenerateAttestation(String challenge);
  @async
  String verify(String clientData, String keyID);
}

class GenerateAssertionResponsePigeon {
  const GenerateAssertionResponsePigeon({
    required this.attestation,
    required this.keyId,
  });
  final String attestation;
  final String keyId;
}

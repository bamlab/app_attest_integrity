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
  @async
  void androidPrepareIntegrityServer(int cloudProjectNumber);
  @async
  GenerateAttestationResponsePigeon? iOSgenerateAttestation(String challenge);
  @async
  String verify({
    required String clientData,
    required String keyID,
    int? cloudProjectNumber,
  });
}

class GenerateAttestationResponsePigeon {
  const GenerateAttestationResponsePigeon({
    required this.attestation,
    required this.keyId,
  });
  final String attestation;
  final String keyId;
}

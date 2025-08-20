// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_attest_integrity/app_attest_integrity.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _keyID;

  @override
  Widget build(BuildContext context) {
    // Use your own cloud project number.
    // It can be found in the Google Play Console.
    const cloudProjectNumber = 000000000000;

    // This is the challenge from the server.
    // It is used to avoid replay attacks.
    final challengeFromServer = '8617db7e-ee2b-4ddf-9c45-3a553aa7e4f5';

    // This is the sensible client data that will be sent to the server.
    // You want your server to check that this data is sent by a valid app.
    final clientData = _MockClientData(
      true,
      12678,
      challengeFromServer,
    ).toJson();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                if (defaultTargetPlatform == TargetPlatform.iOS) {
                  try {
                    final response = await AppAttestIntegrity()
                        .iOSgenerateAttestation(challengeFromServer);
                    _keyID = response?.keyId;
                    print("--------------------------------");
                    print(
                      response == null
                          ? "attestation: nothing returned"
                          : "attestation: ${response.attestation}\nkeyID: ${response.keyId}",
                    );
                    print("--------------------------------");
                  } catch (e) {
                    print("error: $e");
                  }
                } else {
                  try {
                    await AppAttestIntegrity().androidPrepareIntegrityServer(
                      cloudProjectNumber,
                    );
                    print("androidPrepareIntegrityServer finished");
                  } catch (e) {
                    print("error: $e");
                  }
                }
              },
              child: Text('setup an attestation / warmup the provider'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final clientDataBase64 = base64Encode(utf8.encode(clientData));
                try {
                  final keyID = _keyID;
                  if (keyID == null) {
                    print(
                      'There is no keyID yet. Tap on the button above first.',
                    );
                    return;
                  }
                  final assertion = await AppAttestIntegrity().verify(
                    clientData: clientDataBase64,
                    keyID: keyID,
                  );
                  print("--------------------------------");
                  print("assertion: $assertion");
                  print("--------------------------------");
                } catch (e) {
                  print(e);
                }
              },
              child: Text('verify the client data'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockClientData {
  const _MockClientData(this.win, this.score, this.challenge);

  final bool win;
  final int score;
  final String challenge;

  String toJson() =>
      json.encode({'win': win, 'score': score, 'challenge': challenge});
}

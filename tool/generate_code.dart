import 'dart:io';

import 'package:ffigen/ffigen.dart';

void main() {
  final sdkPath = Process.runSync('xcrun', [
    '--sdk',
    'iphoneos',
    '--show-sdk-path',
  ]).stdout.toString().trim();

  final generator = FfiGenerator(
    output: Output(
      dartFile: Uri.parse('lib/src/ios/device_check_bindings.g.dart'),
    ),
    headers: Headers(
      entryPoints: [
        Uri.parse(
          '$sdkPath/System/Library/Frameworks/DeviceCheck.framework/Headers/DeviceCheck.h',
        ),
      ],
    ),
    objectiveC: ObjectiveC(
      interfaces: Interfaces.includeSet({'DCDevice', 'DCAppAttestService'}),
    ),
  );

  generator.generate();
}

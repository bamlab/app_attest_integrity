import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

/// Build hook for app_attest_integrity.
///
/// Compiles the Objective-C file generated
/// by ffigen (device_check_bindings.g.dart.m)
/// into a dylib for iOS (only).
void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets && input.config.code.targetOS == .iOS) {
      await CBuilder.library(
        name: input.packageName,
        assetName: '${input.packageName}.dylib',
        sources: ['lib/src/ios/device_check_bindings.g.dart.m'],
        flags: ['-fobjc-arc'],
        frameworks: ['DeviceCheck', 'Foundation'],
        language: .objectiveC,
      ).run(input: input, output: output, logger: Logger(input.packageName));
    }
  });
}

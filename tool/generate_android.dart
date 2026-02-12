// 1. Downloads AARs (Play Integrity, Play Services Tasks), extracts classes.jar
//    into .jnigen_deps/ so jnigen can generate the bindings.
// 2. Runs jnigen (config in jnigen.yaml).
// All in Dart → cross-platform (Windows / Mac / Linux).
import 'dart:io';

import 'package:archive/archive.dart';

const _mavenBase = 'https://maven.google.com';

/// Maven artifact versions (update as needed from
/// https://maven.google.com/web/index.html).
const _integrityVersion = '1.4.0';
const _tasksVersion = '18.2.0';

const _depsDir = '.jnigen_deps';

Future<void> main() async {
  await _setupDeps();
  await _runJnigen();
}

Future<void> _setupDeps() async {
  print('📦 Fetching dependencies (JARs from Maven)...');

  final deps = Directory(_depsDir);
  if (!deps.existsSync()) deps.createSync(recursive: true);
  final tasksDir = Directory('$_depsDir/tasks');
  if (!tasksDir.existsSync()) tasksDir.createSync(recursive: true);

  // 1. Play Integrity API
  final integrityAar = Uri.parse(
    '$_mavenBase/com/google/android/play/integrity/$_integrityVersion/integrity-$_integrityVersion.aar',
  );
  await _downloadAarAndExtractClassesJar(
    integrityAar,
    '$_depsDir/classes.jar',
  );

  // 2. Play Services Tasks (async callbacks)
  final tasksAar = Uri.parse(
    '$_mavenBase/com/google/android/gms/play-services-tasks/$_tasksVersion/play-services-tasks-$_tasksVersion.aar',
  );
  await _downloadAarAndExtractClassesJar(
    tasksAar,
    '$_depsDir/tasks/classes.jar',
  );

  print('✅ Dependencies ready.');
}

Future<void> _downloadAarAndExtractClassesJar(Uri url, String outputPath) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode} for $url');
    }
    final aarBytes = await response.toList().then((l) => l.expand((e) => e).toList());
    final archive = ZipDecoder().decodeBytes(aarBytes);

    final classesEntry = archive.findFile('classes.jar');
    if (classesEntry == null) {
      throw Exception('No classes.jar in ${url.pathSegments.last}');
    }
    final classesBytes = classesEntry.readBytes();
    if (classesBytes == null || classesBytes.isEmpty) {
      throw Exception('Empty classes.jar in ${url.pathSegments.last}');
    }
    File(outputPath)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(classesBytes);
  } finally {
    client.close();
  }
}

Future<void> _runJnigen() async {
  print('🤖 Generating Android bindings via jnigen...');

  final process = await Process.start(
    'dart',
    ['run', 'jnigen', '--config', 'jnigen.yaml'],
    mode: ProcessStartMode.inheritStdio,
  );

  exit(await process.exitCode);
}

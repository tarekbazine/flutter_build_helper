import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class BuildParams {
  String versionNumber;
  bool generateApk;
  bool generateAab;
  String outputPath;

  BuildParams(
    this.versionNumber,
    this.generateApk,
    this.outputPath,
    this.generateAab,
  );

  @override
  String toString() {
    return 'BuildParams{versionNumber: $versionNumber, generateApk: $generateApk}';
  }
}

const VERSION_ARG = 'v';
const OUTPUT_PATH_ARG = 'out-path';

const APK_FLAG_ARG = 'apk';
const NO_AAB_FLAG_ARG = 'no-aab';

BuildParams parseAndValidateBuildParams(List<String> arguments) {
  final parser = ArgParser();

  parser.addFlag(APK_FLAG_ARG);
  parser.addFlag(NO_AAB_FLAG_ARG);

  parser.addOption(VERSION_ARG, callback: (version) {
    if (version == null || version.isEmpty)
      throw ('Please make sure to provide a version argument !');
  });

  parser.addOption(OUTPUT_PATH_ARG);

  ArgResults argResults = parser.parse(arguments);

  return BuildParams(
    argResults[VERSION_ARG],
    argResults[APK_FLAG_ARG],
    argResults[OUTPUT_PATH_ARG],
    !argResults[NO_AAB_FLAG_ARG],
  );
}

void build(BuildParams arg) {
  buildForAndroid(arg);
}

void buildForAndroid(BuildParams arg) async {
  exitCode = 0; // presume success

  // step - edit version num -> pubspec, config
  final pusSpecPath = './pubspec.yaml';
  await updateLineInFile(
    pusSpecPath,
    'version:',
    'version: ${arg.versionNumber}',
  );

  // todo setup edit stuff

  // todo setup to check stuff

  // step - build then copy to desk (rename)
  var outputPath = arg.outputPath == null || arg.outputPath.isEmpty
      ? getHomePath()
      : arg.outputPath;

  print(outputPath);

  final File file = File(pusSpecPath);
  final String yamlString = file.readAsStringSync();
  var yaml = loadYaml(yamlString);

  var outputFileName = '${yaml['name']}_app_v${arg.versionNumber}';
  print(outputFileName);
  if (arg.generateAab) {
    print('-------- STARTED AAB -----------');
    Process process = await Process.start(
      'flutter build appbundle --target-platform android-arm,android-arm64,android-x64',
      [],
      runInShell: true,
    );

    process.stdout.transform(utf8.decoder).listen((data) {
      print(data);
    }).onDone(() {});

    await process.exitCode;

    ProcessResult results = await Process.run(
      'move',
      [
        p.join(Directory.current.path,
            p.normalize('build/app/outputs/bundle/release/app-release.aab')),
        p.join(p.normalize(outputPath), '${outputFileName}.aab'),
      ],
      runInShell: true,
    );
    print(results.exitCode);
    print(results.stdout);
    print(results.stderr);

    print('-------- FINISHED AAB -----------');
  }

  if (arg.generateApk) {
    print('-------- STARTED APK -----------');

    Process process = await Process.start(
      'flutter build apk --release',
      [],
      runInShell: true,
    );

    process.stdout.transform(utf8.decoder).listen((data) {
      print(data);
    }).onDone(() {});

    await process.exitCode;

    ProcessResult results = await Process.run(
      'move',
      [
        p.join(Directory.current.path,
            p.normalize('build/app/outputs/apk/release/app-release.apk')),
        p.join(p.normalize(outputPath), '${outputFileName}.apk'),
      ],
      runInShell: true,
    );
    print(results.exitCode);
    print(results.stdout);
    print(results.stderr);

    print('-------- FINISHED APK -----------');
  }
}

Future updateLineInFile(
    String filePath, String lineStartsWith, String replaceBy) async {
  final lines = await utf8.decoder
      .bind(File(filePath).openRead())
      .transform(const LineSplitter())
      .toList();

  final idx = lines.indexWhere((line) {
    return line.startsWith(lineStartsWith);
  });

  print('old "${lines[idx]}" => new : "$replaceBy"');
  lines[idx] = replaceBy;

  return File(filePath).writeAsString(lines.join('\n'));
}

String getHomePath() {
  Map<String, String> envVars = Platform.environment;

  if (Platform.isMacOS) {
    return envVars['HOME'];
  }

  if (Platform.isLinux) {
    return envVars['HOME'];
  }

  if (Platform.isWindows) {
    return envVars['UserProfile'];
  }

  return null;
}

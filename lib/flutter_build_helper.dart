import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

// dart build.dart --v=1.3.0+5 --apk
// by default will build only aab
// if --apk will build an apk also

// version argument is a string ex :  --v=1.3.0+5

class BuildParams {
  String versionNumber;
  bool generateApk;
  String outputPath;

  BuildParams(
    this.versionNumber,
    this.generateApk,
    this.outputPath,
  );

  @override
  String toString() {
    return 'BuildParams{versionNumber: $versionNumber, generateApk: $generateApk}';
  }
}

const VERSION_ARG = 'v';
const OUTPUT_PATH_ARG = 'out-path';

const APK_FLAG_ARG = 'apk';

BuildParams parseAndValidateBuildParams(List<String> arguments) {
  final parser = ArgParser();

  parser.addFlag(APK_FLAG_ARG);

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
  );
}

void build(BuildParams arg) {
  buildForAndroid(arg);
}

void buildForAndroid(BuildParams arg) async {
  exitCode = 0; // presume success

  // step 1 - edit version num -> pubspec, config
  final pusSpecPath = './pubspec.yaml';
  await updateLineInFile(
    pusSpecPath,
    'version:',
    'version: ${arg.versionNumber}',
  );

  // todo setup edit stuff

  // todo setup to check stuff

  // step 3 - build then copy to desk (rename)
  var outputPath = arg.outputPath == null || arg.outputPath.isEmpty
      ? getHomePath()
      : arg.outputPath;

  print(outputPath);

  final File file = File(pusSpecPath);
  final String yamlString = file.readAsStringSync();
  var yaml = loadYaml(yamlString);

  var outputFileName = '${yaml['name']}_app_v${arg.versionNumber}';
  print(outputFileName);

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

  // ProcessResult results = await Process.run(
  //     'move',
  //     [
  //       'D:\\codeLabs\\tamejida\\build\\app\\outputs\\bundle\\release\\app.aab',
  //       'C:\\Users\\Tarek BAZ\\Desktop\\${outputFileName}.aab'
  //     ],
  //     runInShell: true);
  // print(results.exitCode);
  // print(results.stdout);
  // print(results.stderr);

  print('-------- FINISHED AAB -----------');

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

    // ProcessResult results = await Process.run(
    //     'move',
    //     [
    //       'D:\\codeLabs\\tamejida\\build\\app\\outputs\\apk\\release\\app-release.apk',
    //       'C:\\Users\\Tarek BAZ\\Desktop\\${outputFileName}.apk'
    //     ],
    //     runInShell: true);
    // print(results.exitCode);
    // print(results.stdout);
    // print(results.stderr);

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

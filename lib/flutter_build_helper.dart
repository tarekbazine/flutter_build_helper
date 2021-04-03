import 'package:args/args.dart';

// dart build.dart --v=1.3.0+5 --apk
// by default will build only aab
// if --apk will build an apk also

// version argument is a string ex :  --v=1.3.0+5

class BuildParams {
  String versionNumber;
  bool generateApk;

  BuildParams(this.versionNumber, this.generateApk);

  @override
  String toString() {
    return 'BuildParams{versionNumber: $versionNumber, generateApk: $generateApk}';
  }
}

const VERSION_ARG = 'v';

const APK_FLAG_ARG = 'apk';

BuildParams parseAndValidateBuildParams(List<String> arguments) {
  final parser = ArgParser();

  parser.addFlag(APK_FLAG_ARG);

  parser.addOption(VERSION_ARG, callback: (version) {
    if (version == null || version.isEmpty)
      throw ('Please make sure to provide a version argument !');
  });

  ArgResults argResults = parser.parse(arguments);

  return BuildParams(
    argResults[VERSION_ARG],
    argResults[APK_FLAG_ARG],
  );
}

void build(BuildParams arg) {
  buildForAndroid(arg);
}

void buildForAndroid(BuildParams arg) {}

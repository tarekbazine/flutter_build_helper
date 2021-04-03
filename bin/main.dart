import 'package:flutter_build_helper/flutter_build_helper.dart';

void main(List<String> arguments) {
  BuildParams arg = parseAndValidateBuildParams(arguments);
  print(arg);

  build(arg);
}

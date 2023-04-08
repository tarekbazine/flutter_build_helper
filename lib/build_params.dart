class BuildParams {
  String versionNumber;
  bool generateApk;
  bool generateAab;
  String? outputPath;

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
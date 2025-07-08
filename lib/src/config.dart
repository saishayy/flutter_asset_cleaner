class Config {
  final String projectPath;
  final bool isDryRun;
  final bool isInteractive;
  final bool isVerbose;
  final List<String> excludePatterns;
  final List<String> extensions;

  Config({
    required this.projectPath,
    this.isDryRun = false,
    this.isInteractive = false,
    this.isVerbose = false,
    this.excludePatterns = const [],
    this.extensions = const ['png', 'jpg', 'jpeg', 'gif', 'svg', 'webp', 'json', 'ttf', 'otf'],
  });

  List<String> get assetExtensions => extensions.map((e) => '.$e').toList();
}
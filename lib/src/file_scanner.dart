import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:glob/glob.dart';
import 'config.dart';

class FileScanner {
  final Config config;

  FileScanner(this.config);

  /// Get all asset files in the project
  Future<List<File>> getAssetFiles() async {
    final assetDir = Directory(path.join(config.projectPath, 'assets'));
    if (!await assetDir.exists()) {
      return [];
    }

    final assets = <File>[];
    await for (final entity in assetDir.list(recursive: true)) {
      if (entity is File) {
        final extension = path.extension(entity.path).toLowerCase();
        if (config.assetExtensions.contains(extension)) {
          if (!_isExcluded(entity.path)) {
            assets.add(entity);
          }
        }
      }
    }
    return assets;
  }

  /// Get all Dart files in the project
  Future<List<File>> getDartFiles() async {
    final libDir = Directory(path.join(config.projectPath, 'lib'));
    if (!await libDir.exists()) {
      return [];
    }

    final dartFiles = <File>[];
    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && path.extension(entity.path) == '.dart') {
        dartFiles.add(entity);
      }
    }
    return dartFiles;
  }

  /// Get pubspec.yaml file
  Future<File?> getPubspecFile() async {
    final pubspecPath = path.join(config.projectPath, 'pubspec.yaml');
    final pubspecFile = File(pubspecPath);
    return await pubspecFile.exists() ? pubspecFile : null;
  }

  bool _isExcluded(String filePath) {
    final fileName = path.basename(filePath);
    return config.excludePatterns.any((pattern) {
      final glob = Glob(pattern);
      return glob.matches(fileName);
    });
  }
}
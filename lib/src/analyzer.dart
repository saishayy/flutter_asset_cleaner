import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import 'config.dart';
import 'file_scanner.dart';

class AssetUsage {
  final File assetFile;
  final bool isUsed;
  final List<String> usageLocations;

  AssetUsage({
    required this.assetFile,
    required this.isUsed,
    required this.usageLocations,
  });

  String get relativePath => path.relative(assetFile.path);
  String get assetPath => path.relative(assetFile.path, from: path.join(path.dirname(assetFile.path), '..'));
}

class AssetAnalyzer {
  final Config config;
  final FileScanner scanner;

  AssetAnalyzer(this.config) : scanner = FileScanner(config);

  Future<List<AssetUsage>> analyzeAssets() async {
    final assetFiles = await scanner.getAssetFiles();
    final dartFiles = await scanner.getDartFiles();
    final pubspecFile = await scanner.getPubspecFile();

    if (config.isVerbose) {
      print('Found ${assetFiles.length} asset files');
      print('Found ${dartFiles.length} Dart files');
    }

    final results = <AssetUsage>[];
    
    for (final assetFile in assetFiles) {
      final usage = await _analyzeAssetUsage(assetFile, dartFiles, pubspecFile);
      results.add(usage);
    }

    return results;
  }

  Future<AssetUsage> _analyzeAssetUsage(File assetFile, List<File> dartFiles, File? pubspecFile) async {
    final usageLocations = <String>[];
    
    // Generate possible asset reference patterns
    final assetPatterns = _generateAssetPatterns(assetFile);
    
    // Check Dart files for usage
    for (final dartFile in dartFiles) {
      final content = await dartFile.readAsString();
      for (final pattern in assetPatterns) {
        if (content.contains(pattern)) {
          usageLocations.add('${dartFile.path}');
          break;
        }
      }
    }

    // Check pubspec.yaml for explicit declarations
    if (pubspecFile != null) {
      final pubspecContent = await pubspecFile.readAsString();
      final yaml = loadYaml(pubspecContent);
      
      if (yaml['flutter']?['assets'] != null) {
        final assets = yaml['flutter']['assets'] as List;
        final assetPath = path.relative(assetFile.path, from: config.projectPath);
        
        for (final asset in assets) {
          if (asset.toString().contains(path.dirname(assetPath)) || 
              asset.toString() == assetPath) {
            usageLocations.add('pubspec.yaml');
            break;
          }
        }
      }
    }

    return AssetUsage(
      assetFile: assetFile,
      isUsed: usageLocations.isNotEmpty,
      usageLocations: usageLocations,
    );
  }

  List<String> _generateAssetPatterns(File assetFile) {
    final patterns = <String>[];
    final projectPath = config.projectPath;
    
    // Relative path from project root
    final relativePath = path.relative(assetFile.path, from: projectPath);
    patterns.add(relativePath);
    
    // Asset path (without leading directory)
    final assetPath = path.relative(assetFile.path, from: path.join(projectPath, 'assets'));
    patterns.add(assetPath);
    patterns.add('assets/$assetPath');
    
    // Just filename
    final fileName = path.basename(assetFile.path);
    patterns.add(fileName);
    
    // Without extension
    final nameWithoutExt = path.basenameWithoutExtension(assetFile.path);
    patterns.add(nameWithoutExt);
    
    return patterns;
  }
}
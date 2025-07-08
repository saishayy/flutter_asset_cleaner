import 'dart:io';
import 'package:colorize/colorize.dart';
import 'analyzer.dart';
import 'config.dart';
import 'reporter.dart';

class AssetCleaner {
  final Config config;
  final AssetAnalyzer analyzer;
  final Reporter reporter;

  AssetCleaner(this.config) 
    : analyzer = AssetAnalyzer(config),
      reporter = Reporter(config);

  Future<void> run() async {
    print('${Colorize('Flutter Asset Cleaner').bold()}');
    print('Analyzing project: ${config.projectPath}');
    
    // Verify this is a Flutter project
    if (!await _isFlutterProject()) {
      print('${Colorize('Error: Not a Flutter project').red()}');
      exit(1);
    }

    // Analyze assets
    final results = await analyzer.analyzeAssets();
    
    // Show report
    reporter.printAnalysisReport(results);
    
    // Get unused assets
    final unusedAssets = results.where((r) => !r.isUsed).toList();
    
    if (unusedAssets.isEmpty) {
      print('\n${Colorize('✓ No unused assets found!').green()}');
      return;
    }

    // Handle deletion
    if (config.isDryRun) {
      print('\n${Colorize('DRY RUN: No files were deleted').yellow()}');
      return;
    }

    List<AssetUsage> assetsToDelete;
    
    if (config.isInteractive) {
      assetsToDelete = reporter.selectAssetsInteractively(unusedAssets);
    } else {
      if (!reporter.confirmDeletion(unusedAssets)) {
        print('Operation cancelled.');
        return;
      }
      assetsToDelete = unusedAssets;
    }

    // Delete selected assets
    await _deleteAssets(assetsToDelete);
  }

  Future<bool> _isFlutterProject() async {
    final pubspecFile = File('${config.projectPath}/pubspec.yaml');
    if (!await pubspecFile.exists()) return false;
    
    final content = await pubspecFile.readAsString();
    return content.contains('flutter:');
  }

  Future<void> _deleteAssets(List<AssetUsage> assetsToDelete) async {
    if (assetsToDelete.isEmpty) {
      print('No assets selected for deletion.');
      return;
    }

    print('\n${Colorize('Deleting ${assetsToDelete.length} assets...').yellow()}');
    
    int deletedCount = 0;
    int failedCount = 0;
    
    for (final asset in assetsToDelete) {
      try {
        await asset.assetFile.delete();
        deletedCount++;
        if (config.isVerbose) {
          print('  ${Colorize('✓').green()} Deleted: ${asset.relativePath}');
        }
      } catch (e) {
        failedCount++;
        print('  ${Colorize('✗').red()} Failed to delete: ${asset.relativePath} ($e)');
      }
    }

    print('\n${Colorize('Deletion Summary:').bold()}');
    print('  ${Colorize('Successfully deleted:').green()} $deletedCount');
    if (failedCount > 0) {
      print('  ${Colorize('Failed to delete:').red()} $failedCount');
    }
    
    // Clean up empty directories
    await _cleanupEmptyDirectories();
  }

  Future<void> _cleanupEmptyDirectories() async {
    final assetsDir = Directory('${config.projectPath}/assets');
    if (!await assetsDir.exists()) return;

    await _removeEmptyDirsRecursively(assetsDir);
  }

  Future<void> _removeEmptyDirsRecursively(Directory dir) async {
    await for (final entity in dir.list()) {
      if (entity is Directory) {
        await _removeEmptyDirsRecursively(entity);
        
        // Check if directory is empty after processing subdirectories
        final isEmpty = await entity.list().isEmpty;
        if (isEmpty) {
          try {
            await entity.delete();
            if (config.isVerbose) {
              print('  ${Colorize('✓').green()} Removed empty directory: ${entity.path}');
            }
          } catch (e) {
            // Ignore errors when deleting directories
          }
        }
      }
    }
  }
}
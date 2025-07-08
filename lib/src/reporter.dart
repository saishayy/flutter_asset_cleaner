import 'dart:io';
import 'package:colorize/colorize.dart';
import 'analyzer.dart';
import 'config.dart';

class Reporter {
  final Config config;

  Reporter(this.config);

  void printAnalysisReport(List<AssetUsage> results) {
    final unusedAssets = results.where((r) => !r.isUsed).toList();
    final usedAssets = results.where((r) => r.isUsed).toList();

    print('\n${Colorize('Asset Analysis Report').bold()}');
    print('${'=' * 50}');
    
    print('${Colorize('Total assets found:').green()} ${results.length}');
    print('${Colorize('Used assets:').green()} ${usedAssets.length}');
    print('${Colorize('Unused assets:').red()} ${unusedAssets.length}');
    
    if (unusedAssets.isNotEmpty) {
      print('\n${Colorize('Unused Assets:').red().bold()}');
      for (final asset in unusedAssets) {
        print('  ${Colorize('✗').red()} ${asset.relativePath}');
      }
      
      final totalSize = _calculateTotalSize(unusedAssets);
      print('\n${Colorize('Total size of unused assets:').yellow()} ${_formatSize(totalSize)}');
    }

    if (config.isVerbose && usedAssets.isNotEmpty) {
      print('\n${Colorize('Used Assets:').green().bold()}');
      for (final asset in usedAssets) {
        print('  ${Colorize('✓').green()} ${asset.relativePath}');
        if (asset.usageLocations.isNotEmpty) {
          print('    Used in: ${asset.usageLocations.join(', ')}');
        }
      }
    }
  }

  int _calculateTotalSize(List<AssetUsage> assets) {
    int totalSize = 0;
    for (final asset in assets) {
      try {
        totalSize += asset.assetFile.lengthSync();
      } catch (e) {
        // File might not exist
      }
    }
    return totalSize;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  bool confirmDeletion(List<AssetUsage> unusedAssets) {
    if (unusedAssets.isEmpty) return false;
    
    print('\n${Colorize('Are you sure you want to delete these ${unusedAssets.length} unused assets?').yellow()}');
    stdout.write('Type "yes" to confirm: ');
    final input = stdin.readLineSync()?.toLowerCase();
    return input == 'yes';
  }

  List<AssetUsage> selectAssetsInteractively(List<AssetUsage> unusedAssets) {
    final selected = <AssetUsage>[];
    
    print('\n${Colorize('Select assets to delete (y/n/q to quit):').yellow()}');
    
    for (final asset in unusedAssets) {
      stdout.write('Delete ${asset.relativePath}? (y/n/q): ');
      final input = stdin.readLineSync()?.toLowerCase();
      
      if (input == 'q') break;
      if (input == 'y') selected.add(asset);
    }
    
    return selected;
  }
}
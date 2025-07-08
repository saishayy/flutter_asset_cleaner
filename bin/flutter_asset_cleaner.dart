#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:flutter_asset_cleaner/flutter_asset_cleaner.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Show usage information')
    ..addFlag('dry-run', abbr: 'd', help: 'Show what would be deleted without actually deleting')
    ..addFlag('interactive', abbr: 'i', help: 'Interactive mode for selective deletion')
    ..addFlag('verbose', abbr: 'v', help: 'Verbose output')
    ..addOption('path', abbr: 'p', help: 'Path to Flutter project', defaultsTo: '.')
    ..addOption('exclude', help: 'Comma-separated list of patterns to exclude')
    ..addMultiOption('extensions', help: 'Asset file extensions to check', defaultsTo: ['png', 'jpg', 'jpeg', 'gif', 'svg', 'webp', 'json', 'ttf', 'otf']);

  try {
    final results = parser.parse(arguments);
    
    if (results['help']) {
      _showHelp(parser);
      return;
    }

    final config = Config(
      projectPath: results['path'],
      isDryRun: results['dry-run'],
      isInteractive: results['interactive'],
      isVerbose: results['verbose'],
      excludePatterns: results['exclude']?.split(',') ?? [],
      extensions: results['extensions'],
    );

    final cleaner = AssetCleaner(config);
    await cleaner.run();
    
  } catch (e) {
    print('Error: $e');
    print('Use --help for usage information');
    exit(1);
  }
}

void _showHelp(ArgParser parser) {
  print('Flutter Asset Cleaner - Remove unused assets from Flutter projects');
  print('');
  print('Usage: flutter_asset_cleaner [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  flutter_asset_cleaner --dry-run');
  print('  flutter_asset_cleaner --path /path/to/project --interactive');
  print('  flutter_asset_cleaner --exclude "logo.*,icon.*"');
}
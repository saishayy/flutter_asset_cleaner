# Flutter Assets Cleaner

```
flutter_asset_cleaner/
├── bin/
│   └── flutter_asset_cleaner.dart          # Main CLI entry point
├── lib/
│   ├── src/
│   │   ├── analyzer.dart                   # Asset usage analyzer
│   │   ├── cleaner.dart                    # Asset removal logic
│   │   ├── config.dart                     # Configuration management
│   │   ├── file_scanner.dart               # File scanning utilities
│   │   └── reporter.dart                   # Report generation
│   └── flutter_asset_cleaner.dart          # Main library file
├── pubspec.yaml                            # Package configuration
└── README.md                               # Documentation
```

## Key Features

- Asset Detection: Scans your assets/ directory for all asset files
- Usage Analysis: Checks Dart files and pubspec.yaml for asset references
- Safety Features: Dry-run mode, interactive selection, and confirmation prompts
- Smart Patterns: Detects various ways assets can be referenced in code
- Clean Output: Colored terminal output with detailed reports
- Flexible Configuration: Exclude patterns, custom extensions, verbose mode

## How It Works

- File Scanner finds all assets and Dart files in your project
- Analyzer generates multiple patterns for each asset and searches for them in your code
- Reporter presents the results in a clear, actionable format
- Cleaner safely removes unused assets with user confirmation

## Usage Example

```bash
# Dry run (show what would be deleted)
flutter_asset_cleaner --dry-run

# Interactive mode
flutter_asset_cleaner --interactive

# Specify different project path
flutter_asset_cleaner --path /path/to/your/flutter/project

# Exclude certain patterns
flutter_asset_cleaner --exclude "logo.*,icon.*"

# Verbose output
flutter_asset_cleaner --verbose

# Combine options
flutter_asset_cleaner --dry-run --verbose --exclude "*.svg"
```

// Sync versions from versions.yaml into subpackage pubspec.yaml files.
// Also sync overrides from overrides.yaml into pubspec_overrides.yaml files.
// Dependency-free parser for simple `key: value` lines.
import 'dart:io';

const List<String> packages = <String>[
  '.', // root project
  'openim_common',
];

void main() {
  final String root = Directory.current.path;

  // Sync versions.yaml
  _syncVersions(root);

  // Sync overrides.yaml
  _syncOverrides(root);
}

void _syncVersions(String root) {
  final File versionsFile = File('$root/versions.yaml');
  if (!versionsFile.existsSync()) {
    stderr.writeln('versions.yaml not found at $root');
    exit(1);
  }

  final Map<String, String> versions = _parseSimpleYaml(versionsFile.readAsLinesSync());
  if (versions.isEmpty) {
    stderr.writeln('versions.yaml is empty or invalid.');
    exit(1);
  }

  for (final String pkg in packages) {
    final String dir = pkg == '.' ? root : '$root/$pkg';
    final File pubspec = File('$dir/pubspec.yaml');
    if (!pubspec.existsSync()) {
      stdout.writeln('Skip $pkg: pubspec.yaml not found');
      continue;
    }
    final List<String> lines = pubspec.readAsLinesSync();
    final bool changed = _syncFile(lines, versions);
    if (changed) {
      pubspec.writeAsStringSync(lines.join('\n'));
      stdout.writeln('Updated $pkg/pubspec.yaml');
    } else {
      stdout.writeln('No changes for $pkg/pubspec.yaml');
    }
  }
}

void _syncOverrides(String root) {
  final File overridesFile = File('$root/overrides.yaml');
  if (!overridesFile.existsSync()) {
    stdout.writeln('overrides.yaml not found, skipping dependency overrides sync.');
    return;
  }

  final Map<String, String> overrides = _parseSimpleYaml(overridesFile.readAsLinesSync());
  if (overrides.isEmpty) {
    stdout.writeln('overrides.yaml is empty, will clean up non-melos overrides.');
  }

  for (final String pkg in packages) {
    final String dir = pkg == '.' ? root : '$root/$pkg';
    final File overridesTarget = File('$dir/pubspec_overrides.yaml');

    // Read existing file or create new content
    List<String> existingLines = [];
    String melosHeader = '';
    Map<String, String> existingOverrides = {};

    if (overridesTarget.existsSync()) {
      existingLines = overridesTarget.readAsLinesSync();
      // Extract melos header and existing overrides
      for (final line in existingLines) {
        if (line.startsWith('# melos_managed_dependency_overrides:')) {
          melosHeader = line;
          break;
        }
      }
      // Parse existing overrides (skip melos-managed ones)
      existingOverrides = _parseExistingOverrides(existingLines, pkg, root);
    }

    // Merge overrides: existing melos-managed + new from overrides.yaml
    final StringBuffer newContent = StringBuffer();
    if (melosHeader.isNotEmpty) {
      newContent.writeln(melosHeader);
    }
    newContent.writeln('dependency_overrides:');

    // Add melos-managed path overrides first
    for (final entry in existingOverrides.entries) {
      if (entry.value.contains('path:')) {
        newContent.writeln('  ${entry.key}:');
        for (final line in entry.value.split('\n')) {
          if (line.trim().isNotEmpty) {
            newContent.writeln('    ${line.trim()}');
          }
        }
      }
    }

    // Add overrides from overrides.yaml
    for (final entry in overrides.entries) {
      if (entry.value.contains('\n')) {
        // Multi-line override (e.g., git dependency)
        newContent.writeln('  ${entry.key}:');
        for (final line in entry.value.split('\n')) {
          if (line.trim().isNotEmpty) {
            newContent.writeln('    ${line.trim()}');
          }
        }
      } else {
        // Single-line override
        newContent.writeln('  ${entry.key}: ${entry.value}');
      }
    }

    final String finalContent = newContent.toString().trimRight() + '\n';
    final String existingContent = existingLines.join('\n');

    if (finalContent.trim() != existingContent.trim()) {
      overridesTarget.writeAsStringSync(finalContent);
      stdout.writeln('Updated $pkg/pubspec_overrides.yaml with overrides');
    } else {
      stdout.writeln('No override changes for $pkg/pubspec_overrides.yaml');
    }
  }
}

Map<String, String> _parseExistingOverrides(List<String> lines, String pkg, String root) {
  final Map<String, String> result = {};
  bool inDependencyOverrides = false;
  String currentKey = '';
  StringBuffer currentValue = StringBuffer();

  for (final line in lines) {
    if (line.trim() == 'dependency_overrides:') {
      inDependencyOverrides = true;
      continue;
    }
    if (!inDependencyOverrides) continue;

    // Check if this is a new key (2-space indent, ends with :)
    if (line.startsWith('  ') && !line.startsWith('    ') && line.trim().endsWith(':')) {
      // Save previous key
      if (currentKey.isNotEmpty) {
        result[currentKey] = currentValue.toString().trimRight();
      }
      currentKey = line.trim().replaceAll(':', '');
      currentValue = StringBuffer();
    } else if (line.startsWith('    ') && currentKey.isNotEmpty) {
      // This is a value line for current key
      currentValue.writeln(line.substring(4)); // Remove 4-space indent
    }
  }
  // Save last key
  if (currentKey.isNotEmpty) {
    result[currentKey] = currentValue.toString().trimRight();
  }

  return result;
}

Map<String, String> _parseSimpleYaml(List<String> lines) {
  final Map<String, String> map = <String, String>{};
  for (int i = 0; i < lines.length; i++) {
    final String raw = lines[i];
    final String line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;

    final int idx = line.indexOf(':');
    if (idx <= 0) continue;

    final String key = line.substring(0, idx).trim();
    String value = line.substring(idx + 1).trim();

    // If value is empty, it might be a multi-line value (e.g. git dependency)
    if (value.isEmpty) {
      final StringBuffer buffer = StringBuffer();
      // Look ahead for indented lines
      int j = i + 1;
      while (j < lines.length) {
        final String nextRaw = lines[j];
        if (nextRaw.trim().isEmpty) {
          j++;
          continue;
        }
        // Check indentation: must be greater than current line's indentation
        // Simple check: starts with space
        if (!nextRaw.startsWith(' ')) {
          break;
        }
        buffer.writeln(nextRaw);
        j++;
      }
      if (buffer.isNotEmpty) {
        value = '\n${buffer.toString().trimRight()}';
        i = j - 1; // Advance outer loop
      }
    }

    if (key.isNotEmpty) {
      map[key] = value;
    }
  }
  return map;
}

bool _syncFile(List<String> lines, Map<String, String> versions) {
  bool changed = false;
  final Set<String> keys = versions.keys.toSet();

  for (int i = 0; i < lines.length; i++) {
    final String original = lines[i];
    // Capture leading indentation
    int j = 0;
    while (j < original.length && (original[j] == ' ' || original[j] == '\t')) {
      j++;
    }
    final String indent = original.substring(0, j);
    final String rest = original.substring(j);

    // Skip comments or empty lines
    if (rest.startsWith('#') || rest.trim().isEmpty) continue;

    final int colon = rest.indexOf(':');
    if (colon <= 0) continue;

    final String name = rest.substring(0, colon).trim();
    if (!keys.contains(name)) continue;

    final String newVersion = versions[name]!;
    String replacement;

    if (newVersion.contains('\n')) {
      // Multi-line replacement with indentation aligned to the current level.
      final List<String> parts = newVersion.split('\n');
      int baseIndent = -1;
      for (final String part in parts.skip(1)) {
        if (part.trim().isEmpty) continue;
        final int spaces = _leadingSpaces(part);
        if (baseIndent == -1 || spaces < baseIndent) {
          baseIndent = spaces;
        }
      }
      if (baseIndent < 0) baseIndent = 0;

      final StringBuffer adjusted = StringBuffer();
      for (int idx = 0; idx < parts.length; idx++) {
        final String line = parts[idx];
        if (idx == 0) {
          adjusted.write(line);
          continue;
        }
        if (line.trim().isEmpty) {
          adjusted.writeln();
          continue;
        }
        final int relativeIndent = _leadingSpaces(line) - baseIndent;
        final String childIndent = '$indent  ${' ' * (relativeIndent < 0 ? 0 : relativeIndent)}';
        adjusted.write('\n$childIndent${line.trimLeft()}');
      }
      replacement = '$indent$name:${adjusted.toString()}';
    } else {
      // Single-line replacement
      replacement = '$indent$name: $newVersion';
    }

    // Check if we need to update
    // We also need to check if the CURRENT entry in pubspec is multi-line and remove those lines

    // Check if current line matches replacement (only for single line check, multi-line is harder)
    if (original.trim() != replacement.trim() || newVersion.contains('\n')) {
      // If we are here, we might need to replace.
      // First, let's see if the current entry has multi-line children we need to remove.
      int k = i + 1;
      while (k < lines.length) {
        final String nextLine = lines[k];
        if (nextLine.trim().isEmpty) {
          k++;
          continue;
        }
        int nextIndent = 0;
        while (nextIndent < nextLine.length && (nextLine[nextIndent] == ' ' || nextLine[nextIndent] == '\t')) {
          nextIndent++;
        }
        final String trimmedNext = nextLine.trimLeft();
        final bool forceChild =
            newVersion.contains('\n') && RegExp(r'^(git|hosted|path|url|ref|branch):').hasMatch(trimmedNext);

        if (nextIndent > j || forceChild) {
          k++;
        } else {
          break;
        }
      }

      // Construct the new block
      // If we are replacing, we should check if the content is actually different to avoid "Updated" message if not needed.
      // But for simplicity and correctness with multi-line, let's reconstruct and compare.

      // Extract current full block
      final StringBuffer currentBlock = StringBuffer();
      currentBlock.write(original);
      for (int m = i + 1; m < k; m++) {
        currentBlock.writeln();
        currentBlock.write(lines[m]);
      }

      if (currentBlock.toString().trim() != replacement.trim()) {
        // Perform replacement
        lines[i] = replacement;
        // Remove subsequent lines that were part of the old block
        if (k > i + 1) {
          lines.removeRange(i + 1, k);
        }
        changed = true;
      }
    }
  }
  return changed;
}

int _leadingSpaces(String line) {
  int count = 0;
  while (count < line.length && line[count] == ' ') {
    count++;
  }
  return count;
}

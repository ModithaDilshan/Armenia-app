import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;

    // 1. Fix context.dc.primary -> AppColors.primary
    if (content.contains('context.dc.primary')) {
      content = content.replaceAll('context.dc.primary', 'AppColors.primary');
      changed = true;
    }
    if (content.contains('context.dc.secondary')) {
      content = content.replaceAll('context.dc.secondary', 'AppColors.secondary');
      changed = true;
    }
    if (content.contains('context.dc.tertiary')) {
      content = content.replaceAll('context.dc.tertiary', 'AppColors.tertiary');
      changed = true;
    }

    // 2. Fix const widget with context.dc
    final constRegex = RegExp(r'const\s+([A-Za-z0-9_]+)\([^)]*context\.dc\.[a-zA-Z0-9_]+', multiLine: true);
    while (constRegex.hasMatch(content)) {
      final match = constRegex.firstMatch(content)!;
      // remove 'const ' from the match
      final matchedString = match.group(0)!;
      final newString = matchedString.replaceFirst(RegExp(r'const\s+'), '');
      content = content.replaceFirst(matchedString, newString);
      changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Fixed \${file.path}');
    }
  }
}

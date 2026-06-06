import 'dart:io';

void main() {
  final filesToUpdate = [
    r'lib\screens\admin\admin_student_progress_screen.dart',
    r'lib\screens\admin\applications_list_screen.dart',
    r'lib\screens\admin\manage_media_screen.dart',
    r'lib\screens\admin\post_announcement_screen.dart',
    r'lib\screens\admin\send_notification_screen.dart',
    r'lib\screens\apply\apply_screen.dart',
    r'lib\screens\auth\register_screen.dart',
    r'lib\screens\universities\universities_screen.dart',
    r'lib\screens\universities\university_detail_screen.dart',
    r'lib\screens\media\media_screen.dart',
    r'lib\screens\admin\admin_dashboard_screen.dart',
  ];

  for (final path in filesToUpdate) {
    final file = File(path);
    if (!file.existsSync()) continue;

    String content = file.readAsStringSync();
    if (!content.contains('AppColors.background') &&
        !content.contains('AppColors.surface') &&
        !content.contains('AppColors.surfaceHighlight') &&
        !content.contains('AppColors.textMain') &&
        !content.contains('AppColors.textMuted')) {
      continue;
    }

    content = content.replaceAll('AppColors.background', 'context.dc.background');
    content = content.replaceAll('AppColors.surface', 'context.dc.surface');
    content = content.replaceAll('AppColors.surfaceHighlight', 'context.dc.surfaceHighlight');
    content = content.replaceAll('AppColors.textMain', 'context.dc.textMain');
    content = content.replaceAll('AppColors.textMuted', 'context.dc.textMuted');

    if (!content.contains('dynamic_colors.dart')) {
      int depth = path.split(r'\').length - 2;
      String prefix = '../' * depth;
      String importLine = "import '${prefix}core/theme/dynamic_colors.dart';";
      
      final lines = content.split('\n');
      int lastImport = -1;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].startsWith('import ')) {
          lastImport = i;
        }
      }
      if (lastImport != -1) {
        lines.insert(lastImport + 1, importLine);
        content = lines.join('\n');
      }
    }

    file.writeAsStringSync(content);
    print('Updated $path');
  }
}

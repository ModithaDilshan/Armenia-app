import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:armenia_lanka_edu/core/constants/app_constants.dart';
import 'package:armenia_lanka_edu/core/theme/theme_provider.dart';
import 'package:armenia_lanka_edu/models/university_model.dart';

void main() {
  test('university catalogue contains valid, unique entries', () {
    final universities = UniversityData.getUniversities();

    expect(universities, isNotEmpty);
    expect(universities.map((item) => item.id).toSet().length,
        universities.length);
    for (final university in universities) {
      expect(university.name, isNotEmpty);
      expect(university.faculties, isNotEmpty);
      expect(university.tuitionFeeUSD, greaterThan(0));
      expect(university.imageUrl, startsWith('assets/images/'));
    }
  });

  test('WhatsApp links are encoded safely', () {
    final uri =
        AppConstants.whatsappUri('94770000000', 'Hello there & welcome');

    expect(uri.host, 'wa.me');
    expect(uri.path, '/94770000000');
    expect(uri.queryParameters['text'], 'Hello there & welcome');
  });

  testWidgets('theme provider exposes the selected mode', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(isDark: false),
        child: MaterialApp(
          home: Builder(builder: (context) {
            final provider = context.watch<ThemeProvider>();
            return Text(provider.isDark ? 'dark' : 'light');
          }),
        ),
      ),
    );

    expect(find.text('light'), findsOneWidget);
    expect(find.text('dark'), findsNothing);
  });
}

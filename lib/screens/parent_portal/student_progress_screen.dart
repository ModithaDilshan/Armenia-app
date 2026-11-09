import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import '../../services/firestore_service.dart';

class StudentProgressScreen extends StatelessWidget {
  final String? studentId;
  final String studentName;
  final String university;
  final String program;

  const StudentProgressScreen({
    super.key,
    this.studentId,
    this.studentName = 'Student',
    this.university = 'Yerevan State Medical University',
    this.program = 'Medicine',
  });

  void _launchWhatsApp() async {
    final uri = Uri.parse(
        'https://wa.me/94702821035?text=Hello%2C%20I%20would%20like%20to%20request%20the%20full%20report%20card%20for%20my%20child.');
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Color _gradeColor(String grade) {
    if (grade.startsWith('A')) return const Color(0xFF00E676);
    if (grade.startsWith('B')) return AppColors.secondary;
    if (grade.startsWith('C')) return AppColors.tertiary;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final uid = studentId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text(
          '📊 $studentName\'s Progress',
          style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800, color: context.dc.textMain),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: context.dc.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirestoreService().getStudentProgressStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          // No data yet — show placeholder with message
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildNoDataView(context);
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final semester = data['semester'] ?? 'Year 1 · Semester 2';
          final gpa = data['gpa'] ?? '—';
          final overallAtt = (data['overallAttendance'] ?? 0) as int;
          final labAtt = (data['labAttendance'] ?? 0) as int;
          final subjects = (data['subjects'] as List<dynamic>? ?? [])
              .map((s) => s as Map<String, dynamic>)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: _buildSemesterCard(context, semester, gpa),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 100),
                  child: _buildAttendanceCard(context, overallAtt, labAtt),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: Text('📚 Subject Grades — $semester',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: context.dc.textMain)),
                ),
                const SizedBox(height: 14),
                if (subjects.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                        child: Text('No subjects added yet.',
                            style: GoogleFonts.plusJakartaSans(
                                color: context.dc.textMuted))),
                  )
                else
                  ...subjects.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    final grade = s['grade'] as String? ?? '—';
                    final score = s['score'] as String? ?? '—';
                    final status = s['status'] as String? ?? 'Pass';
                    final numScore = int.tryParse(score.split('/').first) ?? 0;
                    final maxScore = int.tryParse(score.split('/').last) ?? 100;
                    final value = maxScore > 0 ? numScore / maxScore : 0.0;
                    final color = _gradeColor(grade);
                    return FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: 250 + (i * 60)),
                      child: AppTheme.glassCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        borderRadius: 16,
                        borderColor: color.withOpacity(0.3),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Center(
                                  child: Text(grade,
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: color))),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s['name'] as String? ?? '',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: context.dc.textMain)),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                          value: value.toDouble(),
                                          backgroundColor: Colors.white10,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  color),
                                          minHeight: 5),
                                    ),
                                  ]),
                            ),
                            const SizedBox(width: 14),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(score,
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: context.dc.textMain)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: color.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Text(status,
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: color)),
                                  ),
                                ]),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 500),
                  child: _buildRequestCard(context),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoDataView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📊', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text('Progress Not Updated Yet',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: context.dc.textMain)),
            const SizedBox(height: 12),
            Text(
                'Your academic progress report will appear here once the admin uploads your results. Please check back later.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: context.dc.textMuted, height: 1.6)),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(
                    'https://wa.me/94702821035?text=Hello%2C%20I%20would%20like%20to%20request%20my%20progress%20report.');
                if (await canLaunchUrl(uri)) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF25D366), Color(0xFF128C7E)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('Contact Admin via WhatsApp',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterCard(BuildContext context, String semester, String gpa) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Current Semester',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(semester,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text('$university\n$program • Sep 2024 Intake',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: Colors.white70, height: 1.5)),
              ])),
          Column(children: [
            Text('GPA',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(gpa,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
            Text('/ 4.0',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: Colors.white70)),
          ]),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context, int overall, int lab) {
    final rows = [
      {
        'label': 'Overall Attendance',
        'value': overall / 100.0,
        'pct': '$overall%',
        'color': const Color(0xFF00E676)
      },
      {
        'label': 'Lab Sessions',
        'value': lab / 100.0,
        'pct': '$lab%',
        'color': AppColors.secondary
      },
    ];
    return AppTheme.glassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      borderColor: const Color(0xFF00E676).withOpacity(0.3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🗓️ Attendance',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.dc.textMain)),
        const SizedBox(height: 16),
        ...rows.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s['label'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: context.dc.textMuted,
                                  fontWeight: FontWeight.w500)),
                          Text(s['pct'] as String,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: s['color'] as Color)),
                        ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                          value: (s['value'] as double).clamp(0.0, 1.0),
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              s['color'] as Color),
                          minHeight: 8),
                    ),
                  ]),
            )),
      ]),
    );
  }

  Widget _buildRequestCard(BuildContext context) {
    return GestureDetector(
      onTap: _launchWhatsApp,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF25D366), Color(0xFF128C7E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF25D366).withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(children: [
          const Icon(Icons.chat_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Request Full Report Card',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text('Tap to contact counselor via WhatsApp',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: Colors.white70)),
              ])),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white, size: 16),
        ]),
      ),
    );
  }
}

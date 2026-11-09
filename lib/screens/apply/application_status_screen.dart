import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import '../../services/auth_service.dart';

class ApplicationStatusScreen extends StatelessWidget {
  const ApplicationStatusScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFF00E676);
      case 'Processing':
        return AppColors.secondary;
      case 'Rejected':
        return AppColors.primary;
      default:
        return const Color(0xFFFF9800);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight,
        title: Text('Application Status',
            style: GoogleFonts.plusJakartaSans(
              color: context.dc.textMain,
              fontWeight: FontWeight.w800,
            )),
      ),
      body: FutureBuilder<String?>(
        future: AuthService().getAccessibleStudentId(),
        builder: (context, idSnapshot) {
          if (idSnapshot.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final studentId = idSnapshot.data;
          if (studentId == null) {
            return _empty(context, 'No linked student account was found.');
          }
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('applications')
                .doc(studentId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _empty(
                    context, 'Application status could not be loaded.');
              }
              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary));
              }
              final data = snapshot.data!.data();
              if (data == null) {
                return _empty(
                    context, 'You have not submitted an application yet.');
              }
              final status = data['status'] as String? ?? 'Pending Review';
              final color = _statusColor(status);
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  AppTheme.glassCard(
                    padding: const EdgeInsets.all(24),
                    borderColor: color.withOpacity(0.45),
                    child: Column(children: [
                      Icon(Icons.assignment_turned_in_rounded,
                          size: 58, color: color),
                      const SizedBox(height: 14),
                      Text(status,
                          style: GoogleFonts.plusJakartaSans(
                            color: color,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          )),
                      const SizedBox(height: 8),
                      Text(
                        _statusMessage(status),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                            color: context.dc.textMuted, height: 1.5),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  _detail(context, 'Student', data['name'] as String? ?? '—'),
                  _detail(context, 'University',
                      data['university'] as String? ?? '—'),
                  _detail(
                      context, 'Program', data['program'] as String? ?? '—'),
                  _detail(context, 'Email', data['email'] as String? ?? '—'),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _statusMessage(String status) {
    switch (status) {
      case 'Approved':
        return 'Your application has been approved. A counselor will contact you with the next steps.';
      case 'Processing':
        return 'Your documents are being processed. We will update this page when the next step is ready.';
      case 'Rejected':
        return 'Please contact a counselor to discuss the application and available alternatives.';
      default:
        return 'Your application has been received and is waiting for review.';
    }
  }

  Widget _detail(BuildContext context, String label, String value) {
    return AppTheme.glassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        SizedBox(
            width: 92,
            child: Text(label,
                style:
                    GoogleFonts.plusJakartaSans(color: context.dc.textMuted))),
        Expanded(
            child: Text(value,
                style: GoogleFonts.plusJakartaSans(
                  color: context.dc.textMain,
                  fontWeight: FontWeight.w700,
                ))),
      ]),
    );
  }

  Widget _empty(BuildContext context, String message) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(message,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: context.dc.textMuted,
            fontSize: 16,
          )),
    ));
  }
}

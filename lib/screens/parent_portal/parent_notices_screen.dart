import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import '../../services/firestore_service.dart';

class ParentNoticesScreen extends StatelessWidget {
  const ParentNoticesScreen({super.key});

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Intake':
        return AppColors.primary;
      case 'Scholarship':
        return AppColors.secondary;
      case 'Info':
        return const Color(0xFF00E676);
      case 'Event':
        return AppColors.neonPurple;
      default:
        return AppColors.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text('📋 Notices & Announcements',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800, color: context.dc.textMain)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: context.dc.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getAnnouncementsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📭', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  Text('No notices yet',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16, color: context.dc.textMuted)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final tag = data['tag'] ?? 'Info';
              final color = _tagColor(tag);
              final ts = data['createdAt'];
              String dateStr = '';
              if (ts is Timestamp) {
                final d = ts.toDate();
                dateStr = '${d.day} ${_month(d.month)}, ${d.year}';
              }

              return FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: i * 70),
                child: AppTheme.glassCard(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  borderRadius: 20,
                  borderColor: color.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(tag,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: color)),
                          ),
                          const Spacer(),
                          if (dateStr.isNotEmpty)
                            Text(dateStr,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11, color: context.dc.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data['title'] ?? '',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.dc.textMain,
                            height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['body'] ?? '',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: context.dc.textMuted,
                            height: 1.6),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _month(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[m - 1];
  }
}

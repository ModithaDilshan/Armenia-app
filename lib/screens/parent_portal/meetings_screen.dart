import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import '../../services/firestore_service.dart';

class MeetingsScreen extends StatelessWidget {
  const MeetingsScreen({super.key});

  void _launchWhatsApp() async {
    final uri = Uri.parse('https://wa.me/94702821035?text=Hello%2C%20I%20would%20like%20to%20book%20a%20parent%20counseling%20meeting.');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _launchMeet(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text('📅 Parent Meetings', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: context.dc.textMain)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: context.dc.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirestoreService().getMeetingsFuture(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final docs = snapshot.data?.docs ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: _buildRequestBanner(context),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  child: Text('🗓️ Scheduled Meetings',
                      style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: context.dc.textMain)),
                ),
                const SizedBox(height: 14),
                if (docs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Column(children: [
                        const Text('📭', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('No meetings scheduled yet', style: GoogleFonts.plusJakartaSans(color: context.dc.textMuted, fontSize: 15)),
                      ]),
                    ),
                  )
                else
                  ...docs.asMap().entries.map((entry) {
                    final i = entry.key;
                    final m = entry.value.data() as Map<String, dynamic>;
                    return FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: 150 + i * 80),
                      child: _buildMeetingCard(context, m),
                    );
                  }),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestBanner(BuildContext context) {
    return GestureDetector(
      onTap: _launchWhatsApp,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF25D366), Color(0xFF128C7E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF25D366).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 30),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Request a Private Meeting', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Available Mon–Sat, 9AM–9PM (SL Time)', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
        ]),
      ),
    );
  }

  Widget _buildMeetingCard(BuildContext context, Map<String, dynamic> m) {
    final status = m['status'] as String? ?? 'Upcoming';
    final canJoin = m['canJoin'] as bool? ?? false;
    final meetUrl = m['meetUrl'] as String? ?? '';
    final statusColor = status == 'Completed' ? const Color(0xFF00E676) : AppColors.secondary;

    return AppTheme.glassCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      borderColor: statusColor.withOpacity(0.3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
          ),
          const Spacer(),
          Text(m['date'] as String? ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: context.dc.textMuted)),
        ]),
        const SizedBox(height: 12),
        Text(m['title'] as String? ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: context.dc.textMain, height: 1.3)),
        const SizedBox(height: 6),
        Row(children: [
          Icon(Icons.person_outline_rounded, color: context.dc.textMuted, size: 14),
          const SizedBox(width: 4),
          Text(m['host'] as String? ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: context.dc.textMuted)),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          Icon(Icons.schedule_rounded, color: context.dc.textMuted, size: 14),
          const SizedBox(width: 4),
          Text(m['time'] as String? ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: context.dc.textMuted)),
        ]),
        if (canJoin && meetUrl.isNotEmpty) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.videocam_rounded, size: 18),
              label: Text('Join Google Meet', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: () => _launchMeet(meetUrl),
            ),
          ),
        ],
      ]),
    );
  }
}

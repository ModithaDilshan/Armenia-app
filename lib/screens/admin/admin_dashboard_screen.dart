import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/dynamic_colors.dart';
import '../../../services/auth_service.dart';
import 'applications_list_screen.dart';
import 'post_announcement_screen.dart';
import 'send_notification_screen.dart';
import 'manage_media_screen.dart';
import 'admin_student_progress_screen.dart';
import 'admin_fees_screen.dart';
import 'admin_meetings_screen.dart';
import 'admin_news_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text(
          '⚙️ Admin Panel',
          style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800, color: context.dc.textMain),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
            onPressed: () async {
              await _authService.logout();
              if (context.mounted) Navigator.of(context).pop();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(),
            const SizedBox(height: 24),
            _buildLiveStats(),
            const SizedBox(height: 32),
            Text(
              '🛠️ Quick Actions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.dc.textMain,
              ),
            ),
            const SizedBox(height: 16),
            _buildAdminGrid(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.neonPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Admin 👋',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Representative Office — Armenia in Sri Lanka',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          const Text('🇦🇲', style: TextStyle(fontSize: 40)),
        ],
      ),
    );
  }

  Widget _buildLiveStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statCard('Applications', _db('applications'), AppColors.primary, Icons.assignment_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Announcements', _db('announcements'), AppColors.secondary, Icons.campaign_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Media Posts', _db('media_posts'), AppColors.tertiary, Icons.photo_library_rounded)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _statCard('Meetings', _db('meetings'), const Color(0xFF00E676), Icons.video_call_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('News Articles', _db('news_articles'), const Color(0xFFFF9800), Icons.newspaper_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Progress Records', _db('student_progress'), AppColors.neonPurple, Icons.school_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _statCard(
      String label, Future<QuerySnapshot> future, Color color, IconData icon) {
    return AppTheme.glassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: color.withOpacity(0.3),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          FutureBuilder<QuerySnapshot>(
            future: future,
            builder: (context, snap) {
              final count = snap.data?.docs.length ?? 0;
              return Text(
                '$count',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              );
            },
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11, color: context.dc.textMuted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<QuerySnapshot> _db(String collection) {
    return FirebaseFirestore.instance.collection(collection).get();
  }

  Widget _buildAdminGrid(BuildContext context) {
    final actions = [
      {'icon': Icons.assignment_rounded, 'label': 'View Applications', 'desc': 'See all student submissions', 'color': AppColors.primary, 'screen': const ApplicationsListScreen()},
      {'icon': Icons.campaign_rounded, 'label': 'Post Announcement', 'desc': 'Publish a new notice', 'color': AppColors.secondary, 'screen': const PostAnnouncementScreen()},
      {'icon': Icons.photo_library_rounded, 'label': 'Manage Media', 'desc': 'Add/delete photo posts', 'color': AppColors.tertiary, 'screen': const ManageMediaScreen()},
      {'icon': Icons.notifications_active_rounded, 'label': 'Send Notification', 'desc': 'Push alert to all users', 'color': const Color(0xFF00E676), 'screen': const SendNotificationScreen()},
      {'icon': Icons.school_rounded, 'label': 'Student Progress', 'desc': 'Update grades & GPA', 'color': AppColors.neonPurple, 'screen': const AdminStudentProgressScreen()},
      {'icon': Icons.credit_card_rounded, 'label': 'Fee Records', 'desc': 'Manage student fees', 'color': const Color(0xFFFF9800), 'screen': const AdminFeesScreen()},
      {'icon': Icons.video_call_rounded, 'label': 'Meetings', 'desc': 'Schedule parent meetings', 'color': AppColors.secondary, 'screen': const AdminMeetingsScreen()},
      {'icon': Icons.newspaper_rounded, 'label': 'News Articles', 'desc': 'Post parent news & updates', 'color': const Color(0xFF00BCD4), 'screen': const AdminNewsScreen()},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) {
        final item = actions[i];
        final color = item['color'] as Color;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item['screen'] as Widget),
          ),
          child: AppTheme.glassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 18,
            borderColor: color.withOpacity(0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'] as IconData,
                      color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  item['label'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.dc.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['desc'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: context.dc.textMuted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

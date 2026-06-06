import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import '../media/media_screen.dart';
import 'student_progress_screen.dart';
import 'parent_news_screen.dart';
import 'parent_notices_screen.dart';
import 'meetings_screen.dart';
import 'fee_status_screen.dart';

class ParentPortalScreen extends StatefulWidget {
  const ParentPortalScreen({super.key});

  @override
  State<ParentPortalScreen> createState() => _ParentPortalScreenState();
}

class _ParentPortalScreenState extends State<ParentPortalScreen> {
  Map<String, dynamic>? _studentData;
  Map<String, dynamic>? _appData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final appDoc  = await FirebaseFirestore.instance.collection('applications').doc(uid).get();
      setState(() {
        _studentData = userDoc.data();
        _appData     = appDoc.exists ? appDoc.data() : null;
        _loading     = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _launchWhatsApp1() async {
    final uri = Uri.parse('https://wa.me/94702821035?text=Hello%2C%20I%20would%20like%20to%20speak%20with%20a%20counselor%20about%20my%20child%27s%20studies%20in%20Armenia.');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _launchWhatsApp2() async {
    final uri = Uri.parse('https://wa.me/94741190119?text=Hello%2C%20I%20would%20like%20to%20speak%20with%20a%20counselor%20about%20my%20child%27s%20studies%20in%20Armenia.');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _launchFacebook() async {
    // Try to open Facebook app first, fall back to browser
    final fbAppUri = Uri.parse('fb://facewebmodal/f?href=https://www.facebook.com/share/17kEMmU4fu/');
    final fbWebUri = Uri.parse('https://www.facebook.com/share/17kEMmU4fu/');
    if (await canLaunchUrl(fbAppUri)) {
      launchUrl(fbAppUri, mode: LaunchMode.externalApplication);
    } else {
      launchUrl(fbWebUri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchMeet() async {
    final uri = Uri.parse('https://meet.google.com');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.dc.surfaceHighlight,
        title: Text('Logout', style: GoogleFonts.plusJakartaSans(color: context.dc.textMain, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.plusJakartaSans(color: context.dc.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: context.dc.textMuted))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Logout', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: context.dc.background,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final studentName  = _studentData?['name']  ?? _appData?['name']  ?? 'Student';
    final parentName   = _appData?['parentName'] ?? 'Parent';
    final university   = _appData?['university'] ?? 'Yerevan State Medical University';
    final program      = _appData?['program']    ?? 'Medicine';

    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text(
          '👨‍👩‍👧 Parent Portal',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: context.dc.textMain),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(duration: const Duration(milliseconds: 600), child: _buildWelcomeBanner(context, parentName, studentName, university, program)),
            const SizedBox(height: 28),
            FadeInUp(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 100), child: _buildSectionTitle(context, '📋 Quick Access')),
            const SizedBox(height: 16),
            FadeInUp(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 200), child: _buildPortalGrid(context, studentName, university, program)),
            const SizedBox(height: 32),
            FadeInUp(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 300), child: _buildSectionTitle(context, '📢 Latest Notices')),
            const SizedBox(height: 16),
            FadeInUp(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 400), child: _buildNotices(context)),
            const SizedBox(height: 32),
            FadeInUp(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 500), child: _buildSectionTitle(context, '📞 Contact & Meetings')),
            const SizedBox(height: 16),
            FadeInUp(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 600), child: _buildContactSection(context)),
            const SizedBox(height: 32),
            FadeInUp(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 700), child: _buildSectionTitle(context, '📅 Upcoming Events')),
            const SizedBox(height: 16),
            FadeInUp(duration: const Duration(milliseconds: 600), delay: const Duration(milliseconds: 800), child: _buildEvents(context)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, String parent, String student, String uni, String prog) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/parent_portal_header.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.3)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $parent 🙏',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$student • $uni',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Stay connected with your child\'s academic journey in Armenia. We keep you informed every step of the way.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.85),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: context.dc.textMain,
      ),
    );
  }

  Widget _buildPortalGrid(BuildContext context, String studentName, String university, String program) {
    final items = [
      {
        'icon': '📊',
        'title': 'Track Progress',
        'desc': 'Academic perf.',
        'color': AppColors.secondary,
      },
      {
        'icon': '📰',
        'title': 'News',
        'desc': 'Latest updates',
        'color': AppColors.primary,
      },
      {
        'icon': '📸',
        'title': 'Media',
        'desc': 'Campus life',
        'color': AppColors.neonPurple,
      },
      {
        'icon': '📋',
        'title': 'Notices',
        'desc': 'Announcements',
        'color': AppColors.tertiary,
      },
      {
        'icon': '📅',
        'title': 'Meetings',
        'desc': 'Google Meet',
        'color': const Color(0xFF00E676),
      },
      {
        'icon': '💳',
        'title': 'Fee Status',
        'desc': 'Payment info',
        'color': const Color(0xFFFF9800),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final color = item['color'] as Color;
        return GestureDetector(
          onTap: () {
            switch (i) {
              case 0:
                Navigator.push(context, MaterialPageRoute(builder: (_) => StudentProgressScreen(
                  studentName: studentName,
                  university: university,
                  program: program,
                )));
                break;
              case 1:
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentNewsScreen()));
                break;
              case 2:
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MediaScreen()));
                break;
              case 3:
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentNoticesScreen()));
                break;
              case 4:
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MeetingsScreen()));
                break;
              case 5:
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeStatusScreen()));
                break;
            }
          },
          child: AppTheme.glassCard(
            padding: const EdgeInsets.all(12),
            borderRadius: 16,
            borderColor: color.withOpacity(0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(item['icon'] as String,
                      style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 8),
                Text(
                  item['title'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: context.dc.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['desc'] as String,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    color: context.dc.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotices(BuildContext context) {
    final notices = [
      {
        'title': '✅ Visa Approved - September Batch',
        'desc':
            'All 23 students from the September 2025 batch have received their visas successfully.',
        'date': 'May 14, 2025',
        'color': const Color(0xFF00E676),
      },
      {
        'title': '📅 Parent Meeting - June 5, 2025',
        'desc':
            'Online parent information session via Google Meet at 7:00 PM (SL time). Meeting link will be sent via WhatsApp.',
        'date': 'May 12, 2025',
        'color': AppColors.secondary,
      },
      {
        'title': '💰 New Payment Plan Available',
        'desc':
            'Installment payment scheme now available for YSMU tuition fees. Contact us for details.',
        'date': 'May 8, 2025',
        'color': AppColors.tertiary,
      },
    ];

    return Column(
      children: notices.map((n) {
        final color = n['color'] as Color;
        return AppTheme.glassCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          borderColor: color.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                n['title'] as String,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.dc.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                n['desc'] as String,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: context.dc.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  n['date'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Column(
      children: [
        _contactCard(
          context: context,
          icon: FontAwesomeIcons.whatsapp,
          title: 'Chat with Counselor',
          subtitle: '070 282 1035 · Available 9AM–9PM',
          color: const Color(0xFF25D366),
          onTap: _launchWhatsApp1,
        ),
        const SizedBox(height: 12),
        _contactCard(
          context: context,
          icon: FontAwesomeIcons.whatsapp,
          title: 'Chat with Counselor 2',
          subtitle: '074 119 0119 · Available 9AM–9PM',
          color: const Color(0xFF25D366),
          onTap: _launchWhatsApp2,
        ),
        const SizedBox(height: 12),
        _contactCard(
          context: context,
          icon: FontAwesomeIcons.facebookF,
          title: 'Follow us on Facebook',
          subtitle: 'Armenia Lanka Education · Official Page',
          color: const Color(0xFF1877F2),
          onTap: _launchFacebook,
        ),
        const SizedBox(height: 12),
        _contactCard(
          context: context,
          icon: Icons.video_call_rounded,
          title: 'Join Google Meet',
          subtitle: 'Schedule a parent counseling session',
          color: const Color(0xFF4285F4),
          onTap: _launchMeet,
          isIcon: true,
        ),
      ],
    );
  }

  Widget _contactCard({
    required BuildContext context,
    required dynamic icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AppTheme.glassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        borderColor: color.withOpacity(0.3),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: isIcon
                    ? Icon(icon as IconData, color: color, size: 24)
                    : FaIcon(icon as IconData, color: color, size: 22),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.dc.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: context.dc.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEvents(BuildContext context) {
    final events = [
      {
        'date': 'JUN\n5',
        'title': 'Parent Information Meeting',
        'time': '7:00 PM (SL Time) · Online via Google Meet',
        'color': AppColors.secondary,
      },
      {
        'date': 'JUN\n20',
        'title': 'Scholarship Exam',
        'time': '10:00 AM · Colombo Examination Center',
        'color': AppColors.primary,
      },
      {
        'date': 'SEP\n1',
        'title': 'New Student Departure',
        'time': 'Bandaranaike International Airport · Colombo',
        'color': AppColors.tertiary,
      },
    ];

    return Column(
      children: events.map((e) {
        final color = e['color'] as Color;
        return AppTheme.glassCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          borderColor: color.withOpacity(0.2),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: color.withOpacity(0.4),
                  ),
                ),
                child: Center(
                  child: Text(
                    e['date'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e['title'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.dc.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e['time'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: context.dc.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

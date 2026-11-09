import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/dynamic_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../services/notification_service.dart';
import '../../services/preferences_service.dart';
import '../../services/auth_service.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _appData;
  bool _loading = true;
  bool _notificationsEnabled = true;
  bool _emailUpdates = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('users').doc(uid).get(),
        FirebaseFirestore.instance.collection('applications').doc(uid).get(),
        PreferencesService.getNotificationsEnabled(),
        PreferencesService.getEmailUpdatesEnabled(),
      ]);
      final ud = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final ad = results[1] as DocumentSnapshot<Map<String, dynamic>>;
      setState(() {
        _userData = ud.data();
        _appData = ad.exists ? ad.data() : null;
        _notificationsEnabled = results[2] as bool;
        _emailUpdates = results[3] as bool;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String get _name => _userData?['name'] ?? _appData?['name'] ?? 'Student';
  String get _email =>
      FirebaseAuth.instance.currentUser?.email ?? _userData?['email'] ?? '—';
  String get _university => _appData?['university'] ?? 'Not Enrolled';
  String get _program => _appData?['program'] ?? '—';
  String get _initial => _name.isNotEmpty ? _name[0].toUpperCase() : 'S';

  // ─── Actions ─────────────────────────────────────────────────────────────

  void _showPersonalDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.dc.surfaceHighlight,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 24),
          Text('Personal Details',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: context.dc.textMain)),
          const SizedBox(height: 24),
          _detailRow('👤', 'Full Name', _name),
          _detailRow('📧', 'Email Address', _email),
          _detailRow('🏫', 'University', _university),
          _detailRow('📚', 'Program', _program),
          _detailRow(
              '🆔',
              _userData?['role'] == 'student' ? 'Student ID' : 'User ID',
              FirebaseAuth.instance.currentUser?.uid ?? '—'),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Widget _detailRow(String emoji, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: context.dc.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: context.dc.textMuted)),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.dc.textMain)),
        ])),
      ]),
    );
  }

  void _showChangePassword() {
    final currentC = TextEditingController();
    final newC = TextEditingController();
    final confirmC = TextEditingController();
    bool loading = false;
    bool showCurrent = false, showNew = false, showConfirm = false;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.dc.surfaceHighlight,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
          builder: (ctx, setS) => Padding(
                padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
                child: Form(
                    key: formKey,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 20),
                      Text('🔒 Change Password',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: context.dc.textMain)),
                      const SizedBox(height: 8),
                      Text('Enter your current password and choose a new one.',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, color: context.dc.textMuted),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      _pwField(
                          'Current Password',
                          currentC,
                          showCurrent,
                          () => setS(() => showCurrent = !showCurrent),
                          (v) => v == null || v.isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),
                      _pwField(
                          'New Password',
                          newC,
                          showNew,
                          () => setS(() => showNew = !showNew),
                          (v) => v == null || v.length < 6
                              ? 'Min 6 characters'
                              : null),
                      const SizedBox(height: 12),
                      _pwField(
                          'Confirm New Password',
                          confirmC,
                          showConfirm,
                          () => setS(() => showConfirm = !showConfirm),
                          (v) =>
                              v != newC.text ? 'Passwords do not match' : null),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setS(() => loading = true);
                                  try {
                                    final user =
                                        FirebaseAuth.instance.currentUser!;
                                    final cred = EmailAuthProvider.credential(
                                        email: user.email!,
                                        password: currentC.text);
                                    await user
                                        .reauthenticateWithCredential(cred);
                                    await user.updatePassword(newC.text);
                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                    }
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(
                                            '✅ Password updated successfully!',
                                            style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w700)),
                                        backgroundColor:
                                            const Color(0xFF00E676),
                                        behavior: SnackBarBehavior.floating,
                                      ));
                                    }
                                  } on FirebaseAuthException catch (e) {
                                    setS(() => loading = false);
                                    String msg =
                                        'Update failed. Please try again.';
                                    if (e.code == 'wrong-password') {
                                      msg = 'Current password is incorrect.';
                                    }
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text('❌ $msg',
                                            style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w700)),
                                        backgroundColor: AppColors.primary,
                                        behavior: SnackBarBehavior.floating,
                                      ));
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text('Update Password',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                        ),
                      ),
                    ])),
              )),
    );
  }

  Widget _pwField(String label, TextEditingController c, bool show,
      VoidCallback toggle, String? Function(String?) validator) {
    return TextFormField(
      controller: c,
      obscureText: !show,
      style: GoogleFonts.plusJakartaSans(color: context.dc.textMain),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(
            color: context.dc.textMuted, fontSize: 13),
        filled: true,
        fillColor: context.dc.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary)),
        suffixIcon: IconButton(
            icon: Icon(
                show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: context.dc.textMuted,
                size: 20),
            onPressed: toggle),
        prefixIcon: Icon(Icons.lock_outline_rounded,
            color: context.dc.textMuted, size: 20),
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.dc.surfaceHighlight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🇦🇲', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text('Armenia Lanka Education',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.dc.textMain),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Version 1.0.0',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: context.dc.textMuted)),
          const SizedBox(height: 16),
          Text(
            'Connecting Sri Lankan students with world-class universities in Armenia. We provide comprehensive support from application to graduation.',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: context.dc.textMuted, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text('© 2025 Armenia Lanka Education',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: context.dc.textMuted.withOpacity(0.6))),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close',
                  style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary, fontWeight: FontWeight.w700)))
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.dc.surfaceHighlight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('👋 Logout',
            style: GoogleFonts.plusJakartaSans(
                color: context.dc.textMain, fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to logout from your account?',
            style: GoogleFonts.plusJakartaSans(
                color: context.dc.textMuted, height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: GoogleFonts.plusJakartaSans(
                      color: context.dc.textMuted))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text('Logout',
                style:
                    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService().logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _setNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await NotificationService.setEnabled(value);
  }

  Future<void> _setEmailUpdates(bool value) async {
    setState(() => _emailUpdates = value);
    await PreferencesService.setEmailUpdatesEnabled(value);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'preferences': {'emailUpdates': value},
      }, SetOptions(merge: true));
    }
  }

  Future<void> _rateApp() async {
    if (!await launchUrl(
      AppConstants.playStoreUri,
      mode: LaunchMode.externalApplication,
    )) {
      await launchUrl(
        AppConstants.playStoreWebUri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : CustomScrollView(slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInDown(
                            duration: const Duration(milliseconds: 500),
                            child: _buildProfileCard()),
                        const SizedBox(height: 28),
                        FadeInUp(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 100),
                            child:
                                _buildSection('👤 Account', _accountTiles())),
                        const SizedBox(height: 20),
                        FadeInUp(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 200),
                            child: _buildSection(
                                '🔔 Notifications', _notificationTiles())),
                        const SizedBox(height: 20),
                        FadeInUp(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 300),
                            child: _buildSection(
                                '📞 Connect with Us', _socialTiles())),
                        const SizedBox(height: 20),
                        FadeInUp(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 400),
                            child: _buildSection('ℹ️ About', _aboutTiles())),
                        const SizedBox(height: 20),
                        FadeInUp(
                            duration: const Duration(milliseconds: 500),
                            delay: const Duration(milliseconds: 500),
                            child: _buildLogoutButton()),
                      ]),
                ),
              ),
            ]),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: context.dc.surfaceHighlight.withOpacity(0.95),
      title: Text('⚙️ Settings',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.dc.textMain)),
      centerTitle: true,
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primary.withOpacity(0.4)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.4), width: 2)),
          child: Center(
              child: Text(_initial,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white))),
        ),
        const SizedBox(width: 18),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_name,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(_email,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: Colors.white.withOpacity(0.85))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)),
            child: Text(_university,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ])),
      ]),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Text(title,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.dc.textMain)),
      ),
      AppTheme.glassCard(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        child: Column(children: tiles),
      ),
    ]);
  }

  List<Widget> _accountTiles() => [
        _tile(
            icon: Icons.person_rounded,
            label: 'Personal Details',
            subtitle: 'View your profile information',
            color: AppColors.secondary,
            onTap: _showPersonalDetails),
        _divider(),
        _tile(
            icon: Icons.lock_rounded,
            label: 'Change Password',
            subtitle: 'Update your account password',
            color: AppColors.neonPurple,
            onTap: _showChangePassword),
        _divider(),
        _tile(
            icon: Icons.email_rounded,
            label: 'Email Address',
            subtitle: _email,
            color: AppColors.tertiary,
            onTap: null,
            trailing: Icon(Icons.copy_rounded,
                size: 16, color: context.dc.textMuted)),
      ];

  List<Widget> _notificationTiles() {
    final themeProvider = context.watch<ThemeProvider>();
    return [
      // Theme Toggle Tile
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (themeProvider.isDark
                      ? const Color(0xFF7C5CBF)
                      : const Color(0xFFFFB03A))
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                themeProvider.isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: themeProvider.isDark
                    ? const Color(0xFF7C5CBF)
                    : const Color(0xFFFFB03A),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  themeProvider.isDark ? 'Dark Mode' : 'Light Mode',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.dc.textMain),
                ),
                Text(
                  themeProvider.isDark
                      ? 'Switch to light theme'
                      : 'Switch to dark theme',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: context.dc.textMuted),
                ),
              ])),
          Switch(
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggleTheme(),
            activeColor: const Color(0xFF7C5CBF),
            activeTrackColor: const Color(0xFF7C5CBF).withOpacity(0.3),
            inactiveThumbColor: const Color(0xFFFFB03A),
            inactiveTrackColor: const Color(0xFFFFB03A).withOpacity(0.3),
          ),
        ]),
      ),
      _divider(),
      _switchTile(
          icon: Icons.notifications_rounded,
          label: 'Push Notifications',
          subtitle: 'Announcements & updates',
          color: const Color(0xFFFF9800),
          value: _notificationsEnabled,
          onChanged: _setNotifications),
      _divider(),
      _switchTile(
          icon: Icons.mark_email_read_rounded,
          label: 'Email Updates',
          subtitle: 'Receive news via email',
          color: AppColors.secondary,
          value: _emailUpdates,
          onChanged: _setEmailUpdates),
    ];
  }

  List<Widget> _socialTiles() => [
        _tile(
            icon: FontAwesomeIcons.whatsapp,
            label: 'Counselor 1',
            subtitle: '077 820 0056',
            color: const Color(0xFF25D366),
            isFa: true,
            onTap: () => _launchUrl(
                'https://wa.me/94778200056?text=Hello%2C%20I%20need%20help%20with%20my%20student%20account.')),
        _divider(),
        _tile(
            icon: FontAwesomeIcons.whatsapp,
            label: 'Counselor 2',
            subtitle: '077 820 0043',
            color: const Color(0xFF25D366),
            isFa: true,
            onTap: () => _launchUrl(
                'https://wa.me/94778200043?text=Hello%2C%20I%20need%20help%20with%20my%20student%20account.')),
        _divider(),
        _tile(
            icon: FontAwesomeIcons.whatsapp,
            label: 'Counselor 3',
            subtitle: '077 820 0053',
            color: const Color(0xFF25D366),
            isFa: true,
            onTap: () => _launchUrl(
                'https://wa.me/94778200053?text=Hello%2C%20I%20need%20help%20with%20my%20student%20account.')),
        _divider(),
        _tile(
            icon: FontAwesomeIcons.facebookF,
            label: 'Facebook Page',
            subtitle: 'Armenia Lanka Education',
            color: const Color(0xFF1877F2),
            isFa: true,
            onTap: () =>
                _launchUrl('https://www.facebook.com/share/17kEMmU4fu/')),
        _divider(),
        _tile(
            icon: Icons.video_call_rounded,
            label: 'Book a Meeting',
            subtitle: 'Request a meeting via WhatsApp',
            color: const Color(0xFF4285F4),
            onTap: () => _launchUrl(AppConstants.meetingBookingUri.toString())),
      ];

  List<Widget> _aboutTiles() => [
        _tile(
            icon: Icons.info_rounded,
            label: 'About This App',
            subtitle: 'Version 1.0.0',
            color: AppColors.primary,
            onTap: _showAbout),
        _divider(),
        _tile(
            icon: Icons.privacy_tip_rounded,
            label: 'Privacy Policy',
            subtitle: 'How we handle your data',
            color: context.dc.textMuted,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen()))),
        _divider(),
        _tile(
            icon: Icons.star_rounded,
            label: 'Rate This App',
            subtitle: 'Your feedback helps us improve',
            color: const Color(0xFFFFD700),
            onTap: _rateApp),
      ];

  Widget _tile({
    required dynamic icon,
    required String label,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
    bool isFa = false,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12)),
            child: Center(
                child: isFa
                    ? FaIcon(icon as IconData, color: color, size: 18)
                    : Icon(icon as IconData, color: color, size: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.dc.textMain)),
                Text(subtitle,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: context.dc.textMuted)),
              ])),
          trailing ??
              (onTap != null
                  ? Icon(Icons.arrow_forward_ios_rounded,
                      color: context.dc.textMuted, size: 14)
                  : const SizedBox()),
        ]),
      ),
    );
  }

  Widget _switchTile(
      {required IconData icon,
      required String label,
      required String subtitle,
      required Color color,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12)),
          child: Center(child: Icon(icon, color: color, size: 22)),
        ),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.dc.textMain)),
          Text(subtitle,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: context.dc.textMuted)),
        ])),
        Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.3)),
      ]),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, color: Colors.white10, indent: 70);

  Widget _buildLogoutButton() {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 600),
      child: GestureDetector(
        onTap: _logout,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.logout_rounded,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Text('Logout',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
          ]),
        ),
      ),
    );
  }
}

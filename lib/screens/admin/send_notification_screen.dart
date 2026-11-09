import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    try {
      // Save notification to Firestore — the app reads this on next open
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'sentAt': FieldValue.serverTimestamp(),
        'sentBy': 'admin',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ Notification sent to all users!',
              style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFF00E676),
          behavior: SnackBarBehavior.floating,
        ));
        _titleController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to send. Check connection.',
              style: GoogleFonts.plusJakartaSans()),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
    if (mounted) setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text('🔔 Send Notification',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800, color: context.dc.textMain)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFF00E676), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Notifications are saved to Firestore and shown to all users when they open the app.',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: const Color(0xFF00E676),
                          fontWeight: FontWeight.w600,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppTheme.glassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              borderColor: const Color(0xFF00E676).withOpacity(0.2),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Compose Notification',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.dc.textMain)),
                    const SizedBox(height: 16),
                    _field(
                        _titleController,
                        'Notification Title',
                        Icons.notifications_rounded,
                        (v) => (v == null || v.isEmpty) ? 'Enter title' : null),
                    const SizedBox(height: 12),
                    _field(
                        _messageController,
                        'Message to users',
                        Icons.message_rounded,
                        (v) =>
                            (v == null || v.isEmpty) ? 'Enter message' : null,
                        maxLines: 4),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E676),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isSending ? null : _sendNotification,
                        icon: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.black87, strokeWidth: 2))
                            : const Icon(Icons.send_rounded,
                                color: Colors.black87),
                        label: Text(
                            _isSending ? 'Sending...' : 'Send to All Users',
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                color: Colors.black87)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Past notifications
            Align(
              alignment: Alignment.centerLeft,
              child: Text('📬 Past Notifications',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: context.dc.textMain)),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .orderBy('sentAt', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF00E676)));
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Text('No notifications sent yet.',
                        style: GoogleFonts.plusJakartaSans(
                            color: context.dc.textMuted)),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return AppTheme.glassCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      borderRadius: 16,
                      borderColor: const Color(0xFF00E676).withOpacity(0.2),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_rounded,
                              color: Color(0xFF00E676), size: 24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['title'] ?? '',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: context.dc.textMain)),
                                const SizedBox(height: 4),
                                Text(data['message'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: context.dc.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      String? Function(String?) validator,
      {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style:
          GoogleFonts.plusJakartaSans(color: context.dc.textMain, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(
            color: context.dc.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF00E676), size: 20),
        filled: true,
        fillColor: context.dc.surfaceHighlight,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
}

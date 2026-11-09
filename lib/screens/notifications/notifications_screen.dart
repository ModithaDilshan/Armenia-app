import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  CollectionReference<Map<String, dynamic>> get _notifications =>
      FirebaseFirestore.instance.collection('notifications');

  CollectionReference<Map<String, dynamic>>? get _reads {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notification_reads');
  }

  Future<void> _markRead(String id) async {
    await _reads?.doc(id).set({'readAt': FieldValue.serverTimestamp()});
  }

  String _date(dynamic value) {
    if (value is! Timestamp) return 'Just now';
    return DateFormat('MMM d, y • h:mm a').format(value.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight,
        title: Text('Notifications',
            style: GoogleFonts.plusJakartaSans(
              color: context.dc.textMain,
              fontWeight: FontWeight.w800,
            )),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _notifications
            .orderBy('sentAt', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, notificationSnapshot) {
          if (notificationSnapshot.hasError) {
            return const _Message(
                icon: Icons.cloud_off_rounded,
                text: 'Notifications could not be loaded.');
          }
          if (!notificationSnapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final docs = notificationSnapshot.data!.docs;
          if (docs.isEmpty) {
            return const _Message(
                icon: Icons.notifications_none_rounded,
                text: 'No notifications yet.');
          }
          final reads = _reads;
          if (reads == null) return const SizedBox.shrink();
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: reads.snapshots(),
            builder: (context, readSnapshot) {
              final readIds =
                  readSnapshot.data?.docs.map((doc) => doc.id).toSet() ??
                      <String>{};
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();
                  final isRead = readIds.contains(doc.id);
                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _markRead(doc.id),
                    child: AppTheme.glassCard(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 18,
                      borderColor: isRead
                          ? context.dc.textMuted.withOpacity(0.12)
                          : AppColors.secondary.withOpacity(0.45),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isRead
                                  ? Icons.notifications_none_rounded
                                  : Icons.notifications_active_rounded,
                              color: isRead
                                  ? context.dc.textMuted
                                  : AppColors.secondary,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(data['title'] as String? ?? 'Update',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: isRead
                                            ? FontWeight.w600
                                            : FontWeight.w800,
                                        color: context.dc.textMain,
                                      )),
                                  const SizedBox(height: 5),
                                  Text(data['message'] as String? ?? '',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: context.dc.textMuted,
                                        height: 1.4,
                                      )),
                                  const SizedBox(height: 8),
                                  Text(_date(data['sentAt']),
                                      style: GoogleFonts.plusJakartaSans(
                                        color: context.dc.textMuted,
                                        fontSize: 11,
                                      )),
                                ])),
                          ]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Message({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 56, color: context.dc.textMuted),
      const SizedBox(height: 12),
      Text(text,
          style: GoogleFonts.plusJakartaSans(color: context.dc.textMuted)),
    ]));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';

class AdminParentLinksScreen extends StatelessWidget {
  const AdminParentLinksScreen({super.key});

  Future<void> _setApproved(
    BuildContext context,
    String parentId,
    bool approved,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(parentId).update({
      'linkApproved': approved,
      'linkReviewedAt': FieldValue.serverTimestamp(),
    });
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(approved ? 'Parent link approved.' : 'Parent link revoked.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight,
        title: Text('Parent Links',
            style: GoogleFonts.plusJakartaSans(
              color: context.dc.textMain,
              fontWeight: FontWeight.w800,
            )),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'parent')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Parent links could not be loaded.',
                    style: GoogleFonts.plusJakartaSans(
                        color: context.dc.textMuted)));
          }
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
                child: Text('No parent accounts yet.',
                    style: GoogleFonts.plusJakartaSans(
                        color: context.dc.textMuted)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final approved = data['linkApproved'] == true;
              return AppTheme.glassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] as String? ?? 'Parent',
                          style: GoogleFonts.plusJakartaSans(
                            color: context.dc.textMain,
                            fontWeight: FontWeight.w800,
                          )),
                      const SizedBox(height: 6),
                      Text(data['email'] as String? ?? '',
                          style: GoogleFonts.plusJakartaSans(
                              color: context.dc.textMuted)),
                      const SizedBox(height: 6),
                      SelectableText(
                          'Student ID: ${data['linkedStudentId'] ?? 'Not provided'}',
                          style: GoogleFonts.plusJakartaSans(
                              color: context.dc.textMuted)),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: () =>
                              _setApproved(context, doc.id, !approved),
                          icon: Icon(approved
                              ? Icons.link_off_rounded
                              : Icons.verified_rounded),
                          label: Text(approved ? 'Revoke' : 'Approve'),
                        ),
                      ),
                    ]),
              );
            },
          );
        },
      ),
    );
  }
}

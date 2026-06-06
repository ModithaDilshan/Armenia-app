import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/firestore_service.dart';
import '../../core/theme/dynamic_colors.dart';

class ApplicationsListScreen extends StatefulWidget {
  const ApplicationsListScreen({super.key});

  @override
  State<ApplicationsListScreen> createState() => _ApplicationsListScreenState();
}

class _ApplicationsListScreenState extends State<ApplicationsListScreen> {
  final _firestoreService = FirestoreService();
  String _filterStatus = 'All';

  final List<String> _statuses = [
    'All', 'Pending Review', 'Under Review', 'Approved', 'Rejected'
  ];

  final Map<String, Color> _statusColors = {
    'Pending Review': AppColors.tertiary,
    'Under Review': AppColors.secondary,
    'Approved': const Color(0xFF00E676),
    'Rejected': AppColors.primary,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text(
          '📋 Applications',
          style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800, color: context.dc.textMain),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Status filter
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _statuses.length,
              itemBuilder: (context, i) {
                final s = _statuses[i];
                final isSelected = _filterStatus == s;
                final color = s == 'All' ? AppColors.primary : (_statusColors[s] ?? AppColors.primary);
                return GestureDetector(
                  onTap: () => setState(() => _filterStatus = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? color : context.dc.surfaceHighlight,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Text(s,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: isSelected ? Colors.white : context.dc.textMuted,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        )),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getAllApplicationsStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return _emptyState();
                }

                var docs = snap.data!.docs;
                if (_filterStatus != 'All') {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return data['status'] == _filterStatus;
                  }).toList();
                }

                if (docs.isEmpty) return _emptyState();

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return _applicationCard(docs[i].id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _applicationCard(String docId, Map<String, dynamic> data) {
    final status = data['status'] ?? 'Pending Review';
    final statusColor = _statusColors[status] ?? AppColors.tertiary;

    return AppTheme.glassCard(
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: 18,
      borderColor: statusColor.withOpacity(0.3),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (data['name'] as String? ?? 'S').substring(0, 1).toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? 'Unknown',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.dc.textMain),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data['email'] ?? '',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: context.dc.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A3E)),
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _detailRow('🎓 University', data['university'] ?? 'N/A'),
                _detailRow('📚 Program', data['program'] ?? 'N/A'),
                _detailRow('📞 Phone', data['phone'] ?? 'N/A'),
                _detailRow('👨‍👩‍👧 Parent', data['parentName'] ?? 'N/A'),
                const SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _actionBtn(
                        label: 'WhatsApp',
                        icon: Icons.chat_rounded,
                        color: const Color(0xFF25D366),
                        onTap: () => _launchWhatsApp(data['phone'] ?? ''),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionBtn(
                        label: 'Approve',
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF00E676),
                        onTap: () => _updateStatus(docId, 'Approved'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionBtn(
                        label: 'Reject',
                        icon: Icons.cancel_rounded,
                        color: AppColors.primary,
                        onTap: () => _updateStatus(docId, 'Rejected'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: context.dc.textMuted)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: context.dc.textMain,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 60, color: context.dc.textMuted),
          const SizedBox(height: 16),
          Text('No applications yet',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: context.dc.textMain,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Applications from students will appear here',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: context.dc.textMuted)),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String docId, String status) async {
    await FirestoreService().updateApplicationStatus(docId, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Application marked as $status',
            style: GoogleFonts.plusJakartaSans()),
        backgroundColor: const Color(0xFF00E676),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _launchWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$cleaned');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

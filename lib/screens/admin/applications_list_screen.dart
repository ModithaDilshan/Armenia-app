import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import '../../services/firestore_service.dart';

class ApplicationsListScreen extends StatefulWidget {
  const ApplicationsListScreen({super.key});

  @override
  State<ApplicationsListScreen> createState() => _ApplicationsListScreenState();
}

class _ApplicationsListScreenState extends State<ApplicationsListScreen> {
  final _firestoreService = FirestoreService();
  String _filterStatus = 'All';

  final List<String> _statuses = [
    'All',
    'Pending Review',
    'Under Review',
    'Approved',
    'Rejected'
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
                final color = s == 'All'
                    ? AppColors.primary
                    : (_statusColors[s] ?? AppColors.primary);
                return GestureDetector(
                  onTap: () => setState(() => _filterStatus = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? color : context.dc.surfaceHighlight,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Text(s,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color:
                              isSelected ? Colors.white : context.dc.textMuted,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
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
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary));
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
                      (() {
                        final n = (data['name'] as String? ?? '').trim();
                        return n.isNotEmpty ? n[0].toUpperCase() : 'S';
                      })(),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          // Summary details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              children: [
                _detailRow('🎓 University', data['university'] ?? 'N/A'),
                _detailRow('📚 Program', data['program'] ?? 'N/A'),
                _detailRow('📞 Phone', data['phone'] ?? 'N/A'),
                _detailRow('👨‍👩‍👧 Parent', data['parentName'] ?? 'N/A'),
              ],
            ),
          ),
          // View Full Details button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: GestureDetector(
              onTap: () => _showFullDetails(docId, data),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.neonPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.neonPurple.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.visibility_rounded,
                        color: AppColors.neonPurple, size: 16),
                    const SizedBox(width: 8),
                    Text('View Full Application Details',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.neonPurple,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A3E)),
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
          ),
        ],
      ),
    );
  }

  void _showFullDetails(String docId, Map<String, dynamic> data) {
    final status = data['status'] ?? 'Pending Review';
    final statusColor = _statusColors[status] ?? AppColors.tertiary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: context.dc.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppColors.neonPurple.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: context.dc.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_rounded,
                        color: AppColors.neonPurple, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('Full Application Details',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: context.dc.textMain)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: statusColor.withOpacity(0.4)),
                      ),
                      child: Text(status,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF2A2A3E)),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── PERSONAL INFORMATION ──
                    _sectionHeader('👤 Personal Information'),
                    const SizedBox(height: 12),
                    _fullDetailRow(Icons.person_rounded, 'Full Name',
                        data['name'] ?? 'N/A'),
                    _fullDetailRow(Icons.email_rounded, 'Email Address',
                        data['email'] ?? 'N/A'),
                    _fullDetailRow(Icons.phone_rounded, 'Mobile Number',
                        data['phone'] ?? 'N/A'),
                    _fullDetailRow(Icons.cake_rounded, 'Date of Birth',
                        data['dob'] ?? 'N/A'),
                    _fullDetailRow(Icons.home_rounded, 'Home Address',
                        data['address'] ?? 'N/A'),
                    _fullDetailRow(
                        Icons.wc_rounded, 'Gender', data['gender'] ?? 'N/A'),
                    const SizedBox(height: 20),

                    // ── ACADEMIC PREFERENCES ──
                    _sectionHeader('🎓 Academic Preferences'),
                    const SizedBox(height: 12),
                    _fullDetailRow(Icons.school_rounded, 'University',
                        data['university'] ?? 'N/A'),
                    _fullDetailRow(Icons.menu_book_rounded, 'Program',
                        data['program'] ?? 'N/A'),
                    const SizedBox(height: 20),

                    // ── PARENT / GUARDIAN ──
                    _sectionHeader('👨‍👩‍👧 Parent / Guardian'),
                    const SizedBox(height: 12),
                    _fullDetailRow(Icons.people_rounded, 'Parent Name',
                        data['parentName'] ?? 'N/A'),
                    _fullDetailRow(Icons.phone_in_talk_rounded, 'Parent Phone',
                        data['parentPhone'] ?? 'N/A'),
                    const SizedBox(height: 20),

                    // ── DOCUMENTS ──
                    _sectionHeader('📎 Documents'),
                    const SizedBox(height: 12),
                    _documentNote(data),
                    const SizedBox(height: 20),

                    // ── SUBMISSION INFO ──
                    _sectionHeader('📅 Submission Info'),
                    const SizedBox(height: 12),
                    _fullDetailRow(
                      Icons.calendar_today_rounded,
                      'Submitted At',
                      data['submittedAt'] != null
                          ? (data['submittedAt'] as Timestamp)
                              .toDate()
                              .toString()
                              .substring(0, 16)
                          : 'N/A',
                    ),
                    _fullDetailRow(
                        Icons.fingerprint_rounded, 'Application ID', docId),
                    const SizedBox(height: 24),

                    // ── STATUS ACTIONS ──
                    _sectionHeader('⚙️ Update Status'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _actionBtn(
                            label: 'Under Review',
                            icon: Icons.hourglass_top_rounded,
                            color: AppColors.secondary,
                            onTap: () {
                              Navigator.pop(ctx);
                              _updateStatus(docId, 'Under Review');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _actionBtn(
                            label: 'Approve',
                            icon: Icons.check_circle_rounded,
                            color: const Color(0xFF00E676),
                            onTap: () {
                              Navigator.pop(ctx);
                              _updateStatus(docId, 'Approved');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _actionBtn(
                            label: 'Reject',
                            icon: Icons.cancel_rounded,
                            color: AppColors.primary,
                            onTap: () {
                              Navigator.pop(ctx);
                              _updateStatus(docId, 'Rejected');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // WhatsApp button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _launchWhatsApp(data['phone'] ?? '');
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFF25D366).withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_rounded,
                                color: Color(0xFF25D366), size: 18),
                            const SizedBox(width: 8),
                            Text('Contact on WhatsApp',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: const Color(0xFF25D366),
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Text(title,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primary)),
    );
  }

  Widget _fullDetailRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.dc.surfaceHighlight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dc.textMuted.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: context.dc.textMuted,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(value,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: context.dc.textMain,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentNote(Map<String, dynamic> data) {
    Map<String, dynamic>? docs;
    try {
      docs = data['documents'] != null
          ? Map<String, dynamic>.from(data['documents'] as Map)
          : null;
    } catch (_) {
      docs = null;
    }

    bool docHasUrl(String key) {
      try {
        final d = docs?[key];
        if (d == null) return false;
        final m = Map<String, dynamic>.from(d as Map);
        return m['url'] != null && (m['url'] as String).isNotEmpty;
      } catch (_) {
        return false;
      }
    }

    final hasUploaded = docs != null &&
        (docHasUrl('passport') ||
            docHasUrl('alResult') ||
            docHasUrl('olResult') ||
            docHasUrl('photo'));

    if (!hasUploaded) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.tertiary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.tertiary.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.tertiary, size: 18),
                const SizedBox(width: 8),
                Text('Documents Not Uploaded Yet',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.tertiary)),
              ],
            ),
            const SizedBox(height: 8),
            Text('The student has not uploaded documents through the app yet.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: context.dc.textMuted)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _launchWhatsApp(data['phone'] ?? ''),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF25D366).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_rounded,
                        color: Color(0xFF25D366), size: 15),
                    const SizedBox(width: 6),
                    Text('Request Documents via WhatsApp',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF25D366),
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF00E676).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF00E676), size: 16),
              const SizedBox(width: 8),
              Text('Documents uploaded by student',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00E676))),
            ],
          ),
        ),
        _documentTile('📄 Passport Copy', docs['passport']),
        _documentTile('📊 A/L Results', docs['alResult']),
        _documentTile('📋 O/L Results', docs['olResult']),
        _documentTile('🖼️ Passport Photo', docs['photo']),
      ],
    );
  }

  Widget _documentTile(String label, dynamic docData) {
    String? url;
    String? fileName;
    try {
      if (docData != null) {
        final Map<String, dynamic> doc =
            Map<String, dynamic>.from(docData as Map);
        url = doc['url'] as String?;
        if (url != null && url.isEmpty) url = null;
        fileName = doc['fileName'] as String?;
      }
    } catch (_) {
      url = null;
      fileName = null;
    }
    final bool uploaded = url != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.dc.surfaceHighlight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: uploaded
              ? const Color(0xFF00E676).withOpacity(0.3)
              : context.dc.textMuted.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: uploaded
                  ? const Color(0xFF00E676).withOpacity(0.12)
                  : context.dc.textMuted.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              uploaded
                  ? Icons.file_present_rounded
                  : Icons.file_upload_outlined,
              size: 18,
              color: uploaded ? const Color(0xFF00E676) : context.dc.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: context.dc.textMain)),
                Text(
                  fileName ?? (uploaded ? 'File uploaded' : 'Not uploaded'),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: context.dc.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (uploaded)
            GestureDetector(
              onTap: () => _openDocument(url!),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.secondary.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.open_in_new_rounded,
                        color: AppColors.secondary, size: 14),
                    const SizedBox(width: 4),
                    Text('View',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openDocument(String url) async {
    // Handle Firestore base64 stored documents (when Firebase Storage not available)
    if (url.startsWith('firestore://')) {
      final path = url.replaceFirst('firestore://', '');
      final parts = path.split('/');
      if (parts.length < 2) return;
      final collection = parts[0];
      final docId = parts[1];

      try {
        final doc = await FirebaseFirestore.instance
            .collection(collection)
            .doc(docId)
            .get();
        final data = doc.data();
        if (data == null || !mounted) return;

        final base64Data = data['base64Data'] as String?;
        final contentType = data['contentType'] as String? ?? 'image/jpeg';
        final fileName = data['fileName'] as String? ?? 'document';

        if (base64Data == null) return;

        final bytes = base64Decode(base64Data);
        final isImage = contentType.startsWith('image/');

        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: const Color(0xFF0D0D1A),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description_rounded,
                          color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(fileName,
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                if (isImage)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(bytes, fit: BoxFit.contain),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(Icons.picture_as_pdf,
                            color: Colors.red, size: 60),
                        const SizedBox(height: 12),
                        Text('PDF document: $fileName',
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text('${(bytes.length / 1024).toStringAsFixed(1)} KB',
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      } catch (e) {
        debugPrint('Error loading document from Firestore: $e');
      }
      return;
    }

    // Handle regular https:// or file:// URLs
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch document: $e');
    }
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
                    fontSize: 12, color: color, fontWeight: FontWeight.w700)),
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
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

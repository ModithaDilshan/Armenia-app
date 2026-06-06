import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/firestore_service.dart';
import '../../core/theme/dynamic_colors.dart';

class PostAnnouncementScreen extends StatefulWidget {
  const PostAnnouncementScreen({super.key});

  @override
  State<PostAnnouncementScreen> createState() => _PostAnnouncementScreenState();
}

class _PostAnnouncementScreenState extends State<PostAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _selectedTag = 'Info';
  bool _isPosting = false;
  final _firestoreService = FirestoreService();

  final List<String> _tags = ['Info', 'Intake', 'Scholarship', 'Event', 'Urgent', 'Update'];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isPosting = true);

    try {
      await _firestoreService.postAnnouncement(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        tag: _selectedTag,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ Announcement posted successfully!',
              style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFF00E676),
          behavior: SnackBarBehavior.floating,
        ));
        _titleController.clear();
        _bodyController.clear();
        setState(() => _selectedTag = 'Info');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to post. Check your connection.',
              style: GoogleFonts.plusJakartaSans()),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }

    if (mounted) setState(() => _isPosting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text('📢 Post Announcement',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800, color: context.dc.textMain)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form
            AppTheme.glassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              borderColor: AppColors.secondary.withOpacity(0.3),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Announcement',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.dc.textMain)),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _titleController,
                      label: 'Title (e.g. 📢 2025 Intake Open)',
                      icon: Icons.title_rounded,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _bodyController,
                      label: 'Full announcement text...',
                      icon: Icons.article_rounded,
                      maxLines: 4,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Enter the announcement body' : null,
                    ),
                    const SizedBox(height: 16),
                    Text('Tag',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: context.dc.textMuted)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        final selected = _selectedTag == tag;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTag = tag),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.secondary
                                  : context.dc.surfaceHighlight,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: AppColors.secondary.withOpacity(0.4)),
                            ),
                            child: Text(tag,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: selected
                                        ? Colors.white
                                        : context.dc.textMuted,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isPosting ? null : _post,
                        icon: _isPosting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.send_rounded,
                                color: Colors.white),
                        label: Text(
                          _isPosting ? 'Posting...' : 'Post Announcement',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Live list of existing announcements
            Text('📋 Existing Announcements',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.dc.textMain)),
            const SizedBox(height: 16),
            StreamBuilder(
              stream: FirestoreService().getAnnouncementsStream(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary));
                }
                final docs = snap.data!.docs;
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
                      borderColor: AppColors.secondary.withOpacity(0.2),
                      child: Row(
                        children: [
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
                                Text(data['body'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: context.dc.textMuted)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.primary, size: 24),
                            onPressed: () => FirestoreService()
                                .deleteAnnouncement(docs[i].id),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.plusJakartaSans(color: context.dc.textMain, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.plusJakartaSans(color: context.dc.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.secondary, size: 20),
        filled: true,
        fillColor: context.dc.surfaceHighlight,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.secondary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
}

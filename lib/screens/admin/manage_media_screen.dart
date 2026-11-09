import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/firestore_service.dart';
import '../../core/theme/dynamic_colors.dart';

class ManageMediaScreen extends StatefulWidget {
  const ManageMediaScreen({super.key});

  @override
  State<ManageMediaScreen> createState() => _ManageMediaScreenState();
}

class _ManageMediaScreenState extends State<ManageMediaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _videoUrlController = TextEditingController();
  String _selectedTag = 'Student Life';
  String _selectedEmoji = '📸';
  bool _isPosting = false;

  final List<String> _tags = [
    'Student Life',
    'Academic',
    'Graduation',
    'Community',
    'Tourism',
    'New Intake'
  ];
  final List<String> _emojis = [
    '📸',
    '❄️',
    '🏥',
    '🎓',
    '🏠',
    '🌆',
    '🛬',
    '🎉',
    '🇦🇲'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _addPost() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isPosting = true);
    try {
      await FirestoreService().addMediaPost(
        title: _titleController.text.trim(),
        desc: _descController.text.trim(),
        tag: _selectedTag,
        emoji: _selectedEmoji,
        videoUrl: _videoUrlController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('✅ Post added!', style: GoogleFonts.plusJakartaSans()),
          backgroundColor: const Color(0xFF00E676),
          behavior: SnackBarBehavior.floating,
        ));
        _titleController.clear();
        _descController.clear();
        _videoUrlController.clear();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Failed to add post.', style: GoogleFonts.plusJakartaSans()),
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
        title: Text('📸 Manage Media',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800, color: context.dc.textMain)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTheme.glassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 20,
              borderColor: AppColors.tertiary.withOpacity(0.3),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add New Post',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.dc.textMain)),
                    const SizedBox(height: 16),
                    _field(_titleController, 'Post Title', Icons.title_rounded,
                        (v) => (v == null || v.isEmpty) ? 'Enter title' : null),
                    const SizedBox(height: 12),
                    _field(
                        _descController,
                        'Description',
                        Icons.description_rounded,
                        (v) => (v == null || v.isEmpty)
                            ? 'Enter description'
                            : null,
                        maxLines: 3),
                    const SizedBox(height: 12),
                    _field(
                      _videoUrlController,
                      'Video URL (optional)',
                      Icons.play_circle_outline_rounded,
                      (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        final uri = Uri.tryParse(value.trim());
                        return uri != null &&
                                uri.hasScheme &&
                                uri.host.isNotEmpty
                            ? null
                            : 'Enter a valid HTTPS video URL';
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Emoji',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 13, color: context.dc.textMuted)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _emojis.map((e) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedEmoji = e),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _selectedEmoji == e
                                  ? AppColors.tertiary.withOpacity(0.2)
                                  : context.dc.surfaceHighlight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedEmoji == e
                                    ? AppColors.tertiary
                                    : Colors.transparent,
                              ),
                            ),
                            child:
                                Text(e, style: const TextStyle(fontSize: 24)),
                          ),
                        );
                      }).toList(),
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
                        final sel = _selectedTag == tag;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTag = tag),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.tertiary
                                  : context.dc.surfaceHighlight,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: sel
                                      ? AppColors.tertiary
                                      : context.dc.surfaceHighlight
                                          .withOpacity(0.5)),
                            ),
                            child: Text(tag,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: sel
                                        ? Colors.white
                                        : context.dc.textMuted,
                                    fontWeight: sel
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
                          backgroundColor: AppColors.tertiary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isPosting ? null : _addPost,
                        icon: _isPosting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.add_circle_rounded,
                                color: Colors.white),
                        label: Text(_isPosting ? 'Posting...' : 'Add Post',
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('📂 Existing Posts',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.dc.textMain)),
            const SizedBox(height: 16),
            StreamBuilder(
              stream: FirestoreService().getMediaPostsStream(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.tertiary));
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
                      borderColor: AppColors.tertiary.withOpacity(0.2),
                      child: Row(
                        children: [
                          Text(data['emoji'] ?? '📸',
                              style: const TextStyle(fontSize: 32)),
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
                                Text(data['tag'] ?? '',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: AppColors.tertiary,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: AppColors.primary, size: 24),
                            onPressed: () =>
                                FirestoreService().deleteMediaPost(docs[i].id),
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
        prefixIcon: Icon(icon, color: AppColors.tertiary, size: 20),
        filled: true,
        fillColor: context.dc.surfaceHighlight,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.tertiary, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }
}

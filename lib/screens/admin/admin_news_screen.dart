import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';

class AdminNewsScreen extends StatefulWidget {
  const AdminNewsScreen({super.key});

  @override
  State<AdminNewsScreen> createState() => _AdminNewsScreenState();
}

class _AdminNewsScreenState extends State<AdminNewsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<String> _tags = [
    'Academic',
    'Visa',
    'Health',
    'Finance',
    'Student Life',
  ];

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Academic':
        return AppColors.neonPurple;
      case 'Visa':
        return const Color(0xFF00E676);
      case 'Health':
        return AppColors.primary;
      case 'Finance':
        return const Color(0xFFFF9800);
      case 'Student Life':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  Future<void> _deleteArticle(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.dc.surfaceHighlight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Article',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this news article? This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestore.collection('news_articles').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Article deleted.',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _openArticleDialog({DocumentSnapshot? doc}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ArticleDialog(
        existingDoc: doc,
        tags: _tags,
        onSave: (data) async {
          if (doc != null) {
            await _firestore
                .collection('news_articles')
                .doc(doc.id)
                .update(data);
          } else {
            await _firestore.collection('news_articles').add(data);
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  doc != null
                      ? 'Article updated successfully.'
                      : 'Article added successfully.',
                  style: GoogleFonts.plusJakartaSans(),
                ),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '📰 Manage News',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _openArticleDialog(),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Article',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _firestore
            .collection('news_articles')
            .orderBy('createdAt', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong.\nPlease try again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📭', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text(
                    'No news articles yet.',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap the button below to add one.',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white30,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] as String? ?? '';
              final tag = data['tag'] as String? ?? '';
              final emoji = data['emoji'] as String? ?? '📰';
              final date = data['date'] as String? ?? '';

              return FadeInUp(
                duration: Duration(milliseconds: 300 + index * 60),
                child: _NewsCard(
                  emoji: emoji,
                  title: title,
                  tag: tag,
                  date: date,
                  tagColor: _tagColor(tag),
                  onEdit: () => _openArticleDialog(doc: doc),
                  onDelete: () => _deleteArticle(doc.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// News Card Widget
// ─────────────────────────────────────────────

class _NewsCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String tag;
  final String date;
  final Color tagColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NewsCard({
    required this.emoji,
    required this.title,
    required this.tag,
    required this.date,
    required this.tagColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.dc.surfaceHighlight.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Emoji badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: tagColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: tagColor.withOpacity(0.5), width: 1),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.plusJakartaSans(
                            color: tagColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          date,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Actions
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionIcon(
                  icon: Icons.edit_rounded,
                  color: AppColors.primary,
                  onTap: onEdit,
                ),
                const SizedBox(height: 6),
                _ActionIcon(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  onTap: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Add / Edit Article Dialog
// ─────────────────────────────────────────────

class _ArticleDialog extends StatefulWidget {
  final DocumentSnapshot? existingDoc;
  final List<String> tags;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  const _ArticleDialog({
    required this.existingDoc,
    required this.tags,
    required this.onSave,
  });

  @override
  State<_ArticleDialog> createState() => _ArticleDialogState();
}

class _ArticleDialogState extends State<_ArticleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _emojiCtrl;
  late final TextEditingController _dateCtrl;
  late String _selectedTag;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.existingDoc?.data() as Map<String, dynamic>?;
    _titleCtrl = TextEditingController(text: data?['title'] ?? '');
    _bodyCtrl = TextEditingController(text: data?['body'] ?? '');
    _emojiCtrl = TextEditingController(text: data?['emoji'] ?? '');
    _dateCtrl = TextEditingController(text: data?['date'] ?? '');
    _selectedTag = (data?['tag'] as String?) ?? widget.tags.first;
    if (!widget.tags.contains(_selectedTag)) {
      _selectedTag = widget.tags.first;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _emojiCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final data = {
        'title': _titleCtrl.text.trim(),
        'body': _bodyCtrl.text.trim(),
        'tag': _selectedTag,
        'emoji': _emojiCtrl.text.trim(),
        'date': _dateCtrl.text.trim(),
        'createdAt': widget.existingDoc != null
            ? (widget.existingDoc!.data()
                    as Map<String, dynamic>)['createdAt'] ??
                FieldValue.serverTimestamp()
            : FieldValue.serverTimestamp(),
      };
      await widget.onSave(data);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error saving article. Please try again.',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white54),
      hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white24),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: GoogleFonts.plusJakartaSans(color: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingDoc != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: context.dc.surfaceHighlight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? '✏️ Edit Article' : '📝 New Article',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _isSaving ? null : () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white38, size: 22),
                  ),
                ],
              ),
            ),
            // Form body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleCtrl,
                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                        decoration: _fieldDecoration('Title',
                            hint: 'Enter article title'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Title is required'
                            : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      // Body
                      TextFormField(
                        controller: _bodyCtrl,
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.white, fontSize: 14),
                        decoration: _fieldDecoration('Body',
                            hint: 'Write the full article text here…'),
                        minLines: 4,
                        maxLines: 10,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Body is required'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      // Tag dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedTag,
                        dropdownColor: context.dc.surfaceHighlight,
                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                        decoration: _fieldDecoration('Tag'),
                        items: widget.tags
                            .map((tag) => DropdownMenuItem(
                                  value: tag,
                                  child: Text(
                                    tag,
                                    style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedTag = val);
                        },
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Select a tag' : null,
                      ),
                      const SizedBox(height: 14),
                      // Emoji
                      TextFormField(
                        controller: _emojiCtrl,
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.white, fontSize: 20),
                        decoration: _fieldDecoration('Emoji',
                            hint: 'e.g. 🏆'),
                        maxLength: 8,
                        buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Emoji is required'
                            : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 14),
                      // Date
                      TextFormField(
                        controller: _dateCtrl,
                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                        decoration: _fieldDecoration('Date',
                            hint: 'e.g. June 3, 2025'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Date is required'
                            : null,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: Colors.white.withOpacity(0.2), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white60,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              isEditing ? 'Update' : 'Save',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

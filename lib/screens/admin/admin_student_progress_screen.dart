import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class _SubjectEntry {
  String name;
  String grade;
  String score;
  String status;

  _SubjectEntry({
    this.name = '',
    this.grade = 'A',
    this.score = '',
    this.status = 'Pass',
  });

  _SubjectEntry.fromMap(Map<String, dynamic> map)
      : name = map['name'] as String? ?? '',
        grade = map['grade'] as String? ?? 'A',
        score = map['score'] as String? ?? '',
        status = map['status'] as String? ?? 'Pass';

  Map<String, dynamic> toMap() => {
        'name': name,
        'grade': grade,
        'score': score,
        'status': status,
      };
}

class _StudentItem {
  final String userId;
  final String name;
  final String email;
  final String university;

  const _StudentItem({
    required this.userId,
    required this.name,
    required this.email,
    required this.university,
  });
}

// ---------------------------------------------------------------------------
// Root Screen — student list
// ---------------------------------------------------------------------------

class AdminStudentProgressScreen extends StatefulWidget {
  const AdminStudentProgressScreen({super.key});

  @override
  State<AdminStudentProgressScreen> createState() =>
      _AdminStudentProgressScreenState();
}

class _AdminStudentProgressScreenState
    extends State<AdminStudentProgressScreen> {
  bool _loading = true;
  List<_StudentItem> _students = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('applications')
          .orderBy('submittedAt', descending: true)
          .get();

      final list = snap.docs.map((doc) {
        final data = doc.data();
        final String userId = data['userId'] as String? ?? doc.id;
        final String name =
            data['fullName'] as String? ?? data['name'] as String? ?? 'Unknown';
        final String email = data['email'] as String? ?? '';
        final String university = data['university'] as String? ??
            data['targetUniversity'] as String? ??
            '';
        return _StudentItem(
          userId: userId,
          name: name,
          email: email,
          university: university,
        );
      }).toList();

      // De-duplicate by userId — keep first occurrence (most recent application)
      final seen = <String>{};
      final unique = <_StudentItem>[];
      for (final s in list) {
        if (seen.add(s.userId)) unique.add(s);
      }

      setState(() {
        _students = unique;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _openEditForm(_StudentItem student) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _EditProgressScreen(student: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.dc.textMain),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '📊 Student Progress',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: context.dc.textMain,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh_rounded, color: context.dc.textMuted),
            onPressed: _fetchStudents,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.primary, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load students',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.dc.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: context.dc.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchStudents,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_students.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, color: context.dc.textMuted, size: 56),
            const SizedBox(height: 16),
            Text(
              'No applications found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.dc.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        return FadeInUp(
          delay: Duration(milliseconds: 60 * index),
          duration: const Duration(milliseconds: 400),
          child: _StudentCard(
            student: student,
            onEdit: () => _openEditForm(student),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Student card widget
// ---------------------------------------------------------------------------

class _StudentCard extends StatelessWidget {
  final _StudentItem student;
  final VoidCallback onEdit;

  const _StudentCard({required this.student, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return AppTheme.glassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.secondary, AppColors.neonPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.dc.textMain,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  student.email,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: context.dc.textMuted,
                  ),
                ),
                if (student.university.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_rounded,
                          size: 12, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          student.university,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.85),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: Text(
                      'Edit Progress',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit Progress Screen
// ---------------------------------------------------------------------------

class _EditProgressScreen extends StatefulWidget {
  final _StudentItem student;
  const _EditProgressScreen({required this.student});

  @override
  State<_EditProgressScreen> createState() => _EditProgressScreenState();
}

class _EditProgressScreenState extends State<_EditProgressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _semesterCtrl = TextEditingController();
  final _gpaCtrl = TextEditingController();
  final _overallAttCtrl = TextEditingController();
  final _labAttCtrl = TextEditingController();

  List<_SubjectEntry> _subjects = [];

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fetchExistingProgress();
  }

  @override
  void dispose() {
    _semesterCtrl.dispose();
    _gpaCtrl.dispose();
    _overallAttCtrl.dispose();
    _labAttCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchExistingProgress() async {
    setState(() => _loading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('student_progress')
          .doc(widget.student.userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _semesterCtrl.text = data['semester'] as String? ?? '';
        _gpaCtrl.text = data['gpa'] as String? ?? '';
        _overallAttCtrl.text =
            (data['overallAttendance'] as int?)?.toString() ?? '';
        _labAttCtrl.text = (data['labAttendance'] as int?)?.toString() ?? '';

        final rawSubjects = data['subjects'] as List<dynamic>? ?? [];
        _subjects = rawSubjects
            .map((e) =>
                _SubjectEntry.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {
      // Non-fatal — form starts empty
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final overallAtt = int.tryParse(_overallAttCtrl.text.trim());
    final labAtt = int.tryParse(_labAttCtrl.text.trim());

    if (overallAtt == null || overallAtt < 0 || overallAtt > 100) {
      _showSnack('Overall Attendance must be 0–100', isError: true);
      return;
    }
    if (labAtt == null || labAtt < 0 || labAtt > 100) {
      _showSnack('Lab Attendance must be 0–100', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('student_progress')
          .doc(widget.student.userId)
          .set({
        'semester': _semesterCtrl.text.trim(),
        'gpa': _gpaCtrl.text.trim(),
        'overallAttendance': overallAtt,
        'labAttendance': labAtt,
        'subjects': _subjects.map((s) => s.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _showSnack('Progress saved successfully ✓');
    } catch (e) {
      _showSnack('Save failed: $e', isError: true);
    }
    setState(() => _saving = false);
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: isError ? AppColors.primary : const Color(0xFF00C26F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _addSubjectDialog() {
    showDialog(
      context: context,
      builder: (_) => _AddSubjectDialog(
        onAdd: (entry) {
          setState(() => _subjects.add(entry));
        },
      ),
    );
  }

  void _removeSubject(int index) {
    setState(() => _subjects.removeAt(index));
  }

  InputDecoration _inputDeco(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: context.dc.surface,
        labelStyle: GoogleFonts.plusJakartaSans(
            color: context.dc.textMuted, fontSize: 14),
        hintStyle: GoogleFonts.plusJakartaSans(
            color: context.dc.textMuted.withOpacity(0.5), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.dc.textMain),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Progress',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.dc.textMain,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.secondary))
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Student header card
          FadeInUp(
            duration: const Duration(milliseconds: 350),
            child: AppTheme.glassCard(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              borderColor: AppColors.secondary.withOpacity(0.3),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.neonPurple],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.student.name.isNotEmpty
                            ? widget.student.name[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.student.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.dc.textMain,
                          ),
                        ),
                        Text(
                          widget.student.email,
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
            ),
          ),

          // ---- Academic Info ----
          _sectionLabel('Academic Info'),
          const SizedBox(height: 10),

          FadeInUp(
            delay: const Duration(milliseconds: 60),
            duration: const Duration(milliseconds: 350),
            child: TextFormField(
              controller: _semesterCtrl,
              style: GoogleFonts.plusJakartaSans(
                  color: context.dc.textMain, fontSize: 14),
              decoration:
                  _inputDeco('Semester', hint: 'e.g. Year 1 · Semester 2'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
          ),
          const SizedBox(height: 14),

          FadeInUp(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 350),
            child: TextFormField(
              controller: _gpaCtrl,
              style: GoogleFonts.plusJakartaSans(
                  color: context.dc.textMain, fontSize: 14),
              decoration: _inputDeco('GPA', hint: 'e.g. 3.6'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final d = double.tryParse(v.trim());
                if (d == null) return 'Enter a valid number';
                return null;
              },
            ),
          ),
          const SizedBox(height: 22),

          // ---- Attendance ----
          _sectionLabel('Attendance'),
          const SizedBox(height: 10),

          FadeInUp(
            delay: const Duration(milliseconds: 140),
            duration: const Duration(milliseconds: 350),
            child: TextFormField(
              controller: _overallAttCtrl,
              style: GoogleFonts.plusJakartaSans(
                  color: context.dc.textMain, fontSize: 14),
              decoration: _inputDeco('Overall Attendance %', hint: '0 – 100'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final n = int.tryParse(v.trim());
                if (n == null || n < 0 || n > 100) {
                  return 'Must be 0–100';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 14),

          FadeInUp(
            delay: const Duration(milliseconds: 180),
            duration: const Duration(milliseconds: 350),
            child: TextFormField(
              controller: _labAttCtrl,
              style: GoogleFonts.plusJakartaSans(
                  color: context.dc.textMain, fontSize: 14),
              decoration:
                  _inputDeco('Lab Sessions Attendance %', hint: '0 – 100'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final n = int.tryParse(v.trim());
                if (n == null || n < 0 || n > 100) {
                  return 'Must be 0–100';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 22),

          // ---- Subjects ----
          _sectionLabel('Subjects'),
          const SizedBox(height: 10),

          if (_subjects.isEmpty)
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 350),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.dc.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Center(
                  child: Text(
                    'No subjects added yet',
                    style: GoogleFonts.plusJakartaSans(
                      color: context.dc.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),

          ..._subjects.asMap().entries.map((entry) {
            final i = entry.key;
            final sub = entry.value;
            return FadeInUp(
              delay: Duration(milliseconds: 60 * i),
              duration: const Duration(milliseconds: 300),
              child: _SubjectCard(
                subject: sub,
                onDelete: () => _removeSubject(i),
              ),
            );
          }),

          const SizedBox(height: 10),

          FadeInUp(
            delay: const Duration(milliseconds: 220),
            duration: const Duration(milliseconds: 350),
            child: OutlinedButton.icon(
              onPressed: _addSubjectDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: Text(
                'Add Subject',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ---- Save ----
          FadeInUp(
            delay: const Duration(milliseconds: 260),
            duration: const Duration(milliseconds: 350),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Save Progress',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.secondary,
        letterSpacing: 1.1,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subject card in the list
// ---------------------------------------------------------------------------

class _SubjectCard extends StatelessWidget {
  final _SubjectEntry subject;
  final VoidCallback onDelete;

  const _SubjectCard({required this.subject, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final bool isPassing = subject.status == 'Pass';
    return AppTheme.glassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 10),
      borderColor: isPassing
          ? const Color(0xFF00C26F).withOpacity(0.3)
          : AppColors.primary.withOpacity(0.3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.dc.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _chip(subject.grade, AppColors.secondary),
                    const SizedBox(width: 8),
                    _chip(subject.score, context.dc.textMuted),
                    const SizedBox(width: 8),
                    _chip(
                      subject.status,
                      isPassing ? const Color(0xFF00C26F) : AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.primary, size: 20),
            onPressed: onDelete,
            tooltip: 'Remove subject',
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Subject Dialog
// ---------------------------------------------------------------------------

class _AddSubjectDialog extends StatefulWidget {
  final void Function(_SubjectEntry entry) onAdd;

  const _AddSubjectDialog({required this.onAdd});

  @override
  State<_AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<_AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _scoreCtrl = TextEditingController();

  static const _grades = [
    'A',
    'A-',
    'B+',
    'B',
    'B-',
    'C+',
    'C',
    'F',
  ];

  String _grade = 'A';
  String _status = 'Pass';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final scoreRaw = _scoreCtrl.text.trim();
    final score = scoreRaw.contains('/') ? scoreRaw : '$scoreRaw/100';
    widget.onAdd(
      _SubjectEntry(
        name: _nameCtrl.text.trim(),
        grade: _grade,
        score: score,
        status: _status,
      ),
    );
    Navigator.of(context).pop();
  }

  InputDecoration _deco(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: context.dc.surfaceHighlight,
        labelStyle: GoogleFonts.plusJakartaSans(
            color: context.dc.textMuted, fontSize: 13),
        hintStyle: GoogleFonts.plusJakartaSans(
            color: context.dc.textMuted.withOpacity(0.5), fontSize: 13),
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
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.dc.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Subject',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.dc.textMain,
                ),
              ),
              const SizedBox(height: 20),

              // Subject Name
              TextFormField(
                controller: _nameCtrl,
                style: GoogleFonts.plusJakartaSans(
                    color: context.dc.textMain, fontSize: 14),
                decoration: _deco('Subject Name', hint: 'e.g. Mathematics'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // Grade
              DropdownButtonFormField<String>(
                value: _grade,
                dropdownColor: context.dc.surfaceHighlight,
                style: GoogleFonts.plusJakartaSans(
                    color: context.dc.textMain, fontSize: 14),
                decoration: _deco('Grade'),
                items: _grades
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g,
                              style: GoogleFonts.plusJakartaSans(
                                  color: context.dc.textMain)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _grade = v ?? 'A'),
              ),
              const SizedBox(height: 14),

              // Score
              TextFormField(
                controller: _scoreCtrl,
                style: GoogleFonts.plusJakartaSans(
                    color: context.dc.textMain, fontSize: 14),
                decoration: _deco('Score', hint: 'e.g. 88 or 88/100'),
                keyboardType: TextInputType.text,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // Status
              DropdownButtonFormField<String>(
                value: _status,
                dropdownColor: context.dc.surfaceHighlight,
                style: GoogleFonts.plusJakartaSans(
                    color: context.dc.textMain, fontSize: 14),
                decoration: _deco('Status'),
                items: ['Pass', 'Fail']
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s,
                              style: GoogleFonts.plusJakartaSans(
                                  color: context.dc.textMain)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? 'Pass'),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.dc.textMuted,
                        side: BorderSide(color: Colors.white.withOpacity(0.15)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: Text('Cancel',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                      ),
                      child: Text(
                        'Add',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

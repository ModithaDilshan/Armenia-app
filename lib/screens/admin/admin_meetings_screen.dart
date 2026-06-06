import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';

class AdminMeetingsScreen extends StatelessWidget {
  const AdminMeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '📅 Manage Meetings',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('meetings')
            .orderBy('order')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
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
                  const Icon(Icons.video_camera_front_outlined,
                      color: Colors.white30, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No meetings yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white38,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return FadeInUp(
                delay: Duration(milliseconds: index * 80),
                duration: const Duration(milliseconds: 400),
                child: _MeetingCard(
                  docId: doc.id,
                  data: data,
                  onEdit: () => _showMeetingForm(context, docId: doc.id, existing: data),
                  onDelete: () => _confirmDelete(context, doc.id, data['title'] ?? 'Meeting'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showMeetingForm(context),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Add Meeting',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showMeetingForm(
    BuildContext context, {
    String? docId,
    Map<String, dynamic>? existing,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MeetingFormSheet(docId: docId, existing: existing),
    );
  }

  void _confirmDelete(BuildContext context, String docId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Meeting',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$title"? This action cannot be undone.',
          style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await FirebaseFirestore.instance
                  .collection('meetings')
                  .doc(docId)
                  .delete();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Meeting deleted.',
                      style: GoogleFonts.plusJakartaSans(),
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MeetingCard({
    required this.docId,
    required this.data,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'Upcoming';
    final isUpcoming = status == 'Upcoming';
    final statusColor = isUpcoming ? AppColors.secondary : const Color(0xFF00E676);
    final meetUrl = data['meetUrl'] ?? '';
    final truncatedUrl = meetUrl.length > 40 ? '${meetUrl.substring(0, 40)}…' : meetUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    data['title'] ?? 'Untitled',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.plusJakartaSans(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _InfoRow(icon: Icons.calendar_today_rounded, text: data['date'] ?? '—'),
            const SizedBox(height: 5),
            _InfoRow(icon: Icons.access_time_rounded, text: data['time'] ?? '—'),
            const SizedBox(height: 5),
            _InfoRow(icon: Icons.person_rounded, text: 'Host: ${data['host'] ?? '—'}'),
            const SizedBox(height: 5),
            _InfoRow(
              icon: Icons.link_rounded,
              text: truncatedUrl.isEmpty ? 'No link set' : truncatedUrl,
            ),
            const SizedBox(height: 5),
            _InfoRow(
              icon: Icons.login_rounded,
              text: 'Can Join: ${(data['canJoin'] ?? false) ? 'Yes' : 'No'}',
            ),
            const SizedBox(height: 5),
            _InfoRow(
              icon: Icons.format_list_numbered_rounded,
              text: 'Order: ${data['order'] ?? 0}',
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  color: AppColors.secondary,
                  onTap: onEdit,
                ),
                const SizedBox(width: 10),
                _ActionButton(
                  icon: Icons.delete_rounded,
                  label: 'Delete',
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white60,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetingFormSheet extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existing;

  const _MeetingFormSheet({this.docId, this.existing});

  @override
  State<_MeetingFormSheet> createState() => _MeetingFormSheetState();
}

class _MeetingFormSheetState extends State<_MeetingFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _hostCtrl;
  late final TextEditingController _meetUrlCtrl;
  late final TextEditingController _orderCtrl;

  String _status = 'Upcoming';
  bool _canJoin = false;
  bool _isSaving = false;

  bool get isEditing => widget.docId != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing ?? {};
    _titleCtrl = TextEditingController(text: e['title'] ?? '');
    _dateCtrl = TextEditingController(text: e['date'] ?? '');
    _timeCtrl = TextEditingController(text: e['time'] ?? '');
    _hostCtrl = TextEditingController(text: e['host'] ?? '');
    _meetUrlCtrl = TextEditingController(text: e['meetUrl'] ?? '');
    _orderCtrl = TextEditingController(text: (e['order'] ?? 0).toString());
    _status = e['status'] ?? 'Upcoming';
    _canJoin = e['canJoin'] ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _hostCtrl.dispose();
    _meetUrlCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final data = {
      'title': _titleCtrl.text.trim(),
      'date': _dateCtrl.text.trim(),
      'time': _timeCtrl.text.trim(),
      'host': _hostCtrl.text.trim(),
      'meetUrl': _meetUrlCtrl.text.trim(),
      'order': int.tryParse(_orderCtrl.text.trim()) ?? 0,
      'status': _status,
      'canJoin': _canJoin,
    };

    try {
      final col = FirebaseFirestore.instance.collection('meetings');
      if (isEditing) {
        await col.doc(widget.docId).update(data);
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
        await col.add(data);
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Meeting updated!' : 'Meeting added!',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(0xFF00E676),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF121E2D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEditing ? 'Edit Meeting' : 'Add Meeting',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              _buildField(
                controller: _titleCtrl,
                label: 'Title',
                hint: 'e.g. Parent–Teacher Meeting',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _dateCtrl,
                label: 'Date',
                hint: 'e.g. JUN 5, 2025',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Date is required' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _timeCtrl,
                label: 'Time',
                hint: 'e.g. 7:00 PM – 8:00 PM (SL Time)',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Time is required' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _hostCtrl,
                label: 'Host',
                hint: 'e.g. Mr. Karunasena',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Host is required' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _meetUrlCtrl,
                label: 'Meet URL',
                hint: 'https://meet.google.com/...',
                keyboardType: TextInputType.url,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Meet URL is required' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _orderCtrl,
                label: 'Order',
                hint: 'e.g. 1',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Order is required';
                  if (int.tryParse(v.trim()) == null) return 'Must be a whole number';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Text(
                'Status',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _status,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A2B3C),
                    style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
                    items: const [
                      DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
                      DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Can Join',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Switch(
                      value: _canJoin,
                      onChanged: (val) => setState(() => _canJoin = val),
                      activeColor: AppColors.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    disabledBackgroundColor: AppColors.secondary.withOpacity(0.4),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          isEditing ? 'Save Changes' : 'Add Meeting',
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
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
          cursorColor: AppColors.secondary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white30, fontSize: 13),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.secondary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            errorStyle: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

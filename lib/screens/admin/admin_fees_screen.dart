import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';

class AdminFeesScreen extends StatelessWidget {
  const AdminFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text('💳 Fee Records',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800, color: context.dc.textMain)),
        centerTitle: true,
        leading: IconButton(
            icon:
                Icon(Icons.arrow_back_ios_rounded, color: context.dc.textMain),
            onPressed: () => Navigator.pop(context)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('applications')
            .orderBy('submittedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  const Text('📭', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text('No students found',
                      style: GoogleFonts.plusJakartaSans(
                          color: context.dc.textMuted, fontSize: 16)),
                ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final uid = d['userId'] as String? ?? docs[i].id;
              return FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: i * 60),
                child: AppTheme.glassCard(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  borderRadius: 18,
                  borderColor: AppColors.primary.withOpacity(0.2),
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          shape: BoxShape.circle),
                      child: Center(
                          child: Text(
                              (d['name'] as String? ?? 'S')[0].toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(d['name'] as String? ?? 'Unknown',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: context.dc.textMain)),
                          Text(d['university'] as String? ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11, color: context.dc.textMuted)),
                        ])),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => _FeeEditorScreen(
                                  userId: uid,
                                  studentName:
                                      d['name'] as String? ?? 'Student'))),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.primary, Color(0xFF900020)]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Manage Fees',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FeeEditorScreen extends StatefulWidget {
  final String userId;
  final String studentName;
  const _FeeEditorScreen({required this.userId, required this.studentName});

  @override
  State<_FeeEditorScreen> createState() => _FeeEditorScreenState();
}

class _FeeEditorScreenState extends State<_FeeEditorScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('student_fees')
          .doc(widget.userId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        _items = List<Map<String, dynamic>>.from(
          (data['items'] as List<dynamic>? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map)),
        );
      } else {
        _items = [
          {
            'label': 'Tuition Fee — Year 1',
            'amount': 'USD 4,500',
            'status': 'Paid',
            'note': 'Annual tuition fee',
            'iconKey': 'school'
          },
          {
            'label': 'Hostel Accommodation',
            'amount': 'USD 1,200',
            'status': 'Paid',
            'note': 'Sep 2024 – Jun 2025',
            'iconKey': 'home'
          },
          {
            'label': 'Student Visa Fees',
            'amount': 'USD 350',
            'status': 'Paid',
            'note': 'One-time visa processing fee',
            'iconKey': 'airplane'
          },
          {
            'label': 'Health Insurance',
            'amount': 'USD 180',
            'status': 'Paid',
            'note': 'Sep 2024 – Aug 2025',
            'iconKey': 'health'
          },
          {
            'label': 'Tuition Fee — Year 2',
            'amount': 'USD 4,500',
            'status': 'Pending',
            'note': 'Due by July 30, 2025',
            'iconKey': 'school'
          },
          {
            'label': 'Airport Pickup & Orientation',
            'amount': 'USD 75',
            'status': 'Paid',
            'note': 'One-time service fee',
            'iconKey': 'flight_land'
          },
        ];
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('student_fees')
          .doc(widget.userId)
          .set({
        'items': _items,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('✅ Fee records saved!',
                style:
                    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFF00E676),
            behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('❌ Save failed: $e', style: GoogleFonts.plusJakartaSans()),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating));
      }
    }
    setState(() => _saving = false);
  }

  int _parseAmount(String a) =>
      int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  IconData _iconForKey(String k) {
    switch (k) {
      case 'school':
        return Icons.school_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'airplane':
        return Icons.airplane_ticket_rounded;
      case 'health':
        return Icons.health_and_safety_rounded;
      case 'flight_land':
        return Icons.flight_land_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  void _showForm({Map<String, dynamic>? existing, int? index}) {
    final labelC = TextEditingController(text: existing?['label'] ?? '');
    final amountC = TextEditingController(text: existing?['amount'] ?? '');
    final noteC = TextEditingController(text: existing?['note'] ?? '');
    String status = existing?['status'] ?? 'Paid';
    String iconKey = existing?['iconKey'] ?? 'school';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.dc.surfaceHighlight,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Form(
            key: formKey,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(existing == null ? '➕ Add Fee Item' : '✏️ Edit Fee Item',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: context.dc.textMain)),
                  const SizedBox(height: 20),
                  _field('Label', labelC, 'e.g. Tuition Fee — Year 1'),
                  const SizedBox(height: 12),
                  _field('Amount', amountC, 'e.g. USD 4,500'),
                  const SizedBox(height: 12),
                  _field('Note', noteC, 'e.g. Due by July 30, 2025',
                      required: false),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    dropdownColor: context.dc.surfaceHighlight,
                    style:
                        GoogleFonts.plusJakartaSans(color: context.dc.textMain),
                    decoration: _inputDec('Status'),
                    items: ['Paid', 'Pending']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setModalState(() => status = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: iconKey,
                    dropdownColor: context.dc.surfaceHighlight,
                    style:
                        GoogleFonts.plusJakartaSans(color: context.dc.textMain),
                    decoration: _inputDec('Icon'),
                    items: [
                      'school',
                      'home',
                      'airplane',
                      'health',
                      'flight_land',
                      'payment'
                    ]
                        .map((k) => DropdownMenuItem(
                            value: k,
                            child: Row(children: [
                              Icon(_iconForKey(k),
                                  size: 18, color: context.dc.textMuted),
                              const SizedBox(width: 8),
                              Text(k)
                            ])))
                        .toList(),
                    onChanged: (v) => setModalState(() => iconKey = v!),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final item = {
                          'label': labelC.text.trim(),
                          'amount': amountC.text.trim(),
                          'status': status,
                          'note': noteC.text.trim(),
                          'iconKey': iconKey
                        };
                        setState(() {
                          if (index != null) {
                            _items[index] = item;
                          } else {
                            _items.add(item);
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      child: Text('Save',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label) => InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.plusJakartaSans(
            color: context.dc.textMuted, fontSize: 13),
        filled: true,
        fillColor: context.dc.surface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary)),
      );

  Widget _field(String label, TextEditingController c, String hint,
      {bool required = true}) {
    return TextFormField(
      controller: c,
      style: GoogleFonts.plusJakartaSans(color: context.dc.textMain),
      decoration: _inputDec(label).copyWith(
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
              color: context.dc.textMuted, fontSize: 12)),
      validator:
          required ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final paid = _items
        .where((i) => i['status'] == 'Paid')
        .fold<int>(0, (s, i) => s + _parseAmount(i['amount'] ?? ''));
    final pending = _items
        .where((i) => i['status'] == 'Pending')
        .fold<int>(0, (s, i) => s + _parseAmount(i['amount'] ?? ''));

    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text('${widget.studentName} — Fees',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: context.dc.textMain,
                fontSize: 15)),
        centerTitle: true,
        leading: IconButton(
            icon:
                Icon(Icons.arrow_back_ios_rounded, color: context.dc.textMain),
            onPressed: () => Navigator.pop(context)),
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)))
              : IconButton(
                  icon:
                      const Icon(Icons.save_rounded, color: Color(0xFF00E676)),
                  onPressed: _save,
                  tooltip: 'Save'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Expanded(
                      child: _summaryCard(
                          'Total Paid', 'USD $paid', const Color(0xFF00E676))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _summaryCard(
                          'Pending', 'USD $pending', AppColors.primary)),
                ]),
              ),
              Expanded(
                child: _items.isEmpty
                    ? Center(
                        child: Text('No fee items yet. Tap + to add.',
                            style: GoogleFonts.plusJakartaSans(
                                color: context.dc.textMuted)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _items.length,
                        itemBuilder: (context, i) {
                          final fee = _items[i];
                          final isPaid = fee['status'] == 'Paid';
                          final statusColor = isPaid
                              ? const Color(0xFF00E676)
                              : AppColors.primary;
                          return FadeInUp(
                            duration: const Duration(milliseconds: 350),
                            delay: Duration(milliseconds: i * 50),
                            child: AppTheme.glassCard(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              borderRadius: 14,
                              borderColor: statusColor.withOpacity(0.25),
                              child: Row(children: [
                                Icon(_iconForKey(fee['iconKey'] ?? ''),
                                    color: statusColor, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(fee['label'] as String? ?? '',
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: context.dc.textMain)),
                                      Text(fee['note'] as String? ?? '',
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: context.dc.textMuted)),
                                    ])),
                                Text(fee['amount'] as String? ?? '',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: context.dc.textMain)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(fee['status'] as String? ?? '',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: statusColor)),
                                ),
                                IconButton(
                                    icon: Icon(Icons.edit_rounded,
                                        color: context.dc.textMuted, size: 18),
                                    onPressed: () =>
                                        _showForm(existing: fee, index: i)),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      color: Colors.red, size: 18),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      backgroundColor:
                                          context.dc.surfaceHighlight,
                                      title: Text('Delete?',
                                          style: GoogleFonts.plusJakartaSans(
                                              color: context.dc.textMain,
                                              fontWeight: FontWeight.w700)),
                                      content: Text('Remove "${fee['label']}"?',
                                          style: GoogleFonts.plusJakartaSans(
                                              color: context.dc.textMuted)),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text('Cancel',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                        color: context
                                                            .dc.textMuted))),
                                        TextButton(
                                            onPressed: () {
                                              setState(
                                                  () => _items.removeAt(i));
                                              Navigator.pop(context);
                                            },
                                            child: Text('Delete',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.w700))),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
              ),
            ]),
    );
  }

  Widget _summaryCard(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11, color: context.dc.textMuted)),
        const SizedBox(height: 4),
        Text(amount,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      ]),
    );
  }
}

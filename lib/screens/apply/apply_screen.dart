import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:convert';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import '../../services/firestore_service.dart';
import 'application_status_screen.dart';

class ApplyScreen extends StatefulWidget {
  const ApplyScreen({super.key});

  @override
  State<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends State<ApplyScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();

  String? _selectedUniversity;
  String? _selectedProgram;
  String? _selectedGender;
  bool _agreedToTerms = false;
  bool _isSubmitting = false;
  DateTime? _selectedDob; // Date picker value

  String? _passportFile;
  String? _alResultFile;
  String? _olResultFile;
  String? _photoFile;

  // Store file bytes for upload (works on all platforms)
  Uint8List? _passportBytes;
  Uint8List? _alResultBytes;
  Uint8List? _olResultBytes;
  Uint8List? _photoBytes;

  final List<String> _universities = [
    'Yerevan State Medical University (YSMU)',
    'State Engineering University of Armenia (SEUA)',
    'American University of Armenia (AUA)',
    'National Academy of Architecture (NAA)',
    'Yerevan State University - Tourism',
  ];

  final Map<String, List<String>> _programs = {
    'Yerevan State Medical University (YSMU)': [
      'General Medicine (MBBS)',
      'Dentistry (BDS)',
      'Pharmacy',
      'Pediatrics',
    ],
    'State Engineering University of Armenia (SEUA)': [
      'Civil Engineering',
      'Electrical Engineering',
      'Computer Science',
      'Mechanical Engineering',
    ],
    'American University of Armenia (AUA)': [
      'Computer & Information Science',
      'Business Administration',
      'Law',
      'Data Science',
    ],
    'National Academy of Architecture (NAA)': [
      'Architecture',
      'Interior Design',
      'Urban Planning',
    ],
    'Yerevan State University - Tourism': [
      'Tourism Management',
      'Hotel Management',
      'Event Management',
    ],
  };

  List<String> get _availablePrograms {
    if (_selectedUniversity == null) return [];
    return _programs[_selectedUniversity!] ?? [];
  }

  Future<void> _pickFile(String type) async {
    if (type == 'photo') {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _photoFile = picked.name;
          _photoBytes = bytes;
        });
      }
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true, // ensures bytes are loaded in memory
      );
      if (result != null) {
        final file = result.files.single;
        final bytes = file.bytes;
        setState(() {
          if (type == 'passport') {
            _passportFile = file.name;
            _passportBytes = bytes;
          }
          if (type == 'al') {
            _alResultFile = file.name;
            _alResultBytes = bytes;
          }
          if (type == 'ol') {
            _olResultFile = file.name;
            _olResultBytes = bytes;
          }
        });
      }
    }
  }

  // Compress image bytes to fit under Firestore 1MB limit
  Uint8List _compressImage(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return bytes;
      // Resize to max 800px on longest side
      img.Image resized = decoded;
      if (decoded.width > 800 || decoded.height > 800) {
        resized = decoded.width >= decoded.height
            ? img.copyResize(decoded, width: 800)
            : img.copyResize(decoded, height: 800);
      }
      // Encode as JPEG at 65% quality
      final compressed = img.encodeJpg(resized, quality: 65);
      debugPrint(
          'Compressed: ${bytes.length ~/ 1024}KB → ${compressed.length ~/ 1024}KB');
      return Uint8List.fromList(compressed);
    } catch (e) {
      debugPrint('Compression failed, using original: $e');
      return bytes;
    }
  }

  // Upload bytes — tries Firebase Storage first, falls back to Firestore base64
  // Works on ALL platforms: Windows, Chrome, Android (no Firebase Storage plan needed)
  Future<String?> _uploadBytes(
      Uint8List bytes, String fileName, String folder) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    // 1. Try Firebase Storage (works if bucket is enabled)
    try {
      final ref =
          FirebaseStorage.instance.ref('applications/$uid/$folder/$fileName');
      final metadata = SettableMetadata(
        contentType: isPdf ? 'application/pdf' : 'image/jpeg',
      );
      final snapshot = await ref.putData(bytes, metadata);
      final url = await snapshot.ref.getDownloadURL();
      debugPrint('Uploaded to Firebase Storage: $url');
      return url;
    } catch (e) {
      debugPrint('Firebase Storage unavailable, using Firestore fallback: $e');
    }

    // 2. Fallback: Store as base64 in Firestore
    // For images: compress first to stay under 1MB limit
    try {
      final Uint8List uploadBytes = isPdf ? bytes : _compressImage(bytes);

      // Check if still too large (PDFs can be big)
      if (uploadBytes.length > 900000) {
        debugPrint(
            'File too large for Firestore (${uploadBytes.length ~/ 1024}KB). Skipping.');
        return null;
      }

      final base64Data = base64Encode(uploadBytes);
      final contentType = isPdf ? 'application/pdf' : 'image/jpeg';
      final docId = '${uid}_$folder';

      await FirebaseFirestore.instance
          .collection('document_files')
          .doc(docId)
          .set({
        'base64Data': base64Data,
        'contentType': contentType,
        'fileName': fileName,
        'userId': uid,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Stored in Firestore as base64: document_files/$docId');
      return 'firestore://document_files/$docId';
    } catch (e) {
      debugPrint('Firestore fallback also failed: $e');
      return null;
    }
  }

  void _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please agree to the terms & conditions',
              style: GoogleFonts.plusJakartaSans()),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Upload documents to Firebase Storage using bytes (works on all platforms)
    String? passportUrl;
    String? alResultUrl;
    String? olResultUrl;
    String? photoUrl;

    if (_passportBytes != null) {
      passportUrl =
          await _uploadBytes(_passportBytes!, _passportFile!, 'passport');
    }
    if (_alResultBytes != null) {
      alResultUrl =
          await _uploadBytes(_alResultBytes!, _alResultFile!, 'al_results');
    }
    if (_olResultBytes != null) {
      olResultUrl =
          await _uploadBytes(_olResultBytes!, _olResultFile!, 'ol_results');
    }
    if (_photoBytes != null) {
      photoUrl = await _uploadBytes(_photoBytes!, _photoFile!, 'photo');
    }

    final error = await FirestoreService().submitApplication(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      dob: _selectedDob != null
          ? '${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}'
          : _dobController.text,
      address: _addressController.text,
      gender: _selectedGender ?? '',
      parentName: _parentNameController.text,
      parentPhone: _parentPhoneController.text,
      university: _selectedUniversity ?? '',
      program: _selectedProgram ?? '',
      passportUrl: passportUrl,
      alResultUrl: alResultUrl,
      olResultUrl: olResultUrl,
      photoUrl: photoUrl,
      passportFileName: _passportFile,
      alResultFileName: _alResultFile,
      olResultFileName: _olResultFile,
      photoFileName: _photoFile,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: GoogleFonts.plusJakartaSans()),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: context.dc.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.primary.withOpacity(0.3))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF00E676), size: 70),
            const SizedBox(height: 20),
            Text(
              'Application Submitted!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: context.dc.textMain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your application has been received. Our counselor will contact you within 24 hours via WhatsApp and Email to collect your documents.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: context.dc.textMuted,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true)
                      .pop(); // close dialog
                  // Navigate back to home safely
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Great, Thank You!',
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text(
          '📝 Apply Online',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: context.dc.textMain,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Application status',
            icon: const Icon(Icons.track_changes_rounded,
                color: AppColors.secondary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ApplicationStatusScreen()),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: context.dc.textMuted,
          labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Personal Info'),
            Tab(text: 'Documents'),
            Tab(text: 'Review'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPersonalInfoTab(),
            _buildDocumentsTab(),
            _buildReviewTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('👤 Student Information'),
            _textField(_nameController, 'Full Name (as in Passport)',
                Icons.person_rounded),
            _textField(_emailController, 'Email Address', Icons.email_rounded,
                keyboardType: TextInputType.emailAddress),
            _textField(_phoneController, 'Mobile Number', Icons.phone_rounded,
                keyboardType: TextInputType.phone),
            // DOB — Date Picker field
            _dobPickerField(),
            _textField(_addressController, 'Home Address', Icons.home_rounded,
                maxLines: 2),
            _dropdownField(
              label: 'Gender',
              value: _selectedGender,
              items: ['Male', 'Female', 'Prefer not to say'],
              icon: Icons.wc_rounded,
              onChanged: (v) => setState(() => _selectedGender = v),
            ),
            const SizedBox(height: 24),
            _sectionHeader('🎓 Academic Preferences'),
            _dropdownField(
              label: 'Select University',
              value: _selectedUniversity,
              items: _universities,
              icon: Icons.account_balance_rounded,
              onChanged: (v) => setState(() {
                _selectedUniversity = v;
                _selectedProgram = null;
              }),
            ),
            _dropdownField(
              label: 'Select Program',
              value: _selectedProgram,
              items: _availablePrograms,
              icon: Icons.school_rounded,
              onChanged: (v) => setState(() => _selectedProgram = v),
            ),
            const SizedBox(height: 24),
            _sectionHeader('👨‍👩‍👧 Parent / Guardian Information'),
            _textField(_parentNameController, 'Parent/Guardian Name',
                Icons.family_restroom_rounded),
            _textField(_parentPhoneController, 'Parent Mobile Number',
                Icons.phone_in_talk_rounded,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 32),
            _nextButton(() {
              // Validate personal info before advancing
              if (!_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill all required fields correctly',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600)),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
                return;
              }
              if (_selectedDob == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please select your date of birth',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600)),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
                return;
              }
              _tabController.animateTo(1);
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('📎 Upload Required Documents'),
            const SizedBox(height: 4),
            Text(
              'Accepted formats: PDF, JPG, PNG (Max 5MB each)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: context.dc.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            _uploadCard(
              title: '🛂 Passport Copy',
              subtitle: 'Upload clear copy of all pages',
              fileName: _passportFile,
              isRequired: true,
              onTap: () => _pickFile('passport'),
            ),
            _uploadCard(
              title: '📊 A/L Results',
              subtitle: 'Advanced Level certificate or results sheet',
              fileName: _alResultFile,
              isRequired: true,
              onTap: () => _pickFile('al'),
            ),
            _uploadCard(
              title: '📋 O/L Results',
              subtitle: 'Ordinary Level certificate or results sheet',
              fileName: _olResultFile,
              isRequired: true,
              onTap: () => _pickFile('ol'),
            ),
            _uploadCard(
              title: '📸 Passport Photograph',
              subtitle: 'Recent passport size photo (white background)',
              fileName: _photoFile,
              isRequired: true,
              onTap: () => _pickFile('photo'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.secondary, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'All documents will be kept confidential and used only for university application purposes.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.secondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.dc.textMuted),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _tabController.animateTo(0),
                    child: Text('← Back',
                        style: GoogleFonts.plusJakartaSans(
                            color: context.dc.textMuted,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _nextButton(() => _tabController.animateTo(2)),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewTab() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('✅ Review Your Application'),
            AppTheme.glassCard(
              padding: EdgeInsets.zero,
              borderRadius: 16,
              child: Column(
                children: [
                  _reviewCard(
                      'Student Name',
                      _nameController.text.isNotEmpty
                          ? _nameController.text
                          : 'Not filled',
                      isFirst: true),
                  _reviewCard(
                      'Email',
                      _emailController.text.isNotEmpty
                          ? _emailController.text
                          : 'Not filled'),
                  _reviewCard(
                      'Phone',
                      _phoneController.text.isNotEmpty
                          ? _phoneController.text
                          : 'Not filled'),
                  _reviewCard(
                      'University', _selectedUniversity ?? 'Not selected'),
                  _reviewCard('Program', _selectedProgram ?? 'Not selected'),
                  _reviewCard(
                      'Parent Name',
                      _parentNameController.text.isNotEmpty
                          ? _parentNameController.text
                          : 'Not filled'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _sectionHeader('📄 Document Status'),
            AppTheme.glassCard(
              padding: EdgeInsets.zero,
              borderRadius: 16,
              child: Column(
                children: [
                  _reviewCard('Passport', _passportFile ?? '⚠️ Not uploaded',
                      isFirst: true),
                  _reviewCard(
                      'A/L Results', _alResultFile ?? '⚠️ Not uploaded'),
                  _reviewCard(
                      'O/L Results', _olResultFile ?? '⚠️ Not uploaded'),
                  _reviewCard('Photo', _photoFile ?? '⚠️ Not uploaded'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CheckboxListTile(
              value: _agreedToTerms,
              onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
              activeColor: AppColors.primary,
              title: Text(
                'I agree to the Terms & Conditions and confirm that all information provided is accurate.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: context.dc.textMuted,
                  height: 1.5,
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              tileColor: context.dc.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                onPressed: _isSubmitting ? null : _submitApplication,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        '🚀 Submit Application',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: context.dc.textMain,
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.plusJakartaSans(
            color: context.dc.textMain, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.plusJakartaSans(
              color: context.dc.textMuted, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
          filled: true,
          fillColor: context.dc.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'This field is required';
          return null;
        },
      ),
    );
  }

  // ── Date of Birth Picker Field ─────────────────────────────────────────────
  Widget _dobPickerField() {
    final displayText = _selectedDob != null
        ? '${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate:
                _selectedDob ?? DateTime(now.year - 18, now.month, now.day),
            firstDate: DateTime(1950),
            lastDate: DateTime(now.year - 14, now.month, now.day),
            helpText: 'SELECT DATE OF BIRTH',
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: context.dc.surface,
                  onSurface: context.dc.textMain,
                ),
                dialogBackgroundColor: context.dc.background,
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            setState(() => _selectedDob = picked);
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            controller: TextEditingController(text: displayText),
            readOnly: true,
            style: GoogleFonts.plusJakartaSans(
                color: context.dc.textMain, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Date of Birth *',
              labelStyle: GoogleFonts.plusJakartaSans(
                  color: context.dc.textMuted, fontSize: 14),
              prefixIcon: const Icon(Icons.cake_rounded,
                  color: AppColors.primary, size: 22),
              suffixIcon: const Icon(Icons.calendar_month_rounded,
                  color: AppColors.primary, size: 20),
              hintText: 'Tap to select date',
              hintStyle: GoogleFonts.plusJakartaSans(
                  color: context.dc.textMuted, fontSize: 13),
              filled: true,
              fillColor: context.dc.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: AppColors.primary.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: _selectedDob == null
                        ? Colors.orange.withOpacity(0.4)
                        : const Color(0xFF00E676).withOpacity(0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            validator: (_) {
              if (_selectedDob == null) {
                return 'Please select your date of birth';
              }
              final age = DateTime.now().year - _selectedDob!.year;
              if (age < 14) return 'Applicant must be at least 14 years old';
              if (age > 60) return 'Please enter a valid date of birth';
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: context.dc.surface,
        style: GoogleFonts.plusJakartaSans(
            color: context.dc.textMain, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.plusJakartaSans(
              color: context.dc.textMuted, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
          filled: true,
          fillColor: context.dc.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, color: context.dc.textMain),
                      overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Please select an option' : null,
      ),
    );
  }

  Widget _uploadCard({
    required String title,
    required String subtitle,
    required String? fileName,
    required bool isRequired,
    required VoidCallback onTap,
  }) {
    final isUploaded = fileName != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.dc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded
                ? const Color(0xFF00E676).withOpacity(0.5)
                : AppColors.primary.withOpacity(0.3),
            width: isUploaded ? 1.5 : 1,
          ),
          boxShadow: [
            if (isUploaded)
              BoxShadow(
                  color: const Color(0xFF00E676).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isUploaded
                    ? const Color(0xFF00E676).withOpacity(0.15)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isUploaded
                    ? Icons.check_circle_rounded
                    : Icons.upload_file_rounded,
                color: isUploaded ? const Color(0xFF00E676) : AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.dc.textMain,
                        ),
                      ),
                      if (isRequired)
                        const Text(' *',
                            style: TextStyle(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUploaded ? '✅ $fileName' : subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isUploaded
                          ? const Color(0xFF00E676)
                          : context.dc.textMuted,
                      fontWeight:
                          isUploaded ? FontWeight.w600 : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: context.dc.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewCard(String label, String value, {bool isFirst = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: isFirst
            ? null
            : Border(
                top: BorderSide(color: context.dc.textMuted.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: context.dc.textMuted,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: context.dc.textMain,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextButton(VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.4),
        ),
        onPressed: onTap,
        child: Text(
          'Next →',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

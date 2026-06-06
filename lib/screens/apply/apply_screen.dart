import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import '../../services/firestore_service.dart';

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

  String? _passportFile;
  String? _alResultFile;
  String? _olResultFile;
  String? _photoFile;

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
      final picked =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _photoFile = picked.name);
      }
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null) {
        final name = result.files.single.name;
        setState(() {
          if (type == 'passport') _passportFile = name;
          if (type == 'al') _alResultFile = name;
          if (type == 'ol') _olResultFile = name;
        });
      }
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
    
    final error = await FirestoreService().submitApplication(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      dob: _dobController.text,
      address: _addressController.text,
      gender: _selectedGender ?? '',
      parentName: _parentNameController.text,
      parentPhone: _parentPhoneController.text,
      university: _selectedUniversity ?? '',
      program: _selectedProgram ?? '',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: AppColors.primary.withOpacity(0.3))),
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
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to home
                },
                child: Text('Great, Thank You!',
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
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
            _textField(_dobController, 'Date of Birth (DD/MM/YYYY)',
                Icons.calendar_today_rounded),
            _textField(
                _addressController, 'Home Address', Icons.home_rounded,
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
            _textField(
                _parentNameController, 'Parent/Guardian Name', Icons.family_restroom_rounded),
            _textField(_parentPhoneController, 'Parent Mobile Number',
                Icons.phone_in_talk_rounded,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 32),
            _nextButton(() => _tabController.animateTo(1)),
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
                        style: GoogleFonts.plusJakartaSans(color: context.dc.textMuted, fontWeight: FontWeight.w700)),
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
                  _reviewCard('Student Name', _nameController.text.isNotEmpty ? _nameController.text : 'Not filled', isFirst: true),
                  _reviewCard('Email', _emailController.text.isNotEmpty ? _emailController.text : 'Not filled'),
                  _reviewCard('Phone', _phoneController.text.isNotEmpty ? _phoneController.text : 'Not filled'),
                  _reviewCard('University', _selectedUniversity ?? 'Not selected'),
                  _reviewCard('Program', _selectedProgram ?? 'Not selected'),
                  _reviewCard('Parent Name', _parentNameController.text.isNotEmpty ? _parentNameController.text : 'Not filled'),
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
                  _reviewCard('Passport', _passportFile ?? '⚠️ Not uploaded', isFirst: true),
                  _reviewCard('A/L Results', _alResultFile ?? '⚠️ Not uploaded'),
                  _reviewCard('O/L Results', _olResultFile ?? '⚠️ Not uploaded'),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        style: GoogleFonts.plusJakartaSans(color: context.dc.textMain, fontSize: 14),
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
        validator: (v) =>
            (v == null || v.isEmpty) ? 'This field is required' : null,
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
        style: GoogleFonts.plusJakartaSans(color: context.dc.textMain, fontSize: 14),
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
              BoxShadow(color: const Color(0xFF00E676).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
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
                color: isUploaded
                    ? const Color(0xFF00E676)
                    : AppColors.primary,
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
                        Text(' *',
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
                      fontWeight: isUploaded ? FontWeight.w600 : FontWeight.w500,
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
        border: isFirst ? null : Border(top: BorderSide(color: context.dc.textMuted.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: context.dc.textMuted, fontWeight: FontWeight.w600),
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/dynamic_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight,
        title: Text('Privacy Policy',
            style: GoogleFonts.plusJakartaSans(
              color: context.dc.textMain,
              fontWeight: FontWeight.w800,
            )),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _section(context, 'Information we collect',
              'We collect account details, contact information, application details, academic records, fee records, and documents you choose to upload.'),
          _section(context, 'How information is used',
              'Information is used to process university applications, provide counseling, share academic and payment updates, arrange meetings, and support enrolled students and their parents or guardians.'),
          _section(context, 'Storage and access',
              'Data is stored using Firebase services. Access is limited to the account owner, an explicitly linked parent or guardian, and authorized administrators.'),
          _section(context, 'Sharing',
              'Application information may be shared with selected universities and relevant education, visa, travel, or accommodation providers only when required to provide the requested service.'),
          _section(context, 'Your choices',
              'You can disable push notifications in Settings. To request access, correction, or deletion of personal data, contact ${AppConstants.supportEmail}.'),
          _section(context, 'Contact',
              'Questions about privacy can be sent to ${AppConstants.supportEmail}.'),
          Text('Last updated: September 23, 2026',
              style: GoogleFonts.plusJakartaSans(
                color: context.dc.textMuted,
                fontSize: 12,
              )),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.plusJakartaSans(
              color: context.dc.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            )),
        const SizedBox(height: 8),
        Text(body,
            style: GoogleFonts.plusJakartaSans(
              color: context.dc.textMuted,
              height: 1.6,
            )),
      ]),
    );
  }
}

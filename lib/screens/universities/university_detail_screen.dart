import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import '../../models/university_model.dart';

class UniversityDetailScreen extends StatefulWidget {
  final University university;

  const UniversityDetailScreen({super.key, required this.university});

  @override
  State<UniversityDetailScreen> createState() => _UniversityDetailScreenState();
}

class _UniversityDetailScreenState extends State<UniversityDetailScreen> {
  University get university => widget.university;

  Color get _color {
    final map = {
      'Medical': AppColors.primary,
      'Engineering': AppColors.secondary,
      'IT & Business': AppColors.neonPurple,
      'Architecture': const Color(0xFFE65100),
      'Tourism & Hospitality': const Color(0xFF00695C),
    };
    return map[university.category] ?? AppColors.primary;
  }

  void _launchWhatsApp(BuildContext context) async {
    final uri = Uri.parse(
        'https://wa.me/${university.whatsapp.replaceAll('+', '')}?text=I%20am%20interested%20in%20${Uri.encodeComponent(university.name)}');
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: _buildQuickStats()),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 100),
                    child: _buildBadges()),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: _buildSection('📖 About', university.description)),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 300),
                    child: _buildSection('🏛️ History', university.history)),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                    child: _buildSection(
                        '✅ Accreditation', university.accreditation)),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 500),
                    child: _buildSection('🏆 Rankings', university.ranking)),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 600),
                    child: _buildFaculties()),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 700),
                    child: _buildFeesSection()),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 800),
                    child: _buildBenefits()),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 900),
                    child: _buildTestimonials()),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 1000),
                    child: _buildApplySection(context)),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: _color,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(university.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // Dark overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.2)
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        university.category,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      university.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          university.location,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppTheme.glassCard(
        padding: const EdgeInsets.symmetric(vertical: 20),
        borderColor: _color.withOpacity(0.3),
        borderRadius: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statItem(
                '${university.sriLankanStudents}+', 'SL Students', _color),
            _vDivider(),
            _statItem(
                '\$${university.tuitionFeeUSD.toInt()}', 'Tuition/yr', _color),
            _vDivider(),
            _statItem(
                '\$${university.hostelFeeUSD.toInt()}', 'Hostel/yr', _color),
            _vDivider(),
            _statItem(
                university.degreeDuration.split('(').last.replaceAll(')', ''),
                'Duration',
                _color),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: context.dc.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _vDivider() => Container(
      width: 1, height: 36, color: context.dc.textMuted.withOpacity(0.2));

  Widget _buildBadges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (university.noIeltsRequired)
            _badge('✅ No IELTS Required', const Color(0xFF00E676)),
          if (university.hasEnglishMedium)
            _badge('🗣️ English Medium', AppColors.secondary),
          _badge('✈️ Airport Pickup', AppColors.primary),
          _badge('🏠 Hostel Available', AppColors.neonPurple),
          _badge('🎓 Visa Support', AppColors.tertiary),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.dc.textMain,
            ),
          ),
          const SizedBox(height: 12),
          AppTheme.glassCard(
            padding: const EdgeInsets.all(20),
            borderRadius: 16,
            child: Text(
              content,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: context.dc.textMuted,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaculties() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📚 Faculties & Programs',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.dc.textMain,
            ),
          ),
          const SizedBox(height: 12),
          ...university.faculties.map((f) => AppTheme.glassCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderRadius: 14,
                borderColor: _color.withOpacity(0.2),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: _color.withOpacity(0.5), blurRadius: 6)
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      f,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: context.dc.textMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFeesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💰 Tuition & Costs',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.dc.textMain,
            ),
          ),
          const SizedBox(height: 12),
          AppTheme.glassCard(
            padding: EdgeInsets.zero,
            borderRadius: 16,
            borderColor: _color.withOpacity(0.3),
            child: Column(
              children: [
                _feeRow('📘 Tuition Fee',
                    '\$${university.tuitionFeeUSD.toInt()} / year', true),
                _feeRow('🏠 Hostel Fee',
                    '\$${university.hostelFeeUSD.toInt()} / year', false),
                _feeRow('🏥 Insurance',
                    '\$${university.insuranceFeeUSD.toInt()} / year', true),
                _feeRow('🛂 Visa Fee',
                    '\$${university.visaFeeUSD.toInt()} (one-time)', false),
                _feeRow(
                    '💵 Total/Year (est.)',
                    '\$${(university.tuitionFeeUSD + university.hostelFeeUSD + university.insuranceFeeUSD).toInt()}',
                    true,
                    isTotal: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.tertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.tertiary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.tertiary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payment plans & installment schemes available. Contact us for details.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.tertiary,
                      fontWeight: FontWeight.w600,
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

  Widget _feeRow(String label, String value, bool isShaded,
      {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isShaded ? _color.withOpacity(0.08) : Colors.transparent,
        borderRadius: isTotal
            ? const BorderRadius.vertical(bottom: Radius.circular(16))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isTotal ? context.dc.textMain : context.dc.textMuted,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isTotal ? _color : context.dc.textMain,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⭐ Benefits & Support',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.dc.textMain,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemCount: university.benefits.length,
            itemBuilder: (context, i) => AppTheme.glassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              borderRadius: 12,
              borderColor: _color.withOpacity(0.2),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: _color, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      university.benefits[i],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: context.dc.textMain,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonials() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💬 Student Testimonials',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.dc.textMain,
            ),
          ),
          const SizedBox(height: 12),
          ...university.testimonials.map((t) {
            final parts = t.split(' - ');
            return AppTheme.glassCard(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(20),
              borderRadius: 16,
              borderColor: _color.withOpacity(0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote_rounded,
                      color: AppColors.tertiary, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    parts.first,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: context.dc.textMain.withOpacity(0.9),
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (parts.length > 1) ...[
                    const SizedBox(height: 12),
                    Text(
                      '— ${parts.last}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: _color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildApplySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _color,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 10,
                shadowColor: _color.withOpacity(0.4),
              ),
              onPressed: () {},
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              label: Text(
                'Apply to ${university.shortName}',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _launchWhatsApp(context),
              icon: const FaIcon(FontAwesomeIcons.whatsapp,
                  color: Color(0xFF25D366), size: 20),
              label: Text(
                'Ask About ${university.shortName} on WhatsApp',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: const Color(0xFF25D366),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

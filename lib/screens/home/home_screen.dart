import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import '../../models/university_model.dart';
import '../universities/university_detail_screen.dart';
import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _carouselIndex = 0;

  final List<Map<String, dynamic>> _heroSlides = [
    {
      'title': 'Study Medicine\nin Armenia 🏥',
      'subtitle': 'WHO Listed Universities • English Medium • No IELTS',
      'color': AppColors.primary,
      'imageUrl': 'assets/images/home_medical.png',
    },
    {
      'title': 'World-Class\nEngineering 🏗️',
      'subtitle': 'Top Universities • Affordable Fees • Global Recognition',
      'color': AppColors.secondary,
      'imageUrl': 'assets/images/home_engineering.png',
    },
    {
      'title': 'IT & Technology\nDegrees 💻',
      'subtitle': 'US-Accredited Programs • Silicon Valley Connections',
      'color': AppColors.neonPurple,
      'imageUrl': 'assets/images/home_it.png',
    },
    {
      'title': 'Scholarships\nAvailable 🎓',
      'subtitle': 'Special Discounts for Sri Lankan Students',
      'color': AppColors.tertiary,
      'imageUrl': 'assets/images/home_scholarships.png',
    },
  ];

  final List<Map<String, dynamic>> _whyArmeniaPoints = [
    {
      'icon': Icons.medical_services_rounded,
      'title': 'WHO Listed',
      'desc': 'Globally recognized',
      'color': AppColors.primary
    },
    {
      'icon': Icons.language_rounded,
      'title': 'English',
      'desc': 'No language barrier',
      'color': AppColors.secondary
    },
    {
      'icon': Icons.attach_money_rounded,
      'title': 'Affordable',
      'desc': 'Low living cost',
      'color': AppColors.tertiary
    },
    {
      'icon': Icons.verified_rounded,
      'title': 'No IELTS',
      'desc': 'Easy admission',
      'color': const Color(0xFF00E676)
    },
    {
      'icon': Icons.flight_takeoff_rounded,
      'title': 'Easy Visa',
      'desc': 'Full support',
      'color': AppColors.neonPurple
    },
    {
      'icon': Icons.groups_rounded,
      'title': 'Community',
      'desc': 'Lankan students',
      'color': const Color(0xFFFF3D00)
    },
  ];

  void _launchWhatsApp() async {
    final uri = Uri.parse(
        'https://wa.me/94778200056?text=Hello%2C%20I%20am%20interested%20in%20studying%20in%20Armenia');
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchFacebook() async {
    final fbAppUri = Uri.parse(
        'fb://facewebmodal/f?href=https://www.facebook.com/share/17kEMmU4fu/');
    final fbWebUri = Uri.parse('https://www.facebook.com/share/17kEMmU4fu/');
    if (await canLaunchUrl(fbAppUri)) {
      launchUrl(fbAppUri, mode: LaunchMode.externalApplication);
    } else {
      launchUrl(fbWebUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: _buildHeroCarousel()),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: _buildQuickActions()),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 300),
                    child: _buildAnnouncements()),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                    child: _buildWhyArmenia()),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 500),
                    child: _buildWelcomeMessage()),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 600),
                    child: _buildFeaturedUniversities()),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 700),
                    child: _buildWhatsAppQR()),
                FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 800),
                    child: _buildArmeniaFacts()),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 70,
      floating: true,
      pinned: true,
      backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMiniFlag(),
            const SizedBox(width: 10),
            Text(
              'Study Armenia 🇱🇰',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.dc.textMain,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.secondary),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
          tooltip: 'Notifications',
        ),
      ],
    );
  }

  Widget _buildMiniFlag() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 24,
        height: 16,
        child: Column(
          children: [
            Expanded(child: Container(color: AppColors.armeniaRed)),
            Expanded(child: Container(color: AppColors.armeniaBlue)),
            Expanded(child: Container(color: AppColors.armeniaOrange)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCarousel() {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 220,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (index, _) {
              setState(() => _carouselIndex = index);
            },
          ),
          items: _heroSlides.map((slide) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(slide['imageUrl'] as String),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (slide['color'] as Color).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          slide['title'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          slide['subtitle'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: slide['color'] as Color,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => widget.onNavigate?.call(2),
                          child: Text(
                            'Apply Now →',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        AnimatedSmoothIndicator(
          activeIndex: _carouselIndex,
          count: _heroSlides.length,
          effect: ExpandingDotsEffect(
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: AppColors.primary,
            dotColor: context.dc.surfaceHighlight,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.dc.textMain),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: FontAwesomeIcons.whatsapp,
                  label: 'Chat with\nCounselor',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF25D366), Color(0xFF128C7E)]),
                  onTap: _launchWhatsApp,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: FontAwesomeIcons.facebookF,
                  label: 'Our\nFacebook',
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1877F2), Color(0xFF0A4DA8)]),
                  onTap: _launchFacebook,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.school_rounded,
                  label: 'Apply\nNow',
                  gradient: AppColors.techGradient,
                  onTap: () => widget.onNavigate?.call(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required dynamic icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            icon is IconData
                ? Icon(icon, color: Colors.white, size: 26)
                : FaIcon(icon as IconData, color: Colors.white, size: 24),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncements() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📢 Announcements',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.dc.textMain),
          ),
          const SizedBox(height: 16),
          FutureBuilder<QuerySnapshot>(
            future: FirestoreService().getAnnouncementsStream().first,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return AppTheme.glassCard(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text('No announcements right now.',
                        style: GoogleFonts.plusJakartaSans(
                            color: context.dc.textMuted)),
                  ),
                );
              }
              final docs = snapshot.data!.docs;
              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _announcementCard(data);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _announcementCard(Map<String, dynamic> item) {
    return AppTheme.glassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: AppColors.primary.withOpacity(0.3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 8,
                  )
                ]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.dc.textMain,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['body'] ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: context.dc.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyArmenia() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🇦🇲 Why Study in Armenia?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.dc.textMain,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _whyArmeniaPoints.length,
            itemBuilder: (context, index) {
              final point = _whyArmeniaPoints[index];
              return AppTheme.glassCard(
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                borderColor: (point['color'] as Color).withOpacity(0.2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (point['color'] as Color).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        point['icon'] as IconData,
                        color: point['color'] as Color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      point['title'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: context.dc.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      point['desc'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        color: context.dc.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: AppTheme.glassCard(
        padding: const EdgeInsets.all(24),
        borderColor: AppColors.secondary.withOpacity(0.3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildMiniFlag(),
                const SizedBox(width: 12),
                Text(
                  'Official Message',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '"Welcome to the Representative Office & Cultural Center of Armenia in Sri Lanka. We are dedicated to building a strong bridge between our two nations through education, culture, and friendship. Armenia offers world-class education at affordable costs, and we are here to guide every Sri Lankan student and family through this transformative journey."',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: context.dc.textMain.withOpacity(0.9),
                height: 1.7,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '— Representative Office, Armenia in Sri Lanka',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: context.dc.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedUniversities() {
    final universities = UniversityData.getUniversities().take(3).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🎓 Featured Universities',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.dc.textMain,
                ),
              ),
              Text(
                'See All',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...universities.map((u) => _miniUniversityCard(u)),
        ],
      ),
    );
  }

  Widget _miniUniversityCard(University u) {
    final categoryColors = {
      'Medical': AppColors.primary,
      'Engineering': AppColors.secondary,
      'IT & Business': AppColors.neonPurple,
      'Architecture': const Color(0xFFE65100),
      'Tourism & Hospitality': const Color(0xFF00695C),
    };
    final color = categoryColors[u.category] ?? AppColors.primary;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UniversityDetailScreen(university: u),
          ),
        );
      },
      child: AppTheme.glassCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        borderColor: color.withOpacity(0.2),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [color, color.withOpacity(0.6)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  u.shortName.substring(0, 2),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u.shortName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: context.dc.textMain,
                    ),
                  ),
                  Text(
                    u.category,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${u.sriLankanStudents} Sri Lankan Students • \$${u.tuitionFeeUSD.toInt()}/yr',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: context.dc.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppQR() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: AppTheme.glassCard(
        padding: const EdgeInsets.all(24),
        borderColor: const Color(0xFF25D366).withOpacity(0.3),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.whatsapp,
                          color: Color(0xFF25D366), size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'WhatsApp Us',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: context.dc.textMain,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Scan the QR code or tap the button to chat with our counselor directly.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: context.dc.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _launchWhatsApp,
                    icon: const FaIcon(FontAwesomeIcons.whatsapp,
                        size: 18, color: Colors.white),
                    label: Text(
                      'Chat Now',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: 'https://wa.me/94702821035',
                version: QrVersions.auto,
                size: 90,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArmeniaFacts() {
    final facts = [
      {
        'icon': '🏔️',
        'fact': 'Land of\nMount Ararat',
        'sub': 'Stunning Scenery'
      },
      {
        'icon': '❄️',
        'fact': 'Experience\nReal Snow',
        'sub': 'First time for many!'
      },
      {
        'icon': '🏛️',
        'fact': '2,800+\nYears Old',
        'sub': 'Ancient Civilization'
      },
      {'icon': '🌍', 'fact': '120+\nCountries', 'sub': 'Degree Recognized'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌟 Armenia Facts',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: context.dc.textMain,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: facts.map((f) {
              return Expanded(
                child: AppTheme.glassCard(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(12),
                  borderRadius: 16,
                  child: Column(
                    children: [
                      Text(f['icon']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 8),
                      Text(
                        f['fact']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: context.dc.textMain,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        f['sub']!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8,
                          color: context.dc.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

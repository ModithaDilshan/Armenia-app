import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import '../../models/university_model.dart';
import 'university_detail_screen.dart';

class UniversitiesScreen extends StatefulWidget {
  const UniversitiesScreen({super.key});

  @override
  State<UniversitiesScreen> createState() => _UniversitiesScreenState();
}

class _UniversitiesScreenState extends State<UniversitiesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final List<String> _categories = [
    'All',
    'Medical',
    'Engineering',
    'IT & Business',
    'Architecture',
    'Tourism & Hospitality',
  ];

  List<University> get _filteredUniversities {
    final all = UniversityData.getUniversities();
    return all.where((university) {
      final matchesCategory = _selectedCategory == 'All' ||
          university.category == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          university.name.toLowerCase().contains(query) ||
          university.shortName.toLowerCase().contains(query) ||
          university.category.toLowerCase().contains(query) ||
          university.faculties.any(
            (faculty) => faculty.toLowerCase().contains(query),
          );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  final Map<String, Color> _categoryColors = {
    'Medical': AppColors.primary,
    'Engineering': AppColors.secondary,
    'IT & Business': AppColors.neonPurple,
    'Architecture': const Color(0xFFE65100),
    'Tourism & Hospitality': const Color(0xFF00695C),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text(
          '🎓 Universities',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: context.dc.textMain,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _buildCategoryFilter(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: GoogleFonts.plusJakartaSans(color: context.dc.textMain),
              decoration: InputDecoration(
                hintText: 'Search universities or programs',
                hintStyle:
                    GoogleFonts.plusJakartaSans(color: context.dc.textMuted),
                prefixIcon:
                    Icon(Icons.search_rounded, color: context.dc.textMuted),
                filled: true,
                fillColor: context.dc.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          _buildStatsBar(),
          Expanded(
            child: _filteredUniversities.isEmpty
                ? Center(
                    child: Text(
                    'No universities match your search.',
                    style: GoogleFonts.plusJakartaSans(
                        color: context.dc.textMuted),
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredUniversities.length,
                    itemBuilder: (context, index) {
                      return FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        delay: Duration(milliseconds: index * 60),
                        child:
                            _buildUniversityCard(_filteredUniversities[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          final color = cat == 'All'
              ? AppColors.tertiary
              : (_categoryColors[cat] ?? AppColors.primary);
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? color : context.dc.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? color : color.withOpacity(0.3),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ]
                    : [],
              ),
              child: Text(
                cat,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : context.dc.textMuted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsBar() {
    final total = _filteredUniversities.length;
    final totalStudents = _filteredUniversities.fold<int>(
        0, (sum, u) => sum + u.sriLankanStudents);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: AppTheme.glassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        borderColor: AppColors.primary.withOpacity(0.3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('$total', 'Universities', AppColors.primary),
            _divider(),
            _statItem(
                '$totalStudents+', 'Sri Lankan Students', AppColors.secondary),
            _divider(),
            _statItem('5', 'Categories', AppColors.tertiary),
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
            fontSize: 18,
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

  Widget _divider() {
    return Container(
        width: 1, height: 36, color: context.dc.textMuted.withOpacity(0.2));
  }

  Widget _buildUniversityCard(University u) {
    final color = _categoryColors[u.category] ?? AppColors.primary;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UniversityDetailScreen(university: u),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: context.dc.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Banner
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                image: DecorationImage(
                  image: AssetImage(u.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Dark overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            u.category,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          u.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _infoChip(Icons.location_on_rounded, u.location, color),
                      const SizedBox(width: 12),
                      _infoChip(Icons.timer_rounded,
                          u.degreeDuration.split('|').first.trim(), color),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _featureBadge('No IELTS', u.noIeltsRequired,
                          const Color(0xFF00E676)),
                      const SizedBox(width: 8),
                      _featureBadge('English Medium', u.hasEnglishMedium,
                          AppColors.secondary),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _feeItem('Tuition/yr',
                              '\$${u.tuitionFeeUSD.toInt()}', color)),
                      Expanded(
                          child: _feeItem('Hostel/yr',
                              '\$${u.hostelFeeUSD.toInt()}', color)),
                      Expanded(
                          child: _feeItem(
                              'SL Students', '${u.sriLankanStudents}+', color)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  UniversityDetailScreen(university: u)),
                        );
                      },
                      child: Text(
                        'View Details & Apply',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Colors.white,
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

  Widget _infoChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: context.dc.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _featureBadge(String label, bool active, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? color.withOpacity(0.4) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: active ? color : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: active ? color : Colors.grey,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _feeItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
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
}

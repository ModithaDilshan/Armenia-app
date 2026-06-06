import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import '../../services/firestore_service.dart';

class ParentNewsScreen extends StatelessWidget {
  const ParentNewsScreen({super.key});

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Academic': return AppColors.neonPurple;
      case 'Visa': return const Color(0xFF00E676);
      case 'Health': return AppColors.primary;
      case 'Finance': return const Color(0xFFFF9800);
      case 'Student Life': return AppColors.secondary;
      default: return AppColors.tertiary;
    }
  }

  void _showArticle(BuildContext context, Map<String, dynamic> article) {
    final color = _tagColor(article['tag'] as String? ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(color: context.dc.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
          padding: const EdgeInsets.all(24),
          child: ListView(controller: controller, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 20),
            Text(article['emoji'] as String? ?? '📰', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(article['tag'] as String? ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            ),
            const SizedBox(height: 12),
            Text(article['title'] as String? ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 19, fontWeight: FontWeight.w800, color: context.dc.textMain, height: 1.4)),
            const SizedBox(height: 8),
            Text(article['date'] as String? ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: context.dc.textMuted)),
            const Divider(color: Colors.white10, height: 32),
            Text(article['body'] as String? ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 15, color: context.dc.textMuted, height: 1.7)),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text('📰 Armenia News', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: context.dc.textMain)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: context.dc.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('news_articles').orderBy('createdAt', descending: true).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('📭', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                Text('No news articles yet', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: context.dc.textMuted)),
              ]),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final article = docs[i].data() as Map<String, dynamic>;
              final color = _tagColor(article['tag'] as String? ?? '');
              return FadeInUp(
                duration: const Duration(milliseconds: 400),
                delay: Duration(milliseconds: i * 80),
                child: GestureDetector(
                  onTap: () => _showArticle(context, article),
                  child: AppTheme.glassCard(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    borderRadius: 20,
                    borderColor: color.withOpacity(0.25),
                    child: Row(children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
                        child: Center(child: Text(article['emoji'] as String? ?? '📰', style: const TextStyle(fontSize: 26))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                            child: Text(article['tag'] as String? ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
                          ),
                          const Spacer(),
                          Text(article['date'] as String? ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: context.dc.textMuted)),
                        ]),
                        const SizedBox(height: 6),
                        Text(article['title'] as String? ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: context.dc.textMain, height: 1.4)),
                        const SizedBox(height: 6),
                        Text('Tap to read full article →',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                      ])),
                    ]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

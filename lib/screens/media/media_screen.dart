import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      appBar: AppBar(
        backgroundColor: context.dc.surfaceHighlight.withOpacity(0.9),
        title: Text(
          '📸 Daily Updates',
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
            Tab(text: 'All'),
            Tab(text: 'Photos'),
            Tab(text: 'Videos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeed(),
          _buildPhotoGrid(),
          _buildVideoPlaceholder(context),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().getMediaPostsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No media posts yet.',
                style:
                    GoogleFonts.plusJakartaSans(color: context.dc.textMuted)),
          );
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: Duration(milliseconds: index * 60),
              child: _buildPostCard(data),
            );
          },
        );
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    Color tagColor;
    final tag = post['tag'] ?? '';
    if (tag == 'Student Life') {
      tagColor = AppColors.secondary;
    } else if (tag == 'Academic') {
      tagColor = AppColors.primary;
    } else if (tag == 'Graduation') {
      tagColor = AppColors.tertiary;
    } else if (tag == 'Community') {
      tagColor = const Color(0xFF00E676);
    } else if (tag == 'Tourism') {
      tagColor = AppColors.neonPurple;
    } else {
      tagColor = AppColors.primary;
    }

    return AppTheme.glassCard(
      margin: const EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.zero,
      borderColor: tagColor.withOpacity(0.3),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder with gradient
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: post.containsKey('imageUrl')
                  ? null
                  : LinearGradient(
                      colors: [tagColor.withOpacity(0.8), tagColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              image: post.containsKey('imageUrl')
                  ? DecorationImage(
                      image: AssetImage(post['imageUrl']),
                      fit: BoxFit.cover,
                    )
                  : null,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              children: [
                if (!post.containsKey('imageUrl'))
                  Center(
                    child: Text(
                      post['emoji'] ?? '📸',
                      style: const TextStyle(fontSize: 90),
                    ),
                  ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: tagColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['title'] ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.dc.textMain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post['desc'] ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: context.dc.textMuted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Spacer(),
                    _interactionBtn(
                        Icons.favorite_border_rounded, '0', AppColors.primary),
                    const SizedBox(width: 20),
                    _interactionBtn(Icons.chat_bubble_outline_rounded, '0',
                        AppColors.secondary),
                    const SizedBox(width: 20),
                    _interactionBtn(
                        Icons.share_rounded, 'Share', AppColors.tertiary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _interactionBtn(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
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

  Widget _buildPhotoGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().getMediaPostsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No media available',
                style:
                    GoogleFonts.plusJakartaSans(color: context.dc.textMuted)),
          );
        }

        final docs = snapshot.data!.docs;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final post = docs[index].data() as Map<String, dynamic>;
            Color tagColor;
            final tag = post['tag'] ?? '';
            if (tag == 'Student Life') {
              tagColor = AppColors.secondary;
            } else if (tag == 'Academic') {
              tagColor = AppColors.primary;
            } else if (tag == 'Graduation') {
              tagColor = AppColors.tertiary;
            } else if (tag == 'Community') {
              tagColor = const Color(0xFF00E676);
            } else if (tag == 'Tourism') {
              tagColor = AppColors.neonPurple;
            } else {
              tagColor = AppColors.primary;
            }

            return FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: Duration(milliseconds: index * 50),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tagColor.withOpacity(0.7),
                      tagColor.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tagColor.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                        color: tagColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        post['emoji'] ?? '📸',
                        style: const TextStyle(fontSize: 60),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20)),
                        ),
                        child: Text(
                          post['title'] ?? '',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVideoPlaceholder(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 800),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: context.dc.surfaceHighlight.withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4), width: 1.5),
              ),
              child: const Icon(Icons.play_circle_outline_rounded,
                  color: AppColors.primary, size: 70),
            ),
            const SizedBox(height: 24),
            Text(
              'Videos Coming Soon!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: context.dc.textMain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Student life videos, university tours\nand testimonials will be added here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: context.dc.textMuted,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

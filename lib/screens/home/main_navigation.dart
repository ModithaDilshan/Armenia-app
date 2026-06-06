import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import 'home_screen.dart';
import '../universities/universities_screen.dart';
import '../apply/apply_screen.dart';
import '../media/media_screen.dart';
import '../parent_portal/parent_portal_screen.dart';
import '../settings/settings_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../../services/auth_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final isAdmin = await AuthService().isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _isLoading = false;
      });
    }
  }

  Widget _buildScreen(int index) {
    // Only build the currently selected screen (prevents all screens loading at once)
    switch (index) {
      case 0: return const HomeScreen();
      case 1: return const UniversitiesScreen();
      case 2: return const ApplyScreen();
      case 3: return const MediaScreen();
      case 4: return const ParentPortalScreen();
      case 5: return const SettingsScreen();
      case 6: return _isAdmin ? const AdminDashboardScreen() : const HomeScreen();
      default: return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.dc.background,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final List<Widget> navItems = [
      _buildNavItem(context, Icons.home_rounded, 0),
      _buildNavItem(context, Icons.account_balance_rounded, 1),
      _buildNavItem(context, Icons.post_add_rounded, 2),
      _buildNavItem(context, Icons.photo_library_rounded, 3),
      _buildNavItem(context, Icons.family_restroom_rounded, 4),
      _buildNavItem(context, Icons.settings_rounded, 5),
      if (_isAdmin) _buildNavItem(context, Icons.admin_panel_settings_rounded, 6),
    ];

    return Scaffold(
      backgroundColor: context.dc.background,
      body: _buildScreen(_currentIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          color: context.dc.surface,
          buttonBackgroundColor: AppColors.primary,
          height: 60,
          index: _currentIndex,
          animationDuration: const Duration(milliseconds: 400),
          animationCurve: Curves.easeInOutBack,
          items: navItems,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index) {
    return Icon(
      icon,
      color: _currentIndex == index ? context.dc.textMain : context.dc.textMuted,
      size: 26,
    );
  }
}

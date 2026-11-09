import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/dynamic_colors.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AuthGate(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dc.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0F1A), Color(0xFF05050A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Background ambient glows
            Positioned(
              top: -100,
              right: -50,
              child:
                  _buildAmbientGlow(AppColors.primary.withOpacity(0.15), 300),
            ),
            Positioned(
              bottom: -50,
              left: -100,
              child: _buildAmbientGlow(
                  AppColors.neonPurple.withOpacity(0.15), 300),
            ),

            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: _buildGlassFlag(),
                  ),
                  const SizedBox(height: 40),
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      'Study Armenia',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: context.dc.textMain,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 600),
                    child: Text(
                      'YOUR MEDICAL GATEWAY 🇱🇰',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Loading
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeIn(
                delay: const Duration(milliseconds: 1000),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _glowAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.dc.surfaceHighlight,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.5)),
                        ),
                        child: const CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildGlassFlag() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/firebase/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_navigation.dart';
import 'screens/splash/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/preferences_service.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch Flutter framework errors — prevent silent crash
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase failed to initialize — show error on screen
    runApp(_ErrorApp(error: 'Firebase init failed:\n$e'));
    return;
  }

  // Seed initial data — safe, errors are ignored
  final isDark = await PreferencesService.getDarkMode();
  if (FirebaseAuth.instance.currentUser == null) {
    await NotificationService.unsubscribeForLogout();
  } else {
    await NotificationService.initialize();
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDark: isDark),
      child: const MyApp(),
    ),
  );
}

/// Shown when app fails to start — displays error for debugging
class _ErrorApp extends StatelessWidget {
  final String error;
  const _ErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0D0D1A),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 70),
                const SizedBox(height: 20),
                const Text('App Startup Error',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: SelectableText(
                    error,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 13, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please share this error message\nwith the developer.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom scroll behavior that allows mouse drag scrolling on web
/// AND prevents the mouse_tracker assertion caused by animated list items
/// being disposed while the mouse hovers over them.
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.foregroundMessage.addListener(_showNotification);
  }

  void _showNotification() {
    final notification =
        NotificationService.foregroundMessage.value?.notification;
    if (notification == null) return;
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          notification.body == null
              ? notification.title ?? 'New notification'
              : '${notification.title ?? 'Update'}\n${notification.body}',
        ),
      ),
    );
  }

  @override
  void dispose() {
    NotificationService.foregroundMessage.removeListener(_showNotification);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'Study Armenia LK',
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      scrollBehavior: AppScrollBehavior(),
      home: const SplashScreen(),
    );
  }
}

/// Auth gate — shows Login if not signed in, MainNavigation if signed in
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D0D1A),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFD90012)),
            ),
          );
        }
        // User is logged in
        if (snapshot.hasData) {
          return const MainNavigation();
        }
        // Not logged in — show login
        return const LoginScreen();
      },
    );
  }
}

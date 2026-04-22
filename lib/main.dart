import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'features/auth/login_screen.dart';
import 'features/auth/auth_success_screen.dart';
import 'features/nagbar/app_shell.dart';
import 'core/currency_provider.dart';
import 'core/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load saved preferences & Auth
  await Future.wait([
    CurrencyProvider().loadPreferences(),
    AuthService().init(),
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _determineHome() {
    // Check if this is a Google OAuth callback (URL contains accessToken param)
    final uri = Uri.parse(html.window.location.href);
    if (uri.queryParameters.containsKey('accessToken')) {
      return const AuthSuccessScreen();
    }

    // Otherwise use saved session to decide starting screen
    return AuthService().token != null
        ? AppShell(key: AppShell.appShellKey)
        : const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trend Reversal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE0543D)),
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      home: _determineHome(),
      routes: {
        '/home': (context) => AppShell(key: AppShell.appShellKey),
        '/login': (context) => const LoginScreen(),
        '/auth/success': (context) => const AuthSuccessScreen(),
      },
    );
  }
}

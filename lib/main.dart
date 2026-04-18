import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/auth/login_screen.dart';
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
      // Start from Login screen
      // Start from Home if already logged in, otherwise Login
      home: AuthService().token != null ? const AppShell() : const LoginScreen(),
      routes: {
        '/home': (context) => const AppShell(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

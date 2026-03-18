import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/setting/setting_screen.dart';
import 'features/portfolio/portfolioremove_screen.dart';
import 'features/chat/historychat_screen.dart';
import 'features/chat/chat_screen.dart';
// import 'features/portfolio/portfolio_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      // start app directly on PortfolioRemoveScreen for testing/demo
      home: const ChatScreen(),
    );
  }
}



import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../../core/auth_service.dart';

/// This screen handles the redirect from Google OAuth.
/// The backend redirects to /auth/success?accessToken=xxx&refreshToken=xxx
class AuthSuccessScreen extends StatefulWidget {
  const AuthSuccessScreen({super.key});

  @override
  State<AuthSuccessScreen> createState() => _AuthSuccessScreenState();
}

class _AuthSuccessScreenState extends State<AuthSuccessScreen> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    try {
      // Parse the URL parameters from the current page
      final uri = Uri.parse(html.window.location.href);
      final accessToken = uri.queryParameters['accessToken'];

      if (accessToken != null && accessToken.isNotEmpty) {
        // Save the session from the Google OAuth tokens
        await AuthService().loginWithTokens(accessToken);

        if (mounted) {
          // Navigate to home, removing all previous routes
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else {
        // No token found — redirect to login with error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google Sign-in ล้มเหลว กรุณาลองอีกครั้ง')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFE0543D)),
            SizedBox(height: 16),
            Text(
              'กำลังเข้าสู่ระบบด้วย Google...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

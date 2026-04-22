import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import '../../core/auth_service.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _rememberDevice = false;
  bool _obscurePassword = true;
  bool _loading = false;
  late final TapGestureRecognizer _registerRecognizer;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    _registerRecognizer = TapGestureRecognizer()..onTap = () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
    };
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final pass  = _passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณากรอก Email และ Password'),
          backgroundColor: const Color(0xFFE0543D),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final ok = await AuthService().login(email, pass);
    if (mounted) setState(() => _loading = false);

    if (ok) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('เข้าสู่ระบบไม่สำเร็จ กรุณาตรวจสอบข้อมูล'),
            backgroundColor: const Color(0xFFE0543D),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _registerRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),
                // Email Address Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Address',
                      style: GoogleFonts.golosText(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // gradient border (white top to black bottom) with dark interior
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFF000000),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _emailFocusNode.hasFocus
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFE4472B).withValues(alpha: 0.3),
                                  offset: Offset(0, 0),
                                  blurRadius: 0,
                                  spreadRadius: 3,
                                ),
                              ]
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(0.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF191919),
                            borderRadius: BorderRadius.circular(7.5),
                          ),
                          child: TextField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            style: GoogleFonts.golosText(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFFFFFFF),
                              height: 1.125,
                            ),
                            decoration: InputDecoration(
                              hintText: 'you@example.com',
                              hintStyle: GoogleFonts.golosText(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF999999),
                                height: 1.125,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 43),
                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password',
                      style: GoogleFonts.golosText(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // gradient border (white top to black bottom) with dark interior
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFF000000),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _passwordFocusNode.hasFocus
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFE4472B).withValues(alpha: 0.3),
                                  offset: Offset(0, 0),
                                  blurRadius: 0,
                                  spreadRadius: 3,
                                ),
                              ]
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(0.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF191919),
                            borderRadius: BorderRadius.circular(7.5),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.golosText(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFFFFFFF),
                              height: 1.125,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SvgPicture.asset(
                                    'assets/icons/eye_icon.svg',
                                    width: 13,
                                    height: 8,
                                    colorFilter: ColorFilter.mode(
                                      _obscurePassword ? Colors.white : Colors.black,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 175),
                // Remember this device checkbox
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _rememberDevice = !_rememberDevice;
                        });
                      },
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _rememberDevice
                                ? const Color(0xFFE0543D)
                                : const Color(0xFF595959),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(2),
                          color: _rememberDevice
                              ? const Color(0xFFE0543D)
                              : Colors.transparent,
                        ),
                        child: _rememberDevice
                            ? const Icon(
                                Icons.check,
                                size: 12,
                                color: Color(0xFFFFFFFF),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remember this device',
                      style: GoogleFonts.golosText(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFFFFFFF),
                        height: 1.125,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Sign in button
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0543D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFF050505),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Sign in',
                            style: GoogleFonts.golosText(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF050505),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 33),
                // Agreement text
                Center(
                  child: RichText(
                    softWrap: false,
                    text: TextSpan(
                      text: 'By logging in, you agree to ',
                      style: GoogleFonts.golosText(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF999999),
                      ),
                      children: [
                        TextSpan(
                          text: 'register an account',
                          style: GoogleFonts.golosText(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFE0543D),
                          ),
                          recognizer: _registerRecognizer,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 31),
                // Divider with "or"
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.0),
                      child: Text(
                        'or',
                        style: GoogleFonts.golosText(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF595959),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                // Sign up with Google button
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: () {
                      html.window.localStorage['flutter_app_url'] = html.window.location.origin;
                      html.window.open(AuthService().googleAuthUrl, '_self');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF191919),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Color(0xFF595959),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sign up with Google',
                          style: GoogleFonts.golosText(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 15),
                        SvgPicture.asset(
                          'assets/icons/google_logo.svg',
                          width: 24,
                          height: 25,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

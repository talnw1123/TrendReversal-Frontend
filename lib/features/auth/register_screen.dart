import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../../core/auth_service.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _firstNameFocusNode.addListener(() {
      setState(() {});
    });
    _lastNameFocusNode.addListener(() {
      setState(() {});
    });
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
    _confirmPasswordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบทุกช่อง')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน กรุณาตรวจสอบอีกครั้ง')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร')),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await AuthService().register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    if (mounted) setState(() => _loading = false);

    if (result.pendingId != null) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              email: email,
              pendingId: result.pendingId!,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage ?? 'การสมัครสมาชิกล้มเหลว')),
        );
      }
    }
  }

  void _handleGoogleSignIn() {
    // Save the current Flutter app URL so the backend can redirect back here after OAuth
    html.window.localStorage['flutter_app_url'] = html.window.location.origin;
    html.window.open(AuthService().googleAuthUrl, '_self');
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
                const SizedBox(height: 22),
                // Back button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/icons/back_icon.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                // First Name and Last Name Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'First Name',
                            style: GoogleFonts.golosText(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF999999),
                            ),
                          ),
                          const SizedBox(height: 6),
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
                              boxShadow: _firstNameFocusNode.hasFocus
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
                                  controller: _firstNameController,
                                  focusNode: _firstNameFocusNode,
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
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Last Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last Name',
                            style: GoogleFonts.golosText(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF999999),
                            ),
                          ),
                          const SizedBox(height: 6),
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
                              boxShadow: _lastNameFocusNode.hasFocus
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
                                  controller: _lastNameController,
                                  focusNode: _lastNameFocusNode,
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
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 43),
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
                            keyboardType: TextInputType.emailAddress,
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
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Text(
                      'At least 8 characters, with numbers and symbols.',
                      style: GoogleFonts.golosText(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF999999),
                        height: 1.125,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 45),
                // Confirm New Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Confirm Password',
                      style: GoogleFonts.golosText(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 6),
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
                        boxShadow: _confirmPasswordFocusNode.hasFocus
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
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocusNode,
                            obscureText: _obscureConfirmPassword,
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
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SvgPicture.asset(
                                    'assets/icons/eye_icon.svg',
                                    width: 13,
                                    height: 8,
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
                const SizedBox(height: 57),
                // Create Account button
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleRegister,
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
                            'Create Account',
                            style: GoogleFonts.golosText(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF050505),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 33),
                // Terms of service text
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'By logging in, you agree to follow our ',
                      style: GoogleFonts.golosText(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF999999),
                      ),
                      children: [
                        TextSpan(
                          text: 'terms of service',
                          style: GoogleFonts.golosText(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFE0543D),
                          ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                Container(
                  width: double.infinity,
                  height: 49,
                  decoration: BoxDecoration(
                    color: const Color(0xFF191919),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF595959),
                      width: 0.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.50),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleGoogleSignIn,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sign up with Google',
                              style: GoogleFonts.golosText(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFFFFFFF),
                                height: 1.125,
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

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late FocusNode _passwordFocusNode;
  late FocusNode _newPasswordFocusNode;
  late FocusNode _confirmPasswordFocusNode;

  bool _obscurePassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    _newPasswordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 22),
                      // Header: back button + title
                      Row(
                        children: [
                          _BackButton(onTap: () => Navigator.pop(context)),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Change Password',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                          // Balance spacer to keep title centred
                          const SizedBox(width: 44),
                        ],
                      ),
                      const SizedBox(height: 57),
                      // Password
                      _PasswordField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onToggle: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      const SizedBox(height: 43),
                      // New Password
                      _PasswordField(
                        label: 'New Password',
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        onToggle: () => setState(
                            () => _obscureNewPassword = !_obscureNewPassword),
                      ),
                      const SizedBox(height: 43),
                      // Confirm New Password
                      _PasswordField(
                        label: 'Confirm New Password',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        onToggle: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      const SizedBox(height: 13),
                      // Helper text
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
                ),
              ),
            ),
            // Confirm button pinned at bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 16, 40, 32),
              child: SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle change password
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0543D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.golosText(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF050505),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable back button ─────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}

// ── Reusable password field ──────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.golosText(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF999999),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF191919),
            border: Border.all(
              color: const Color(0xFF595959),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.50),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
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
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    'assets/icons/eye_icon.svg',
                    width: 13,
                    height: 8,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF999999),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

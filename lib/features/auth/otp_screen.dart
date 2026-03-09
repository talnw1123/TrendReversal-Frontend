import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final VoidCallback? onVerifySuccess;
  final VoidCallback? onResendOtp;

  const OtpScreen({
    super.key,
    required this.email,
    this.onVerifySuccess,
    this.onResendOtp,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  int _currentFocusIndex = 0;

  @override
  void initState() {
    super.initState();
    // Add listeners to focus nodes to track current focus
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {
            _currentFocusIndex = i;
          });
        }
      });
    }
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field, remove focus
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      // Move to previous field
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getOtpCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _handleContinue() {
    String otp = _getOtpCode();
    if (otp.length == 6) {
      // Handle OTP verification
      widget.onVerifySuccess?.call();
    }
  }

  void _handleResend() {
    // Clear all fields
    for (var controller in _controllers) {
      controller.clear();
    }
    // Focus first field
    _focusNodes[0].requestFocus();
    // Call resend callback
    widget.onResendOtp?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35.0),
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
              const SizedBox(height: 65),
              // Title
              Text(
                'Verify account with OTP',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(height: 9),
              // Subtitle with email
              Text(
                'We have sent 6 code to ${widget.email}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFFFFFFF).withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 35),
              // OTP Input Boxes
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate box size based on available width
                  // Total gaps: 5 gaps × 10px = 50px
                  final totalGaps = 50.0;
                  final availableWidth = constraints.maxWidth;
                  final boxWidth = (availableWidth - totalGaps) / 6;
                  // Maintain aspect ratio (approximately square, slightly wider than tall)
                  final boxHeight = boxWidth * 0.91; // Original ratio: 51/56 ≈ 0.91
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      6,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                          right: index < 5 ? 10 : 0,
                        ),
                        child: _OtpInputBox(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          isActive: _currentFocusIndex == index,
                          onChanged: (value) => _onChanged(value, index),
                          onBackspace: () => _onBackspace(index),
                          width: boxWidth,
                          height: boxHeight,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 34),
              // Resend text
              RichText(
                text: TextSpan(
                  text: 'Didn’t get the code? ',
                  style: GoogleFonts.golosText(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF999999),
                  ),
                  children: [
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: _handleResend,
                        child: Text(
                          'Resend it.',
                          style: GoogleFonts.golosText(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFE0543D),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0543D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.golosText(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF050505),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              // Bottom helper text
              Center(
                child: Text(
                  'OTP has been sent to your email',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFFFFFFF).withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpInputBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isActive;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;
  final double width;
  final double height;

  const _OtpInputBox({
    required this.controller,
    required this.focusNode,
    required this.isActive,
    required this.onChanged,
    required this.onBackspace,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFFFFFFF),
          width: 0.5,
        ),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.50),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
          if (isActive)
            BoxShadow(
              color: const Color(0xFFE4472B).withOpacity(0.3),
              blurRadius: 0,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.golosText(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFFFFFFF),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            // Handle backspace
            onBackspace();
          } else {
            onChanged(value);
          }
        },
        onTap: () {
          // Move cursor to end for better UX
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        },
      ),
    );
  }
}

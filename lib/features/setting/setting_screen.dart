import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import SVG
import '../../core/currency_provider.dart';
import 'changepass_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: CurrencyProvider(),
          builder: (context, _) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 42),
                    // Title
                    Center(
                      child: Text(
                        'Setting',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Profile Section
                    const ProfileSection(
                      name: 'Athipat Somdee',
                      email: 'athipattawan@gmail.com',
                      avatarPath: 'assets/icons/profile_avatar.jpg',
                    ),
                    const SizedBox(height: 25),
                    // Other Settings Label
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        'Other Settings',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Settings Items Container
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF191919),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: const Color(0xFF282828),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          SettingItem(
                            icon: 'assets/icons/changepass.svg',
                            title: 'Change Password',
                            isSvg: true,
                            iconColor: Colors.white, // สีขาวตามคำขอ
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ChangePasswordScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 2,
                            color: Color(0xFF282828),
                            indent: 20,
                            endIndent: 20,
                          ),
                          SettingItem(
                            icon: 'assets/icons/currency.svg',
                            title: 'Currency',
                            isSvg: true,
                            iconColor: Colors.white, // สีเขียวมิ้นต์ที่เข้ากัน
                            trailingValue: CurrencyProvider().currentCurrency,
                            trailingIcon: CurrencyProvider().isUsd 
                                ? 'assets/images/united-states.png' 
                                : 'assets/images/thailand.png',
                            showChevron: false,
                            actionLabel: 'Change',
                            onActionPressed: () {
                              CurrencyProvider().toggle();
                            },
                            onTap: () {}, // Disabled row tap
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Sign Out Button
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF191919),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: const Color(0xFF282828),
                          width: 1,
                        ),
                      ),
                      child: SettingItem(
                        icon: 'assets/icons/singout.svg',
                        isSvg: true,
                        iconColor: const Color(0xFFDB2110), // สีแดงตามคำขอ
                        title: 'Sign out',
                        titleColor: const Color(0xFFDB2110),
                        chevronPath: 'assets/icons/chevron_right_red.png',
                        onTap: () {
                          // Handle sign out
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  final String name;
  final String email;
  final String avatarPath;

  const ProfileSection({
    super.key,
    required this.name,
    required this.email,
    required this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF282828), width: 1),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(avatarPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Name and Email
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Chevron
          Transform.rotate(
            angle: math.pi, // Pi (Points Right)
            child: Image.asset(
              'assets/icons/chevron_right_white.png',
              width: 15,
              height: 15,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final String icon;
  final String title;
  final Color? titleColor;
  final String? chevronPath;
  final String? trailingValue;
  final String? trailingIcon;
  final bool showChevron;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final VoidCallback onTap;
  final bool isSvg;
  final Color? iconColor; // เพิ่มพารามิเตอร์สีไอคอน

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    this.titleColor,
    this.chevronPath,
    this.trailingValue,
    this.trailingIcon,
    this.showChevron = true,
    this.actionLabel,
    this.onActionPressed,
    required this.onTap,
    this.isSvg = false,
    this.iconColor, // รับค่าสี
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            // Icon (รองรับการใส่สีผ่าน ColorFilter)
            SizedBox(
              width: 30,
              height: 30,
              child: isSvg
                  ? SvgPicture.asset(
                      icon,
                      fit: BoxFit.contain,
                      colorFilter: iconColor != null
                          ? ColorFilter.mode(iconColor!, BlendMode.srcIn)
                          : null,
                    )
                  : Image.asset(
                      icon,
                      fit: BoxFit.cover,
                      color: iconColor,
                    ),
            ),
            const SizedBox(width: 20),
            // Title
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Colors.white,
                ),
              ),
            ),
            // Trailing Value
            if (trailingValue != null)
              Padding(
                padding: EdgeInsets.only(right: actionLabel != null ? 8.0 : 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (trailingIcon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.asset(
                          trailingIcon!,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                    Text(
                      trailingValue!,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            // Action Button
            if (actionLabel != null)
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0543D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    actionLabel!,
                    style: GoogleFonts.golosText(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            // Chevron
            if (showChevron && actionLabel == null)
              Transform.rotate(
                angle: 3.14159, // Pi
                child: Image.asset(
                  chevronPath ?? 'assets/icons/chevron_right_white.png',
                  width: 15,
                  height: 15,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

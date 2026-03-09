import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'changepass_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
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
                        icon: 'assets/icons/password_icon.png',
                        title: 'Change Password',
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
                        icon: 'assets/icons/notification_icon.png',
                        title: 'Notifications',
                        onTap: () {
                          // Navigate to notifications screen
                        },
                      ),
                      const Divider(
                        height: 1,
                        thickness: 2,
                        color: Color(0xFF282828),
                        indent: 20,
                        endIndent: 20,
                      ),
                      SettingItemWithToggle(
                        icon: 'assets/icons/dark_mode_icon.png',
                        title: 'Dark mode',
                        value: _isDarkMode,
                        onChanged: (value) {
                          setState(() {
                            _isDarkMode = value;
                          });
                        },
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
                    icon: 'assets/icons/sign_out_icon.png',
                    title: 'Sign out',
                    titleColor: const Color(0xFFDB2110),
                    chevronPath: 'assets/icons/chevron_right_red.png',
                    onTap: () {
                      // Handle sign out
                    },
                  ),
                ),
              ],
            ),
          ),
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
          ClipOval(
            child: Image.asset(
              avatarPath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
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
  final VoidCallback onTap;

  const SettingItem({
    super.key,
    required this.icon,
    required this.title,
    this.titleColor,
    this.chevronPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            // Icon
            Image.asset(icon, width: 30, height: 30, fit: BoxFit.cover),
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
            // Chevron
            Transform.rotate(
              angle: pi,
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

class SettingItemWithToggle extends StatelessWidget {
  final String icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingItemWithToggle({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Icon
          Image.asset(icon, width: 30, height: 30, fit: BoxFit.cover),
          const SizedBox(width: 20),
          // Title
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Toggle Switch
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFFE0543D),
              activeTrackColor: const Color(0xFFE0543D).withOpacity(0.5),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

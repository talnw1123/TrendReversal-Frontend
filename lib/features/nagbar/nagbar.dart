import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

// ─── Nav Item Data ────────────────────────────────────────────────────────────
class _NavItemData {
  final String iconAsset;
  final String label;
  const _NavItemData({required this.iconAsset, required this.label});
}

const List<_NavItemData> _kNavItems = [
  _NavItemData(iconAsset: 'assets/icons/nav_home.svg', label: 'Home'),
  _NavItemData(iconAsset: 'assets/icons/nav_ai.svg', label: 'Ai'),
  _NavItemData(iconAsset: 'assets/icons/nav_portfolio.svg', label: 'Portfolio'),
  _NavItemData(iconAsset: 'assets/icons/nav_setting.svg', label: 'Setting'),
];

// ═══════════════════════════════════════════════════════════════════════════════
// AppNavBar
// ═══════════════════════════════════════════════════════════════════════════════
/// Bottom navigation bar with 4 tabs and a floating center action button.
///
/// [selectedIndex]: 0 = Home, 1 = Ai, 2 = Portfolio, 3 = Setting
/// [onTabSelected]: fired when a tab is tapped
/// [onCenterTap]:   fired when the floating center button is tapped
class AppNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onCenterTap;

  const AppNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavTab(
                  iconAsset: _kNavItems[0].iconAsset,
                  label: 'Home',
                  isActive: selectedIndex == 0,
                  onTap: () => onTabSelected(0),
                ),
                _NavTab(
                  iconAsset: _kNavItems[1].iconAsset,
                  label: 'Chat',
                  isActive: selectedIndex == 1,
                  onTap: () => onTabSelected(1),
                ),
                // Center Trend Button (Market Screen - Index 2)
                GestureDetector(
                  onTap: onCenterTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: EdgeInsets.all(selectedIndex == 2 ? 14 : 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: selectedIndex == 2
                          ? [
                              BoxShadow(
                                color: const Color(0xFFEC6244).withValues(alpha: 0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEC6244), Color(0xFFDB2110)],
                      ),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/nav_trend.svg',
                      width: 15,
                      height: 15,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                _NavTab(
                  iconAsset: _kNavItems[2].iconAsset,
                  label: 'Portfolio',
                  isActive: selectedIndex == 3,
                  onTap: () => onTabSelected(3),
                ),
                _NavTab(
                  iconAsset: _kNavItems[3].iconAsset,
                  label: 'Setting',
                  isActive: selectedIndex == 4,
                  onTap: () => onTabSelected(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _NavTab
// ═══════════════════════════════════════════════════════════════════════════════
class _NavTab extends StatelessWidget {
  final String iconAsset;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTab({
    required this.iconAsset,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                isActive ? const Color(0xFFDB2110) : Colors.white60,
                BlendMode.srcIn,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

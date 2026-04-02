import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color _kNavBg = Color(0xFF282828);
const Color _kNavActive = Color(0xFFFFFFFF);
const Color _kNavInactive = Color(0x80FFFFFF); // 50% white
const Color _kCenterTop = Color(0xFFFF5733); // gradient top (lighter orange)
const Color _kCenterBottom = Color(0xFFBF1800); // gradient bottom (darker red)

// ─── Nav Item Data ────────────────────────────────────────────────────────────
class _NavItemData {
  final String iconAsset;
  final String label;
  const _NavItemData({required this.iconAsset, required this.label});
}

const List<_NavItemData> _kNavItems = [
  _NavItemData(iconAsset: 'assets/icons/nav_home.png', label: 'Home'),
  _NavItemData(iconAsset: 'assets/icons/nav_ai.png', label: 'Ai'),
  _NavItemData(iconAsset: 'assets/icons/nav_portfolio.png', label: 'Portfolio'),
  _NavItemData(iconAsset: 'assets/icons/nav_setting.png', label: 'Setting'),
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
    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // ── Bar background + 4 tabs ─────────────────────────────────────
          Positioned.fill(
            child: Container(
              color: _kNavBg,
              child: Row(
                children: [
                  // Left pair
                  _NavTab(
                    data: _kNavItems[0],
                    isActive: selectedIndex == 0,
                    onTap: () => onTabSelected(0),
                  ),
                  _NavTab(
                    data: _kNavItems[1],
                    isActive: selectedIndex == 1,
                    onTap: () => onTabSelected(1),
                  ),
                  // Center spacer (equal flex to each tab, reserved for button)
                  const Expanded(child: SizedBox()),
                  // Right pair
                  _NavTab(
                    data: _kNavItems[2],
                    isActive: selectedIndex == 2,
                    onTap: () => onTabSelected(2),
                  ),
                  _NavTab(
                    data: _kNavItems[3],
                    isActive: selectedIndex == 3,
                    onTap: () => onTabSelected(3),
                  ),
                ],
              ),
            ),
          ),

          // ── Floating center button ──────────────────────────────────────
          Positioned(
            top: -18,
            child: Tooltip(
              message: 'Exchange',
              child: GestureDetector(
                onTap: onCenterTap,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment(-0.3, -0.4),
                      radius: 0.85,
                      colors: [_kCenterTop, _kCenterBottom],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x55BF1800),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white,
                    size: 30,
                    semanticLabel: 'Exchange',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// _NavTab
// ═══════════════════════════════════════════════════════════════════════════════
class _NavTab extends StatelessWidget {
  final _NavItemData data;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTab({
    super.key,
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _kNavActive : _kNavInactive;

    return Expanded(
      child: Semantics(
        label: data.label,
        selected: isActive,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                data.iconAsset,
                width: 25,
                height: 25,
                color: color,
              ),
              const SizedBox(height: 6),
              Text(
                data.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

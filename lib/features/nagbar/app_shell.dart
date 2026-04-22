import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../chat/aiagent_screen.dart';
import '../portfolio/portfolio_screen.dart';
import '../setting/setting_screen.dart';
import '../trend/market_screen.dart'; // เพิ่ม MarketScreen
import '../nagbar/nagbar.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// AppShell — Main wrapper with working bottom navigation bar
// ═══════════════════════════════════════════════════════════════════════════════
class AppShell extends StatefulWidget {
  static final GlobalKey<AppShellState> appShellKey =
      GlobalKey<AppShellState>();

  AppShell({super.key});

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  // Keep pages alive with IndexedStack
  static const List<Widget> _pages = [
    HomeScreen(),
    AiAgentScreen(),
    MarketScreen(), // แทรกหน้า Market ตรงกลาง (Index 2)
    PortfolioScreen(),
    SettingScreen(),
  ];

  void setSelectedIndex(int index) {
    if (mounted) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppNavBar(
        selectedIndex: _selectedIndex,
        onTabSelected: setSelectedIndex,
        onCenterTap: () {
          // สั่งเปลี่ยนไปหน้า Market (Index 2)
          setSelectedIndex(2);
        },
      ),
    );
  }
}

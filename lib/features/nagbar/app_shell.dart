import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../chat/aiagent_screen.dart';
import '../portfolio/portfolio_screen.dart';
import '../setting/setting_screen.dart';
import '../nagbar/nagbar.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// AppShell — Main wrapper with working bottom navigation bar
// ═══════════════════════════════════════════════════════════════════════════════
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  // Keep pages alive with IndexedStack
  static const List<Widget> _pages = [
    HomeScreen(),
    AiAgentScreen(),
    PortfolioScreen(),
    SettingScreen(),
  ];

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
        onTabSelected: (index) => setState(() => _selectedIndex = index),
        onCenterTap: () {
          // Navigate to AI screen (center action)
          setState(() => _selectedIndex = 1);
        },
      ),
    );
  }
}

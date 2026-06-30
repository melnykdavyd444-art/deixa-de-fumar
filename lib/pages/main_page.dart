import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme_colors.dart';
import 'login_page.dart';
import 'dashboard_page.dart';
import 'achievements_page.dart';
import 'stats_page.dart';
import '../widgets/settings_sheet.dart';

class MainPage extends StatefulWidget {
  final int userId;
  final String userName;
  final DateTime quitDate;
  final int cigarettesPerDay;
  final double pricePerPack;

  const MainPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.quitDate,
    required this.cigarettesPerDay,
    required this.pricePerPack,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late int cigarettesPerDay;
  late double pricePerPack;
  late DateTime quitDate;

  @override
  void initState() {
    super.initState();
    cigarettesPerDay = widget.cigarettesPerDay;
    pricePerPack = widget.pricePerPack;
    quitDate = widget.quitDate;
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SettingsSheet(
        userId: widget.userId,
        cigarettesPerDay: cigarettesPerDay,
        pricePerPack: pricePerPack,
        onDataUpdated: (cigs, price) {
          setState(() {
            cigarettesPerDay = cigs;
            pricePerPack = price;
          });
        },
        onLogout: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('loggedUserId');
          if (!context.mounted) return;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const LoginPage()));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        userId: widget.userId,
        userName: widget.userName,
        quitDate: quitDate,
        cigarettesPerDay: cigarettesPerDay,
        pricePerPack: pricePerPack,
        onSettingsTap: _openSettings,
        onQuitDateChanged: (novaData) {
          setState(() => quitDate = novaData);
        },
      ),
      AchievementsPage(
        userId: widget.userId,
        quitDate: quitDate,
        cigarettesPerDay: cigarettesPerDay,
        pricePerPack: pricePerPack,
      ),
      StatsPage(
        quitDate: quitDate,
        cigarettesPerDay: cigarettesPerDay,
        pricePerPack: pricePerPack,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.card(context),
        indicatorColor: AppColors.isDark(context)
            ? const Color(0xFF2A3A2A)
            : const Color(0xFFE8F5E9),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF2E7D32)),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events, color: Color(0xFF2E7D32)),
            label: 'Conquistas',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: Color(0xFF2E7D32)),
            label: 'Estatísticas',
          ),
        ],
      ),
    );
  }
}
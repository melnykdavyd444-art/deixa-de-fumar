import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database.dart';
import 'login_page.dart';
import 'main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final userId = prefs.getInt('loggedUserId');
    if (userId != null) {
      final db = await DatabaseHelper.database;
      final users = await db.query('users', where: 'id = ?', whereArgs: [userId]);
      if (users.isNotEmpty) {
        final user = users.first;
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => MainPage(
            userId: user['id'] as int,
            userName: user['name'] as String,
            quitDate: DateTime.parse(user['quitDate'] as String),
            cigarettesPerDay: user['cigarettesPerDay'] as int,
            pricePerPack: user['pricePerPack'] as double,
          ),
        ));
        return;
      }
    }
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.smoke_free, size: 90, color: Colors.white),
              SizedBox(height: 16),
              Text('Deixa de Fumar',
                  style: TextStyle(fontSize: 32,
                      fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 8),
              Text('A tua vida começa agora',
                  style: TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
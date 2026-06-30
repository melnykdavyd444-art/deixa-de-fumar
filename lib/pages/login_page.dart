import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database.dart';
import 'main_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _isLoading = true; _error = null; });
    final user = await DatabaseHelper.loginUser(
        nameController.text.trim(), passwordController.text.trim());
    if (!mounted) return;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('loggedUserId', user['id'] as int);
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => MainPage(
          userId: user['id'] as int,
          userName: user['name'] as String,
          quitDate: DateTime.parse(user['quitDate'] as String),
          cigarettesPerDay: user['cigarettesPerDay'] as int,
          pricePerPack: user['pricePerPack'] as double,
        ),
      ));
    } else {
      setState(() { _error = 'Nome ou palavra-passe incorretos.'; _isLoading = false; });
    }
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.smoke_free, size: 64, color: Colors.white),
                const SizedBox(height: 20),
                const Text('Bem-vindo! 👋',
                    style: TextStyle(fontSize: 36,
                        fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Inicia sessão para continuar.',
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 32),
                _inputField(nameController, 'Nome de utilizador', Icons.person),
                const SizedBox(height: 14),
                _inputField(passwordController, 'Palavra-passe', Icons.lock,
                    obscure: _obscure, suffix: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Entrar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegisterPage())),
                    child: const Text('Não tens conta? Regista-te',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String hint,
      IconData icon, {bool obscure = false, Widget? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
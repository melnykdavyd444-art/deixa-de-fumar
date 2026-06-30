import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database.dart';
import 'main_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final cigarettesController = TextEditingController();
  final priceController = TextEditingController();
  bool _obscure = true;
  String? _error;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _register() async {
    final name = nameController.text.trim();
    final pass = passwordController.text.trim();
    final confirm = confirmController.text.trim();
    final cigs = int.tryParse(cigarettesController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0.0;

    if (name.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Preenche todos os campos.');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'As palavras-passe não coincidem.');
      return;
    }
    if (pass.length < 4) {
      setState(() => _error = 'A palavra-passe deve ter pelo menos 4 caracteres.');
      return;
    }

    final id = await DatabaseHelper.registerUser(name, pass, selectedDate, cigs, price);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loggedUserId', id);
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => MainPage(
        userId: id,
        userName: name,
        quitDate: selectedDate,
        cigarettesPerDay: cigs,
        pricePerPack: price,
      ),
    ));
  }

  Widget _inputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w700,
              fontSize: 15, color: Color(0xFF2E7D32))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 8),
                const Text('Criar conta',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20))),
                const SizedBox(height: 6),
                const Text('Preenche os teus dados para começar.',
                    style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 28),

                _label('Nome de utilizador'),
                _inputCard(child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Ex: João',
                    border: InputBorder.none,
                    icon: Icon(Icons.person, color: Color(0xFF2E7D32)),
                  ),
                )),
                const SizedBox(height: 16),

                _label('Palavra-passe'),
                _inputCard(child: TextField(
                  controller: passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Mínimo 4 caracteres',
                    border: InputBorder.none,
                    icon: const Icon(Icons.lock, color: Color(0xFF2E7D32)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                )),
                const SizedBox(height: 16),

                _label('Confirmar palavra-passe'),
                _inputCard(child: TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Repete a palavra-passe',
                    border: InputBorder.none,
                    icon: Icon(Icons.lock_outline, color: Color(0xFF2E7D32)),
                  ),
                )),
                const SizedBox(height: 16),

                _label('Quando paraste de fumar?'),
                GestureDetector(
                  onTap: _pickDate,
                  child: _inputCard(child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 12),
                      Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: const TextStyle(fontSize: 16)),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ]),
                  )),
                ),
                const SizedBox(height: 16),

                _label('Cigarros por dia?'),
                _inputCard(child: TextField(
                  controller: cigarettesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Ex: 10',
                    border: InputBorder.none,
                    icon: Icon(Icons.smoke_free, color: Color(0xFF2E7D32)),
                  ),
                )),
                const SizedBox(height: 16),

                _label('Preço do maço (€)?'),
                _inputCard(child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Ex: 5.50',
                    border: InputBorder.none,
                    icon: Icon(Icons.euro, color: Color(0xFF2E7D32)),
                  ),
                )),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
                const SizedBox(height: 28),

                Container(
                  width: double.infinity, height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.4),
                        blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Criar conta 🚀',
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
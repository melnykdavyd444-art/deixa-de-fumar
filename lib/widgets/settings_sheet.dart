import 'package:flutter/material.dart';
import '../database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../notification_service.dart';
import '../theme_colors.dart';

class SettingsSheet extends StatefulWidget {
  final int userId;
  final int cigarettesPerDay;
  final double pricePerPack;
  final Function(int, double) onDataUpdated;
  final VoidCallback onLogout;

  const SettingsSheet({
    super.key,
    required this.userId,
    required this.cigarettesPerDay,
    required this.pricePerPack,
    required this.onDataUpdated,
    required this.onLogout,
  });

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late TextEditingController cigarettesController;
  late TextEditingController priceController;
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  String? _dataMsg;
  String? _passMsg;
  bool _notificationsOn = false;
  String? _notifMsg;

  @override
  void initState() {
    super.initState();
    cigarettesController =
        TextEditingController(text: widget.cigarettesPerDay.toString());
    priceController =
        TextEditingController(text: widget.pricePerPack.toStringAsFixed(2));
  }

  Future<void> _saveData() async {
    final cigs = int.tryParse(cigarettesController.text) ?? widget.cigarettesPerDay;
    final price = double.tryParse(priceController.text) ?? widget.pricePerPack;
    await DatabaseHelper.updateData(widget.userId, cigs, price);
    widget.onDataUpdated(cigs, price);
    setState(() => _dataMsg = '✅ Dados atualizados!');
  }

  Future<void> _changePassword() async {
    final oldPass = oldPassController.text.trim();
    final newPass = newPassController.text.trim();
    if (newPass.length < 4) {
      setState(() => _passMsg = '❌ Mínimo 4 caracteres.');
      return;
    }
    final db = await DatabaseHelper.database;
    final users = await db.query('users',
        where: 'id = ? AND password = ?',
        whereArgs: [widget.userId, DatabaseHelper.hashPassword(oldPass)]);
    if (users.isEmpty) {
      setState(() => _passMsg = '❌ Palavra-passe atual incorreta.');
      return;
    }
    await DatabaseHelper.updatePassword(widget.userId, newPass);
    setState(() => _passMsg = '✅ Palavra-passe alterada!');
    oldPassController.clear();
    newPassController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de arrastar
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Definições',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                      color: AppColors.green(context))),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppColors.textSecondary(context)),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.card(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Editar dados
          Text('Editar dados',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.green(context))),
          const SizedBox(height: 12),
          _settingField(cigarettesController, 'Cigarros por dia',
              Icons.smoke_free, TextInputType.number),
          const SizedBox(height: 10),
          _settingField(priceController, 'Preço do maço (€)',
              Icons.euro, TextInputType.number),
          if (_dataMsg != null) ...[
            const SizedBox(height: 6),
            Text(_dataMsg!, style: const TextStyle(fontSize: 13)),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, height: 46,
            child: ElevatedButton(
              onPressed: _saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Guardar alterações'),
            ),
          ),

          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),

          // Alterar palavra-passe
          Text('Alterar palavra-passe',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.green(context))),
          const SizedBox(height: 12),
          _settingField(oldPassController, 'Palavra-passe atual',
              Icons.lock_outline, TextInputType.text, obscure: true),
          const SizedBox(height: 10),
          _settingField(newPassController, 'Nova palavra-passe',
              Icons.lock, TextInputType.text, obscure: true),
          if (_passMsg != null) ...[
            const SizedBox(height: 6),
            Text(_passMsg!, style: const TextStyle(fontSize: 13)),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, height: 46,
            child: ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Alterar palavra-passe'),
            ),
          ),

          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),

          // Notificações
          Text('Notificações',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.green(context))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active,
                    color: Color(0xFF2E7D32), size: 20),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text('Lembrete diário (9h)',
                      style: TextStyle(fontSize: 15)),
                ),
                Switch(
                  value: _notificationsOn,
                  activeThumbColor: const Color(0xFF2E7D32),
                  onChanged: (value) async {
                    setState(() => _notificationsOn = value);
                    if (value) {
                      await NotificationService.requestPermission();
                      await NotificationService.scheduleDailyNotification(9, 0);
                      setState(() => _notifMsg = '✅ Lembrete diário ativado!');
                    } else {
                      await NotificationService.cancelAll();
                      setState(() => _notifMsg = 'Lembretes desativados.');
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, height: 46,
            child: OutlinedButton.icon(
              onPressed: () async {
                await NotificationService.requestPermission();
                await NotificationService.showTestNotification();
              },
              icon: const Icon(Icons.send, color: Color(0xFF2E7D32), size: 18),
              label: const Text('Testar notificação',
                  style: TextStyle(color: Color(0xFF2E7D32))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2E7D32)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (_notifMsg != null) ...[
            const SizedBox(height: 6),
            Text(_notifMsg!, style: const TextStyle(fontSize: 13)),
          ],

          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),

          // Aparência
          Text('Aparência',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.green(context))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Row(
              children: [
                Icon(
                  themeNotifier.value == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: const Color(0xFF2E7D32),
                  size: 20,
                ),
                const SizedBox(width: 14),
                Text('Modo escuro',
                    style: TextStyle(fontSize: 15,
                        color: AppColors.textPrimary(context))),
                const Spacer(),
                Switch(
                  value: themeNotifier.value == ThemeMode.dark,
                  activeThumbColor: const Color(0xFF2E7D32),
                  onChanged: (value) async {
                    themeNotifier.value =
                        value ? ThemeMode.dark : ThemeMode.light;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('darkMode', value);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 16),

          // Encerrar sessão
          SizedBox(
            width: double.infinity, height: 46,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                widget.onLogout();
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Encerrar sessão',
                  style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _settingField(TextEditingController controller, String hint,
      IconData icon, TextInputType type, {bool obscure = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          icon: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        ),
      ),
    );
  }
}
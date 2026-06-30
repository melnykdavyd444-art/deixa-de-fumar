import 'package:flutter/material.dart';
import '../database.dart';
import '../theme_colors.dart';

class CravingsPage extends StatefulWidget {
  final int userId;
  const CravingsPage({super.key, required this.userId});

  @override
  State<CravingsPage> createState() => _CravingsPageState();
}

class _CravingsPageState extends State<CravingsPage> {
  List<Map<String, dynamic>> _cravings = [];
  int _resistedCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCravings();
  }

  Future<void> _loadCravings() async {
    final cravings = await DatabaseHelper.getCravings(widget.userId);
    final resisted = await DatabaseHelper.countResisted(widget.userId);
    if (!mounted) return;
    setState(() {
      _cravings = cravings;
      _resistedCount = resisted;
      _loading = false;
    });
  }

  Future<void> _registerCraving(bool resisted) async {
    // Se cedeu, pede confirmação porque vai reiniciar o contador
    if (!resisted) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Reiniciar contador?'),
          content: const Text(
              'Se cedeste, o contador de tempo volta a zero a partir de agora. '
              'As tuas conquistas mantêm-se.\n\nTens a certeza?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sim, reiniciar'),
            ),
          ],
        ),
      );

      if (confirmar != true) return; // cancelou, não faz nada
    }

    if (!resisted) {
      // Reinicia a data de início para agora e limpa o histórico
      final agora = DateTime.now();
      await DatabaseHelper.updateQuitDate(widget.userId, agora);
      await DatabaseHelper.clearCravings(widget.userId);
      await _loadCravings();
      if (!mounted) return;
      // Devolve a nova data ao dashboard
      Navigator.pop(context, agora);
      return;
    }

    await DatabaseHelper.addCraving(widget.userId, resisted);

    await _loadCravings();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💪 Boa! Mais uma vontade controlada!'),
        backgroundColor: Color(0xFF2E7D32),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Formata a data/hora de forma legível
  String _formatDateTime(String iso) {
    final dt = DateTime.parse(iso);
    final dia = dt.day.toString().padLeft(2, '0');
    final mes = dt.month.toString().padLeft(2, '0');
    final hora = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dia/$mes às $hora:$min';
  }

  @override
  Widget build(BuildContext context) {
    final total = _cravings.length;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Histórico de vontades',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Estatísticas no topo
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _stat('$total', 'Total'),
                      Container(width: 1, height: 44, color: Colors.white24),
                      _stat('$_resistedCount', 'Não fumei 💪'),
                    ],
                  ),
                ),

                // Botões de registo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _registerCraving(true),
                          icon: const Icon(Icons.thumb_up, size: 18),
                          label: const Text('Não fumei'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _registerCraving(false),
                          icon: const Icon(Icons.thumb_down, size: 18),
                          label: const Text('Fumei'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Lista de vontades
                Expanded(
                  child: _cravings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history,
                                  size: 64,
                                  color: AppColors.textSecondary(context)),
                              const SizedBox(height: 12),
                              Text('Ainda não registaste vontades.',
                                  style: TextStyle(
                                      color: AppColors.textSecondary(context))),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _cravings.length,
                          itemBuilder: (context, index) {
                            final c = _cravings[index];
                            final resisted = c['resisted'] == 1;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.card(context),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: resisted
                                          ? const Color(0xFFE8F5E9)
                                          : const Color(0xFFFFF3E0),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      resisted
                                          ? Icons.check_circle
                                          : Icons.smoking_rooms,
                                      color: resisted
                                          ? const Color(0xFF2E7D32)
                                          : Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resisted ? 'Não fumaste!' : 'Fumaste',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: resisted
                                                ? const Color(0xFF2E7D32)
                                                : Colors.orange),
                                      ),
                                      Text(
                                        _formatDateTime(c['dateTime']),
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary(
                                                context)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
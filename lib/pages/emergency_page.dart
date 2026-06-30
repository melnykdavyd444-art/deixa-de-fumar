import 'package:flutter/material.dart';
import 'dart:async';
import '../theme_colors.dart';

class EmergencyPage extends StatefulWidget {
  final int days;
  final double moneySaved;
  final int cigarettesAvoided;

  const EmergencyPage({
    super.key,
    required this.days,
    required this.moneySaved,
    required this.cigarettesAvoided,
  });

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage>
    with SingleTickerProviderStateMixin {
  // Animação de respiração
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  String _breathText = 'Inspira';

  // Timer de 5 minutos
  int _secondsLeft = 300; // 5 minutos
  Timer? _timer;
  bool _timerRunning = false;

  final List<String> _tips = [
    '🫁 Respira fundo 10 vezes, devagar.',
    '💧 Bebe um copo de água lentamente.',
    '🚶 Levanta-te e dá uma volta de 5 minutos.',
    '📞 Liga a alguém de quem gostas.',
    '🍎 Come uma peça de fruta ou mastiga pastilha.',
    '🎵 Ouve a tua música preferida.',
    '🧠 Lembra-te: a vontade passa em poucos minutos!',
    '✍️ Escreve porque é que decidiste parar.',
  ];

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breathAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _breathController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _breathText = 'Expira');
        _breathController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _breathText = 'Inspira');
        _breathController.forward();
      }
    });
    _breathController.forward();
  }

  void _startTimer() {
    setState(() => _timerRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        setState(() => _timerRunning = false);
      }
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Aguenta firme! 💪',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Mensagem de topo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text('A vontade vai passar! 🌊',
                      style: TextStyle(color: Colors.white, fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Respira fundo. Tu consegues resistir a este momento.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Respiração guiada
            Text('Respiração guiada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                    color: AppColors.green(context))),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Center(
                child: AnimatedBuilder(
                  animation: _breathAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 160 * _breathAnimation.value,
                      height: 160 * _breathAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(_breathText,
                            style: const TextStyle(color: Colors.white,
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Timer de 5 minutos
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  Text('Espera 5 minutos',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                          color: AppColors.green(context))),
                  const SizedBox(height: 8),
                  Text('A maioria das vontades passa em poucos minutos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13,
                          color: AppColors.textSecondary(context))),
                  const SizedBox(height: 16),
                  Text('$minutes:$seconds',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold,
                          color: AppColors.green(context))),
                  const SizedBox(height: 16),
                  if (!_timerRunning && _secondsLeft == 300)
                    SizedBox(
                      width: double.infinity, height: 48,
                      child: ElevatedButton(
                        onPressed: _startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Iniciar contagem'),
                      ),
                    )
                  else if (_secondsLeft == 0)
                    const Text('🎉 Conseguiste! A vontade passou!',
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Lembretes do progresso
            Text('Lembra-te do teu progresso',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                    color: AppColors.green(context))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _reminderCard('📅', '${widget.days}',
                    'dias sem fumar', context)),
                const SizedBox(width: 12),
                Expanded(child: _reminderCard('💰',
                    '${widget.moneySaved.toStringAsFixed(0)}€',
                    'poupados', context)),
              ],
            ),
            const SizedBox(height: 12),
            _reminderCard('🚭', '${widget.cigarettesAvoided}',
                'cigarros que NÃO fumaste', context, fullWidth: true),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '⚠️ Se fumares agora, deitas tudo isto a perder. Vale mesmo a pena?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFFE65100),
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),

            // Dicas
            Text('Dicas para resistir',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                    color: AppColors.green(context))),
            const SizedBox(height: 16),
            ..._tips.map((tip) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Text(tip, style: TextStyle(fontSize: 15,
                  color: AppColors.textPrimary(context))),
            )),
          ],
        ),
      ),
    );
  }

  Widget _reminderCard(String emoji, String value, String label,
      BuildContext context, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
              color: AppColors.green(context))),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12,
                  color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }
}
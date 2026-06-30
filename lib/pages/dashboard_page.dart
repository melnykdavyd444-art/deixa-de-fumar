import 'package:flutter/material.dart';
import '../theme_colors.dart';
import 'emergency_page.dart';
import 'share_page.dart';
import 'package:quit_smoke/widgets/daily_quote.dart';
import 'cravings_page.dart';

class DashboardPage extends StatefulWidget {
  final int userId;
  final String userName;
  final DateTime quitDate;
  final int cigarettesPerDay;
  final double pricePerPack;
  final VoidCallback onSettingsTap;
  final ValueChanged<DateTime> onQuitDateChanged;

  const DashboardPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.quitDate,
    required this.cigarettesPerDay,
    required this.pricePerPack,
    required this.onSettingsTap,
    required this.onQuitDateChanged,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late Duration elapsed;
  late DateTime quitDate;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    quitDate = widget.quitDate;
    _updateTime();
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) setState(() => _updateTime());
    });

    // Animação saltitante do botão de emergência
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _updateTime() {
    elapsed = DateTime.now().difference(quitDate);
  }

  String _motivationalMessage(int days) {
    if (days == 0) return 'O primeiro passo é o mais corajoso! 🌱';
    if (days < 3) return 'Estás a passar o mais difícil. Força! 💪';
    if (days < 7) return 'Já $days dias! O teu corpo agradece!';
    if (days < 30) return 'Uma semana incrível! Continua assim! 🌟';
    if (days < 90) return 'Um mês sem fumar! És incrível! 🏆';
    return 'És uma inspiração! $days dias de vitória! 🎉';
  }

  @override
  Widget build(BuildContext context) {
    final int days = elapsed.inDays;
    final int hours = elapsed.inHours % 24;
    final int minutes = elapsed.inMinutes % 60;
    final int seconds = elapsed.inSeconds % 60;
    final double moneySaved = (elapsed.inMinutes / 1440) *
        widget.cigarettesPerDay / 20 * widget.pricePerPack;
    final int cigarettesAvoided =
        (elapsed.inMinutes / 1440 * widget.cigarettesPerDay).floor();
    final double weekProgress = (days % 7) / 7;

    return Scaffold(
      floatingActionButton: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: child,
          );
        },
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EmergencyPage(
                  days: days,
                  moneySaved: moneySaved,
                  cigarettesAvoided: cigarettesAvoided,
                ),
              ),
            );
          },
          backgroundColor: const Color(0xFFD32F2F),
          elevation: 6,
          child: const Icon(Icons.healing, color: Colors.white, size: 28),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.header(context),
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jornada de ${widget.userName}',
                            style: const TextStyle(fontSize: 20,
                                fontWeight: FontWeight.bold, color: Colors.white)),
                        const Text('Continua a lutar! 💚',
                            style: TextStyle(fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.history, color: Colors.white),
                      onPressed: () async {
                        final novaData = await Navigator.push<DateTime>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CravingsPage(userId: widget.userId),
                          ),
                        );
                        // Se o utilizador cedeu, recebe a nova data e reinicia
                        if (novaData != null && mounted) {
                          setState(() {
                            quitDate = novaData;
                            _updateTime();
                          });
                          widget.onQuitDateChanged(novaData);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SharePage(
                              userName: widget.userName,
                              days: days,
                              moneySaved: moneySaved,
                              cigarettesAvoided: cigarettesAvoided,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: widget.onSettingsTap,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bg(context),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Contador principal
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(
                                color: Colors.green.withValues(alpha: 0.3),
                                blurRadius: 16, offset: const Offset(0, 8))],
                          ),
                          child: Column(
                            children: [
                              const Text('Sem fumar há',
                                  style: TextStyle(color: Colors.white70, fontSize: 15)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _timeUnit(days.toString(), 'dias'),
                                  _divider(),
                                  _timeUnit(hours.toString().padLeft(2, '0'), 'horas'),
                                  _divider(),
                                  _timeUnit(minutes.toString().padLeft(2, '0'), 'min'),
                                  _divider(),
                                  _timeUnit(seconds.toString().padLeft(2, '0'), 'seg'),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Progresso desta semana: ${(weekProgress * 100).toInt()}%',
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 12)),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: weekProgress,
                                      backgroundColor: Colors.white24,
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Cards estatísticas
                        Row(
                          children: [
                            Expanded(child: _statCard(context,
                              icon: Icons.euro_rounded,
                              label: 'Poupado',
                              value: '${moneySaved.toStringAsFixed(2)}€',
                              color: const Color(0xFFE65100),
                              bgColor: const Color(0xFFFFF3E0),
                            )),
                            const SizedBox(width: 14),
                            Expanded(child: _statCard(context,
                              icon: Icons.smoke_free,
                              label: 'Evitados',
                              value: '$cigarettesAvoided',
                              color: const Color(0xFF1565C0),
                              bgColor: const Color(0xFFE3F2FD),
                            )),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Mensagem motivacional
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.card(context),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.isDark(context)
                                      ? const Color(0xFF2A3A2A)
                                      : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text('💪',
                                    style: TextStyle(fontSize: 28)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(_motivationalMessage(days),
                                    style: TextStyle(fontSize: 15,
                                        color: AppColors.textPrimary(context),
                                        height: 1.4)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Frase do dia
                        DailyQuote(),
                        const SizedBox(height: 20),
                        // Benefícios de saúde
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.card(context),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Benefícios de saúde',
                                  style: TextStyle(fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.green(context))),
                              const SizedBox(height: 14),
                              _healthBenefit(context, '20 minutos',
                                  'Pressão arterial normaliza',
                                  elapsed.inMinutes >= 20),
                              _healthBenefit(context, '8 horas',
                                  'Oxigénio no sangue normaliza',
                                  elapsed.inHours >= 8),
                              _healthBenefit(context, '1 dia',
                                  'Risco cardíaco começa a baixar',
                                  elapsed.inDays >= 1),
                              _healthBenefit(context, '3 dias',
                                  'Respiração fica mais fácil',
                                  elapsed.inDays >= 3),
                              _healthBenefit(context, '1 semana',
                                  'Paladar e olfato melhoram',
                                  elapsed.inDays >= 7),
                              _healthBenefit(context, '1 mês',
                                  'Pulmões começam a recuperar',
                                  elapsed.inDays >= 30),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80), // espaço para o botão flutuante
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: Colors.white24);

  Widget _timeUnit(String value, String label) => Column(
    children: [
      Text(value, style: const TextStyle(color: Colors.white,
          fontSize: 26, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
    ],
  );

  Widget _statCard(BuildContext context, {required IconData icon,
    required String label, required String value,
    required Color color, required Color bgColor}) {
    final cardBg = AppColors.isDark(context) ? AppColors.card(context) : bgColor;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20,
              fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12,
              color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }

  Widget _healthBenefit(BuildContext context, String time,
      String description, bool achieved) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: achieved
                  ? const Color(0xFF2E7D32)
                  : (AppColors.isDark(context)
                      ? Colors.white24
                      : Colors.grey.shade200),
              shape: BoxShape.circle,
            ),
            child: Icon(achieved ? Icons.check : Icons.lock_outline,
                size: 16,
                color: achieved ? Colors.white : Colors.grey),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time, style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: achieved
                      ? AppColors.green(context)
                      : Colors.grey)),
              Text(description, style: TextStyle(fontSize: 13,
                  color: achieved
                      ? AppColors.textPrimary(context)
                      : Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
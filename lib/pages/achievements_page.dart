import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../theme_colors.dart';
import '../database.dart';

class AchievementsPage extends StatefulWidget {
  final int userId;
  final DateTime quitDate;
  final double pricePerPack;
  final int cigarettesPerDay;

  const AchievementsPage({
    super.key,
    required this.userId,
    required this.quitDate,
    this.pricePerPack = 0,
    this.cigarettesPerDay = 0,
  });

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  late ConfettiController _confettiController;
  String _selectedCategory = 'Tempo';

  // Progresso guardado
  int _savedMaxXP = 0;
  Set<String> _savedUnlocked = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await DatabaseHelper.getProgress(widget.userId);
    final savedXP = progress['maxXP'] as int;
    final savedList = (progress['unlockedAchievements'] as String)
        .split(',')
        .where((s) => s.isNotEmpty)
        .toSet();

    // Calcula o estado atual
    final currentXP = _calculateCurrentXP();
    final currentUnlocked = _currentlyUnlocked();

    // Junta o guardado com o atual (fica sempre com o melhor)
    final newMaxXP = currentXP > savedXP ? currentXP : savedXP;
    final newUnlocked = {...savedList, ...currentUnlocked};

    // Se houve progresso novo, grava
    if (newMaxXP != savedXP || newUnlocked.length != savedList.length) {
      await DatabaseHelper.saveProgress(
          widget.userId, newMaxXP, newUnlocked.join(','));
    }

    if (!mounted) return;
    setState(() {
      _savedMaxXP = newMaxXP;
      _savedUnlocked = newUnlocked;
      _loading = false;
    });

    // Dispara confetti se há conquistas desbloqueadas
    if (newUnlocked.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // ─── Cálculos base ───
  Duration get elapsed => DateTime.now().difference(widget.quitDate);
  int get days => elapsed.inDays;
  double get moneySaved =>
      (elapsed.inMinutes / 1440) * widget.cigarettesPerDay / 20 * widget.pricePerPack;

  // XP só do tempo/conquistas atuais
  int _calculateCurrentXP() {
    int xp = days * 10;
    for (final a in _allAchievements()) {
      if (a['achieved'] as bool) xp += a['xp'] as int;
    }
    return xp;
  }

  // Lista de IDs das conquistas atualmente desbloqueadas
  Set<String> _currentlyUnlocked() {
    return _allAchievements()
        .where((a) => a['achieved'] as bool)
        .map((a) => a['title'] as String)
        .toSet();
  }

  // O XP mostrado é sempre o máximo (guardado ou atual)
  int get totalXP {
    final current = _calculateCurrentXP();
    return current > _savedMaxXP ? current : _savedMaxXP;
  }

  // Uma conquista conta como desbloqueada se está guardada OU se está ativa agora
  bool _isUnlocked(Map<String, dynamic> a) {
    return (a['achieved'] as bool) || _savedUnlocked.contains(a['title']);
  }

  static const List<int> _levelThresholds = [
    0, 100, 250, 500, 850, 1300, 1900, 2600, 3500, 5000
  ];

  static const List<String> _levelTitles = [
    'Iniciante', 'Aprendiz', 'Lutador', 'Guerreiro', 'Veterano',
    'Mestre', 'Campeão', 'Herói', 'Lenda', 'Imortal'
  ];

  int get currentLevel {
    int level = 1;
    for (int i = 0; i < _levelThresholds.length; i++) {
      if (totalXP >= _levelThresholds[i]) level = i + 1;
    }
    return level;
  }

  String get levelTitle =>
      _levelTitles[(currentLevel - 1).clamp(0, _levelTitles.length - 1)];

  int get xpForCurrentLevel =>
      _levelThresholds[(currentLevel - 1).clamp(0, _levelThresholds.length - 1)];
  int get xpForNextLevel => currentLevel < _levelThresholds.length
      ? _levelThresholds[currentLevel]
      : _levelThresholds.last;

  double get levelProgress {
    if (currentLevel >= _levelThresholds.length) return 1.0;
    final range = xpForNextLevel - xpForCurrentLevel;
    final progress = totalXP - xpForCurrentLevel;
    return (progress / range).clamp(0.0, 1.0);
  }

  List<Map<String, dynamic>> _allAchievements() {
    return [
      // TEMPO
      {'cat': 'Tempo', 'icon': '🌱', 'title': 'Primeiro Passo', 'desc': '1 dia sem fumar',
        'target': 1, 'current': days, 'achieved': days >= 1, 'xp': 50, 'unit': 'dias'},
      {'cat': 'Tempo', 'icon': '🔥', 'title': 'Em Chamas', 'desc': '3 dias sem fumar',
        'target': 3, 'current': days, 'achieved': days >= 3, 'xp': 75, 'unit': 'dias'},
      {'cat': 'Tempo', 'icon': '⭐', 'title': 'Uma Semana!', 'desc': '7 dias sem fumar',
        'target': 7, 'current': days, 'achieved': days >= 7, 'xp': 100, 'unit': 'dias'},
      {'cat': 'Tempo', 'icon': '💪', 'title': 'Determinado', 'desc': '14 dias sem fumar',
        'target': 14, 'current': days, 'achieved': days >= 14, 'xp': 150, 'unit': 'dias'},
      {'cat': 'Tempo', 'icon': '🏅', 'title': 'Um Mês!', 'desc': '30 dias sem fumar',
        'target': 30, 'current': days, 'achieved': days >= 30, 'xp': 250, 'unit': 'dias'},
      {'cat': 'Tempo', 'icon': '👑', 'title': 'Lenda', 'desc': '90 dias sem fumar',
        'target': 90, 'current': days, 'achieved': days >= 90, 'xp': 500, 'unit': 'dias'},
      // DINHEIRO
      {'cat': 'Dinheiro', 'icon': '🪙', 'title': 'Primeiras Moedas', 'desc': 'Poupar 10€',
        'target': 10, 'current': moneySaved.floor(), 'achieved': moneySaved >= 10, 'xp': 75, 'unit': '€'},
      {'cat': 'Dinheiro', 'icon': '💶', 'title': 'Carteira Cheia', 'desc': 'Poupar 50€',
        'target': 50, 'current': moneySaved.floor(), 'achieved': moneySaved >= 50, 'xp': 150, 'unit': '€'},
      {'cat': 'Dinheiro', 'icon': '💰', 'title': 'Poupador', 'desc': 'Poupar 100€',
        'target': 100, 'current': moneySaved.floor(), 'achieved': moneySaved >= 100, 'xp': 250, 'unit': '€'},
      {'cat': 'Dinheiro', 'icon': '🏦', 'title': 'Investidor', 'desc': 'Poupar 250€',
        'target': 250, 'current': moneySaved.floor(), 'achieved': moneySaved >= 250, 'xp': 400, 'unit': '€'},
      {'cat': 'Dinheiro', 'icon': '💎', 'title': 'Rico', 'desc': 'Poupar 500€',
        'target': 500, 'current': moneySaved.floor(), 'achieved': moneySaved >= 500, 'xp': 600, 'unit': '€'},
      // SAÚDE
      {'cat': 'Saúde', 'icon': '❤️', 'title': 'Coração Feliz', 'desc': 'Pressão normaliza (20 min)',
        'target': 1, 'current': elapsed.inMinutes >= 20 ? 1 : 0, 'achieved': elapsed.inMinutes >= 20, 'xp': 50, 'unit': ''},
      {'cat': 'Saúde', 'icon': '🫁', 'title': 'Respira Fundo', 'desc': 'Oxigénio normaliza (8h)',
        'target': 1, 'current': elapsed.inHours >= 8 ? 1 : 0, 'achieved': elapsed.inHours >= 8, 'xp': 75, 'unit': ''},
      {'cat': 'Saúde', 'icon': '👅', 'title': 'Sabor da Vida', 'desc': 'Paladar melhora (7 dias)',
        'target': 1, 'current': days >= 7 ? 1 : 0, 'achieved': days >= 7, 'xp': 150, 'unit': ''},
      {'cat': 'Saúde', 'icon': '🌬️', 'title': 'Pulmões Limpos', 'desc': 'Pulmões recuperam (30 dias)',
        'target': 1, 'current': days >= 30 ? 1 : 0, 'achieved': days >= 30, 'xp': 300, 'unit': ''},
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.bg(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final categories = ['Tempo', 'Dinheiro', 'Saúde'];
    final filtered = _allAchievements()
        .where((a) => a['cat'] == _selectedCategory)
        .toList();
    final unlockedCount =
        _allAchievements().where((a) => _isUnlocked(a)).length;
    final totalCount = _allAchievements().length;

    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Conquistas 🏆',
                            style: TextStyle(fontSize: 22,
                                fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('$unlockedCount/$totalCount',
                            style: const TextStyle(fontSize: 16,
                                color: Colors.white70, fontWeight: FontWeight.bold)),
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
                            const SizedBox(height: 6),
                            _levelCard(),
                            const SizedBox(height: 18),
                            _categoryTabs(categories),
                            const SizedBox(height: 18),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.82,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) =>
                                  _achievementCard(filtered[index]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              maxBlastForce: 25,
              minBlastForce: 10,
              gravity: 0.3,
              colors: const [
                Color(0xFF2E7D32), Color(0xFF4CAF50), Color(0xFFFFC107),
                Color(0xFF1565C0), Color(0xFFE65100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nível $currentLevel',
                      style: const TextStyle(color: Color(0xFFC0DD97), fontSize: 13)),
                  Text(levelTitle,
                      style: const TextStyle(color: Colors.white,
                          fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                width: 54, height: 54,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('$currentLevel',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              currentLevel >= _levelThresholds.length
                  ? '$totalXP XP · Nível máximo atingido! 🎉'
                  : '$totalXP / $xpForNextLevel XP · faltam ${xpForNextLevel - totalXP} para subir',
              style: const TextStyle(color: Color(0xFFC0DD97), fontSize: 11),
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: levelProgress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTabs(List<String> categories) {
    return Row(
      children: categories.map((cat) {
        final selected = cat == _selectedCategory;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF2E7D32) : AppColors.card(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? const Color(0xFF2E7D32) : AppColors.border(context),
                ),
              ),
              child: Text(cat,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.grey,
                  )),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _achievementCard(Map<String, dynamic> a) {
    final achieved = _isUnlocked(a);
    final target = a['target'] as int;
    final current = a['current'] as int;
    final progress = (current / target).clamp(0.0, 1.0);
    final remaining = target - current;
    final unit = a['unit'] as String;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achieved ? AppColors.card(context) : AppColors.locked(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: achieved ? [BoxShadow(color: Colors.green.withValues(alpha: 0.15),
            blurRadius: 10, offset: const Offset(0, 4))] : [],
        border: Border.all(
          color: achieved ? const Color(0xFF4CAF50) : Colors.grey.shade300,
          width: achieved ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(a['icon'] as String,
              style: TextStyle(fontSize: 34,
                  color: achieved ? null : const Color(0x44000000))),
          const SizedBox(height: 6),
          Text(a['title'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                  color: achieved ? const Color(0xFF2E7D32) : Colors.grey)),
          const SizedBox(height: 2),
          Text(a['desc'] as String,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10,
                  color: achieved ? Colors.black54 : Colors.grey.shade400)),
          const SizedBox(height: 8),
          if (achieved)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('+${a['xp']} XP ✓',
                  style: const TextStyle(fontSize: 10,
                      color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
            )
          else
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF888780)),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 3),
                Text('faltam $remaining$unit',
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
              ],
            ),
        ],
      ),
    );
  }
}
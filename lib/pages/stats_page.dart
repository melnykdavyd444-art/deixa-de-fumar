import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme_colors.dart';

class StatsPage extends StatelessWidget {
  final DateTime quitDate;
  final int cigarettesPerDay;
  final double pricePerPack;

  const StatsPage({
    super.key,
    required this.quitDate,
    required this.cigarettesPerDay,
    required this.pricePerPack,
  });

  @override
  Widget build(BuildContext context) {
    final elapsed = DateTime.now().difference(quitDate);
    final int days = elapsed.inDays;
    final double dailySaving = cigarettesPerDay / 20 * pricePerPack;

    final List<BarChartGroupData> barGroups = List.generate(7, (i) {
      final dayIndex = days - 6 + i;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: dayIndex > 0 ? dailySaving : 0,
            color: const Color(0xFF4CAF50),
            width: 18,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });

    final totalMoney = days * dailySaving;
    final totalCigarettes = days * cigarettesPerDay;

    return Scaffold(
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Estatísticas 📊',
                      style: TextStyle(fontSize: 22,
                          fontWeight: FontWeight.bold, color: Colors.white)),
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
                        Row(
                          children: [
                            Expanded(child: _bigStatCard(context,
                                '${totalMoney.toStringAsFixed(2)}€',
                                'Total poupado', Icons.savings,
                                const Color(0xFFE65100),
                                const Color(0xFFFFF3E0))),
                            const SizedBox(width: 14),
                            Expanded(child: _bigStatCard(context,
                                '$totalCigarettes',
                                'Cigarros evitados', Icons.smoke_free,
                                const Color(0xFF1565C0),
                                const Color(0xFFE3F2FD))),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                              Text('Dinheiro poupado (últimos 7 dias)',
                                  style: TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.green(context))),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 200,
                                child: BarChart(BarChartData(
                                  barGroups: barGroups,
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          const d = ['S','D','T','Q','Q','S','S'];
                                          return Text(d[value.toInt()],
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary(context)));
                                        },
                                      ),
                                    ),
                                  ),
                                )),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
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
                              Text('Resumo',
                                  style: TextStyle(fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.green(context))),
                              const SizedBox(height: 14),
                              _resumoItem(context, '📅', 'Dias sem fumar', '$days dias'),
                              _resumoItem(context, '🚬', 'Cigarros por dia',
                                  '$cigarettesPerDay cig/dia'),
                              _resumoItem(context, '💶', 'Preço do maço',
                                  '${pricePerPack.toStringAsFixed(2)}€'),
                              _resumoItem(context, '💰', 'Poupança mensal estimada',
                                  '${(dailySaving * 30).toStringAsFixed(2)}€/mês'),
                            ],
                          ),
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
    );
  }

  Widget _bigStatCard(BuildContext context, String value, String label,
      IconData icon, Color color, Color bgColor) {
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
          Text(value, style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11,
                  color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }

  Widget _resumoItem(BuildContext context, String emoji,
      String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(fontSize: 14,
              color: AppColors.textSecondary(context))),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.green(context))),
        ],
      ),
    );
  }
}
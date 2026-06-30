import 'package:flutter/material.dart';
import '../theme_colors.dart';

class DailyQuote extends StatelessWidget {
  const DailyQuote({super.key});

  // Lista de frases motivacionais
  static const List<String> _quotes = [
    'Cada dia sem fumar é uma vitória que ninguém te pode tirar.',
    'O segredo para avançar é começar.',
    'Não contes os dias, faz com que os dias contem.',
    'A tua saúde é o maior presente que podes dar a ti mesmo.',
    'És mais forte do que aquilo que te tenta controlar.',
    'Pequenos passos todos os dias levam a grandes mudanças.',
    'O melhor momento para parar foi ontem. O segundo melhor é agora.',
    'Acredita que consegues e já estás a meio caminho.',
    'A disciplina é escolher entre o que queres agora e o que mais queres.',
    'Cada cigarro que recusas é uma vitória do teu futuro.',
    'A força não vem do que consegues fazer, mas de superar o que pensavas não conseguir.',
    'Respira fundo. A vontade passa, o orgulho fica.',
    'O teu corpo é o teu lar. Cuida bem dele.',
    'Hoje é mais um dia para te orgulhares de ti.',
    'Desistir do tabaco não é perder algo, é ganhar a tua vida de volta.',
    'A jornada de mil milhas começa com um único passo.',
    'Tu controlas os teus hábitos, eles não te controlam a ti.',
    'A mudança é difícil no início, confusa no meio e linda no fim.',
    'Investe em ti. É o melhor investimento que podes fazer.',
    'Sê paciente contigo. Estás a fazer algo extraordinário.',
    'A coragem não é a ausência de medo, é agir apesar dele.',
    'Cada respiração limpa é um lembrete da tua força.',
    'O futuro pertence a quem acredita na beleza dos seus sonhos.',
    'Não pares quando estás cansado. Para quando tiveres terminado.',
    'A vida começa no fim da tua zona de conforto.',
    'O sucesso é a soma de pequenos esforços repetidos dia após dia.',
    'Orgulha-te de cada minuto em que escolheste a tua saúde.',
    'Tu já provaste que consegues. Continua a provar.',
    'A melhor versão de ti está do outro lado deste hábito.',
    'Hoje escolhe-te a ti mesmo. Outra vez.',
    'Cada dia é uma nova oportunidade para seres livre.',
  ];

  @override
  Widget build(BuildContext context) {
    // Escolhe a frase com base no dia do ano (muda todos os dias)
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    final quote = _quotes[dayOfYear % _quotes.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.isDark(context)
                      ? const Color(0xFF2A3A2A)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.format_quote,
                    color: AppColors.green(context), size: 22),
              ),
              const SizedBox(width: 12),
              Text('Frase do dia',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                      color: AppColors.green(context))),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '"$quote"',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
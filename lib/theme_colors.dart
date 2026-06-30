import 'package:flutter/material.dart';

// Cores centrais da app — cada uma adapta-se ao modo claro/escuro
class AppColors {
  static bool isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  // Fundo do conteúdo (a parte de baixo arredondada)
  static Color bg(BuildContext c) =>
      isDark(c) ? const Color(0xFF121212) : const Color(0xFFF1F8E9);

  // Cartões (eram brancos)
  static Color card(BuildContext c) =>
      isDark(c) ? const Color(0xFF1E1E1E) : Colors.white;

  // Texto principal (era preto)
  static Color textPrimary(BuildContext c) =>
      isDark(c) ? Colors.white : Colors.black87;

  // Texto secundário (era cinzento)
  static Color textSecondary(BuildContext c) =>
      isDark(c) ? Colors.white60 : Colors.black54;

  // Verde principal — um tom mais claro lê melhor no escuro
  static Color green(BuildContext c) =>
      isDark(c) ? const Color(0xFF81C784) : const Color(0xFF2E7D32);

  // Gradiente do topo (header)
  static List<Color> header(BuildContext c) => isDark(c)
      ? [const Color(0xFF0A1F0C), const Color(0xFF14331A)]
      : [const Color(0xFF1B5E20), const Color(0xFF388E3C)];

  // Fundo de elementos bloqueados (conquistas, etc.)
  static Color locked(BuildContext c) =>
      isDark(c) ? const Color(0xFF2A2A2A) : Colors.grey.shade100;

  // Cor de bordas
  static Color border(BuildContext c) =>
      isDark(c) ? const Color(0xFF3A3A3A) : Colors.grey.shade300;
}
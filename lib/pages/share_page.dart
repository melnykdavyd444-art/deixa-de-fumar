import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../theme_colors.dart';

class SharePage extends StatefulWidget {
  final String userName;
  final int days;
  final double moneySaved;
  final int cigarettesAvoided;

  const SharePage({
    super.key,
    required this.userName,
    required this.days,
    required this.moneySaved,
    required this.cigarettesAvoided,
  });

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _sharing = false;

  Future<void> _shareImage() async {
    setState(() => _sharing = true);
    try {
      // Captura o cartão como imagem
      final image = await _screenshotController.capture();
      if (image == null) return;

      // Guarda temporariamente
      final directory = await getTemporaryDirectory();
      final imagePath = File('${directory.path}/progresso.png');
      await imagePath.writeAsBytes(image);

      // Abre o menu de partilha
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Já vou em ${widget.days} dias sem fumar! 🚭💪 #DeixaDeFumar',
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Partilhar progresso',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text('Mostra a todos a tua conquista! 🎉',
                style: TextStyle(fontSize: 16,
                    color: AppColors.textSecondary(context))),
            const SizedBox(height: 24),

            // O cartão que vai ser partilhado
            Screenshot(
              controller: _screenshotController,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.smoke_free, size: 60, color: Colors.white),
                    const SizedBox(height: 12),
                    Text('${widget.userName} está livre do tabaco!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white,
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),

                    // Número de dias em destaque
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text('${widget.days}',
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 56, fontWeight: FontWeight.bold)),
                          const Text('DIAS SEM FUMAR',
                              style: TextStyle(color: Colors.white70,
                                  fontSize: 14, letterSpacing: 2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Estatísticas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _shareStat('💰', '${widget.moneySaved.toStringAsFixed(0)}€',
                            'poupados'),
                        Container(width: 1, height: 50,
                            color: Colors.white24),
                        _shareStat('🚭', '${widget.cigarettesAvoided}',
                            'evitados'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('Deixa de Fumar 📱',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botão de partilhar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _sharing ? null : _shareImage,
                icon: _sharing
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.share),
                label: Text(_sharing ? 'A preparar...' : 'Partilhar imagem',
                    style: const TextStyle(fontSize: 16,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shareStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white,
            fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
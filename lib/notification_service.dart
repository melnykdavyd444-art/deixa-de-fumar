import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Mensagens motivacionais que vão aparecer
  static const List<String> _messages = [
    'Continua firme! Cada dia conta. 💪',
    'O teu corpo está a agradecer-te neste momento. 🫁',
    'Lembra-te do dinheiro que estás a poupar! 💰',
    'És mais forte que a vontade de fumar. 🔥',
    'Mais um dia, mais uma vitória! 🏆',
    'Respira fundo. Estás a conseguir! 🌬️',
    'Pensa em quão longe já chegaste. 🌟',
    'A tua saúde melhora a cada hora sem fumar. ❤️',
  ];

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'quit_smoke_channel',
    'Motivação',
    channelDescription: 'Mensagens motivacionais diárias',
    importance: Importance.max,
    priority: Priority.high,
  );

  // Inicializa o serviço (chamado no arranque da app)
  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: initSettings);
  }

  // Pede permissão ao utilizador para enviar notificações
  static Future<void> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation
        <AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  // Envia uma notificação imediata (para testar)
  static Future<void> showTestNotification() async {
await _plugin.show(
      id: 0,
      title: 'Deixa de Fumar 🚭',
      body: _messages[DateTime.now().second % _messages.length],
      notificationDetails: const NotificationDetails(android: _androidDetails),
    );
  }

  // Agenda uma notificação diária a uma certa hora
  static Future<void> scheduleDailyNotification(int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

 await _plugin.zonedSchedule(
      id: 1,
      title: 'Deixa de Fumar 🚭',
      body: _messages[DateTime.now().day % _messages.length],
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(android: _androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repete todos os dias
    );
  }

  // Cancela todas as notificações agendadas
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
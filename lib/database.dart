import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static Database? _db;

  // Encripta a palavra-passe (SHA-256)
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = p.join(await getDatabasesPath(), 'quitsmoke.db');
    return openDatabase(path, version: 3, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          password TEXT NOT NULL,
          quitDate TEXT NOT NULL,
          cigarettesPerDay INTEGER NOT NULL,
          pricePerPack REAL NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE cravings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          dateTime TEXT NOT NULL,
          resisted INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE progress (
          userId INTEGER PRIMARY KEY,
          maxXP INTEGER NOT NULL DEFAULT 0,
          unlockedAchievements TEXT NOT NULL DEFAULT ''
        )
      ''');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
          CREATE TABLE cravings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            dateTime TEXT NOT NULL,
            resisted INTEGER NOT NULL
          )
        ''');
      }
      if (oldVersion < 3) {
        await db.execute('''
          CREATE TABLE progress (
            userId INTEGER PRIMARY KEY,
            maxXP INTEGER NOT NULL DEFAULT 0,
            unlockedAchievements TEXT NOT NULL DEFAULT ''
          )
        ''');
      }
    });
  }

  static Future<int> registerUser(String name, String password,
      DateTime quitDate, int cigarettes, double price) async {
    final db = await database;
    return db.insert('users', {
      'name': name,
      'password': hashPassword(password),
      'quitDate': quitDate.toIso8601String(),
      'cigarettesPerDay': cigarettes,
      'pricePerPack': price,
    });
  }

  static Future<Map<String, dynamic>?> loginUser(
      String name, String password) async {
    final db = await database;
    final result = await db.query('users',
        where: 'name = ? AND password = ?',
        whereArgs: [name, hashPassword(password)]);
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> updatePassword(int id, String newPassword) async {
    final db = await database;
    await db.update('users', {'password': hashPassword(newPassword)},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateData(int id, int cigarettes, double price) async {
    final db = await database;
    await db.update('users',
        {'cigarettesPerDay': cigarettes, 'pricePerPack': price},
        where: 'id = ?', whereArgs: [id]);
  }

  // ─── Vontades (cravings) ───

  // Regista uma nova vontade
  static Future<void> addCraving(int userId, bool resisted) async {
    final db = await database;
    await db.insert('cravings', {
      'userId': userId,
      'dateTime': DateTime.now().toIso8601String(),
      'resisted': resisted ? 1 : 0,
    });
  }

  // Vai buscar todas as vontades de um utilizador (mais recentes primeiro)
  static Future<List<Map<String, dynamic>>> getCravings(int userId) async {
    final db = await database;
    return db.query('cravings',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'dateTime DESC');
  }

  // Conta quantas vontades o utilizador resistiu
  static Future<int> countResisted(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as total FROM cravings WHERE userId = ? AND resisted = 1',
        [userId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }
  // Atualiza a data de "parou de fumar" (usado no reset)
  static Future<void> updateQuitDate(int id, DateTime newDate) async {
    final db = await database;
    await db.update('users', {'quitDate': newDate.toIso8601String()},
        where: 'id = ?', whereArgs: [id]);
  }
  // Apaga todas as vontades de um utilizador (usado no reset)
  static Future<void> clearCravings(int userId) async {
    final db = await database;
    await db.delete('cravings', where: 'userId = ?', whereArgs: [userId]);
  }
  // ─── Progresso (XP máximo e conquistas) ───

  // Lê o progresso guardado do utilizador
  static Future<Map<String, dynamic>> getProgress(int userId) async {
    final db = await database;
    final result =
        await db.query('progress', where: 'userId = ?', whereArgs: [userId]);
    if (result.isEmpty) {
      // Se ainda não existe, cria um registo vazio
      await db.insert('progress', {
        'userId': userId,
        'maxXP': 0,
        'unlockedAchievements': '',
      });
      return {'maxXP': 0, 'unlockedAchievements': ''};
    }
    return result.first;
  }

  // Guarda o progresso (XP máximo e lista de conquistas)
  static Future<void> saveProgress(
      int userId, int maxXP, String unlockedAchievements) async {
    final db = await database;
    await db.insert(
      'progress',
      {
        'userId': userId,
        'maxXP': maxXP,
        'unlockedAchievements': unlockedAchievements,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
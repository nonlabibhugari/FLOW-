import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'scm_inventory.db');
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      // جدول المنتجات
      await db.execute('''
       CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        quantity INTEGER,
        supplier TEXT,
        imagePath TEXT,
        status TEXT
        )
      ''');

      // جدول المستخدمين
      await db.execute('''
       CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        image TEXT
        )
      ''');

      // الجدول  لحفظ التنبيهات المحذوفة نهائياً
      await db.execute('''
       CREATE TABLE hidden_notifications(
        notif_id TEXT PRIMARY KEY
        )
      ''');
    });
  }

  // Products
  // ===============================
  static Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  static Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return maps.map((e) => Product.fromMap(e)).toList();
  }

  static Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete('products', where: 'id=?', whereArgs: [id]);
  }

  // Users
  // ===============================
  static Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  static Future<Map<String, dynamic>?> getUser(
      String email, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return res.isNotEmpty ? res.first : null;
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // دوال التنبيهات الجديدة
  // ===============================

  static Future<void> hideNotification(String notifId) async {
    final db = await database;
    await db.insert('hidden_notifications', {'notif_id': notifId},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<String>> getHiddenNotifications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('hidden_notifications');
    return maps.map((e) => e['notif_id'] as String).toList();
  }
}

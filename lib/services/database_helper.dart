import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Helper untuk membuka/membuat database SQLite.
/// Database ini tersimpan LANGSUNG di file system HP/device,
/// tidak butuh internet, WiFi, atau server apapun.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ujikom_alya.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE umkm (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_usaha TEXT NOT NULL,
        kategori TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        created_by TEXT,
        created_at TEXT
      )
    ''');
  }
}
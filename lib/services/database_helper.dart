import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        nip TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'pegawai'
      )
    ''');

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

    await db.execute('''
      CREATE TABLE presensi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_pegawai TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        jam_masuk TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        alamat TEXT
      )
    ''');

    await db.insert('users', {
      'nama': 'Admin',
      'email': 'admin@gmail.com',
      'password': 'admin123',
      'nip': '-',
      'role': 'admin',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE presensi (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama_pegawai TEXT NOT NULL,
          tanggal TEXT NOT NULL,
          jam_masuk TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          alamat TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          nip TEXT NOT NULL,
          role TEXT NOT NULL DEFAULT 'pegawai'
        )
      ''');

      await db.insert('users', {
        'nama': 'Admin',
        'email': 'admin@gmail.com',
        'password': 'admin123',
        'nip': '-',
        'role': 'admin',
      });
    }

    if (oldVersion < 4) {
      await db.update(
        'users',
        {
          'email': 'admin@gmail.com',
          'password': 'admin123',
        },
        where: 'role = ?',
        whereArgs: ['admin'],
      );
    }
  }
}
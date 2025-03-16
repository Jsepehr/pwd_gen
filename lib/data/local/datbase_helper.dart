import 'package:path/path.dart';
import 'package:pwd_gen/repository/pwd_repository.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper implements IDatabaseHelper {
  final String _dbName = 'passwords.db';
  final String _tableName = 'pwd_table';

  Database? _database;
  @override
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath(); // Get proper path
    final path = join(dbPath, _dbName); // Combine with db name
    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            hint TEXT NOT NULL,
            password TEXT NOT NULL,
            usageDate TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db
              .execute('ALTER TABLE $_tableName ADD COLUMN lastUsed INTEGER');
        }
      },
    );
  }

  @override
  String get tableName => _tableName;
}

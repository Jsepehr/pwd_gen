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
    return openDatabase(
      _dbName,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT NOT NULL,
            hint TEXT NOT NULL,
            password TEXT NOT NULL,
            usageCount TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  String get tableName => _tableName;
}

import '/core/injector.dart';
import '/data/local/datbase_helper.dart';
import '/domain/pwd_entity.dart';
import '/repository/pwd_repository.dart';
import 'package:sqflite/sqlite_api.dart';

class PwdRepositoryImpl implements PwdRepository {
  final _dbHelper = getIt<DatabaseHelper>();
  @override
  Future<int> insertPwd(PwdEntity pwd) async {
    final db = await _dbHelper.database;
    return await db.insert(
      _dbHelper.tableName,
      pwd.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<PwdEntity>> getAllPwds() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps =
          await db.query(_dbHelper.tableName);
      return maps.map((map) => PwdEntity.fromMap(map)).toList();
    } on Exception catch (e) {
      throw (e.toString());
    }
  }

  @override
  Future<int> updatePwd(PwdEntity updatedPwd) async {
    // Check if the ID exists
    final db = await _dbHelper.database;
    if (db.isOpen == false) {
      throw Exception("Database is not open");
    }
    final List<Map<String, dynamic>> existing = await db.query(
      _dbHelper.tableName,
      where: 'id = ?',
      whereArgs: [updatedPwd.id],
    );

    if (existing.isEmpty) {
      throw Exception("No record found with ID: ${updatedPwd.id}");
    }

    return await db.update(
      _dbHelper.tableName,
      {'hint': updatedPwd.hint.toString(), 'usageDate': updatedPwd.usageDate},
      where: 'id = ?',
      whereArgs: [updatedPwd.id],
    );
  }

}

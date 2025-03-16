import 'package:pwd_gen/core/injector.dart';
import 'package:pwd_gen/data/local/datbase_helper.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';
import 'package:pwd_gen/repository/pwd_repository.dart';
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
  Future<int> deletePwd(String id) async {
    final db = await _dbHelper.database;
    return await db
        .delete(_dbHelper.tableName, where: 'id = ?', whereArgs: [id]);
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

  Future<void> updateAndVerify(String id, PwdEntity newPwd) async {
    // Update the password entry
    await updatePwd(newPwd);

    // Fetch the updated entry
    final updatedPwd = await getPwdById(id);

    if (updatedPwd != null && updatedPwd.id == newPwd.id) {
      print("✅ Update successful: ${updatedPwd.toMap()}");
    } else {
      print("❌ Update failed! Record not found.");
    }
  }

  Future<PwdEntity?> getPwdById(String id) async {
    /* final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _dbHelper.tableName,
      where: 'id = ?',
      whereArgs: [id],
    ); */
    await Future.delayed(Duration(seconds: 1));
    final db = await _dbHelper.database;
    final result = await db
        .rawQuery("SELECT * FROM ${_dbHelper.tableName} WHERE id = ?", [id]);

    if (result.isNotEmpty) {
      return PwdEntity.fromMap(result.first); // Convert map to PwdEntity
    }
    return null; // Return null if not found
  }
}

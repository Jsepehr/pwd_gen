import 'package:pwd_gen/core/injector.dart';
import 'package:pwd_gen/data/local/datbase_helper.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';
import 'package:pwd_gen/repository/pwd_repository.dart';

class PwdRepositoryImpl implements PwdRepository {
  final _dbHelper = getIt<DatabaseHelper>();
  @override
  Future<int> insertPwd(PwdEntity pwd) async {
    final db = await _dbHelper.database;
    return await db.insert(_dbHelper.tableName, pwd.toMap());
  }

  @override
  Future<List<PwdEntity>> getAllPwds() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(_dbHelper.tableName);
    return maps.map((map) => PwdEntity.fromMap(map)).toList();
  }

  @override
  Future<int> deletePwd(String id) async {
    final db = await _dbHelper.database;
    return await db
        .delete(_dbHelper.tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> updatePwd(PwdEntity updatedPwd) async {
    final db = await _dbHelper.database;
    return await db.update(
      _dbHelper.tableName,
      updatedPwd.toMap(),
      where: 'id = ?',
      whereArgs: [updatedPwd.id],
    );
  }
}

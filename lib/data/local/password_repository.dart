import 'package:pwd_gen/data/models/pwd_model.dart';
import 'package:pwd_gen/repository/pwd_repository.dart';

class PasswordRepository implements PwdRepository {
  final IDatabaseHelper _dbHelper;

  PasswordRepository(this._dbHelper);
  @override
  Future<int> insertPwd(PwdModel pwd) async {
    final db = await _dbHelper.database;
    return await db.insert(_dbHelper.tableName, pwd.toMap());
  }

  @override
  Future<List<PwdModel>> getAllPwds() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(_dbHelper.tableName);
    return maps.map((map) => PwdModel.fromMap(map)).toList();
  }

  @override
  Future<int> deletePwd(String id) async {
    final db = await _dbHelper.database;
    return await db
        .delete(_dbHelper.tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> updatePwd(PwdModel updatedPwd) async {
    final db = await _dbHelper.database;
    return await db.update(
      _dbHelper.tableName,
      updatedPwd.toMap(),
      where: 'id = ?',
      whereArgs: [updatedPwd.id],
    );
  }
}

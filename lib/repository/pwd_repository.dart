import 'package:pwd_gen/domain/pwd_entity.dart';
import 'package:sqflite/sqflite.dart';

abstract class PwdRepository {
  Future<int> updatePwd(PwdEntity updatedPwd);
  Future<List<PwdEntity>> getAllPwds();
  Future<void> deletePwd(String id);
  Future<int> insertPwd(PwdEntity pwd);
}

abstract class IDatabaseHelper {
  Future<Database> get database;
  String get tableName;
}

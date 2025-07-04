import '/domain/pwd_entity.dart';
import 'package:sqflite/sqflite.dart';

abstract class PwdRepository {
  Future<int> updatePwd(PwdEntity updatedPwd);
  Future<List<PwdEntity>> getAllPwds();
  Future<int> insertPwd(PwdEntity pwd);
}

abstract class IDatabaseHelper {
  Future<Database> get database;
  String get tableName;
}

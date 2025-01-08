import 'package:pwd_gen/data/models/pwd_model.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';
import 'package:sqflite/sqflite.dart';

abstract class PwdRepository {
  Future<int> updatePwd(PwdModel updatedPwd);
  Future<List<PwdEntity>> getAllPwds();
  Future<void> deletePwd(String id);
  Future<int> insertPwd(PwdModel pwd);
}

abstract class IDatabaseHelper {
  Future<Database> get database;
  String get tableName;
}

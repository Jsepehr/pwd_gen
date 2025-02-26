import 'package:get_it/get_it.dart';
import 'package:pwd_gen/core/static_data.dart';
import 'package:pwd_gen/data/local/datbase_helper.dart';
import 'package:pwd_gen/data/local/password_repository.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';

final getIt = GetIt.instance;

void setupLocator() {
  final db = DatabaseHelper();

  getIt.registerLazySingleton<PwdRepositoryImpl>(() => PwdRepositoryImpl(db));
  getIt.registerLazySingleton<String>(() => fixedString,
      instanceName: 'fixedString');
  getIt.registerSingleton<PwdEntityEdit>(
      PwdEntityEdit(password: "", hint: "",));
}

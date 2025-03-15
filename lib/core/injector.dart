import 'package:get_it/get_it.dart';
import 'package:pwd_gen/core/static_data.dart';
import 'package:pwd_gen/data/local/datbase_helper.dart';
import 'package:pwd_gen/data/local/password_repository.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<PwdRepositoryImpl>(() => PwdRepositoryImpl());
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  getIt.registerSingleton<FixedString>(FixedString._instance);
  getIt.registerSingleton<PwdEntityEdit>(PwdEntityEdit(
    password: "",
    hint: "",
  ));
}

class FixedString {
  static final FixedString _instance = FixedString._internal();


  FixedString._internal();

  // Factory che restituisce sempre la stessa istanza
  factory FixedString() => _instance;

  final String fixedString =
      "00123,00213,00231,00312,00321,01023,01032,02031,02310,03021,03120,03210"
      ",10023,10032,10203,10302,10320,12003,13002,13200,20031,20130,20301,21003,23100,30012,30102"
      ",31002,31020,31200,32010,32100,01123,01132,01231,02113,10123,10132,10312,11023,11032,11230"
      ",12013,12130,12301,12310,13012,13102,13120,13201,13210,20113,20131,21031,21103,21130,21301"
      ",21310,23110,30211,31012,31210,32011,32110,01223,01232,02132,02213,02231,02312,10322,12023"
      ",12230,12320,13022,13202,13220,20132,20231,20321,21023,21302,21320,22013,22031,22130,22310"
      ",23021,23201,30122,30212,30221,31022,31220,32021,32201,01233,01323,02133,02331,03123,03132"
      ",03321,10233,10332,13203,13320,21033,23013,23103,23130,23301,23310,30213,30231,30312,30321"
      ",31032,31203,31302,32013,32031,32103,33012,33021,33102,33201,33210";

  // Metodo di esempio
  String get() => fixedString;
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pwd_gen/core/injector.dart';
import 'package:pwd_gen/core/routs.dart';
import 'package:pwd_gen/cubit_pwds_list/pwd_list_cubit.dart';
import 'package:pwd_gen/data/local/password_repository.dart';
import 'package:pwd_gen/view/widgets/cubit_config_pwds/config_pwds_cubit.dart';
import 'package:pwd_gen/view/widgets/cubit_pwd_editor/pwd_editor_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  final myService = getIt<PwdRepositoryImpl>();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<PwdListCubit>(
            create: (context) => PwdListCubit(myService)..loadPwdsFromDb()),
        BlocProvider<ConfigPwdsCubit>(
            create: (context) => ConfigPwdsCubit()..emitState()),
        BlocProvider<PwdEditorCubit>(
            create: (context) => PwdEditorCubit()..init()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        darkTheme: ThemeData.dark().copyWith(
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.black,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                color: const Color.fromARGB(255, 76, 102, 175),
                width: 2.0,
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, // Text color
              backgroundColor: Colors.black, // Button background color
            ),
          ),
        ),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

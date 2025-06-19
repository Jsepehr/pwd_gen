import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/injector.dart';
import '/core/routs.dart';
import '/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import '/view/widgets/pwd_config/cubit_config_pwds/config_pwds_cubit.dart';
import '/view/widgets/pwd_edit/cubit_pwd_editor/pwd_editor_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<PwdListCubit>(
            create: (context) => PwdListCubit()..loadPwdsFromDb()),
        BlocProvider<ConfigPwdsCubit>(create: (context) => ConfigPwdsCubit()),
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

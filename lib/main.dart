import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/core/app_pallet.dart';
import 'package:pwd_gen/core/app_restart.dart';
import 'package:pwd_gen/core/app_shared_preferences.dart';
import 'package:pwd_gen/core/dictionary/app_strings.dart';
import 'package:pwd_gen/core/dictionary/language_helper.dart';

import '/core/injector.dart';
import '/core/routs.dart';
import '/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import '/view/widgets/pwd_config/cubit_config_pwds/config_pwds_cubit.dart';
import '/view/widgets/pwd_edit/cubit_pwd_editor/pwd_editor_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await _loadStrings();
  runApp(
    AppRestartWidget(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<PwdListCubit>(
            lazy: false,
            create: (context) => PwdListCubit()..loadPwdsFromDb(),
          ),
          BlocProvider<ConfigPwdsCubit>(create: (context) => ConfigPwdsCubit()),
          BlocProvider<PwdEditorCubit>(
            lazy: false,
            create: (context) => PwdEditorCubit()..init(),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          darkTheme: _buildDarkTheme(),
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
        ),
      ),
    ),
  );
}

Future<void> _loadStrings() async {
  final override = await AppSharedPreferences.loadLanguageOverride();
  final lang = override ?? LanguageHelper.getDeviceLanguageCode();
  final json = await getLanguageJson(lang);
  AppStrings.fromJson(jsonDecode(json));
}

ThemeData _buildDarkTheme() {
  final base = ThemeData.dark();
  const buttonRadius = BorderRadius.all(Radius.circular(AppRadius.md));

  return base.copyWith(
    scaffoldBackgroundColor: AppPallet.darkBlue,
    colorScheme: base.colorScheme.copyWith(
      primary: AppPallet.bottomSheetTitleIcon,
      onPrimary: Colors.white,
      surface: AppPallet.bottomSheetBG,
      error: AppPallet.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppPallet.bottomSheetBG,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppPallet.bottomSheetBG,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppPallet.bottomSheetTitleIcon,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(
          color: AppPallet.buttonBorderSides,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(
          color: AppPallet.bottomSheetTitleIcon,
          width: 2.0,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppPallet.bottomSheetTitleIcon,
        shape: const RoundedRectangleBorder(borderRadius: buttonRadius),
      ),
    ),
  );
}

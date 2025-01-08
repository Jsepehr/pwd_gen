import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pwd_gen/data/local/datbase_helper.dart';
import 'package:pwd_gen/data/local/password_repository.dart';
import 'package:pwd_gen/view/animated_list_works.dart';
import 'package:pwd_gen/view/pwd_list_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(
    GetMaterialApp(
      home: PwdListView(),
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
  );
}

void setupDependencies() {
  Get.lazyPut<PasswordRepository>(() => PasswordRepository(
        DatabaseHelper(),
      ));
}

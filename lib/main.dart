import 'package:flutter/material.dart';

import 'package:pwd_gen/core/ingector.dart';
import 'package:pwd_gen/core/routs.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(
    MaterialApp.router(
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
  );
}




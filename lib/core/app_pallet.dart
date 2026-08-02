import 'package:flutter/material.dart';

/// Single source of truth for colors used across the app's theme and any
/// widget that paints outside of what [ThemeData] covers directly.
class AppPallet {
  static const Color bottomSheetBG =
      Color.fromARGB(255, 0, 47, 91); // surface: dialogs, sheets, cards
  static const Color darkBlue =
      Color.fromARGB(255, 0, 24, 46); // app background
  static const Color black = Color.fromARGB(255, 0, 0, 0);
  static const Color success = Color.fromARGB(255, 0, 128, 0);
  static const Color error = Color.fromARGB(255, 255, 0, 0);
  static const Color bottomSheetTitleIcon =
      Colors.blue; // primary accent (icons, buttons, focus)
  static const Color buttonBorderSides =
      Colors.white54; // disabled / subtle borders
  static const Color scrim = Color(0xC8000000); // full-screen loading overlay
  static const Color highlight =
      Color.fromARGB(255, 255, 106, 0); // transient "just edited" pulse
}

/// Shared corner-radius scale so buttons, inputs, dialogs and bottom sheets
/// don't drift into different roundness across the app.
class AppRadius {
  AppRadius._();

  static const double md = 12; // buttons, inputs, small cards
  static const double lg = 20; // dialogs, bottom sheets, large cards
}

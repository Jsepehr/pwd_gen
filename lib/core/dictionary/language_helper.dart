import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';

class LanguageHelper {
  // Lista delle lingue supportate (sulle quali hai i tuoi file JSON)
  static const List<String> _supportedLanguages = [
    'en', // inglese
    'ar', // arabo
    'es', // spagnolo
    'fa', // persiano
    'fr', // francese
    'it', // italiano
    'pt', // portoghese
    'ru', // russo
  ];

  // Metodo che restituisce il codice lingua da usare, con fallback a 'en'
  static String getDeviceLanguageCode() {
    Locale systemLocale = ui.PlatformDispatcher.instance
        .locale; // prendi la lingua del sistema Android
    if (_supportedLanguages.contains(systemLocale.languageCode)) {
      return systemLocale.languageCode;
    } else {
      return 'en'; // fallback a inglese se non supportato
    }
  }
}

Future<String> getLanguageJson(String lang) async {
  return await rootBundle
      .loadString('assets/$lang.json');
}

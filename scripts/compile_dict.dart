import 'dart:convert';
import 'dart:io';

void main() async {
  // 1. Leggi il file JSON
  final jsonFile = File('assets/en.json');
  if (!await jsonFile.exists()) {
    print("Errore: assets/en.json non trovato!");
    return;
  }

  final String content = await jsonFile.readAsString();
  final Map<String, dynamic> data = jsonDecode(content);

  // 2. Costruisci il contenuto del file Dart
  final buffer = StringBuffer();
  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  buffer.writeln('\nclass AppStrings {');

  data.forEach((key, value) {
    // Trasforma la chiave in un nome variabile valido (es. api_key -> apiKey)
    final fieldName = key.replaceAllMapped(RegExp(r'(_[a-z])'), (match) {
      return match.group(0)!.toUpperCase().replaceFirst('_', '');
    });

    buffer.writeln('  static late String $fieldName;');
  });

  buffer.writeln('\nstatic fromJson(Map<String, dynamic> json) {');

  data.forEach((key, value) {
    final fieldName = key.replaceAllMapped(RegExp(r'(_[a-z])'), (match) {
      return match.group(0)!.toUpperCase().replaceFirst('_', '');
    });

    buffer.writeln('    $fieldName = json[\'$key\'] ?? \'\';');
  });
  buffer.writeln('  }');

  buffer.writeln('}');

  // 3. Scrivi il file nella cartella lib
  final outFile = File('lib/core/dictionary/app_strings.dart');
  await outFile.writeAsString(buffer.toString());

  print('✅ File generato con successo in: ${outFile.path}');
}

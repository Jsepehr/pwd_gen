import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:pwd_gen/core/utility.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final path = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOAD);

    final dir = Directory(path + '/notepas');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File('${dir.path}/test.txt');

    try {
      await file.writeAsString('ciao mi chi',
          flush: true, mode: FileMode.writeOnlyAppend);
    } catch (e) {
      debugPrint('$e');
      MPGState.applyState(MPGStateEnums.somethingWentWrong);
    }
  } on Exception catch (e) {
    debugPrint('$e');
  }
}

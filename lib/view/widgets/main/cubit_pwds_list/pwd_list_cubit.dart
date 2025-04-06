import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pwd_gen/core/injector.dart';
import 'package:pwd_gen/core/utility.dart';
import 'package:pwd_gen/data/local/password_repository.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'pwd_list_state.dart';

class PwdListCubit extends Cubit<PwdListState> {
  PwdListCubit() : super(PwdListInitial());
  List<PwdEntity> _pwdListSaved = []; // read from db
  List<PwdEntity> _pwdListShow = []; // u see this on the list view
  bool isSearching = false;
  bool isLoading = false;

  int _len = 0;
  int i = 0;
  int _usageCount = 0;
  final db = getIt<PwdRepositoryImpl>();

  void loadPwdsFromDb() async {
    await loadPwdsFromLocalDb();
    _pwdListShow = List.from(_pwdListSaved);
    _len = _pwdListShow.length;
    _pwdListShow.sort(
        (a, b) => int.parse(b.usageDate).compareTo(int.parse(a.usageDate)));
    _emitState();
  }

  Future<void> _saveAllToLocalDb(PwdEntity pwd) async {
    await db.insertPwd(pwd);
  }

  void loadPwdsFromFile() async {
    final res = await readContentFromFile();
    if (res == null) return;

    for (var item in res) {
      _pwdListShow.add(
        PwdEntity(
          id: Uuid().v4(),
          password: item[1],
          hint: item[0] == 'vuoto' ? '' : item[0],
          usageDate: item[2],
        ),
      );
      await _saveAllToLocalDb(PwdEntity(
        id: Uuid().v4(),
        password: item[1],
        hint: item[0] == 'vuoto' ? '' : item[0],
        usageDate: item[2],
      ));
    }

    _emitState();
  }

  void toggleSearch() {
    isSearching = !isSearching;
    _emitState();
  }

  void searchThis(String inputString) {
    List<PwdEntity> filteredList = [];

    if (inputString.isEmpty || !isSearching) {
      _pwdListShow = _pwdListSaved;
      _emitState();
      return;
    }
    for (int i = 0; i < _len; i++) {
      if (_pwdListSaved[i]
          .hint
          .toLowerCase()
          .contains(inputString.toLowerCase())) {
        filteredList.add(_pwdListSaved[i]);
      }
    }
    _pwdListShow = List.from(filteredList);

    _emitState();
  }

  Future<void> loadPwdsFromLocalDb() async {
    try {
      _pwdListSaved = await db.getAllPwds();
      _pwdListSaved.sort((a, b) => b.usageDate.compareTo(a.usageDate));
    } catch (e) {
      print("Failed to load passwords: $e");
    }
  }

  Future<void> updateHintAndPwds(PwdEntityEdit pwdModified, int index) async {
    _usageCount = DateTime.now().millisecondsSinceEpoch;
    _pwdListShow[index].usageDate = _usageCount.toString();
    _pwdListShow[index].hint = pwdModified.hint;
    _pwdListShow[index].password = pwdModified.password;
    await db.updatePwd(_pwdListShow[index]);
    _emitState();
  }

  Future<void> updateDateTime(int index) async {
    _usageCount = DateTime.now().millisecondsSinceEpoch;
    _pwdListShow[index].usageDate = _usageCount.toString();
    await db.updatePwd(_pwdListShow[index]);
    _emitState();
  }

  Future<void> generatePwds(String? secretText, File? image) async {
    isLoading = true;
    _emitState();
    final List<String> numForRand = getIt<FixedString>().fixedString.split(',');

    if (image == null) {
      return;
    }
    final imageHash = generateImageHash(image);
    if (secretText == null) {
      return;
    }
    final stringHash = generateStringHash(secretText);
    var pass1 = CreatePasswords.allDonePreDB(imageHash, numForRand);
    var pass2 = CreatePasswords.allDonePreDB(stringHash, numForRand);

    final c = combineStrings(pass1, pass2);
    for (int k = 0; k < 50; k++) {
      _pwdListShow.add(PwdEntity(
          id: Uuid().v4(), hint: 'Hint $i', password: c[k], usageDate: '0'));

      await _saveAllToLocalDb(PwdEntity(
          id: _pwdListShow[k].id,
          hint: _pwdListShow[k].hint,
          password: _pwdListShow[k].password,
          usageDate: _pwdListShow[k].usageDate));
      i++;
    }
    _len = _pwdListShow.length;
    _pwdListSaved = List.from(_pwdListShow);
    await Future.delayed(Duration(milliseconds: 2));
    isLoading = false;
    _emitState();
  }

  Future<bool> requestStoragePermission() async {
    isLoading = true;
    _emitState();
    if (await Permission.storage.request().isGranted) {
      return true; // Storage permission granted (for Android 9 and below)
    }

    if (await Permission.manageExternalStorage.request().isGranted) {
      return true; // Full access granted (for Android 11+)
    }

    // If denied, show settings dialog for Android 11+
    if (await Permission.manageExternalStorage.request().isDenied) {
      isLoading = false;
      _emitState();
      return false;
    }
    isLoading = false;
    _emitState();
    return false;
  }

  Future<String> get _localPath async {
    final directory = Directory('/storage/emulated/0/Download');
    final folderPath = '${directory.path}/Notepass'; // Custom folder

    final folder = Directory(folderPath);
    if (!await folder.exists()) {
      await folder.create(); // Create the folder if it doesn't exist
    }

    return folderPath;
  }

  Future<void> _saveText(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('path', filePath);
  }

  Future<String?> _loadSavedText() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('path');
  }

  Future<File> get _localFile async {
    final fileToDelete = await _loadSavedText();
    if (fileToDelete != null) {
      try {
        final file = File(fileToDelete);
        if (await file.exists()) {
          await file.delete();
          print('File eliminato con successo.');
        } else {
          print('Il file non esiste.');
        }
      } catch (e) {
        print('Errore durante l\'eliminazione del file: $e');
      }
    }
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyyMMddkkmm').format(now);
    final path = await _localPath;
    await _saveText('$path/Notepass_pwdc$formattedDate.txt');

    return File('$path/Notepass_pwdc$formattedDate.txt');
  }

  Future<bool> wrightContentToFile() async {
    try {
      /*  List<PwdEntity> data = await db.getAllPwds();
      if (data.isEmpty) return; */

      final file = await _localFile;
      String result = '';

      for (var element in _pwdListShow) {
        result +=
            '${element.hint == '' ? 'vuoto' : element.hint}<|||>${element.password}<|||>${element.usageDate}<|||>';
      }

      file.writeAsString(result);
      isLoading = false;
      _emitState();
      return true;
    } on Exception catch (e) {
      debugPrint('wrightContentToFile error : $e');
      return false;
    }
  }

  _emitState() {
    isLoading = true;
    emit(
      PwdListLoaded(
        pwdListShow: [..._pwdListShow],
        isSearching: isSearching,
        isLoading: isLoading,
      ),
    );
    isLoading = false;

    emit(
      PwdListLoaded(
        pwdListShow: [..._pwdListShow],
        isSearching: isSearching,
        isLoading: isLoading,
      ),
    );
  }
}

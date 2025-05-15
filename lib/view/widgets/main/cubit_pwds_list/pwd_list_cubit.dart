import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pwd_gen/core/injector.dart';
import 'package:pwd_gen/core/notepass_encrypt.dart';
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
  final LocalAuthentication _auth = LocalAuthentication();
  bool res = false;

  Future<void> authenticate() async {
    emit(PwdListInitial());
    try {
      res = await _auth.authenticate(
        localizedReason: 'Autenticati per continuare',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return;
    }
  }

  int _len = 0;
  int i = 0;
  int _usageCount = 0;
  final db = getIt<PwdRepositoryImpl>();

  Future<void> loadPwdsFromDb() async {
    await loadPwdsFromLocalDb();
    if (_pwdListSaved.isNotEmpty && !res) {
      await authenticate();
      await loadPwdsFromDb();
    }
    _pwdListShow = List.from(_pwdListSaved);
    _len = _pwdListShow.length;
    _pwdListShow.sort(
        (a, b) => int.parse(b.usageDate!).compareTo(int.parse(a.usageDate!)));
    _emitState();
  }

  Future<void> _saveAllToLocalDb(PwdEntity pwd) async {
    await db.insertPwd(pwd);
  }

  void loadPwdsFromFile() async {
    isLoading = true;
    _emitState();
    final res = await readContentFromFile(); // read from binary TODO
    if (res == null) return;

    _pwdListShow.addAll(res);
    for (var pwd in res) {
      await _saveAllToLocalDb(pwd);
    }

    isLoading = false;
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
      _pwdListSaved.sort((a, b) => b.usageDate!.compareTo(a.usageDate!));
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
    // save hashes on user prefs
    await _saveImageHashes(imageHsh: imageHash);

    var pass1 = CreatePasswords.allDonePreDB(imageHash, numForRand);
    var pass2 = CreatePasswords.allDonePreDB(stringHash, numForRand);

    final c = combineStrings(pass1, pass2);
    for (int k = 0; k < 50; k++) {
      _pwdListShow.add(PwdEntity(
          id: Uuid().v4(),
          hint: 'Your comment...',
          password: c[k],
          usageDate: '0'));

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

  Future<void> _saveImageHashes({required String imageHsh}) async {
    final prefs = await SharedPreferences.getInstance();
    final hashes = prefs.getString('imageHash');
    if (hashes != null) {
      final jsonD = json.decode(hashes) as List<String>;
      jsonD.add(imageHsh);
      final hashesString = json.encode(jsonD);
      await prefs.setString('imageHash', hashesString);
      return;
    }
    await prefs.setString('imageHash', imageHsh);
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
          debugPrint('File eliminato con successo.'); // TODO handle
        } else {
          debugPrint('Il file non esiste.');
        }
      } catch (e) {
        debugPrint('Errore durante l\'eliminazione del file: $e');
      }
    }
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyyMMddkkmm').format(now);
    final path = await _localPath;
    await _saveText('$path/Notepass_pwdc$formattedDate.nps');

    return File('$path/Notepass_pwdc$formattedDate.nps');
  }

  Future<bool> wrightContentToFile() async {
    // TODO save as binary
    try {
      /*  List<PwdEntity> data = await db.getAllPwds();
      if (data.isEmpty) return; */

      final file = await _localFile;
      // String result = '';

      // result = PwdEntityList(_pwdListShow).toJsonList();

      await BinaryEncryptor.saveBinaryEncryptedFile(
          passwords: _pwdListShow, filename: file.path.split('/').last);

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

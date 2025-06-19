import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:external_path/external_path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/core/notepass_encrypt.dart';
import '/core/utility.dart';
import '/data/local/password_repository.dart';
import '/domain/pwd_entity.dart';
import '/core/injector.dart';

part 'pwd_list_state.dart';

class PwdListCubit extends Cubit<PwdListState> {
  PwdListCubit() : super(PwdListInitial());
  List<PwdEntity> _pwdListSaved = []; // read from db
  List<PwdEntity> _pwdListShow = []; // u see this on the list view
  bool _isSearching = false;
  bool _isLoading = false;
  final LocalAuthentication _auth = LocalAuthentication();
  bool res = false;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  int pwdsListLen() {
    return _pwdListShow.length;
  }

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
    _emitState(_pwdListShow);
  }

  Future<void> _saveAllToLocalDb(PwdEntity pwd) async {
    await db.insertPwd(pwd);
  }

  Future<void> selectMPGFile() async {
    setIsLoadingState(true);
    final res = await ReadNpsFile().readContentFromFile();
    if (res != null) {
      for (var element in res) {
        await _saveAllToLocalDb(element);
      }
      _pwdListSaved = res;
      _pwdListShow = res;
      MPGState.applyState(MPGStateEnums.oldImportDone);
      setIsLoadingState(false);
      _emitState(_pwdListShow);
      return;
    }
    if (MPGState.currentState != MPGStateEnums.ok) {
      setIsLoadingState(false);
      return;
    }
  }

  Future<void> selectImageFileForPWDGenerator() async {
    final res = await ReadNpsFile().imageSelectionAndGenPwds();

    if (res.isEmpty) {
      _isLoading = false;
      _emitState(_pwdListShow);
      return;
    }

    _pwdListShow.addAll(res);
    for (var pwd in res) {
      await _saveAllToLocalDb(pwd);
    }

    setIsLoadingState(false);
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    _emitState(_pwdListShow);
  }

  void searchThis(String inputString) {
    List<PwdEntity> filteredList = [];

    if (inputString.isEmpty || !_isSearching) {
      _pwdListShow = _pwdListSaved;
      _emitState(_pwdListShow);
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

    _emitState(_pwdListShow);
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
    final updatedPwd = _pwdListShow[index].copyWith(
      usageDate: _usageCount.toString(),
      hint: pwdModified.hint,
      password: pwdModified.password,
    );

// Aggiorna la lista con il nuovo oggetto
    final newListShow = List<PwdEntity>.from(_pwdListShow);
    newListShow[index] = updatedPwd;

// Aggiorna il database
    await db.updatePwd(updatedPwd);
// Emetti la nuova lista
    _pwdListShow = newListShow;
    _pwdListSaved = newListShow;
    _emitState(newListShow);
  }

  Future<void> updateDateTime(int index) async {
    _usageCount = DateTime.now().millisecondsSinceEpoch;
    _pwdListShow[index].usageDate = _usageCount.toString();
    await db.updatePwd(_pwdListShow[index]);
    _emitState(_pwdListShow);
  }

  Future<void> generatePwds(String? secretText, File? image) async {
    setIsLoadingState(true);
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
    //await _saveImageHashes(imageHsh: imageHash);

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
    setIsLoadingState(false);
  }

  Future<void> requestStoragePermission() async {
    setIsLoadingState(true);
    if (await Permission.storage.request().isGranted) {
      // Storage permission granted (for Android 9 and below)
      MPGState.applyState(MPGStateEnums.permissionGranted);
    }

    if (await Permission.manageExternalStorage.request().isGranted) {
      // Full access granted (for Android 11+)
      MPGState.applyState(MPGStateEnums.permissionGranted);
    }

    // If denied, show settings dialog for Android 11+
    if (await Permission.manageExternalStorage.request().isDenied) {
      setIsLoadingState(false);
      MPGState.applyState(MPGStateEnums.permissionDenied);
    }
  }

  Future<void> _savePath() async {
    final fileName = _createFileName();
    String path = '';
    try {
      path = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOAD);
    } on Exception catch (e) {
      debugPrint('$e');
      MPGState.applyState(MPGStateEnums.somethingWentWrong);
    }

    final finalPath = '$path/$appFolderName';
    final dir = Directory(finalPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserPrefPath, finalPath);
    await prefs.setString(keyUserPrefFileName, fileName);
  }

/*   Future<void> _saveImageHashes({required String imageHsh}) async {
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
  } */

  Future<void> _deleteOldFile() async {
    final fileDir = await loadSavedDirectory();
    final fileName = await loadSavedFileName();
    if (fileDir != null && fileName != null) {
      try {
        final file = File('$fileDir/$fileName');
        if (await file.exists()) {
          debugPrint(file.path.split('/').last);
          await file.delete();
          debugPrint('File eliminato con successo.');
        } else {
          debugPrint('Il file non esiste.');
        }
      } catch (e) {
        debugPrint('Errore durante l\'eliminazione del file: $e');
      }
    }
  }

  String _createFileName() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyyMMddkkmm').format(now);
    return 'MPG$formattedDate.nps';
  }

  Future<bool> wrightContentToFile(String imageHash) async {
    try {
      await _deleteOldFile();
      await _savePath();
      // this will create file path and file name
      await BinaryEncrypt.saveBinaryEncryptedFile(
          passwords: _pwdListShow, imageHash: imageHash);
      setIsLoadingState(false);
      return true;
    } on Exception catch (e) {
      debugPrint('wrightContentToFile error : $e');
      return false;
    }
  }

  _emitState(List<PwdEntity>? newPwd) {
    emit(
      PwdListLoaded(
        pwdListShow: [...newPwd ?? []],
        isSearching: _isSearching,
        isLoading: _isLoading,
      ),
    );
  }

  void setIsLoadingState(bool isLoading) {
    _isLoading = isLoading;
    _emitState(_pwdListShow);
  }
}

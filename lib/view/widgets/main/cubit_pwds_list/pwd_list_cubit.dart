import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pwd_gen/core/app_shared_preferences.dart';
import 'package:pwd_gen/core/read_file_generate_pwds.dart';
import 'package:uuid/uuid.dart';

import '/core/injector.dart';
import '/core/notepass_encrypt.dart';
import '/core/utility.dart';
import '/data/local/password_repository.dart';
import '/domain/pwd_entity.dart';
import '/view/widgets/shared/app_dialog.dart';

part 'pwd_list_state.dart';

class PwdListCubit extends Cubit<PwdListState> {
  PwdListCubit() : super(PwdListInitial());
  List<PwdEntity> _pwdListSaved = []; // read from db
  List<PwdEntity> _pwdListShow = []; // u see this on the list view
  bool _isSearching = false;
  bool _isLoading = false;
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isUserAuthenticated = false;
  bool get isUserAuthenticated => _isUserAuthenticated;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  final _readFileGeneratePwds = ReadFileGeneratePwds();

  int get pwdsListLen => _pwdListShow.length;

  String _currentSearchString = '';
  // This is used to filter the list when searching
  List<PwdEntity> _filteredList = [];

  Future<void> authenticate() async {
    _isUserAuthenticated = false;
    try {
      _isUserAuthenticated = await _auth.authenticate(
        localizedReason: 'Autenticati per continuare',
      );
    } catch (e) {
      print(e);
      return;
    }
  }

  void setUserAuthenticated(bool value) {
    _isUserAuthenticated = value;
  }

  void emitSecurityOptions() {
    emit(UiPwdListChooseSecurity());
  }

  void emitChoosePin() {
    emit(UiPwdChoosePin());
  }

  void resetList() {
    _pwdListShow = [];
    _pwdListSaved = [];
    _isSearching = false;
    _len = 0;
    getIt<PwdRepositoryImpl>().deleteAllPwds();
    _emitState(_pwdListShow);
  }

  int _len = 0;
  int _usageCount = 0;
  final db = getIt<PwdRepositoryImpl>();

  Future<void> loadPwdsFromDb() async {
    final welcome = await AppSharedPreferences.loadBoolFirstRun() ?? false;
    final userEntryMode = await AppSharedPreferences.loadEntryMode();
    if (welcome == false) {
      emit(UiPwdListWelcome());
    } else {
      if (userEntryMode == UserEntryMode.unknown) {
        emit(UiPwdListChooseSecurity());
      } else {
        if (userEntryMode == UserEntryMode.customPwd) {
          final pwdHash = await AppSharedPreferences.loadPwdHash();
          if (pwdHash == null || pwdHash.isEmpty) {
            // se non c'è una password salvata, mostra la schermata di scelta del PIN
            emit(UiPwdChoosePin());
          } else {
            if (!_isUserAuthenticated) {
              emit(UiPwdLoginWithPassword());
            } else {
              await _loadPwdsFromLocalDb();
              _len = _pwdListSaved.length;
              _pwdListShow = List.from(_pwdListSaved);
              _isLoading = false;
              _isSearching = false;
              _emitState(_pwdListShow);
            }
          }
        } else {
          await authenticate();
          if (!_isUserAuthenticated) {
            emit(UiPwdListAuth());
            return;
          }
          await _loadPwdsFromLocalDb();
          _len = _pwdListSaved.length;
          _pwdListShow = List.from(_pwdListSaved);
          _emitState(_pwdListShow);
        }
      }
    }
  }

  Future<void> _saveAllToLocalDb(PwdEntity pwd) async {
    await db.insertPwd(pwd);
  }

  Future<void> selectKeymageFile() async {
    setIsLoadingState(true);
    final generatedPwds = await _readFileGeneratePwds.readContentFromFile();
    if (generatedPwds != null) {
      // here the list from old version
      for (var element in generatedPwds) {
        await _saveAllToLocalDb(element);
      }
      _pwdListSaved = generatedPwds;
      _pwdListShow = generatedPwds;
      KeymageState.applyState(KeymageStateEnums.oldImportDone);
      setIsLoadingState(false);
      _len = generatedPwds.length;
      _emitState(_pwdListShow);
      return;
    }
    setIsLoadingState(false);
  }

  Future<void> selectImageFileForPWDGenerator() async {
    KeymageState.applyState(KeymageStateEnums.start);
    final res = await _readFileGeneratePwds.imageSelectionAndGenPwds();
    if (res.isEmpty) {
      _isLoading = false;
      _emitState(_pwdListShow);
      return;
    }

    _pwdListShow.addAll(res);
    _pwdListSaved.addAll(res);
    for (var pwd in res) {
      await _saveAllToLocalDb(pwd);
    }

    setIsLoadingState(false);
  }

  void toggleSearch() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      // Closing search must drop the filter, or a stale filtered subset
      // lingers as _pwdListShow — which generatePwds() and others treat as
      // the full list, silently losing entries that didn't match the filter.
      _currentSearchString = '';
      _filteredList.clear();
      _pwdListShow = _pwdListSaved;
    }
    _emitState(_pwdListShow);
  }

  /// Searches the list of passwords based on the input string.
  /// If the input string is empty or searching is not enabled, it resets the list to the saved passwords.
  /// Otherwise, it filters the passwords based on whether their hint contains the input string.
  void searchThis(String inputString) {
    _len = _pwdListSaved.length;
    _currentSearchString = inputString;
    if (inputString.isEmpty || !_isSearching) {
      _pwdListShow = _pwdListSaved;
      _filteredList.clear();
      _emitState(_pwdListShow);
      return;
    }
    _filteredList.clear();
    for (int i = 0; i < _len; i++) {
      if (_pwdListSaved[i]
          .hint
          .toLowerCase()
          .contains(inputString.toLowerCase())) {
        _filteredList.add(_pwdListSaved[i]);
      }
    }
    _pwdListShow = List.from(_filteredList);
    _emitState(_pwdListShow);
  }

  Future<void> _loadPwdsFromLocalDb() async {
    try {
      _pwdListSaved = await db.getAllPwds();
      _pwdListSaved.sort((a, b) => b.usageDate!.compareTo(a.usageDate!));
    } catch (e) {
      print("Failed to load passwords: $e");
    }
  }

  Future<void> updateHintAndPwds(
    PwdEntity pwdModified,
  ) async {
    _usageCount = DateTime.now().millisecondsSinceEpoch;
    final index = _pwdListShow.indexWhere((e) => e.id == pwdModified.id);
    final indexSaved = _pwdListSaved.indexWhere((e) => e.id == pwdModified.id);
    if (index == -1) {
      debugPrint("Error: Password not found in the list.");
      return;
    }
    final updatedPwd = _pwdListShow[index].copyWith(
      usageDate: _usageCount.toString(),
      hint: pwdModified.hint,
      password: pwdModified.password,
    );

    final newListShow = List<PwdEntity>.from(_pwdListShow);

    newListShow[index] = updatedPwd;
    _pwdListSaved[indexSaved] = updatedPwd;

    final res = await db.updatePwd(updatedPwd);
    if (res < 1) {
      KeymageState.applyState(KeymageStateEnums.somethingWentWrong);
    }
    final imageHash = await AppSharedPreferences.loadImageHash();
    if (imageHash != null) {
      await wrightContentToFile(imageHash);
    }
    if (_currentSearchString.isNotEmpty) {
      _pwdListShow = newListShow;
      _emitState(_pwdListShow);
    } else {
      _pwdListShow = newListShow;
      _pwdListSaved = newListShow;
      _emitState(_pwdListSaved);
    }
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
    _len = _pwdListShow.length;
    for (int k = 0; k < 50; k++) {
      final tmpPwd =
          PwdEntity(id: Uuid().v4(), hint: '', password: c[k], usageDate: '0');
      _pwdListShow.add(tmpPwd);

      await _saveAllToLocalDb(tmpPwd);
    }
    _len = _pwdListShow.length;
    _pwdListSaved = List.from(_pwdListShow);
    await Future.delayed(Duration(milliseconds: 2));
    setIsLoadingState(false);
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

  String _createFileName() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyyMMddkkmm').format(now);
    return 'Keymage$formattedDate.kmg';
  }

  /// Returns `"ok"`, `"permission_needed"`, or `"error"` — see
  /// [BinaryEncrypt.saveBinaryEncryptedFile].
  Future<String> wrightContentToFile(String imageHash) async {
    try {
      final status = await BinaryEncrypt.saveBinaryEncryptedFile(
        passwords: _pwdListSaved,
        imageHash: imageHash,
        fileName: _createFileName(),
      );
      setIsLoadingState(false);
      return status;
    } on Exception catch (e) {
      debugPrint('wrightContentToFile error : $e');
      return 'error';
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

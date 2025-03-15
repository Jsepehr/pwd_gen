import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pwd_gen/core/injector.dart';
import 'package:pwd_gen/core/utility.dart';
import 'package:pwd_gen/data/local/password_repository.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';
import 'package:uuid/uuid.dart';

part 'pwd_list_state.dart';

class PwdListCubit extends Cubit<PwdListState> {
  PwdListCubit() : super(PwdListInitial());
  List<PwdEntity> _pwdList = []; // this is the state
  List<PwdEntity> _pwdListSaved = []; // read from db
  //List<PwdEntity> _pwdFilteredList = []; // filtered
  List<PwdEntity> _pwdListShow = []; // this is animated
  final List<bool> _opacityFlags = [];
  bool isSearching = false;
  bool isLoading = false;

  int _len = 0;
  final db = getIt<PwdRepositoryImpl>();

  void loadPwdsFromDb() async {
    await loadPwdsFromLocalDb();
    if (_pwdListSaved.isNotEmpty) {
      await _showPwds(_pwdListSaved);
    }
    _emitState();
  }

  Future<void> _saveAllToLocalDb() async {
    for (var element in _pwdList) {
      await db.insertPwd(element);
    }
  }

  Future<void> updatePwdOnDb(PwdEntity pwd) async {
    await db.updatePwd(pwd);
  }

  void loadPwdsFromFile() async {
    final res = await readContentFromFile();
    if (res == null) return;

    for (var item in res) {
      _pwdList.add(PwdEntity(
          id: Uuid().v4(),
          password: item[1],
          hint: item[0] == 'vuoto' ? '' : item[0],
          usageCount: 0));
    }
    await _saveAllToLocalDb();
    await _showPwds(_pwdList);
  }

  void toggleSearch() {
    isSearching = !isSearching;
    _emitState();
  }

  void searchThis(String inputString) {
    List<PwdEntity> filteredList = [];

    if (inputString.isEmpty || !isSearching) {
      _pwdListShow = _pwdList;
      return;
    }
    for (int i = 0; i < _len; i++) {
      if (_pwdList[i].hint.toLowerCase().contains(inputString.toLowerCase())) {
        filteredList.add(_pwdList[i]);
      }
    }
    _pwdListShow = filteredList;

    _emitState();
  }

  Future<void> loadPwdsFromLocalDb() async {
    try {
      _pwdListSaved = await db.getAllPwds();
      _pwdListSaved.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    } catch (e) {
      print("Failed to load passwords: $e");
    }
  }

  Future<void> _showPwds(List<PwdEntity> newPwds) async {
    isLoading = true;
    int lenAll = newPwds.length;
    //final lenShowed = _pwdListShow.length;
    for (int i = lenAll - 50; i < lenAll; i++) {
      final pwd = newPwds[i];
      _pwdListShow.add(pwd);
      _opacityFlags.add(false);
      if (i == 0) {
        _emitState();
      }
      Future.delayed(const Duration(milliseconds: 100), () {
        _opacityFlags[i] = true;
        _pwdListSaved = _pwdListShow;
        _emitState(); // Emit after changing opacity
      });
    }
    isLoading = false;
    _emitState();
  }

  void editPwd(PwdEntityEdit pwdModified, int index) async {
    List<PwdEntity> updatedList = List.from(_pwdList);

    updatedList[index] = updatedList[index].copyWith(
      hint: pwdModified.hint,
      password: pwdModified.password,
    );

    await updatePwdOnDb(updatedList[index]);

    _pwdList = updatedList;
    _pwdListShow = List.from(updatedList);

    _emitState();
  }

  Future<void> generatePwds(String? secretText, File? image) async {
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
    int i = 0;
    final c = combineStrings(pass1, pass2);
    for (String item in c) {
      _pwdList.add(PwdEntity(
          id: Uuid().v4(), hint: 'Hint $i', password: item, usageCount: 0));
      _opacityFlags.add(false);
      i++;
    }
    _len = _pwdList.length;
    await _saveAllToLocalDb();
    await _showPwds(List.from(_pwdList));
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future get _localPath async {
    if (await _requestPermission(Permission.storage)) {
      final directory = await AndroidPathProvider.downloadsPath;
      return directory;
    }
  }

  Future<File> get _localFile async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyyMMddkkmm').format(now);
    final path = await _localPath;

    return File('$path/Notepass_pwdc$formattedDate.txt');
  }

  void wrightContentToFile() async {
    try {
      /*  List<PwdEntity> data = await db.getAllPwds();
      if (data.isEmpty) return; */

      final file = await _localFile;
      String result = '';

      for (var element in _pwdList) {
        result +=
            '${element.hint == '' ? 'vuoto' : element.hint}<|||>${element.password}<|||>${element.usageCount}<|||>';
      }

      file.writeAsString(result);
    } on Exception catch (e) {
      debugPrint('wrightContentToFile error : $e');
    }
  }

  _emitState() {
    emit(PwdListLoaded(
        pwdListShow:
            List.from(_pwdListShow), // Lista attuale senza il nuovo elemento
        opacityFlags: List.from(_opacityFlags),
        isSearching: isSearching,
        isLoading: isLoading));
  }
}

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/core/injector.dart';
import 'package:pwd_gen/core/utility.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';
import 'package:pwd_gen/repository/pwd_repository.dart';
import 'package:uuid/uuid.dart';

part 'pwd_list_state.dart';

class PwdListCubit extends Cubit<PwdListState> {
  PwdRepository pwdRepository;
  PwdListCubit(this.pwdRepository) : super(PwdListInitial());
  List<PwdEntity> pwdList = []; // this is the state
  List<PwdEntity> pwdListSaved = []; // read from db
  List<PwdEntity> pwdFilteredList = []; // filtered
  List<PwdEntity> pwdListShow = []; // this is animated
  List<bool> opacityFlags = [];
  bool isSearching = false;
  int addingIndex = 0;

  void loadPwdsFromDb() async {
    await loadPwdsFromLocalDb();

    if (pwdListSaved.isNotEmpty) {
      await showPwds(pwdListSaved);
    }

    addingIndex = pwdListSaved.length;
    emit(PwdListLoaded(
      pwdListShow: pwdListSaved,
      opacityFlags: opacityFlags,
      isSearching: false,
      pwdFilteredList: pwdListSaved,
    ));
  }

  Future<void> loadPwdsFromLocalDb() async {
    try {
      pwdListSaved = await pwdRepository.getAllPwds();
      pwdListSaved.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    } catch (e) {
      print("Failed to load passwords: $e");
    }
  }

  Future<void> showPwds(List<PwdEntity> newPwds) async {
    int lenAll = newPwds.length;
    //final lenShowed = pwdListShow.length;
    for (int i = lenAll - 50; i < lenAll; i++) {
      final pwd = newPwds[i];
      pwdListShow.add(pwd);
      opacityFlags.add(false);
      if (i == 0) {
        emit(PwdListLoaded(
          pwdListShow:
              List.from(pwdListShow), // Lista attuale senza il nuovo elemento
          opacityFlags: List.from(opacityFlags),
          isSearching: false,
          pwdFilteredList: List.from(pwdList),
        ));
      }
      await Future.delayed(const Duration(milliseconds: 50));

      opacityFlags[i] = true;
      pwdListSaved = pwdListShow;
      emit(PwdListLoaded(
        pwdListShow:
            List.from(pwdListShow), // Lista attuale senza il nuovo elemento
        opacityFlags: List.from(opacityFlags),
        isSearching: false,
        pwdFilteredList: List.from(pwdList),
      ));
    }
  }

  void editPwd(PwdEntityEdit pwdModified, int index) {
    List<PwdEntity> updatedList = List.from(pwdList);

    updatedList[index] = updatedList[index].copyWith(
      hint: pwdModified.hint,
      password: pwdModified.password,
    );

    pwdList = updatedList;
    pwdListShow = List.from(updatedList);

    emit(PwdListLoaded(
      pwdListShow: List.from(pwdList),
      opacityFlags: List.from(opacityFlags),
      isSearching: false,
      pwdFilteredList: List.from(pwdList),
    ));
  }

  Future<void> generatePwds(String? secretText, File? image) async {
    final List<String> numForRand =
        getIt<String>(instanceName: 'fixedString').split(',');

    if (image == null) {
      return;
    }
    final imageHash = generateImageHash(image);
    if (secretText == null) {
      return;
    }
    final stringHash = generateStringHash(secretText);
    debugPrint(imageHash);
    debugPrint(stringHash);
    var pass1 = CreatePasswords.allDonePreDB(imageHash, numForRand);
    var pass2 = CreatePasswords.allDonePreDB(stringHash, numForRand);
    int i = 0;
    final c = combineStrings(pass1, pass2);
    for (String item in c) {
      pwdList.add(PwdEntity(
          id: Uuid().v4(), hint: 'Hint $i', password: item, usageCount: 0));
      opacityFlags.add(false);
      i++;
    }
    await showPwds(List.from(pwdList));
  }
}

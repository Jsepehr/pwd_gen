import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/core/ingector.dart';
import 'package:pwd_gen/core/utility.dart';
import 'package:pwd_gen/data/models/pwd_model.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';
import 'package:pwd_gen/repository/pwd_repository.dart';
import 'package:uuid/uuid.dart';

part 'pwd_list_state.dart';

class PwdListCubit extends Cubit<PwdListState> {
  PwdRepository pwdRepository;
  PwdListCubit(this.pwdRepository) : super(PwdListInitial());

  List<PwdEntity> pwdList = [];
  List<PwdEntity> pwdListSaved = [];
  List<PwdEntity> pwdFilteredList = [];
  List<PwdEntity> pwdListShow = [];
  List<bool> opacityFlags = [];
  bool isSearching = false;
  int addingIndex = 0;
  TextEditingController secretString = TextEditingController();

  void loadPwdsFromDb() async {
    await loadPwdsFromLocalDb();

    await showPwds(pwdListSaved);
    addingIndex = pwdListSaved.length;
    emit(PwdListLoaded(
        secretString: secretString,
        pwdListShow: pwdListSaved,
        opacityFlags: opacityFlags,
        isSearching: false,
        pwdList: pwdListSaved,
        pwdListSaved: pwdListSaved,
        pwdFilteredList: pwdListSaved,
        addingIndex: 0));
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
    for (var pwd in newPwds) {
      opacityFlags.add(false); // Add initial opacity flag
      await Future.delayed(const Duration(milliseconds: 50));
      pwdListShow.add(pwd); // Add the new password to the display list
      pwdList.add(pwd);
      await Future.delayed(const Duration(milliseconds: 50));
      opacityFlags[pwdListShow.length - 1] =
          true; // Activate the fade-in animation
    }

    debugPrint('Final pwdListShow length: ${pwdListShow.length}');
    debugPrint('Final pwdList length: ${pwdList.length}');
  }

  void generatePwds() async {
    final List<String> numForRand =
        getIt<String>(instanceName: 'fixedString').split(',');
    final hash1 = 'asjdhfksjdhfiusdgfiasdfgashdfgsdfsdf';
    final hash2 = 'knkdmfodifhdifb76tfsghfbsdfjdhfisdf9';
    var pass1 = CreatePasswords.allDonePreDB(hash1, numForRand);
    var pass2 = CreatePasswords.allDonePreDB(hash2, numForRand);
    for (var item in combineStrings(pass1, pass2)) {
      pwdList.add(PwdEntity(
          id: Uuid().v4(), hint: 'Hint', password: item, usageCount: 0));
    }
    await showPwds(pwdList);
  }
}

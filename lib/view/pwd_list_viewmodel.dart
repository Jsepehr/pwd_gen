import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pwd_gen/core/utility.dart';
import 'package:pwd_gen/data/local/password_repository.dart';
import 'package:pwd_gen/data/models/pwd_model.dart';

import 'package:uuid/uuid.dart';

class PwdListViewModel extends GetxController {
  final PasswordRepository _repository = Get.find<PasswordRepository>();
  List<PwdModel> pwdList = [];
  List<PwdModel> pwdListSaved = [];
  List<PwdModel> pwdFilteredList = [];
  RxList<PwdModel> pwdListShow = RxList<PwdModel>();
  RxList<bool> opacityFlags = RxList<bool>();
  RxBool isSearching = false.obs;
  int x = 0;
  @override
  void onInit() async {
    await loadPwdsFromLocalDb();
    debugPrint('${pwdListSaved.length}');
    if (pwdListSaved.isNotEmpty) {
      await showPwds(pwdListSaved);
      x = pwdListSaved.length;
    } else {
      print("pwdList is empty after loadPwds.");
    }
    super.onInit();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      pwdListShow.assignAll(pwdList);
    }
  }

  void filterPwds(String query) {
    pwdFilteredList.assignAll(pwdListShow
        .where((pwd) => pwd.hint.toLowerCase().contains(query.toLowerCase())));
    if (isSearching.value && query.isNotEmpty) {
      pwdListShow.assignAll(pwdFilteredList);
      debugPrint('$pwdListShow');
    } else {
      debugPrint('$pwdList');
      pwdListShow.assignAll(pwdList);
    }
  }

  Future<void> loadPwdsFromLocalDb() async {
    try {
      pwdListSaved = await _repository.getAllPwds();
      pwdListSaved.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    } catch (e) {
      print("Failed to load passwords: $e");
    }
  }

  Future<void> insertNewPwd(String hint, String password) async {
    try {
      final id = Uuid().v4();
      final newPwd =
          PwdModel(id: id, hint: hint, password: password, usageCount: 0);
      await _repository.insertPwd(newPwd);
    } catch (e) {
      print("Failed to add password: $e");
    }
  }

  Future<void> saveOnLocalDb() async {
    try {
      // final List<PwdModel> batchList = pwdList.toList();
      debugPrint('saveOnLocalDb ${pwdList.length}');
      for (int i = x; i < pwdList.length; i++) {
        debugPrint('---- inserting $i ----');
        await _repository.insertPwd(pwdList[i]);
      }
      x = pwdList.length;
      // await loadPwds();
    } catch (e) {
      print("Failed to add all passwords: $e");
    }
  }

  Future<void> editPwdById(PwdModel editedPwd) async {
    try {
      // Increment the usageCount
      final updatedPwd = PwdModel(
        id: editedPwd.id,
        hint: editedPwd.hint,
        password: editedPwd.password,
        usageCount: editedPwd.usageCount + 1, // Increment usage count
      );

      // Save to the database
      await _repository.updatePwd(updatedPwd);
    } catch (e) {
      // Handle any errors gracefully
      print("Failed to edit password: $e");
    }
  }

  Future<void> showPwds(List<PwdModel> newPwds) async {
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


}

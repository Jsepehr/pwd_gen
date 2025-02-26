import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'pwd_editor_state.dart';

class PwdEditorCubit extends Cubit<PwdEditorState> {
  PwdEditorCubit() : super(PwdEditorInitial());

  TextEditingController hintController = TextEditingController();
  TextEditingController pwdController = TextEditingController();

  String pwd = '';
  String hint = '';

  void modifyPwd(String newPwd) {
    pwd = newPwd;
  }

  void modifyHint(String newHint) {
    hint = newHint;
  }

  void init() {
    _emitState();
  }

  _emitState() {
    emit(PwdEditorLoaded(
        pwd: pwd,
        hint: hint,
        hintController: hintController,
        pwdController: pwdController));
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'pwd_editor_state.dart';

class PwdEditorCubit extends Cubit<PwdEditorState> {
  PwdEditorCubit() : super(PwdEditorInitial());



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
        hint: hint,));
  }
}

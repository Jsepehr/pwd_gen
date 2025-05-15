import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'pwd_keyword_state.dart';

class PwdKeyWordCubit extends Cubit<PwdKeyWordState> {
  PwdKeyWordCubit() : super(PwdKeyWordInitial());

  TextEditingController keyWord = TextEditingController();

  FocusNode focusNode = FocusNode();

  String keyWordStr = '';

  void init() {
    _emitState();
  }

  _emitState() {
    emit(PwdKeyWordLoaded(
      focusNode: focusNode,
      keyWord: keyWordStr,
      hintController: keyWord,
    ));
  }
}

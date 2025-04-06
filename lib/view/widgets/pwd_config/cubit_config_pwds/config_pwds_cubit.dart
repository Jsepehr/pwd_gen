import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'config_pwds_state.dart';

class ConfigPwdsCubit extends Cubit<ConfigPwdsState> {
  ConfigPwdsCubit() : super(ConfigPwdsInitial());
  String secretPhrase = '';
  bool isGenerateBtnEnabled = false;
  bool isImageBtnEnabled = false;
  FocusNode focusNode = FocusNode();

  void emitState(File? image) {
    isGenerateBtnEnabled = false;
    isImageBtnEnabled = false;
    isImageBtnEnabled = secretPhrase.isNotEmpty;
    isGenerateBtnEnabled = secretPhrase.isNotEmpty && image != null;
    emit(ConfigPwdsLoaded(
      focusNode :focusNode,
      isGenerateBtnEnabled: isGenerateBtnEnabled,
      isImageBtnEnabled: isImageBtnEnabled,
      secretPhrase: secretPhrase,
    ));
  }
}

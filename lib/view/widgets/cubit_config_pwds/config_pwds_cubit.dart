import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/core/utility.dart';

part 'config_pwds_state.dart';

class ConfigPwdsCubit extends Cubit<ConfigPwdsState> {
  ConfigPwdsCubit() : super(ConfigPwdsInitial());

  TextEditingController secretPhraseCtl = TextEditingController();
  bool isGenerateBtnEnabled = false;
  bool isImageBtnEnabled = false;
  File? image;

  void enableImageBtn() {
    isImageBtnEnabled = secretPhraseCtl.text.isNotEmpty;
    debugPrint('$isImageBtnEnabled');
    emitState();
  }

  Future<void> openGallery() async {
    image = await selectImage();
    if (image != null && secretPhraseCtl.text.isNotEmpty) {
      isGenerateBtnEnabled = true;
    }
    emitState();
    image = null;
  }

  @override
  Future<void> close() {
    secretPhraseCtl.dispose(); // Esegui il dispose del TextEditingController
    return super.close(); // Chiama il metodo close della classe base
  }

  void emitState() {
    emit(ConfigPwdsLoaded(
      image: image,
      isGenerateBtnEnabled: isGenerateBtnEnabled,
      isImageBtnEnabled: isImageBtnEnabled,
      secretPhrase: secretPhraseCtl.text,
    ));
  }
}

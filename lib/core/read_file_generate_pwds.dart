import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '/core/notepass_encrypt.dart';
import '/core/utility.dart';
import '/domain/pwd_entity.dart';
import '/view/widgets/shared/app_dialog.dart';

class ReadFileGeneratePwds {
  static FilePickerResult? _kmgFile;

  Future<List<PwdEntity>?> readContentFromFile() async {
    _kmgFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (_kmgFile == null) {
      KeymageState.applyState(KeymageStateEnums.kmgFileNotSelected);
      return null;
    }
    final file = _kmgFile!.files;
    String fileName = file.first.name;
    RegExp expOld = RegExp(r'Notepass_pwdc\d{5,}\.txt');
    if (expOld.firstMatch(fileName) != null) {
      final res = await _verifyOldVersionFile(file);
      if (res == null) {
        KeymageState.applyState(KeymageStateEnums.somethingWentWrong);
      }
      return res;
    }
    if (!_kmgFile!.files.first.name.contains('.kmg')) {
      KeymageState.applyState(KeymageStateEnums.wrongSelectedFileFormat);
      return null;
    }
    RegExp exp = RegExp(r'Keymage\d{5,}\.kmg'); // changed to kmg format
    if (file[0].extension! == 'kmg' && exp.firstMatch(fileName) == null) {
      KeymageState.applyState(KeymageStateEnums.fileNameFormatError);
      return null;
    }
    return null;
  }

  Future<List<PwdEntity>?> _verifyOldVersionFile(List<PlatformFile> file,
      {int splitNumber = 2}) async {
    try {
      List<PwdEntity> pwdList = [];
      var myFile = await File(file[0].path!).readAsString();
      List fileContent = splitList(myFile.split('<|||>'), splitNumber);
      for (var item in fileContent) {
        pwdList.add(PwdEntity(
            id: Uuid().v4(),
            password: item[1],
            hint: item[0] == 'vuoto' ? '' : item[0],
            usageDate: '0'));
      }
      return pwdList;
    } on Exception catch (_) {
      final res = await _verifyOldVersionFile(file, splitNumber: 3);
      if (res != null) return res;
      return res;
    }
  }

  Future<List<PwdEntity>> imageSelectionAndGenPwds() async {
    if (_kmgFile == null) {
      throw ('_kmgFile is null');
    }
    File selectedFile = File(_kmgFile!.files.single.path!);
    final image = await selectImage();
    if (image == null) {
      KeymageState.applyState(KeymageStateEnums.imageNotSelected);
      return [];
    }
    final imageHash = generateImageHash(image);
    final pwdList = await BinaryEncrypt.readFileAndValidateHash(
        imageHash: imageHash, file: selectedFile);
    if (pwdList.isNotEmpty) {
      KeymageState.applyState(KeymageStateEnums.endOk);
    }
    return pwdList;
  }
}

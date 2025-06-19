import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/core/notepass_encrypt.dart';
import '/domain/pwd_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const appFolderName = 'MPG';
const keyUserPrefPath = 'path';
const keyUserPrefFileName = 'fileName';

enum MPGStateEnums {
  permissionDenied,
  ok,
  fileNameFormatError,
  corruptedFile,
  permissionGranted,
  imageNotSelected,
  wrongImageSelected,
  npsFileNotSelected,
  wrongSelectedFileFormat,
  somethingWentWrong,
  pwdsGeneratedSuccess,
  fileGenSuccess,
  unknown,
  oldImportDone,
  showNotificationSecretImageDecrypt,
  showNotificationSecretImageEncrypt,
}

Future<String?> loadSavedDirectory() async {
  final prefs = await SharedPreferences.getInstance();

  return prefs.getString(keyUserPrefPath);
}

Future<String?> loadSavedFileName() async {
  final prefs = await SharedPreferences.getInstance();

  return prefs.getString(keyUserPrefFileName);
}

Future<void> appDialog(BuildContext context,
    {bool barrierDismissible = false}) {
  const fileStoredOk =
      'File stored on\nDownloads > MPG folder\nsuccessfully :)';
  const imageNotSelected = 'Image not selected';
  const npsNotSelected = 'nps file is not selected!';
  const wrongImage = 'wrong image selected, try again';
  const wrongSelectedFileFormat =
      'Wrong selected file format (.mpg) or name mismatch';
  const somethingWentWrong = 'Something went wrong! :(';
  const corruptedFile = 'The file is corrupted';
  const permissionNotGranted =
      '"This app needs full storage access to save files. Please enable it in settings."';
  const selectSecretImageDecrypt =
      'Select the the Secret image that you used for the file backup generation';
  const selectSecretImageEncrypt =
      'Select the Secret image: Remember this image file or save it somewhere in your local disk!\nThis image will use by app for retrieving your passwords.';

  String finalRes = '-----';
  switch (MPGState.currentState) {
    case MPGStateEnums.fileGenSuccess:
      finalRes = fileStoredOk;
      break;
    case MPGStateEnums.imageNotSelected:
      finalRes = imageNotSelected;
      break;
    case MPGStateEnums.wrongImageSelected:
      finalRes = wrongImage;
      break;
    case MPGStateEnums.somethingWentWrong:
      break;
    case MPGStateEnums.permissionDenied:
      finalRes = permissionNotGranted;
      break;
    case MPGStateEnums.npsFileNotSelected:
      finalRes = npsNotSelected;
      break;
    case MPGStateEnums.wrongSelectedFileFormat:
      finalRes = wrongSelectedFileFormat;
      break;
    case MPGStateEnums.corruptedFile:
      finalRes = corruptedFile;
      break;
    case MPGStateEnums.showNotificationSecretImageDecrypt:
      finalRes = selectSecretImageDecrypt;
      break;
    case MPGStateEnums.showNotificationSecretImageEncrypt:
      finalRes = selectSecretImageEncrypt;
      break;
    default:
      finalRes = somethingWentWrong;
  }
  return showDialog(
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (context) {
      return Center(
        child: Material(
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 20, 36), // Colore di sfondo
              borderRadius: BorderRadius.circular(12), // Angoli arrotondati
              border: Border.all(
                // Bordo bianco 2px
                color: const Color.fromARGB(107, 255, 255, 255),
                width: 1,
              ),
            ),
            constraints: BoxConstraints(
              maxWidth: 300, // Imposta una larghezza massima
            ),
            padding: EdgeInsets.all(20), // Aggiungi un padding interno

            child: IntrinsicWidth(
              // Adatta la larghezza al contenuto
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Importante: fa espandere la colonna solo quanto necessario
                children: [
                  Text(
                    finalRes,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.done_all_outlined),
                    label: Text('OK'), // Aggiungi un testo al pulsante
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class MPGState {
  static MPGStateEnums _currentState = MPGStateEnums.unknown;
  static void applyState(MPGStateEnums state) {
    debugPrint('${state.name}  sepehr');
    _currentState = state;
  }

  static get currentState => _currentState;
}

class CreatePasswords {
  static List<String> allDonePreDB(String? digest, List<String> numsForRand) {
    List<int> seed = indexAnalyses(
      listToString(
        strToASCII(digest!),
      ),
    );
    List upAbc = randomizeList(makeArrASHII(26, 65), seed);
    List lwdAbc = randomizeList(makeArrASHII(26, 97), seed);
    List numbers = randomizeList(makeArrASHII(10, 48), seed);
    List specialChars = randomizeList(makeArrASHII(47 - 32, 32), seed);

    List<String> randomized = randomizeListString(numsForRand, seed);
    List<String> listapsUnico =
        select(lwdAbc, upAbc, specialChars, numbers, randomized);
    listapsUnico = spiltList(listapsUnico);

    return listapsUnico;
  }
}

List<int> makeArrASHII(int l, int fine) {
  //dovrebbe generare una lista numeri
  List<int> list = List<int>.generate(l, (i) => i + fine);
  return list;
}

//una funzione che prende una stringa e restituisce una lista di numeri
List<int> strToASCII(String s) {
  List<int> list = [];

  for (var i = 0; i < s.length; i++) {
    list.add(s.codeUnitAt(i));
  }

  return list;
}

//split list to più lists
List<String> spiltList(List inputList) {
  List<String> listOfLists = [];
  var tmpList = [];
  for (var i = 0; i < inputList.length; i++) {
    tmpList.add(inputList[i]);
    if ((i + 1) % 5 == 0) {
      listOfLists.add(tmpList.join());
      tmpList = [];
    }
  }

  return listOfLists;
}

List<String> combineStrings(List<String> list1, List<String> list2) {
  List<String> finalList = [];
  var tmpStr = "";
  for (var i = 0; i < 50; i++) {
    tmpStr = list1[i] + list2[i];
    finalList.add(tmpStr);
    tmpStr = "";
  }
  return finalList;
}

// list to string
listToString(List l) {
  return l.join();
}

List<String> randomizeListString(
    List<String> listaDaMescolare, List<int> seed) {
  List<String> listaMescolata = [];

  for (var i = 0; i < seed.length; i++) {
    listaMescolata
        .add((listaDaMescolare[seed[i] % listaDaMescolare.length]).toString());
  }

  return listaMescolata;
}

List<int> randomizeList(List<int> listaDaMescolare, List<int> seed) {
  List<int> listaMescolata = [];

  for (var i = 0; i < seed.length; i++) {
    listaMescolata.add(listaDaMescolare[seed[i] % listaDaMescolare.length]);
  }

  return listaMescolata;
}

List<String> select(List a, List b, List c, List d, List seed) {
  List<String> result = [];
  int count = 0;
  for (var item in seed) {
    for (var i = 0; i < item.length; i++) {
      switch (item[i]) {
        case '0':
          result.add(String.fromCharCode(a[count % a.length]));
          break;
        case '1':
          result.add(String.fromCharCode(b[count % b.length]));
          break;
        case '2':
          result.add(String.fromCharCode(c[count % c.length]));
          break;
        case '3':
          result.add(String.fromCharCode(d[count % d.length]));
          break;
      }
      count++;
    }
  }
  return result;
}

//questo fa seed
List<int> indexAnalyses(String s) {
  List<int> result = [];
  for (int i = 0; i < 10; i++) {
    switch (i) {
      case 0:
        for (var i = 0; i < s.length; i++) {
          if (s[i] == '0') {
            result.add(i);
          }
        }

        break;
      case 1:
        for (var i = 0; i < s.length; i++) {
          if (s[i] == '1') {
            result.add(i);
          }
        }
        break;
      case 2:
        for (var i = 0; i < s.length; i++) {
          if (s[i] == '2') {
            result.add(i);
          }
        }
        break;
      case 3:
        for (var i = 0; i < s.length; i++) {
          if (s[i] == '3') {
            result.add(i);
          }
        }
        break;
      case 4:
        for (var i = 0; i < s.length; i++) {
          if (s[i] == '4') {
            result.add(i);
          }
        }
        break;
      case 5:
        for (var i = 0; i < s.length; i++) {
          if (s[i] == '5') {
            result.add(i);
          }
        }
        break;
      case 6:
        for (var i = 0; i < s.length; i++) {
          if (s[i] == '6') {
            result.add(i);
          }
        }
        break;
      case 7:
        for (var i = 0; i < s.length; i++) {
          if (s[i] == '7') {
            result.add(i);
          }
        }
        break;
      case 8:
        for (var i = 0; i < s.length; i++) {
          if (s[i] == '8') {
            result.add(i);
          }
        }
        break;
      case 9:
        for (var i = 0; i < s.length; i++) {
          if (s[i] == '9') {
            result.add(i);
          }
        }
        break;
    }
  }
  return result;
}

String generateImageHash(File file) {
  var imageByte = file.readAsBytesSync().toString();
  var bytes = utf8.encode(imageByte); // data being hashed
  String digest = sha256.convert(bytes).toString();
  return digest;
}

String generateStringHash(String str) {
  var bytes1 = utf8.encode(str); // data being hashed
  var digest1 = sha256.convert(bytes1).toString();
  return digest1;
}

Future<File?> selectImage() async {
  final first = ImagePicker();
  final imageFile = await first.pickImage(
    source: ImageSource.gallery,
    maxWidth: 600,
  );

  if (imageFile == null) return null;

  File storedImage = File(imageFile.path);
  return storedImage;
}

List<PwdEntity> filterListOfPwd(String needle, List<PwdEntity> lPwd) {
  List<PwdEntity> tmp = [];
  if (needle != '') {
    for (var element in lPwd) {
      if (element.hint.contains(needle)) {
        tmp.add(element);
      }
    }
    if (tmp.isNotEmpty) {
      return tmp;
    } else {
      return [];
    }
  } else {
    return lPwd;
  }
}

///the function splitList generates a list of lists
List<List<String>> splitList(List<String> input, int chunkSize) {
  final tmpLists = List<String>.filled(chunkSize, '');
  List<List<String>> result = [];

  for (int i = 0; i < input.length - 1; i = chunkSize + i) {
    for (int k = 0; k < tmpLists.length; k++) {
      tmpLists[k] = input[i + k];
    }
    result.add(tmpLists.toList());
  }
  return result;
}

class ReadNpsFile {
  static FilePickerResult? _npsFile;

  Future<List<PwdEntity>?> readContentFromFile() async {
    MPGState.applyState(MPGStateEnums.ok);
    _npsFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (_npsFile == null) {
      MPGState.applyState(MPGStateEnums.npsFileNotSelected);
      return null;
    }
    final file = _npsFile!.files;
    String fileName = file.first.name;
    RegExp expOld = RegExp(r'Notepass_pwdc\d{5,}\.txt');
    if (expOld.firstMatch(fileName) != null) {
      final res = await _verifyOldVersionFile(file);
      if(res == null) {
        MPGState.applyState(MPGStateEnums.somethingWentWrong);
      }
      return res;
    }
    if (!_npsFile!.files.first.name.contains('.nps')) {
      MPGState.applyState(MPGStateEnums.wrongSelectedFileFormat);
      return null;
    }
    RegExp exp = RegExp(r'MPG\d{5,}\.nps'); // changed to nps format
    if (file[0].extension! == 'nps' && exp.firstMatch(fileName) == null) {
      MPGState.applyState(MPGStateEnums.fileNameFormatError);
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
    if (MPGState.currentState != MPGStateEnums.ok) {
      return [];
    }
    if (_npsFile == null) {
      throw ('_npsFile is null');
    }
    File selectedFile = File(_npsFile!.files.single.path!);
    final image = await selectImage();
    if (image == null) {
      MPGState.applyState(MPGStateEnums.imageNotSelected);
      return [];
    }
    final imageHash = generateImageHash(image);
    final pwdList = await BinaryEncrypt.readFileAndValidateHash(
        imageHash: imageHash, file: selectedFile);
    if (pwdList.isNotEmpty) {
      MPGState.applyState(MPGStateEnums.ok);
    }
    return pwdList;
  }
}

Future<List<String>?> getImageHashes() async {
  final prefs = await SharedPreferences.getInstance();
  final imgHashes = prefs.getString(
    'imageHash',
  );
  if (imgHashes == null) return null;
  return json.decode(imgHashes) as List<String>;
}

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';

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

combineStrings(List elle1, List elle2) {
  var listaFinale = [];
  var tmpStr = "";
  for (var i = 0; i < 50; i++) {
    tmpStr = elle1[i] + elle2[i];
    listaFinale.add(tmpStr);
    tmpStr = "";
  }
  return listaFinale;
}

// list to string
listToString(List l) {
  return l.join();
}

List<String> randomizeListString(List listaDaMescolare, List<int> seed) {
  List<String> listaMescolata = [];

  for (var i = 0; i < seed.length; i++) {
    listaMescolata
        .add((listaDaMescolare[seed[i] % listaDaMescolare.length]).toString());
  }

  return listaMescolata;
}

List<int> randomizeList(List listaDaMescolare, List<int> seed) {
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

Future<String> generateImageHash(File file) async {
  var imageByte = file.readAsBytesSync().toString();
  var bytes = utf8.encode(imageByte); // data being hashed
  String digest = sha256.convert(bytes).toString();
  return digest;
}

String? generateStringHash(String str) {
  if (str == '') return null;
  var bytes1 = utf8.encode(str); // data being hashed
  var digest1 = sha256.convert(bytes1).toString();
  return digest1;
}

Future<String?> selectImage() async {
  final first = ImagePicker();
  final imageFile = await first.pickImage(
    source: ImageSource.gallery,
    maxWidth: 600,
  );

  if (imageFile == null) return null;

  File storedImage = File(imageFile.path);
  return await generateImageHash(storedImage);
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

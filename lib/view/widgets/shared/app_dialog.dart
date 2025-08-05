import 'package:flutter/material.dart';
import 'package:pwd_gen/core/app_pallet.dart';
import 'package:vibration/vibration.dart';

import '/core/dictionary.dart';
import '/core/utility.dart';

enum MPGStateEnums {
  corruptedFile,
  endOk,
  endWithError,
  fileGenSuccess,
  fileNameFormatError,
  imageNotSelected,
  kmgFileNotSelected,
  oldImportDone,
  permissionDenied,
  permissionGranted,
  pwdsGeneratedSuccess,
  reset,
  showNotificationSecretImageDecrypt,
  showNotificationSecretImageEncrypt,
  somethingWentWrong,
  start,
  unknown,
  wrongImageSelected,
  wrongSelectedFileFormat,
}

Future<bool?> appDialogV(
    {required BuildContext context, bool? barrierDismissible = true}) async {
  if (await Vibration.hasVibrator()) {
    Vibration.vibrate();
  }
  return appDialog(context, barrierDismissible: barrierDismissible ?? true);
}

Future<bool?> appDialog(BuildContext context,
    {bool barrierDismissible = false}) {
  String finalRes = '-----';
  Color finalColor = AppPallet.buttonBorderSides;
  switch (MPGState.currentState) {
    case MPGStateEnums.fileGenSuccess:
      finalColor = AppPallet.success;
      finalRes = fileStoredOk;
      break;
    case MPGStateEnums.imageNotSelected:
      finalRes = imageNotSelected;
      finalColor = AppPallet.error;
      break;
    case MPGStateEnums.reset:
      finalRes = resetAllPwds;
      finalColor = AppPallet.error;
      break;
    case MPGStateEnums.wrongImageSelected:
      finalRes = wrongImage;
      finalColor = AppPallet.error;
      break;
    case MPGStateEnums.somethingWentWrong:
      finalRes = somethingWentWrong;
      finalColor = AppPallet.error;
      break;
    case MPGStateEnums.permissionDenied:
      finalRes = permissionNotGranted;
      finalColor = AppPallet.error;
      break;
    case MPGStateEnums.kmgFileNotSelected:
      finalRes = kmgNotSelected;
      finalColor = AppPallet.error;
      break;
    case MPGStateEnums.wrongSelectedFileFormat:
      finalRes = wrongSelectedFileFormat;
      finalColor = AppPallet.error;
      break;
    case MPGStateEnums.corruptedFile:
      finalRes = corruptedFile;
      finalColor = AppPallet.error;
      break;
    case MPGStateEnums.showNotificationSecretImageDecrypt:
      finalRes = selectSecretImageDecrypt;
      finalColor = AppPallet.bottomSheetTitleIcon;
      break;
    case MPGStateEnums.showNotificationSecretImageEncrypt:
      finalRes = selectSecretImageEncrypt;
      finalColor = AppPallet.bottomSheetTitleIcon;
      break;
    default:
      finalRes = somethingWentWrong;
      finalColor = AppPallet.error;
  }
  return showDialog(
    barrierDismissible: barrierDismissible,
    context: context,
    builder: (context) {
      return Center(
        child: Material(
          child: Container(
            decoration: BoxDecoration(
              color: AppPallet.bottomSheetBG, // Colore di sfondo
              borderRadius: BorderRadius.circular(12), // Angoli arrotondati
              border: Border.all(
                // Bordo bianco 2px
                color: finalColor,
                width: 3,
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
                      Navigator.of(context).pop(true);
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
  ).then((value) async {
    return value;
  });
}

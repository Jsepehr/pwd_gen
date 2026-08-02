import 'package:flutter/material.dart';

import '/core/app_shared_preferences.dart';
import '/core/dictionary/app_strings.dart';
import '/core/utility.dart';
import '/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import '/view/widgets/shared/app_dialog.dart';

/// Confirms the user's identity before a destructive action. Uses whichever
/// method the user chose for unlocking the app: their custom password if
/// that's their entry mode, otherwise device biometrics.
Future<bool> confirmIdentity(BuildContext context, PwdListCubit cubit) async {
  final entryMode = await AppSharedPreferences.loadEntryMode();
  if (entryMode != UserEntryMode.customPwd) {
    await cubit.authenticate();
    return cubit.isUserAuthenticated;
  }
  if (!context.mounted) return false;
  final controller = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(AppStrings.enterYourPassword),
      content: TextField(
        controller: controller,
        obscureText: true,
        autofocus: true,
        decoration: InputDecoration(hintText: AppStrings.passwordHere),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            final savedPwd = await AppSharedPreferences.loadPwdHash();
            final inputHash = generateStringHash(controller.text);
            Navigator.of(dialogContext)
                .pop(savedPwd != null && inputHash == savedPwd);
          },
          child: Text(AppStrings.confirm),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Picks a secret image and writes the whole vault to an encrypted .kmg
/// backup file in Downloads.
Future<void> exportVaultFlow(BuildContext context, PwdListCubit cubit) async {
  cubit.setIsLoadingState(true);
  await cubit.requestStoragePermission();
  if (KeymageState.currentState != KeymageStateEnums.permissionGranted) {
    if (!context.mounted) return;
    await appDialogV(context: context);
  }
  KeymageState.applyState(KeymageStateEnums.showNotificationSecretImageEncrypt);
  if (!context.mounted) return;
  await appDialogV(context: context);
  final image = await selectImage();

  if (image == null) {
    KeymageState.applyState(KeymageStateEnums.imageNotSelected);
    if (!context.mounted) return;
    await appDialogV(context: context);
    cubit.setIsLoadingState(false);
    return;
  }
  final imageHash = generateImageHash(image);
  await AppSharedPreferences.savedImageHash(imageHash);
  if (!context.mounted) return;
  await cubit.wrightContentToFile(imageHash);
  if (!context.mounted) return;
  cubit.setIsLoadingState(false);
  await appDialogV(context: context);
}

/// Picks a .kmg backup file (or legacy export) plus the secret image used to
/// encrypt it, and merges the recovered passwords into the vault.
Future<void> importVaultFlow(BuildContext context, PwdListCubit cubit) async {
  try {
    KeymageState.applyState(KeymageStateEnums.start);
    await cubit.selectKeymageFile();
    if (KeymageState.currentState == KeymageStateEnums.oldImportDone) {
      return;
    }
    if (KeymageState.currentState == KeymageStateEnums.kmgFileNotSelected) {
      if (!context.mounted) return;
      await appDialogV(context: context);
      return;
    }
    KeymageState.applyState(
        KeymageStateEnums.showNotificationSecretImageDecrypt);
    if (!context.mounted) return;
    await appDialogV(context: context, barrierDismissible: true);
    await cubit.selectImageFileForPWDGenerator();
    if (KeymageState.currentState == KeymageStateEnums.endOk) {
      return;
    } else {
      if (!context.mounted) return;
      await appDialogV(context: context, barrierDismissible: true);
    }
  } catch (e) {
    // Broad catch, not `on Exception`: a malformed/malicious .kmg file can
    // trigger errors (e.g. RangeError) that don't extend Exception, and this
    // flow must never let one escape uncaught and crash the app.
    debugPrint('$e');
  }
}

/// Confirms, re-authenticates, then permanently deletes every saved password.
Future<void> resetVaultFlow(BuildContext context, PwdListCubit cubit) async {
  KeymageState.applyState(KeymageStateEnums.reset);
  final confirmed =
      await appDialogV(context: context, barrierDismissible: true);
  if (confirmed != true) return;
  if (!context.mounted) return;
  final authenticated = await confirmIdentity(context, cubit);
  if (!authenticated) return;
  cubit.resetList();
  KeymageState.applyState(KeymageStateEnums.endOk);
}

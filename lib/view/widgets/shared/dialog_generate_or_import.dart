import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/core/dictionary/app_strings.dart';

import '/core/app_pallet.dart';
import '/core/utility.dart';
import '/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import '/view/widgets/pwd_config/pwd_configure_bottom_sheet.dart';
import '/view/widgets/shared/app_dialog.dart';

class DialogGenerateOrImport extends StatelessWidget {
  const DialogGenerateOrImport({super.key});
  @override
  Widget build(BuildContext context) {
    debugPrint("Building DialogGenerateOrImport");
    final pwdListCubit = context.read<PwdListCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 100,
          width: 150,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallet.bottomSheetBG,
              side: BorderSide(
                  style: BorderStyle.solid,
                  width: 0.5,
                  color: AppPallet.buttonBorderSides),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.md),
                  bottomLeft: Radius.circular(AppRadius.md),
                ),
              ),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await showModalBottomSheet(
                  isScrollControlled: true,
                  enableDrag: !pwdListCubit.isLoading,
                  isDismissible: !pwdListCubit.isLoading,
                  context: context,
                  builder: (BuildContext bottomSheetContext) {
                    return BlocProvider.value(
                      value: bottomSheetContext.read<PwdListCubit>(),
                      child: PwdConfigureBottomSheet(),
                    );
                  });
            },
            child: Text(
              AppStrings.generate,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 8,
        ),
        SizedBox(
          height: 100,
          width: 150,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallet.bottomSheetBG,
              side: BorderSide(
                  style: BorderStyle.solid,
                  width: 0.5,
                  color: AppPallet.buttonBorderSides),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(AppRadius.md),
                  bottomRight: Radius.circular(AppRadius.md),
                ),
              ),
            ),
            onPressed: () async {
              try {
                KeymageState.applyState(KeymageStateEnums.start);
                await pwdListCubit.selectKeymageFile();
                if (KeymageState.currentState ==
                    KeymageStateEnums.oldImportDone) {
                  return;
                }
                if (KeymageState.currentState ==
                    KeymageStateEnums.kmgFileNotSelected) {
                  if (!context.mounted) return;
                  await appDialogV(
                    context: context,
                  );
                  Navigator.of(context).pop();
                  return;
                }
                KeymageState.applyState(
                    KeymageStateEnums.showNotificationSecretImageDecrypt);
                if (!context.mounted) return;
                await appDialogV(context: context, barrierDismissible: true);
                await pwdListCubit.selectImageFileForPWDGenerator();
                if (KeymageState.currentState == KeymageStateEnums.endOk) {
                  Navigator.of(context).pop();
                  return;
                } else {
                  if (!context.mounted) return;
                  await appDialogV(context: context, barrierDismissible: true);
                }
              } on Exception catch (e) {
                debugPrint('$e');
              }
              if (!context.mounted) return;
              Navigator.pop(context); // Handle Import action
            },
            child: Text(
              AppStrings.import,
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

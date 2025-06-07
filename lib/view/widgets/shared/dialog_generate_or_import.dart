import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/core/utility.dart';
import 'package:pwd_gen/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import 'package:pwd_gen/view/widgets/pwd_config/pwd_configure_bottom_sheet.dart';

class DialogGenerateOrImport extends StatelessWidget {
  const DialogGenerateOrImport({super.key});
  @override
  Widget build(BuildContext context) {
    final pwdListCubit = context.read<PwdListCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 100,
          width: 150,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), // Adjust the radius as needed
                  bottomLeft:
                      Radius.circular(15), // Adjust the radius as needed
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
            child: const Text('Generate'),
          ),
        ),
        SizedBox(
          width: 1,
        ),
        SizedBox(
          height: 100,
          width: 150,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15), // Adjust the radius as needed
                  bottomRight:
                      Radius.circular(15), // Adjust the radius as needed
                ),
              ),
            ),
            onPressed: () async {
              try {
                await pwdListCubit.selectMPGFile();
                if (MPGState.currentState == MPGStateEnums.oldImportDone) {
                  return;
                }
                if (MPGState.currentState != MPGStateEnums.ok) {
                  if (!context.mounted) return;
                  await appDialog(
                    context,
                  );
                  return;
                }
                MPGState.applyState(
                    MPGStateEnums.showNotificationSecretImageDecrypt);
                if (!context.mounted) return;
                await appDialog(context, barrierDismissible: true);
                MPGState.applyState(MPGStateEnums.ok);
                await pwdListCubit.selectImageFileForPWDGenerator();
                if (MPGState.currentState == MPGStateEnums.ok) return;
                if (!context.mounted) return;
                await appDialog(context, barrierDismissible: true);
              } on Exception catch (e) {
                // TODO
                debugPrint('$e');
              }
              if (!context.mounted) return;
              Navigator.pop(context); // Handle Import action
            },
            child: const Text('Import'),
          ),
        ),
      ],
    );
  }
}

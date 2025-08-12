import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pwd_gen/core/app_pallet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/core/utility.dart';
import '/view/welcome_dialog.dart';
import '/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import '/view/widgets/pwd_edit/pwd_editor_bottom_sheet.dart';
import '/view/widgets/shared/dialog_generate_or_import.dart';
import '/view/widgets/shared/pwd_widget.dart';
import '/view/widgets/shared/search_field.dart';
import '/view/widgets/shared/app_dialog.dart';

class PwdListView extends StatelessWidget {
  Future<void> _showWelcomeDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => WelcomeDialog(),
    );
  }

  const PwdListView({super.key});
  @override
  Widget build(BuildContext context) {
    final pwdListCubit = context.read<PwdListCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final showWelcomePage = await SharedPreferences.getInstance();
      final res = showWelcomePage.getBool('welcome');
      if (res != null) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _showWelcomeDialog(context);
        showWelcomePage.setBool('welcome', true);
      });
    });
    return pwdListCubit.isLoading
        ? Container(
            color: const Color.fromARGB(200, 0, 0, 0),
            child: Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                  color: AppPallet.bottomSheetTitleIcon, size: 50),
            ),
          )
        : BlocBuilder<PwdListCubit, PwdListState>(
            builder: (context, state) {
              if (state is PwdListLoaded) {
                return Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      leading: IconButton(
                        icon: Icon(
                          Icons.save_outlined,
                          color: AppPallet.bottomSheetTitleIcon,
                        ),
                        onPressed: state.pwdListShow.isNotEmpty
                            ? () async {
                                pwdListCubit.setIsLoadingState(true);
                                await pwdListCubit.requestStoragePermission();
                                if (MPGState.currentState !=
                                    MPGStateEnums.permissionGranted) {
                                  if (!context.mounted) return;
                                  await appDialogV(
                                    context: context,
                                  );
                                }
                                MPGState.applyState(MPGStateEnums
                                    .showNotificationSecretImageEncrypt);
                                if (!context.mounted) return;
                                await appDialogV(context: context);
                                final image = await selectImage();

                                if (image == null) {
                                  MPGState.applyState(
                                      MPGStateEnums.imageNotSelected);
                                  if (!context.mounted) return;
                                  await appDialogV(
                                    context: context,
                                  );
                                  pwdListCubit.setIsLoadingState(false);
                                  return;
                                }
                                // get the image hash
                                final imageHash = generateImageHash(image);
                                if (!context.mounted) return;
                                await pwdListCubit
                                    .wrightContentToFile(imageHash);
                                if (!context.mounted) return;
                                pwdListCubit.setIsLoadingState(false);
                                await appDialogV(
                                  context: context,
                                );
                              }
                            : null,
                      ),
                      title: GestureDetector(
                          onLongPress: () {
                            MPGState.applyState(MPGStateEnums.reset);
                            if (!context.mounted) return;
                            final res = appDialogV(
                                context: context, barrierDismissible: true);
                            res.then((value) {
                              if (value == true) {
                                pwdListCubit.resetList();
                                MPGState.applyState(MPGStateEnums.endOk);
                              }
                            });
                          },
                          child: Text('Passwords List')),
                      actions: [
                        IconButton(
                          onPressed: state.pwdListShow.isNotEmpty
                              ? () {
                                  context.read<PwdListCubit>().toggleSearch();
                                }
                              : null,
                          icon: Icon(
                              color: AppPallet.bottomSheetTitleIcon,
                              !state.isSearching ? Icons.search : Icons.close),
                        ),
                      ],
                    ),
                    body: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 500),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SizeTransition(
                                    sizeFactor: animation,
                                    axisAlignment: -1.0,
                                    child: child,
                                  ),
                                );
                              },
                              child: state.isSearching
                                  ? SearchField(
                                      key: ValueKey(
                                          1), // Important for AnimatedSwitcher
                                      onChange: (value) {
                                        context
                                            .read<PwdListCubit>()
                                            .searchThis(value);
                                      },
                                    )
                                  : SizedBox.shrink(
                                      key: ValueKey(
                                          2)), // Ensures transition happens
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: state.pwdListShow.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == state.pwdListShow.length) {
                                    return Visibility(
                                      visible: !state.isSearching,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: SizedBox(
                                          height: 50,
                                          width: 100,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppPallet.bottomSheetBG,
                                              side: BorderSide(
                                                  style: BorderStyle.solid,
                                                  width: 0.5,
                                                  color: AppPallet
                                                      .buttonBorderSides),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                            onPressed: () async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    DialogGenerateOrImport(),
                                              );
                                            },
                                            child: Icon(Icons.add),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 10),
                                    child: SizedBox(
                                      height: 50,
                                      child: PwdWidget(
                                        pwd: state.pwdListShow[index],
                                        onEdit: () async {
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            enableDrag: false,
                                            isDismissible: state.isLoading,
                                            context: context,
                                            builder: (context) {
                                              return PwdEditorBottomSheet(
                                                pwd: state.pwdListShow[index],
                                              );
                                            },
                                          );
                                        },
                                        onShareOrOnVisibilityChanged: () {
                                          context
                                              .read<PwdListCubit>()
                                              .updateDateTime(index);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                        state.isLoading
                            ? Container(
                                color: const Color.fromARGB(200, 0, 0, 0),
                                child: Center(
                                  child:
                                      LoadingAnimationWidget.threeArchedCircle(
                                          color: AppPallet.bottomSheetTitleIcon,
                                          size: 50),
                                ),
                              )
                            : SizedBox.shrink()
                      ],
                    ));
              } else {
                if (state is PwdListAuth) {
                  return Container(
                    color: const Color.fromARGB(200, 0, 0, 0),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          LoadingAnimationWidget.threeArchedCircle(
                              color: AppPallet.bottomSheetTitleIcon, size: 50),
                          IconButton.outlined(
                            onPressed: () {
                              context.read<PwdListCubit>().loadPwdsFromDb();
                            },
                            icon: Icon(Icons.fingerprint_outlined),
                          )
                        ],
                      ),
                    ),
                  );
                }
                return Container(
                  color: const Color.fromARGB(200, 0, 0, 0),
                  child: Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                        color: AppPallet.bottomSheetTitleIcon, size: 50),
                  ),
                );
              }
            },
          );
  }
}

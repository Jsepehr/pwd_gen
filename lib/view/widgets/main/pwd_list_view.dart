import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/core/injector.dart';
import '/core/utility.dart';
import '/view/welcome_dialog.dart';
import '/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import '/domain/pwd_entity.dart';
import '/view/widgets/shared/dialog_generate_or_import.dart';
import '/view/widgets/pwd_edit/pwd_editor_bottom_sheet.dart';
import '/view/widgets/shared/pwd_widget.dart';
import '/view/widgets/shared/search_field.dart';

class PwdListView extends StatelessWidget {
  /* void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Storage Permission Required"),
        content: Text(
            "This app needs full storage access to save files. Please enable it in settings."),
        actions: [
          TextButton(
            onPressed: () async {
              await openAppSettings(); // Open settings page
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pop(context);
              });
            },
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
  } */

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
    final isSearching = pwdListCubit.isSearching;
    debugPrint('$isSearching sepehr');
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
                  color: const Color.fromARGB(255, 0, 102, 192), size: 50),
            ),
          )
        : BlocBuilder<PwdListCubit, PwdListState>(
            builder: (context, state) {
              if (state is PwdListLoaded) {
                return Scaffold(
                    appBar: AppBar(
                      centerTitle: true,
                      leading: IconButton(
                        icon: Icon(Icons.save_outlined),
                        onPressed: state.pwdListShow.isNotEmpty
                            ? () async {
                                pwdListCubit.setIsLoadingState(true);
                                await pwdListCubit.requestStoragePermission();
                                if (MPGState.currentState !=
                                    MPGStateEnums.permissionGranted) {
                                  if (!context.mounted) return;
                                  await appDialog(
                                    context,
                                  );
                                }
                                MPGState.applyState(MPGStateEnums
                                    .showNotificationSecretImageEncrypt);
                                if (!context.mounted) return;
                                await appDialog(context);
                                final image = await selectImage();

                                if (image == null) {
                                  MPGState.applyState(
                                      MPGStateEnums.imageNotSelected);
                                  if (!context.mounted) return;
                                  await appDialog(
                                    context,
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
                                await appDialog(
                                  context,
                                );
                              }
                            : null,
                      ),
                      title: Text('Passwords List'),
                      actions: [
                        IconButton(
                          onPressed: state.pwdListShow.isNotEmpty
                              ? () {
                                  context.read<PwdListCubit>().toggleSearch();
                                }
                              : null,
                          icon: Icon(
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
                                          getIt<PwdEntityEdit>().update(
                                              hint:
                                                  state.pwdListShow[index].hint,
                                              password: state
                                                  .pwdListShow[index].password,
                                              index: index);

                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            enableDrag: false,
                                            isDismissible: state.isLoading,
                                            context: context,
                                            builder: (context) {
                                              return PwdEditorBottomSheet(
                                                index: index,
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
                                          color: const Color.fromARGB(
                                              255, 0, 102, 192),
                                          size: 50),
                                ),
                              )
                            : SizedBox.shrink()
                      ],
                    ));
              } else {
                return Container(
                  color: const Color.fromARGB(200, 0, 0, 0),
                  child: Center(
                    child: LoadingAnimationWidget.threeArchedCircle(
                        color: const Color.fromARGB(255, 0, 102, 192),
                        size: 50),
                  ),
                );
              }
            },
          );
  }
}

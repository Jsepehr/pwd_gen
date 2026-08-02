import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/core/app_pallet.dart';
import 'package:pwd_gen/view/widgets/main/security_choice_view/ui_security_choice.dart';
import 'package:pwd_gen/view/widgets/shared/ui_choose_pin.dart';
import 'package:pwd_gen/view/widgets/shared/ui_login_with_password.dart';

import '/view/welcome_dialog.dart';
import '/view/widgets/main/app_drawer.dart';
import '/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import '/view/widgets/pwd_edit/pwd_editor_bottom_sheet.dart';
import '/view/widgets/shared/dialog_generate_or_import.dart';
import '/view/widgets/shared/loading_overlay.dart';
import '/view/widgets/shared/pwd_widget.dart';
import '/view/widgets/shared/search_field.dart';

class PwdListView extends StatefulWidget {
  const PwdListView({super.key});

  @override
  State<PwdListView> createState() => _PwdListViewState();
}

class _PwdListViewState extends State<PwdListView> {
  final Map<String, GlobalKey<PwdWidgetState>> pwdKeys = {};

  @override
  Widget build(BuildContext context) {
    debugPrint("Building PwdListView");
    final pwdListCubit = context.read<PwdListCubit>();
    return pwdListCubit.isLoading
        ? const LoadingOverlay()
        : BlocBuilder<PwdListCubit, PwdListState>(
            builder: (context, state) {
              if (state is PwdListLoaded) {
                return Scaffold(
                    drawer:
                        AppDrawer(hasPasswords: state.pwdListShow.isNotEmpty),
                    appBar: AppBar(
                      centerTitle: true,
                      title: Text('Passwords List'),
                      actions: [
                        IconButton(
                          onPressed: state.pwdListShow.isNotEmpty
                              ? () {
                                  context.read<PwdListCubit>().toggleSearch();
                                }
                              : null,
                          icon: Icon(
                              color: state.pwdListShow.isNotEmpty
                                  ? AppPallet.bottomSheetTitleIcon
                                  : AppPallet.buttonBorderSides,
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
                                  String id = '';
                                  if (state.pwdListShow.length != 0 &&
                                      index != state.pwdListShow.length) {
                                    id = state.pwdListShow[index].id;
                                    if (!pwdKeys.containsKey(id)) {
                                      pwdKeys[id] = GlobalKey<PwdWidgetState>();
                                    }
                                  }
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
                                                    BorderRadius.circular(
                                                        AppRadius.md),
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
                                        key: pwdKeys[id],
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
                                          pwdKeys[id]
                                              ?.currentState
                                              ?.changeBorderColor();
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
                            ? const LoadingOverlay()
                            : SizedBox.shrink()
                      ],
                    ));
              } else {
                if (state is UiPwdListAuth) {
                  return LoadingOverlay(
                    overlay: IconButton.outlined(
                      onPressed: () {
                        context.read<PwdListCubit>().loadPwdsFromDb();
                      },
                      icon: Icon(Icons.fingerprint_outlined),
                    ),
                  );
                }
                if (state is UiPwdListWelcome) {
                  return WelcomePage();
                }
                if (state is UiPwdListChooseSecurity) {
                  return UiSecurityChoice();
                }
                if (state is UiPwdChoosePin) {
                  return UiChoosePin();
                }
                if (state is UiPwdLoginWithPassword) {
                  return UiLoginWithPassword();
                }
                return const LoadingOverlay();
              }
            },
          );
  }
}

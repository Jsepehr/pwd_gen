import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/core/dictionary/app_strings.dart';
import '/core/app_pallet.dart';
import '/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import '/domain/pwd_entity.dart';

import 'package:pwd_gen/view/widgets/pwd_edit/cubit_pwd_editor/pwd_editor_cubit.dart';
import 'package:pwd_gen/view/widgets/shared/edit_pwd_textfield.dart';

class PwdEditorBottomSheet extends StatefulWidget {
  final PwdEntity pwd;
  const PwdEditorBottomSheet({
    super.key,
    required this.pwd,
  });
  @override
  State<PwdEditorBottomSheet> createState() => _PwdEditorBottomSheetState();
}

class _PwdEditorBottomSheetState extends State<PwdEditorBottomSheet> {
  late PwdEditorCubit cubit;
  TextEditingController hintController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit = context.read<PwdEditorCubit>();
      hintController.text = widget.pwd.hint;
      pwdController.text = widget.pwd.password;
      cubit.modifyPwd(widget.pwd.password);
      cubit.modifyHint(widget.pwd.hint);
      focusNode.requestFocus();
      if (hintController.text == '${AppStrings.readyToBegin}...') {
        hintController.selection = TextSelection(
            baseOffset: 0, extentOffset: hintController.text.length);
      }
    });
  }

  @override
  void dispose() {
    hintController.dispose();
    pwdController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubitPwdsList = context.read<PwdListCubit>();
    debugPrint("Building PwdEditorBottomSheet");
    return Padding(
      // 👇 Pushes content above the keyboard
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: AppPallet.bottomSheetBG,
          height: 250,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
            child: BlocBuilder<PwdEditorCubit, PwdEditorState>(
              builder: (context, state) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.edit,
                          color: AppPallet.bottomSheetTitleIcon,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: state is PwdEditorLoaded
                          ? EditPwdTextField(
                              focusNode: focusNode,
                              controller: hintController,
                              onChange: (p0) {
                                cubit.modifyHint(p0);
                              },
                            )
                          : CircularProgressIndicator(),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      height: 50,
                      child: state is PwdEditorLoaded
                          ? EditPwdTextField(
                              focusNode: FocusNode(),
                              controller: pwdController,
                              onChange: (p0) {
                                cubit.modifyPwd(p0);
                              },
                            )
                          : CircularProgressIndicator(),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        state is PwdEditorLoaded
                            ? ElevatedButton(
                                onPressed: () async {
                                  final updatedPwd = widget.pwd.copyWith(
                                    hint: cubit.hint,
                                    password: cubit.pwd,
                                  );
                                  await cubitPwdsList.updateHintAndPwds(
                                    updatedPwd,
                                  );
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  AppStrings.apply,
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : CircularProgressIndicator(),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            AppStrings.cancel,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

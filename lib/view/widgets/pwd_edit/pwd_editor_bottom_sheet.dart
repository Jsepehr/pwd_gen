import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/core/app_pallet.dart';
import '/core/injector.dart';
import '/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import '/domain/pwd_entity.dart';

import 'package:pwd_gen/view/widgets/pwd_edit/cubit_pwd_editor/pwd_editor_cubit.dart';
import 'package:pwd_gen/view/widgets/shared/edit_pwd_textfield.dart';

class PwdEditorBottomSheet extends StatefulWidget {
  final int index;
  const PwdEditorBottomSheet({
    super.key,
    required this.index,
  });
  @override
  State<PwdEditorBottomSheet> createState() => _PwdEditorBottomSheetState();
}

class _PwdEditorBottomSheetState extends State<PwdEditorBottomSheet> {
  late PwdEditorCubit cubit;
  PwdEntityEdit pwd = getIt<PwdEntityEdit>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cubit = context.read<PwdEditorCubit>();
      cubit.hintController.text = pwd.hint;
      cubit.pwdController.text = pwd.password;
      cubit.modifyPwd(pwd.password);
      cubit.modifyHint(pwd.hint);
      cubit.focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubitPwdsList = context.read<PwdListCubit>();
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
                              focusNode: state.focusNode,
                              controller: state.hintController,
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
                              controller: state.pwdController,
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
                                  getIt<PwdEntityEdit>().update(
                                      hint: cubit.hint,
                                      password: cubit.pwd,
                                      index: widget.index);
                                  PwdEntityEdit pwd = getIt<PwdEntityEdit>();

                                  cubitPwdsList.updateHintAndPwds(
                                      pwd, widget.index);
                                  Navigator.pop(context);
                                },
                                child: Text('Apply'))
                            : CircularProgressIndicator(),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Dismiss')),
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

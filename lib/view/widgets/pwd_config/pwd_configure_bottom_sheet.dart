import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/core/app_pallet.dart';
import 'package:pwd_gen/core/utility.dart';
import 'package:pwd_gen/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import 'package:pwd_gen/view/widgets/pwd_config/cubit_config_pwds/config_pwds_cubit.dart';
import 'package:pwd_gen/view/widgets/shared/edit_pwd_textfield.dart';

class PwdConfigureBottomSheet extends StatefulWidget {
  const PwdConfigureBottomSheet({
    super.key,
  });

  @override
  State<PwdConfigureBottomSheet> createState() =>
      _PwdConfigureBottomSheetState();
}

class _PwdConfigureBottomSheetState extends State<PwdConfigureBottomSheet> {
  TextEditingController secretPhraseCtl = TextEditingController();
  File? image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<ConfigPwdsCubit>().emitState(image);
    });
  }

  @override
  void dispose() {
    secretPhraseCtl.dispose();
    image = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConfigPwdsCubit>();
    cubit.secretPhrase = secretPhraseCtl.text;
    final width = MediaQuery.of(context).size.width;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: AppPallet.bottomSheetBG,
        height: 220,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.settings,
                    color: AppPallet.bottomSheetTitleIcon,
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              BlocBuilder<ConfigPwdsCubit, ConfigPwdsState>(
                builder: (context, state) {
                  if (state is ConfigPwdsLoaded) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 50,
                            child: EditPwdTextField(
                              controller: secretPhraseCtl,
                              hintText: 'Secret phrase...',
                              onChange: (p0) {
                                cubit.secretPhrase = p0;
                                cubit.emitState(image);
                              },
                            ),
                          ),
                        ]);
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              SizedBox(
                height: 8,
              ),
              SizedBox(
                width: width,
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: BlocBuilder<ConfigPwdsCubit, ConfigPwdsState>(
                        builder: (context, state) {
                          if (state is ConfigPwdsLoaded) {
                            return Row(
                              children: [
                                SizedBox(
                                  height: 50,
                                  width: width / 1.8,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(
                                                15), // Adjust the radius as needed
                                            bottomLeft: Radius.circular(
                                                15), // Adjust the radius as needed
                                          ),
                                        ),
                                      ),
                                      onPressed: state.isImageBtnEnabled
                                          ? () async {
                                              image = await selectImage();
                                              cubit.emitState(image);
                                            }
                                          : null,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('Secret Image'),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Icon(Icons.file_open_outlined),
                                        ],
                                      )),
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                SizedBox(
                                  width: width / 3,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(
                                              15), // Adjust the radius as needed
                                          bottomRight: Radius.circular(
                                              15), // Adjust the radius as needed
                                        ),
                                      ),
                                    ),
                                    onPressed: state.isGenerateBtnEnabled
                                        ? () async {
                                            await context
                                                .read<PwdListCubit>()
                                                .generatePwds(
                                                    state.secretPhrase, image);
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                                    (_) async {
                                              Navigator.pop(context);
                                            });
                                          }
                                        : null,
                                    child: Text('Generate'),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

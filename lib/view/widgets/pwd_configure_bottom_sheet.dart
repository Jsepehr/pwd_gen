import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/core/app_pallet.dart';
import 'package:pwd_gen/cubit_pwds_list/pwd_list_cubit.dart';
import 'package:pwd_gen/view/widgets/cubit_config_pwds/config_pwds_cubit.dart';
import 'package:pwd_gen/view/widgets/edit_pwd_textfield.dart';

class PwdConfigureBottomSheet extends StatelessWidget {
  const PwdConfigureBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ConfigPwdsCubit>();
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
                              controller: cubit.secretPhraseCtl,
                              hintText: 'Secret phrase...',
                              onChange: (p0) {
                                debugPrint(cubit.secretPhraseCtl.text);
                                cubit.enableImageBtn();
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
                                          ? () async =>
                                              await cubit.openGallery()
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
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                                    (_) async {
                                              Navigator.pop(context);
                                            });
                                            await context
                                                .read<PwdListCubit>()
                                                .generatePwds(
                                                    state.secretPhrase,
                                                    state.image);
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

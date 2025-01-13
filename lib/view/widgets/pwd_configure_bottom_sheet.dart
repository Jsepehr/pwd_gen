import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/core/app_pallet.dart';
import 'package:pwd_gen/cubit/pwd_list_cubit.dart';
import 'package:pwd_gen/view/widgets/edit_pwd_textfield.dart';

class PwdConfigureBottomSheet extends StatefulWidget {
  const PwdConfigureBottomSheet({
    super.key,
  });

  @override
  State<PwdConfigureBottomSheet> createState() =>
      _PwdConfigureBottomSheetState();
}

class _PwdConfigureBottomSheetState extends State<PwdConfigureBottomSheet> {
  TextEditingController pwdController = TextEditingController();
  bool isGenerateBtnEnabled = true;
  bool isImageBtnEnabled = false;

  @override
  Widget build(BuildContext context) {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50,
                    child: EditPwdTextField(
                      controller: pwdController,
                      hintText: 'Secret phrase...',
                      onChange: (p0) {
                        if (p0.isNotEmpty) {
                          setState(() {
                            isImageBtnEnabled = true;
                          });
                        } else {
                          isImageBtnEnabled = false;
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              SizedBox(
                width: 400,
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 500,
                      height: 60,
                      child: Row(
                        children: [
                          SizedBox(
                            height: 50,
                            width: 258,
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
                                onPressed: isImageBtnEnabled
                                    ? () => print('Button Pressed')
                                    : null,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                            width: 2,
                          ),
                          SizedBox(
                            width: 110,
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
                              onPressed: isGenerateBtnEnabled
                                  ? () {
                                      context
                                          .read<PwdListCubit>()
                                          .generatePwds();
                                    }
                                  : null,
                              child: Text('Generate'),
                            ),
                          ),
                        ],
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

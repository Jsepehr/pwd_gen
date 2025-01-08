import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pwd_gen/core/app_pallet.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';
import 'package:pwd_gen/view/widgets/edit_pwd_textfield.dart';

class PwdEditorBottomSheet extends StatefulWidget {
  const PwdEditorBottomSheet(
      {super.key, required this.pwd, required this.saveChanges});

  final PwdEntity pwd;
  final Function(String, String) saveChanges;

  @override
  State<PwdEditorBottomSheet> createState() => _PwdEditorBottomSheetState();
}

class _PwdEditorBottomSheetState extends State<PwdEditorBottomSheet> {
  TextEditingController hintController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  @override
  void initState() {
    hintController.text = widget.pwd.hint;
    pwdController.text = widget.pwd.password;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: AppPallet.bottomSheetBG,
        height: 250,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
          child: Column(
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
                child: EditPwdTextField(controller: hintController),
              ),
              SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 50,
                child: EditPwdTextField(controller: pwdController),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        widget.saveChanges(
                            hintController.text, pwdController.text);
                        Get.back();
                      },
                      child: Text('Apply')),
                  ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('Dismiss')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

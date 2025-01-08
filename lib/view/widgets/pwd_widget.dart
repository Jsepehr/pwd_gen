import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pwd_gen/data/models/pwd_model.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';
import 'package:pwd_gen/view/pwd_list_viewmodel.dart';
import 'package:pwd_gen/view/widgets/pwd_editor_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

class PwdWidget extends StatefulWidget {
  final PwdModel pwd;
  const PwdWidget({super.key, required this.pwd});
  @override
  State<PwdWidget> createState() => _PwdWidgetState();
}

class _PwdWidgetState extends State<PwdWidget> {
  final PwdListViewModel _viewModel = Get.put(PwdListViewModel());

  TextEditingController controller = TextEditingController();
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    if (_isVisible) {
      controller.text = widget.pwd.password;
    } else {
      controller.text = widget.pwd.hint;
    }
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Stack(
              children: [
                TextField(
                  controller: controller,
                  enabled: true,
                  readOnly: true,
                  textAlign: TextAlign.start,
                  style: GoogleFonts.firaCode(
                      // Use Google Font for input text
                      textStyle: TextStyle(
                    fontSize: 18,
                  )),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () async {
                              await Get.bottomSheet(PwdEditorBottomSheet(
                                saveChanges: (hint, pwd) {
                                  final index = _viewModel.pwdListShow
                                      .indexOf(widget.pwd);
                                  widget.pwd.hint = hint;
                                  widget.pwd.password = pwd;
                                  _viewModel.pwdListShow[index] = widget.pwd;
                                  _viewModel.editPwdById(widget.pwd);
                                },
                                pwd: widget.pwd,
                              ));
                            },
                            icon: Icon(Icons.edit)),
                        IconButton(
                            onPressed: () {
                              Share.share(widget.pwd.password);
                            },
                            icon: Icon(Icons.share)),
                        IconButton(
                            onPressed: () {
                              _isVisible = !_isVisible;

                              setState(() {});
                            },
                            icon: _isVisible
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




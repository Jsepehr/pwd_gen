import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '/domain/pwd_entity.dart';

class PwdWidget extends StatefulWidget {
  final PwdEntity pwd;
  final VoidCallback onEdit;
  final VoidCallback onShareOrOnVisibilityChanged;
  const PwdWidget(
      {super.key,
      required this.pwd,
      required this.onEdit,
      required this.onShareOrOnVisibilityChanged});
  @override
  State<PwdWidget> createState() => _PwdWidgetState();
}

class _PwdWidgetState extends State<PwdWidget> {
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
      body: ClipRRect(
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
                        onPressed: widget.onEdit, icon: Icon(Icons.edit)),
                    IconButton(
                        onPressed: () async {
                          await SharePlus.instance
                              .share(ShareParams(text: widget.pwd.password));
                          widget.onShareOrOnVisibilityChanged();
                        },
                        icon: Icon(Icons.share)),
                    IconButton(
                        onPressed: () {
                          _isVisible = !_isVisible;
                          if (!_isVisible) {
                            widget.onShareOrOnVisibilityChanged();
                          }
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
    );
  }
}

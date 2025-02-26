import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:pwd_gen/domain/pwd_entity.dart';
import 'package:share_plus/share_plus.dart';

class PwdWidget extends StatefulWidget {
  final PwdEntity pwd;
  final VoidCallback onEdit;
  const PwdWidget({super.key, required this.pwd, required this.onEdit});
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
                        onPressed: widget.onEdit,
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
    );
  }
}

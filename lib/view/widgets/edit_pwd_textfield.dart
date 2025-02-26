import 'package:flutter/material.dart';

class EditPwdTextField extends StatelessWidget {
  const EditPwdTextField({
    super.key,
    required this.controller,
    required this.onChange,
    this.hintText,
  });

  final TextEditingController controller;
  final String? hintText;
  final Function(String)? onChange;
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChange,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      controller: controller,
    );
  }
}

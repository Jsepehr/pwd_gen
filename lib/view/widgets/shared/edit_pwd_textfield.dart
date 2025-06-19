import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';

class EditPwdTextField extends StatelessWidget {
  const EditPwdTextField({
    super.key,
    required this.controller,
    required this.onChange,
    required this.focusNode,
    this.hintText,
  });

  final TextEditingController controller;
  final String? hintText;
  final Function(String)? onChange;
  final  FocusNode focusNode;
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      onChanged: onChange,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      controller: controller,
      autocorrect: false,
      enableSuggestions: false,
      enabled: !context.watch<PwdListCubit>().isLoading,
    );
  }
}

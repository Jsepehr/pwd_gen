import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';

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
      autocorrect: false,
      enableSuggestions: false,
      enabled: !context.watch<PwdListCubit>().isLoading,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/core/app_pallet.dart';
import 'package:pwd_gen/core/app_shared_preferences.dart';
import 'package:pwd_gen/core/dictionary/app_strings.dart';
import 'package:pwd_gen/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import 'package:pwd_gen/view/widgets/shared/app_dialog.dart'
    show KeymageStateEnums, appDialogV;

import '/core/utility.dart';

class UiChoosePin extends StatefulWidget {
  @override
  _UiChoosePinState createState() => _UiChoosePinState();
}

class _UiChoosePinState extends State<UiChoosePin> {
  final _formKey = GlobalKey<FormState>();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    debugPrint("Building UiChoosePin");

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.read<PwdListCubit>().emitSecurityOptions(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPallet.bottomSheetBG,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.createNewPassword,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppPallet.bottomSheetTitleIcon,
                        ),
                  ),
                  const SizedBox(height: 25),

                  // Campo Nuova Password
                  TextFormField(
                    controller: _passController,
                    obscureText: _obscureText,
                    decoration: _inputDecoration(
                        AppStrings.newPassword, Icons.lock_outline),
                    validator: (value) => (value == null || value.isEmpty)
                        ? AppStrings.passwordRequired
                        : null,
                  ),

                  const SizedBox(height: 15),

                  // Campo Ripeti Password
                  TextFormField(
                    controller: _confirmPassController,
                    obscureText: _obscureText,
                    decoration: _inputDecoration(
                        AppStrings.repeatPassword, Icons.lock_reset),
                    validator: (value) {
                      if (value != _passController.text) {
                        return AppStrings.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 70,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final image = await selectImage();
                              if (image == null) {
                                KeymageState.applyState(
                                    KeymageStateEnums.imageNotSelected);
                                if (!context.mounted) return;
                                appDialogV(context: context);
                                return;
                              }
                              final imageHash = generateImageHash(image);
                              await AppSharedPreferences.saveImageHashEnterApp(
                                  imageHash);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text(AppStrings.selectImageToLogin)),
                              );
                            },
                            child:
                                Text(softWrap: true, AppStrings.loginWithImage),
                          ),
                        ),
                        Container(
                          color: AppPallet.bottomSheetTitleIcon,
                          width: 1,
                          height: double.infinity,
                        ),
                        IconButton(
                          onPressed: () {
                            KeymageState.applyState(
                                KeymageStateEnums.helpForCreateNewPassword);
                            if (!context.mounted) return;
                            appDialogV(context: context);
                          },
                          icon: Icon(Icons.help_outline),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottone di Conferma
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text(AppStrings.passwordSavedSuccessfully)),
                          );
                          final hash =
                              generateStringHash(_confirmPassController.text);
                          await AppSharedPreferences.savedPwdHash(hash);
                          context.read<PwdListCubit>().loadPwdsFromDb();
                        }
                      },
                      child: Text(AppStrings.confirm),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper per lo stile degli input
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppPallet.bottomSheetTitleIcon),
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      ),
    );
  }
}

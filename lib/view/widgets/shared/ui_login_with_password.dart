import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pwd_gen/core/app_pallet.dart';
import 'package:pwd_gen/core/app_shared_preferences.dart';
import 'package:pwd_gen/core/dictionary/app_strings.dart';
import 'package:pwd_gen/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import 'package:pwd_gen/view/widgets/shared/app_dialog.dart'
    show KeymageStateEnums, appDialogV;

import '/core/utility.dart';

class UiLoginWithPassword extends StatefulWidget {
  @override
  _UiLoginWithPasswordState createState() => _UiLoginWithPasswordState();
}

class _UiLoginWithPasswordState extends State<UiLoginWithPassword> {
  final _formKey = GlobalKey<FormState>();
  final _passController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    debugPrint("Building UiLoginWithPassword");

    return Scaffold(
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
                    AppStrings.enterYourPassword,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppPallet.bottomSheetTitleIcon,
                        ),
                  ),
                  const SizedBox(height: 25),

                  // Campo Password
                  TextFormField(
                    controller: _passController,
                    obscureText: _obscureText,
                    decoration: _inputDecoration(
                        AppStrings.passwordHere, Icons.lock_outline),
                    validator: (value) => (value == null || value.isEmpty)
                        ? AppStrings.passwordRequired
                        : null,
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      onPressed: () async {
                        final image = await selectImage();
                        if (image == null) {
                          KeymageState.applyState(
                              KeymageStateEnums.imageNotSelected);
                          if (!context.mounted) return;
                          appDialogV(context: context);
                          return;
                        }
                        final imageHash = generateImageHash(image);
                        final savedImage =
                            await AppSharedPreferences.loadImageHashEnterApp();
                        if (savedImage == null || savedImage.isEmpty) {
                          // error nessuna immagine salvata
                          KeymageState.applyState(
                              KeymageStateEnums.noSavedImage);
                          if (!context.mounted) return;
                          appDialogV(context: context);
                          return;
                        }
                        if (imageHash != savedImage) {
                          KeymageState.applyState(
                              KeymageStateEnums.imageMismatch);
                          if (!context.mounted) return;
                          appDialogV(context: context);
                          return;
                        }
                        context.read<PwdListCubit>().setUserAuthenticated(true);
                        context.read<PwdListCubit>().loadPwdsFromDb();
                      },
                      icon: const Icon(Icons.image_outlined),
                      label: Text(AppStrings.loginWithImage),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      onPressed: () async {
                        final cubit = context.read<PwdListCubit>();
                        await cubit.authenticate();
                        if (!context.mounted) return;
                        if (!cubit.isUserAuthenticated) return;
                        cubit.loadPwdsFromDb();
                      },
                      icon: const Icon(Icons.fingerprint),
                      label: Text(AppStrings.userAndroidSecurityAuthentication),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottone di Conferma
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final pin = _passController.text;
                          final savedPwd =
                              await AppSharedPreferences.loadPwdHash();
                          // paragona le hash di due passwords e se non corrispondono mostra un dialogo di errore
                          if (savedPwd != null && savedPwd.isNotEmpty) {
                            final inputHash = generateStringHash(pin);
                            if (inputHash != savedPwd) {
                              KeymageState.applyState(
                                  KeymageStateEnums.pinMismatch);
                              if (!context.mounted) return;
                              appDialogV(context: context);
                              return;
                            }
                          }

                          context
                              .read<PwdListCubit>()
                              .setUserAuthenticated(true);
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

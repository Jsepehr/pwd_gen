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
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // Definizione dei colori del tema
    const darkBackground = AppPallet.bottomSheetBG;
    const accentBlue = AppPallet.bottomSheetTitleIcon;
    const surfaceColor = AppPallet.bottomSheetBG;

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBackground,
        colorScheme: ColorScheme.dark(primary: accentBlue),
      ),
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
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
                    const Text(
                      "Inserisci la tua PIN",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: accentBlue,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Campo Nuova Password
                    TextFormField(
                      controller: _passController,
                      obscureText: _obscureText,
                      decoration: _inputDecoration(
                          "Nuova Password", Icons.lock_outline),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Inserisci una password"
                          : null,
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
                                final savedImage = await AppSharedPreferences
                                    .loadImageHashEnterApp();
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
                                context.read<PwdListCubit>().loadPwdsFromDb();
                              },
                              child: Text(
                                  softWrap: true,
                                  AppStrings.loginWithImage,),
                            ),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final pin = _passController.text;
                           final savedPwd = await AppSharedPreferences.loadPwdHash();
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
                           
                            context.read<PwdListCubit>().loadPwdsFromDb();
                          }
                        },
                        child: const Text(
                          "Conferme",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
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
      prefixIcon: Icon(icon, color: Colors.blueAccent),
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
    );
  }
}

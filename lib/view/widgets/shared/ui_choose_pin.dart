import 'package:flutter/material.dart';
import 'package:pwd_gen/core/app_shared_preferences.dart';
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
    // Definizione dei colori del tema
    const darkBackground = Color(0xFF121212);
    const accentBlue = Color(0xFF448AFF);
    const surfaceColor = Color(0xFF1E1E1E);

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
                      "Crea Nuova Password",
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

                    const SizedBox(height: 15),

                    // Campo Ripeti Password
                    TextFormField(
                      controller: _confirmPassController,
                      obscureText: _obscureText,
                      decoration:
                          _inputDecoration("Ripeti Password", Icons.lock_reset),
                      validator: (value) {
                        if (value != _passController.text)
                          return "Le password non coincidono";
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
                                await AppSharedPreferences
                                    .saveImageHashEnterApp(imageHash);
                              },
                              child: Text(
                                  softWrap: true,
                                  'Seleziona un immagine come opzione secondaria per entrare nell\'app'),
                            ),
                          ),
                          Container(
                            color: accentBlue,
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius
                            .circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Password salvata con successo!')),
                            );
                            AppSharedPreferences
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

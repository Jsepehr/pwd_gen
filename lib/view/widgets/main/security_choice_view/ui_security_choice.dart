import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pwd_gen/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';

class UiSecurityChoice extends StatelessWidget {
  const UiSecurityChoice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_person_rounded,
                  size: 80, color: Colors.blue),
              const SizedBox(height: 32),
              Text(
                'Proteggi i tuoi dati',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Scegli come vuoi accedere all\'app. Questa impostazione è obbligatoria per la tua sicurezza.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // Opzione 1: Codice Personalizzato
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade900,
                  elevation: 0,
                ),
                onPressed: () {
                  // TODO: Salva la preferenza "Codice PIN"
                  // Esempio: prefs.setString('security_type', 'pin');
                  //context.go('/');
                  context.read<PwdListCubit>().emitChoosePin();
                },
                icon: const Icon(Icons.dialpad_rounded),
                label: const Text('Usa un codice PIN personalizzato'),
              ),

              const SizedBox(height: 16),

              // Opzione 2: Blocco di Sistema (Biometria/Sequenza)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // TODO: Salva la preferenza "Blocco Sistema"
                  // Esempio: prefs.setString('security_type', 'biometric');
                  //context.go('/');
                },
                icon: const Icon(Icons.fingerprint_rounded),
                label: const Text('Usa il blocco del telefono'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

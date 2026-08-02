import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';

import '/core/app_pallet.dart';
import '/core/app_shared_preferences.dart';
import '/core/dictionary/app_strings.dart';
import '/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';

class UiSecurityChoice extends StatelessWidget {
  const UiSecurityChoice({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Building UiSecurityChoice");
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_person_rounded,
                  size: 80, color: AppPallet.bottomSheetTitleIcon),
              const SizedBox(height: 32),
              Text(
                AppStrings.protectYourVault,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.chooseYourPreferredSecurityMethod,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // Opzione 1: Codice Personalizzato
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppPallet.bottomSheetBG,
                  foregroundColor: AppPallet.bottomSheetTitleIcon,
                  elevation: 0,
                ),
                onPressed: () {
                  AppSharedPreferences.saveEntryMode(UserEntryMode.customPwd);
                  context.read<PwdListCubit>().emitChoosePin();
                },
                icon: const Icon(Icons.dialpad_rounded),
                label: Text(AppStrings.useAPersonalizedPassword),
              ),

              const SizedBox(height: 16),

              // Opzione 2: Blocco di Sistema (Biometria/Sequenza)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () async {
                  final isSupported =
                      await LocalAuthentication().isDeviceSupported();
                  if (!isSupported) {
                    if (!context.mounted) return;
                    await showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(AppStrings.noScreenLockTitle),
                        content: Text(AppStrings.noScreenLockMessage),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: Text(AppStrings.cancel),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              AppSettings.openAppSettings(
                                  type: AppSettingsType.security);
                            },
                            child: Text(AppStrings.openSettings),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  await AppSharedPreferences.saveEntryMode(
                      UserEntryMode.androidSecurity);
                  if (!context.mounted) return;
                  context.read<PwdListCubit>().loadPwdsFromDb();
                },
                icon: const Icon(Icons.fingerprint_rounded),
                label: Text(AppStrings.userAndroidSecurityAuthentication),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

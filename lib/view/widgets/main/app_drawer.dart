import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '/core/app_pallet.dart';
import '/core/dictionary/app_strings.dart';
import '/view/widgets/main/cubit_pwds_list/pwd_list_cubit.dart';
import '/view/widgets/shared/about_screen.dart';
import '/view/widgets/shared/language_picker.dart';
import '/view/widgets/shared/vault_actions.dart';

class AppDrawer extends StatelessWidget {
  final bool hasPasswords;

  const AppDrawer({super.key, required this.hasPasswords});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PwdListCubit>();
    return Drawer(
      backgroundColor: AppPallet.bottomSheetBG,
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_person_rounded,
                    size: 40,
                    color: AppPallet.bottomSheetTitleIcon,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.welcomeToMyPasswordGenerator,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.save_outlined),
              title: Text(AppStrings.export),
              enabled: hasPasswords,
              onTap: () async {
                Navigator.pop(context);
                await exportVaultFlow(context, cubit);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: Text(AppStrings.import),
              onTap: () async {
                Navigator.pop(context);
                await importVaultFlow(context, cubit);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(AppStrings.changeLanguage),
              onTap: () async {
                Navigator.pop(context);
                if (!context.mounted) return;
                await showLanguagePicker(context);
              },
            ),
            const Divider(),
            ListTile(
              leading:
                  Icon(Icons.delete_forever_outlined, color: AppPallet.error),
              title: Text(AppStrings.resetVault,
                  style: const TextStyle(color: AppPallet.error)),
              enabled: hasPasswords,
              onTap: () async {
                Navigator.pop(context);
                await resetVaultFlow(context, cubit);
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: Text(AppStrings.shareApp),
              onTap: () async {
                Navigator.pop(context);
                await SharePlus.instance
                    .share(ShareParams(text: AppStrings.shareAppMessage));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(AppStrings.about),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

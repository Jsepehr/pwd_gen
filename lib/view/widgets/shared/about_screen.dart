import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/app_pallet.dart';
import '/core/dictionary/app_strings.dart';

const String kDeveloperName = 'Sepehr Amini';
const String kDeveloperWebsite = 'https://jsepehr.github.io/';
const String kPrivacyPolicyUrl =
    'https://jsepehr.github.io/pwd_gen/pwd-gen-privacy-policy.html';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.about)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.welcomeToMyPasswordGenerator,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final info = snapshot.data;
                if (info == null) return const SizedBox.shrink();
                return Text(
                  '${AppStrings.version} ${info.version} (${info.buildNumber})',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              AppStrings.developedBy,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(kDeveloperName),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _openLink(context, kDeveloperWebsite),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.link, color: AppPallet.bottomSheetTitleIcon),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.visitWebsite,
                    style: const TextStyle(
                      color: AppPallet.bottomSheetTitleIcon,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _openLink(context, kPrivacyPolicyUrl),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    color: AppPallet.bottomSheetTitleIcon,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.privacyPolicy,
                    style: const TextStyle(
                      color: AppPallet.bottomSheetTitleIcon,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLink(BuildContext context, String url) async {
    if (url.startsWith('TODO')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Set kDeveloperWebsite in about_screen.dart')),
      );
      return;
    }
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

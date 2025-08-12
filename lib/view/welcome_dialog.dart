import 'package:flutter/material.dart';
import 'package:pwd_gen/core/dictionary/app_strings.dart';

class WelcomeDialog extends StatefulWidget {
  const WelcomeDialog({super.key});

  @override
  State<WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> {
  int currentIndex = 0;

  final List<_SlideData> slides = [
    _SlideData(
      title: AppStrings.welcomeToMyPasswordGenerator,
      subtitle: AppStrings.securePrivateSmart,
    ),
    _SlideData(
      title: AppStrings.localAndPrivateByDesign,
      subtitle:
          '${AppStrings.noInternetAccess}\n${AppStrings.noDataCollection}\n${AppStrings.everythingStaysOnYourDevice}',
    ),
    _SlideData(
      title: AppStrings.smartPasswordGeneration,
      subtitle:
          '${AppStrings.useAPhotoAndKeywordToGenerateStrongPasswords}\n${AppStrings.addAHintForEachPassword}',
    ),
    _SlideData(
      title: AppStrings.manageAndExportYourVault,
      subtitle:
          '${AppStrings.editPasswordsAndHints}\n${AppStrings.exportToDownloads}\n${AppStrings.importYourListAnytime}',
    ),
    _SlideData(
      title: AppStrings.readyToBegin,
      subtitle: AppStrings.keepYourDigitalLifeSecureWithoutCompromises,
    ),
  ];

  void _nextSlide() {
    if (currentIndex < slides.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = slides[currentIndex];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                slide.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              _buildDotsIndicator(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _nextSlide,
                child:
                    Text(currentIndex == slides.length - 1 ? AppStrings.start : AppStrings.next),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(slides.length, (index) {
        bool isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey[400],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _SlideData {
  final String title;
  final String subtitle;

  _SlideData({required this.title, required this.subtitle});
}

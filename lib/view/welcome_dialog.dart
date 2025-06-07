import 'package:flutter/material.dart';

class WelcomeDialog extends StatefulWidget {
  const WelcomeDialog({super.key});

  @override
  State<WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> {
  int currentIndex = 0;

  final List<_SlideData> slides = [
    _SlideData(
      title: 'Welcome to My Password Generator',
      subtitle:
          'Secure. Private. Smart.\n\nYour offline password generator and manager.',
    ),
    _SlideData(
      title: 'Local & Private by Design',
      subtitle:
          'No internet access.\nNo data collection.\nEverything stays on your device.',
    ),
    _SlideData(
      title: 'Smart Password Generation',
      subtitle:
          '🔐 Use a photo + keyword to generate strong passwords.\n💡 Add a hint for each password.',
    ),
    _SlideData(
      title: 'Manage and Export Your Vault',
      subtitle:
          '✏️ Edit passwords and hints.\n📂 Export to Downloads.\n📥 Import your list anytime.',
    ),
    _SlideData(
      title: 'Ready to Begin?',
      subtitle: 'Let\'s keep your digital life secure - without compromises.',
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
                    Text(currentIndex == slides.length - 1 ? 'Start' : 'Next'),
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

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '/core/app_pallet.dart';

/// Full-bleed scrim with a centered spinner, used everywhere the app blocks
/// the UI while it waits on a background operation. Pass [overlay] to stack
/// an extra widget (e.g. a retry button) on top of the spinner.
class LoadingOverlay extends StatelessWidget {
  final Widget? overlay;

  const LoadingOverlay({super.key, this.overlay});

  @override
  Widget build(BuildContext context) {
    final spinner = LoadingAnimationWidget.threeArchedCircle(
      color: AppPallet.bottomSheetTitleIcon,
      size: 50,
    );
    return Container(
      color: AppPallet.scrim,
      child: Center(
        child: overlay == null
            ? spinner
            : Stack(
                alignment: Alignment.center,
                children: [spinner, overlay!],
              ),
      ),
    );
  }
}

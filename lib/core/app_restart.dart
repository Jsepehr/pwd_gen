import 'package:flutter/material.dart';

/// Wraps the app so it can be fully rebuilt from scratch on demand — used to
/// apply a language change everywhere, since [AppStrings] are plain static
/// fields read directly in `build()` methods rather than an observable
/// InheritedWidget. Rebuilding the whole subtree under a fresh key re-reads
/// those statics everywhere without needing to wire up a full localization
/// delegate.
class AppRestartWidget extends StatefulWidget {
  final Widget child;

  const AppRestartWidget({super.key, required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_AppRestartWidgetState>()?._restart();
  }

  @override
  State<AppRestartWidget> createState() => _AppRestartWidgetState();
}

class _AppRestartWidgetState extends State<AppRestartWidget> {
  Key _key = UniqueKey();

  void _restart() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}

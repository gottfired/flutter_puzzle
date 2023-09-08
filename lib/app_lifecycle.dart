import 'package:flutter/material.dart';

class AppLifecycle extends WidgetsBindingObserver {
  AppLifecycle({this.onResume, this.onPause});

  final void Function()? onResume;
  final void Function()? onPause;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        onPause?.call();
        break;
      case AppLifecycleState.resumed:
        onResume?.call();
        break;
    }
  }
}

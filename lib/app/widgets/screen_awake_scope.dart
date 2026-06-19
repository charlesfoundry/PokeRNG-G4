import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _screenAwakeChannel = MethodChannel('pokerng_g4/screen_awake');

class ScreenAwakeScope extends StatefulWidget {
  const ScreenAwakeScope({super.key, required this.child});

  final Widget child;

  @override
  State<ScreenAwakeScope> createState() => _ScreenAwakeScopeState();
}

class _ScreenAwakeScopeState extends State<ScreenAwakeScope>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setScreenAwake(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setScreenAwake(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _setScreenAwake(true);
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _setScreenAwake(false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _setScreenAwake(bool enabled) {
    if (kIsWeb) {
      return;
    }
    _screenAwakeChannel
        .invokeMethod<void>('setEnabled', {'enabled': enabled})
        .catchError((Object _) {});
  }
}

import 'package:flutter/material.dart';

import '../app_profile.dart';
import 'gen4_timer_panel.dart';

class Gen4IdTimerPanel extends StatelessWidget {
  const Gen4IdTimerPanel({
    super.key,
    required this.profile,
    required this.targetDelay,
    required this.targetSecond,
    this.targetDateTime,
    this.delayHit,
    this.delayHitToken,
    this.hitSecond,
    this.lockDelayHit = false,
    this.onCalibrationApplied,
  });

  final AppProfile profile;
  final int? targetDelay;
  final int? targetSecond;
  final DateTime? targetDateTime;
  final int? delayHit;
  final Object? delayHitToken;
  final int? hitSecond;
  final bool lockDelayHit;
  final ValueChanged<Gen4TimerCalibrationChange>? onCalibrationApplied;

  @override
  Widget build(BuildContext context) {
    final idTimerProfile = profile.copyWith(
      calibratedDelay: profile.idCalibratedDelay,
    );
    return Gen4TimerPanel(
      profile: idTimerProfile,
      targetDelay: targetDelay,
      targetSecond: targetSecond,
      targetDateTime: targetDateTime,
      delayHit: delayHit,
      delayHitToken: delayHitToken,
      hitSecond: hitSecond,
      lockDelayHit: lockDelayHit,
      onCalibrationApplied: onCalibrationApplied,
    );
  }
}

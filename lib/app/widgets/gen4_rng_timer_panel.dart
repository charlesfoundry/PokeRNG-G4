import 'package:flutter/material.dart';

import '../app_profile.dart';
import 'gen4_timer_panel.dart';

export 'gen4_timer_panel.dart' show Gen4TimerCalibrationChange;

enum Gen4TimerCalibrationSlot { encounter, id, egg }

class Gen4RngTimerPanel extends StatelessWidget {
  const Gen4RngTimerPanel({
    super.key,
    required this.slot,
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

  final Gen4TimerCalibrationSlot slot;
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
    return Gen4TimerPanel(
      profile: _timerProfile,
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

  AppProfile get _timerProfile {
    final calibratedDelay = switch (slot) {
      Gen4TimerCalibrationSlot.encounter => profile.calibratedDelay,
      Gen4TimerCalibrationSlot.id => profile.idCalibratedDelay,
      Gen4TimerCalibrationSlot.egg => profile.eggCalibratedDelay,
    };
    return profile.copyWith(calibratedDelay: calibratedDelay);
  }
}

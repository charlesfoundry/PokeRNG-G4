enum Gen4TimerConsole {
  gba,
  ndsSlot1,
  ndsSlot2,
  dsi,
  threeDs,
  custom;

  double frameRate({double customFrameRate = 60.0}) {
    return switch (this) {
      Gen4TimerConsole.gba => 16777216 / 280896,
      Gen4TimerConsole.ndsSlot1 => 59.8261,
      Gen4TimerConsole.ndsSlot2 => 59.6555,
      Gen4TimerConsole.dsi => 59.8261,
      Gen4TimerConsole.threeDs => 59.8261,
      Gen4TimerConsole.custom => customFrameRate,
    };
  }

  String get storageKey {
    return switch (this) {
      Gen4TimerConsole.gba => 'gba',
      Gen4TimerConsole.ndsSlot1 => 'ndsSlot1',
      Gen4TimerConsole.ndsSlot2 => 'ndsSlot2',
      Gen4TimerConsole.dsi => 'dsi',
      Gen4TimerConsole.threeDs => 'threeDs',
      Gen4TimerConsole.custom => 'custom',
    };
  }

  static Gen4TimerConsole fromStorageKey(String? value) {
    return switch (value) {
      'gba' => Gen4TimerConsole.gba,
      'ndsSlot2' => Gen4TimerConsole.ndsSlot2,
      'dsi' => Gen4TimerConsole.dsi,
      'threeDs' => Gen4TimerConsole.threeDs,
      'custom' => Gen4TimerConsole.custom,
      _ => Gen4TimerConsole.ndsSlot1,
    };
  }
}

class Gen4TimerSettings {
  const Gen4TimerSettings({
    this.console = Gen4TimerConsole.ndsSlot1,
    this.customFrameRate = 60.0,
    this.minimumLength = const Duration(seconds: 14),
    this.precisionCalibration = false,
  });

  final Gen4TimerConsole console;
  final double customFrameRate;
  final Duration minimumLength;
  final bool precisionCalibration;

  double get _millisecondsPerDelay {
    final frameRate = console.frameRate(customFrameRate: customFrameRate);
    if (frameRate <= 0) {
      throw ArgumentError.value(frameRate, 'customFrameRate');
    }
    return 1000 / frameRate;
  }

  int toDelays(Duration duration) {
    return _roundHalfToEven(
      duration.inMicroseconds / 1000 / _millisecondsPerDelay,
    );
  }

  Duration toDuration(int delays) {
    final milliseconds = _roundHalfToEven(_millisecondsPerDelay * delays);
    return Duration(milliseconds: milliseconds);
  }

  int calibrationToDelays(Duration duration) {
    if (precisionCalibration) {
      return _roundHalfToEven(duration.inMicroseconds / 1000);
    }
    return toDelays(duration);
  }

  Duration calibrationToDuration(int calibration) {
    if (precisionCalibration) {
      return Duration(milliseconds: calibration);
    }
    return toDuration(calibration);
  }
}

class Gen4TimerModel {
  const Gen4TimerModel({
    required this.targetDelay,
    required this.targetSecond,
    required this.calibratedDelay,
    required this.calibratedSecond,
  });

  final int targetDelay;
  final int targetSecond;
  final int calibratedDelay;
  final int calibratedSecond;
}

class Gen4TimerPhases {
  const Gen4TimerPhases({required this.first, required this.second});

  final Duration first;
  final Duration second;

  Duration get total => first + second;

  int get minutesBeforeTarget => total.inMilliseconds ~/ 60000;

  List<Duration> get values => [first, second];
}

class Gen4TimerCalibration {
  const Gen4TimerCalibration({
    required this.delayDelta,
    required this.nextCalibratedDelay,
  });

  final int delayDelta;
  final int nextCalibratedDelay;
}

class Gen4Timer {
  const Gen4Timer({this.settings = const Gen4TimerSettings()});

  static const closeThreshold = Duration(milliseconds: 167);

  final Gen4TimerSettings settings;

  Gen4TimerPhases createPhases(Gen4TimerModel model) {
    final calibration = _calibration(model);
    final secondPhase = _createDelayPhase(
      targetDelay: model.targetDelay,
      targetSecond: model.targetSecond,
      calibration: calibration,
    );
    return secondPhase;
  }

  int minutesBeforeTarget(Gen4TimerModel model) {
    final phases = _createDelayPhase(
      targetDelay: model.targetDelay,
      targetSecond: model.targetSecond,
      calibration: Duration.zero,
    );
    return phases.minutesBeforeTarget;
  }

  Gen4TimerCalibration calibrate({
    required Gen4TimerModel model,
    required int delayHit,
  }) {
    if (delayHit <= 0) {
      return Gen4TimerCalibration(
        delayDelta: 0,
        nextCalibratedDelay: model.calibratedDelay,
      );
    }
    final delta =
        settings.toDuration(delayHit) - settings.toDuration(model.targetDelay);
    final adjustedDelta = delta.abs() <= closeThreshold
        ? _scaleDuration(delta, 0.75)
        : delta;
    final delayDelta = settings.toDelays(adjustedDelta);
    return Gen4TimerCalibration(
      delayDelta: delayDelta,
      nextCalibratedDelay: model.calibratedDelay + delayDelta,
    );
  }

  Duration _calibration(Gen4TimerModel model) {
    final calibratedSecondMilliseconds = model.calibratedSecond * 1000;
    final calibratedSecondDelays = settings.toDelays(
      Duration(milliseconds: calibratedSecondMilliseconds),
    );
    return settings.toDuration(model.calibratedDelay - calibratedSecondDelays);
  }

  Gen4TimerPhases _createDelayPhase({
    required int targetDelay,
    required int targetSecond,
    required Duration calibration,
  }) {
    final targetDelayDuration = settings.toDuration(targetDelay);
    final first = _toMinimumLength(
      _createSecondPhase(targetSecond, calibration) - targetDelayDuration,
    );
    final second = targetDelayDuration - calibration;
    return Gen4TimerPhases(first: first, second: second);
  }

  Duration _createSecondPhase(int targetSecond, Duration calibration) {
    return _toMinimumLength(
      Duration(seconds: targetSecond) +
          calibration +
          const Duration(milliseconds: 200),
    );
  }

  Duration _toMinimumLength(Duration value) {
    var duration = value;
    while (duration < settings.minimumLength) {
      duration += const Duration(minutes: 1);
    }
    return duration;
  }
}

Duration _scaleDuration(Duration duration, double factor) {
  final microseconds = _roundHalfToEven(duration.inMicroseconds * factor);
  return Duration(microseconds: microseconds);
}

int _roundHalfToEven(num value) {
  if (!value.isFinite) {
    return value.round();
  }
  final lower = value.floor();
  final upper = value.ceil();
  if (lower == upper) {
    return lower;
  }
  final lowerDistance = value - lower;
  final upperDistance = upper - value;
  final epsilon =
      2.220446049250313e-16 * [1, value.abs()].reduce((a, b) => a > b ? a : b);
  if ((lowerDistance - upperDistance).abs() <= epsilon) {
    return lower.abs().isEven ? lower : upper;
  }
  return lowerDistance < upperDistance ? lower : upper;
}

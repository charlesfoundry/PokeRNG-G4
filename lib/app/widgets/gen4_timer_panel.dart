import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/gen4/gen4.dart';
import '../../l10n/app_localizations.dart';
import '../app_profile.dart';

const _timerCueLead = Duration(milliseconds: 1500);
const _timerPreparation = Duration(seconds: 5);
const _timerBeepChannel = MethodChannel('pokerng_g4/timer_beep');
const _screenAwakeChannel = MethodChannel('pokerng_g4/screen_awake');

enum _TimerPhase { idle, preparation, first, second, finished }

class Gen4TimerPanel extends StatefulWidget {
  const Gen4TimerPanel({
    super.key,
    required this.profile,
    this.targetDelay,
    this.targetSecond,
    this.targetDateTime,
    this.hitSecond,
    this.delayHit,
    this.delayHitToken,
    this.lockDelayHit = false,
    this.onCalibrationApplied,
    this.onFinished,
  });

  final AppProfile profile;
  final int? targetDelay;
  final int? targetSecond;
  final DateTime? targetDateTime;
  final int? hitSecond;
  final int? delayHit;
  final Object? delayHitToken;
  final bool lockDelayHit;
  final ValueChanged<Gen4TimerCalibrationChange>? onCalibrationApplied;
  final VoidCallback? onFinished;

  @override
  State<Gen4TimerPanel> createState() => _Gen4TimerPanelState();
}

class _Gen4TimerPanelState extends State<Gen4TimerPanel>
    with WidgetsBindingObserver {
  final _targetDelayController = TextEditingController();
  final _targetSecondController = TextEditingController();
  final _calibratedDelayController = TextEditingController();
  final _calibratedSecondController = TextEditingController();
  final _delayHitController = TextEditingController();
  final _stopwatch = Stopwatch();
  Timer? _timer;
  Timer? _cueTimer;
  List<Duration> _phases = const [];
  _TimerPhase _phase = _TimerPhase.idle;
  Duration _phaseDuration = Duration.zero;
  Duration _remaining = Duration.zero;
  int _signalVersion = 0;
  bool _phaseTransitionPending = false;
  Future<void>? _beepPreparation;
  bool _beepReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setProfileDefaults(widget.profile);
    _prepareTimerBeep();
  }

  @override
  void didUpdateWidget(covariant Gen4TimerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_timerRunning &&
        (_timerDefaultsChanged(oldWidget.profile, widget.profile) ||
            oldWidget.targetDelay != widget.targetDelay ||
            oldWidget.targetSecond != widget.targetSecond)) {
      _setProfileDefaults(widget.profile, includeDelayHit: false);
    }
    if (!_timerRunning &&
        (oldWidget.delayHit != widget.delayHit ||
            oldWidget.delayHitToken != widget.delayHitToken)) {
      _setDelayHitField(widget.delayHit);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setScreenAwake(false);
    _cancelTimer();
    _targetDelayController.dispose();
    _targetSecondController.dispose();
    _calibratedDelayController.dispose();
    _calibratedSecondController.dispose();
    _delayHitController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _setScreenAwake(_timerRunning);
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _setScreenAwake(false);
        _stopTimer();
    }
  }

  bool get _timerRunning {
    return _phase == _TimerPhase.preparation ||
        _phase == _TimerPhase.first ||
        _phase == _TimerPhase.second;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final hasSeedTime = widget.targetDateTime != null;
    final model = _model;
    final timer = Gen4Timer(settings: widget.profile.timerSettings);
    final phases = model == null || !hasSeedTime
        ? null
        : timer.createPhases(model);
    final ndsSetTime = phases == null
        ? null
        : widget.targetDateTime!.subtract(
            Duration(minutes: phases.minutesBeforeTarget),
          );
    final displayRemaining = _timerRunning
        ? _remaining
        : phases?.first ?? Duration.zero;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.retailTimer,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Text(_phaseLabel(l10n), style: theme.textTheme.labelMedium),
                ],
              ),
              const SizedBox(height: 10),
              _TimerInputGrid(
                children: [
                  _TimerNumberField(
                    label: l10n.timerTargetDelay,
                    controller: _targetDelayController,
                    enabled: !_timerRunning,
                    onChanged: _refresh,
                  ),
                  _TimerNumberField(
                    label: l10n.timerTargetSecond,
                    controller: _targetSecondController,
                    enabled: !_timerRunning,
                    onChanged: _refresh,
                  ),
                  _TimerNumberField(
                    label: l10n.timerCalibratedDelay,
                    controller: _calibratedDelayController,
                    enabled: !_timerRunning,
                    onChanged: _refresh,
                  ),
                  _TimerNumberField(
                    label: l10n.timerCalibratedSecond,
                    controller: _calibratedSecondController,
                    enabled: !_timerRunning,
                    onChanged: _refresh,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _TimerValue(
                      label: l10n.timerPreparation,
                      value: hasSeedTime
                          ? _formatDuration(_timerPreparation)
                          : '-',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TimerValue(
                      label: l10n.timerFirstCountdown,
                      value: phases == null
                          ? '-'
                          : _formatDuration(phases.first),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TimerValue(
                      label: l10n.timerSecondCountdown,
                      value: phases == null
                          ? '-'
                          : _formatDuration(phases.second),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _TimerValue(
                label: l10n.timerCurrentCountdown,
                value: phases == null && !_timerRunning
                    ? '-'
                    : _formatDuration(displayRemaining),
              ),
              if (kIsWeb)
                Text(
                  l10n.timerWebSoundUnsupported,
                  style: theme.textTheme.labelSmall,
                ),
              if (_error != null) ...[
                const SizedBox(height: 6),
                Text(
                  _error!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _TimerNumberField(
                      label: l10n.timerDelayHit,
                      controller: _delayHitController,
                      enabled:
                          !_timerRunning &&
                          !(widget.lockDelayHit && widget.delayHit != null),
                      onChanged: _refresh,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _timerRunning ? null : _applyCalibration,
                      child: Text(l10n.timerApplyCalibration),
                    ),
                  ),
                ],
              ),
              if (ndsSetTime != null) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.timerNdsSetTime(_formatClock(ndsSetTime)),
                  style: theme.textTheme.labelSmall,
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _timerRunning || hasSeedTime ? _toggleTimer : null,
                  icon: Icon(_timerRunning ? Icons.stop : Icons.play_arrow),
                  label: Text(_timerRunning ? l10n.timerStop : l10n.timerStart),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Gen4TimerModel? get _model {
    final targetDelay = _parseInt(_targetDelayController);
    final targetSecond = _parseInt(_targetSecondController);
    final calibratedDelay = _parseInt(_calibratedDelayController);
    final calibratedSecond = _parseInt(_calibratedSecondController);
    if (targetDelay == null ||
        targetSecond == null ||
        calibratedDelay == null ||
        calibratedSecond == null ||
        targetDelay < 0 ||
        targetSecond < 0 ||
        calibratedDelay < 0 ||
        calibratedSecond < 0) {
      return null;
    }
    return Gen4TimerModel(
      targetDelay: targetDelay,
      targetSecond: targetSecond,
      calibratedDelay: calibratedDelay,
      calibratedSecond: calibratedSecond,
    );
  }

  void _refresh() {
    setState(() => _error = null);
  }

  void _setProfileDefaults(AppProfile profile, {bool includeDelayHit = true}) {
    _targetDelayController.text =
        '${widget.targetDelay ?? profile.calibratedDelay}';
    _targetSecondController.text =
        '${widget.targetSecond ?? profile.calibratedSecond}';
    _calibratedDelayController.text = '${profile.calibratedDelay}';
    _calibratedSecondController.text = '${profile.calibratedSecond}';
    if (includeDelayHit) {
      _setDelayHitField(widget.delayHit);
    }
  }

  void _setDelayHitField(int? delayHit) {
    if (delayHit == null) {
      return;
    }
    _delayHitController.text = '$delayHit';
  }

  Future<void> _applyCalibration() async {
    final model = _model;
    final delayHit = _parseInt(_delayHitController);
    final l10n = AppLocalizations.of(context);
    if (model == null || delayHit == null || delayHit <= 0) {
      setState(() => _error = l10n.timerInputError);
      return;
    }
    final calibration = Gen4Timer(
      settings: widget.profile.timerSettings,
    ).calibrate(model: model, delayHit: delayHit);
    final timer = Gen4Timer(settings: widget.profile.timerSettings);
    final previousPhases = timer.createPhases(model);
    final secondDelta = _signedSecondDelta(
      hitSecond: widget.hitSecond,
      targetSecond: model.targetSecond,
    );
    final nextCalibratedSecond = (model.calibratedSecond + secondDelta)
        .clamp(0, 59)
        .toInt();
    final nextModel = Gen4TimerModel(
      targetDelay: model.targetDelay,
      targetSecond: model.targetSecond,
      calibratedDelay: calibration.nextCalibratedDelay,
      calibratedSecond: nextCalibratedSecond,
    );
    final nextPhases = timer.createPhases(nextModel);
    final change = Gen4TimerCalibrationChange(
      previousCalibratedDelay: model.calibratedDelay,
      nextCalibratedDelay: calibration.nextCalibratedDelay,
      previousCalibratedSecond: model.calibratedSecond,
      nextCalibratedSecond: nextCalibratedSecond,
      previousPhases: previousPhases,
      nextPhases: nextPhases,
    );
    setState(() {
      _calibratedDelayController.text = calibration.nextCalibratedDelay
          .toString();
      _calibratedSecondController.text = nextCalibratedSecond.toString();
      _delayHitController.clear();
      _error = null;
    });
    widget.onCalibrationApplied?.call(change);
    await _showCalibrationDialog(change);
  }

  Future<void> _showCalibrationDialog(Gen4TimerCalibrationChange change) async {
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.timerCalibrationAppliedTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.timerCalibrationDelayChange(
                  change.previousCalibratedDelay.toString(),
                  change.nextCalibratedDelay.toString(),
                ),
              ),
              Text(
                l10n.timerCalibrationSecondChange(
                  change.previousCalibratedSecond.toString(),
                  change.nextCalibratedSecond.toString(),
                ),
              ),
              Text(
                l10n.timerCalibrationFirstCountdownChange(
                  _formatDuration(change.previousPhases.first),
                  _formatDuration(change.nextPhases.first),
                ),
              ),
              Text(
                l10n.timerCalibrationSecondCountdownChange(
                  _formatDuration(change.previousPhases.second),
                  _formatDuration(change.nextPhases.second),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  void _toggleTimer() {
    if (_timerRunning) {
      _stopTimer();
      return;
    }
    _startTimer();
  }

  void _startTimer() {
    final model = _model;
    final l10n = AppLocalizations.of(context);
    if (model == null) {
      setState(() => _error = l10n.timerInputError);
      return;
    }
    final phases = Gen4Timer(
      settings: widget.profile.timerSettings,
    ).createPhases(model).values;
    _prepareTimerBeep();
    _timer?.cancel();
    _cueTimer?.cancel();
    _signalVersion += 1;
    _stopwatch
      ..reset()
      ..start();
    _setScreenAwake(true);
    setState(() {
      _error = null;
      _phases = phases;
      _phase = _TimerPhase.preparation;
      _phaseDuration = _timerPreparation;
      _remaining = _timerPreparation;
      _phaseTransitionPending = false;
    });
    _scheduleTimerCue(_TimerPhase.preparation, _timerPreparation);
    _timer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _tickTimer(),
    );
  }

  void _stopTimer() {
    _cancelTimer();
    if (!mounted) {
      return;
    }
    setState(_resetTimerState);
  }

  void _cancelTimer() {
    _signalVersion += 1;
    _cueTimer?.cancel();
    _cueTimer = null;
    _timer?.cancel();
    _timer = null;
    _stopwatch
      ..stop()
      ..reset();
    _phaseTransitionPending = false;
    _setScreenAwake(false);
  }

  void _resetTimerState() {
    _phase = _TimerPhase.idle;
    _phaseDuration = Duration.zero;
    _remaining = Duration.zero;
    _phases = const [];
    _phaseTransitionPending = false;
  }

  void _tickTimer() {
    if (!mounted) {
      _cancelTimer();
      return;
    }
    if (_phaseTransitionPending) {
      return;
    }
    final remaining = _phaseDuration - _stopwatch.elapsed;
    if (remaining > Duration.zero) {
      setState(() => _remaining = remaining);
      return;
    }
    if (_phase == _TimerPhase.preparation) {
      setState(() {
        _remaining = Duration.zero;
        _phaseTransitionPending = true;
      });
      _signalTimerAfterFrame(() {
        if (_phase != _TimerPhase.preparation || !_phaseTransitionPending) {
          return;
        }
        _stopwatch
          ..reset()
          ..start();
        setState(() {
          _phase = _TimerPhase.first;
          _phaseDuration = _phases[0];
          _remaining = _phases[0];
          _phaseTransitionPending = false;
        });
        _scheduleTimerCue(_TimerPhase.first, _phases[0]);
      });
      return;
    }
    if (_phase == _TimerPhase.first) {
      setState(() {
        _remaining = Duration.zero;
        _phaseTransitionPending = true;
      });
      _signalTimerAfterFrame(() {
        if (_phase != _TimerPhase.first || !_phaseTransitionPending) {
          return;
        }
        _stopwatch
          ..reset()
          ..start();
        setState(() {
          _phase = _TimerPhase.second;
          _phaseDuration = _phases[1];
          _remaining = _phases[1];
          _phaseTransitionPending = false;
        });
        _scheduleTimerCue(_TimerPhase.second, _phases[1]);
      });
      return;
    }
    _cancelTimer();
    setState(() {
      _phase = _TimerPhase.finished;
      _remaining = Duration.zero;
    });
    _signalTimerAfterFrame(widget.onFinished);
  }

  void _signalTimerAfterFrame([VoidCallback? afterSignal]) {
    final signalVersion = _signalVersion;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || signalVersion != _signalVersion) {
        return;
      }
      _signalTimer();
      afterSignal?.call();
    });
  }

  void _signalTimer() {
    unawaited(_playTimerHaptics());
  }

  void _scheduleTimerCue(_TimerPhase phase, Duration phaseDuration) {
    _cueTimer?.cancel();
    final cueDelay = phaseDuration - _timerCueLead;
    final signalVersion = _signalVersion;
    _cueTimer = Timer(cueDelay <= Duration.zero ? Duration.zero : cueDelay, () {
      if (!mounted || signalVersion != _signalVersion || _phase != phase) {
        return;
      }
      unawaited(_playTimerBeep());
    });
  }

  void _prepareTimerBeep() {
    if (kIsWeb) {
      return;
    }
    final preparation = _beepPreparation;
    if (preparation != null) {
      return;
    }
    _beepPreparation = _timerBeepChannel
        .invokeMethod<void>('prepare')
        .then<void>((_) {
          _beepReady = true;
        })
        .catchError((Object _) {
          _beepReady = false;
          _beepPreparation = null;
        });
  }

  Future<void> _playTimerBeep() async {
    if (kIsWeb) {
      unawaited(SystemSound.play(_timerSoundType));
      return;
    }
    try {
      if (!_beepReady) {
        _prepareTimerBeep();
        await _beepPreparation;
      }
      await _timerBeepChannel.invokeMethod<void>('play');
    } catch (_) {
      unawaited(SystemSound.play(_timerSoundType));
    }
  }

  SystemSoundType get _timerSoundType {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.fuchsia => SystemSoundType.click,
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => SystemSoundType.alert,
    };
  }

  Future<void> _playTimerHaptics() async {
    if (kIsWeb) {
      return;
    }
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }

  void _setScreenAwake(bool enabled) {
    if (kIsWeb) {
      return;
    }
    unawaited(
      _screenAwakeChannel
          .invokeMethod<void>('setEnabled', {'enabled': enabled})
          .catchError((Object _) {}),
    );
  }

  String _phaseLabel(AppLocalizations l10n) {
    return switch (_phase) {
      _TimerPhase.idle => l10n.timerReady,
      _TimerPhase.preparation => l10n.timerPreparation,
      _TimerPhase.first => l10n.timerPhase('1'),
      _TimerPhase.second => l10n.timerPhase('2'),
      _TimerPhase.finished => l10n.timerFinished,
    };
  }
}

class Gen4TimerCalibrationChange {
  const Gen4TimerCalibrationChange({
    required this.previousCalibratedDelay,
    required this.nextCalibratedDelay,
    required this.previousCalibratedSecond,
    required this.nextCalibratedSecond,
    required this.previousPhases,
    required this.nextPhases,
  });

  final int previousCalibratedDelay;
  final int nextCalibratedDelay;
  final int previousCalibratedSecond;
  final int nextCalibratedSecond;
  final Gen4TimerPhases previousPhases;
  final Gen4TimerPhases nextPhases;
}

class _TimerInputGrid extends StatelessWidget {
  const _TimerInputGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const columns = 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final child in children)
              SizedBox(
                width: (width - (columns - 1) * 8) / columns,
                child: child,
              ),
          ],
        );
      },
    );
  }
}

class _TimerNumberField extends StatelessWidget {
  const _TimerNumberField({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => onChanged(),
    );
  }
}

class _TimerValue extends StatelessWidget {
  const _TimerValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

int? _parseInt(TextEditingController controller) {
  return int.tryParse(controller.text.trim());
}

int _signedSecondDelta({required int? hitSecond, required int targetSecond}) {
  if (hitSecond == null) {
    return 0;
  }
  var delta = hitSecond - targetSecond;
  if (delta > 30) {
    delta -= 60;
  } else if (delta < -30) {
    delta += 60;
  }
  return delta;
}

String _formatDuration(Duration duration) {
  final positive = duration < Duration.zero ? Duration.zero : duration;
  final totalMilliseconds = positive.inMilliseconds;
  final minutes = totalMilliseconds ~/ 60000;
  final seconds = (totalMilliseconds % 60000) ~/ 1000;
  final milliseconds = totalMilliseconds % 1000;
  return '$minutes:${seconds.toString().padLeft(2, '0')}.'
      '${milliseconds.toString().padLeft(3, '0')}';
}

String _formatClock(DateTime dateTime) {
  return '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}';
}

bool _timerDefaultsChanged(AppProfile left, AppProfile right) {
  return left.calibratedDelay != right.calibratedDelay ||
      left.calibratedSecond != right.calibratedSecond ||
      left.delayWindow != right.delayWindow ||
      left.secondWindow != right.secondWindow ||
      left.timerConsole != right.timerConsole ||
      left.timerCustomFrameRate != right.timerCustomFrameRate ||
      left.timerMinimumLengthSeconds != right.timerMinimumLengthSeconds ||
      left.timerPrecisionCalibration != right.timerPrecisionCalibration;
}

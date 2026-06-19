import '../data/gen4/gen4_game.dart';
import '../core/gen4/gen4_timer.dart';

enum Gen4PhoneCaller {
  elm('elm'),
  irwin('irwin');

  const Gen4PhoneCaller(this.storageKey);

  final String storageKey;

  static Gen4PhoneCaller fromStorageKey(String? value) {
    return Gen4PhoneCaller.values.firstWhere(
      (caller) => caller.storageKey == value,
      orElse: () => Gen4PhoneCaller.elm,
    );
  }
}

class AppProfile {
  const AppProfile({
    required this.game,
    required this.tid,
    required this.sid,
    this.calibratedDelay = 500,
    this.idCalibratedDelay = 500,
    this.eggCalibratedDelay = 500,
    this.calibratedSecond = 14,
    this.delayWindow = 20,
    this.secondWindow = 2,
    this.maxPhoneCallSkip = 30,
    this.timerConsole = Gen4TimerConsole.ndsSlot1,
    this.timerCustomFrameRate = 60.0,
    this.timerMinimumLengthSeconds = 14,
    this.timerPrecisionCalibration = false,
    this.phoneCaller = Gen4PhoneCaller.elm,
    this.eggParentAIvs = defaultEggParentIvs,
    this.eggParentBIvs = defaultEggParentIvs,
    this.eggMasuda = false,
    this.eggLockedPid = '',
  });

  static const defaultEggParentIvs = [31, 31, 31, 31, 31, 31];

  factory AppProfile.defaultsFor(Gen4GameVersion game) {
    return AppProfile(game: game, tid: 0, sid: 0);
  }

  static AppProfile get initial {
    return AppProfile.defaultsFor(Gen4GameVersion.diamond);
  }

  final Gen4GameVersion game;
  final int tid;
  final int sid;
  final int calibratedDelay;
  final int idCalibratedDelay;
  final int eggCalibratedDelay;
  final int calibratedSecond;
  final int delayWindow;
  final int secondWindow;
  final int maxPhoneCallSkip;
  final Gen4TimerConsole timerConsole;
  final double timerCustomFrameRate;
  final int timerMinimumLengthSeconds;
  final bool timerPrecisionCalibration;
  final Gen4PhoneCaller phoneCaller;
  final List<int> eggParentAIvs;
  final List<int> eggParentBIvs;
  final bool eggMasuda;
  final String eggLockedPid;

  Gen4TimerSettings get timerSettings {
    return Gen4TimerSettings(
      console: timerConsole,
      customFrameRate: timerCustomFrameRate,
      minimumLength: Duration(seconds: timerMinimumLengthSeconds),
      precisionCalibration: timerPrecisionCalibration,
    );
  }

  AppProfile copyWith({
    Gen4GameVersion? game,
    int? tid,
    int? sid,
    int? calibratedDelay,
    int? idCalibratedDelay,
    int? eggCalibratedDelay,
    int? calibratedSecond,
    int? delayWindow,
    int? secondWindow,
    int? maxPhoneCallSkip,
    Gen4TimerConsole? timerConsole,
    double? timerCustomFrameRate,
    int? timerMinimumLengthSeconds,
    bool? timerPrecisionCalibration,
    Gen4PhoneCaller? phoneCaller,
    List<int>? eggParentAIvs,
    List<int>? eggParentBIvs,
    bool? eggMasuda,
    String? eggLockedPid,
  }) {
    return AppProfile(
      game: game ?? this.game,
      tid: tid ?? this.tid,
      sid: sid ?? this.sid,
      calibratedDelay: calibratedDelay ?? this.calibratedDelay,
      idCalibratedDelay: idCalibratedDelay ?? this.idCalibratedDelay,
      eggCalibratedDelay: eggCalibratedDelay ?? this.eggCalibratedDelay,
      calibratedSecond: calibratedSecond ?? this.calibratedSecond,
      delayWindow: delayWindow ?? this.delayWindow,
      secondWindow: secondWindow ?? this.secondWindow,
      maxPhoneCallSkip: maxPhoneCallSkip ?? this.maxPhoneCallSkip,
      timerConsole: timerConsole ?? this.timerConsole,
      timerCustomFrameRate: timerCustomFrameRate ?? this.timerCustomFrameRate,
      timerMinimumLengthSeconds:
          timerMinimumLengthSeconds ?? this.timerMinimumLengthSeconds,
      timerPrecisionCalibration:
          timerPrecisionCalibration ?? this.timerPrecisionCalibration,
      phoneCaller: phoneCaller ?? this.phoneCaller,
      eggParentAIvs: eggParentAIvs ?? this.eggParentAIvs,
      eggParentBIvs: eggParentBIvs ?? this.eggParentBIvs,
      eggMasuda: eggMasuda ?? this.eggMasuda,
      eggLockedPid: eggLockedPid ?? this.eggLockedPid,
    );
  }
}

import 'lcrng.dart';
import 'seed_verification.dart';

enum Gen4SeedTimeVerificationType { coinFlips, phoneCalls }

class Gen4SeedTime {
  const Gen4SeedTime({required this.dateTime, required this.delay});

  final DateTime dateTime;
  final int delay;

  int get seed => calcSeed(dateTime: dateTime, delay: delay);

  static int calcSeed({required DateTime dateTime, required int delay}) {
    _validateYear(dateTime.year);
    _validateDelay(delay);
    final ab =
        (dateTime.month * dateTime.day + dateTime.minute + dateTime.second) &
        0xff;
    final cd = dateTime.hour & 0xff;
    return (((ab << 24) | (cd << 16)) + delay + dateTime.year - 2000) &
        0xffffffff;
  }

  static List<Gen4SeedTime> calculateTimes({
    required int seed,
    required int year,
    bool forceSecond = false,
    int forcedSecond = 0,
  }) {
    if (forcedSecond < 0 || forcedSecond > 59) {
      throw ArgumentError.value(
        forcedSecond,
        'forcedSecond',
        'must be in 0..59',
      );
    }
    final info = seedInfo(seed: seed, year: year);

    final results = <Gen4SeedTime>[];
    for (var month = 1; month <= 12; month++) {
      final maxDay = DateTime(year, month + 1, 0).day;
      for (var day = 1; day <= maxDay; day++) {
        for (var minute = 0; minute < 60; minute++) {
          for (var second = 0; second < 60; second++) {
            if (forceSecond && second != forcedSecond) {
              continue;
            }
            if (info.ab == ((month * day + minute + second) & 0xff)) {
              results.add(
                Gen4SeedTime(
                  dateTime: DateTime(
                    year,
                    month,
                    day,
                    info.hour,
                    minute,
                    second,
                  ),
                  delay: info.delay,
                ),
              );
            }
          }
        }
      }
    }
    return results;
  }

  static Gen4SeedTimeInfo seedInfo({required int seed, required int year}) {
    _validateSeed(seed);
    _validateYear(year);
    final ab = (seed >>> 24) & 0xff;
    final hourByte = (seed >>> 16) & 0xff;
    final rawDelay = seed & 0xffff;
    final hour = hourByte > 23 ? 23 : hourByte;
    final delay =
        (hourByte > 23
            ? rawDelay + (2000 - year) + ((hourByte - 23) * 0x10000)
            : rawDelay + (2000 - year)) &
        u32Mask;
    return Gen4SeedTimeInfo(
      seed: seed,
      year: year,
      ab: ab,
      hourByte: hourByte,
      rawDelay: rawDelay,
      hour: hour,
      delay: delay,
    );
  }

  static List<Gen4SeedTimeCalibration> calibrate({
    required Gen4SeedTime target,
    required int delayCalibration,
    required int secondCalibration,
  }) {
    return _calibrate(
      target: target,
      delayCalibration: delayCalibration,
      secondCalibration: secondCalibration,
    );
  }

  static List<Gen4SeedTimeCalibration> calibrateHgssRoamers({
    required Gen4SeedTime target,
    required int delayCalibration,
    required int secondCalibration,
    required bool raikouActive,
    required bool enteiActive,
    required bool latiActive,
    required int raikouRoute,
    required int enteiRoute,
    required int latiRoute,
  }) {
    return _calibrate(
      target: target,
      delayCalibration: delayCalibration,
      secondCalibration: secondCalibration,
      roamerFactory: (seed) => Gen4SeedVerification.hgssRoamerRoutes(
        seed: seed,
        raikouActive: raikouActive,
        enteiActive: enteiActive,
        latiActive: latiActive,
        raikouRoute: raikouRoute,
        enteiRoute: enteiRoute,
        latiRoute: latiRoute,
      ),
    );
  }

  static List<Gen4SeedTimeCalibration> searchByCoinFlips({
    required Gen4SeedTime target,
    required int delayCalibration,
    required int secondCalibration,
    required List<CoinFlip> observed,
  }) {
    _validateObservedSequence(observed, 'observed');
    return calibrate(
          target: target,
          delayCalibration: delayCalibration,
          secondCalibration: secondCalibration,
        )
        .where((result) {
          return _startsWith(
            result.coinFlips.take(observed.length).toList(growable: false),
            observed,
          );
        })
        .toList(growable: false);
  }

  static List<Gen4SeedTimeCalibration> searchByPhoneCalls({
    required Gen4SeedTime target,
    required int delayCalibration,
    required int secondCalibration,
    required List<PhoneCall> observed,
    int minPhoneCallSkip = 0,
    int maxPhoneCallSkip = 0,
  }) {
    _validateObservedSequence(observed, 'observed');
    _validateSkipRange(minPhoneCallSkip, maxPhoneCallSkip);
    final results = <Gen4SeedTimeCalibration>[];
    for (final result in calibrate(
      target: target,
      delayCalibration: delayCalibration,
      secondCalibration: secondCalibration,
    )) {
      for (final skip in _matchingPhoneCallSkips(
        result: result,
        observed: observed,
        minPhoneCallSkip: minPhoneCallSkip,
        maxPhoneCallSkip: maxPhoneCallSkip,
      )) {
        results.add(
          result.withPhoneCallSkip(
            skip,
            observedPhoneCallCount: observed.length,
          ),
        );
      }
    }
    return results;
  }

  static List<Gen4SeedTimeCalibration> searchHgssRoamersByPhoneCalls({
    required Gen4SeedTime target,
    required int delayCalibration,
    required int secondCalibration,
    required List<PhoneCall> observed,
    required bool raikouActive,
    required bool enteiActive,
    required bool latiActive,
    required int raikouRoute,
    required int enteiRoute,
    required int latiRoute,
    int minPhoneCallSkip = 0,
    int maxPhoneCallSkip = 0,
  }) {
    _validateObservedSequence(observed, 'observed');
    _validateSkipRange(minPhoneCallSkip, maxPhoneCallSkip);
    final results = <Gen4SeedTimeCalibration>[];
    for (final result in calibrateHgssRoamers(
      target: target,
      delayCalibration: delayCalibration,
      secondCalibration: secondCalibration,
      raikouActive: raikouActive,
      enteiActive: enteiActive,
      latiActive: latiActive,
      raikouRoute: raikouRoute,
      enteiRoute: enteiRoute,
      latiRoute: latiRoute,
    )) {
      for (final skip in _matchingPhoneCallSkips(
        result: result,
        observed: observed,
        minPhoneCallSkip: minPhoneCallSkip,
        maxPhoneCallSkip: maxPhoneCallSkip,
      )) {
        results.add(
          result.withPhoneCallSkip(
            skip,
            observedPhoneCallCount: observed.length,
          ),
        );
      }
    }
    return results;
  }

  static List<Gen4SeedTimeCalibration> _calibrate({
    required Gen4SeedTime target,
    required int delayCalibration,
    required int secondCalibration,
    HgssRoamerRoutes Function(int seed)? roamerFactory,
  }) {
    if (delayCalibration < 0) {
      throw ArgumentError.value(
        delayCalibration,
        'delayCalibration',
        'must be non-negative',
      );
    }
    if (secondCalibration < 0) {
      throw ArgumentError.value(
        secondCalibration,
        'secondCalibration',
        'must be non-negative',
      );
    }
    _validateYear(target.dateTime.year);
    _validateDelay(target.delay);
    if (target.delay - delayCalibration < 0 ||
        target.delay + delayCalibration > u32Mask) {
      throw ArgumentError(
        'calibrated delay range must stay within 0..0xffffffff',
      );
    }

    final results = <Gen4SeedTimeCalibration>[];
    for (
      var secondOffset = -secondCalibration;
      secondOffset <= secondCalibration;
      secondOffset++
    ) {
      final dateTime = target.dateTime.add(Duration(seconds: secondOffset));
      for (
        var delayOffset = -delayCalibration;
        delayOffset <= delayCalibration;
        delayOffset++
      ) {
        final delay = target.delay + delayOffset;
        final seed = calcSeed(dateTime: dateTime, delay: delay);
        results.add(
          Gen4SeedTimeCalibration(
            dateTime: dateTime,
            delay: delay,
            seed: seed,
            roamerRoutes: roamerFactory?.call(seed),
          ),
        );
      }
    }
    return results;
  }

  @override
  String toString() {
    return '${dateTime.toIso8601String()} delay=$delay';
  }
}

class Gen4SeedTimeInfo {
  const Gen4SeedTimeInfo({
    required this.seed,
    required this.year,
    required this.ab,
    required this.hourByte,
    required this.rawDelay,
    required this.hour,
    required this.delay,
  });

  final int seed;
  final int year;
  final int ab;
  final int hourByte;
  final int rawDelay;
  final int hour;
  final int delay;

  bool get hasOverflowHour => hourByte > 23;
}

void _validateSeed(int seed) {
  if (seed < 0 || seed > u32Mask) {
    throw ArgumentError.value(seed, 'seed', 'must be in 0..0xffffffff');
  }
}

void _validateDelay(int delay) {
  if (delay < 0 || delay > u32Mask) {
    throw ArgumentError.value(delay, 'delay', 'must be in 0..0xffffffff');
  }
}

void _validateYear(int year) {
  if (year < 2000 || year > 2099) {
    throw ArgumentError.value(year, 'year', 'must be in 2000..2099');
  }
}

void _validateObservedSequence<T>(List<T> observed, String name) {
  if (observed.isEmpty) {
    throw ArgumentError.value(observed, name, 'must not be empty');
  }
}

void _validateSkipRange(int minSkip, int maxSkip) {
  if (minSkip < 0 || maxSkip < minSkip) {
    throw ArgumentError.value(
      maxSkip,
      'maxPhoneCallSkip',
      'must be greater than or equal to minPhoneCallSkip',
    );
  }
}

bool _startsWith<T>(List<T> actual, List<T> expected) {
  if (actual.length < expected.length) {
    return false;
  }
  for (var index = 0; index < expected.length; index += 1) {
    if (actual[index] != expected[index]) {
      return false;
    }
  }
  return true;
}

List<int> _matchingPhoneCallSkips({
  required Gen4SeedTimeCalibration result,
  required List<PhoneCall> observed,
  required int minPhoneCallSkip,
  required int maxPhoneCallSkip,
}) {
  final stream = Gen4SeedVerification.phoneCalls(
    result.seed,
    count: maxPhoneCallSkip + observed.length,
    skips: result.roamerSkipCount,
  );
  final matches = <int>[];
  for (var skip = minPhoneCallSkip; skip <= maxPhoneCallSkip; skip += 1) {
    if (_matchesAt(stream, observed, skip)) {
      matches.add(skip);
    }
  }
  return matches;
}

bool _matchesAt<T>(List<T> actual, List<T> expected, int start) {
  if (start < 0 || actual.length - start < expected.length) {
    return false;
  }
  for (var index = 0; index < expected.length; index += 1) {
    if (actual[start + index] != expected[index]) {
      return false;
    }
  }
  return true;
}

class Gen4SeedTimeCalibration extends Gen4SeedTime {
  const Gen4SeedTimeCalibration({
    required super.dateTime,
    required super.delay,
    required this.seed,
    this.roamerRoutes,
    this.phoneCallSkip = 0,
    this.observedPhoneCallCount = 0,
  });

  @override
  final int seed;

  final HgssRoamerRoutes? roamerRoutes;

  final int phoneCallSkip;

  final int observedPhoneCallCount;

  Gen4SeedTimeVerificationType get verificationType => roamerRoutes == null
      ? Gen4SeedTimeVerificationType.coinFlips
      : Gen4SeedTimeVerificationType.phoneCalls;

  int get roamerSkipCount => roamerRoutes?.skips ?? 0;

  int get totalPhoneCallSkip => roamerSkipCount + phoneCallSkip;

  int get currentAdvance => totalPhoneCallSkip + observedPhoneCallCount;

  bool get usesHgssRoamerSkips => roamerSkipCount > 0;

  bool get usesPhoneCallSkip => totalPhoneCallSkip > 0;

  List<CoinFlip> get coinFlips => Gen4SeedVerification.coinFlips(seed);

  String get coinFlipSequence => Gen4SeedVerification.coinFlipString(seed);

  List<PhoneCall> get phoneCalls =>
      Gen4SeedVerification.phoneCalls(seed, skips: totalPhoneCallSkip);

  String get phoneCallSequence =>
      Gen4SeedVerification.phoneCallString(seed, skips: totalPhoneCallSkip);

  String get verificationSequence {
    return switch (verificationType) {
      Gen4SeedTimeVerificationType.coinFlips => coinFlipSequence,
      Gen4SeedTimeVerificationType.phoneCalls => phoneCallSequence,
    };
  }

  String get sequence => verificationSequence;

  Gen4SeedTimeCalibration withPhoneCallSkip(
    int skip, {
    int observedPhoneCallCount = 0,
  }) {
    return Gen4SeedTimeCalibration(
      dateTime: dateTime,
      delay: delay,
      seed: seed,
      roamerRoutes: roamerRoutes,
      phoneCallSkip: skip,
      observedPhoneCallCount: observedPhoneCallCount,
    );
  }
}

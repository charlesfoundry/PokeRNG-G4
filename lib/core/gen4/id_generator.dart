import 'lcrng.dart';
import 'mt.dart';
import 'pokemon_attributes.dart';
import 'seed_time.dart';
import 'static_generator.dart';

class Gen4IdGenerator {
  const Gen4IdGenerator({
    required this.minDelay,
    required this.maxDelay,
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    this.filter = const Gen4IdFilter(),
  });

  final int minDelay;
  final int maxDelay;
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;
  final Gen4IdFilter filter;

  List<Gen4IdState> generate() {
    _validateConfiguration();

    final states = <Gen4IdState>[];
    for (var second = 0; second < 60; second++) {
      for (var efgh = minDelay; efgh <= maxDelay; efgh++) {
        final seed =
            ((((month * day) + minute + second) & 0xff) << 24) | (hour << 16);
        final state = Gen4IdState.fromSeed(
          seed + efgh,
          delay: efgh + 2000 - year,
          second: second,
        );
        if (filter.matches(state)) {
          states.add(state);
        }
      }
    }
    return states;
  }

  void _validateConfiguration() {
    _validateDelayRange(minDelay: minDelay, maxDelay: maxDelay);
    _validateYear(year);
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'must be in 1..12');
    }
    final maxDay = DateTime(year, month + 1, 0).day;
    if (day < 1 || day > maxDay) {
      throw ArgumentError.value(day, 'day', 'must be valid for month/year');
    }
    if (hour < 0 || hour > 23) {
      throw ArgumentError.value(hour, 'hour', 'must be in 0..23');
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(minute, 'minute', 'must be in 0..59');
    }
    filter._validate();
  }
}

class Gen4IdSearcher {
  const Gen4IdSearcher({
    required this.minDelay,
    required this.maxDelay,
    required this.year,
    this.filter = const Gen4IdFilter(),
  });

  final int minDelay;
  final int maxDelay;
  final int year;
  final Gen4IdFilter filter;

  List<Gen4IdState> search() {
    _validateConfiguration();

    final states = <Gen4IdState>[];
    for (var efgh = minDelay; efgh <= maxDelay; efgh++) {
      for (var ab = 0; ab < 256; ab++) {
        for (var cd = 0; cd < 24; cd++) {
          final seed = (ab << 24) | (cd << 16) | efgh;
          final state = Gen4IdState.fromSeed(seed, delay: efgh + 2000 - year);
          if (filter.matches(state)) {
            states.add(state);
          }
        }
      }
    }
    return states;
  }

  void _validateConfiguration() {
    _validateDelayRange(minDelay: minDelay, maxDelay: maxDelay);
    _validateYear(year);
    filter._validate();
  }
}

class Gen4IdHitSearcher {
  const Gen4IdHitSearcher({
    required this.target,
    required this.delayWindow,
    required this.secondWindow,
    required this.tid,
    this.sid,
  });

  final Gen4SeedTime target;
  final int delayWindow;
  final int secondWindow;
  final int tid;
  final int? sid;

  List<Gen4IdHit> search() {
    _validate();

    final hits = <Gen4IdHit>[];
    for (
      var secondOffset = -secondWindow;
      secondOffset <= secondWindow;
      secondOffset += 1
    ) {
      final dateTime = target.dateTime.add(Duration(seconds: secondOffset));
      final minDelay = target.delay - delayWindow;
      final maxDelay = target.delay + delayWindow;
      final rawMinDelay = _displayDelayToRaw(minDelay, dateTime.year);
      final rawMaxDelay = _displayDelayToRaw(maxDelay, dateTime.year);
      if (rawMinDelay < 0 || rawMaxDelay > 0xffff) {
        continue;
      }
      final states = Gen4IdGenerator(
        minDelay: rawMinDelay,
        maxDelay: rawMaxDelay,
        year: dateTime.year,
        month: dateTime.month,
        day: dateTime.day,
        hour: dateTime.hour,
        minute: dateTime.minute,
        filter: Gen4IdFilter(
          tids: {tid},
          sids: sid == null ? const {} : {sid!},
          seconds: {dateTime.second},
        ),
      ).generate();
      for (final state in states) {
        hits.add(
          Gen4IdHit(
            seedTime: Gen4SeedTime(dateTime: dateTime, delay: state.delay),
            state: state,
          ),
        );
      }
    }
    hits.sort((left, right) {
      final leftSecondDistance = left.seedTime.dateTime
          .difference(target.dateTime)
          .inSeconds
          .abs();
      final rightSecondDistance = right.seedTime.dateTime
          .difference(target.dateTime)
          .inSeconds
          .abs();
      final secondCompare = leftSecondDistance.compareTo(rightSecondDistance);
      if (secondCompare != 0) {
        return secondCompare;
      }
      return (left.state.delay - target.delay).abs().compareTo(
        (right.state.delay - target.delay).abs(),
      );
    });
    return hits;
  }

  void _validate() {
    if (delayWindow < 0) {
      throw ArgumentError.value(delayWindow, 'delayWindow', 'must be >= 0');
    }
    if (secondWindow < 0) {
      throw ArgumentError.value(secondWindow, 'secondWindow', 'must be >= 0');
    }
    _validateSet({tid}, name: 'tid', min: 0, max: 0xffff);
    if (sid != null) {
      _validateSet({sid!}, name: 'sid', min: 0, max: 0xffff);
    }
  }
}

class Gen4IdHit {
  const Gen4IdHit({required this.seedTime, required this.state});

  final Gen4SeedTime seedTime;
  final Gen4IdState state;
}

class Gen4IdState {
  const Gen4IdState({
    required this.seed,
    required this.delay,
    required this.tid,
    required this.sid,
    this.second,
  });

  factory Gen4IdState.fromSeed(int seed, {required int delay, int? second}) {
    final sidtid = Mt(seed, 1).next();
    return Gen4IdState(
      seed: seed & u32Mask,
      delay: delay,
      tid: sidtid & 0xffff,
      sid: sidtid >>> 16,
      second: second,
    );
  }

  final int seed;
  final int delay;
  final int tid;
  final int sid;
  final int? second;

  int get hour => (seed >>> 16) & 0xff;
  int get trainerShinyValue =>
      PokemonTrainerIds.trainerShinyValue(tid: tid, sid: sid);
  int get fullTrainerShinyValue =>
      PokemonTrainerIds.fullShinyValue(tid: tid, sid: sid);

  Gen4SeedTimeInfo seedInfo({required int year}) {
    return Gen4SeedTime.seedInfo(seed: seed, year: year);
  }

  List<Gen4SeedTime> seedTimes({
    required int year,
    bool forceSecond = false,
    int forcedSecond = 0,
  }) {
    return Gen4SeedTime.calculateTimes(
      seed: seed,
      year: year,
      forceSecond: forceSecond,
      forcedSecond: forcedSecond,
    );
  }
}

class Gen4ShinySidRange {
  const Gen4ShinySidRange({required this.first, required this.last});

  factory Gen4ShinySidRange.fromTidPid({required int tid, required int pid}) {
    _validateSet({tid}, name: 'tid', min: 0, max: 0xffff);
    _validateSet({pid}, name: 'pid', min: 0, max: u32Mask);
    final squareSid =
        PokemonPid(pid).fullPersonalityShinyValue ^ (tid & 0xffff);
    final first = squareSid & 0xfff8;
    return Gen4ShinySidRange(first: first, last: first + 7);
  }

  final int first;
  final int last;

  bool contains(int sid) => sid >= first && sid <= last;

  List<int> get values {
    return [for (var sid = first; sid <= last; sid += 1) sid];
  }

  String get display {
    return '${first.toString().padLeft(5, '0')} - '
        '${last.toString().padLeft(5, '0')}';
  }
}

class Gen4CuteCharmIdTarget {
  const Gen4CuteCharmIdTarget({
    required this.lead,
    required this.genderRatio,
    required this.nature,
    required this.pid,
    required this.targetGender,
  });

  factory Gen4CuteCharmIdTarget.create({
    required Gen4CuteCharmLead lead,
    required int genderRatio,
    required Nature nature,
  }) {
    if (lead == Gen4CuteCharmLead.none) {
      throw ArgumentError.value(lead, 'lead', 'must be male or female');
    }
    if (!PokemonGenderRatio.isVariable(genderRatio)) {
      throw ArgumentError.value(
        genderRatio,
        'genderRatio',
        'must be a variable gender ratio',
      );
    }
    final buffer = lead == Gen4CuteCharmLead.female
        ? PokemonGenderRatio.cuteCharmFemaleBuffer(genderRatio)
        : 0;
    final pid = buffer + nature.index;
    final targetGender = PokemonPid(pid).gender(genderRatio: genderRatio);
    final expectedGender = lead == Gen4CuteCharmLead.female
        ? PokemonGender.male
        : PokemonGender.female;
    if (targetGender != expectedGender) {
      throw ArgumentError.value(
        genderRatio,
        'genderRatio',
        'does not support this Cute Charm target nature',
      );
    }
    return Gen4CuteCharmIdTarget(
      lead: lead,
      genderRatio: genderRatio,
      nature: nature,
      pid: pid,
      targetGender: targetGender,
    );
  }

  final Gen4CuteCharmLead lead;
  final int genderRatio;
  final Nature nature;
  final int pid;
  final PokemonGender targetGender;

  PokemonPid get pokemonPid => PokemonPid(pid);
  int get trainerShinyValue => pokemonPid.personalityShinyValue;
  int get abilitySlot => pokemonPid.abilitySlot;
}

class Gen4IdFilter {
  const Gen4IdFilter({
    this.tids = const {},
    this.sids = const {},
    this.trainerShinyValues = const {},
    this.seeds = const {},
    this.delays = const {},
    this.seconds = const {},
  });

  final Set<int> tids;
  final Set<int> sids;
  final Set<int> trainerShinyValues;
  final Set<int> seeds;
  final Set<int> delays;
  final Set<int> seconds;

  bool matches(Gen4IdState state) {
    return (tids.isEmpty || tids.contains(state.tid)) &&
        (sids.isEmpty || sids.contains(state.sid)) &&
        (trainerShinyValues.isEmpty ||
            trainerShinyValues.contains(state.trainerShinyValue)) &&
        (seeds.isEmpty || seeds.contains(state.seed)) &&
        (delays.isEmpty || delays.contains(state.delay)) &&
        (seconds.isEmpty ||
            (state.second != null && seconds.contains(state.second)));
  }

  void _validate() {
    _validateSet(tids, name: 'tids', min: 0, max: 0xffff);
    _validateSet(sids, name: 'sids', min: 0, max: 0xffff);
    _validateSet(
      trainerShinyValues,
      name: 'trainerShinyValues',
      min: 0,
      max: 0x1fff,
    );
    _validateSet(seeds, name: 'seeds', min: 0, max: u32Mask);
    _validateSet(delays, name: 'delays', min: -99, max: 0xffff);
    _validateSet(seconds, name: 'seconds', min: 0, max: 59);
  }
}

void _validateDelayRange({required int minDelay, required int maxDelay}) {
  if (minDelay > maxDelay) {
    throw ArgumentError('minDelay must be <= maxDelay');
  }
  if (minDelay < 0 || maxDelay > 0xffff) {
    throw ArgumentError('delay range must be within 0..65535');
  }
}

void _validateYear(int year) {
  if (year < 2000 || year > 2099) {
    throw ArgumentError.value(year, 'year', 'must be in 2000..2099');
  }
}

int _displayDelayToRaw(int delay, int year) {
  return delay + year - 2000;
}

void _validateSet(
  Set<int> values, {
  required String name,
  required int min,
  required int max,
}) {
  for (final value in values) {
    if (value < min || value > max) {
      throw ArgumentError.value(value, name, 'must be in $min..$max');
    }
  }
}

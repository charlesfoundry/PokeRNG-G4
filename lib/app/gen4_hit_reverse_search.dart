import '../core/gen4/gen4.dart';
import '../data/gen4/gen4_game.dart';
import '../data/gen4/personal_data.dart';
import '../data/gen4/wild_encounter_repository.dart';
import '../data/gen4/wild_encounters.dart';
import 'search_results.dart';

const gen4HitReverseResultLimit = 200;

class Gen4HitReverseRequest {
  const Gen4HitReverseRequest({
    required this.target,
    required this.personal,
    required this.wildRepository,
    required this.tid,
    required this.sid,
    required this.speciesId,
    required this.level,
    required this.nature,
    required this.observedStats,
    required this.minAdvance,
    required this.maxAdvance,
    this.abilitySlot,
    this.gender,
    this.characteristic,
    this.extraSeeds = const [],
    this.targetSeedTime,
    this.nearbyDelayWindow = 0,
    this.nearbySecondWindow = 0,
    this.alwaysSearchNearbySeeds = false,
    this.maxResults = gen4HitReverseResultLimit,
  });

  final Gen4SearchResultRow target;
  final Gen4PersonalTable personal;
  final Gen4WildEncounterRepository wildRepository;
  final int tid;
  final int sid;
  final int speciesId;
  final int level;
  final Nature nature;
  final PokemonStats observedStats;
  final int minAdvance;
  final int maxAdvance;
  final int? abilitySlot;
  final PokemonGender? gender;
  final int? characteristic;
  final List<int> extraSeeds;
  final Gen4SeedTime? targetSeedTime;
  final int nearbyDelayWindow;
  final int nearbySecondWindow;
  final bool alwaysSearchNearbySeeds;
  final int maxResults;
}

class Gen4HitReverseResult {
  const Gen4HitReverseResult({
    required this.seed,
    required this.delay,
    required this.advance,
    required this.speciesId,
    required this.level,
    required this.nature,
    required this.pid,
    required this.ivs,
    required this.stats,
    required this.abilitySlot,
    required this.gender,
    required this.hiddenPowerType,
    required this.hiddenPowerStrength,
    this.encounterSlot,
  });

  final int seed;
  final int delay;
  final int advance;
  final int speciesId;
  final int level;
  final Nature nature;
  final String pid;
  final Ivs ivs;
  final PokemonStats stats;
  final int abilitySlot;
  final PokemonGender gender;
  final int hiddenPowerType;
  final int hiddenPowerStrength;
  final int? encounterSlot;

  String get seedHex => seed.toRadixString(16).padLeft(8, '0').toUpperCase();

  bool isShiny({required int tid, required int sid}) {
    return PokemonPid(int.parse(pid, radix: 16)).isShiny(tid: tid, sid: sid);
  }
}

List<Gen4HitReverseResult> searchGen4HitReverse(Gen4HitReverseRequest request) {
  if (request.minAdvance < 0 || request.maxAdvance < request.minAdvance) {
    throw ArgumentError('invalid reverse hit advance range');
  }
  final source = request.target.source;
  if (source == null) {
    return const [];
  }
  final seed = int.tryParse(request.target.seed, radix: 16);
  if (seed == null) {
    return const [];
  }
  final currentSeedResults = _searchSeed(request, source, seed);
  if (currentSeedResults.isNotEmpty && !request.alwaysSearchNearbySeeds) {
    return _sortedLimited(currentSeedResults, request.maxResults);
  }

  final results = <Gen4HitReverseResult>[...currentSeedResults];
  for (final candidateSeed in _fallbackSeeds(request, seed)) {
    results.addAll(_searchSeed(request, source, candidateSeed));
    if (results.length >= request.maxResults) {
      break;
    }
  }
  return _sortedLimited(results, request.maxResults);
}

List<Gen4HitReverseResult> _searchSeed(
  Gen4HitReverseRequest request,
  Gen4SearchResultSource source,
  int seed,
) {
  if (source.isWild) {
    return _searchWild(request, source, seed);
  }
  if (source.isStatic) {
    return _searchStatic(request, source, seed);
  }
  return const [];
}

List<int> _fallbackSeeds(Gen4HitReverseRequest request, int targetSeed) {
  if (request.extraSeeds.isNotEmpty) {
    return [
      for (final seed in request.extraSeeds)
        if (seed != targetSeed) seed & u32Mask,
    ];
  }
  final window = request.nearbyDelayWindow;
  final targetSeedTime = request.targetSeedTime;
  if (targetSeedTime != null) {
    return _fallbackSeedsBySeedTime(request, targetSeedTime, targetSeed);
  }
  if (window <= 0) {
    return const [];
  }
  final hour = targetSeed & 0xff0000;
  final delay = targetSeed & 0xffff;
  final seeds = <int>[];
  for (var offset = 1; offset <= window; offset += 1) {
    final lower = delay - offset;
    final upper = delay + offset;
    if (lower >= 0) {
      seeds.add(hour | lower);
    }
    if (upper <= 0xffff) {
      seeds.add(hour | upper);
    }
  }
  return seeds;
}

List<int> _fallbackSeedsBySeedTime(
  Gen4HitReverseRequest request,
  Gen4SeedTime targetSeedTime,
  int targetSeed,
) {
  final delayWindow = request.nearbyDelayWindow;
  final secondWindow = request.nearbySecondWindow;
  if (delayWindow < 0 || secondWindow < 0) {
    return const [];
  }
  final offsets = <_SeedTimeOffset>[];
  for (
    var secondOffset = -secondWindow;
    secondOffset <= secondWindow;
    secondOffset += 1
  ) {
    for (
      var delayOffset = -delayWindow;
      delayOffset <= delayWindow;
      delayOffset += 1
    ) {
      if (secondOffset == 0 && delayOffset == 0) {
        continue;
      }
      offsets.add(
        _SeedTimeOffset(secondOffset: secondOffset, delayOffset: delayOffset),
      );
    }
  }
  offsets.sort((left, right) {
    final distanceCompare = left.distance.compareTo(right.distance);
    if (distanceCompare != 0) {
      return distanceCompare;
    }
    final secondCompare = left.secondOffset.abs().compareTo(
      right.secondOffset.abs(),
    );
    if (secondCompare != 0) {
      return secondCompare;
    }
    return left.delayOffset.abs().compareTo(right.delayOffset.abs());
  });

  final seeds = <int>[];
  final seen = <int>{targetSeed};
  for (final offset in offsets) {
    final delay = targetSeedTime.delay + offset.delayOffset;
    if (delay < 0 || delay > u32Mask) {
      continue;
    }
    final dateTime = targetSeedTime.dateTime.add(
      Duration(seconds: offset.secondOffset),
    );
    if (dateTime.year < 2000 || dateTime.year > 2099) {
      continue;
    }
    final seed = Gen4SeedTime.calcSeed(dateTime: dateTime, delay: delay);
    if (seen.add(seed)) {
      seeds.add(seed);
    }
  }
  return seeds;
}

class _SeedTimeOffset {
  const _SeedTimeOffset({
    required this.secondOffset,
    required this.delayOffset,
  });

  final int secondOffset;
  final int delayOffset;

  int get distance => secondOffset.abs() + delayOffset.abs();
}

List<Gen4HitReverseResult> _sortedLimited(
  List<Gen4HitReverseResult> results,
  int maxResults,
) {
  results.sort((left, right) {
    final advanceCompare = left.advance.compareTo(right.advance);
    if (advanceCompare != 0) {
      return advanceCompare;
    }
    return left.seed.compareTo(right.seed);
  });
  return List.unmodifiable(results.take(maxResults));
}

List<Gen4HitReverseResult> _searchWild(
  Gen4HitReverseRequest request,
  Gen4SearchResultSource source,
  int seed,
) {
  final area = _wildCoreArea(request, source);
  if (area == null) {
    return const [];
  }
  final method = Gen4WildMethod.values.byName(source.method);
  final lead = source.lead == null
      ? Gen4WildLead.none
      : Gen4WildLead.values.byName(source.lead!);
  final generator = Gen4WildGenerator(
    initialAdvances: request.minAdvance,
    maxAdvances: request.maxAdvance - request.minAdvance,
    offset: 0,
    method: method,
    game: Gen4WildGame.values.byName(
      source.wildGame ?? Gen4WildGame.diamondPearl.name,
    ),
    area: area,
    tid: request.tid,
    sid: request.sid,
    lead: lead,
    synchronizeNature: lead.isSynchronize
        ? Nature.values[source.synchronizeNatureId ?? Nature.hardy.index]
        : null,
    encounterSlot: request.target.encounterSlot ?? 0,
    feebasTile: source.feebasTile,
    unownRadio: source.unownRadio,
  );
  return [
    for (final state in generator.generate(seed))
      if (_matchesWildState(request, state)) _wildResult(request, seed, state),
  ];
}

List<Gen4HitReverseResult> _searchStatic(
  Gen4HitReverseRequest request,
  Gen4SearchResultSource source,
  int seed,
) {
  if (request.speciesId != source.speciesId ||
      !_staticLevelMatches(request, source)) {
    return const [];
  }
  final generator = Gen4StaticGenerator(
    initialAdvances: request.minAdvance,
    maxAdvances: request.maxAdvance - request.minAdvance,
    offset: 0,
    method: Gen4StaticMethod.values.byName(source.method),
    level: source.minLevel,
    tid: request.tid,
    sid: request.sid,
    genderRatio: source.genderRatio,
    fixedGender: PokemonGenderRatio.isFixed(source.genderRatio),
    synchronizeNature: _staticSynchronizeNature(source),
    cuteCharmLead: _staticCuteCharmLead(source),
    shinyPolicy: source.staticShinyPolicy == null
        ? Gen4StaticShinyPolicy.random
        : Gen4StaticShinyPolicy.values.byName(source.staticShinyPolicy!),
  );
  return [
    for (final state in generator.generate(seed))
      if (_matchesStaticState(request, state))
        _staticResult(request, seed, state),
  ];
}

Gen4WildArea? _wildCoreArea(
  Gen4HitReverseRequest request,
  Gen4SearchResultSource source,
) {
  final game = gen4GameVersionFromJson(source.game);
  final locationId = source.locationId;
  final encounter = source.wildEncounter;
  if (locationId == null || encounter == null) {
    return null;
  }
  final areas = request.wildRepository.areasForLocation(
    game: game,
    locationId: locationId,
  );
  for (final area in areas) {
    if (area.encounter.jsonName != encounter) {
      continue;
    }
    if (area.time?.jsonName != source.wildTime) {
      continue;
    }
    return area.toCoreArea(
      request.personal,
      modifiers: source.wildModifiers.isEmpty
          ? [?source.wildModifier]
          : source.wildModifiers,
    );
  }
  return null;
}

bool _matchesWildState(Gen4HitReverseRequest request, Gen4WildState state) {
  return state.species == request.speciesId &&
      state.level == request.level &&
      state.nature == request.nature &&
      (request.abilitySlot == null ||
          state.abilitySlot == request.abilitySlot) &&
      (request.gender == null || state.gender == request.gender) &&
      (request.characteristic == null ||
          state.characteristic == request.characteristic) &&
      _sameStats(request.observedStats, _displayStats(request, state.ivs));
}

bool _matchesStaticState(Gen4HitReverseRequest request, Gen4StaticState state) {
  return state.nature == request.nature &&
      (request.abilitySlot == null ||
          state.abilitySlot == request.abilitySlot) &&
      (request.gender == null || state.gender == request.gender) &&
      (request.characteristic == null ||
          state.characteristic == request.characteristic) &&
      _sameStats(request.observedStats, _displayStats(request, state.ivs));
}

Nature? _staticSynchronizeNature(Gen4SearchResultSource source) {
  if (source.method == Gen4StaticMethod.method1.name ||
      source.lead != Gen4WildLead.synchronize.name) {
    return null;
  }
  final natureId = source.synchronizeNatureId;
  if (natureId == null || natureId < 0 || natureId >= Nature.values.length) {
    return null;
  }
  return Nature.values[natureId];
}

Gen4CuteCharmLead _staticCuteCharmLead(Gen4SearchResultSource source) {
  if (source.method == Gen4StaticMethod.method1.name ||
      PokemonGenderRatio.isFixed(source.genderRatio)) {
    return Gen4CuteCharmLead.none;
  }
  return switch (source.lead) {
    'cuteCharmMale' => Gen4CuteCharmLead.male,
    'cuteCharmFemale' => Gen4CuteCharmLead.female,
    _ => Gen4CuteCharmLead.none,
  };
}

PokemonStats _displayStats(Gen4HitReverseRequest request, Ivs ivs) {
  final info = request.personal.requireSpecies(request.speciesId);
  return Gen4StatCalculator.calculateDisplayStats(
    baseStats: info.baseStats,
    ivs: ivs,
    nature: request.nature,
    level: request.level,
  );
}

bool _sameStats(PokemonStats left, PokemonStats right) {
  final leftValues = left.ordered;
  final rightValues = right.ordered;
  for (var index = 0; index < leftValues.length; index += 1) {
    if (leftValues[index] != rightValues[index]) {
      return false;
    }
  }
  return true;
}

Gen4HitReverseResult _wildResult(
  Gen4HitReverseRequest request,
  int seed,
  Gen4WildState state,
) {
  return Gen4HitReverseResult(
    seed: seed,
    delay: _seedDelay(request, seed),
    advance: state.advance,
    speciesId: state.species,
    level: state.level,
    nature: state.nature,
    pid: state.pid.hex,
    ivs: state.ivs,
    stats: _displayStats(request, state.ivs),
    abilitySlot: state.abilitySlot,
    gender: state.gender,
    hiddenPowerType: state.hiddenPowerType,
    hiddenPowerStrength: state.hiddenPowerStrength,
    encounterSlot: state.encounterSlot,
  );
}

Gen4HitReverseResult _staticResult(
  Gen4HitReverseRequest request,
  int seed,
  Gen4StaticState state,
) {
  return Gen4HitReverseResult(
    seed: seed,
    delay: _seedDelay(request, seed),
    advance: state.advance,
    speciesId: request.speciesId,
    level: _staticResultLevel(request, state),
    nature: state.nature,
    pid: state.pid.hex,
    ivs: state.ivs,
    stats: _displayStats(request, state.ivs),
    abilitySlot: state.abilitySlot,
    gender: state.gender,
    hiddenPowerType: state.hiddenPowerType,
    hiddenPowerStrength: state.hiddenPowerStrength,
  );
}

int _seedDelay(Gen4HitReverseRequest request, int seed) {
  return Gen4SeedTime.seedInfo(seed: seed, year: request.target.year).delay;
}

bool _staticLevelMatches(
  Gen4HitReverseRequest request,
  Gen4SearchResultSource source,
) {
  if (source.staticType == 'starter') {
    return source.minLevel == 5 && (request.level == 5 || request.level == 6);
  }
  return request.level == source.minLevel;
}

int _staticResultLevel(Gen4HitReverseRequest request, Gen4StaticState state) {
  if (request.target.source?.staticType == 'starter' &&
      (request.level == 5 || request.level == 6)) {
    return request.level;
  }
  return state.level;
}

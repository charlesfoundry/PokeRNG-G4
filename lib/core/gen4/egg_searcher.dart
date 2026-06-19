import 'egg_generator.dart';
import 'pokemon_attributes.dart';
import 'search_result_utils.dart';
import 'seed_time.dart';
import 'stat_calculator.dart';

class Gen4EggSearcher {
  const Gen4EggSearcher({
    required this.minDelay,
    required this.maxDelay,
    required this.generator,
    this.maxResults,
    this.maxSearchSeeds = 2000000,
  });

  final int minDelay;
  final int maxDelay;
  final Gen4EggGenerator generator;
  final int? maxResults;
  final int maxSearchSeeds;

  List<Gen4EggHeldSearchResult> searchHeld({
    int? pid,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
  }) {
    _validate();
    _validateHeldFilters(pid: pid, abilitySlot: abilitySlot);

    final results = <Gen4EggHeldSearchResult>[];
    for (var ab = 0; ab <= 0xff; ab++) {
      for (var hour = 0; hour < 24; hour++) {
        for (var delay = minDelay; delay <= maxDelay; delay++) {
          final seed = (ab << 24) | (hour << 16) | delay;
          final states = generator.generateHeld(seed);
          for (final state in states) {
            if (_matchesHeld(
              state,
              pid: pid,
              nature: nature,
              abilitySlot: abilitySlot,
              gender: gender,
              shiny: shiny,
            )) {
              results.add(
                Gen4EggHeldSearchResult(
                  seed: seed,
                  hour: hour,
                  delay: delay,
                  state: state,
                ),
              );
              if (maxResults != null && results.length >= maxResults!) {
                return results;
              }
            }
          }
        }
      }
    }
    return results;
  }

  List<Gen4EggSearchResult> searchPickup({
    required List<Gen4EggHeldState> heldStates,
    Ivs? ivs,
    int? pid,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
  }) {
    _validate();
    _validateHeldFilters(pid: pid, abilitySlot: abilitySlot);
    _validatePickupFilters(heldStates: heldStates, ivs: ivs);
    final filter = _createPokemonFilter(
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
    );

    final results = <Gen4EggSearchResult>[];
    for (var ab = 0; ab <= 0xff; ab++) {
      for (var hour = 0; hour < 24; hour++) {
        for (var delay = minDelay; delay <= maxDelay; delay++) {
          final seed = (ab << 24) | (hour << 16) | delay;
          final states = generator.generatePickup(seed, heldStates);
          for (final state in states) {
            if (_matchesPickup(
              state,
              ivs: ivs,
              pid: pid,
              nature: nature,
              filter: filter,
            )) {
              results.add(
                Gen4EggSearchResult(
                  seed: seed,
                  hour: hour,
                  delay: delay,
                  state: state,
                ),
              );
              if (maxResults != null && results.length >= maxResults!) {
                return results;
              }
            }
          }
        }
      }
    }
    return results;
  }

  List<Gen4EggSearchResult> searchPickupStats({
    required List<Gen4EggHeldState> heldStates,
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    int? pid,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int maxIvCombinations = 100000,
  }) {
    return searchPickupStatsDetailed(
      heldStates: heldStates,
      baseStats: baseStats,
      observedStats: observedStats,
      pid: pid,
      nature: nature,
      level: level,
      effortValues: effortValues,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      maxIvCombinations: maxIvCombinations,
    ).results;
  }

  Gen4StatsSearchResult<Gen4EggSearchResult> searchPickupStatsDetailed({
    required List<Gen4EggHeldState> heldStates,
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    int? pid,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int maxIvCombinations = 100000,
  }) {
    final ivRangeResult = _ivRangeResultForObservedStats(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
    );
    return Gen4StatsSearchResult(
      ivRangeResult: ivRangeResult,
      maxIvCombinations: maxIvCombinations,
      maxResults: maxResults,
      results: searchPickupRanges(
        heldStates: heldStates,
        ranges: ivRangeResult.ranges,
        pid: pid,
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        maxIvCombinations: maxIvCombinations,
      ),
    );
  }

  List<Gen4EggSearchResult> searchPickupRanges({
    required List<Gen4EggHeldState> heldStates,
    required Gen4IvRanges ranges,
    int? pid,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int maxIvCombinations = 100000,
  }) {
    _validate();
    _validateRangeSearch(maxIvCombinations);
    _validateIvRanges(ranges);
    _validateHeldFilters(pid: pid, abilitySlot: abilitySlot);
    _validatePickupFilters(heldStates: heldStates);
    _createPokemonFilter(
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
    );

    final results = <Gen4EggSearchResult>[];
    for (final ivs in ranges.enumerate(maxCombinations: maxIvCombinations)) {
      results.addAll(
        searchPickup(
          heldStates: heldStates,
          ivs: ivs,
          pid: pid,
          nature: nature,
          abilitySlot: abilitySlot,
          gender: gender,
          shiny: shiny,
          hiddenPowerType: hiddenPowerType,
          minHiddenPowerStrength: minHiddenPowerStrength,
          maxHiddenPowerStrength: maxHiddenPowerStrength,
        ),
      );
      if (maxResults != null && results.length >= maxResults!) {
        return _dedupedLimitedSearchResults(results);
      }
    }
    return _dedupedLimitedSearchResults(results);
  }

  List<Gen4EggSearchResult> searchStats({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    int? pid,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int maxIvCombinations = 100000,
  }) {
    return searchStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      pid: pid,
      nature: nature,
      level: level,
      effortValues: effortValues,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      maxIvCombinations: maxIvCombinations,
    ).results;
  }

  Gen4StatsSearchResult<Gen4EggSearchResult> searchStatsDetailed({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    int? pid,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int maxIvCombinations = 100000,
  }) {
    final ivRangeResult = _ivRangeResultForObservedStats(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
    );
    return Gen4StatsSearchResult(
      ivRangeResult: ivRangeResult,
      maxIvCombinations: maxIvCombinations,
      maxResults: maxResults,
      results: searchRanges(
        ranges: ivRangeResult.ranges,
        pid: pid,
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        maxIvCombinations: maxIvCombinations,
      ),
    );
  }

  List<Gen4EggSearchResult> search({
    Ivs? ivs,
    int? pid,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
  }) {
    _validate();
    _validateHeldFilters(pid: pid, abilitySlot: abilitySlot);
    _validatePickupFilters(ivs: ivs);
    final filter = _createPokemonFilter(
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
    );

    final results = <Gen4EggSearchResult>[];
    for (var ab = 0; ab <= 0xff; ab++) {
      for (var hour = 0; hour < 24; hour++) {
        for (var delay = minDelay; delay <= maxDelay; delay++) {
          final seed = (ab << 24) | (hour << 16) | delay;
          final states = generator.generate(heldSeed: seed, pickupSeed: seed);
          for (final state in states) {
            if (_matches(
              state,
              ivs: ivs,
              pid: pid,
              nature: nature,
              filter: filter,
            )) {
              results.add(
                Gen4EggSearchResult(
                  seed: seed,
                  hour: hour,
                  delay: delay,
                  state: state,
                ),
              );
              if (maxResults != null && results.length >= maxResults!) {
                return results;
              }
            }
          }
        }
      }
    }
    return results;
  }

  List<Gen4EggSearchResult> searchRanges({
    required Gen4IvRanges ranges,
    int? pid,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int maxIvCombinations = 100000,
  }) {
    _validate();
    _validateRangeSearch(maxIvCombinations);
    _validateIvRanges(ranges);
    _validateHeldFilters(pid: pid, abilitySlot: abilitySlot);
    _validatePickupFilters();
    _createPokemonFilter(
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
    );

    final results = <Gen4EggSearchResult>[];
    for (final ivs in ranges.enumerate(maxCombinations: maxIvCombinations)) {
      results.addAll(
        search(
          ivs: ivs,
          pid: pid,
          nature: nature,
          abilitySlot: abilitySlot,
          gender: gender,
          shiny: shiny,
          hiddenPowerType: hiddenPowerType,
          minHiddenPowerStrength: minHiddenPowerStrength,
          maxHiddenPowerStrength: maxHiddenPowerStrength,
        ),
      );
      if (maxResults != null && results.length >= maxResults!) {
        return _dedupedLimitedSearchResults(results);
      }
    }
    return _dedupedLimitedSearchResults(results);
  }

  bool _matchesHeld(
    Gen4EggHeldState state, {
    required int? pid,
    required Nature? nature,
    required int? abilitySlot,
    required PokemonGender? gender,
    required Shiny? shiny,
  }) {
    if (pid != null && state.pid.value != pid) {
      return false;
    }
    if (nature != null && state.nature != nature) {
      return false;
    }
    if (abilitySlot != null && state.abilitySlot != abilitySlot) {
      return false;
    }
    if (gender != null && state.gender != gender) {
      return false;
    }
    if (shiny != null && state.shiny != shiny) {
      return false;
    }
    return true;
  }

  bool _matchesPickup(
    Gen4EggState state, {
    required Ivs? ivs,
    required int? pid,
    required Nature? nature,
    required Gen4PokemonSearchFilter filter,
  }) {
    if (ivs != null && !_sameIvs(state.ivs, ivs)) {
      return false;
    }
    if (pid != null && state.pid.value != pid) {
      return false;
    }
    if (nature != null && state.nature != nature) {
      return false;
    }
    if (!filter.matches(
      abilitySlot: state.abilitySlot,
      gender: state.gender,
      shiny: state.shiny,
      hiddenPowerType: state.hiddenPowerType,
      hiddenPowerStrength: state.hiddenPowerStrength,
    )) {
      return false;
    }
    return true;
  }

  void _validate() {
    if (minDelay > maxDelay) {
      throw ArgumentError('minDelay must be <= maxDelay');
    }
    if (minDelay < 0 || maxDelay > 0xffff) {
      throw ArgumentError('delay values must be in 0..65535');
    }
    Gen4SearchResultUtils.validateMaxResults(maxResults);
    if (maxSearchSeeds <= 0) {
      throw ArgumentError.value(
        maxSearchSeeds,
        'maxSearchSeeds',
        'must be positive',
      );
    }
    generator.validateConfiguration();
    _validateSearchSize();
  }

  void _validateSearchSize() {
    final delayCount = maxDelay - minDelay + 1;
    final seedCount = 256 * 24 * delayCount;
    if (seedCount > maxSearchSeeds) {
      throw StateError(
        'egg search would scan $seedCount seeds; '
        'increase maxSearchSeeds to allow this range',
      );
    }
  }

  void _validateRangeSearch(int maxIvCombinations) {
    if (maxIvCombinations <= 0) {
      throw ArgumentError.value(
        maxIvCombinations,
        'maxIvCombinations',
        'must be positive',
      );
    }
  }

  void _validateIvRanges(Gen4IvRanges ranges) {
    Gen4StatCalculator.validateIvRanges(ranges);
  }

  void _validateHeldFilters({required int? pid, required int? abilitySlot}) {
    if (pid != null && (pid < 0 || pid > 0xffffffff)) {
      throw ArgumentError.value(pid, 'pid', 'must be in 0..0xffffffff');
    }
    PokemonAbilitySlot.validateOptional(abilitySlot);
  }

  void _validatePickupFilters({List<Gen4EggHeldState>? heldStates, Ivs? ivs}) {
    if (heldStates != null && heldStates.isEmpty) {
      throw ArgumentError.value(heldStates, 'heldStates', 'must not be empty');
    }
    if (ivs != null) {
      Gen4StatCalculator.validateIvs(ivs);
    }
  }

  Gen4PokemonSearchFilter _createPokemonFilter({
    required int? abilitySlot,
    required PokemonGender? gender,
    required Shiny? shiny,
    required int? hiddenPowerType,
    required int? minHiddenPowerStrength,
    required int? maxHiddenPowerStrength,
  }) {
    final filter = Gen4PokemonSearchFilter(
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPower: Gen4HiddenPowerFilter(
        type: hiddenPowerType,
        minStrength: minHiddenPowerStrength,
        maxStrength: maxHiddenPowerStrength,
      ),
    );
    filter.validate();
    return filter;
  }

  Gen4StatIvRangeResult _ivRangeResultForObservedStats({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    required PokemonEffortValues effortValues,
  }) {
    return Gen4StatCalculator.ivRangeResultForStats(
      baseStats: baseStats,
      stats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
    );
  }

  bool _matches(
    Gen4EggState state, {
    required Ivs? ivs,
    required int? pid,
    required Nature? nature,
    required Gen4PokemonSearchFilter filter,
  }) {
    if (ivs != null && !_sameIvs(state.ivs, ivs)) {
      return false;
    }
    if (pid != null && state.pid.value != pid) {
      return false;
    }
    if (nature != null && state.nature != nature) {
      return false;
    }
    if (!filter.matches(
      abilitySlot: state.abilitySlot,
      gender: state.gender,
      shiny: state.shiny,
      hiddenPowerType: state.hiddenPowerType,
      hiddenPowerStrength: state.hiddenPowerStrength,
    )) {
      return false;
    }
    return true;
  }

  List<Gen4EggSearchResult> _dedupedLimitedSearchResults(
    List<Gen4EggSearchResult> results,
  ) {
    return Gen4SearchResultUtils.dedupedLimited(
      results,
      dedupeKey: (result) {
        final state = result.state;
        return (
          result.seed,
          state.advance,
          state.pickupAdvance,
          state.pid.value,
        );
      },
      maxResults: maxResults,
    );
  }

  bool _sameIvs(Ivs left, Ivs right) {
    return left.hp == right.hp &&
        left.attack == right.attack &&
        left.defense == right.defense &&
        left.specialAttack == right.specialAttack &&
        left.specialDefense == right.specialDefense &&
        left.speed == right.speed;
  }
}

class Gen4EggHeldSearchResult {
  const Gen4EggHeldSearchResult({
    required this.seed,
    required this.hour,
    required this.delay,
    required this.state,
  });

  final int seed;
  final int hour;
  final int delay;
  final Gen4EggHeldState state;

  int get initialSeed => seed;
  String get seedHex => Gen4SearchResultUtils.seedHex(seed);
  int get advance => state.advance;
  int get frame => advance;

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

class Gen4EggSearchResult {
  const Gen4EggSearchResult({
    required this.seed,
    required this.hour,
    required this.delay,
    required this.state,
  });

  final int seed;
  final int hour;
  final int delay;
  final Gen4EggState state;

  int get initialSeed => seed;
  String get seedHex => Gen4SearchResultUtils.seedHex(seed);
  int get advance => state.advance;
  int get frame => advance;
  int get pickupFrame => state.pickupAdvance;

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

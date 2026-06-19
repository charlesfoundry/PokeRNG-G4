import 'event_generator.dart';
import 'lcrng.dart';
import 'lcrng_reverse.dart';
import 'pokemon_attributes.dart';
import 'search_result_utils.dart';
import 'seed_time.dart';
import 'stat_calculator.dart';

class Gen4EventSearcher {
  const Gen4EventSearcher({
    required this.minAdvance,
    required this.maxAdvance,
    required this.minDelay,
    required this.maxDelay,
    required this.level,
    required this.nature,
    required this.genderRatio,
    this.maxResults,
    this.allowedHours = const {},
    this.maxSearchAdvances = 2000000,
  });

  final int minAdvance;
  final int maxAdvance;
  final int minDelay;
  final int maxDelay;
  final int level;
  final Nature nature;
  final int genderRatio;
  final int? maxResults;
  final Set<int> allowedHours;
  final int maxSearchAdvances;

  List<Gen4EventSearchResult> searchStats({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
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

  Gen4StatsSearchResult<Gen4EventSearchResult> searchStatsDetailed({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int maxIvCombinations = 100000,
  }) {
    final ivRangeResult = Gen4StatCalculator.ivRangeResultForStats(
      baseStats: baseStats,
      stats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
    );
    return Gen4StatsSearchResult(
      ivRangeResult: ivRangeResult,
      maxIvCombinations: maxIvCombinations,
      maxResults: maxResults,
      results: searchRanges(
        ivRangeResult.ranges,
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

  List<Gen4EventSearchResult> searchRanges(
    Gen4IvRanges ranges, {
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int maxIvCombinations = 100000,
  }) {
    _validateRangeSearch(ranges, maxIvCombinations);
    _createFilter(
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
    );
    final results = <Gen4EventSearchResult>[];
    for (final ivs in ranges.enumerate(maxCombinations: maxIvCombinations)) {
      results.addAll(
        search(
          ivs,
          abilitySlot: abilitySlot,
          gender: gender,
          shiny: shiny,
          hiddenPowerType: hiddenPowerType,
          minHiddenPowerStrength: minHiddenPowerStrength,
          maxHiddenPowerStrength: maxHiddenPowerStrength,
        ),
      );
    }
    return _sortedLimitedResults(results);
  }

  List<Gen4EventSearchResult> search(
    Ivs ivs, {
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
  }) {
    _validateRange();
    Gen4StatCalculator.validateIvs(ivs);
    final filters = _createFilter(
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
    );

    final candidates = <int>{};
    final ivSeeds = LcrngReverse.recoverPokeRngIvs(
      hp: ivs.hp,
      attack: ivs.attack,
      defense: ivs.defense,
      specialAttack: ivs.specialAttack,
      specialDefense: ivs.specialDefense,
      speed: ivs.speed,
    );

    for (final ivSeed in ivSeeds) {
      final encounterSeed = Lcrng.pokeRngReverse(ivSeed).next().value;
      candidates
        ..add(encounterSeed)
        ..add(encounterSeed ^ 0x80000000);
    }

    return _searchInitialSeeds(
      ivs: ivs,
      candidates: candidates,
      filters: filters,
    );
  }

  void _validateRange() {
    if (minAdvance > maxAdvance) {
      throw ArgumentError('minAdvance must be <= maxAdvance');
    }
    if (minDelay > maxDelay) {
      throw ArgumentError('minDelay must be <= maxDelay');
    }
    if (minAdvance < 0) {
      throw ArgumentError('minAdvance must be non-negative');
    }
    if (minDelay < 0 || maxDelay > 0xffff) {
      throw ArgumentError('delay range must be within 0..65535');
    }
    if (level < 1 || level > 100) {
      throw ArgumentError.value(level, 'level', 'must be in 1..100');
    }
    if (genderRatio < 0 || genderRatio > 255) {
      throw ArgumentError.value(
        genderRatio,
        'genderRatio',
        'must be in 0..255',
      );
    }
    Gen4SearchResultUtils.validateAllowedHours(allowedHours);
    if (maxSearchAdvances <= 0) {
      throw ArgumentError.value(
        maxSearchAdvances,
        'maxSearchAdvances',
        'must be positive',
      );
    }
    Gen4SearchResultUtils.validateMaxResults(maxResults);
    _validateSearchSize();
  }

  void _validateSearchSize() {
    final advanceCount = maxAdvance - minAdvance + 1;
    if (advanceCount > maxSearchAdvances) {
      throw StateError(
        'event search would scan $advanceCount advances per candidate; '
        'increase maxSearchAdvances to allow this range',
      );
    }
  }

  void _validateRangeSearch(Gen4IvRanges ranges, int maxIvCombinations) {
    _validateRange();
    if (maxIvCombinations <= 0) {
      throw ArgumentError.value(
        maxIvCombinations,
        'maxIvCombinations',
        'must be positive',
      );
    }
    Gen4StatCalculator.validateIvRanges(ranges);
  }

  Gen4PokemonSearchFilter _createFilter({
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

  List<Gen4EventSearchResult> _searchInitialSeeds({
    required Ivs ivs,
    required Set<int> candidates,
    required Gen4PokemonSearchFilter filters,
  }) {
    final results = <Gen4EventSearchResult>[];
    for (final candidate in candidates) {
      var initialSeed = Lcrng.pokeRngReverse(
        candidate,
      ).advance(minAdvance).seed;

      for (var advance = minAdvance; advance <= maxAdvance; advance++) {
        final hour = (initialSeed >>> 16) & 0xff;
        final delay = initialSeed & 0xffff;
        if (_isAllowedHour(hour) && delay >= minDelay && delay <= maxDelay) {
          final generator = Gen4EventGenerator(
            initialAdvances: advance,
            maxAdvances: 0,
            offset: 0,
            level: level,
            nature: nature,
            genderRatio: genderRatio,
          );
          final state = generator.generate(initialSeed).single;
          if (_sameIvs(state.ivs, ivs) && _matchesFilters(state, filters)) {
            results.add(
              Gen4EventSearchResult(
                initialSeed: initialSeed,
                delay: delay,
                advance: advance,
                state: state,
              ),
            );
          }
        }

        initialSeed = Lcrng.pokeRngReverse(initialSeed).next().value;
      }
    }

    return _sortedLimitedResults(results);
  }

  bool _isAllowedHour(int hour) {
    return hour < 24 &&
        Gen4SearchResultUtils.effectiveAllowedHours(
          allowedHours,
        ).contains(hour);
  }

  bool _matchesFilters(Gen4EventState state, Gen4PokemonSearchFilter filters) {
    return filters.matches(
      abilitySlot: state.abilitySlot,
      gender: state.gender,
      shiny: state.shiny,
      hiddenPowerType: state.hiddenPowerType,
      hiddenPowerStrength: state.hiddenPowerStrength,
    );
  }

  List<Gen4EventSearchResult> _sortedLimitedResults(
    List<Gen4EventSearchResult> results,
  ) {
    return Gen4SearchResultUtils.sortedDedupedLimited(
      results,
      compare: (left, right) {
        final advanceCompare = left.advance.compareTo(right.advance);
        if (advanceCompare != 0) {
          return advanceCompare;
        }
        return left.initialSeed.compareTo(right.initialSeed);
      },
      dedupeKey: (result) => (result.initialSeed, result.advance),
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

class Gen4EventSearchResult {
  const Gen4EventSearchResult({
    required this.initialSeed,
    required this.delay,
    required this.advance,
    required this.state,
  });

  final int initialSeed;
  final int delay;
  final int advance;
  final Gen4EventState state;

  int get seed => initialSeed;
  String get seedHex => Gen4SearchResultUtils.seedHex(initialSeed);
  int get hour => Gen4SearchResultUtils.seedHour(initialSeed);
  int get frame => advance;

  Gen4SeedTimeInfo seedInfo({required int year}) {
    return Gen4SeedTime.seedInfo(seed: initialSeed, year: year);
  }

  List<Gen4SeedTime> seedTimes({
    required int year,
    bool forceSecond = false,
    int forcedSecond = 0,
  }) {
    return Gen4SeedTime.calculateTimes(
      seed: initialSeed,
      year: year,
      forceSecond: forceSecond,
      forcedSecond: forcedSecond,
    );
  }
}

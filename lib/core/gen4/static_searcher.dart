import 'lcrng.dart';
import 'lcrng_reverse.dart';
import 'pokemon_attributes.dart';
import 'search_result_utils.dart';
import 'seed_time.dart';
import 'stat_calculator.dart';
import 'static_generator.dart';

class Gen4StaticSearcher {
  const Gen4StaticSearcher({
    required this.minAdvance,
    required this.maxAdvance,
    required this.minDelay,
    required this.maxDelay,
    required this.level,
    required this.tid,
    required this.sid,
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
  final int tid;
  final int sid;
  final int genderRatio;
  final int? maxResults;
  final Set<int> allowedHours;
  final int maxSearchAdvances;

  List<Gen4StaticSearchResult> searchMethod1Stats({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int maxIvCombinations = 100000,
  }) {
    return searchMethod1StatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
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

  Gen4StatsSearchResult<Gen4StaticSearchResult> searchMethod1StatsDetailed({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
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
      effortValues: effortValues,
    );
    return Gen4StatsSearchResult(
      ivRangeResult: ivRangeResult,
      maxIvCombinations: maxIvCombinations,
      maxResults: maxResults,
      results: searchMethod1Ranges(
        ivRangeResult.ranges,
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

  List<Gen4StaticSearchResult> searchMethod1Ranges(
    Gen4IvRanges ranges, {
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int maxIvCombinations = 100000,
  }) {
    _validateRangeSearch(ranges, maxIvCombinations);
    _createPokemonFilter(
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
    );
    final results = <Gen4StaticSearchResult>[];
    for (final ivs in ranges.enumerate(maxCombinations: maxIvCombinations)) {
      results.addAll(
        searchMethod1(
          ivs,
          nature: nature,
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

  List<Gen4StaticSearchResult> searchMethod1(
    Ivs ivs, {
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
  }) {
    _validateRange();
    Gen4StatCalculator.validateIvs(ivs);
    final filters = _createStaticFilter(
      nature: nature,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
    );

    final candidates = <_StaticSearchCandidate>[];
    final ivSeeds = LcrngReverse.recoverPokeRngIvs(
      hp: ivs.hp,
      attack: ivs.attack,
      defense: ivs.defense,
      specialAttack: ivs.specialAttack,
      specialDefense: ivs.specialDefense,
      speed: ivs.speed,
    );

    for (final ivSeed in ivSeeds) {
      var reverse = Lcrng.pokeRngReverse(ivSeed);
      final high = reverse.nextU16();
      reverse = Lcrng.pokeRngReverse(high.seed);
      final low = reverse.nextU16();
      reverse = Lcrng.pokeRngReverse(low.seed);

      final pid = (high.value << 16) | low.value;
      final encounterSeed = reverse.next().value;
      candidates.add(_StaticSearchCandidate(seed: encounterSeed, pid: pid));
    }

    return _searchInitialSeeds(
      ivs: ivs,
      method: Gen4StaticMethod.method1,
      candidates: candidates,
      filters: filters,
    );
  }

  List<Gen4StaticSearchResult> searchMethodJStats({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Nature? synchronizeNature,
    Gen4CuteCharmLead cuteCharmLead = Gen4CuteCharmLead.none,
    bool fixedGender = false,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int maxIvCombinations = 100000,
  }) {
    return searchMethodJStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      effortValues: effortValues,
      synchronizeNature: synchronizeNature,
      cuteCharmLead: cuteCharmLead,
      fixedGender: fixedGender,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      maxIvCombinations: maxIvCombinations,
    ).results;
  }

  Gen4StatsSearchResult<Gen4StaticSearchResult> searchMethodJStatsDetailed({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Nature? synchronizeNature,
    Gen4CuteCharmLead cuteCharmLead = Gen4CuteCharmLead.none,
    bool fixedGender = false,
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
      effortValues: effortValues,
    );
    return Gen4StatsSearchResult(
      ivRangeResult: ivRangeResult,
      maxIvCombinations: maxIvCombinations,
      maxResults: maxResults,
      results: searchMethodJRanges(
        ivRangeResult.ranges,
        synchronizeNature: synchronizeNature,
        cuteCharmLead: cuteCharmLead,
        fixedGender: fixedGender,
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

  List<Gen4StaticSearchResult> searchMethodJ(
    Ivs ivs, {
    Nature? synchronizeNature,
    Gen4CuteCharmLead cuteCharmLead = Gen4CuteCharmLead.none,
    bool fixedGender = false,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
  }) {
    return _searchMethodJk(
      ivs,
      method: Gen4StaticMethod.methodJ,
      synchronizeNature: synchronizeNature,
      cuteCharmLead: cuteCharmLead,
      fixedGender: fixedGender,
      filters: _createStaticFilter(
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
      ),
    );
  }

  List<Gen4StaticSearchResult> searchMethodJRanges(
    Gen4IvRanges ranges, {
    Nature? synchronizeNature,
    Gen4CuteCharmLead cuteCharmLead = Gen4CuteCharmLead.none,
    bool fixedGender = false,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int maxIvCombinations = 100000,
  }) {
    _validateRangeSearch(ranges, maxIvCombinations);
    _createPokemonFilter(
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
    );
    final results = <Gen4StaticSearchResult>[];
    for (final ivs in ranges.enumerate(maxCombinations: maxIvCombinations)) {
      results.addAll(
        searchMethodJ(
          ivs,
          synchronizeNature: synchronizeNature,
          cuteCharmLead: cuteCharmLead,
          fixedGender: fixedGender,
          nature: nature,
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

  List<Gen4StaticSearchResult> searchMethodKStats({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Nature? synchronizeNature,
    Gen4CuteCharmLead cuteCharmLead = Gen4CuteCharmLead.none,
    bool fixedGender = false,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int maxIvCombinations = 100000,
  }) {
    return searchMethodKStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      effortValues: effortValues,
      synchronizeNature: synchronizeNature,
      cuteCharmLead: cuteCharmLead,
      fixedGender: fixedGender,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      maxIvCombinations: maxIvCombinations,
    ).results;
  }

  Gen4StatsSearchResult<Gen4StaticSearchResult> searchMethodKStatsDetailed({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Nature? synchronizeNature,
    Gen4CuteCharmLead cuteCharmLead = Gen4CuteCharmLead.none,
    bool fixedGender = false,
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
      effortValues: effortValues,
    );
    return Gen4StatsSearchResult(
      ivRangeResult: ivRangeResult,
      maxIvCombinations: maxIvCombinations,
      maxResults: maxResults,
      results: searchMethodKRanges(
        ivRangeResult.ranges,
        synchronizeNature: synchronizeNature,
        cuteCharmLead: cuteCharmLead,
        fixedGender: fixedGender,
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

  List<Gen4StaticSearchResult> searchMethodK(
    Ivs ivs, {
    Nature? synchronizeNature,
    Gen4CuteCharmLead cuteCharmLead = Gen4CuteCharmLead.none,
    bool fixedGender = false,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
  }) {
    return _searchMethodJk(
      ivs,
      method: Gen4StaticMethod.methodK,
      synchronizeNature: synchronizeNature,
      cuteCharmLead: cuteCharmLead,
      fixedGender: fixedGender,
      filters: _createStaticFilter(
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
      ),
    );
  }

  List<Gen4StaticSearchResult> searchMethodKRanges(
    Gen4IvRanges ranges, {
    Nature? synchronizeNature,
    Gen4CuteCharmLead cuteCharmLead = Gen4CuteCharmLead.none,
    bool fixedGender = false,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int maxIvCombinations = 100000,
  }) {
    _validateRangeSearch(ranges, maxIvCombinations);
    _createPokemonFilter(
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
    );
    final results = <Gen4StaticSearchResult>[];
    for (final ivs in ranges.enumerate(maxCombinations: maxIvCombinations)) {
      results.addAll(
        searchMethodK(
          ivs,
          synchronizeNature: synchronizeNature,
          cuteCharmLead: cuteCharmLead,
          fixedGender: fixedGender,
          nature: nature,
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

  List<Gen4StaticSearchResult> _searchMethodJk(
    Ivs ivs, {
    required Gen4StaticMethod method,
    required Nature? synchronizeNature,
    required Gen4CuteCharmLead cuteCharmLead,
    required bool fixedGender,
    required _StaticSearchFilters filters,
  }) {
    _validateRange();
    Gen4StatCalculator.validateIvs(ivs);
    filters.validate();
    if (synchronizeNature != null &&
        cuteCharmLead != Gen4CuteCharmLead.none &&
        !fixedGender) {
      throw ArgumentError('synchronizeNature and cuteCharmLead are exclusive');
    }

    final candidates = <_StaticSearchCandidate>[];
    final methodJ = method == Gen4StaticMethod.methodJ;
    final modulo = !methodJ;
    final cuteCharm = cuteCharmLead != Gen4CuteCharmLead.none && !fixedGender;
    final ivSeeds = LcrngReverse.recoverPokeRngIvs(
      hp: ivs.hp,
      attack: ivs.attack,
      defense: ivs.defense,
      specialAttack: ivs.specialAttack,
      specialDefense: ivs.specialDefense,
      speed: ivs.speed,
    );

    for (final ivSeed in ivSeeds) {
      var reverse = Lcrng.pokeRngReverse(ivSeed);

      if (cuteCharm) {
        final nature = reverse.nextU16Bounded(
          Nature.values.length,
          modulo: modulo,
        );
        reverse = Lcrng.pokeRngReverse(nature.seed);
        final charm = reverse.nextU16Bounded(3, modulo: modulo);
        reverse = Lcrng.pokeRngReverse(charm.seed);

        if (charm.value != 0) {
          final buffer = cuteCharmLead == Gen4CuteCharmLead.female
              ? 25 * ((genderRatio ~/ 25) + 1)
              : 0;
          candidates.add(
            _StaticSearchCandidate(
              seed: reverse.next().value,
              pid: buffer + nature.value,
              cuteCharmLead: cuteCharmLead,
              fixedGender: fixedGender,
            ),
          );
        }
        continue;
      }

      final high = reverse.nextU16();
      reverse = Lcrng.pokeRngReverse(high.seed);
      final low = reverse.nextU16();
      reverse = Lcrng.pokeRngReverse(low.seed);

      final pid = (high.value << 16) | low.value;
      final nature = pid % Nature.values.length;

      var prev1 = reverse.nextU16();
      reverse = Lcrng.pokeRngReverse(prev1.seed);
      var prev2 = reverse.nextU16();
      reverse = Lcrng.pokeRngReverse(prev2.seed);

      while (true) {
        final leadNature = methodJ
            ? prev1.value ~/ 0xa3e
            : prev1.value % Nature.values.length;
        if (synchronizeNature == null) {
          if (leadNature == nature) {
            candidates.add(
              _StaticSearchCandidate(seed: reverse.seed, pid: pid),
            );
          }
        } else {
          final syncSuccess = methodJ
              ? (prev1.value >> 15) == 0
              : prev1.value.isEven;
          if (syncSuccess && nature == synchronizeNature.index) {
            candidates.add(
              _StaticSearchCandidate(
                seed: reverse.seed,
                pid: pid,
                synchronizeNature: synchronizeNature,
              ),
            );
          }

          final syncFailed = methodJ
              ? (prev2.value >> 15) == 1
              : prev2.value.isOdd;
          if (syncFailed && leadNature == nature) {
            candidates.add(
              _StaticSearchCandidate(
                seed: Lcrng.pokeRngReverse(reverse.seed).next().value,
                pid: pid,
                synchronizeNature: synchronizeNature,
              ),
            );
          }
        }

        final huntNature =
            ((prev1.value << 16) | prev2.value) % Nature.values.length;
        if (huntNature == nature) {
          break;
        }

        prev1 = reverse.nextU16();
        reverse = Lcrng.pokeRngReverse(prev1.seed);
        prev2 = reverse.nextU16();
        reverse = Lcrng.pokeRngReverse(prev2.seed);
      }
    }

    return _searchInitialSeeds(
      ivs: ivs,
      method: method,
      candidates: candidates,
      filters: filters,
    );
  }

  Gen4StatIvRangeResult _ivRangeResultForObservedStats({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
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
    if (tid < 0 || tid > 0xffff) {
      throw ArgumentError.value(tid, 'tid', 'must be in 0..65535');
    }
    if (sid < 0 || sid > 0xffff) {
      throw ArgumentError.value(sid, 'sid', 'must be in 0..65535');
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
        'static search would scan $advanceCount advances per candidate; '
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

  _StaticSearchFilters _createStaticFilter({
    required Nature? nature,
    required int? abilitySlot,
    required PokemonGender? gender,
    required Shiny? shiny,
    required int? hiddenPowerType,
    required int? minHiddenPowerStrength,
    required int? maxHiddenPowerStrength,
  }) {
    return _StaticSearchFilters(
      nature: nature,
      pokemon: _createPokemonFilter(
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
      ),
    );
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

  List<Gen4StaticSearchResult> _searchInitialSeeds({
    required Ivs ivs,
    required Gen4StaticMethod method,
    required List<_StaticSearchCandidate> candidates,
    required _StaticSearchFilters filters,
  }) {
    final results = <Gen4StaticSearchResult>[];
    for (final candidate in candidates) {
      var initialSeed = Lcrng.pokeRngReverse(
        candidate.seed,
      ).advance(minAdvance).seed;

      for (var advance = minAdvance; advance <= maxAdvance; advance++) {
        final hour = (initialSeed >>> 16) & 0xff;
        final delay = initialSeed & 0xffff;
        if (_isAllowedHour(hour) && delay >= minDelay && delay <= maxDelay) {
          final generator = Gen4StaticGenerator(
            initialAdvances: advance,
            maxAdvances: 0,
            offset: 0,
            method: method,
            level: level,
            tid: tid,
            sid: sid,
            genderRatio: genderRatio,
            fixedGender: candidate.fixedGender,
            synchronizeNature: candidate.synchronizeNature,
            cuteCharmLead: candidate.cuteCharmLead,
          );
          final state = generator.generate(initialSeed).single;
          if (state.pid.value == candidate.pid &&
              _sameIvs(state.ivs, ivs) &&
              _matchesFilters(state, filters)) {
            results.add(
              Gen4StaticSearchResult(
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

  bool _matchesFilters(Gen4StaticState state, _StaticSearchFilters filters) {
    if (filters.nature != null && state.nature != filters.nature) {
      return false;
    }
    return filters.pokemon.matches(
      abilitySlot: state.abilitySlot,
      gender: state.gender,
      shiny: state.shiny,
      hiddenPowerType: state.hiddenPowerType,
      hiddenPowerStrength: state.hiddenPowerStrength,
    );
  }

  List<Gen4StaticSearchResult> _sortedLimitedResults(
    List<Gen4StaticSearchResult> results,
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

class Gen4StaticSearchResult {
  const Gen4StaticSearchResult({
    required this.initialSeed,
    required this.delay,
    required this.advance,
    required this.state,
  });

  final int initialSeed;
  final int delay;
  final int advance;
  final Gen4StaticState state;

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

class _StaticSearchCandidate {
  const _StaticSearchCandidate({
    required this.seed,
    required this.pid,
    this.synchronizeNature,
    this.cuteCharmLead = Gen4CuteCharmLead.none,
    this.fixedGender = false,
  });

  final int seed;
  final int pid;
  final Nature? synchronizeNature;
  final Gen4CuteCharmLead cuteCharmLead;
  final bool fixedGender;
}

class _StaticSearchFilters {
  const _StaticSearchFilters({this.nature, required this.pokemon});

  final Nature? nature;
  final Gen4PokemonSearchFilter pokemon;

  void validate() {
    pokemon.validate();
  }
}

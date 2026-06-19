import 'lcrng.dart';
import 'lcrng_reverse.dart';
import 'pokemon_attributes.dart';
import 'search_result_utils.dart';
import 'seed_time.dart';
import 'stat_calculator.dart';
import 'wild_generator.dart';

class Gen4WildSearcher {
  const Gen4WildSearcher({
    required this.minAdvance,
    required this.maxAdvance,
    required this.minDelay,
    required this.maxDelay,
    required this.game,
    required this.area,
    required this.tid,
    required this.sid,
    this.happiness = 0,
    this.feebasTile = false,
    this.unownRadio = false,
    this.maxResults,
    this.allowedHours = const {},
    this.maxGenerationSearchStates = 2000000,
    this.maxSearchAdvances = 2000000,
  });

  final int minAdvance;
  final int maxAdvance;
  final int minDelay;
  final int maxDelay;
  final Gen4WildGame game;
  final Gen4WildArea area;
  final int tid;
  final int sid;
  final int happiness;
  final bool feebasTile;
  final bool unownRadio;
  final int? maxResults;
  final Set<int> allowedHours;
  final int maxGenerationSearchStates;
  final int maxSearchAdvances;

  List<Gen4WildSearchResult> searchMethodJWildStats({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Gen4WildLead lead = Gen4WildLead.none,
    int? encounterSlot,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    return searchMethodJWildStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
      lead: lead,
      encounterSlot: encounterSlot,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      species: species,
      item: item,
      form: form,
      maxIvCombinations: maxIvCombinations,
    ).results;
  }

  Gen4StatsSearchResult<Gen4WildSearchResult> searchMethodJWildStatsDetailed({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Gen4WildLead lead = Gen4WildLead.none,
    int? encounterSlot,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    return _searchStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
      maxIvCombinations: maxIvCombinations,
      searchRanges: (ranges) => searchMethodJWildRanges(
        ranges,
        lead: lead,
        encounterSlot: encounterSlot,
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        species: species,
        minLevel: level,
        maxLevel: level,
        item: item,
        form: form,
        maxIvCombinations: maxIvCombinations,
      ),
    );
  }

  List<Gen4WildSearchResult> searchMethodJGrassNoLead(
    Ivs ivs, {
    int? encounterSlot,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
  }) {
    return searchMethodJGrass(
      ivs,
      encounterSlot: encounterSlot,
      nature: nature,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      species: species,
      minLevel: minLevel,
      maxLevel: maxLevel,
      item: item,
      form: form,
    );
  }

  List<Gen4WildSearchResult> searchMethodJNoLead(
    Ivs ivs, {
    int? encounterSlot,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
  }) {
    return searchMethodJWild(
      ivs,
      encounterSlot: encounterSlot,
      nature: nature,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      species: species,
      minLevel: minLevel,
      maxLevel: maxLevel,
      item: item,
      form: form,
    );
  }

  List<Gen4WildSearchResult> searchMethodJWildRanges(
    Gen4IvRanges ranges, {
    Gen4WildLead lead = Gen4WildLead.none,
    int? encounterSlot,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    _validateRangeSearch(ranges, maxIvCombinations);
    final results = <Gen4WildSearchResult>[];
    for (final ivs in ranges.enumerate(maxCombinations: maxIvCombinations)) {
      results.addAll(
        searchMethodJWild(
          ivs,
          lead: lead,
          encounterSlot: encounterSlot,
          nature: nature,
          abilitySlot: abilitySlot,
          gender: gender,
          shiny: shiny,
          hiddenPowerType: hiddenPowerType,
          minHiddenPowerStrength: minHiddenPowerStrength,
          maxHiddenPowerStrength: maxHiddenPowerStrength,
          species: species,
          minLevel: minLevel,
          maxLevel: maxLevel,
          item: item,
          form: form,
        ),
      );
    }
    return _sortedLimitedResults(results);
  }

  List<Gen4WildSearchResult> searchMethodJWild(
    Ivs ivs, {
    Gen4WildLead lead = Gen4WildLead.none,
    int? encounterSlot,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
  }) {
    return _searchBasicLead(
      ivs,
      method: Gen4WildMethod.methodJ,
      lead: lead,
      encounterSlot: encounterSlot,
      filters: _createFilters(
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        species: species,
        minLevel: minLevel,
        maxLevel: maxLevel,
        item: item,
        form: form,
      ),
    );
  }

  List<Gen4WildSearchResult> searchMethodJGrassStats({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    int? encounterSlot,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    return searchMethodJGrassStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
      lead: lead,
      synchronizeNature: synchronizeNature,
      encounterSlot: encounterSlot,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      species: species,
      item: item,
      form: form,
      maxIvCombinations: maxIvCombinations,
    ).results;
  }

  Gen4StatsSearchResult<Gen4WildSearchResult> searchMethodJGrassStatsDetailed({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    int? encounterSlot,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    return _searchStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
      maxIvCombinations: maxIvCombinations,
      searchRanges: (ranges) => searchMethodJGrassRanges(
        ranges,
        lead: lead,
        synchronizeNature: synchronizeNature,
        encounterSlot: encounterSlot,
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        species: species,
        minLevel: level,
        maxLevel: level,
        item: item,
        form: form,
        maxIvCombinations: maxIvCombinations,
      ),
    );
  }

  List<Gen4WildSearchResult> searchMethodJGrassRanges(
    Gen4IvRanges ranges, {
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    int? encounterSlot,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    _validateRangeSearch(ranges, maxIvCombinations);
    final results = <Gen4WildSearchResult>[];
    for (final ivs in ranges.enumerate(maxCombinations: maxIvCombinations)) {
      results.addAll(
        searchMethodJGrass(
          ivs,
          lead: lead,
          synchronizeNature: synchronizeNature,
          encounterSlot: encounterSlot,
          nature: nature,
          abilitySlot: abilitySlot,
          gender: gender,
          shiny: shiny,
          hiddenPowerType: hiddenPowerType,
          minHiddenPowerStrength: minHiddenPowerStrength,
          maxHiddenPowerStrength: maxHiddenPowerStrength,
          species: species,
          minLevel: minLevel,
          maxLevel: maxLevel,
          item: item,
          form: form,
        ),
      );
    }
    return _sortedLimitedResults(results);
  }

  List<Gen4WildSearchResult> searchMethodJGrass(
    Ivs ivs, {
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    int? encounterSlot,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
  }) {
    return _searchGrass(
      ivs,
      method: Gen4WildMethod.methodJ,
      lead: lead,
      synchronizeNature: synchronizeNature,
      encounterSlot: encounterSlot,
      filters: _createFilters(
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        species: species,
        minLevel: minLevel,
        maxLevel: maxLevel,
        item: item,
        form: form,
      ),
    );
  }

  List<Gen4WildSearchResult> searchMethodKWildStats({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Gen4WildLead lead = Gen4WildLead.none,
    int? encounterSlot,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    return searchMethodKWildStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
      lead: lead,
      encounterSlot: encounterSlot,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      species: species,
      item: item,
      form: form,
      maxIvCombinations: maxIvCombinations,
    ).results;
  }

  Gen4StatsSearchResult<Gen4WildSearchResult> searchMethodKWildStatsDetailed({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Gen4WildLead lead = Gen4WildLead.none,
    int? encounterSlot,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    return _searchStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
      maxIvCombinations: maxIvCombinations,
      searchRanges: (ranges) => searchMethodKWildRanges(
        ranges,
        lead: lead,
        encounterSlot: encounterSlot,
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        species: species,
        minLevel: level,
        maxLevel: level,
        item: item,
        form: form,
        maxIvCombinations: maxIvCombinations,
      ),
    );
  }

  List<Gen4WildSearchResult> searchMethodKGrassNoLead(
    Ivs ivs, {
    int? encounterSlot,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
  }) {
    return searchMethodKGrass(
      ivs,
      encounterSlot: encounterSlot,
      nature: nature,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      species: species,
      minLevel: minLevel,
      maxLevel: maxLevel,
      item: item,
      form: form,
    );
  }

  List<Gen4WildSearchResult> searchMethodKNoLead(
    Ivs ivs, {
    int? encounterSlot,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
  }) {
    return searchMethodKWild(
      ivs,
      encounterSlot: encounterSlot,
      nature: nature,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      species: species,
      minLevel: minLevel,
      maxLevel: maxLevel,
      item: item,
      form: form,
    );
  }

  List<Gen4WildSearchResult> searchMethodKWildRanges(
    Gen4IvRanges ranges, {
    Gen4WildLead lead = Gen4WildLead.none,
    int? encounterSlot,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    _validateRangeSearch(ranges, maxIvCombinations);
    final results = <Gen4WildSearchResult>[];
    for (final ivs in ranges.enumerate(maxCombinations: maxIvCombinations)) {
      results.addAll(
        searchMethodKWild(
          ivs,
          lead: lead,
          encounterSlot: encounterSlot,
          nature: nature,
          abilitySlot: abilitySlot,
          gender: gender,
          shiny: shiny,
          hiddenPowerType: hiddenPowerType,
          minHiddenPowerStrength: minHiddenPowerStrength,
          maxHiddenPowerStrength: maxHiddenPowerStrength,
          species: species,
          minLevel: minLevel,
          maxLevel: maxLevel,
          item: item,
          form: form,
        ),
      );
    }
    return _sortedLimitedResults(results);
  }

  List<Gen4WildSearchResult> searchMethodKWild(
    Ivs ivs, {
    Gen4WildLead lead = Gen4WildLead.none,
    int? encounterSlot,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
  }) {
    return _searchBasicLead(
      ivs,
      method: Gen4WildMethod.methodK,
      lead: lead,
      encounterSlot: encounterSlot,
      filters: _createFilters(
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        species: species,
        minLevel: minLevel,
        maxLevel: maxLevel,
        item: item,
        form: form,
      ),
    );
  }

  List<Gen4WildSearchResult> searchMethodKGrassStats({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    int? encounterSlot,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    return searchMethodKGrassStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
      lead: lead,
      synchronizeNature: synchronizeNature,
      encounterSlot: encounterSlot,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      species: species,
      item: item,
      form: form,
      maxIvCombinations: maxIvCombinations,
    ).results;
  }

  Gen4StatsSearchResult<Gen4WildSearchResult> searchMethodKGrassStatsDetailed({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    int? encounterSlot,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    return _searchStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
      maxIvCombinations: maxIvCombinations,
      searchRanges: (ranges) => searchMethodKGrassRanges(
        ranges,
        lead: lead,
        synchronizeNature: synchronizeNature,
        encounterSlot: encounterSlot,
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        species: species,
        minLevel: level,
        maxLevel: level,
        item: item,
        form: form,
        maxIvCombinations: maxIvCombinations,
      ),
    );
  }

  List<Gen4WildSearchResult> searchMethodKGrassRanges(
    Gen4IvRanges ranges, {
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    int? encounterSlot,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    _validateRangeSearch(ranges, maxIvCombinations);
    final results = <Gen4WildSearchResult>[];
    for (final ivs in ranges.enumerate(maxCombinations: maxIvCombinations)) {
      results.addAll(
        searchMethodKGrass(
          ivs,
          lead: lead,
          synchronizeNature: synchronizeNature,
          encounterSlot: encounterSlot,
          nature: nature,
          abilitySlot: abilitySlot,
          gender: gender,
          shiny: shiny,
          hiddenPowerType: hiddenPowerType,
          minHiddenPowerStrength: minHiddenPowerStrength,
          maxHiddenPowerStrength: maxHiddenPowerStrength,
          species: species,
          minLevel: minLevel,
          maxLevel: maxLevel,
          item: item,
          form: form,
        ),
      );
    }
    return _sortedLimitedResults(results);
  }

  List<Gen4WildSearchResult> searchMethodKGrass(
    Ivs ivs, {
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    int? encounterSlot,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
  }) {
    return _searchGrass(
      ivs,
      method: Gen4WildMethod.methodK,
      lead: lead,
      synchronizeNature: synchronizeNature,
      encounterSlot: encounterSlot,
      filters: _createFilters(
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        species: species,
        minLevel: minLevel,
        maxLevel: maxLevel,
        item: item,
        form: form,
      ),
    );
  }

  List<Gen4WildSearchResult> searchHoneyTreeStats({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    required int encounterSlot,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    return searchHoneyTreeStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      encounterSlot: encounterSlot,
      effortValues: effortValues,
      lead: lead,
      synchronizeNature: synchronizeNature,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      species: species,
      item: item,
      form: form,
      maxIvCombinations: maxIvCombinations,
    ).results;
  }

  Gen4StatsSearchResult<Gen4WildSearchResult> searchHoneyTreeStatsDetailed({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    required int encounterSlot,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    return _searchStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
      maxIvCombinations: maxIvCombinations,
      searchRanges: (ranges) => searchHoneyTreeRanges(
        ranges,
        encounterSlot: encounterSlot,
        lead: lead,
        synchronizeNature: synchronizeNature,
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        species: species,
        minLevel: level,
        maxLevel: level,
        item: item,
        form: form,
        maxIvCombinations: maxIvCombinations,
      ),
    );
  }

  List<Gen4WildSearchResult> searchHoneyTreeRanges(
    Gen4IvRanges ranges, {
    required int encounterSlot,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    _validateRangeSearch(ranges, maxIvCombinations);
    final results = <Gen4WildSearchResult>[];
    for (final ivs in ranges.enumerate(maxCombinations: maxIvCombinations)) {
      results.addAll(
        searchHoneyTree(
          ivs,
          encounterSlot: encounterSlot,
          lead: lead,
          synchronizeNature: synchronizeNature,
          nature: nature,
          abilitySlot: abilitySlot,
          gender: gender,
          shiny: shiny,
          hiddenPowerType: hiddenPowerType,
          minHiddenPowerStrength: minHiddenPowerStrength,
          maxHiddenPowerStrength: maxHiddenPowerStrength,
          species: species,
          minLevel: minLevel,
          maxLevel: maxLevel,
          item: item,
          form: form,
        ),
      );
    }
    return _sortedLimitedResults(results);
  }

  List<Gen4WildSearchResult> searchHoneyTree(
    Ivs ivs, {
    required int encounterSlot,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
  }) {
    _validateHoneyTreeSearch(
      lead: lead,
      synchronizeNature: synchronizeNature,
      encounterSlot: encounterSlot,
    );
    final syncNature = lead.isSynchronize
        ? (synchronizeNature ?? Nature.hardy)
        : null;
    return _searchByGeneration(
      ivs,
      method: Gen4WildMethod.honeyTree,
      lead: lead,
      synchronizeNature: syncNature,
      encounterSlot: encounterSlot,
      filters: _createFilters(
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        species: species,
        minLevel: minLevel,
        maxLevel: maxLevel,
        item: item,
        form: form,
      ),
    );
  }

  List<Gen4WildSearchResult> searchPokeRadarStats({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    required int encounterSlot,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    return searchPokeRadarStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      encounterSlot: encounterSlot,
      effortValues: effortValues,
      lead: lead,
      synchronizeNature: synchronizeNature,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      species: species,
      item: item,
      form: form,
      maxIvCombinations: maxIvCombinations,
    ).results;
  }

  Gen4StatsSearchResult<Gen4WildSearchResult> searchPokeRadarStatsDetailed({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    required int encounterSlot,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    return _searchStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
      maxIvCombinations: maxIvCombinations,
      searchRanges: (ranges) => searchPokeRadarRanges(
        ranges,
        encounterSlot: encounterSlot,
        lead: lead,
        synchronizeNature: synchronizeNature,
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        species: species,
        minLevel: level,
        maxLevel: level,
        item: item,
        form: form,
        maxIvCombinations: maxIvCombinations,
      ),
    );
  }

  List<Gen4WildSearchResult> searchPokeRadarRanges(
    Gen4IvRanges ranges, {
    required int encounterSlot,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    _validateRangeSearch(ranges, maxIvCombinations);
    final results = <Gen4WildSearchResult>[];
    for (final ivs in ranges.enumerate(maxCombinations: maxIvCombinations)) {
      results.addAll(
        searchPokeRadar(
          ivs,
          encounterSlot: encounterSlot,
          lead: lead,
          synchronizeNature: synchronizeNature,
          nature: nature,
          abilitySlot: abilitySlot,
          gender: gender,
          shiny: shiny,
          hiddenPowerType: hiddenPowerType,
          minHiddenPowerStrength: minHiddenPowerStrength,
          maxHiddenPowerStrength: maxHiddenPowerStrength,
          species: species,
          minLevel: minLevel,
          maxLevel: maxLevel,
          item: item,
          form: form,
        ),
      );
    }
    return _sortedLimitedResults(results);
  }

  List<Gen4WildSearchResult> searchPokeRadar(
    Ivs ivs, {
    required int encounterSlot,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
  }) {
    _validatePokeRadarSearch(
      lead: lead,
      synchronizeNature: synchronizeNature,
      encounterSlot: encounterSlot,
    );
    final syncNature = lead.isSynchronize
        ? (synchronizeNature ?? Nature.hardy)
        : null;
    return _searchByGeneration(
      ivs,
      method: Gen4WildMethod.pokeRadar,
      lead: lead,
      synchronizeNature: syncNature,
      encounterSlot: encounterSlot,
      filters: _createFilters(
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        species: species,
        minLevel: minLevel,
        maxLevel: maxLevel,
        item: item,
        form: form,
      ),
    );
  }

  List<Gen4WildSearchResult> searchPokeRadarShinyStats({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    required int encounterSlot,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    return searchPokeRadarShinyStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      encounterSlot: encounterSlot,
      effortValues: effortValues,
      lead: lead,
      synchronizeNature: synchronizeNature,
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPowerType: hiddenPowerType,
      minHiddenPowerStrength: minHiddenPowerStrength,
      maxHiddenPowerStrength: maxHiddenPowerStrength,
      species: species,
      item: item,
      form: form,
      maxIvCombinations: maxIvCombinations,
    ).results;
  }

  Gen4StatsSearchResult<Gen4WildSearchResult>
  searchPokeRadarShinyStatsDetailed({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    required int encounterSlot,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    return _searchStatsDetailed(
      baseStats: baseStats,
      observedStats: observedStats,
      nature: nature,
      level: level,
      effortValues: effortValues,
      maxIvCombinations: maxIvCombinations,
      searchRanges: (ranges) => searchPokeRadarShinyRanges(
        ranges,
        encounterSlot: encounterSlot,
        lead: lead,
        synchronizeNature: synchronizeNature,
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        species: species,
        minLevel: level,
        maxLevel: level,
        item: item,
        form: form,
        maxIvCombinations: maxIvCombinations,
      ),
    );
  }

  List<Gen4WildSearchResult> searchPokeRadarShinyRanges(
    Gen4IvRanges ranges, {
    required int encounterSlot,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
    int maxIvCombinations = 100000,
  }) {
    _validateRangeSearch(ranges, maxIvCombinations);
    final results = <Gen4WildSearchResult>[];
    for (final ivs in ranges.enumerate(maxCombinations: maxIvCombinations)) {
      results.addAll(
        searchPokeRadarShiny(
          ivs,
          encounterSlot: encounterSlot,
          lead: lead,
          synchronizeNature: synchronizeNature,
          nature: nature,
          abilitySlot: abilitySlot,
          gender: gender,
          shiny: shiny,
          hiddenPowerType: hiddenPowerType,
          minHiddenPowerStrength: minHiddenPowerStrength,
          maxHiddenPowerStrength: maxHiddenPowerStrength,
          species: species,
          minLevel: minLevel,
          maxLevel: maxLevel,
          item: item,
          form: form,
        ),
      );
    }
    return _sortedLimitedResults(results);
  }

  List<Gen4WildSearchResult> searchPokeRadarShiny(
    Ivs ivs, {
    required int encounterSlot,
    Gen4WildLead lead = Gen4WildLead.none,
    Nature? synchronizeNature,
    Nature? nature,
    int? abilitySlot,
    PokemonGender? gender,
    Shiny? shiny,
    int? hiddenPowerType,
    int? minHiddenPowerStrength,
    int? maxHiddenPowerStrength,
    int? species,
    int? minLevel,
    int? maxLevel,
    int? item,
    int? form,
  }) {
    _validatePokeRadarSearch(
      lead: lead,
      synchronizeNature: synchronizeNature,
      encounterSlot: encounterSlot,
    );
    final syncNature = lead.isSynchronize
        ? (synchronizeNature ?? Nature.hardy)
        : null;
    return _searchByGeneration(
      ivs,
      method: Gen4WildMethod.pokeRadarShiny,
      lead: lead,
      synchronizeNature: syncNature,
      encounterSlot: encounterSlot,
      filters: _createFilters(
        nature: nature,
        abilitySlot: abilitySlot,
        gender: gender,
        shiny: shiny,
        hiddenPowerType: hiddenPowerType,
        minHiddenPowerStrength: minHiddenPowerStrength,
        maxHiddenPowerStrength: maxHiddenPowerStrength,
        species: species,
        minLevel: minLevel,
        maxLevel: maxLevel,
        item: item,
        form: form,
      ),
    );
  }

  List<Gen4WildSearchResult> _searchBasicLead(
    Ivs ivs, {
    required Gen4WildMethod method,
    required Gen4WildLead lead,
    required int? encounterSlot,
    required _WildSearchFilters filters,
  }) {
    Gen4StatCalculator.validateIvs(ivs);
    _validateRange();
    _validateEncounterSlotFilter(encounterSlot);
    if (!_supportedBasicLead(lead)) {
      throw ArgumentError.value(lead, 'lead', 'unsupported basic wild lead');
    }
    final methodJ = method == Gen4WildMethod.methodJ;
    if ((!methodJ && _usesGenerationSearch) || _usesFeebasGenerationSearch) {
      return _searchByGeneration(
        ivs,
        method: method,
        lead: lead,
        synchronizeNature: null,
        encounterSlot: encounterSlot,
        filters: filters,
      );
    }

    final candidates = <_WildSearchCandidate>[];
    final preNatureCalls = _preNatureCalls(method, lead: lead);
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
      final nature = pid % Nature.values.length;

      var prev1 = reverse.nextU16();
      reverse = Lcrng.pokeRngReverse(prev1.seed);
      var prev2 = reverse.nextU16();
      reverse = Lcrng.pokeRngReverse(prev2.seed);

      while (true) {
        final leadNature = methodJ
            ? prev1.value ~/ 0xa3e
            : prev1.value % Nature.values.length;
        if (leadNature == nature) {
          candidates.add(
            _WildSearchCandidate(
              seed: _rewindPreNature(reverse, preNatureCalls),
              pid: pid,
              lead: lead,
            ),
          );
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
      encounterSlot: encounterSlot,
      filters: filters,
    );
  }

  List<Gen4WildSearchResult> _searchGrass(
    Ivs ivs, {
    required Gen4WildMethod method,
    required Gen4WildLead lead,
    required Nature? synchronizeNature,
    required int? encounterSlot,
    required _WildSearchFilters filters,
  }) {
    Gen4StatCalculator.validateIvs(ivs);
    _validateRange();
    if (!area.encounter.isGrass) {
      throw ArgumentError('only grass wild search is supported');
    }
    _validateEncounterSlotFilter(encounterSlot);
    if (!_supportedGrassLead(lead)) {
      throw ArgumentError.value(lead, 'lead', 'unsupported grass search lead');
    }
    if (synchronizeNature != null && !lead.isSynchronize) {
      throw ArgumentError(
        'synchronizeNature is only valid with synchronize lead',
      );
    }

    final candidates = <_WildSearchCandidate>[];
    final methodJ = method == Gen4WildMethod.methodJ;
    final modulo = !methodJ;
    final cuteCharm = lead.isCuteCharm;
    final syncNature = lead.isSynchronize
        ? (synchronizeNature ?? Nature.hardy)
        : null;
    if (!methodJ && _usesGenerationSearch) {
      return _searchByGeneration(
        ivs,
        method: method,
        lead: lead,
        synchronizeNature: syncNature,
        encounterSlot: encounterSlot,
        filters: filters,
      );
    }

    final ivSeeds = LcrngReverse.recoverPokeRngIvs(
      hp: ivs.hp,
      attack: ivs.attack,
      defense: ivs.defense,
      specialAttack: ivs.specialAttack,
      specialDefense: ivs.specialDefense,
      speed: ivs.speed,
    );

    final preNatureCalls = _preNatureCalls(method, lead: lead);
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
        final slot = reverse.nextU16Bounded(100, modulo: modulo);
        reverse = Lcrng.pokeRngReverse(slot.seed);

        if (charm.value != 0) {
          final slotIndex = _grassSlot(slot.value);
          if (area.slots[slotIndex].fixedGender) {
            continue;
          }
          candidates.add(
            _WildSearchCandidate(
              seed: reverse.next().value,
              pid: _cuteCharmPid(
                lead: lead,
                slotIndex: slotIndex,
                nature: nature.value,
              ),
              lead: lead,
              synchronizeNature: synchronizeNature,
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
        if (syncNature == null) {
          if (leadNature == nature) {
            candidates.add(
              _WildSearchCandidate(
                seed: _rewindPreNature(reverse, preNatureCalls),
                pid: pid,
                lead: lead,
                synchronizeNature: synchronizeNature,
              ),
            );
          }
        } else {
          final syncSuccess = methodJ
              ? (prev1.value >> 15) == 0
              : prev1.value.isEven;
          if (syncSuccess && nature == syncNature.index) {
            candidates.add(
              _WildSearchCandidate(
                seed: reverse.next().value,
                pid: pid,
                lead: lead,
                synchronizeNature: syncNature,
              ),
            );
          }

          final syncFailed = methodJ
              ? (prev2.value >> 15) == 1
              : prev2.value.isOdd;
          if (syncFailed && leadNature == nature) {
            var slotReverse = Lcrng.pokeRngReverse(reverse.seed);
            final slot = slotReverse.nextU16Bounded(100, modulo: modulo);
            slotReverse = Lcrng.pokeRngReverse(slot.seed);
            candidates.add(
              _WildSearchCandidate(
                seed: slotReverse.next().value,
                pid: pid,
                lead: lead,
                synchronizeNature: syncNature,
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
      encounterSlot: encounterSlot,
      filters: filters,
    );
  }

  List<Gen4WildSearchResult> _searchByGeneration(
    Ivs ivs, {
    required Gen4WildMethod method,
    required Gen4WildLead lead,
    required Nature? synchronizeNature,
    required int? encounterSlot,
    required _WildSearchFilters filters,
  }) {
    Gen4StatCalculator.validateIvs(ivs);
    _validateGenerationSearchSize();
    final results = <Gen4WildSearchResult>[];
    for (final hour in Gen4SearchResultUtils.effectiveAllowedHours(
      allowedHours,
    )) {
      for (var delay = minDelay; delay <= maxDelay; delay++) {
        final initialSeed = (hour << 16) | delay;
        final generator = Gen4WildGenerator(
          initialAdvances: minAdvance,
          maxAdvances: maxAdvance - minAdvance,
          offset: 0,
          method: method,
          game: game,
          area: area,
          tid: tid,
          sid: sid,
          lead: lead,
          synchronizeNature: synchronizeNature,
          happiness: happiness,
          encounterSlot: encounterSlot ?? 0,
          feebasTile: feebasTile,
          unownRadio: unownRadio,
        );
        for (final state in generator.generate(initialSeed)) {
          if (_sameIvs(state.ivs, ivs) &&
              (encounterSlot == null || state.encounterSlot == encounterSlot) &&
              _matchesFilters(state, filters)) {
            results.add(
              Gen4WildSearchResult(
                initialSeed: initialSeed,
                delay: delay,
                advance: state.advance,
                state: state,
              ),
            );
          }
        }
      }
    }
    return _sortedLimitedResults(results);
  }

  Gen4StatsSearchResult<Gen4WildSearchResult> _searchStatsDetailed({
    required PokemonStats baseStats,
    required PokemonStats observedStats,
    required Nature nature,
    required int level,
    required PokemonEffortValues effortValues,
    required int maxIvCombinations,
    required List<Gen4WildSearchResult> Function(Gen4IvRanges ranges)
    searchRanges,
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
      results: searchRanges(ivRangeResult.ranges),
    );
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

  bool _supportedGrassLead(Gen4WildLead lead) {
    return lead.supportsGrassWildSearch;
  }

  bool _supportedBasicLead(Gen4WildLead lead) {
    return lead.supportsBasicWildSearch;
  }

  bool _supportedHoneyTreeLead(Gen4WildLead lead) {
    return lead.supportsHoneyTree;
  }

  void _validateHoneyTreeSearch({
    required Gen4WildLead lead,
    required Nature? synchronizeNature,
    required int encounterSlot,
  }) {
    _validateRange();
    if (!area.encounter.isHoneyTree) {
      throw ArgumentError('only honey tree search is supported');
    }
    _validateEncounterSlotFilter(encounterSlot);
    if (!_supportedHoneyTreeLead(lead)) {
      throw ArgumentError.value(lead, 'lead', 'unsupported honey tree lead');
    }
    if (synchronizeNature != null && !lead.isSynchronize) {
      throw ArgumentError(
        'synchronizeNature is only valid with synchronize lead',
      );
    }
  }

  bool _supportedPokeRadarLead(Gen4WildLead lead) {
    return lead.supportsPokeRadar;
  }

  void _validatePokeRadarSearch({
    required Gen4WildLead lead,
    required Nature? synchronizeNature,
    required int encounterSlot,
  }) {
    _validateRange();
    if (!area.encounter.isGrass) {
      throw ArgumentError('Poke Radar search must use grass areas');
    }
    _validateEncounterSlotFilter(encounterSlot);
    if (!_supportedPokeRadarLead(lead)) {
      throw ArgumentError.value(lead, 'lead', 'unsupported Poke Radar lead');
    }
    if (synchronizeNature != null && !lead.isSynchronize) {
      throw ArgumentError(
        'synchronizeNature is only valid with synchronize lead',
      );
    }
  }

  int _preNatureCalls(Gen4WildMethod method, {required Gen4WildLead lead}) {
    var calls = 1;
    if (_usesTypeAttractLead(lead)) {
      calls++;
    }
    if (!area.encounter.isGrass) {
      calls++;
    }
    if (_needsEncounterCheck(method)) {
      calls++;
    }
    if (lead.isPressure) {
      calls++;
    }
    return calls;
  }

  bool _needsEncounterCheck(Gen4WildMethod method) =>
      area.needsEncounterCheck(method: method);

  bool get _usesGenerationSearch => area.usesGenerationSearch;

  bool get _usesFeebasGenerationSearch => area.feebasLocation && feebasTile;

  bool _usesTypeAttractLead(Gen4WildLead lead) {
    return lead.usesTypeAttract;
  }

  int _rewindPreNature(Lcrng reverse, int calls) {
    var go = reverse;
    var seed = go.seed;
    for (var i = 0; i < calls; i++) {
      final previous = go.next();
      seed = previous.value;
      go = Lcrng.pokeRngReverse(previous.seed);
    }
    return seed;
  }

  int _cuteCharmPid({
    required Gen4WildLead lead,
    required int slotIndex,
    required int nature,
  }) {
    final slot = area.slots[slotIndex];
    final buffer = lead.isCuteCharmFemale
        ? PokemonGenderRatio.cuteCharmFemaleBuffer(slot.genderRatio)
        : 0;
    return buffer + nature;
  }

  int _grassSlot(int rand) {
    return switch (rand) {
      < 20 => 0,
      < 40 => 1,
      < 50 => 2,
      < 60 => 3,
      < 70 => 4,
      < 80 => 5,
      < 85 => 6,
      < 90 => 7,
      < 94 => 8,
      < 98 => 9,
      < 99 => 10,
      _ => 11,
    };
  }

  void _validateRange() {
    if (minAdvance > maxAdvance) {
      throw ArgumentError('minAdvance must be <= maxAdvance');
    }
    if (minDelay > maxDelay) {
      throw ArgumentError('minDelay must be <= maxDelay');
    }
    if (minDelay < 0 || maxDelay > 0xffff) {
      throw ArgumentError('delay range must be within 0..65535');
    }
    if (minAdvance < 0) {
      throw ArgumentError('minAdvance must be non-negative');
    }
    if (maxGenerationSearchStates <= 0) {
      throw ArgumentError('maxGenerationSearchStates must be positive');
    }
    if (maxSearchAdvances <= 0) {
      throw ArgumentError.value(
        maxSearchAdvances,
        'maxSearchAdvances',
        'must be positive',
      );
    }
    Gen4SearchResultUtils.validateMaxResults(maxResults);
    if (tid < 0 || tid > 0xffff) {
      throw ArgumentError.value(tid, 'tid', 'must be in 0..65535');
    }
    if (sid < 0 || sid > 0xffff) {
      throw ArgumentError.value(sid, 'sid', 'must be in 0..65535');
    }
    if (happiness < 0 || happiness > 255) {
      throw ArgumentError.value(happiness, 'happiness', 'must be in 0..255');
    }
    Gen4SearchResultUtils.validateAllowedHours(allowedHours);
    _validateArea();
    _validateSearchSize();
  }

  void _validateSearchSize() {
    final advanceCount = maxAdvance - minAdvance + 1;
    if (advanceCount > maxSearchAdvances) {
      throw StateError(
        'wild search would scan $advanceCount advances per candidate; '
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

  void _validateArea() {
    if (area.rate < 0 || area.rate > 100) {
      throw ArgumentError.value(area.rate, 'area.rate', 'must be in 0..100');
    }
    if (area.location < 0) {
      throw ArgumentError.value(
        area.location,
        'area.location',
        'must be non-negative',
      );
    }
    if (!area.validSlotCount) {
      throw ArgumentError(
        'Gen4 wild areas must provide 12 slots, or 6 slots for Headbutt',
      );
    }
    for (var index = 0; index < area.slots.length; index++) {
      _validateSlot(area.slots[index], 'area.slots[$index]');
    }
    _validateUnownForms(area.unownUnlockedForms, 'area.unownUnlockedForms');
    _validateUnownForms(
      area.unownUndiscoveredForms,
      'area.unownUndiscoveredForms',
    );
  }

  void _validateSlot(Gen4WildSlot slot, String name) {
    if (slot.species < 0 || slot.species > 493) {
      throw ArgumentError.value(
        slot.species,
        '$name.species',
        'must be in 0..493',
      );
    }
    if (slot.species == 0) {
      if (slot.minLevel < 0 ||
          slot.maxLevel > 100 ||
          slot.minLevel > slot.maxLevel) {
        throw ArgumentError.value(
          '${slot.minLevel}-${slot.maxLevel}',
          '$name.level',
          'empty slots must stay within 0..100 with min <= max',
        );
      }
    } else {
      if (slot.minLevel < 1 ||
          slot.maxLevel > 100 ||
          slot.minLevel > slot.maxLevel) {
        throw ArgumentError.value(
          '${slot.minLevel}-${slot.maxLevel}',
          '$name.level',
          'must be in 1..100 with min <= max',
        );
      }
    }
    if (slot.genderRatio < 0 || slot.genderRatio > 255) {
      throw ArgumentError.value(
        slot.genderRatio,
        '$name.genderRatio',
        'must be in 0..255',
      );
    }
    if (slot.item1 < 0 || slot.item2 < 0) {
      throw ArgumentError.value(
        '${slot.item1}/${slot.item2}',
        '$name.items',
        'must be non-negative',
      );
    }
  }

  void _validateUnownForms(List<int> forms, String name) {
    final seen = <int>{};
    for (var index = 0; index < forms.length; index++) {
      final form = forms[index];
      if (form < 0 || form > 27) {
        throw ArgumentError.value(form, '$name[$index]', 'must be in 0..27');
      }
      if (!seen.add(form)) {
        throw ArgumentError.value(
          form,
          '$name[$index]',
          'must not be duplicated',
        );
      }
    }
  }

  void _validateEncounterSlotFilter(int? encounterSlot) {
    if (encounterSlot == null) {
      return;
    }
    if (encounterSlot < 0 || encounterSlot >= area.slots.length) {
      throw ArgumentError.value(
        encounterSlot,
        'encounterSlot',
        'must be within area slots',
      );
    }
  }

  _WildSearchFilters _createFilters({
    required Nature? nature,
    required int? abilitySlot,
    required PokemonGender? gender,
    required Shiny? shiny,
    required int? hiddenPowerType,
    required int? minHiddenPowerStrength,
    required int? maxHiddenPowerStrength,
    required int? species,
    required int? minLevel,
    required int? maxLevel,
    required int? item,
    required int? form,
  }) {
    final pokemon = Gen4PokemonSearchFilter(
      abilitySlot: abilitySlot,
      gender: gender,
      shiny: shiny,
      hiddenPower: Gen4HiddenPowerFilter(
        type: hiddenPowerType,
        minStrength: minHiddenPowerStrength,
        maxStrength: maxHiddenPowerStrength,
      ),
    );
    pokemon.validate();

    if (species != null && (species < 0 || species > 493)) {
      throw ArgumentError.value(species, 'species', 'must be in 0..493');
    }
    if (minLevel != null && (minLevel < 1 || minLevel > 100)) {
      throw ArgumentError.value(minLevel, 'minLevel', 'must be in 1..100');
    }
    if (maxLevel != null && (maxLevel < 1 || maxLevel > 100)) {
      throw ArgumentError.value(maxLevel, 'maxLevel', 'must be in 1..100');
    }
    if (minLevel != null && maxLevel != null && minLevel > maxLevel) {
      throw ArgumentError('minLevel must be <= maxLevel');
    }
    if (item != null && item < 0) {
      throw ArgumentError.value(item, 'item', 'must be non-negative');
    }
    if (form != null && (form < 0 || form > 27)) {
      throw ArgumentError.value(form, 'form', 'must be in 0..27');
    }
    return _WildSearchFilters(
      nature: nature,
      pokemon: pokemon,
      species: species,
      minLevel: minLevel,
      maxLevel: maxLevel,
      item: item,
      form: form,
    );
  }

  void _validateGenerationSearchSize() {
    final delayCount = maxDelay - minDelay + 1;
    final advanceCount = maxAdvance - minAdvance + 1;
    final states =
        Gen4SearchResultUtils.effectiveAllowedHours(allowedHours).length *
        delayCount *
        advanceCount;
    if (states > maxGenerationSearchStates) {
      throw StateError(
        'generation search would scan $states states; '
        'increase maxGenerationSearchStates to allow this range',
      );
    }
  }

  List<Gen4WildSearchResult> _searchInitialSeeds({
    required Ivs ivs,
    required Gen4WildMethod method,
    required List<_WildSearchCandidate> candidates,
    required int? encounterSlot,
    required _WildSearchFilters filters,
  }) {
    final results = <Gen4WildSearchResult>[];
    for (final candidate in candidates) {
      var initialSeed = Lcrng.pokeRngReverse(
        candidate.seed,
      ).advance(minAdvance).seed;

      for (var advance = minAdvance; advance <= maxAdvance; advance++) {
        final hour = (initialSeed >>> 16) & 0xff;
        final delay = initialSeed & 0xffff;
        if (_isAllowedHour(hour) && delay >= minDelay && delay <= maxDelay) {
          final generator = Gen4WildGenerator(
            initialAdvances: advance,
            maxAdvances: 0,
            offset: 0,
            method: method,
            game: game,
            area: area,
            tid: tid,
            sid: sid,
            lead: candidate.lead,
            synchronizeNature: candidate.synchronizeNature,
            happiness: happiness,
            encounterSlot: encounterSlot ?? 0,
            feebasTile: feebasTile,
            unownRadio: unownRadio,
          );
          final states = generator.generate(initialSeed);
          if (states.length == 1) {
            final state = states.single;
            if (state.pid.value == candidate.pid &&
                _sameIvs(state.ivs, ivs) &&
                (encounterSlot == null ||
                    state.encounterSlot == encounterSlot) &&
                _matchesFilters(state, filters)) {
              results.add(
                Gen4WildSearchResult(
                  initialSeed: initialSeed,
                  delay: delay,
                  advance: advance,
                  state: state,
                ),
              );
            }
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

  bool _matchesFilters(Gen4WildState state, _WildSearchFilters filters) {
    if (filters.nature != null && state.nature != filters.nature) {
      return false;
    }
    if (!filters.pokemon.matches(
      abilitySlot: state.abilitySlot,
      gender: state.gender,
      shiny: state.shiny,
      hiddenPowerType: state.hiddenPowerType,
      hiddenPowerStrength: state.hiddenPowerStrength,
    )) {
      return false;
    }
    if (filters.species != null && state.species != filters.species) {
      return false;
    }
    if (filters.minLevel != null && state.level < filters.minLevel!) {
      return false;
    }
    if (filters.maxLevel != null && state.level > filters.maxLevel!) {
      return false;
    }
    if (filters.item != null && state.item != filters.item) {
      return false;
    }
    if (filters.form != null && state.form != filters.form) {
      return false;
    }
    return true;
  }

  List<Gen4WildSearchResult> _sortedLimitedResults(
    List<Gen4WildSearchResult> results,
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

class Gen4WildSearchResult {
  const Gen4WildSearchResult({
    required this.initialSeed,
    required this.delay,
    required this.advance,
    required this.state,
  });

  final int initialSeed;
  final int delay;
  final int advance;
  final Gen4WildState state;

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

class _WildSearchCandidate {
  const _WildSearchCandidate({
    required this.seed,
    required this.pid,
    this.lead = Gen4WildLead.none,
    this.synchronizeNature,
  });

  final int seed;
  final int pid;
  final Gen4WildLead lead;
  final Nature? synchronizeNature;
}

class _WildSearchFilters {
  const _WildSearchFilters({
    this.nature,
    required this.pokemon,
    this.species,
    this.minLevel,
    this.maxLevel,
    this.item,
    this.form,
  });

  final Nature? nature;
  final Gen4PokemonSearchFilter pokemon;
  final int? species;
  final int? minLevel;
  final int? maxLevel;
  final int? item;
  final int? form;
}

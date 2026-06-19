import 'pokemon_attributes.dart';

class Gen4StatCalculator {
  const Gen4StatCalculator._();

  static PokemonStats calculateStats({
    required PokemonStats baseStats,
    required Ivs ivs,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
  }) {
    _validateLevel(level);
    _validateBaseStats(baseStats);
    _validateIvs(ivs);
    _validateEffortValues(effortValues);
    return PokemonStats(
      hp: _hpStat(
        base: baseStats.hp,
        iv: ivs.hp,
        effortValue: effortValues.hp,
        level: level,
      ),
      attack: _nonHpStat(
        base: baseStats.attack,
        iv: ivs.attack,
        effortValue: effortValues.attack,
        level: level,
        nature: nature,
        statIndex: 0,
      ),
      defense: _nonHpStat(
        base: baseStats.defense,
        iv: ivs.defense,
        effortValue: effortValues.defense,
        level: level,
        nature: nature,
        statIndex: 1,
      ),
      specialAttack: _nonHpStat(
        base: baseStats.specialAttack,
        iv: ivs.specialAttack,
        effortValue: effortValues.specialAttack,
        level: level,
        nature: nature,
        statIndex: 3,
      ),
      specialDefense: _nonHpStat(
        base: baseStats.specialDefense,
        iv: ivs.specialDefense,
        effortValue: effortValues.specialDefense,
        level: level,
        nature: nature,
        statIndex: 4,
      ),
      speed: _nonHpStat(
        base: baseStats.speed,
        iv: ivs.speed,
        effortValue: effortValues.speed,
        level: level,
        nature: nature,
        statIndex: 2,
      ),
    );
  }

  static PokemonStats calculateDisplayStats({
    required PokemonStats baseStats,
    required Ivs ivs,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
  }) {
    return calculateStats(
      baseStats: baseStats,
      ivs: ivs,
      nature: nature,
      level: level,
      effortValues: effortValues,
    );
  }

  static Gen4IvRanges possibleIvRangesForStats({
    required PokemonStats baseStats,
    required PokemonStats stats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
  }) {
    return ivRangeResultForStats(
      baseStats: baseStats,
      stats: stats,
      nature: nature,
      level: level,
      effortValues: effortValues,
    ).ranges;
  }

  static Gen4StatIvRangeResult ivRangeResultForStats({
    required PokemonStats baseStats,
    required PokemonStats stats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
  }) {
    final values = possibleIvValuesForStats(
      baseStats: baseStats,
      stats: stats,
      nature: nature,
      level: level,
      effortValues: effortValues,
    );
    final ranges = Gen4IvRanges.fromValues(values);
    return Gen4StatIvRangeResult(ranges: ranges);
  }

  static List<List<int>> possibleIvValuesForStats({
    required PokemonStats baseStats,
    required PokemonStats stats,
    required Nature nature,
    required int level,
    PokemonEffortValues effortValues = PokemonEffortValues.zero,
  }) {
    _validateLevel(level);
    _validateBaseStats(baseStats);
    _validateStats(stats, name: 'stats');
    _validateEffortValues(effortValues);
    final observed = stats.ordered;
    final possible = List<List<int>>.generate(6, (_) => []);
    for (var iv = 0; iv <= 31; iv++) {
      final calculated = calculateStats(
        baseStats: baseStats,
        ivs: Ivs(
          hp: iv,
          attack: iv,
          defense: iv,
          specialAttack: iv,
          specialDefense: iv,
          speed: iv,
        ),
        nature: nature,
        level: level,
        effortValues: effortValues,
      ).ordered;
      for (var index = 0; index < observed.length; index++) {
        if (calculated[index] == observed[index]) {
          possible[index].add(iv);
        }
      }
    }
    return possible;
  }

  static bool ivsMatchRanges(Ivs ivs, Gen4IvRanges ranges) {
    _validateIvs(ivs);
    _validateRanges(ranges);
    final values = ivs.ordered;
    final rangeValues = ranges.ordered;
    for (var i = 0; i < values.length; i++) {
      if (!rangeValues[i].contains(values[i])) {
        return false;
      }
    }
    return true;
  }

  static void validateIvs(Ivs ivs) {
    _validateIvs(ivs);
  }

  static void validateIvRanges(Gen4IvRanges ranges) {
    _validateRanges(ranges);
  }

  static void _validateLevel(int level) {
    if (level < 1 || level > 100) {
      throw ArgumentError.value(level, 'level', 'must be in 1..100');
    }
  }

  static void _validateBaseStats(PokemonStats baseStats) {
    _validateStats(baseStats, name: 'baseStats', min: 1, max: 255);
  }

  static void _validateStats(
    PokemonStats stats, {
    required String name,
    int min = 1,
    int max = 999,
  }) {
    final values = stats.ordered;
    const names = [
      'hp',
      'attack',
      'defense',
      'specialAttack',
      'specialDefense',
      'speed',
    ];
    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      if (value < min || value > max) {
        throw ArgumentError.value(
          value,
          '$name.${names[index]}',
          'must be in $min..$max',
        );
      }
    }
  }

  static void _validateIvs(Ivs ivs) {
    final values = ivs.ordered;
    const names = [
      'hp',
      'attack',
      'defense',
      'specialAttack',
      'specialDefense',
      'speed',
    ];
    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      if (value < 0 || value > 31) {
        throw ArgumentError.value(
          value,
          'ivs.${names[index]}',
          'must be 0..31',
        );
      }
    }
  }

  static void _validateEffortValues(PokemonEffortValues effortValues) {
    final values = effortValues.ordered;
    const names = [
      'hp',
      'attack',
      'defense',
      'specialAttack',
      'specialDefense',
      'speed',
    ];
    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      if (value < 0 || value > 255) {
        throw ArgumentError.value(
          value,
          'effortValues.${names[index]}',
          'must be in 0..255',
        );
      }
    }
    if (effortValues.total > 510) {
      throw ArgumentError.value(
        effortValues.total,
        'effortValues.total',
        'must be <= 510',
      );
    }
  }

  static void _validateRanges(Gen4IvRanges ranges) {
    final values = ranges.ordered;
    const names = [
      'hp',
      'attack',
      'defense',
      'specialAttack',
      'specialDefense',
      'speed',
    ];
    for (var index = 0; index < values.length; index++) {
      final range = values[index];
      if (range.min < 0 || range.min > 31 || range.max < 0 || range.max > 31) {
        throw ArgumentError.value(
          '${range.min}-${range.max}',
          'ranges.${names[index]}',
          'must be within 0..31',
        );
      }
    }
  }

  static int _hpStat({
    required int base,
    required int iv,
    required int effortValue,
    required int level,
  }) {
    if (base == 1) {
      return 1;
    }
    return (((2 * base + iv + (effortValue ~/ 4)) * level) ~/ 100) + level + 10;
  }

  static int _nonHpStat({
    required int base,
    required int iv,
    required int effortValue,
    required int level,
    required Nature nature,
    required int statIndex,
  }) {
    final raw = (((2 * base + iv + (effortValue ~/ 4)) * level) ~/ 100) + 5;
    return (raw * nature.modifierPercentForStatIndex(statIndex)) ~/ 100;
  }
}

class Gen4StatIvRangeResult {
  const Gen4StatIvRangeResult({required this.ranges});

  final Gen4IvRanges ranges;

  int get combinationCount => ranges.combinationCount;
  bool get isEmpty => ranges.isEmpty;

  bool exceedsMaxCombinations(int maxCombinations) {
    if (maxCombinations <= 0) {
      throw ArgumentError.value(
        maxCombinations,
        'maxCombinations',
        'must be positive',
      );
    }
    return combinationCount > maxCombinations;
  }

  void validateMaxCombinations(int maxCombinations) {
    if (exceedsMaxCombinations(maxCombinations)) {
      throw StateError(
        'IV range expands to $combinationCount combinations, '
        'above maxCombinations $maxCombinations',
      );
    }
  }
}

class Gen4StatsSearchResult<T> {
  const Gen4StatsSearchResult({
    required this.ivRangeResult,
    required this.results,
    this.maxIvCombinations,
    this.maxResults,
  });

  final Gen4StatIvRangeResult ivRangeResult;
  final List<T> results;
  final int? maxIvCombinations;
  final int? maxResults;

  Gen4IvRanges get ranges => ivRangeResult.ranges;
  int get combinationCount => ivRangeResult.combinationCount;
  bool get isEmpty => ivRangeResult.isEmpty;
  int get resultCount => results.length;
  bool get hasResults => results.isNotEmpty;
  List<String> get rangeSummaries => ranges.summaries;
  bool get reachedIvCombinationLimit =>
      maxIvCombinations != null && combinationCount >= maxIvCombinations!;
  bool get reachedResultLimit =>
      maxResults != null && results.length >= maxResults!;
}

class Gen4IvRanges {
  const Gen4IvRanges({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
  });

  factory Gen4IvRanges.fromValues(List<List<int>> values) {
    if (values.length != 6) {
      throw ArgumentError.value(values.length, 'values.length', 'must be 6');
    }
    return Gen4IvRanges(
      hp: Gen4IvRange.fromValues(values[0]),
      attack: Gen4IvRange.fromValues(values[1]),
      defense: Gen4IvRange.fromValues(values[2]),
      specialAttack: Gen4IvRange.fromValues(values[3]),
      specialDefense: Gen4IvRange.fromValues(values[4]),
      speed: Gen4IvRange.fromValues(values[5]),
    );
  }

  final Gen4IvRange hp;
  final Gen4IvRange attack;
  final Gen4IvRange defense;
  final Gen4IvRange specialAttack;
  final Gen4IvRange specialDefense;
  final Gen4IvRange speed;

  List<Gen4IvRange> get ordered => [
    hp,
    attack,
    defense,
    specialAttack,
    specialDefense,
    speed,
  ];

  List<String> get summaries {
    Gen4StatCalculator._validateRanges(this);
    return [for (final range in ordered) range.summary];
  }

  bool get isEmpty {
    Gen4StatCalculator._validateRanges(this);
    return ordered.any((range) => range.isEmpty);
  }

  int get combinationCount {
    Gen4StatCalculator._validateRanges(this);
    var count = 1;
    for (final range in ordered) {
      count *= range.length;
    }
    return count;
  }

  Iterable<Ivs> enumerate({int maxCombinations = 100000}) sync* {
    Gen4StatCalculator._validateRanges(this);
    if (maxCombinations <= 0) {
      throw ArgumentError.value(
        maxCombinations,
        'maxCombinations',
        'must be positive',
      );
    }
    if (combinationCount > maxCombinations) {
      throw StateError(
        'IV range expands to $combinationCount combinations, '
        'above maxCombinations $maxCombinations',
      );
    }
    for (final hp in this.hp.values) {
      for (final attack in this.attack.values) {
        for (final defense in this.defense.values) {
          for (final specialAttack in this.specialAttack.values) {
            for (final specialDefense in this.specialDefense.values) {
              for (final speed in this.speed.values) {
                yield Ivs(
                  hp: hp,
                  attack: attack,
                  defense: defense,
                  specialAttack: specialAttack,
                  specialDefense: specialDefense,
                  speed: speed,
                );
              }
            }
          }
        }
      }
    }
  }

  @override
  String toString() {
    return summaries.join('/');
  }
}

class Gen4IvRange {
  const Gen4IvRange({required this.min, required this.max});

  factory Gen4IvRange.fromValues(List<int> values) {
    if (values.isEmpty) {
      return const Gen4IvRange(min: 1, max: 0);
    }
    var min = 31;
    var max = 0;
    for (final value in values) {
      if (value < 0 || value > 31) {
        throw ArgumentError.value(value, 'values', 'must be in 0..31');
      }
      if (value < min) {
        min = value;
      }
      if (value > max) {
        max = value;
      }
    }
    return Gen4IvRange(min: min, max: max);
  }

  final int min;
  final int max;

  bool get isEmpty => min > max;
  bool get isSingle => !isEmpty && min == max;

  int get length {
    _validate();
    return isEmpty ? 0 : max - min + 1;
  }

  Iterable<int> get values sync* {
    _validate();
    for (var value = min; value <= max; value++) {
      yield value;
    }
  }

  bool contains(int value) {
    _validate();
    return !isEmpty && value >= min && value <= max;
  }

  String get summary {
    _validate();
    return isEmpty ? '-' : (isSingle ? '$min' : '$min-$max');
  }

  @override
  String toString() {
    return summary;
  }

  void _validate() {
    if (min < 0 || min > 31 || max < 0 || max > 31) {
      throw ArgumentError.value('$min-$max', 'range', 'must be within 0..31');
    }
  }
}

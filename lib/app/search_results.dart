import '../core/gen4/pokemon_attributes.dart';

enum Gen4SearchRunState { idle, running, completed, cancelled, failed }

class Gen4SearchProgress {
  const Gen4SearchProgress({required this.scanned, required this.total});

  final int scanned;
  final int total;

  double get fraction {
    if (total <= 0) {
      return 0;
    }
    return (scanned / total).clamp(0, 1).toDouble();
  }
}

class Gen4SearchResultRow {
  const Gen4SearchResultRow({
    required this.target,
    required this.method,
    required this.seed,
    required this.delay,
    required this.advance,
    required this.year,
    required this.hour,
    required this.ivs,
    required this.shiny,
    this.second,
    this.pid,
    this.level,
    this.encounterSlot,
    this.abilitySlot,
    this.abilityName,
    this.gender,
    this.natureId,
    this.hiddenPowerType,
    this.hiddenPowerStrength,
    this.stats,
    this.source,
  });

  factory Gen4SearchResultRow.fromJson(Map<String, dynamic> json) {
    return Gen4SearchResultRow(
      target: json['target'] as String,
      method: json['method'] as String,
      seed: json['seed'] as String,
      delay: json['delay'] as int,
      advance: json['advance'] as int,
      year: json['year'] as int,
      hour: json['hour'] as int,
      second: json['second'] as int?,
      ivs: json['ivs'] as String,
      shiny: json['shiny'] as bool,
      pid: json['pid'] as String?,
      level: json['level'] as int?,
      encounterSlot: json['encounterSlot'] as int?,
      abilitySlot: json['abilitySlot'] as int?,
      abilityName: json['abilityName'] as String?,
      gender: _enumOrNull(PokemonGender.values, json['gender']),
      natureId: json['natureId'] as int?,
      hiddenPowerType: json['hiddenPowerType'] as int?,
      hiddenPowerStrength: json['hiddenPowerStrength'] as int?,
      stats: json['stats'] as String?,
      source: json['source'] == null
          ? null
          : Gen4SearchResultSource.fromJson(
              (json['source'] as Map).cast<String, dynamic>(),
            ),
    );
  }

  final String target;
  final String method;
  final String seed;
  final int delay;
  final int advance;
  final int year;
  final int hour;
  final int? second;
  final String ivs;
  final bool shiny;
  final String? pid;
  final int? level;
  final int? encounterSlot;
  final int? abilitySlot;
  final String? abilityName;
  final PokemonGender? gender;
  final int? natureId;
  final int? hiddenPowerType;
  final int? hiddenPowerStrength;
  final String? stats;
  final Gen4SearchResultSource? source;

  Map<String, dynamic> toJson() {
    return {
      'target': target,
      'method': method,
      'seed': seed,
      'delay': delay,
      'advance': advance,
      'year': year,
      'hour': hour,
      'second': second,
      'ivs': ivs,
      'shiny': shiny,
      'pid': pid,
      'level': level,
      'encounterSlot': encounterSlot,
      'abilitySlot': abilitySlot,
      'abilityName': abilityName,
      'gender': gender?.index,
      'natureId': natureId,
      'hiddenPowerType': hiddenPowerType,
      'hiddenPowerStrength': hiddenPowerStrength,
      'stats': stats,
      'source': source?.toJson(),
    };
  }
}

class Gen4SearchResultSource {
  const Gen4SearchResultSource({
    required this.kind,
    required this.game,
    required this.speciesId,
    required this.form,
    required this.method,
    required this.minLevel,
    required this.maxLevel,
    required this.genderRatio,
    required this.abilityIds,
    this.locationId,
    this.wildEncounter,
    this.wildTime,
    this.wildModifier,
    this.wildModifiers = const [],
    this.wildGame,
    this.lead,
    this.synchronizeNatureId,
    this.staticType,
    this.staticShinyPolicy,
    this.feebasTile = false,
    this.unownRadio = false,
  });

  factory Gen4SearchResultSource.fromJson(Map<String, dynamic> json) {
    return Gen4SearchResultSource(
      kind: json['kind'] as String,
      game: json['game'] as String,
      speciesId: json['speciesId'] as int,
      form: json['form'] as int,
      method: json['method'] as String,
      minLevel: json['minLevel'] as int,
      maxLevel: json['maxLevel'] as int,
      genderRatio: json['genderRatio'] as int,
      abilityIds: (json['abilityIds'] as List<dynamic>).cast<int>(),
      locationId: json['locationId'] as int?,
      wildEncounter: json['wildEncounter'] as String?,
      wildTime: json['wildTime'] as String?,
      wildModifier: json['wildModifier'] as String?,
      wildModifiers: (json['wildModifiers'] as List<dynamic>? ?? const [])
          .cast<String>(),
      wildGame: json['wildGame'] as String?,
      lead: json['lead'] as String?,
      synchronizeNatureId: json['synchronizeNatureId'] as int?,
      staticType: json['staticType'] as String?,
      staticShinyPolicy: json['staticShinyPolicy'] as String?,
      feebasTile: json['feebasTile'] as bool? ?? false,
      unownRadio: json['unownRadio'] as bool? ?? false,
    );
  }

  final String kind;
  final String game;
  final int speciesId;
  final int form;
  final String method;
  final int minLevel;
  final int maxLevel;
  final int genderRatio;
  final List<int> abilityIds;
  final int? locationId;
  final String? wildEncounter;
  final String? wildTime;
  final String? wildModifier;
  final List<String> wildModifiers;
  final String? wildGame;
  final String? lead;
  final int? synchronizeNatureId;
  final String? staticType;
  final String? staticShinyPolicy;
  final bool feebasTile;
  final bool unownRadio;

  bool get isWild => kind == 'wild';

  bool get isStatic => kind == 'static';

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'game': game,
      'speciesId': speciesId,
      'form': form,
      'method': method,
      'minLevel': minLevel,
      'maxLevel': maxLevel,
      'genderRatio': genderRatio,
      'abilityIds': abilityIds,
      'locationId': locationId,
      'wildEncounter': wildEncounter,
      'wildTime': wildTime,
      'wildModifier': wildModifier,
      'wildModifiers': wildModifiers,
      'wildGame': wildGame,
      'lead': lead,
      'synchronizeNatureId': synchronizeNatureId,
      'staticType': staticType,
      'staticShinyPolicy': staticShinyPolicy,
      'feebasTile': feebasTile,
      'unownRadio': unownRadio,
    };
  }
}

class Gen4SearchResultsSnapshot {
  const Gen4SearchResultsSnapshot({
    required this.state,
    required this.results,
    this.progress,
    this.error,
    this.resultLimitReached = false,
  });

  const Gen4SearchResultsSnapshot.idle()
    : state = Gen4SearchRunState.idle,
      results = const [],
      progress = null,
      error = null,
      resultLimitReached = false;

  const Gen4SearchResultsSnapshot.running({required this.progress})
    : state = Gen4SearchRunState.running,
      results = const [],
      error = null,
      resultLimitReached = false;

  const Gen4SearchResultsSnapshot.completed({
    required this.results,
    required this.progress,
    this.resultLimitReached = false,
  }) : state = Gen4SearchRunState.completed,
       error = null;

  const Gen4SearchResultsSnapshot.failed({required this.error, this.progress})
    : state = Gen4SearchRunState.failed,
      results = const [],
      resultLimitReached = false;

  final Gen4SearchRunState state;
  final List<Gen4SearchResultRow> results;
  final Gen4SearchProgress? progress;
  final String? error;
  final bool resultLimitReached;

  bool get isRunning => state == Gen4SearchRunState.running;

  bool get hasResults => results.isNotEmpty;

  Gen4SearchResultsSnapshot cancelled() {
    return Gen4SearchResultsSnapshot(
      state: Gen4SearchRunState.cancelled,
      results: results,
      progress: progress,
      resultLimitReached: resultLimitReached,
    );
  }
}

T? _enumOrNull<T>(List<T> values, Object? index) {
  if (index == null) {
    return null;
  }
  final value = index as int;
  if (value < 0 || value >= values.length) {
    return null;
  }
  return values[value];
}

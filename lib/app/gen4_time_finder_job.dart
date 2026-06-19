import 'dart:isolate';

import '../core/gen4/pokemon_attributes.dart';
import '../core/gen4/seed_time.dart';
import '../core/gen4/static_generator.dart';
import '../core/gen4/static_searcher.dart';
import '../core/gen4/stat_calculator.dart';
import '../core/gen4/wild_generator.dart';
import '../core/gen4/wild_searcher.dart';
import 'search_results.dart';

const gen4TimeFinderResultLimit = 1000;
const _gen4TimeFinderMaxReverseIvCombinations = 1000000;
const gen4TimeFinderMaxGenerationSearchStates = 4000000;

class Gen4TimeFinderRequest {
  const Gen4TimeFinderRequest({
    required this.year,
    required this.minDelay,
    required this.maxDelay,
    required this.minAdvance,
    required this.maxAdvance,
    required this.tid,
    required this.sid,
    required this.ivRanges,
    required this.sources,
    this.second,
    this.nature,
    this.abilitySlot,
    this.gender,
    this.shiny,
    this.hiddenPowerType,
    this.minHiddenPowerStrength,
    this.maxHiddenPowerStrength,
    this.encounterSlot,
    this.lead = Gen4WildLead.none,
    this.synchronizeNature = Nature.hardy,
    this.resultLimit = gen4TimeFinderResultLimit,
    this.maxGenerationSearchStates = gen4TimeFinderMaxGenerationSearchStates,
  });

  final int year;
  final int minDelay;
  final int maxDelay;
  final int minAdvance;
  final int maxAdvance;
  final int? second;
  final int tid;
  final int sid;
  final Gen4IvRanges ivRanges;
  final List<Gen4TimeFinderSourceRequest> sources;
  final Nature? nature;
  final int? abilitySlot;
  final PokemonGender? gender;
  final Shiny? shiny;
  final int? hiddenPowerType;
  final int? minHiddenPowerStrength;
  final int? maxHiddenPowerStrength;
  final int? encounterSlot;
  final Gen4WildLead lead;
  final Nature synchronizeNature;
  final int resultLimit;
  final int maxGenerationSearchStates;

  int get rawMinDelay => minDelay + year - 2000;

  int get rawMaxDelay => maxDelay + year - 2000;

  int get delayCount => maxDelay - minDelay + 1;

  int get advanceCount => maxAdvance - minAdvance + 1;

  int get totalProgressUnits {
    var count = 0;
    for (final source in sources) {
      count += _hourCount(source.allowedHours) * delayCount * advanceCount;
    }
    return count;
  }

  bool get canSearch {
    return sources.isNotEmpty &&
        year >= 2000 &&
        year <= 2099 &&
        minDelay >= 0 &&
        maxDelay >= minDelay &&
        rawMinDelay >= 0 &&
        rawMaxDelay <= 0xffff &&
        minAdvance >= 0 &&
        maxAdvance >= minAdvance &&
        (second == null || (second! >= 0 && second! <= 59)) &&
        resultLimit > 0 &&
        totalProgressUnits > 0 &&
        totalProgressUnits <= maxGenerationSearchStates;
  }
}

class Gen4TimeFinderSourceRequest {
  const Gen4TimeFinderSourceRequest.static({
    required this.game,
    required this.targetLabel,
    required this.methodLabel,
    required this.method,
    required this.staticType,
    required this.species,
    required this.level,
    required this.baseStats,
    required this.genderRatio,
    required this.abilityIds,
    required this.abilityNames,
    required this.allowedHours,
    this.form = 0,
    this.shinyPolicy = Gen4StaticShinyPolicy.random,
  }) : wildMethod = null,
       wildGame = null,
       wildArea = null,
       locationId = null,
       wildEncounter = null,
       wildTime = null,
       wildModifier = null,
       wildModifiers = const [],
       minLevel = level,
       maxLevel = level,
       feebasTile = false,
       unownRadio = false;

  const Gen4TimeFinderSourceRequest.wild({
    required this.game,
    required this.targetLabel,
    required this.methodLabel,
    required this.wildMethod,
    required this.wildGame,
    required this.wildArea,
    required this.locationId,
    required this.wildEncounter,
    required this.wildTime,
    required this.wildModifier,
    this.wildModifiers = const [],
    required this.species,
    required this.minLevel,
    required this.maxLevel,
    required this.baseStats,
    required this.genderRatio,
    required this.abilityIds,
    required this.abilityNames,
    required this.allowedHours,
    this.form = 0,
    this.feebasTile = false,
    this.unownRadio = false,
  }) : method = null,
       staticType = null,
       level = maxLevel,
       shinyPolicy = Gen4StaticShinyPolicy.random;

  final String game;
  final String targetLabel;
  final String methodLabel;
  final Gen4StaticMethod? method;
  final String? staticType;
  final Gen4WildMethod? wildMethod;
  final Gen4WildGame? wildGame;
  final Gen4WildArea? wildArea;
  final int? locationId;
  final String? wildEncounter;
  final String? wildTime;
  final String? wildModifier;
  final List<String> wildModifiers;
  final int? species;
  final int minLevel;
  final int maxLevel;
  final int level;
  final PokemonStats baseStats;
  final int genderRatio;
  final List<int> abilityIds;
  final List<String> abilityNames;
  final int form;
  final Set<int> allowedHours;
  final Gen4StaticShinyPolicy shinyPolicy;
  final bool feebasTile;
  final bool unownRadio;

  bool get isStatic => method != null;

  bool get isWild => wildMethod != null;
}

class Gen4TimeFinderSearchResult {
  const Gen4TimeFinderSearchResult({
    required this.results,
    required this.progress,
    required this.resultLimitReached,
  });

  final List<Gen4SearchResultRow> results;
  final Gen4SearchProgress progress;
  final bool resultLimitReached;
}

class Gen4TimeFinderJob {
  Gen4TimeFinderJob._({
    required ReceivePort receivePort,
    required void Function(Gen4SearchProgress progress) onProgress,
    required void Function(Gen4TimeFinderSearchResult result) onComplete,
    required void Function(String error) onError,
  }) : _receivePort = receivePort,
       _onProgress = onProgress,
       _onComplete = onComplete,
       _onError = onError;

  final ReceivePort _receivePort;
  final void Function(Gen4SearchProgress progress) _onProgress;
  final void Function(Gen4TimeFinderSearchResult result) _onComplete;
  final void Function(String error) _onError;
  Isolate? _isolate;
  bool _cancelled = false;

  static Gen4TimeFinderJob start({
    required Gen4TimeFinderRequest request,
    required void Function(Gen4SearchProgress progress) onProgress,
    required void Function(Gen4TimeFinderSearchResult result) onComplete,
    required void Function(String error) onError,
  }) {
    final receivePort = ReceivePort();
    final job = Gen4TimeFinderJob._(
      receivePort: receivePort,
      onProgress: onProgress,
      onComplete: onComplete,
      onError: onError,
    );
    job._listen();
    Isolate.spawn(
          _runGen4TimeFinderSearch,
          _Gen4TimeFinderIsolateMessage(
            sendPort: receivePort.sendPort,
            request: request,
          ),
        )
        .then((isolate) {
          if (job._cancelled) {
            isolate.kill(priority: Isolate.immediate);
          } else {
            job._isolate = isolate;
          }
        })
        .catchError((Object error) {
          if (!job._cancelled) {
            job._finish();
            onError(error.toString());
          }
        });
    return job;
  }

  static Gen4TimeFinderSearchResult searchSync(
    Gen4TimeFinderRequest request, {
    void Function(Gen4SearchProgress progress)? onProgress,
  }) {
    return _searchGen4TimeFinder(request, onProgress: onProgress);
  }

  void cancel() {
    _cancelled = true;
    _isolate?.kill(priority: Isolate.immediate);
    _finish();
  }

  void _listen() {
    _receivePort.listen((message) {
      if (_cancelled) {
        return;
      }
      switch (message) {
        case Gen4SearchProgress():
          _onProgress(message);
        case Gen4TimeFinderSearchResult():
          _finish();
          _onComplete(message);
        case _Gen4TimeFinderFailure():
          _finish();
          _onError(message.error);
      }
    });
  }

  void _finish() {
    _receivePort.close();
    _isolate = null;
  }
}

class _Gen4TimeFinderIsolateMessage {
  const _Gen4TimeFinderIsolateMessage({
    required this.sendPort,
    required this.request,
  });

  final SendPort sendPort;
  final Gen4TimeFinderRequest request;
}

class _Gen4TimeFinderFailure {
  const _Gen4TimeFinderFailure(this.error);

  final String error;
}

void _runGen4TimeFinderSearch(_Gen4TimeFinderIsolateMessage message) {
  try {
    final result = _searchGen4TimeFinder(
      message.request,
      onProgress: message.sendPort.send,
    );
    message.sendPort.send(result);
  } catch (error) {
    message.sendPort.send(_Gen4TimeFinderFailure(error.toString()));
  }
}

Gen4TimeFinderSearchResult _searchGen4TimeFinder(
  Gen4TimeFinderRequest request, {
  void Function(Gen4SearchProgress progress)? onProgress,
}) {
  if (!request.canSearch) {
    throw ArgumentError('invalid or too broad Time Finder request');
  }
  if (request.ivRanges.combinationCount <=
      _gen4TimeFinderMaxReverseIvCombinations) {
    return _searchGen4TimeFinderByIvs(request, onProgress: onProgress);
  }
  return _searchGen4TimeFinderByGeneration(request, onProgress: onProgress);
}

Gen4TimeFinderSearchResult _searchGen4TimeFinderByGeneration(
  Gen4TimeFinderRequest request, {
  void Function(Gen4SearchProgress progress)? onProgress,
}) {
  final results = <Gen4SearchResultRow>[];
  final total = request.totalProgressUnits;
  var scanned = 0;
  final progressStep = _progressStep(total);
  var nextProgress = progressStep;
  var resultLimitReached = false;
  onProgress?.call(Gen4SearchProgress(scanned: scanned, total: total));

  for (final source in request.sources) {
    for (final hour in _effectiveAllowedHours(source.allowedHours)) {
      for (
        var rawDelay = request.rawMinDelay;
        rawDelay <= request.rawMaxDelay;
        rawDelay += 1
      ) {
        final seed = (hour << 16) | rawDelay;
        final remaining = request.resultLimit - results.length;
        if (remaining <= 0) {
          resultLimitReached = true;
          break;
        }

        if (_matchesSecond(request, seed)) {
          final rows = source.isStatic
              ? _generateStaticSeed(request, source, seed)
              : _generateWildSeed(request, source, seed);
          results.addAll(rows.take(remaining));
        }

        scanned += request.advanceCount;
        if (scanned == request.advanceCount ||
            scanned >= nextProgress ||
            scanned >= total) {
          onProgress?.call(Gen4SearchProgress(scanned: scanned, total: total));
          while (nextProgress <= scanned) {
            nextProgress += progressStep;
          }
        }
        if (results.length >= request.resultLimit) {
          resultLimitReached = true;
          break;
        }
      }
      if (resultLimitReached) {
        break;
      }
    }
    if (resultLimitReached) {
      break;
    }
  }

  results.sort(_compareRows);
  if (results.length > request.resultLimit) {
    results.removeRange(request.resultLimit, results.length);
    resultLimitReached = true;
  }
  return Gen4TimeFinderSearchResult(
    results: List.unmodifiable(results),
    progress: Gen4SearchProgress(scanned: scanned, total: total),
    resultLimitReached: resultLimitReached,
  );
}

Gen4TimeFinderSearchResult _searchGen4TimeFinderByIvs(
  Gen4TimeFinderRequest request, {
  void Function(Gen4SearchProgress progress)? onProgress,
}) {
  final results = <Gen4SearchResultRow>[];
  final total = request.sources.length * request.ivRanges.combinationCount;
  var scanned = 0;
  final progressStep = _progressStep(total);
  var nextProgress = progressStep;
  var resultLimitReached = false;
  onProgress?.call(Gen4SearchProgress(scanned: scanned, total: total));

  for (final source in request.sources) {
    for (final ivs in request.ivRanges.enumerate(
      maxCombinations: _gen4TimeFinderMaxReverseIvCombinations,
    )) {
      final remaining = request.resultLimit - results.length;
      if (remaining <= 0) {
        resultLimitReached = true;
        break;
      }
      if (source.isStatic) {
        results.addAll(_searchStaticIvs(request, source, ivs, remaining));
      } else if (source.isWild) {
        results.addAll(_searchWildIvs(request, source, ivs, remaining));
      }
      scanned += 1;
      if (scanned == 1 || scanned >= nextProgress || scanned == total) {
        onProgress?.call(Gen4SearchProgress(scanned: scanned, total: total));
        while (nextProgress <= scanned) {
          nextProgress += progressStep;
        }
      }
      if (results.length >= request.resultLimit) {
        resultLimitReached = true;
        break;
      }
    }
    if (resultLimitReached) {
      break;
    }
  }

  results.sort(_compareRows);
  if (results.length > request.resultLimit) {
    results.removeRange(request.resultLimit, results.length);
    resultLimitReached = true;
  }
  return Gen4TimeFinderSearchResult(
    results: List.unmodifiable(results),
    progress: Gen4SearchProgress(scanned: scanned, total: total),
    resultLimitReached: resultLimitReached,
  );
}

List<Gen4SearchResultRow> _searchStaticIvs(
  Gen4TimeFinderRequest request,
  Gen4TimeFinderSourceRequest source,
  Ivs ivs,
  int remaining,
) {
  final searcher = Gen4StaticSearcher(
    minAdvance: request.minAdvance,
    maxAdvance: request.maxAdvance,
    minDelay: request.rawMinDelay,
    maxDelay: request.rawMaxDelay,
    level: source.level,
    tid: request.tid,
    sid: request.sid,
    genderRatio: source.genderRatio,
    allowedHours: source.allowedHours,
    maxResults: remaining,
  );
  final syncNature = _staticSynchronizeNature(request, source);
  final cuteCharmLead = _staticCuteCharmLead(request, source);
  final fixedGender = PokemonGenderRatio.isFixed(source.genderRatio);
  final results = switch (source.method!) {
    Gen4StaticMethod.method1 => searcher.searchMethod1(
      ivs,
      nature: request.nature,
      abilitySlot: request.abilitySlot,
      gender: request.gender,
      shiny: request.shiny,
      hiddenPowerType: request.hiddenPowerType,
      minHiddenPowerStrength: request.minHiddenPowerStrength,
      maxHiddenPowerStrength: request.maxHiddenPowerStrength,
    ),
    Gen4StaticMethod.methodJ => searcher.searchMethodJ(
      ivs,
      synchronizeNature: syncNature,
      cuteCharmLead: cuteCharmLead,
      fixedGender: fixedGender,
      nature: request.nature,
      abilitySlot: request.abilitySlot,
      gender: request.gender,
      shiny: request.shiny,
      hiddenPowerType: request.hiddenPowerType,
      minHiddenPowerStrength: request.minHiddenPowerStrength,
      maxHiddenPowerStrength: request.maxHiddenPowerStrength,
    ),
    Gen4StaticMethod.methodK => searcher.searchMethodK(
      ivs,
      synchronizeNature: syncNature,
      cuteCharmLead: cuteCharmLead,
      fixedGender: fixedGender,
      nature: request.nature,
      abilitySlot: request.abilitySlot,
      gender: request.gender,
      shiny: request.shiny,
      hiddenPowerType: request.hiddenPowerType,
      minHiddenPowerStrength: request.minHiddenPowerStrength,
      maxHiddenPowerStrength: request.maxHiddenPowerStrength,
    ),
  };
  return [
    for (final result in results)
      if (_matchesSecond(request, result.seed))
        _staticSearchedRow(request, source, result),
  ];
}

List<Gen4SearchResultRow> _searchWildIvs(
  Gen4TimeFinderRequest request,
  Gen4TimeFinderSourceRequest source,
  Ivs ivs,
  int remaining,
) {
  final area = source.wildArea!;
  final searcher = Gen4WildSearcher(
    minAdvance: request.minAdvance,
    maxAdvance: request.maxAdvance,
    minDelay: request.rawMinDelay,
    maxDelay: request.rawMaxDelay,
    game: source.wildGame!,
    area: area,
    tid: request.tid,
    sid: request.sid,
    feebasTile: source.feebasTile,
    unownRadio: source.unownRadio,
    allowedHours: source.allowedHours,
    maxResults: remaining,
    maxGenerationSearchStates: request.maxGenerationSearchStates,
  );
  final results = _searchWildByMethod(
    searcher: searcher,
    request: request,
    source: source,
    ivs: ivs,
  );
  return [
    for (final result in results)
      if (_matchesSecond(request, result.seed))
        _wildSearchedRow(request, source, result),
  ];
}

List<Gen4WildSearchResult> _searchWildByMethod({
  required Gen4WildSearcher searcher,
  required Gen4TimeFinderRequest request,
  required Gen4TimeFinderSourceRequest source,
  required Ivs ivs,
}) {
  final area = source.wildArea!;
  final grassLike =
      area.encounter.isGrass || area.encounter.isBugCatchingContest;
  final encounterSlot = request.encounterSlot;
  final lead = request.lead;
  final syncNature = lead.isSynchronize ? request.synchronizeNature : null;
  final form = source.form == 0 ? null : source.form;

  switch (source.wildMethod!) {
    case Gen4WildMethod.methodJ:
      if (grassLike) {
        return searcher.searchMethodJGrass(
          ivs,
          lead: lead,
          synchronizeNature: syncNature,
          encounterSlot: encounterSlot,
          nature: request.nature,
          abilitySlot: request.abilitySlot,
          gender: request.gender,
          shiny: request.shiny,
          hiddenPowerType: request.hiddenPowerType,
          minHiddenPowerStrength: request.minHiddenPowerStrength,
          maxHiddenPowerStrength: request.maxHiddenPowerStrength,
          species: source.species,
          minLevel: source.minLevel,
          maxLevel: source.maxLevel,
          form: form,
        );
      }
      return searcher.searchMethodJWild(
        ivs,
        lead: lead,
        encounterSlot: encounterSlot,
        nature: request.nature,
        abilitySlot: request.abilitySlot,
        gender: request.gender,
        shiny: request.shiny,
        hiddenPowerType: request.hiddenPowerType,
        minHiddenPowerStrength: request.minHiddenPowerStrength,
        maxHiddenPowerStrength: request.maxHiddenPowerStrength,
        species: source.species,
        minLevel: source.minLevel,
        maxLevel: source.maxLevel,
        form: form,
      );
    case Gen4WildMethod.methodK:
      if (grassLike) {
        return searcher.searchMethodKGrass(
          ivs,
          lead: lead,
          synchronizeNature: syncNature,
          encounterSlot: encounterSlot,
          nature: request.nature,
          abilitySlot: request.abilitySlot,
          gender: request.gender,
          shiny: request.shiny,
          hiddenPowerType: request.hiddenPowerType,
          minHiddenPowerStrength: request.minHiddenPowerStrength,
          maxHiddenPowerStrength: request.maxHiddenPowerStrength,
          species: source.species,
          minLevel: source.minLevel,
          maxLevel: source.maxLevel,
          form: form,
        );
      }
      return searcher.searchMethodKWild(
        ivs,
        lead: lead,
        encounterSlot: encounterSlot,
        nature: request.nature,
        abilitySlot: request.abilitySlot,
        gender: request.gender,
        shiny: request.shiny,
        hiddenPowerType: request.hiddenPowerType,
        minHiddenPowerStrength: request.minHiddenPowerStrength,
        maxHiddenPowerStrength: request.maxHiddenPowerStrength,
        species: source.species,
        minLevel: source.minLevel,
        maxLevel: source.maxLevel,
        form: form,
      );
    case Gen4WildMethod.honeyTree:
      return searcher.searchHoneyTree(
        ivs,
        encounterSlot: encounterSlot ?? 0,
        lead: lead,
        synchronizeNature: syncNature,
        nature: request.nature,
        abilitySlot: request.abilitySlot,
        gender: request.gender,
        shiny: request.shiny,
        hiddenPowerType: request.hiddenPowerType,
        minHiddenPowerStrength: request.minHiddenPowerStrength,
        maxHiddenPowerStrength: request.maxHiddenPowerStrength,
        species: source.species,
        minLevel: source.minLevel,
        maxLevel: source.maxLevel,
        form: form,
      );
    case Gen4WildMethod.pokeRadar:
      return searcher.searchPokeRadar(
        ivs,
        encounterSlot: encounterSlot ?? 0,
        lead: lead,
        synchronizeNature: syncNature,
        nature: request.nature,
        abilitySlot: request.abilitySlot,
        gender: request.gender,
        shiny: request.shiny,
        hiddenPowerType: request.hiddenPowerType,
        minHiddenPowerStrength: request.minHiddenPowerStrength,
        maxHiddenPowerStrength: request.maxHiddenPowerStrength,
        species: source.species,
        minLevel: source.minLevel,
        maxLevel: source.maxLevel,
        form: form,
      );
    case Gen4WildMethod.pokeRadarShiny:
      return searcher.searchPokeRadarShiny(
        ivs,
        encounterSlot: encounterSlot ?? 0,
        lead: lead,
        synchronizeNature: syncNature,
        nature: request.nature,
        abilitySlot: request.abilitySlot,
        gender: request.gender,
        shiny: request.shiny,
        hiddenPowerType: request.hiddenPowerType,
        minHiddenPowerStrength: request.minHiddenPowerStrength,
        maxHiddenPowerStrength: request.maxHiddenPowerStrength,
        species: source.species,
        minLevel: source.minLevel,
        maxLevel: source.maxLevel,
        form: form,
      );
  }
}

List<Gen4SearchResultRow> _generateStaticSeed(
  Gen4TimeFinderRequest request,
  Gen4TimeFinderSourceRequest source,
  int seed,
) {
  final generator = Gen4StaticGenerator(
    initialAdvances: request.minAdvance,
    maxAdvances: request.maxAdvance - request.minAdvance,
    offset: 0,
    method: source.method!,
    level: source.level,
    tid: request.tid,
    sid: request.sid,
    genderRatio: source.genderRatio,
    fixedGender: PokemonGenderRatio.isFixed(source.genderRatio),
    synchronizeNature: _staticSynchronizeNature(request, source),
    cuteCharmLead: _staticCuteCharmLead(request, source),
    shinyPolicy: source.shinyPolicy,
  );
  final rows = <Gen4SearchResultRow>[];
  for (final state in generator.generate(seed)) {
    if (_matchesStaticState(request, state)) {
      rows.add(_staticGeneratedRow(request, source, seed, state));
    }
  }
  return rows;
}

List<Gen4SearchResultRow> _generateWildSeed(
  Gen4TimeFinderRequest request,
  Gen4TimeFinderSourceRequest source,
  int seed,
) {
  final area = source.wildArea!;
  final grassLike =
      area.encounter.isGrass || area.encounter.isBugCatchingContest;
  final lead = _effectiveWildLead(
    requested: request.lead,
    method: source.wildMethod!,
    grassLike: grassLike,
  );
  final generator = Gen4WildGenerator(
    initialAdvances: request.minAdvance,
    maxAdvances: request.maxAdvance - request.minAdvance,
    offset: 0,
    method: source.wildMethod!,
    game: source.wildGame!,
    area: area,
    tid: request.tid,
    sid: request.sid,
    lead: lead,
    synchronizeNature: lead.isSynchronize ? request.synchronizeNature : null,
    encounterSlot: request.encounterSlot ?? 0,
    feebasTile: source.feebasTile,
    unownRadio: source.unownRadio,
  );
  final rows = <Gen4SearchResultRow>[];
  for (final state in generator.generate(seed)) {
    if (_matchesWildState(request, source, state)) {
      rows.add(_wildGeneratedRow(request, source, seed, state));
    }
  }
  return rows;
}

Gen4WildLead _effectiveWildLead({
  required Gen4WildLead requested,
  required Gen4WildMethod method,
  required bool grassLike,
}) {
  if (method == Gen4WildMethod.honeyTree) {
    return requested.supportsHoneyTree ? requested : Gen4WildLead.none;
  }
  if (method == Gen4WildMethod.pokeRadar ||
      method == Gen4WildMethod.pokeRadarShiny) {
    return requested.supportsPokeRadar ? requested : Gen4WildLead.none;
  }
  if (grassLike) {
    return requested.supportsGrassWildSearch ? requested : Gen4WildLead.none;
  }
  return requested.supportsBasicWildSearch ? requested : Gen4WildLead.none;
}

bool _matchesStaticState(Gen4TimeFinderRequest request, Gen4StaticState state) {
  return _matchesIvs(request.ivRanges, state.ivs) &&
      _matchesPokemonFilters(
        request,
        nature: state.nature,
        abilitySlot: state.abilitySlot,
        gender: state.gender,
        shiny: state.shiny,
        hiddenPowerType: state.hiddenPowerType,
        hiddenPowerStrength: state.hiddenPowerStrength,
      );
}

Nature? _staticSynchronizeNature(
  Gen4TimeFinderRequest request,
  Gen4TimeFinderSourceRequest source,
) {
  if (source.method == Gen4StaticMethod.method1 ||
      !request.lead.isSynchronize) {
    return null;
  }
  return request.synchronizeNature;
}

Gen4CuteCharmLead _staticCuteCharmLead(
  Gen4TimeFinderRequest request,
  Gen4TimeFinderSourceRequest source,
) {
  if (source.method == Gen4StaticMethod.method1 ||
      PokemonGenderRatio.isFixed(source.genderRatio)) {
    return Gen4CuteCharmLead.none;
  }
  return switch (request.lead) {
    Gen4WildLead.cuteCharmMale => Gen4CuteCharmLead.male,
    Gen4WildLead.cuteCharmFemale => Gen4CuteCharmLead.female,
    _ => Gen4CuteCharmLead.none,
  };
}

bool _matchesWildState(
  Gen4TimeFinderRequest request,
  Gen4TimeFinderSourceRequest source,
  Gen4WildState state,
) {
  final form = source.form == 0 ? null : source.form;
  return _matchesIvs(request.ivRanges, state.ivs) &&
      (request.encounterSlot == null ||
          state.encounterSlot == request.encounterSlot) &&
      (source.species == null || state.species == source.species) &&
      state.level >= source.minLevel &&
      state.level <= source.maxLevel &&
      (form == null || state.form == form) &&
      _matchesPokemonFilters(
        request,
        nature: state.nature,
        abilitySlot: state.abilitySlot,
        gender: state.gender,
        shiny: state.shiny,
        hiddenPowerType: state.hiddenPowerType,
        hiddenPowerStrength: state.hiddenPowerStrength,
      );
}

bool _matchesIvs(Gen4IvRanges ranges, Ivs ivs) {
  final values = ivs.ordered;
  final orderedRanges = ranges.ordered;
  for (var index = 0; index < orderedRanges.length; index += 1) {
    final range = orderedRanges[index];
    final value = values[index];
    if (value < range.min || value > range.max) {
      return false;
    }
  }
  return true;
}

bool _matchesPokemonFilters(
  Gen4TimeFinderRequest request, {
  required Nature nature,
  required int abilitySlot,
  required PokemonGender gender,
  required Shiny shiny,
  required int hiddenPowerType,
  required int hiddenPowerStrength,
}) {
  if (request.nature != null && nature != request.nature) {
    return false;
  }
  return Gen4PokemonSearchFilter(
    abilitySlot: request.abilitySlot,
    gender: request.gender,
    shiny: request.shiny,
    hiddenPower: Gen4HiddenPowerFilter(
      type: request.hiddenPowerType,
      minStrength: request.minHiddenPowerStrength,
      maxStrength: request.maxHiddenPowerStrength,
    ),
  ).matches(
    abilitySlot: abilitySlot,
    gender: gender,
    shiny: shiny,
    hiddenPowerType: hiddenPowerType,
    hiddenPowerStrength: hiddenPowerStrength,
  );
}

Gen4SearchResultRow _staticGeneratedRow(
  Gen4TimeFinderRequest request,
  Gen4TimeFinderSourceRequest source,
  int seed,
  Gen4StaticState state,
) {
  final info = Gen4SeedTime.seedInfo(seed: seed, year: request.year);
  return Gen4SearchResultRow(
    target: source.targetLabel,
    method: source.methodLabel,
    seed: _seedHex(seed),
    delay: info.delay,
    advance: state.advance,
    year: request.year,
    hour: info.hour,
    second: request.second,
    ivs: state.ivs.toString(),
    shiny: state.shiny.isShiny,
    pid: state.pid.hex,
    level: state.level,
    abilitySlot: state.abilitySlot,
    abilityName: _abilityName(source, state.abilitySlot),
    gender: state.gender,
    natureId: state.nature.index,
    hiddenPowerType: state.hiddenPowerType,
    hiddenPowerStrength: state.hiddenPowerStrength,
    stats: _statsValue(
      baseStats: source.baseStats,
      ivs: state.ivs,
      nature: state.nature,
      level: state.level,
    ),
    source: _sourceInfo(request, source, kind: 'static'),
  );
}

Gen4SearchResultRow _wildGeneratedRow(
  Gen4TimeFinderRequest request,
  Gen4TimeFinderSourceRequest source,
  int seed,
  Gen4WildState state,
) {
  final info = Gen4SeedTime.seedInfo(seed: seed, year: request.year);
  return Gen4SearchResultRow(
    target: source.targetLabel,
    method: source.methodLabel,
    seed: _seedHex(seed),
    delay: info.delay,
    advance: state.advance,
    year: request.year,
    hour: info.hour,
    second: request.second,
    ivs: state.ivs.toString(),
    shiny: state.shiny.isShiny,
    pid: state.pid.hex,
    level: state.level,
    encounterSlot: state.encounterSlot,
    abilitySlot: state.abilitySlot,
    abilityName: _abilityName(source, state.abilitySlot),
    gender: state.gender,
    natureId: state.nature.index,
    hiddenPowerType: state.hiddenPowerType,
    hiddenPowerStrength: state.hiddenPowerStrength,
    stats: _statsValue(
      baseStats: source.baseStats,
      ivs: state.ivs,
      nature: state.nature,
      level: state.level,
    ),
    source: _sourceInfo(request, source, kind: 'wild'),
  );
}

Gen4SearchResultRow _staticSearchedRow(
  Gen4TimeFinderRequest request,
  Gen4TimeFinderSourceRequest source,
  Gen4StaticSearchResult result,
) {
  return _staticGeneratedRow(request, source, result.seed, result.state);
}

Gen4SearchResultRow _wildSearchedRow(
  Gen4TimeFinderRequest request,
  Gen4TimeFinderSourceRequest source,
  Gen4WildSearchResult result,
) {
  return _wildGeneratedRow(request, source, result.seed, result.state);
}

String? _abilityName(Gen4TimeFinderSourceRequest source, int abilitySlot) {
  if (abilitySlot < 0 || abilitySlot >= source.abilityNames.length) {
    return null;
  }
  return source.abilityNames[abilitySlot];
}

Gen4SearchResultSource _sourceInfo(
  Gen4TimeFinderRequest request,
  Gen4TimeFinderSourceRequest source, {
  required String kind,
}) {
  return Gen4SearchResultSource(
    kind: kind,
    game: source.game,
    speciesId: source.species ?? 0,
    form: source.form,
    method: source.isWild ? source.wildMethod!.name : source.method!.name,
    minLevel: source.minLevel,
    maxLevel: source.maxLevel,
    genderRatio: source.genderRatio,
    abilityIds: List.unmodifiable(source.abilityIds),
    locationId: source.locationId,
    wildEncounter: source.wildEncounter,
    wildTime: source.wildTime,
    wildModifier: source.wildModifier,
    wildModifiers: List.unmodifiable(source.wildModifiers),
    wildGame: source.wildGame?.name,
    lead: request.lead.name,
    synchronizeNatureId: request.synchronizeNature.index,
    staticType: source.staticType,
    staticShinyPolicy: source.shinyPolicy.name,
    feebasTile: source.feebasTile,
    unownRadio: source.unownRadio,
  );
}

String _statsValue({
  required PokemonStats baseStats,
  required Ivs ivs,
  required Nature nature,
  required int level,
}) {
  return Gen4StatCalculator.calculateDisplayStats(
    baseStats: baseStats,
    ivs: ivs,
    nature: nature,
    level: level,
  ).toString();
}

bool _matchesSecond(Gen4TimeFinderRequest request, int seed) {
  final second = request.second;
  if (second == null) {
    return true;
  }
  return Gen4SeedTime.calculateTimes(
    seed: seed,
    year: request.year,
    forceSecond: true,
    forcedSecond: second,
  ).isNotEmpty;
}

Iterable<int> _effectiveAllowedHours(Set<int> allowedHours) sync* {
  final hours = allowedHours.isEmpty
      ? List<int>.generate(24, (index) => index)
      : allowedHours.where((hour) => hour >= 0 && hour < 24).toList();
  hours.sort();
  for (final hour in hours) {
    yield hour;
  }
}

int _hourCount(Set<int> allowedHours) {
  return allowedHours.isEmpty
      ? 24
      : allowedHours.where((hour) => hour >= 0 && hour < 24).length;
}

String _seedHex(int seed) {
  return seed.toRadixString(16).padLeft(8, '0').toUpperCase();
}

int _progressStep(int total) {
  if (total <= 100) {
    return 1;
  }
  return (total / 100).ceil();
}

int _compareRows(Gen4SearchResultRow left, Gen4SearchResultRow right) {
  final advanceCompare = left.advance.compareTo(right.advance);
  if (advanceCompare != 0) {
    return advanceCompare;
  }
  final delayCompare = left.delay.compareTo(right.delay);
  if (delayCompare != 0) {
    return delayCompare;
  }
  final hourCompare = left.hour.compareTo(right.hour);
  if (hourCompare != 0) {
    return hourCompare;
  }
  final seedCompare = left.seed.compareTo(right.seed);
  if (seedCompare != 0) {
    return seedCompare;
  }
  return left.target.compareTo(right.target);
}

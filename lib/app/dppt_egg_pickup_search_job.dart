import 'dart:isolate';

import '../core/gen4/gen4.dart';
import 'search_results.dart';

const gen4DpptEggPickupMaxSearchStates = 4000000;

class DpptEggPickupSearchRequest {
  const DpptEggPickupSearchRequest({
    this.seed,
    this.year,
    this.minDelay,
    this.maxDelay,
    required this.heldAdvance,
    required this.heldPid,
    required this.heldAbilitySlot,
    required this.heldGender,
    required this.heldNature,
    required this.heldShiny,
    required this.parentIvs,
    required this.genderRatio,
    required this.masuda,
    required this.tid,
    required this.sid,
    required this.minAdvance,
    required this.maxAdvance,
    required this.minIvs,
    this.exactIvs,
    this.ivOptions,
    this.characteristic,
    this.resultLimit = 100,
  });

  final int? seed;
  final int? year;
  final int? minDelay;
  final int? maxDelay;
  final int heldAdvance;
  final int heldPid;
  final int heldAbilitySlot;
  final PokemonGender heldGender;
  final Nature heldNature;
  final Shiny heldShiny;
  final List<List<int>> parentIvs;
  final int genderRatio;
  final bool masuda;
  final int tid;
  final int sid;
  final int minAdvance;
  final int maxAdvance;
  final List<int?> minIvs;
  final List<int>? exactIvs;
  final List<List<int>>? ivOptions;
  final int? characteristic;
  final int resultLimit;

  int get advanceCount => maxAdvance - minAdvance + 1;

  int get rawMinDelay => minDelay! + year! - 2000;

  int get rawMaxDelay => maxDelay! + year! - 2000;

  int get delayCount => maxDelay! - minDelay! + 1;

  int get seedCount => seed == null ? 24 * delayCount : 1;

  int get totalSearchStates => seedCount * advanceCount;

  bool get canSearch {
    final hasSeed = seed != null && seed! >= 0 && seed! <= 0xffffffff;
    final hasTimeRange =
        seed == null &&
        year != null &&
        year! >= 2000 &&
        year! <= 2099 &&
        minDelay != null &&
        maxDelay != null &&
        minDelay! >= 0 &&
        maxDelay! >= minDelay! &&
        rawMinDelay >= 0 &&
        rawMaxDelay <= 0xffff;
    return (hasSeed || hasTimeRange) &&
        heldAdvance >= 0 &&
        heldPid >= 0 &&
        heldPid <= 0xffffffff &&
        heldAbilitySlot >= 0 &&
        heldAbilitySlot <= 1 &&
        parentIvs.length == 2 &&
        parentIvs.every(
          (ivs) => ivs.length == 6 && ivs.every((iv) => iv >= 0 && iv <= 31),
        ) &&
        genderRatio >= 0 &&
        genderRatio <= 255 &&
        tid >= 0 &&
        tid <= 0xffff &&
        sid >= 0 &&
        sid <= 0xffff &&
        minAdvance >= 0 &&
        maxAdvance >= minAdvance &&
        minIvs.length == 6 &&
        minIvs.every((iv) => iv == null || (iv >= 0 && iv <= 31)) &&
        (exactIvs == null ||
            exactIvs!.length == 6 &&
                exactIvs!.every((iv) => iv >= 0 && iv <= 31)) &&
        (ivOptions == null ||
            ivOptions!.length == 6 &&
                ivOptions!.every(
                  (options) =>
                      options.isNotEmpty &&
                      options.every((iv) => iv >= 0 && iv <= 31),
                )) &&
        (characteristic == null ||
            characteristic! >= 0 && characteristic! < 30) &&
        resultLimit > 0 &&
        totalSearchStates > 0 &&
        totalSearchStates <= gen4DpptEggPickupMaxSearchStates;
  }
}

class DpptEggPickupSearchResult {
  const DpptEggPickupSearchResult({
    required this.seed,
    required this.hour,
    required this.rawDelay,
    required this.prng,
    required this.prngSeed,
    required this.advance,
    required this.pickupAdvance,
    required this.pid,
    required this.ivs,
    required this.inheritance,
    required this.abilitySlot,
    required this.gender,
    required this.nature,
    required this.shiny,
  });

  final int seed;
  final int hour;
  final int rawDelay;
  final int prng;
  final int prngSeed;
  final int advance;
  final int pickupAdvance;
  final int pid;
  final List<int> ivs;
  final List<int> inheritance;
  final int abilitySlot;
  final PokemonGender gender;
  final Nature nature;
  final Shiny shiny;

  String get seedHex => Gen4SearchResultUtils.seedHex(seed);

  Ivs get ivValues {
    return Ivs(
      hp: ivs[0],
      attack: ivs[1],
      defense: ivs[2],
      specialAttack: ivs[3],
      specialDefense: ivs[4],
      speed: ivs[5],
    );
  }

  int get hiddenPowerType => ivValues.hiddenPowerType;
  int get hiddenPowerStrength => ivValues.hiddenPowerStrength;

  Gen4EggSearchResult toSearchResult() {
    return Gen4EggSearchResult(
      seed: seed,
      hour: hour,
      delay: rawDelay,
      state: Gen4EggState(
        prng: prng,
        prngSeed: prngSeed,
        advance: advance,
        pickupAdvance: pickupAdvance,
        pid: PokemonPid(pid),
        ivs: ivValues,
        inheritance: inheritance,
        abilitySlot: abilitySlot,
        gender: gender,
        nature: nature,
        shiny: shiny,
      ),
    );
  }
}

class DpptEggPickupSearchResponse {
  const DpptEggPickupSearchResponse({
    required this.results,
    required this.progress,
    required this.resultLimitReached,
  });

  final List<DpptEggPickupSearchResult> results;
  final Gen4SearchProgress progress;
  final bool resultLimitReached;
}

class DpptEggPickupSearchJob {
  DpptEggPickupSearchJob._({
    required ReceivePort receivePort,
    required void Function(Gen4SearchProgress progress) onProgress,
    required void Function(DpptEggPickupSearchResponse result) onComplete,
    required void Function(String error) onError,
  }) : _receivePort = receivePort,
       _onProgress = onProgress,
       _onComplete = onComplete,
       _onError = onError;

  final ReceivePort _receivePort;
  final void Function(Gen4SearchProgress progress) _onProgress;
  final void Function(DpptEggPickupSearchResponse result) _onComplete;
  final void Function(String error) _onError;
  Isolate? _isolate;
  bool _cancelled = false;

  static Future<DpptEggPickupSearchJob> start({
    required DpptEggPickupSearchRequest request,
    required void Function(Gen4SearchProgress progress) onProgress,
    required void Function(DpptEggPickupSearchResponse result) onComplete,
    required void Function(String error) onError,
  }) async {
    final receivePort = ReceivePort();
    final job = DpptEggPickupSearchJob._(
      receivePort: receivePort,
      onProgress: onProgress,
      onComplete: onComplete,
      onError: onError,
    );
    job._isolate = await Isolate.spawn(
      _runDpptEggPickupSearch,
      _DpptEggPickupSearchMessage(
        sendPort: receivePort.sendPort,
        request: request,
      ),
    );
    job._listen();
    return job;
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
        case DpptEggPickupSearchResponse():
          _finish();
          _onComplete(message);
        case _DpptEggPickupSearchFailure():
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

class _DpptEggPickupSearchMessage {
  const _DpptEggPickupSearchMessage({
    required this.sendPort,
    required this.request,
  });

  final SendPort sendPort;
  final DpptEggPickupSearchRequest request;
}

class _DpptEggPickupSearchFailure {
  const _DpptEggPickupSearchFailure(this.error);

  final String error;
}

void _runDpptEggPickupSearch(_DpptEggPickupSearchMessage message) {
  try {
    message.sendPort.send(
      searchDpptEggPickupsSync(
        message.request,
        onProgress: message.sendPort.send,
      ),
    );
  } catch (error) {
    message.sendPort.send(_DpptEggPickupSearchFailure(error.toString()));
  }
}

DpptEggPickupSearchResponse searchDpptEggPickupsSync(
  DpptEggPickupSearchRequest request, {
  void Function(Gen4SearchProgress progress)? onProgress,
}) {
  if (!request.canSearch) {
    throw ArgumentError('invalid egg pickup search request');
  }

  final heldState = Gen4EggHeldState(
    advance: request.heldAdvance,
    pid: PokemonPid(request.heldPid),
    abilitySlot: request.heldAbilitySlot,
    gender: request.heldGender,
    nature: request.heldNature,
    shiny: request.heldShiny,
  );
  final results = <DpptEggPickupSearchResult>[];
  final total = request.totalSearchStates;
  var scanned = 0;
  final progressStep = _progressStep(total);
  var nextProgress = progressStep;
  var resultLimitReached = false;
  onProgress?.call(Gen4SearchProgress(scanned: scanned, total: total));

  void searchSeed(int seed, int displayDelay) {
    if (results.length >= request.resultLimit) {
      resultLimitReached = true;
      return;
    }
    final generator = Gen4EggGenerator(
      initialAdvances: request.heldAdvance,
      maxAdvances: 0,
      offset: 0,
      initialPickupAdvances: request.minAdvance,
      maxPickupAdvances: request.maxAdvance - request.minAdvance,
      pickupOffset: 0,
      daycare: Gen4Daycare(
        parentIvs: request.parentIvs,
        eggGenderRatio: request.genderRatio,
        masuda: request.masuda,
      ),
      game: Gen4EggGame.diamondPearlPlatinum,
      tid: request.tid,
      sid: request.sid,
    );
    final states = generator.generatePickup(seed, [heldState]);
    for (final state in states) {
      if (_matchesIvs(
            state.ivs,
            minIvs: request.minIvs,
            exactIvs: request.exactIvs,
            ivOptions: request.ivOptions,
          ) &&
          (request.characteristic == null ||
              state.characteristic == request.characteristic)) {
        results.add(_resultFromState(seed, state, displayDelay: displayDelay));
        if (results.length >= request.resultLimit) {
          resultLimitReached = true;
          break;
        }
      }
    }
  }

  void reportProgress() {
    if (scanned == request.advanceCount ||
        scanned >= nextProgress ||
        scanned >= total) {
      onProgress?.call(Gen4SearchProgress(scanned: scanned, total: total));
      while (nextProgress <= scanned) {
        nextProgress += progressStep;
      }
    }
  }

  final singleSeed = request.seed;
  if (singleSeed != null) {
    searchSeed(singleSeed, singleSeed & 0xffff);
    scanned += request.advanceCount;
    reportProgress();
  } else {
    for (var hour = 0; hour < 24; hour += 1) {
      for (
        var rawDelay = request.rawMinDelay;
        rawDelay <= request.rawMaxDelay;
        rawDelay += 1
      ) {
        if (resultLimitReached) {
          break;
        }
        final seed = (hour << 16) | rawDelay;
        final displayDelay = rawDelay + 2000 - request.year!;
        searchSeed(seed, displayDelay);
        scanned += request.advanceCount;
        reportProgress();
      }
      if (resultLimitReached) {
        break;
      }
    }
  }

  return DpptEggPickupSearchResponse(
    results: List.unmodifiable(results),
    progress: Gen4SearchProgress(scanned: scanned, total: total),
    resultLimitReached: resultLimitReached,
  );
}

DpptEggPickupSearchResult _resultFromState(
  int seed,
  Gen4EggState state, {
  int? displayDelay,
}) {
  return DpptEggPickupSearchResult(
    seed: seed,
    hour: (seed >>> 16) & 0xff,
    rawDelay: displayDelay ?? (seed & 0xffff),
    prng: state.prng,
    prngSeed: state.prngSeed,
    advance: state.advance,
    pickupAdvance: state.pickupAdvance,
    pid: state.pid.value,
    ivs: state.ivs.ordered,
    inheritance: state.inheritance,
    abilitySlot: state.abilitySlot,
    gender: state.gender,
    nature: state.nature,
    shiny: state.shiny,
  );
}

bool _matchesIvs(
  Ivs ivs, {
  required List<int?> minIvs,
  List<int>? exactIvs,
  List<List<int>>? ivOptions,
}) {
  final values = ivs.ordered;
  if (exactIvs != null) {
    for (var i = 0; i < values.length; i += 1) {
      if (values[i] != exactIvs[i]) {
        return false;
      }
    }
  }
  if (ivOptions != null) {
    for (var i = 0; i < values.length; i += 1) {
      if (!ivOptions[i].contains(values[i])) {
        return false;
      }
    }
  }
  for (var i = 0; i < values.length; i += 1) {
    final min = minIvs[i];
    if (min != null && values[i] < min) {
      return false;
    }
  }
  return true;
}

int _progressStep(int total) {
  if (total <= 100) {
    return 1;
  }
  return (total / 100).ceil();
}

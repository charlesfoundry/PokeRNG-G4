import 'dart:isolate';

import '../core/gen4/gen4.dart';
import 'gen4_time_finder_job.dart';
import 'search_results.dart';

class EggPidSearchRequest {
  const EggPidSearchRequest({
    required this.year,
    required this.minDelay,
    required this.maxDelay,
    required this.tid,
    required this.sid,
    required this.genderRatio,
    required this.masuda,
    required this.minEggFrame,
    required this.maxEggFrame,
    this.nature,
    this.gender,
    this.abilitySlot,
    this.shiny,
    this.resultLimit = 100,
    this.maxSearchStates = gen4TimeFinderMaxGenerationSearchStates,
  });

  final int year;
  final int minDelay;
  final int maxDelay;
  final int tid;
  final int sid;
  final int genderRatio;
  final bool masuda;
  final int minEggFrame;
  final int maxEggFrame;
  final Nature? nature;
  final PokemonGender? gender;
  final int? abilitySlot;
  final Shiny? shiny;
  final int resultLimit;
  final int maxSearchStates;

  int get rawMinDelay => minDelay + year - 2000;

  int get rawMaxDelay => maxDelay + year - 2000;

  int get minAdvance => minEggFrame - 1;

  int get maxAdvance => maxEggFrame - 1;

  int get eggFrameCount => maxEggFrame - minEggFrame + 1;

  int get delayCount => maxDelay - minDelay + 1;

  int get totalSearchStates => delayCount * 256 * 24 * eggFrameCount;

  bool get canSearch {
    return year >= 2000 &&
        year <= 2099 &&
        minDelay >= 0 &&
        maxDelay >= minDelay &&
        rawMinDelay >= 0 &&
        rawMaxDelay <= 0xffff &&
        tid >= 0 &&
        tid <= 0xffff &&
        sid >= 0 &&
        sid <= 0xffff &&
        genderRatio >= 0 &&
        genderRatio <= 255 &&
        minEggFrame >= 1 &&
        maxEggFrame >= minEggFrame &&
        maxEggFrame <= 999 &&
        resultLimit > 0 &&
        totalSearchStates > 0 &&
        totalSearchStates <= maxSearchStates;
  }
}

class EggPidSearchResult {
  const EggPidSearchResult({
    required this.seed,
    required this.year,
    required this.hour,
    required this.rawDelay,
    required this.advance,
    required this.pid,
    required this.abilitySlot,
    required this.gender,
    required this.nature,
    required this.shiny,
  });

  final int seed;
  final int year;
  final int hour;
  final int rawDelay;
  final int advance;
  final int pid;
  final int abilitySlot;
  final PokemonGender gender;
  final Nature nature;
  final Shiny shiny;

  String get seedHex => Gen4SearchResultUtils.seedHex(seed);

  int get targetEggFrame => advance + 1;

  Gen4SeedTimeInfo get seedInfo {
    return Gen4SeedTime.seedInfo(seed: seed, year: year);
  }

  Gen4EggHeldSearchResult toHeldSearchResult() {
    return Gen4EggHeldSearchResult(
      seed: seed,
      hour: hour,
      delay: rawDelay,
      state: Gen4EggHeldState(
        advance: advance,
        pid: PokemonPid(pid),
        abilitySlot: abilitySlot,
        gender: gender,
        nature: nature,
        shiny: shiny,
      ),
    );
  }
}

class EggPidSearchResponse {
  const EggPidSearchResponse({
    required this.results,
    required this.progress,
    required this.resultLimitReached,
  });

  final List<EggPidSearchResult> results;
  final Gen4SearchProgress progress;
  final bool resultLimitReached;
}

class EggPidSearchJob {
  EggPidSearchJob._({
    required ReceivePort receivePort,
    required void Function(Gen4SearchProgress progress) onProgress,
    required void Function(EggPidSearchResponse result) onComplete,
    required void Function(String error) onError,
  }) : _receivePort = receivePort,
       _onProgress = onProgress,
       _onComplete = onComplete,
       _onError = onError;

  final ReceivePort _receivePort;
  final void Function(Gen4SearchProgress progress) _onProgress;
  final void Function(EggPidSearchResponse result) _onComplete;
  final void Function(String error) _onError;
  Isolate? _isolate;
  bool _cancelled = false;

  static Future<EggPidSearchJob> start({
    required EggPidSearchRequest request,
    required void Function(Gen4SearchProgress progress) onProgress,
    required void Function(EggPidSearchResponse result) onComplete,
    required void Function(String error) onError,
  }) async {
    final receivePort = ReceivePort();
    final job = EggPidSearchJob._(
      receivePort: receivePort,
      onProgress: onProgress,
      onComplete: onComplete,
      onError: onError,
    );
    job._isolate = await Isolate.spawn(
      _runEggPidSearch,
      _EggPidSearchMessage(sendPort: receivePort.sendPort, request: request),
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
        case EggPidSearchResponse():
          _finish();
          _onComplete(message);
        case _EggPidSearchFailure():
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

class _EggPidSearchMessage {
  const _EggPidSearchMessage({required this.sendPort, required this.request});

  final SendPort sendPort;
  final EggPidSearchRequest request;
}

class _EggPidSearchFailure {
  const _EggPidSearchFailure(this.error);

  final String error;
}

void _runEggPidSearch(_EggPidSearchMessage message) {
  try {
    message.sendPort.send(
      searchEggPidsSync(message.request, onProgress: message.sendPort.send),
    );
  } catch (error) {
    message.sendPort.send(_EggPidSearchFailure(error.toString()));
  }
}

EggPidSearchResponse searchEggPidsSync(
  EggPidSearchRequest request, {
  void Function(Gen4SearchProgress progress)? onProgress,
}) {
  if (!request.canSearch) {
    throw ArgumentError('invalid or too broad egg PID search request');
  }

  final generator = Gen4EggGenerator(
    initialAdvances: request.minAdvance,
    maxAdvances: request.maxAdvance - request.minAdvance,
    offset: 0,
    initialPickupAdvances: 0,
    maxPickupAdvances: 0,
    pickupOffset: 0,
    daycare: Gen4Daycare(
      parentIvs: const [
        [31, 31, 31, 31, 31, 31],
        [31, 31, 31, 31, 31, 31],
      ],
      eggGenderRatio: request.genderRatio,
      masuda: request.masuda,
    ),
    game: Gen4EggGame.heartGoldSoulSilver,
    tid: request.tid,
    sid: request.sid,
  );
  final results = <EggPidSearchResult>[];
  final total = request.totalSearchStates;
  var scanned = 0;
  final progressStep = _progressStep(total);
  var nextProgress = progressStep;
  var resultLimitReached = false;
  onProgress?.call(Gen4SearchProgress(scanned: scanned, total: total));

  search:
  for (var ab = 0; ab <= 0xff; ab += 1) {
    for (var hour = 0; hour < 24; hour += 1) {
      for (
        var rawDelay = request.rawMinDelay;
        rawDelay <= request.rawMaxDelay;
        rawDelay += 1
      ) {
        final seed = (ab << 24) | (hour << 16) | rawDelay;
        for (final state in generator.generateHeld(seed)) {
          if (results.length >= request.resultLimit) {
            resultLimitReached = true;
            break search;
          }
          if (_matches(request, state)) {
            results.add(
              EggPidSearchResult(
                seed: seed,
                year: request.year,
                hour: hour,
                rawDelay: rawDelay,
                advance: state.advance,
                pid: state.pid.value,
                abilitySlot: state.abilitySlot,
                gender: state.gender,
                nature: state.nature,
                shiny: state.shiny,
              ),
            );
          }

          scanned += 1;
          if (scanned == 1 || scanned >= nextProgress || scanned >= total) {
            onProgress?.call(
              Gen4SearchProgress(scanned: scanned, total: total),
            );
            while (nextProgress <= scanned) {
              nextProgress += progressStep;
            }
          }
        }
      }
    }
  }

  return EggPidSearchResponse(
    results: List.unmodifiable(results),
    progress: Gen4SearchProgress(scanned: scanned, total: total),
    resultLimitReached: resultLimitReached,
  );
}

bool _matches(EggPidSearchRequest request, Gen4EggHeldState state) {
  final nature = request.nature;
  final gender = request.gender;
  final abilitySlot = request.abilitySlot;
  final shiny = request.shiny;
  if (nature != null && state.nature != nature) {
    return false;
  }
  if (gender != null && state.gender != gender) {
    return false;
  }
  if (abilitySlot != null && state.abilitySlot != abilitySlot) {
    return false;
  }
  if (shiny != null && state.shiny != shiny) {
    return false;
  }
  return true;
}

int _progressStep(int total) {
  if (total <= 100) {
    return 1;
  }
  return (total / 100).ceil();
}

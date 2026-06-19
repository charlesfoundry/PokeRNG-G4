import 'dart:isolate';

import '../core/gen4/gen4.dart';
import 'search_results.dart';

class Gen4IdSearchRequest {
  const Gen4IdSearchRequest({
    required this.year,
    required this.minDelay,
    required this.maxDelay,
    this.filter = const Gen4IdFilter(),
  });

  final int year;
  final int minDelay;
  final int maxDelay;
  final Gen4IdFilter filter;

  int get totalProgressUnits => (maxDelay - minDelay + 1) * 256 * 24;
}

class Gen4IdSearchResult {
  const Gen4IdSearchResult({required this.results, required this.progress});

  final List<Gen4IdState> results;
  final Gen4SearchProgress progress;
}

class Gen4IdSearchJob {
  Gen4IdSearchJob._({
    required ReceivePort receivePort,
    required void Function(Gen4SearchProgress progress) onProgress,
    required void Function(Gen4IdSearchResult result) onComplete,
    required void Function(String error) onError,
  }) : _receivePort = receivePort,
       _onProgress = onProgress,
       _onComplete = onComplete,
       _onError = onError;

  final ReceivePort _receivePort;
  final void Function(Gen4SearchProgress progress) _onProgress;
  final void Function(Gen4IdSearchResult result) _onComplete;
  final void Function(String error) _onError;
  Isolate? _isolate;
  bool _cancelled = false;

  static Gen4IdSearchJob start({
    required Gen4IdSearchRequest request,
    required void Function(Gen4SearchProgress progress) onProgress,
    required void Function(Gen4IdSearchResult result) onComplete,
    required void Function(String error) onError,
  }) {
    final receivePort = ReceivePort();
    final job = Gen4IdSearchJob._(
      receivePort: receivePort,
      onProgress: onProgress,
      onComplete: onComplete,
      onError: onError,
    );
    job._listen();
    Isolate.spawn(
          _runGen4IdSearch,
          _Gen4IdSearchIsolateMessage(
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

  static Gen4IdSearchResult searchSync(
    Gen4IdSearchRequest request, {
    void Function(Gen4SearchProgress progress)? onProgress,
  }) {
    return _searchGen4Ids(request, onProgress: onProgress);
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
        case Gen4IdSearchResult():
          _finish();
          _onComplete(message);
        case _Gen4IdSearchFailure():
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

class _Gen4IdSearchIsolateMessage {
  const _Gen4IdSearchIsolateMessage({
    required this.sendPort,
    required this.request,
  });

  final SendPort sendPort;
  final Gen4IdSearchRequest request;
}

class _Gen4IdSearchFailure {
  const _Gen4IdSearchFailure(this.error);

  final String error;
}

void _runGen4IdSearch(_Gen4IdSearchIsolateMessage message) {
  try {
    final result = _searchGen4Ids(
      message.request,
      onProgress: message.sendPort.send,
    );
    message.sendPort.send(result);
  } catch (error) {
    message.sendPort.send(_Gen4IdSearchFailure(error.toString()));
  }
}

Gen4IdSearchResult _searchGen4Ids(
  Gen4IdSearchRequest request, {
  void Function(Gen4SearchProgress progress)? onProgress,
}) {
  final results = <Gen4IdState>[];
  final total = request.totalProgressUnits;
  var scanned = 0;
  final progressStep = _progressStep(total);
  var nextProgress = progressStep;
  onProgress?.call(Gen4SearchProgress(scanned: scanned, total: total));

  for (var efgh = request.minDelay; efgh <= request.maxDelay; efgh += 1) {
    for (var ab = 0; ab < 256; ab += 1) {
      for (var cd = 0; cd < 24; cd += 1) {
        final seed = (ab << 24) | (cd << 16) | efgh;
        final state = Gen4IdState.fromSeed(
          seed,
          delay: efgh + 2000 - request.year,
        );
        if (request.filter.matches(state)) {
          results.add(state);
        }

        scanned += 1;
        if (scanned == 1 || scanned >= nextProgress || scanned >= total) {
          onProgress?.call(Gen4SearchProgress(scanned: scanned, total: total));
          while (nextProgress <= scanned) {
            nextProgress += progressStep;
          }
        }
      }
    }
  }

  return Gen4IdSearchResult(
    results: results,
    progress: Gen4SearchProgress(scanned: scanned, total: total),
  );
}

int _progressStep(int total) {
  if (total <= 100) {
    return 1;
  }
  return (total / 100).ceil();
}

import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/gen4/gen4.dart';
import '../../data/gen4/gen4_game.dart';
import '../../data/gen4/named_resources.dart';
import '../../l10n/app_localizations.dart';
import '../gen4_excellent_sid_targets.dart';
import '../search_results.dart';

class ExcellentSidSelection {
  const ExcellentSidSelection({
    required this.tid,
    required this.sidRange,
    required this.group,
  });

  final int tid;
  final Gen4ShinySidRange sidRange;
  final Gen4PidTargetGroup group;
}

class ExcellentSidFinderPage extends StatefulWidget {
  const ExcellentSidFinderPage({
    super.key,
    required this.game,
    required this.tid,
  });

  final Gen4GameVersion game;
  final int? tid;

  @override
  State<ExcellentSidFinderPage> createState() => _ExcellentSidFinderPageState();
}

class _ExcellentSidFinderPageState extends State<ExcellentSidFinderPage> {
  late final _tidController = TextEditingController(
    text: widget.tid == null || widget.tid == 0 ? '' : '${widget.tid}',
  );
  final _minIvController = TextEditingController(text: '28');
  final _yearController = TextEditingController(text: '${DateTime.now().year}');
  final _maxDelayController = TextEditingController(text: '40000');
  final _maxFrameController = TextEditingController(text: '200');
  _ExcellentSidSearchJob? _job;
  List<_ReachableExcellentSidGroup>? _groups;
  String? _error;
  Gen4SearchRunState _state = Gen4SearchRunState.idle;
  Gen4SearchProgress? _progress;
  _ExcellentSidMethod _method = _ExcellentSidMethod.method1;
  ExcellentSidSort _sort = ExcellentSidSort.natureCount;
  Future<Gen4NamedResources>? _namesFuture;
  String? _localeName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeName = Localizations.localeOf(context).toString();
    if (_localeName != localeName) {
      _localeName = localeName;
      _namesFuture = Gen4NamedResources.load(localeName);
    }
  }

  @override
  void dispose() {
    _job?.cancel();
    _tidController.dispose();
    _minIvController.dispose();
    _yearController.dispose();
    _maxDelayController.dispose();
    _maxFrameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stationaryMethod = _stationaryMethodForGame(widget.game);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.idRngExcellentSidFinder)),
      body: FutureBuilder<Gen4NamedResources>(
        future: _namesFuture,
        builder: (context, snapshot) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            children: [
              _SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InputGrid(
                      children: [
                        _NumberField(
                          label: l10n.trainerId,
                          controller: _tidController,
                          maxLength: 5,
                          onChanged: _clearResults,
                        ),
                        _NumberField(
                          label: l10n.idRngPidTargetMinIvs,
                          controller: _minIvController,
                          maxLength: 2,
                          onChanged: _clearResults,
                        ),
                        _NumberField(
                          label: l10n.year,
                          controller: _yearController,
                          maxLength: 4,
                          onChanged: _clearResults,
                        ),
                        _NumberField(
                          label: l10n.maxDelay,
                          controller: _maxDelayController,
                          maxLength: 5,
                          onChanged: _clearResults,
                        ),
                        _NumberField(
                          label: l10n.maxAdvance,
                          controller: _maxFrameController,
                          maxLength: 6,
                          onChanged: _clearResults,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.game.isHgss
                          ? l10n.idRngExcellentSidMethodHelpHgss
                          : l10n.idRngExcellentSidMethodHelpDppt,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 6),
                    SegmentedButton<_ExcellentSidMethod>(
                      segments: [
                        const ButtonSegment(
                          value: _ExcellentSidMethod.method1,
                          label: Text('Method 1'),
                        ),
                        ButtonSegment(
                          value: stationaryMethod,
                          label: Text(stationaryMethod.label),
                        ),
                      ],
                      selected: {_method},
                      onSelectionChanged: (selected) {
                        setState(() {
                          _resetSearchState();
                          _method = selected.single;
                          _groups = null;
                          _error = null;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<ExcellentSidSort>(
                      segments: [
                        ButtonSegment(
                          value: ExcellentSidSort.natureCount,
                          label: Text(l10n.idRngSortByNatureCount),
                        ),
                        ButtonSegment(
                          value: ExcellentSidSort.targetCount,
                          label: Text(l10n.idRngSortByTargetCount),
                        ),
                      ],
                      selected: {_sort},
                      onSelectionChanged: (selected) {
                        final sort = selected.single;
                        setState(() {
                          if (_state == Gen4SearchRunState.running) {
                            _resetSearchState();
                          }
                          _sort = sort;
                          _groups = _groups == null
                              ? null
                              : _sortReachableGroups(_groups!, sort);
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _state == Gen4SearchRunState.running
                            ? null
                            : _search,
                        child: Text(l10n.idRngExcellentSidSearch),
                      ),
                    ),
                    if (_state == Gen4SearchRunState.running) ...[
                      const SizedBox(height: 10),
                      _InlineSearchProgressBar(progress: _progress),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.idRngExcellentSidResults,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _ExcellentSidResults(
                groups: _groups,
                tid: _parseOptionalInt(_tidController),
                names: snapshot.data,
                onSelected: (selection) => Navigator.of(context).pop(selection),
              ),
            ],
          );
        },
      ),
    );
  }

  void _search() {
    final l10n = AppLocalizations.of(context);
    final tid = _parseOptionalInt(_tidController);
    final minIv = _parseOptionalInt(_minIvController);
    final year = _parseOptionalInt(_yearController);
    final maxDelay = _parseOptionalInt(_maxDelayController);
    final maxFrame = _parseOptionalInt(_maxFrameController);
    if (tid == null) {
      setState(() {
        _groups = null;
        _error = l10n.idRngTidRequired;
      });
      return;
    }
    if (!_validU16(tid) ||
        minIv == null ||
        minIv < 0 ||
        minIv > 31 ||
        year == null ||
        year < 2000 ||
        year > 2099 ||
        maxDelay == null ||
        maxDelay < 0 ||
        maxDelay > 0xffff ||
        maxFrame == null ||
        maxFrame < 0) {
      setState(() {
        _groups = null;
        _error = l10n.idRngInvalidInput;
      });
      return;
    }
    try {
      final request = _ExcellentSidSearchRequest(
        minIv: minIv,
        sort: _sort,
        method: _method,
        year: year,
        maxDelay: maxDelay,
        maxFrame: maxFrame,
      );
      _startSearch(request);
    } catch (_) {
      setState(() {
        _job = null;
        _state = Gen4SearchRunState.failed;
        _progress = null;
        _groups = null;
        _error = l10n.idRngPidTargetInvalidInput;
      });
    }
  }

  void _startSearch(_ExcellentSidSearchRequest request) {
    _job?.cancel();
    _ExcellentSidSearchJob? job;
    job = _ExcellentSidSearchJob.start(
      request: request,
      onProgress: (progress) {
        if (!mounted || job != _job) {
          return;
        }
        setState(() {
          _state = Gen4SearchRunState.running;
          _progress = progress;
        });
      },
      onComplete: (result) {
        if (!mounted || job != _job) {
          return;
        }
        setState(() {
          _job = null;
          _state = Gen4SearchRunState.completed;
          _progress = result.progress;
          _groups = result.groups;
          _error = null;
        });
      },
      onError: (error) {
        if (!mounted || job != _job) {
          return;
        }
        setState(() {
          _job = null;
          _state = Gen4SearchRunState.failed;
          _progress = null;
          _groups = null;
          _error = error;
        });
      },
    );
    setState(() {
      _job = job;
      _state = Gen4SearchRunState.running;
      _progress = null;
      _groups = null;
      _error = null;
    });
  }

  void _resetSearchState() {
    _job?.cancel();
    _job = null;
    _state = Gen4SearchRunState.idle;
    _progress = null;
  }

  void _clearResults() {
    setState(() {
      _resetSearchState();
      _groups = null;
      _error = null;
    });
  }
}

class _InlineSearchProgressBar extends StatelessWidget {
  const _InlineSearchProgressBar({required this.progress});

  final Gen4SearchProgress? progress;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(value: progress?.fraction);
  }
}

class _ExcellentSidSearchRequest {
  const _ExcellentSidSearchRequest({
    required this.minIv,
    required this.sort,
    required this.method,
    required this.year,
    required this.maxDelay,
    required this.maxFrame,
  });

  final int minIv;
  final ExcellentSidSort sort;
  final _ExcellentSidMethod method;
  final int year;
  final int maxDelay;
  final int maxFrame;
}

class _ExcellentSidSearchResult {
  const _ExcellentSidSearchResult({
    required this.groups,
    required this.progress,
  });

  final List<_ReachableExcellentSidGroup> groups;
  final Gen4SearchProgress progress;
}

class _ExcellentSidSearchJob {
  _ExcellentSidSearchJob._({
    required ReceivePort receivePort,
    required void Function(Gen4SearchProgress progress) onProgress,
    required void Function(_ExcellentSidSearchResult result) onComplete,
    required void Function(String error) onError,
  }) : _receivePort = receivePort,
       _onProgress = onProgress,
       _onComplete = onComplete,
       _onError = onError;

  final ReceivePort _receivePort;
  final void Function(Gen4SearchProgress progress) _onProgress;
  final void Function(_ExcellentSidSearchResult result) _onComplete;
  final void Function(String error) _onError;
  Isolate? _isolate;
  bool _cancelled = false;

  static _ExcellentSidSearchJob start({
    required _ExcellentSidSearchRequest request,
    required void Function(Gen4SearchProgress progress) onProgress,
    required void Function(_ExcellentSidSearchResult result) onComplete,
    required void Function(String error) onError,
  }) {
    final receivePort = ReceivePort();
    final job = _ExcellentSidSearchJob._(
      receivePort: receivePort,
      onProgress: onProgress,
      onComplete: onComplete,
      onError: onError,
    );
    job._listen();
    Isolate.spawn(
          _runExcellentSidSearch,
          _ExcellentSidSearchIsolateMessage(
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
        case _ExcellentSidSearchResult():
          _finish();
          _onComplete(message);
        case _ExcellentSidSearchFailure():
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

class _ExcellentSidSearchIsolateMessage {
  const _ExcellentSidSearchIsolateMessage({
    required this.sendPort,
    required this.request,
  });

  final SendPort sendPort;
  final _ExcellentSidSearchRequest request;
}

class _ExcellentSidSearchFailure {
  const _ExcellentSidSearchFailure(this.error);

  final String error;
}

void _runExcellentSidSearch(_ExcellentSidSearchIsolateMessage message) {
  try {
    final result = _searchExcellentSidTargets(
      message.request,
      onProgress: message.sendPort.send,
    );
    message.sendPort.send(result);
  } catch (error) {
    message.sendPort.send(_ExcellentSidSearchFailure(error.toString()));
  }
}

_ExcellentSidSearchResult _searchExcellentSidTargets(
  _ExcellentSidSearchRequest request, {
  void Function(Gen4SearchProgress progress)? onProgress,
}) {
  final groups = excellentSidTargetGroups(
    minIv: request.minIv,
    sort: request.sort,
  );
  final total = groups.fold<int>(
    0,
    (count, group) => count + group.targets.length,
  );
  onProgress?.call(Gen4SearchProgress(scanned: 0, total: total));
  final filtered = _filterReachableGroups(
    groups,
    method: request.method,
    year: request.year,
    maxDelay: request.maxDelay,
    maxFrame: request.maxFrame,
    sort: request.sort,
    onProgress: onProgress,
  );
  return _ExcellentSidSearchResult(
    groups: filtered,
    progress: Gen4SearchProgress(scanned: total, total: total),
  );
}

class _ExcellentSidResults extends StatelessWidget {
  const _ExcellentSidResults({
    required this.groups,
    required this.tid,
    required this.names,
    required this.onSelected,
  });

  final List<_ReachableExcellentSidGroup>? groups;
  final int? tid;
  final Gen4NamedResources? names;
  final ValueChanged<ExcellentSidSelection> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = this.groups;
    if (groups == null) {
      return _SurfaceCard(child: Text(l10n.searchResultsPlaceholder));
    }
    if (groups.isEmpty) {
      return _SurfaceCard(child: Text(l10n.idRngPidTargetNoResults));
    }
    return Column(
      children: [
        for (final group in groups.take(50)) ...[
          _ExcellentSidGroupCard(
            group: group,
            tid: tid,
            names: names,
            onSelected: onSelected,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ExcellentSidGroupCard extends StatelessWidget {
  const _ExcellentSidGroupCard({
    required this.group,
    required this.tid,
    required this.names,
    required this.onSelected,
  });

  final _ReachableExcellentSidGroup group;
  final int? tid;
  final Gen4NamedResources? names;
  final ValueChanged<ExcellentSidSelection> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sidRange = tid == null ? null : group.group.sidRangeForTid(tid!);
    return _SurfaceCard(
      onTap: tid == null || sidRange == null
          ? null
          : () => onSelected(
              ExcellentSidSelection(
                tid: tid!,
                sidRange: sidRange,
                group: group.group,
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [
              Text(
                l10n.idRngExcellentSidGroup(
                  group.group.personalityShinyValue.toString(),
                ),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(l10n.idRngPidTargetCount(group.targets.length.toString())),
              Text(
                l10n.idRngNatureCount(
                  excellentSidNatureCount(group.group).toString(),
                ),
              ),
              if (sidRange != null)
                Text(l10n.idRngSidRangeShort(sidRange.display)),
            ],
          ),
          const SizedBox(height: 8),
          _TargetTable(targets: group.targets, names: names),
        ],
      ),
    );
  }
}

class _TargetTable extends StatelessWidget {
  const _TargetTable({required this.targets, required this.names});

  final List<_ReachableExcellentSidTarget> targets;
  final Gen4NamedResources? names;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final target in targets)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Table(
                  columnWidths: const {
                    0: FixedColumnWidth(86),
                    1: FixedColumnWidth(70),
                    2: FixedColumnWidth(94),
                    3: FlexColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      children: [
                        _TableText(
                          'D${target.reachability.delay}/'
                          'F${target.reachability.frame}',
                          monospace: true,
                          style: textStyle,
                        ),
                        _TableText(
                          names?.natureName(target.target.nature.index) ??
                              target.target.nature.name,
                          style: textStyle,
                        ),
                        _TableText(
                          excellentSidNatureModifier(target.target.nature),
                          style: textStyle,
                        ),
                        _TableText(
                          target.target.ivs.toString(),
                          monospace: true,
                          style: textStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReachableExcellentSidGroup {
  const _ReachableExcellentSidGroup({
    required this.group,
    required this.targets,
  });

  final Gen4PidTargetGroup group;
  final List<_ReachableExcellentSidTarget> targets;
}

class _ReachableExcellentSidTarget {
  const _ReachableExcellentSidTarget({
    required this.target,
    required this.reachability,
  });

  final Gen4PidTarget target;
  final _Method1Reachability reachability;
}

class _Method1Reachability {
  const _Method1Reachability({
    required this.seed,
    required this.delay,
    required this.frame,
  });

  final int seed;
  final int delay;
  final int frame;
}

enum _ExcellentSidMethod {
  method1('Method 1'),
  methodJ('Method J'),
  methodK('Method K');

  const _ExcellentSidMethod(this.label);

  final String label;
}

_ExcellentSidMethod _stationaryMethodForGame(Gen4GameVersion game) {
  return game.isHgss
      ? _ExcellentSidMethod.methodK
      : _ExcellentSidMethod.methodJ;
}

List<_ReachableExcellentSidGroup> _filterReachableGroups(
  List<Gen4PidTargetGroup> groups, {
  required _ExcellentSidMethod method,
  required int year,
  required int maxDelay,
  required int maxFrame,
  required ExcellentSidSort sort,
  void Function(Gen4SearchProgress progress)? onProgress,
}) {
  final reachableGroups = <_ReachableExcellentSidGroup>[];
  final total = groups.fold<int>(
    0,
    (count, group) => count + group.targets.length,
  );
  var scanned = 0;
  final progressStep = _excellentSidProgressStep(total);
  var nextProgress = progressStep;

  void reportProgress() {
    if (total <= 0) {
      return;
    }
    if (scanned == 1 || scanned >= nextProgress || scanned >= total) {
      onProgress?.call(Gen4SearchProgress(scanned: scanned, total: total));
      while (nextProgress <= scanned) {
        nextProgress += progressStep;
      }
    }
  }

  for (final group in groups) {
    final targets = <_ReachableExcellentSidTarget>[];
    for (final target in group.targets) {
      final reachability = _findReachability(
        target,
        method: method,
        year: year,
        maxDelay: maxDelay,
        maxFrame: maxFrame,
      );
      scanned += 1;
      reportProgress();
      if (reachability == null) {
        continue;
      }
      targets.add(
        _ReachableExcellentSidTarget(
          target: target,
          reachability: reachability,
        ),
      );
    }
    if (targets.isEmpty) {
      continue;
    }
    final filteredGroup = Gen4PidTargetGroup(
      personalityShinyValue: group.personalityShinyValue,
      targets: [for (final target in targets) target.target],
    );
    reachableGroups.add(
      _ReachableExcellentSidGroup(group: filteredGroup, targets: targets),
    );
  }
  return _sortReachableGroups(reachableGroups, sort);
}

int _excellentSidProgressStep(int total) {
  if (total <= 100) {
    return 1;
  }
  return (total / 100).ceil();
}

List<_ReachableExcellentSidGroup> _sortReachableGroups(
  List<_ReachableExcellentSidGroup> groups,
  ExcellentSidSort sort,
) {
  final sorted = [...groups];
  final sortedGroups = sortExcellentSidGroups([
    for (final group in sorted) group.group,
  ], sort);
  final byPsv = {
    for (final group in sorted) group.group.personalityShinyValue: group,
  };
  return [
    for (final group in sortedGroups) byPsv[group.personalityShinyValue]!,
  ];
}

_Method1Reachability? _findMethod1Reachability(
  Gen4PidTarget target, {
  required int year,
  required int maxDelay,
  required int maxFrame,
}) {
  for (var frame = 0; frame <= maxFrame; frame += 1) {
    final seed = Lcrng.pokeRngReverse(target.encounterSeed).advance(frame).seed;
    final hour = (seed >>> 16) & 0xffff;
    if (hour >= 24) {
      continue;
    }
    final info = Gen4SeedTime.seedInfo(seed: seed, year: year);
    if (info.delay <= maxDelay) {
      return _Method1Reachability(seed: seed, delay: info.delay, frame: frame);
    }
  }
  return null;
}

_Method1Reachability? _findReachability(
  Gen4PidTarget target, {
  required _ExcellentSidMethod method,
  required int year,
  required int maxDelay,
  required int maxFrame,
}) {
  return switch (method) {
    _ExcellentSidMethod.method1 => _findMethod1Reachability(
      target,
      year: year,
      maxDelay: maxDelay,
      maxFrame: maxFrame,
    ),
    _ExcellentSidMethod.methodJ => _findMethodJReachability(
      target,
      year: year,
      maxDelay: maxDelay,
      maxFrame: maxFrame,
    ),
    _ExcellentSidMethod.methodK => _findMethodKReachability(
      target,
      year: year,
      maxDelay: maxDelay,
      maxFrame: maxFrame,
    ),
  };
}

_Method1Reachability? _findMethodJReachability(
  Gen4PidTarget target, {
  required int year,
  required int maxDelay,
  required int maxFrame,
}) {
  final rawMinDelay = _displayDelayToRaw(0, year);
  final rawMaxDelay = _displayDelayToRaw(maxDelay, year);
  if (rawMinDelay > rawMaxDelay) {
    return null;
  }
  final results = Gen4StaticSearcher(
    minAdvance: 0,
    maxAdvance: maxFrame,
    minDelay: rawMinDelay,
    maxDelay: rawMaxDelay,
    level: 50,
    tid: 0,
    sid: 0,
    genderRatio: PokemonGenderRatio.genderless,
  ).searchMethodJ(target.ivs, nature: target.nature);
  for (final result in results) {
    if (result.state.pid.value != target.pid.value) {
      continue;
    }
    final info = result.seedInfo(year: year);
    if (info.delay <= maxDelay) {
      return _Method1Reachability(
        seed: result.seed,
        delay: info.delay,
        frame: result.frame,
      );
    }
  }
  return null;
}

_Method1Reachability? _findMethodKReachability(
  Gen4PidTarget target, {
  required int year,
  required int maxDelay,
  required int maxFrame,
}) {
  final rawMinDelay = _displayDelayToRaw(0, year);
  final rawMaxDelay = _displayDelayToRaw(maxDelay, year);
  if (rawMinDelay > rawMaxDelay) {
    return null;
  }
  final results = Gen4StaticSearcher(
    minAdvance: 0,
    maxAdvance: maxFrame,
    minDelay: rawMinDelay,
    maxDelay: rawMaxDelay,
    level: 50,
    tid: 0,
    sid: 0,
    genderRatio: PokemonGenderRatio.genderless,
  ).searchMethodK(target.ivs, nature: target.nature);
  for (final result in results) {
    if (result.state.pid.value != target.pid.value) {
      continue;
    }
    final info = result.seedInfo(year: year);
    if (info.delay <= maxDelay) {
      return _Method1Reachability(
        seed: result.seed,
        delay: info.delay,
        frame: result.frame,
      );
    }
  }
  return null;
}

int _displayDelayToRaw(int delay, int year) {
  final rawDelay = delay + year - 2000;
  if (rawDelay < 0) {
    return 0;
  }
  if (rawDelay > 0xffff) {
    return 0xffff;
  }
  return rawDelay;
}

class _TableText extends StatelessWidget {
  const _TableText(this.text, {required this.style, this.monospace = false});

  final String text;
  final TextStyle? style;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6, bottom: 4),
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        textScaler: TextScaler.linear(_fitScale(text)),
        style: monospace
            ? style?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              )
            : style,
      ),
    );
  }
}

double _fitScale(String text) {
  if (text.length <= 8) {
    return 1;
  }
  if (text.length <= 12) {
    return 0.94;
  }
  if (text.length <= 17) {
    return 0.88;
  }
  return 0.82;
}

class _InputGrid extends StatelessWidget {
  const _InputGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const columns = 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final child in children)
              SizedBox(
                width: (width - (columns - 1) * 8) / columns,
                child: child,
              ),
          ],
        );
      },
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
    required this.maxLength,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final int maxLength;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ],
      onChanged: (_) => onChanged(),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: borderRadius,
      ),
      child: Padding(padding: const EdgeInsets.all(10), child: child),
    );
    if (onTap == null) {
      return content;
    }
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}

int? _parseOptionalInt(TextEditingController controller) {
  final text = controller.text.trim();
  if (text.isEmpty) {
    return null;
  }
  return int.tryParse(text);
}

bool _validU16(int? value) {
  return value == null || value >= 0 && value <= 0xffff;
}

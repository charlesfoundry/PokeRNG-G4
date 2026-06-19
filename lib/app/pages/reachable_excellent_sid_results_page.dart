import 'package:flutter/material.dart';

import '../../core/gen4/gen4.dart';
import '../../data/gen4/named_resources.dart';
import '../../l10n/app_localizations.dart';
import '../gen4_excellent_sid_targets.dart';
import '../gen4_id_search_job.dart';
import '../gen4_reachable_excellent_sid_search.dart';
import '../search_results.dart';

const _reachableExcellentSidDisplayLimit = 200;

class ReachableExcellentSidResultsPage extends StatefulWidget {
  const ReachableExcellentSidResultsPage({super.key, required this.request});

  final ReachableExcellentSidRequest request;

  @override
  State<ReachableExcellentSidResultsPage> createState() =>
      _ReachableExcellentSidResultsPageState();
}

class _ReachableExcellentSidResultsPageState
    extends State<ReachableExcellentSidResultsPage> {
  Gen4IdSearchJob? _job;
  Gen4SearchRunState _state = Gen4SearchRunState.idle;
  Gen4SearchProgress? _progress;
  List<ReachableExcellentSidResult> _results = const [];
  String? _error;
  Future<Gen4NamedResources>? _namesFuture;
  String? _localeName;

  @override
  void initState() {
    super.initState();
    _startSearch();
  }

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayed = _results
        .take(_reachableExcellentSidDisplayLimit)
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.idRngReachableExcellentSidFinder)),
      body: FutureBuilder<Gen4NamedResources>(
        future: _namesFuture,
        builder: (context, snapshot) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.idRngReachableExcellentSidFinder,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (_results.isNotEmpty)
                    Text(
                      l10n.resultCount(displayed.length.toString()),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                ],
              ),
              if (_state == Gen4SearchRunState.running) ...[
                const SizedBox(height: 10),
                _SearchProgressBar(
                  progress: _progress,
                  onCancelSearch: _cancelSearch,
                ),
              ] else if (_results.isEmpty ||
                  _state == Gen4SearchRunState.failed ||
                  _state == Gen4SearchRunState.cancelled) ...[
                const SizedBox(height: 12),
                _StatusMessage(state: _state, error: _error),
              ],
              if (_results.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (final result in displayed) ...[
                  _ReachableExcellentSidCard(
                    result: result,
                    names: snapshot.data,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  void _startSearch() {
    Gen4IdSearchJob? job;
    job = Gen4IdSearchJob.start(
      request: widget.request.searchRequest,
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
          _results = matchReachableExcellentSidResults(
            result.results,
            widget.request.groupsByTsv,
          );
        });
      },
      onError: (error) {
        if (!mounted || job != _job) {
          return;
        }
        setState(() {
          _job = null;
          _state = Gen4SearchRunState.failed;
          _error = error;
        });
      },
    );
    setState(() {
      _job = job;
      _state = Gen4SearchRunState.running;
      _progress = Gen4SearchProgress(
        scanned: 0,
        total: widget.request.searchRequest.totalProgressUnits,
      );
      _results = const [];
      _error = null;
    });
  }

  void _cancelSearch() {
    _job?.cancel();
    setState(() {
      _job = null;
      _state = Gen4SearchRunState.cancelled;
    });
  }
}

class _ReachableExcellentSidCard extends StatelessWidget {
  const _ReachableExcellentSidCard({required this.result, required this.names});

  final ReachableExcellentSidResult result;
  final Gen4NamedResources? names;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = result.state;
    final group = result.group;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(result),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    Text('${l10n.seed}: ${_seedHex(state.seed)}'),
                    Text('${l10n.delay}: ${state.delay}'),
                    Text('${l10n.secretId}: ${_padId(state.sid)}'),
                    Text('TSV: ${state.trainerShinyValue}'),
                    if (group != null) ...[
                      Text(
                        l10n.idRngNatureCount(
                          excellentSidNatureCount(group).toString(),
                        ),
                      ),
                      Text(
                        l10n.idRngPidTargetCount(
                          group.targets.length.toString(),
                        ),
                      ),
                    ],
                  ],
                ),
                if (group != null) ...[
                  const SizedBox(height: 8),
                  _TargetTable(targets: group.targets, names: names),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TargetTable extends StatelessWidget {
  const _TargetTable({required this.targets, required this.names});

  final List<Gen4PidTarget> targets;
  final Gen4NamedResources? names;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall;
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(78),
        1: FixedColumnWidth(70),
        2: FixedColumnWidth(94),
        3: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (final target in targets)
          TableRow(
            children: [
              _TableText(target.pid.hex, monospace: true, style: textStyle),
              _TableText(
                names?.natureName(target.nature.index) ?? target.nature.name,
                style: textStyle,
              ),
              _TableText(
                excellentSidNatureModifier(target.nature),
                style: textStyle,
              ),
              _TableText(
                target.ivs.toString(),
                monospace: true,
                style: textStyle,
              ),
            ],
          ),
      ],
    );
  }
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

class _SearchProgressBar extends StatelessWidget {
  const _SearchProgressBar({
    required this.progress,
    required this.onCancelSearch,
  });

  final Gen4SearchProgress? progress;
  final VoidCallback onCancelSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: progress?.fraction),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 34),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onCancelSearch,
            child: Text(l10n.cancel),
          ),
        ),
      ],
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.state, required this.error});

  final Gen4SearchRunState state;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = switch (state) {
      Gen4SearchRunState.idle => l10n.searchResultsPlaceholder,
      Gen4SearchRunState.running => l10n.searching,
      Gen4SearchRunState.completed => l10n.noResults,
      Gen4SearchRunState.cancelled => l10n.searchCancelled,
      Gen4SearchRunState.failed => l10n.searchFailed,
    };
    final colorScheme = Theme.of(context).colorScheme;
    final isError = state == Gen4SearchRunState.failed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isError ? colorScheme.error : null,
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colorScheme.error),
            ),
          ],
        ],
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

String _seedHex(int seed) {
  return seed.toRadixString(16).padLeft(8, '0').toUpperCase();
}

String _padId(int value) {
  return value.toString().padLeft(5, '0');
}

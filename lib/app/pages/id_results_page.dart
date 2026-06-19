import 'package:flutter/material.dart';

import '../../core/gen4/gen4.dart';
import '../../l10n/app_localizations.dart';
import '../gen4_id_search_job.dart';
import '../search_results.dart';

const _idResultDisplayLimit = 200;

class IdResultsPage extends StatefulWidget {
  const IdResultsPage({super.key, required this.request});

  final Gen4IdSearchRequest request;

  @override
  State<IdResultsPage> createState() => _IdResultsPageState();
}

class _IdResultsPageState extends State<IdResultsPage> {
  Gen4IdSearchJob? _job;
  Gen4SearchRunState _state = Gen4SearchRunState.idle;
  Gen4SearchProgress? _progress;
  List<Gen4IdState> _results = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _startSearch();
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
        .take(_idResultDisplayLimit)
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.idRngResults)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.idRngResults,
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
            for (final state in displayed) ...[
              _IdStateCard(state: state),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }

  void _startSearch() {
    Gen4IdSearchJob? job;
    job = Gen4IdSearchJob.start(
      request: widget.request,
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
          _results = result.results;
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
        total: widget.request.totalProgressUnits,
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

class _IdStateCard extends StatelessWidget {
  const _IdStateCard({required this.state});

  final Gen4IdState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(state),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text('${l10n.seed}: ${_seedHex(state.seed)}'),
                    Text('${l10n.delay}: ${state.delay}'),
                    if (state.second case final second?)
                      Text('${l10n.second}: $second'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.idRngResultSubtitle(
                    _padId(state.tid),
                    _padId(state.sid),
                    state.trainerShinyValue.toString(),
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _seedHex(int seed) {
  return seed.toRadixString(16).padLeft(8, '0').toUpperCase();
}

String _padId(int value) {
  return value.toString().padLeft(5, '0');
}

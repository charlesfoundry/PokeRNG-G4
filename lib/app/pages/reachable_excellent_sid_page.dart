import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/gen4/gen4.dart';
import '../../data/gen4/gen4_game.dart';
import '../../l10n/app_localizations.dart';
import '../gen4_id_search_job.dart';
import '../gen4_reachable_excellent_sid_search.dart';
import 'excellent_sid_finder_page.dart';
import 'reachable_excellent_sid_results_page.dart';

class ReachableExcellentSidSelection {
  const ReachableExcellentSidSelection({
    required this.year,
    required this.state,
    this.group,
  });

  final int year;
  final Gen4IdState state;
  final Gen4PidTargetGroup? group;
}

class ReachableExcellentSidPage extends StatefulWidget {
  const ReachableExcellentSidPage({
    super.key,
    required this.game,
    required this.tid,
    required this.year,
    required this.minDelay,
    required this.maxDelay,
  });

  final Gen4GameVersion game;
  final int? tid;
  final int year;
  final int minDelay;
  final int maxDelay;

  @override
  State<ReachableExcellentSidPage> createState() =>
      _ReachableExcellentSidPageState();
}

class _ReachableExcellentSidPageState extends State<ReachableExcellentSidPage> {
  late final _tidController = TextEditingController(
    text: widget.tid == null ? '' : '${widget.tid}',
  );
  late final _yearController = TextEditingController(text: '${widget.year}');
  late final _minDelayController = TextEditingController(
    text: '${widget.minDelay}',
  );
  late final _maxDelayController = TextEditingController(
    text: '${widget.maxDelay}',
  );
  final _minSidController = TextEditingController();
  final _maxSidController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _tidController.dispose();
    _yearController.dispose();
    _minDelayController.dispose();
    _maxDelayController.dispose();
    _minSidController.dispose();
    _maxSidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.idRngReachableExcellentSidFinder)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        children: [
          _SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: _openExcellentSidFinderPage,
                    icon: const Icon(Icons.manage_search),
                    label: Text(l10n.idRngExcellentSidFinder),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.idRngTarget,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _InputGrid(
                  children: [
                    _NumberField(
                      label: l10n.trainerId,
                      controller: _tidController,
                      maxLength: 5,
                      onChanged: _clearTarget,
                    ),
                    _NumberField(
                      label: l10n.idRngMinSid,
                      controller: _minSidController,
                      maxLength: 5,
                      onChanged: _clearTarget,
                    ),
                    _NumberField(
                      label: l10n.idRngMaxSid,
                      controller: _maxSidController,
                      maxLength: 5,
                      onChanged: _clearTarget,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.searchRange,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _InputGrid(
                  children: [
                    _NumberField(
                      label: l10n.year,
                      controller: _yearController,
                      maxLength: 4,
                      onChanged: _clearResults,
                    ),
                    _NumberField(
                      label: l10n.minDelay,
                      controller: _minDelayController,
                      maxLength: 5,
                      onChanged: _clearResults,
                    ),
                    _NumberField(
                      label: l10n.maxDelay,
                      controller: _maxDelayController,
                      maxLength: 5,
                      onChanged: _clearResults,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _searchSpaceText(l10n),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _searchReachableExcellentSid,
                  child: Text(l10n.idRngReachableExcellentSidSearch),
                ),
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
          _SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.idRngQuickGuide,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(l10n.idRngQuickGuideBody),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _searchSpaceText(AppLocalizations l10n) {
    final year = _parseOptionalInt(_yearController);
    final minDelay = _parseOptionalInt(_minDelayController);
    final maxDelay = _parseOptionalInt(_maxDelayController);
    if (year == null ||
        minDelay == null ||
        maxDelay == null ||
        minDelay > maxDelay) {
      return l10n.searchSpaceInvalid;
    }
    final rawMinDelay = _rawIdDelay(minDelay, year);
    final rawMaxDelay = _rawIdDelay(maxDelay, year);
    if (rawMinDelay < 0 || rawMaxDelay > 0xffff) {
      return l10n.searchSpaceInvalid;
    }
    final states = (rawMaxDelay - rawMinDelay + 1) * 256 * 24;
    return l10n.idRngSearchSpace(_formatInt(states));
  }

  Future<void> _openExcellentSidFinderPage() async {
    final result = await Navigator.of(context).push<ExcellentSidSelection>(
      MaterialPageRoute(
        builder: (_) => ExcellentSidFinderPage(
          game: widget.game,
          tid: _parseOptionalInt(_tidController),
          year: _searchYearValue,
        ),
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    setState(() {
      _tidController.text = result.tid.toString();
      _yearController.text = result.year.toString();
      _minSidController.text = _padId(result.sidRange.first);
      _maxSidController.text = _padId(result.sidRange.last);
      _error = null;
    });
  }

  Future<void> _searchReachableExcellentSid() async {
    final l10n = AppLocalizations.of(context);
    final request = _buildRequest(l10n);
    if (request == null) {
      return;
    }
    final selected = await Navigator.of(context)
        .push<ReachableExcellentSidResult>(
          MaterialPageRoute(
            builder: (_) => ReachableExcellentSidResultsPage(request: request),
          ),
        );
    if (!mounted || selected == null) {
      return;
    }
    Navigator.of(context).pop(
      ReachableExcellentSidSelection(
        year: _searchYearValue,
        state: selected.state,
        group: selected.group,
      ),
    );
  }

  ReachableExcellentSidRequest? _buildRequest(AppLocalizations l10n) {
    final tid = _parseOptionalInt(_tidController);
    final minSid = _parseOptionalInt(_minSidController);
    final maxSid = _parseOptionalInt(_maxSidController);
    final year = _parseOptionalInt(_yearController);
    final minDelay = _parseOptionalInt(_minDelayController);
    final maxDelay = _parseOptionalInt(_maxDelayController);
    if (!_validU16(tid) ||
        tid == null ||
        !_validU16(minSid) ||
        minSid == null ||
        !_validU16(maxSid) ||
        maxSid == null ||
        minSid > maxSid ||
        year == null ||
        year < 2000 ||
        year > 2099 ||
        minDelay == null ||
        maxDelay == null ||
        minDelay > maxDelay) {
      setState(() => _error = l10n.idRngInvalidInput);
      return null;
    }
    final rawMinDelay = _rawIdDelay(minDelay, year);
    final rawMaxDelay = _rawIdDelay(maxDelay, year);
    if (rawMinDelay < 0 || rawMaxDelay > 0xffff) {
      setState(() => _error = l10n.idRngInvalidInput);
      return null;
    }
    try {
      return ReachableExcellentSidRequest(
        searchRequest: Gen4IdSearchRequest(
          year: year,
          minDelay: rawMinDelay,
          maxDelay: rawMaxDelay,
          filter: Gen4IdFilter(
            tids: {tid},
            sids: {for (var sid = minSid; sid <= maxSid; sid += 1) sid},
          ),
        ),
        groupsByTsv: const {},
      );
    } catch (_) {
      setState(() => _error = l10n.idRngPidTargetInvalidInput);
      return null;
    }
  }

  void _clearResults() {
    if (!mounted) {
      return;
    }
    setState(() {
      _error = null;
    });
  }

  void _clearTarget() {
    if (!mounted) {
      return;
    }
    setState(() {
      _error = null;
    });
  }

  int get _searchYearValue {
    return _parseOptionalInt(_yearController) ??
        DateTime.now().year.clamp(2000, 2099).toInt();
  }
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
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(padding: const EdgeInsets.all(10), child: child),
    );
  }
}

int _rawIdDelay(int displayedDelay, int year) {
  return displayedDelay + year - 2000;
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

String _padId(int value) {
  return value.toString().padLeft(5, '0');
}

String _formatInt(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < text.length; index += 1) {
    if (index > 0 && (text.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(text[index]);
  }
  return buffer.toString();
}

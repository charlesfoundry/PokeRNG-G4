import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/gen4/gen4.dart';
import '../../data/gen4/named_resources.dart';
import '../../l10n/app_localizations.dart';
import '../gen4_excellent_sid_targets.dart';
import '../gen4_id_search_job.dart';
import '../gen4_reachable_excellent_sid_search.dart';
import 'cute_charm_id_target_page.dart';
import 'excellent_sid_finder_page.dart';
import 'pid_target_finder_page.dart';
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
    required this.tid,
    required this.year,
    required this.minDelay,
    required this.maxDelay,
  });

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
  final _pidController = TextEditingController();
  final _tsvController = TextEditingController();
  final _minIvController = TextEditingController(text: '28');
  Gen4CuteCharmLead _cuteCharmLead = Gen4CuteCharmLead.male;
  int _cuteCharmGenderRatio = 127;
  int _cuteCharmNatureId = Nature.adamant.index;
  bool _includeNeutralNatures = false;
  bool _extraFiltersExpanded = false;
  String? _error;
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
    _tidController.dispose();
    _yearController.dispose();
    _minDelayController.dispose();
    _maxDelayController.dispose();
    _minSidController.dispose();
    _maxSidController.dispose();
    _pidController.dispose();
    _tsvController.dispose();
    _minIvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.idRngReachableExcellentSidFinder)),
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
                          onChanged: _clearResults,
                        ),
                        _NumberField(
                          label: l10n.idRngMinSid,
                          controller: _minSidController,
                          maxLength: 5,
                          onChanged: _clearResults,
                        ),
                        _NumberField(
                          label: l10n.idRngMaxSid,
                          controller: _maxSidController,
                          maxLength: 5,
                          onChanged: _clearResults,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _TargetPidSummary(
                      tid: _parseOptionalInt(_tidController),
                      pid: _parseOptionalPid(_pidController),
                      names: snapshot.data,
                      onSidSelected: _applySidCandidate,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: _openExcellentSidFinderPage,
                        icon: const Icon(Icons.manage_search),
                        label: Text(l10n.idRngExcellentSidFinder),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      initiallyExpanded: _extraFiltersExpanded,
                      title: Text(l10n.idRngExtraTargetFilters),
                      subtitle: Text(_extraFiltersSummary(l10n)),
                      onExpansionChanged: (expanded) {
                        setState(() => _extraFiltersExpanded = expanded);
                      },
                      children: [
                        const SizedBox(height: 8),
                        _InputGrid(
                          children: [
                            _NumberField(
                              label: l10n.idRngTargetTsv,
                              controller: _tsvController,
                              maxLength: 4,
                              onChanged: _clearResults,
                            ),
                            _PidField(
                              label: l10n.idRngTargetPid,
                              controller: _pidController,
                              onChanged: _clearResults,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: _openCuteCharmTargetPage,
                            child: Text(l10n.cuteCharmIdTarget),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: _openPidTargetFinderPage,
                            child: Text(l10n.idRngPidTargetFinder),
                          ),
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
                    const SizedBox(height: 16),
                    Text(
                      l10n.idRngReachableExcellentSidFinder,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    _InputGrid(
                      children: [
                        _NumberField(
                          label: l10n.idRngPidTargetMinIvs,
                          controller: _minIvController,
                          maxLength: 2,
                          onChanged: _clearResults,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.idRngIncludeNeutralNatures),
                      value: _includeNeutralNatures,
                      onChanged: (value) {
                        setState(() {
                          _includeNeutralNatures = value;
                          _error = null;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
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
          );
        },
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

  String _extraFiltersSummary(AppLocalizations l10n) {
    final parts = <String>[];
    final tsv = _tsvController.text.trim();
    final pid = _pidController.text.trim();
    if (tsv.isNotEmpty) {
      parts.add('${l10n.idRngTargetTsv}: $tsv');
    }
    if (pid.isNotEmpty) {
      parts.add('${l10n.idRngTargetPid}: $pid');
    }
    return parts.isEmpty ? l10n.none : parts.join(' · ');
  }

  void _applyCuteCharmTarget(Gen4CuteCharmIdTarget target) {
    setState(() {
      _pidController.text = _seedHex(target.pid);
      _tsvController.text = target.trainerShinyValue.toString();
      _extraFiltersExpanded = true;
      _error = null;
    });
  }

  Future<void> _openCuteCharmTargetPage() async {
    final result = await Navigator.of(context).push<Gen4CuteCharmIdTarget>(
      MaterialPageRoute(
        builder: (_) => CuteCharmIdTargetPage(
          lead: _cuteCharmLead,
          genderRatio: _cuteCharmGenderRatio,
          natureId: _cuteCharmNatureId,
        ),
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    _cuteCharmLead = result.lead;
    _cuteCharmGenderRatio = result.genderRatio;
    _cuteCharmNatureId = result.nature.index;
    _applyCuteCharmTarget(result);
  }

  Future<void> _openPidTargetFinderPage() async {
    final result = await Navigator.of(context).push<Gen4PidTarget>(
      MaterialPageRoute(
        builder: (_) =>
            PidTargetFinderPage(tid: _parseOptionalInt(_tidController)),
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    setState(() {
      _pidController.text = _seedHex(result.pid.value);
      _tsvController.text = result.personalityShinyValue.toString();
      if (_parseOptionalInt(_tidController) case final tid?) {
        final sidRange = result.sidRangeForTid(tid);
        _minSidController.text = _padId(sidRange.first);
        _maxSidController.text = _padId(sidRange.last);
      }
      _extraFiltersExpanded = true;
      _error = null;
    });
  }

  Future<void> _openExcellentSidFinderPage() async {
    final result = await Navigator.of(context).push<ExcellentSidSelection>(
      MaterialPageRoute(
        builder: (_) =>
            ExcellentSidFinderPage(tid: _parseOptionalInt(_tidController)),
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    setState(() {
      _tidController.text = result.tid.toString();
      _minSidController.text = _padId(result.sidRange.first);
      _maxSidController.text = _padId(result.sidRange.last);
      _error = null;
    });
  }

  void _applySidCandidate(int sid) {
    setState(() {
      _minSidController.text = _padId(sid);
      _maxSidController.text = _padId(sid);
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
    final year = _parseOptionalInt(_yearController);
    final minDelay = _parseOptionalInt(_minDelayController);
    final maxDelay = _parseOptionalInt(_maxDelayController);
    final minIv = _parseOptionalInt(_minIvController);
    if (!_validU16(tid) ||
        tid == null ||
        year == null ||
        year < 2000 ||
        year > 2099 ||
        minDelay == null ||
        maxDelay == null ||
        minDelay > maxDelay ||
        minIv == null ||
        minIv < 0 ||
        minIv > 31) {
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
      final groups = excellentSidTargetGroups(
        minIv: minIv,
        includeNeutralNatures: _includeNeutralNatures,
        sort: ExcellentSidSort.natureCount,
      );
      return ReachableExcellentSidRequest(
        searchRequest: Gen4IdSearchRequest(
          year: year,
          minDelay: rawMinDelay,
          maxDelay: rawMaxDelay,
          filter: Gen4IdFilter(tids: {tid}),
        ),
        groupsByTsv: {
          for (final group in groups) group.personalityShinyValue: group,
        },
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

class _PidField extends StatelessWidget {
  const _PidField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixText: '0x'),
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
        LengthLimitingTextInputFormatter(8),
        TextInputFormatter.withFunction((oldValue, newValue) {
          return newValue.copyWith(text: newValue.text.toUpperCase());
        }),
      ],
      onChanged: (_) => onChanged(),
    );
  }
}

class _TargetPidSummary extends StatelessWidget {
  const _TargetPidSummary({
    required this.tid,
    required this.pid,
    required this.names,
    required this.onSidSelected,
  });

  final int? tid;
  final int? pid;
  final Gen4NamedResources? names;
  final ValueChanged<int> onSidSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (pid == null) {
      return const SizedBox.shrink();
    }
    final pokemonPid = PokemonPid(pid!);
    final nature =
        names?.natureName(pokemonPid.nature.index) ?? pokemonPid.nature.name;
    final sidRange = tid == null
        ? null
        : Gen4ShinySidRange.fromTidPid(tid: tid!, pid: pid!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.idRngPidSummary(
            pokemonPid.personalityShinyValue.toString(),
            nature,
          ),
        ),
        if (sidRange != null) ...[
          const SizedBox(height: 4),
          Text(l10n.idRngSidRange(sidRange.display)),
          const SizedBox(height: 4),
          Text(
            l10n.idRngSidCandidates(sidRange.values.map(_padId).join(' / ')),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final sid in sidRange.values)
                ActionChip(
                  label: Text(_padId(sid)),
                  onPressed: () => onSidSelected(sid),
                ),
            ],
          ),
        ],
      ],
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

int? _parseOptionalPid(TextEditingController controller) {
  final text = controller.text.trim().replaceFirst(RegExp('^0x'), '');
  if (text.isEmpty) {
    return null;
  }
  return int.tryParse(text, radix: 16);
}

bool _validU16(int? value) {
  return value == null || value >= 0 && value <= 0xffff;
}

String _seedHex(int seed) {
  return seed.toRadixString(16).padLeft(8, '0').toUpperCase();
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/gen4/gen4.dart';
import '../../data/gen4/named_resources.dart';
import '../../l10n/app_localizations.dart';

class PidTargetFinderPage extends StatefulWidget {
  const PidTargetFinderPage({super.key, required this.tid});

  final int? tid;

  @override
  State<PidTargetFinderPage> createState() => _PidTargetFinderPageState();
}

class _PidTargetFinderPageState extends State<PidTargetFinderPage> {
  final _hpController = TextEditingController(text: '30');
  final _atkController = TextEditingController(text: '30');
  final _defController = TextEditingController(text: '30');
  final _spaController = TextEditingController(text: '30');
  final _spdController = TextEditingController(text: '30');
  final _speController = TextEditingController(text: '30');
  final _natures = <Nature>{
    Nature.adamant,
    Nature.modest,
    Nature.timid,
    Nature.jolly,
  };
  List<Gen4PidTargetGroup>? _groups;
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
    _hpController.dispose();
    _atkController.dispose();
    _defController.dispose();
    _spaController.dispose();
    _spdController.dispose();
    _speController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.idRngPidTargetFinder)),
      body: FutureBuilder<Gen4NamedResources>(
        future: _namesFuture,
        builder: (context, snapshot) {
          final names = snapshot.data;
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            children: [
              _SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.idRngPidTargetNatures,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final nature in Nature.values)
                          FilterChip(
                            label: Text(
                              names?.natureName(nature.index) ?? nature.name,
                            ),
                            selected: _natures.contains(nature),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _natures.add(nature);
                                } else {
                                  _natures.remove(nature);
                                }
                                _groups = null;
                                _error = null;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.idRngPidTargetMinIvs,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    _InputGrid(
                      children: [
                        _NumberField(
                          label: l10n.hpIv,
                          controller: _hpController,
                          onChanged: _clearResults,
                        ),
                        _NumberField(
                          label: l10n.atkIv,
                          controller: _atkController,
                          onChanged: _clearResults,
                        ),
                        _NumberField(
                          label: l10n.defIv,
                          controller: _defController,
                          onChanged: _clearResults,
                        ),
                        _NumberField(
                          label: l10n.spaIv,
                          controller: _spaController,
                          onChanged: _clearResults,
                        ),
                        _NumberField(
                          label: l10n.spdIv,
                          controller: _spdController,
                          onChanged: _clearResults,
                        ),
                        _NumberField(
                          label: l10n.speIv,
                          controller: _speController,
                          onChanged: _clearResults,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: _search,
                      child: Text(l10n.idRngPidTargetSearch),
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
              Text(
                l10n.idRngPidTargetResults,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _PidTargetResults(
                groups: _groups,
                tid: widget.tid,
                names: names,
                onSelected: (target) => Navigator.of(context).pop(target),
              ),
            ],
          );
        },
      ),
    );
  }

  void _search() {
    final l10n = AppLocalizations.of(context);
    final minIvs = _minIvs();
    if (minIvs == null || _natures.isEmpty) {
      setState(() {
        _error = l10n.idRngPidTargetInvalidInput;
        _groups = null;
      });
      return;
    }
    try {
      final groups = Gen4PidTargetSearcher(
        minIvs: minIvs,
        natures: _natures,
      ).searchMethod1Groups();
      setState(() {
        _groups = groups;
        _error = null;
      });
    } catch (_) {
      setState(() {
        _error = l10n.idRngPidTargetInvalidInput;
        _groups = null;
      });
    }
  }

  Ivs? _minIvs() {
    final values = [
      _parseIv(_hpController),
      _parseIv(_atkController),
      _parseIv(_defController),
      _parseIv(_spaController),
      _parseIv(_spdController),
      _parseIv(_speController),
    ];
    if (values.any((value) => value == null)) {
      return null;
    }
    return Ivs(
      hp: values[0]!,
      attack: values[1]!,
      defense: values[2]!,
      specialAttack: values[3]!,
      specialDefense: values[4]!,
      speed: values[5]!,
    );
  }

  void _clearResults() {
    setState(() {
      _groups = null;
      _error = null;
    });
  }
}

class _PidTargetResults extends StatelessWidget {
  const _PidTargetResults({
    required this.groups,
    required this.tid,
    required this.names,
    required this.onSelected,
  });

  final List<Gen4PidTargetGroup>? groups;
  final int? tid;
  final Gen4NamedResources? names;
  final ValueChanged<Gen4PidTarget> onSelected;

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
        for (final group in groups.take(40)) ...[
          _SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_groupSummary(l10n, group, tid)),
                const SizedBox(height: 8),
                for (final target in group.targets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: OutlinedButton(
                      onPressed: () => onSelected(target),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(_targetLabel(l10n, target, names)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
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
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
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

int? _parseIv(TextEditingController controller) {
  final text = controller.text.trim();
  if (text.isEmpty) {
    return null;
  }
  final value = int.tryParse(text);
  if (value == null || value < 0 || value > 31) {
    return null;
  }
  return value;
}

String _groupSummary(
  AppLocalizations l10n,
  Gen4PidTargetGroup group,
  int? tid,
) {
  final sidRange = tid == null ? null : group.sidRangeForTid(tid);
  return sidRange == null
      ? l10n.idRngPidTargetGroup(
          group.personalityShinyValue.toString(),
          group.targets.length.toString(),
        )
      : l10n.idRngPidTargetGroupWithSid(
          group.personalityShinyValue.toString(),
          group.targets.length.toString(),
          sidRange.display,
        );
}

String _targetLabel(
  AppLocalizations l10n,
  Gen4PidTarget target,
  Gen4NamedResources? names,
) {
  final nature = names?.natureName(target.nature.index) ?? target.nature.name;
  return l10n.idRngPidTargetResult(
    target.pid.hex,
    nature,
    target.ivs.toString(),
    (target.abilitySlot + 1).toString(),
  );
}

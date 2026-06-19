import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/gen4/gen4.dart';
import '../../data/gen4/named_resources.dart';
import '../../l10n/app_localizations.dart';
import '../gen4_excellent_sid_targets.dart';

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
  const ExcellentSidFinderPage({super.key, required this.tid});

  final int? tid;

  @override
  State<ExcellentSidFinderPage> createState() => _ExcellentSidFinderPageState();
}

class _ExcellentSidFinderPageState extends State<ExcellentSidFinderPage> {
  late final _tidController = TextEditingController(
    text: widget.tid == null || widget.tid == 0 ? '' : '${widget.tid}',
  );
  final _minIvController = TextEditingController(text: '28');
  List<Gen4PidTargetGroup>? _groups;
  String? _error;
  bool _includeNeutralNatures = false;
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
    _tidController.dispose();
    _minIvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                          _sort = sort;
                          final groups = _groups;
                          if (groups != null) {
                            _groups = sortExcellentSidGroups(groups, sort);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: _search,
                      child: Text(l10n.idRngExcellentSidSearch),
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
    if (tid == null) {
      setState(() {
        _groups = null;
        _error = l10n.idRngTidRequired;
      });
      return;
    }
    if (!_validU16(tid) || minIv == null || minIv < 0 || minIv > 31) {
      setState(() {
        _groups = null;
        _error = l10n.idRngInvalidInput;
      });
      return;
    }
    try {
      setState(() {
        _groups = excellentSidTargetGroups(
          minIv: minIv,
          includeNeutralNatures: _includeNeutralNatures,
          sort: _sort,
        );
        _error = null;
      });
    } catch (_) {
      setState(() {
        _groups = null;
        _error = l10n.idRngPidTargetInvalidInput;
      });
    }
  }

  void _clearResults() {
    setState(() {
      _groups = null;
      _error = null;
    });
  }
}

class _ExcellentSidResults extends StatelessWidget {
  const _ExcellentSidResults({
    required this.groups,
    required this.tid,
    required this.names,
    required this.onSelected,
  });

  final List<Gen4PidTargetGroup>? groups;
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

  final Gen4PidTargetGroup group;
  final int? tid;
  final Gen4NamedResources? names;
  final ValueChanged<ExcellentSidSelection> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sidRange = tid == null ? null : group.sidRangeForTid(tid!);
    return _SurfaceCard(
      onTap: tid == null || sidRange == null
          ? null
          : () => onSelected(
              ExcellentSidSelection(
                tid: tid!,
                sidRange: sidRange,
                group: group,
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
                  group.personalityShinyValue.toString(),
                ),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(l10n.idRngPidTargetCount(group.targets.length.toString())),
              Text(
                l10n.idRngNatureCount(
                  excellentSidNatureCount(group).toString(),
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

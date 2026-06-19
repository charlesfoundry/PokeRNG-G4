import 'package:flutter/material.dart';

import '../../core/gen4/gen4.dart';
import '../../data/gen4/named_resources.dart';
import '../../l10n/app_localizations.dart';
import '../gen4_hit_reverse_search.dart';
import '../search_results.dart';

class HitReversePage extends StatefulWidget {
  const HitReversePage({super.key, required this.request, required this.names});

  final Gen4HitReverseRequest request;
  final Gen4NamedResources names;

  @override
  State<HitReversePage> createState() => _HitReversePageState();
}

class _HitReversePageState extends State<HitReversePage> {
  late final Future<List<Gen4HitReverseResult>> _results;

  @override
  void initState() {
    super.initState();
    _results = Future(() => searchGen4HitReverse(widget.request));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reverseHitTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: _ReverseTargetCard(
              target: widget.request.target,
              names: widget.names,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Gen4HitReverseResult>>(
              future: _results,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final results = snapshot.data!;
                if (results.isEmpty) {
                  return Center(child: Text(l10n.reverseHitNoResults));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return _ReverseHitCard(
                      result: result,
                      request: widget.request,
                      names: widget.names,
                      onSelected: () => Navigator.of(context).pop(result),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemCount: results.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReverseTargetCard extends StatelessWidget {
  const _ReverseTargetCard({required this.target, required this.names});

  final Gen4SearchResultRow target;
  final Gen4NamedResources names;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(target.target, style: theme.textTheme.bodySmall),
                ),
                if (target.shiny) const _ShinyIcon(),
                Text(l10n.target, style: theme.textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: 8),
            _FieldRow(
              children: [
                _Field(label: l10n.seed, value: target.seed),
                _Field(label: l10n.delay, value: '${target.delay}'),
                _Field(label: l10n.advance, value: '${target.advance}'),
              ],
            ),
            const SizedBox(height: 8),
            _FieldRow(
              children: [
                _Field(
                  label: l10n.levelShort,
                  value: target.level?.toString() ?? '-',
                ),
                _Field(
                  label: l10n.nature,
                  value: _targetNatureValue(names, target.natureId),
                ),
                _Field(label: l10n.pid, value: target.pid ?? '-'),
              ],
            ),
            const SizedBox(height: 8),
            _FieldRow(
              children: [
                _Field(label: l10n.ivs, value: target.ivs, span: 2),
                _Field(label: l10n.stats, value: target.stats ?? '-'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReverseHitCard extends StatelessWidget {
  const _ReverseHitCard({
    required this.result,
    required this.request,
    required this.names,
    required this.onSelected,
  });

  final Gen4HitReverseResult result;
  final Gen4HitReverseRequest request;
  final Gen4NamedResources names;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isTargetSeed =
        result.seedHex == request.target.seed.toUpperCase().padLeft(8, '0');
    final shiny = result.isShiny(tid: request.tid, sid: request.sid);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSelected,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        names.speciesName(result.speciesId),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    if (shiny) const _ShinyIcon(),
                    Text(
                      isTargetSeed
                          ? l10n.reverseHitTargetSeed
                          : l10n.reverseHitNearbySeed,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _FieldRow(
                  children: [
                    _Field(label: l10n.seed, value: result.seedHex),
                    _Field(label: l10n.delay, value: '${result.delay}'),
                    _Field(label: l10n.advance, value: '${result.advance}'),
                  ],
                ),
                const SizedBox(height: 8),
                _FieldRow(
                  children: [
                    _Field(label: l10n.levelShort, value: '${result.level}'),
                    _Field(
                      label: l10n.slot,
                      value: result.encounterSlot?.toString() ?? '-',
                    ),
                    _Field(
                      label: l10n.nature,
                      value: names.natureName(result.nature.index),
                    ),
                    _Field(
                      label: l10n.gender,
                      value: _genderValue(l10n, result.gender),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _FieldRow(
                  children: [
                    _Field(
                      label: l10n.ability,
                      value: _abilityValue(result.abilitySlot),
                    ),
                    _Field(
                      label: l10n.ivs,
                      value: result.ivs.toString(),
                      span: 2,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _FieldRow(
                  children: [
                    _Field(
                      label: l10n.hiddenPower,
                      value:
                          '${_hiddenPowerTypeLabel(l10n, result.hiddenPowerType)} '
                          '${result.hiddenPowerStrength}',
                    ),
                    _Field(
                      label: l10n.stats,
                      value: result.stats.toString(),
                      span: 2,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _abilityValue(int abilitySlot) {
    final source = request.target.source;
    final abilityIds = source?.abilityIds ?? const [];
    final slotLabel = '${abilitySlot + 1}';
    if (abilitySlot < 0 || abilitySlot >= abilityIds.length) {
      return slotLabel;
    }
    return '$slotLabel·${names.abilityName(abilityIds[abilitySlot])}';
  }
}

class _ShinyIcon extends StatelessWidget {
  const _ShinyIcon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: Tooltip(
        message: AppLocalizations.of(context).shiny,
        child: Icon(
          Icons.auto_awesome,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.span = 1});

  final String label;
  final String value;
  final int span;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: span,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.children});

  final List<_Field> children;

  @override
  Widget build(BuildContext context) {
    assert(children.fold<int>(0, (sum, child) => sum + child.span) == 3);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < children.length; index += 1) ...[
          children[index],
          if (index != children.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

String _genderValue(AppLocalizations l10n, PokemonGender gender) {
  return switch (gender) {
    PokemonGender.male => l10n.genderMale,
    PokemonGender.female => l10n.genderFemale,
    PokemonGender.genderless => l10n.genderGenderless,
  };
}

String _targetNatureValue(Gen4NamedResources names, int? natureId) {
  if (natureId == null || natureId < 0 || natureId >= Nature.values.length) {
    return '-';
  }
  return names.natureName(natureId);
}

String _hiddenPowerTypeLabel(AppLocalizations l10n, int type) {
  return switch (type) {
    0 => l10n.typeFighting,
    1 => l10n.typeFlying,
    2 => l10n.typePoison,
    3 => l10n.typeGround,
    4 => l10n.typeRock,
    5 => l10n.typeBug,
    6 => l10n.typeGhost,
    7 => l10n.typeSteel,
    8 => l10n.typeFire,
    9 => l10n.typeWater,
    10 => l10n.typeGrass,
    11 => l10n.typeElectric,
    12 => l10n.typePsychic,
    13 => l10n.typeIce,
    14 => l10n.typeDragon,
    15 => l10n.typeDark,
    _ => '$type',
  };
}

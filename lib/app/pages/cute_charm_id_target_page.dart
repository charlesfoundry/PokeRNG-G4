import 'package:flutter/material.dart';

import '../../core/gen4/gen4.dart';
import '../../data/gen4/named_resources.dart';
import '../../l10n/app_localizations.dart';

class CuteCharmIdTargetPage extends StatefulWidget {
  const CuteCharmIdTargetPage({
    super.key,
    required this.lead,
    required this.genderRatio,
    required this.natureId,
  });

  final Gen4CuteCharmLead lead;
  final int genderRatio;
  final int natureId;

  @override
  State<CuteCharmIdTargetPage> createState() => _CuteCharmIdTargetPageState();
}

class _CuteCharmIdTargetPageState extends State<CuteCharmIdTargetPage> {
  static const _genderRatios = [31, 63, 127, 191];

  late Gen4CuteCharmLead _lead = widget.lead;
  late int _genderRatio = widget.genderRatio;
  late int _natureId = widget.natureId;
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.cuteCharmIdTarget)),
      body: FutureBuilder<Gen4NamedResources>(
        future: _namesFuture,
        builder: (context, snapshot) {
          final target = Gen4CuteCharmIdTarget.create(
            lead: _lead,
            genderRatio: _genderRatio,
            nature: Nature.values[_natureId],
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            children: [
              _SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InputGrid(
                      children: [
                        DropdownButtonFormField<Gen4CuteCharmLead>(
                          isExpanded: true,
                          initialValue: _lead,
                          decoration: InputDecoration(labelText: l10n.lead),
                          items: [
                            DropdownMenuItem(
                              value: Gen4CuteCharmLead.male,
                              child: Text(l10n.leadCuteCharmMale),
                            ),
                            DropdownMenuItem(
                              value: Gen4CuteCharmLead.female,
                              child: Text(l10n.leadCuteCharmFemale),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _lead = value);
                            }
                          },
                        ),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: _genderRatio,
                          decoration: InputDecoration(
                            labelText: l10n.genderRatio,
                          ),
                          items: [
                            for (final ratio in _genderRatios)
                              DropdownMenuItem(
                                value: ratio,
                                child: Text(_genderRatioLabel(ratio)),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _genderRatio = value);
                            }
                          },
                        ),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue: _natureId,
                          decoration: InputDecoration(labelText: l10n.nature),
                          items: [
                            for (
                              var nature = 0;
                              nature < Nature.values.length;
                              nature += 1
                            )
                              DropdownMenuItem(
                                value: nature,
                                child: Text(
                                  snapshot.data?.natureName(nature) ?? '',
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _natureId = value);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.cuteCharmIdSummary(
                        _seedHex(target.pid),
                        target.trainerShinyValue.toString(),
                        (target.abilitySlot + 1).toString(),
                        _genderLabel(l10n, target.targetGender),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(target),
                      child: Text(l10n.cuteCharmApplyIdTarget),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
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

String _genderLabel(AppLocalizations l10n, PokemonGender gender) {
  return switch (gender) {
    PokemonGender.male => l10n.genderMale,
    PokemonGender.female => l10n.genderFemale,
    PokemonGender.genderless => l10n.genderGenderless,
  };
}

String _genderRatioLabel(int genderRatio) {
  return switch (genderRatio) {
    31 => '♂87.5% / ♀12.5%',
    63 => '♂75% / ♀25%',
    127 => '♂50% / ♀50%',
    191 => '♂25% / ♀75%',
    _ => '♂ / ♀',
  };
}

String _seedHex(int seed) {
  return seed.toRadixString(16).padLeft(8, '0').toUpperCase();
}

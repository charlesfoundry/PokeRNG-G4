import 'package:flutter/material.dart';

import '../../core/gen4/gen4.dart';
import '../../data/gen4/named_resources.dart';
import '../../l10n/app_localizations.dart';
import '../dppt_egg_pickup_search_job.dart';
import '../search_results.dart';

class DpptEggPickupResultsPage extends StatefulWidget {
  const DpptEggPickupResultsPage({super.key, required this.request});

  final DpptEggPickupSearchRequest request;

  @override
  State<DpptEggPickupResultsPage> createState() =>
      _DpptEggPickupResultsPageState();
}

class _DpptEggPickupResultsPageState extends State<DpptEggPickupResultsPage> {
  DpptEggPickupSearchJob? _job;
  Gen4SearchRunState _state = Gen4SearchRunState.running;
  Gen4SearchProgress? _progress;
  List<DpptEggPickupSearchResult> _results = const [];
  bool _resultLimitReached = false;
  String? _error;
  Future<Gen4NamedResources>? _names;
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
      _names = Gen4NamedResources.load(localeName);
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.eggPickupResultsTitle)),
      body: FutureBuilder<Gen4NamedResources>(
        future: _names,
        builder: (context, snapshot) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            children: [
              if (_state == Gen4SearchRunState.running) ...[
                _SearchProgressBar(
                  progress: _progress,
                  onCancelSearch: _cancelSearch,
                ),
                const SizedBox(height: 12),
              ] else if (_state == Gen4SearchRunState.failed ||
                  _state == Gen4SearchRunState.cancelled ||
                  _results.isEmpty) ...[
                _StatusMessage(state: _state, error: _error),
                const SizedBox(height: 12),
              ],
              if (_results.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.resultCount(_formatInt(_results.length)),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    if (_resultLimitReached)
                      Text(
                        l10n.resultLimitReached,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final result in _results) ...[
                  _EggPickupResultCard(
                    result: result,
                    names: snapshot.data,
                    onTap: () => Navigator.of(context).pop(result),
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

  Future<void> _startSearch() async {
    try {
      _job = await DpptEggPickupSearchJob.start(
        request: widget.request,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _progress = progress);
          }
        },
        onComplete: (result) {
          if (!mounted) {
            return;
          }
          setState(() {
            _job = null;
            _state = Gen4SearchRunState.completed;
            _progress = result.progress;
            _results = result.results;
            _resultLimitReached = result.resultLimitReached;
            _error = null;
          });
        },
        onError: (error) {
          if (!mounted) {
            return;
          }
          setState(() {
            _job = null;
            _state = Gen4SearchRunState.failed;
            _error = error;
          });
        },
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _state = Gen4SearchRunState.failed;
          _error = error.toString();
        });
      }
    }
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

class _EggPickupResultCard extends StatelessWidget {
  const _EggPickupResultCard({
    required this.result,
    required this.names,
    required this.onTap,
  });

  final DpptEggPickupSearchResult result;
  final Gen4NamedResources? names;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ResultLine(
                  children: [
                    '${l10n.seed}: ${result.seedHex}',
                    '${l10n.delay}: ${result.rawDelay}',
                    '${l10n.eggPickupAdvance}: ${result.pickupAdvance}',
                  ],
                ),
                const SizedBox(height: 4),
                _ResultLine(
                  children: [
                    '${l10n.pid}: ${_hex32(result.pid)}',
                    _natureName(names, result.nature),
                    _genderLabel(l10n, result.gender),
                    '${l10n.ability}: ${result.abilitySlot + 1}',
                    if (result.shiny.isShiny) l10n.shiny,
                  ],
                ),
                const SizedBox(height: 4),
                Text('${l10n.ivs}: ${_ivs(result.ivs)}'),
                const SizedBox(height: 4),
                _ResultLine(
                  children: [
                    '${l10n.hiddenPower}: ${_hiddenPowerTypeLabel(l10n, result.hiddenPowerType)} ${result.hiddenPowerStrength}',
                    '${l10n.eggInheritance}: ${_inheritance(result.inheritance)}',
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.children});

  final List<String> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 2,
      children: [for (final child in children) Text(child)],
    );
  }
}

String _natureName(Gen4NamedResources? names, Nature nature) {
  return names?.natureName(nature.index) ?? nature.name;
}

String _genderLabel(AppLocalizations l10n, PokemonGender gender) {
  return switch (gender) {
    PokemonGender.male => l10n.genderMale,
    PokemonGender.female => l10n.genderFemale,
    PokemonGender.genderless => l10n.genderGenderless,
  };
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

String _inheritance(List<int> inheritance) {
  const stats = ['HP', 'Atk', 'Def', 'SpA', 'SpD', 'Spe'];
  final parts = <String>[];
  for (var i = 0; i < inheritance.length; i += 1) {
    final parent = inheritance[i];
    if (parent != 0) {
      parts.add('${stats[i]}:P$parent');
    }
  }
  return parts.isEmpty ? '-' : parts.join(' ');
}

String _ivs(List<int> ivs) {
  return ivs.join('/');
}

String _hex32(int value) {
  return value.toRadixString(16).toUpperCase().padLeft(8, '0');
}

String _formatInt(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i += 1) {
    final remaining = text.length - i;
    buffer.write(text[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

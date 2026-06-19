import 'package:flutter/material.dart';

import '../../core/gen4/pokemon_attributes.dart';
import '../../data/gen4/named_resources.dart';
import '../../l10n/app_localizations.dart';
import '../search_results.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({
    required this.snapshot,
    required this.onCancelSearch,
    this.onSendToCalibration,
    this.onSaveTarget,
    super.key,
  });

  final Gen4SearchResultsSnapshot snapshot;
  final VoidCallback? onCancelSearch;
  final ValueChanged<Gen4SearchResultRow>? onSendToCalibration;
  final ValueChanged<Gen4SearchResultRow>? onSaveTarget;

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  String? _localeName;
  Future<Gen4NamedResources>? _names;

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
  Widget build(BuildContext context) {
    return FutureBuilder<Gen4NamedResources>(
      future: _names,
      builder: (context, snapshot) {
        return _buildContent(context, snapshot.data);
      },
    );
  }

  Widget _buildContent(BuildContext context, Gen4NamedResources? names) {
    final l10n = AppLocalizations.of(context);
    final resultCount = widget.snapshot.resultLimitReached
        ? '${_formatInt(widget.snapshot.results.length)}+'
        : _formatInt(widget.snapshot.results.length);
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.results,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (widget.snapshot.hasResults)
              Text(resultCount, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        if (widget.snapshot.isRunning && widget.onCancelSearch != null) ...[
          const SizedBox(height: 10),
          _SearchProgressBar(
            progress: widget.snapshot.progress,
            onCancelSearch: widget.onCancelSearch!,
          ),
        ] else if (!widget.snapshot.hasResults ||
            widget.snapshot.state == Gen4SearchRunState.failed ||
            widget.snapshot.state == Gen4SearchRunState.cancelled) ...[
          const SizedBox(height: 12),
          _StatusMessage(snapshot: widget.snapshot),
        ],
        if (widget.snapshot.hasResults) ...[
          if (widget.snapshot.resultLimitReached) ...[
            const SizedBox(height: 8),
            Text(
              l10n.resultLimitReached,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
          const SizedBox(height: 12),
          for (final result in widget.snapshot.results) ...[
            _ResultCard(
              result: result,
              names: names,
              onSendToCalibration: widget.onSendToCalibration,
              onSaveTarget: widget.onSaveTarget,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ],
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
  const _StatusMessage({required this.snapshot});

  final Gen4SearchResultsSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = switch (snapshot.state) {
      Gen4SearchRunState.idle => l10n.searchResultsPlaceholder,
      Gen4SearchRunState.running => l10n.searching,
      Gen4SearchRunState.completed when snapshot.hasResults => '',
      Gen4SearchRunState.completed => l10n.noResults,
      Gen4SearchRunState.cancelled => l10n.searchCancelled,
      Gen4SearchRunState.failed => l10n.searchFailed,
    };
    final error = snapshot.error;
    final colorScheme = Theme.of(context).colorScheme;
    final isError = snapshot.state == Gen4SearchRunState.failed;

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
              error,
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

enum _ResultAction { calibrate, save }

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.names,
    required this.onSendToCalibration,
    required this.onSaveTarget,
  });

  final Gen4SearchResultRow result;
  final Gen4NamedResources? names;
  final ValueChanged<Gen4SearchResultRow>? onSendToCalibration;
  final ValueChanged<Gen4SearchResultRow>? onSaveTarget;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTapUp: (details) => _showMenu(context, details.globalPosition),
        onSecondaryTapDown: (details) =>
            _showMenu(context, details.globalPosition),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _ResultRow(result: result, names: names),
        ),
      ),
    );
  }

  Future<void> _showMenu(BuildContext context, Offset position) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final l10n = AppLocalizations.of(context);
    final action = await showMenu<_ResultAction>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<_ResultAction>(
          value: _ResultAction.calibrate,
          enabled: onSendToCalibration != null,
          child: _MenuItem(
            icon: Icons.gps_fixed,
            label: l10n.sendToCalibration,
          ),
        ),
        PopupMenuItem<_ResultAction>(
          value: _ResultAction.save,
          enabled: onSaveTarget != null,
          child: _MenuItem(icon: Icons.bookmark_add, label: l10n.saveTarget),
        ),
      ],
    );
    if (action == _ResultAction.calibrate) {
      onSendToCalibration?.call(result);
    } else if (action == _ResultAction.save) {
      onSaveTarget?.call(result);
    }
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 10),
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result, required this.names});

  final Gen4SearchResultRow result;
  final Gen4NamedResources? names;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResultFieldRow(
            cells: [
              _ResultCell(
                span: 4,
                child: Text(
                  result.target,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _resultValueStyle(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _ResultFieldRow(
            cells: [
              _ResultCell(
                child: _ResultField(label: l10n.seed, value: result.seed),
              ),
              _ResultCell(
                child: _ResultField(
                  label: l10n.delay,
                  value: '${result.delay}',
                ),
              ),
              _ResultCell(
                child: _ResultField(
                  label: l10n.advance,
                  value: '${result.advance}',
                ),
              ),
              _ResultCell(
                child: _ResultField(
                  label: l10n.nature,
                  value: _natureValue(names, result.natureId),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ResultFieldRow(
            cells: [
              _ResultCell(child: _LevelField(result: result)),
              _ResultCell(
                child: _ResultField(
                  label: l10n.gender,
                  value: _genderValue(l10n, result.gender),
                ),
              ),
              _ResultCell(
                child: _ResultField(
                  label: l10n.ability,
                  value: _abilityValue(result.abilitySlot, result.abilityName),
                ),
              ),
              _ResultCell(
                child: _ResultField(
                  label: l10n.time,
                  value: _hourValue(result.hour),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ResultFieldRow(
            cells: [
              _ResultCell(
                span: 2,
                child: _ResultField(
                  label: l10n.hiddenPower,
                  value: _hiddenPowerValue(l10n, result),
                ),
              ),
              _ResultCell(
                span: 2,
                child: _ResultField(label: l10n.ivs, value: result.ivs),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ResultFieldRow(
            cells: [
              _ResultCell(
                span: 2,
                child: _ResultField(label: l10n.pid, value: result.pid ?? '-'),
              ),
              _ResultCell(
                span: 2,
                child: _ResultField(
                  label: l10n.stats,
                  value: result.stats ?? '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultField extends StatelessWidget {
  const _ResultField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: _resultLabelStyle(context)),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _resultValueStyle(context),
        ),
      ],
    );
  }
}

class _ResultCell {
  const _ResultCell({required this.child, this.span = 1});

  final Widget child;
  final int span;
}

class _ResultFieldRow extends StatelessWidget {
  const _ResultFieldRow({required this.cells});

  final List<_ResultCell> cells;

  @override
  Widget build(BuildContext context) {
    assert(cells.fold<int>(0, (sum, cell) => sum + cell.span) == 4);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < cells.length; index += 1) ...[
          Expanded(flex: cells[index].span, child: cells[index].child),
          if (index != cells.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _LevelField extends StatelessWidget {
  const _LevelField({required this.result});

  final Gen4SearchResultRow result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final level = result.level;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.levelShort, style: _resultLabelStyle(context)),
        Row(
          children: [
            Flexible(
              child: Text(
                level == null ? '-' : '$level',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _resultValueStyle(context),
              ),
            ),
            if (result.shiny) const _ShinyIcon(),
          ],
        ),
      ],
    );
  }
}

class _ShinyIcon extends StatelessWidget {
  const _ShinyIcon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
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

String _genderLabel(AppLocalizations l10n, PokemonGender gender) {
  return switch (gender) {
    PokemonGender.male => l10n.genderMale,
    PokemonGender.female => l10n.genderFemale,
    PokemonGender.genderless => l10n.genderGenderless,
  };
}

TextStyle? _resultLabelStyle(BuildContext context) {
  final style = Theme.of(context).textTheme.labelSmall;
  final size = style?.fontSize;
  return style?.copyWith(fontSize: size == null ? null : size + 1);
}

TextStyle? _resultValueStyle(BuildContext context) {
  final style = Theme.of(context).textTheme.bodySmall;
  final size = style?.fontSize;
  return style?.copyWith(fontSize: size == null ? null : size + 1);
}

String _genderValue(AppLocalizations l10n, PokemonGender? gender) {
  return gender == null ? '-' : _genderLabel(l10n, gender);
}

String _natureValue(Gen4NamedResources? names, int? natureId) {
  if (natureId == null || natureId < 0 || natureId >= Nature.values.length) {
    return '-';
  }
  return names?.natureName(natureId) ?? Nature.values[natureId].name;
}

String _hourValue(int hour) {
  return '${hour.toString().padLeft(2, '0')}:xx';
}

String _abilityValue(int? abilitySlot, String? abilityName) {
  if (abilitySlot == null) {
    return '-';
  }
  final slotLabel = '${abilitySlot + 1}';
  return abilityName == null ? slotLabel : '$slotLabel·$abilityName';
}

String _hiddenPowerValue(AppLocalizations l10n, Gen4SearchResultRow result) {
  final hiddenPowerType = result.hiddenPowerType;
  final hiddenPowerStrength = result.hiddenPowerStrength;
  if (hiddenPowerType == null || hiddenPowerStrength == null) {
    return '-';
  }
  return '${_hiddenPowerTypeLabel(l10n, hiddenPowerType)} $hiddenPowerStrength';
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

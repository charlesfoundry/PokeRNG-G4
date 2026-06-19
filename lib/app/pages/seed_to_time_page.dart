import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/gen4/gen4.dart';
import '../../l10n/app_localizations.dart';

const _seedToTimeDisplayLimit = 200;

class SeedToTimePage extends StatefulWidget {
  const SeedToTimePage({super.key, required this.seed, required this.year});

  final int seed;
  final int year;

  @override
  State<SeedToTimePage> createState() => _SeedToTimePageState();
}

class _SeedToTimePageState extends State<SeedToTimePage> {
  late final _yearController = TextEditingController(text: '${widget.year}');
  final _monthController = TextEditingController();
  final _dayController = TextEditingController();
  List<Gen4SeedTime>? _results;
  String? _error;

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = _results;
    final displayedResults = results
        ?.take(_seedToTimeDisplayLimit)
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.seedToTimeTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        children: [
          _InputGrid(
            children: [
              _NumberField(
                label: l10n.year,
                controller: _yearController,
                enabled: false,
                onChanged: _clearResults,
              ),
              _NumberField(
                label: l10n.month,
                controller: _monthController,
                onChanged: _clearResults,
              ),
              _NumberField(
                label: l10n.day,
                controller: _dayController,
                onChanged: _clearResults,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _searchTimes,
              child: Text(l10n.seedToTimeSearch),
            ),
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
          if (results != null) ...[
            const SizedBox(height: 16),
            Text(
              l10n.resultCount((displayedResults?.length ?? 0).toString()),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            if (results.isEmpty)
              Text(
                l10n.noSeedTimeResults,
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              for (final time in displayedResults!) ...[
                _SeedTimeCard(time: time),
                const SizedBox(height: 8),
              ],
          ],
        ],
      ),
    );
  }

  void _clearResults() {
    setState(() {
      _results = null;
      _error = null;
    });
  }

  void _searchTimes() {
    final l10n = AppLocalizations.of(context);
    final month = _optionalInt(_monthController);
    final day = _optionalInt(_dayController);
    final searchYear = widget.year;
    if (searchYear < 2000 || searchYear > 2099) {
      setState(() => _error = l10n.seedToTimeInvalidFilter);
      return;
    }
    if (month != null && (month < 1 || month > 12)) {
      setState(() => _error = l10n.seedToTimeInvalidFilter);
      return;
    }
    if (day != null && (day < 1 || day > 31)) {
      setState(() => _error = l10n.seedToTimeInvalidFilter);
      return;
    }
    final results =
        Gen4SeedTime.calculateTimes(seed: widget.seed, year: searchYear)
            .where((time) {
              return (month == null || time.dateTime.month == month) &&
                  (day == null || time.dateTime.day == day);
            })
            .toList(growable: false);
    setState(() {
      _results = results;
      _error = null;
    });
  }
}

class _SeedTimeCard extends StatelessWidget {
  const _SeedTimeCard({required this.time});

  final Gen4SeedTime time;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(time),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(_dateTimeValue(time.dateTime)),
                Text('${l10n.delay}: ${time.delay}'),
                Text('${l10n.second}: ${time.dateTime.second}'),
              ],
            ),
          ),
        ),
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
        const columns = 3;
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
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => onChanged(),
    );
  }
}

int? _optionalInt(TextEditingController controller) {
  final text = controller.text.trim();
  if (text.isEmpty) {
    return null;
  }
  return int.tryParse(text);
}

String _dateTimeValue(DateTime dateTime) {
  return '${dateTime.year.toString().padLeft(4, '0')}-'
      '${dateTime.month.toString().padLeft(2, '0')}-'
      '${dateTime.day.toString().padLeft(2, '0')} '
      '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}:'
      '${dateTime.second.toString().padLeft(2, '0')}';
}

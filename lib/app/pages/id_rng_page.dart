import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/gen4/gen4.dart';
import '../../l10n/app_localizations.dart';
import '../app_profile.dart';
import '../widgets/gen4_rng_timer_panel.dart';
import 'id_hit_results_page.dart';
import 'reachable_excellent_sid_page.dart';
import 'seed_to_time_page.dart';

class IdRngPage extends StatefulWidget {
  const IdRngPage({
    super.key,
    required this.profile,
    required this.onProfileChanged,
  });

  final AppProfile profile;
  final ValueChanged<AppProfile> onProfileChanged;

  @override
  State<IdRngPage> createState() => _IdRngPageState();
}

class _IdRngPageState extends State<IdRngPage> {
  final _hitTidController = TextEditingController();
  final _hitDelayWindowController = TextEditingController(text: '100');
  Gen4IdState? _selectedState;
  int? _selectedYear;
  Gen4SeedTime? _selectedSeedTime;
  Gen4IdHit? _selectedHit;
  bool _hitSearching = false;
  String? _hitError;

  @override
  void dispose() {
    _hitTidController.dispose();
    _hitDelayWindowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.idRng)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: _openReachableExcellentSidPage,
              icon: const Icon(Icons.travel_explore),
              label: Text(l10n.idRngReachableExcellentSidFinder),
            ),
          ),
          const SizedBox(height: 16),
          _SelectedIdStateCard(state: _selectedState),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: _selectedState == null ? null : _openSeedToTime,
              child: Text(l10n.seedToTime),
            ),
          ),
          if (_selectedSeedTime != null) ...[
            const SizedBox(height: 10),
            _SelectedSeedTimeCard(time: _selectedSeedTime!),
          ],
          Text(l10n.idRngTimer, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Gen4RngTimerPanel(
            slot: Gen4TimerCalibrationSlot.id,
            profile: widget.profile,
            targetDelay: _selectedSeedTime?.delay,
            targetSecond: _selectedSeedTime?.dateTime.second,
            targetDateTime: _selectedSeedTime?.dateTime,
            delayHit: _selectedHit?.state.delay,
            delayHitToken: _selectedHit,
            hitSecond: _selectedHit?.seedTime.dateTime.second,
            lockDelayHit: _selectedHit != null,
            onCalibrationApplied: _saveTimerCalibration,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.idRngHitCheck,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _InputGrid(
            children: [
              _NumberField(
                label: l10n.trainerId,
                controller: _hitTidController,
                onChanged: _clearHitState,
              ),
              _NumberField(
                label: l10n.idRngHitDelayWindow,
                controller: _hitDelayWindowController,
                onChanged: _clearHitState,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: _hitSearching ? null : _searchHit,
              child: Text(_hitSearching ? l10n.searching : l10n.idRngSearchHit),
            ),
          ),
          if (_hitError != null) ...[
            const SizedBox(height: 8),
            Text(
              _hitError!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ],
          if (_selectedHit != null) ...[
            const SizedBox(height: 10),
            _SelectedIdHitCard(hit: _selectedHit!),
          ],
        ],
      ),
    );
  }

  Future<void> _openSeedToTime() async {
    final state = _selectedState;
    if (state == null) {
      return;
    }
    final result = await Navigator.of(context).push<Gen4SeedTime>(
      MaterialPageRoute(
        builder: (_) => SeedToTimePage(
          seed: state.seed,
          year: _selectedYear ?? _currentYear(),
        ),
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    setState(() {
      _selectedSeedTime = result;
      _selectedHit = null;
      _hitError = null;
    });
  }

  Future<void> _searchHit() async {
    final l10n = AppLocalizations.of(context);
    final target = _selectedSeedTime;
    final tid = _parseOptionalInt(_hitTidController);
    final delayWindow = _parseOptionalInt(_hitDelayWindowController);
    if (target == null) {
      setState(() => _hitError = l10n.idRngNoSeedTime);
      return;
    }
    if (!_validU16(tid) ||
        tid == null ||
        delayWindow == null ||
        delayWindow < 0) {
      setState(() => _hitError = l10n.idRngInvalidInput);
      return;
    }
    final secondWindow = widget.profile.secondWindow;
    setState(() {
      _hitSearching = true;
      _hitError = null;
      _selectedHit = null;
    });
    try {
      final hits = await compute(
        _runIdHitSearch,
        _IdHitSearchQuery(
          target: target,
          delayWindow: delayWindow,
          secondWindow: secondWindow,
          tid: tid,
        ),
      );
      if (!mounted) {
        return;
      }
      if (hits.isEmpty) {
        setState(() {
          _selectedHit = null;
          _hitError = l10n.idRngNoHit;
          _hitSearching = false;
        });
        return;
      }
      if (hits.length == 1) {
        setState(() {
          _selectedHit = hits.first;
          _hitError = null;
          _hitSearching = false;
        });
        return;
      }
      setState(() => _hitSearching = false);
      final selected = await Navigator.of(context).push<Gen4IdHit>(
        MaterialPageRoute(builder: (_) => IdHitResultsPage(hits: hits)),
      );
      if (!mounted || selected == null) {
        return;
      }
      setState(() {
        _selectedHit = selected;
        _hitError = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hitError = l10n.searchFailed;
        _hitSearching = false;
      });
    }
  }

  void _clearHitState() {
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedHit = null;
      _hitError = null;
    });
  }

  Future<void> _openReachableExcellentSidPage() async {
    final result = await Navigator.of(context)
        .push<ReachableExcellentSidSelection>(
          MaterialPageRoute(
            builder: (_) => ReachableExcellentSidPage(
              game: widget.profile.game,
              tid: _selectedState?.tid,
              year: _selectedYear ?? _currentYear(),
              minDelay: 5500,
              maxDelay: 6000,
            ),
          ),
        );
    if (!mounted || result == null) {
      return;
    }
    final state = result.state;
    setState(() {
      _selectedState = state;
      _selectedYear = result.year;
      _selectedSeedTime = null;
      _selectedHit = null;
      _hitError = null;
    });
  }

  void _saveTimerCalibration(Gen4TimerCalibrationChange change) {
    widget.onProfileChanged(
      widget.profile.copyWith(
        idCalibratedDelay: change.nextCalibratedDelay,
        calibratedSecond: change.nextCalibratedSecond,
      ),
    );
  }
}

class _SelectedIdStateCard extends StatelessWidget {
  const _SelectedIdStateCard({required this.state});

  final Gen4IdState? state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = this.state;
    if (state == null) {
      return _SurfaceCard(child: Text(l10n.idRngSelectResultFirst));
    }
    return _SurfaceCard(
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          Text(l10n.idRngSelectedState),
          Text('${l10n.seed}: ${_seedHex(state.seed)}'),
          Text('${l10n.delay}: ${state.delay}'),
          Text('${l10n.trainerId}: ${_padId(state.tid)}'),
          Text('${l10n.secretId}: ${_padId(state.sid)}'),
          Text('TSV: ${state.trainerShinyValue}'),
        ],
      ),
    );
  }
}

class _SelectedSeedTimeCard extends StatelessWidget {
  const _SelectedSeedTimeCard({required this.time});

  final Gen4SeedTime time;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _SurfaceCard(
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          Text(l10n.selectedSeedTime),
          Text(_dateTimeValue(time.dateTime)),
          Text('${l10n.delay}: ${time.delay}'),
          Text('${l10n.second}: ${time.dateTime.second}'),
        ],
      ),
    );
  }
}

class _SelectedIdHitCard extends StatelessWidget {
  const _SelectedIdHitCard({required this.hit});

  final Gen4IdHit hit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = hit.state;
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(l10n.idRngSelectedHit),
              Text('${l10n.seed}: ${_seedHex(state.seed)}'),
              Text('${l10n.delay}: ${state.delay}'),
              Text('${l10n.second}: ${hit.seedTime.dateTime.second}'),
              Text('${l10n.trainerId}: ${_padId(state.tid)}'),
              Text('${l10n.secretId}: ${_padId(state.sid)}'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.idRngHitHelp,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
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
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

class _IdHitSearchQuery {
  const _IdHitSearchQuery({
    required this.target,
    required this.delayWindow,
    required this.secondWindow,
    required this.tid,
  });

  final Gen4SeedTime target;
  final int delayWindow;
  final int secondWindow;
  final int tid;
}

List<Gen4IdHit> _runIdHitSearch(_IdHitSearchQuery query) {
  return Gen4IdHitSearcher(
    target: query.target,
    delayWindow: query.delayWindow,
    secondWindow: query.secondWindow,
    tid: query.tid,
  ).search();
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

int _currentYear() {
  return DateTime.now().year.clamp(2000, 2099).toInt();
}

String _seedHex(int seed) {
  return seed.toRadixString(16).padLeft(8, '0').toUpperCase();
}

String _padId(int value) {
  return value.toString().padLeft(5, '0');
}

String _dateTimeValue(DateTime dateTime) {
  return '${dateTime.year.toString().padLeft(4, '0')}-'
      '${dateTime.month.toString().padLeft(2, '0')}-'
      '${dateTime.day.toString().padLeft(2, '0')} '
      '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}:'
      '${dateTime.second.toString().padLeft(2, '0')}';
}

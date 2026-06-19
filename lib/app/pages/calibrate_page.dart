import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/gen4/gen4.dart';
import '../../data/gen4/gen4_game.dart';
import '../../data/gen4/named_resources.dart';
import '../../data/gen4/personal_data.dart';
import '../../data/gen4/wild_encounter_repository.dart';
import '../../data/gen4/wild_encounters.dart';
import '../../l10n/app_localizations.dart';
import '../app_profile.dart';
import '../gen4_hit_reverse_search.dart';
import '../search_results.dart';
import '../widgets/gen4_rng_timer_panel.dart';
import 'hit_reverse_page.dart';
import 'seed_check_page.dart';
import 'seed_to_time_page.dart';

class CalibratePage extends StatefulWidget {
  const CalibratePage({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    this.target,
  });

  final AppProfile profile;
  final ValueChanged<AppProfile> onProfileChanged;
  final Gen4SearchResultRow? target;

  @override
  State<CalibratePage> createState() => _CalibratePageState();
}

class _CalibratePageState extends State<CalibratePage> {
  late Gen4SeedCheckMode _mode;
  final _yearController = TextEditingController(text: _currentYear());
  final _monthController = TextEditingController(text: '1');
  final _dayController = TextEditingController(text: '1');
  final _hourController = TextEditingController(text: '4');
  final _minuteController = TextEditingController(text: '0');
  final _secondController = TextEditingController();
  final _delayController = TextEditingController();
  final _delayWindowController = TextEditingController();
  final _secondWindowController = TextEditingController();
  final _advanceOffsetController = TextEditingController(text: '0');
  final _initialAdvanceFilterController = TextEditingController();
  final _levelController = TextEditingController();
  final _minHitAdvanceController = TextEditingController();
  final _maxHitAdvanceController = TextEditingController();
  final _starterDelayWindowController = TextEditingController(text: '200');
  final _starterMinAdvanceController = TextEditingController();
  final _starterMaxAdvanceController = TextEditingController();
  final _statControllers = List.generate(6, (_) => TextEditingController());
  Future<_CalibrationData>? _dataFuture;
  String? _localeName;
  int? _observedSpeciesId;
  int _observedNatureId = Nature.hardy.index;
  int? _observedAbilitySlot;
  PokemonGender? _observedGender;
  int? _observedCharacteristic;
  Gen4SeedTimeCalibration? _seedHit;
  Gen4SeedTime? _selectedSeedTime;
  Gen4HitReverseResult? _selectedReverseHit;
  int _advanceOffset = 0;

  @override
  void initState() {
    super.initState();
    _mode = _defaultSeedCheckMode(widget.profile);
    _setTimerDefaultFields(widget.profile);
    _setTargetFields(widget.target);
    _setObservedDefaults(widget.target);
  }

  @override
  void didUpdateWidget(CalibratePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.game.locationGroup !=
        widget.profile.game.locationGroup) {
      _mode = _defaultSeedCheckMode(widget.profile);
    }
    if (oldWidget.target != widget.target) {
      _setTargetFields(widget.target);
      _setObservedDefaults(widget.target);
      _selectedReverseHit = null;
    } else if (widget.target == null &&
        _timerDefaultsChanged(oldWidget.profile, widget.profile)) {
      _setTimerDefaultFields(widget.profile);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeName = Localizations.localeOf(context).toString();
    if (_localeName != localeName) {
      _localeName = localeName;
      _dataFuture = _CalibrationData.load(localeName);
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    _delayController.dispose();
    _delayWindowController.dispose();
    _secondWindowController.dispose();
    _advanceOffsetController.dispose();
    _initialAdvanceFilterController.dispose();
    _levelController.dispose();
    _minHitAdvanceController.dispose();
    _maxHitAdvanceController.dispose();
    _starterDelayWindowController.dispose();
    _starterMinAdvanceController.dispose();
    _starterMaxAdvanceController.dispose();
    for (final controller in _statControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = _buildSeedCheckRequest();
    final targetDelay = _parseInt(_delayController);
    final targetSecond = _parseInt(_secondController);
    final targetSeed = _targetSeed;
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      children: [
        _CalibrationTargetCard(target: widget.target),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: targetSeed == null
                ? null
                : () => _openSeedToTime(targetSeed),
            child: Text(l10n.seedToTime),
          ),
        ),
        if (_selectedSeedTime != null) ...[
          const SizedBox(height: 10),
          _SelectedSeedTimeCard(time: _selectedSeedTime!),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.calibrateTargetTime,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        _InputGrid(
          children: [
            _NumberField(
              label: l10n.year,
              controller: _yearController,
              enabled: false,
              onChanged: _refresh,
            ),
            _NumberField(
              label: l10n.month,
              controller: _monthController,
              enabled: false,
              onChanged: _refresh,
            ),
            _NumberField(
              label: l10n.day,
              controller: _dayController,
              enabled: false,
              onChanged: _refresh,
            ),
            _NumberField(
              label: l10n.hour,
              controller: _hourController,
              enabled: false,
              onChanged: _refresh,
            ),
            _NumberField(
              label: l10n.minute,
              controller: _minuteController,
              enabled: false,
              onChanged: _refresh,
            ),
            _NumberField(
              label: l10n.second,
              controller: _secondController,
              enabled: false,
              onChanged: _refresh,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.calibrateSearchWindow,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        _InputGrid(
          children: [
            _NumberField(
              label: l10n.calibrateTargetDelay,
              controller: _delayController,
              enabled: false,
              onChanged: _refresh,
            ),
            _NumberField(
              label: l10n.calibrateDelayWindow,
              controller: _delayWindowController,
              onChanged: _refresh,
            ),
            _NumberField(
              label: l10n.calibrateSecondWindow,
              controller: _secondWindowController,
              onChanged: _refresh,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SignedNumberField(
                label: l10n.advanceOffset,
                controller: _advanceOffsetController,
                onChanged: _updateAdvanceOffset,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NumberField(
                label: l10n.initialAdvanceFilter,
                controller: _initialAdvanceFilterController,
                onChanged: _refreshSeedHit,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: query == null ? null : () => _openSeedSearch(query),
                child: Text(l10n.seedSearch),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          l10n.advanceOffsetHelp,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        if (query == null) ...[
          const SizedBox(height: 6),
          _MessagePanel(message: _seedSearchError(l10n)),
        ],
        if (_seedHit != null) ...[
          const SizedBox(height: 10),
          _SeedHitCard(match: _seedHit!, profile: widget.profile),
        ],
        const SizedBox(height: 16),
        Gen4RngTimerPanel(
          slot: Gen4TimerCalibrationSlot.encounter,
          profile: widget.profile,
          targetDelay: targetDelay,
          targetSecond: targetSecond,
          targetDateTime: query?.target.dateTime,
          hitSecond: _seedHit?.dateTime.second,
          delayHit: _selectedReverseHit?.delay ?? _seedHit?.delay,
          delayHitToken: _selectedReverseHit ?? _seedHit,
          lockDelayHit: _selectedReverseHit == null && _seedHit != null,
          onCalibrationApplied: _saveTimerCalibration,
        ),
        const SizedBox(height: 16),
        FutureBuilder<_CalibrationData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            final data = snapshot.data;
            if (data == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_isStarterTarget(widget.target)) {
              return _StarterObservedHitPanel(
                target: widget.target,
                data: data,
                profile: widget.profile,
                levelController: _levelController,
                delayWindowController: _starterDelayWindowController,
                minAdvanceController: _starterMinAdvanceController,
                maxAdvanceController: _starterMaxAdvanceController,
                statControllers: _statControllers,
                natureId: _observedNatureId,
                abilitySlot: _observedAbilitySlot,
                gender: _observedGender,
                characteristic: _observedCharacteristic,
                onNatureChanged: (value) =>
                    _setObservedValue(() => _observedNatureId = value),
                onAbilityChanged: (value) =>
                    _setObservedValue(() => _observedAbilitySlot = value),
                onGenderChanged: (value) =>
                    _setObservedValue(() => _observedGender = value),
                onCharacteristicChanged: (value) =>
                    _setObservedValue(() => _observedCharacteristic = value),
                onObservedChanged: _refreshObserved,
                onReverseSearch: () => _openReverseHitSearch(data),
              );
            }
            return _ObservedHitPanel(
              target: widget.target,
              data: data,
              profile: widget.profile,
              selectedSpeciesId: _observedSpeciesId,
              levelController: _levelController,
              minAdvanceController: _minHitAdvanceController,
              maxAdvanceController: _maxHitAdvanceController,
              statControllers: _statControllers,
              natureId: _observedNatureId,
              abilitySlot: _observedAbilitySlot,
              gender: _observedGender,
              onSpeciesChanged: (value) =>
                  _setObservedValue(() => _observedSpeciesId = value),
              onNatureChanged: (value) =>
                  _setObservedValue(() => _observedNatureId = value),
              onAbilityChanged: (value) =>
                  _setObservedValue(() => _observedAbilitySlot = value),
              onGenderChanged: (value) =>
                  _setObservedValue(() => _observedGender = value),
              onObservedChanged: _refreshObserved,
              onReverseSearch: () => _openReverseHitSearch(data),
            );
          },
        ),
        if (_selectedReverseHit != null && widget.target != null) ...[
          const SizedBox(height: 10),
          _ReverseHitFeedbackCard(
            target: widget.target!,
            hit: _selectedReverseHit!,
            advanceOffset: _advanceOffset,
          ),
        ],
      ],
    );
  }

  Future<void> _openSeedSearch(Gen4SeedCheckRequest request) async {
    final result = await Navigator.of(context).push<Gen4SeedTimeCalibration>(
      MaterialPageRoute(builder: (_) => SeedCheckPage(request: request)),
    );
    if (!mounted || result == null) {
      return;
    }
    setState(() => _seedHit = result);
  }

  Future<void> _openReverseHitSearch(_CalibrationData data) async {
    final request = _buildReverseHitRequest(data);
    if (request == null) {
      return;
    }
    final result = await Navigator.of(context).push<Gen4HitReverseResult>(
      MaterialPageRoute(
        builder: (_) => HitReversePage(request: request, names: data.names),
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    setState(() {
      _selectedReverseHit = result;
      final target = widget.target;
      if (target != null) {
        _setAdvanceOffset(
          nextReverseHitAdvanceOffset(
            currentOffset: _advanceOffset,
            targetAdvance: target.advance,
            actualAdvance: result.advance,
          ),
        );
      }
    });
  }

  Future<void> _openSeedToTime(int seed) async {
    final result = await Navigator.of(context).push<Gen4SeedTime>(
      MaterialPageRoute(
        builder: (_) => SeedToTimePage(seed: seed, year: _targetYear),
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    setState(() {
      _selectedSeedTime = result;
      _yearController.text = '${result.dateTime.year}';
      _monthController.text = '${result.dateTime.month}';
      _dayController.text = '${result.dateTime.day}';
      _hourController.text = '${result.dateTime.hour}';
      _minuteController.text = '${result.dateTime.minute}';
      _secondController.text = '${result.dateTime.second}';
      _delayController.text = '${result.delay}';
      _seedHit = null;
    });
  }

  void _saveTimerCalibration(Gen4TimerCalibrationChange change) {
    widget.onProfileChanged(
      widget.profile.copyWith(
        calibratedDelay: change.nextCalibratedDelay,
        calibratedSecond: change.nextCalibratedSecond,
      ),
    );
  }

  void _refresh() {
    setState(() => _seedHit = null);
  }

  void _refreshSeedHit() {
    if (mounted) {
      setState(() => _seedHit = null);
    }
  }

  void _refreshObserved() {
    if (mounted) {
      setState(() => _selectedReverseHit = null);
    }
  }

  void _updateAdvanceOffset() {
    final offset = int.tryParse(_advanceOffsetController.text.trim()) ?? 0;
    if (_advanceOffset == offset) {
      return;
    }
    setState(() => _advanceOffset = offset);
  }

  void _setAdvanceOffset(int offset) {
    _advanceOffset = offset;
    _advanceOffsetController.text = '$offset';
  }

  void _setObservedValue(VoidCallback update) {
    setState(() {
      update();
      _selectedReverseHit = null;
    });
  }

  void _setTimerDefaultFields(AppProfile profile) {
    _secondController.text = '${profile.calibratedSecond}';
    _delayController.text = '${profile.calibratedDelay}';
    _delayWindowController.text = '${profile.delayWindow}';
    _secondWindowController.text = '${profile.secondWindow}';
  }

  void _setTargetFields(Gen4SearchResultRow? target) {
    _seedHit = null;
    _selectedSeedTime = null;
    _setAdvanceOffset(0);
    if (target == null) {
      return;
    }
    _yearController.text = '${target.year}';
    _hourController.text = '${target.hour}';
    if (target.second case final second?) {
      _secondController.text = '$second';
    }
    _delayController.text = '${target.delay}';
  }

  void _setObservedDefaults(Gen4SearchResultRow? target) {
    _observedSpeciesId = target?.source?.speciesId;
    _observedNatureId = target?.natureId ?? Nature.hardy.index;
    _observedAbilitySlot = null;
    _observedGender = null;
    _observedCharacteristic = null;
    _levelController.text = target?.level?.toString() ?? '';
    final advance = target?.advance ?? 0;
    _minHitAdvanceController.text = '${advance - 300 < 0 ? 0 : advance - 300}';
    _maxHitAdvanceController.text = '${advance + 300}';
    _starterDelayWindowController.text = '200';
    _starterMinAdvanceController.text = '0';
    _starterMaxAdvanceController.text = '20';
    final stats = _parseStatsText(target?.stats);
    for (var index = 0; index < _statControllers.length; index += 1) {
      _statControllers[index].text = stats == null ? '' : '${stats[index]}';
    }
  }

  Gen4HitReverseRequest? _buildReverseHitRequest(_CalibrationData data) {
    final target = widget.target;
    final speciesId = _observedSpeciesId;
    final level = _parseInt(_levelController);
    final minAdvance = _parseInt(_minHitAdvanceController);
    final maxAdvance = _parseInt(_maxHitAdvanceController);
    final starterTarget = _isStarterTarget(target);
    final starterDelayWindow = _parseInt(_starterDelayWindowController);
    final starterMinAdvance = _parseInt(_starterMinAdvanceController);
    final starterMaxAdvance = _parseInt(_starterMaxAdvanceController);
    final stats = _observedStats;
    final effectiveMinAdvance = starterTarget ? starterMinAdvance : minAdvance;
    final effectiveMaxAdvance = starterTarget ? starterMaxAdvance : maxAdvance;
    if (target == null ||
        speciesId == null ||
        level == null ||
        effectiveMinAdvance == null ||
        effectiveMaxAdvance == null ||
        stats == null ||
        level < 1 ||
        level > 100 ||
        effectiveMinAdvance < 0 ||
        effectiveMaxAdvance < effectiveMinAdvance ||
        starterTarget &&
            (starterDelayWindow == null || starterDelayWindow < 0)) {
      return null;
    }
    return Gen4HitReverseRequest(
      target: target,
      personal: data.personal.tableFor(widget.profile.game),
      wildRepository: data.wild,
      tid: widget.profile.tid,
      sid: widget.profile.sid,
      speciesId: speciesId,
      level: level,
      nature: Nature.values[_observedNatureId],
      observedStats: stats,
      minAdvance: effectiveMinAdvance,
      maxAdvance: effectiveMaxAdvance,
      abilitySlot: _observedAbilitySlot,
      gender: _observedGender,
      characteristic: starterTarget ? _observedCharacteristic : null,
      targetSeedTime: _targetSeedTimeForReverse(),
      nearbyDelayWindow: starterTarget
          ? starterDelayWindow!
          : widget.profile.delayWindow,
      nearbySecondWindow: starterTarget ? 0 : widget.profile.secondWindow,
      alwaysSearchNearbySeeds: starterTarget,
    );
  }

  PokemonStats? get _observedStats {
    final values = <int>[];
    for (final controller in _statControllers) {
      final value = _parseInt(controller);
      if (value == null || value <= 0) {
        return null;
      }
      values.add(value);
    }
    return PokemonStats(
      hp: values[0],
      attack: values[1],
      defense: values[2],
      specialAttack: values[3],
      specialDefense: values[4],
      speed: values[5],
    );
  }

  Gen4SeedTime? _targetSeedTimeForReverse() {
    final request = _buildSeedCheckRequest();
    final targetSeed = _targetSeed;
    if (request == null || targetSeed == null) {
      return null;
    }
    if (request.target.seed != targetSeed) {
      return null;
    }
    return request.target;
  }

  Gen4SeedCheckRequest? _buildSeedCheckRequest() {
    final year = _parseInt(_yearController);
    final month = _parseInt(_monthController);
    final day = _parseInt(_dayController);
    final hour = _parseInt(_hourController);
    final minute = _parseInt(_minuteController);
    final second = _parseInt(_secondController);
    final delay = _parseInt(_delayController);
    final delayWindow = _parseInt(_delayWindowController);
    final secondWindow = _parseInt(_secondWindowController);
    final initialAdvanceFilter = _parseInt(_initialAdvanceFilterController);
    if (year == null ||
        month == null ||
        day == null ||
        hour == null ||
        minute == null ||
        second == null ||
        delay == null ||
        delayWindow == null ||
        secondWindow == null ||
        delayWindow < 0 ||
        secondWindow < 0 ||
        initialAdvanceFilter != null && initialAdvanceFilter < 0 ||
        delay - delayWindow < 0 ||
        delay + delayWindow > u32Mask) {
      return null;
    }
    final dateTime = DateTime(year, month, day, hour, minute, second);
    if (dateTime.year != year ||
        dateTime.month != month ||
        dateTime.day != day ||
        dateTime.hour != hour ||
        dateTime.minute != minute ||
        dateTime.second != second) {
      return null;
    }
    final target = Gen4SeedTime(dateTime: dateTime, delay: delay);
    final targetSeed = _targetSeed;
    if (targetSeed != null && target.seed != targetSeed) {
      return null;
    }
    return Gen4SeedCheckRequest(
      target: target,
      delayWindow: delayWindow,
      secondWindow: secondWindow,
      mode: _mode,
      targetAdvance: widget.target?.advance,
      advanceOffset: _advanceOffset,
      phoneCaller: widget.profile.phoneCaller,
      minPhoneCallSkip: initialAdvanceFilter ?? 0,
      maxPhoneCallSkip: initialAdvanceFilter ?? widget.profile.maxPhoneCallSkip,
    );
  }

  String _seedSearchError(AppLocalizations l10n) {
    final seedTime = _currentSeedTime();
    final targetSeed = _targetSeed;
    if (seedTime != null && targetSeed != null && seedTime.seed != targetSeed) {
      return l10n.calibrateTargetSeedTimeRequired;
    }
    return l10n.calibrateInvalidTarget;
  }

  Gen4SeedTime? _currentSeedTime() {
    final year = _parseInt(_yearController);
    final month = _parseInt(_monthController);
    final day = _parseInt(_dayController);
    final hour = _parseInt(_hourController);
    final minute = _parseInt(_minuteController);
    final second = _parseInt(_secondController);
    final delay = _parseInt(_delayController);
    if (year == null ||
        month == null ||
        day == null ||
        hour == null ||
        minute == null ||
        second == null ||
        delay == null) {
      return null;
    }
    final dateTime = DateTime(year, month, day, hour, minute, second);
    if (dateTime.year != year ||
        dateTime.month != month ||
        dateTime.day != day ||
        dateTime.hour != hour ||
        dateTime.minute != minute ||
        dateTime.second != second) {
      return null;
    }
    return Gen4SeedTime(dateTime: dateTime, delay: delay);
  }

  int? get _targetSeed {
    final seed = widget.target?.seed;
    if (seed == null) {
      return null;
    }
    return int.tryParse(seed, radix: 16);
  }

  int get _targetYear {
    return int.tryParse(_yearController.text.trim()) ??
        widget.target?.year ??
        DateTime.now().year.clamp(2000, 2099).toInt();
  }
}

class _CalibrationTargetCard extends StatelessWidget {
  const _CalibrationTargetCard({required this.target});

  final Gen4SearchResultRow? target;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final target = this.target;
    if (target == null) {
      return _SurfaceCard(child: Text(l10n.noCalibrationTarget));
    }
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.calibrationTarget,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  target.target,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (target.shiny) const _ShinyIcon(),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text('${l10n.seed}: ${target.seed}'),
              Text('${l10n.delay}: ${target.delay}'),
              Text('${l10n.second}: ${target.second ?? '-'}'),
              Text('${l10n.advance}: ${target.advance}'),
            ],
          ),
          if (target.pid != null || target.ivs.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (target.pid case final pid?) Text('${l10n.pid}: $pid'),
                Text('${l10n.ivs}: ${target.ivs}'),
              ],
            ),
          ],
        ],
      ),
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

class _SeedHitCard extends StatelessWidget {
  const _SeedHitCard({required this.match, required this.profile});

  final Gen4SeedTimeCalibration match;
  final AppProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final seed = match.seed.toRadixString(16).padLeft(8, '0').toUpperCase();
    final hitSecond = match.dateTime.second;
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(l10n.selectedSeedHit),
              Text('${l10n.seed}: $seed'),
              Text('${l10n.delay}: ${match.delay}'),
              Text('${l10n.second}: ${match.dateTime.second}'),
              if (match.observedPhoneCallCount > 0)
                Text('${l10n.initialAdvance}: ${match.totalPhoneCallSkip}'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.selectedSeedHitHelp,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                l10n.calibratedSecondCurrent(
                  profile.calibratedSecond.toString(),
                ),
              ),
              Text(l10n.calibratedSecondHit(hitSecond.toString())),
            ],
          ),
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

class _ReverseHitFeedbackCard extends StatelessWidget {
  const _ReverseHitFeedbackCard({
    required this.target,
    required this.hit,
    required this.advanceOffset,
  });

  final Gen4SearchResultRow target;
  final Gen4HitReverseResult hit;
  final int advanceOffset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final targetSeed = target.seed.toUpperCase().padLeft(8, '0');
    final seedMatched = hit.seedHex == targetSeed;
    final targetAdvance = target.advance;
    final advanceDelta = hit.advance - targetAdvance;
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.reverseHitFeedback,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Text(
                seedMatched
                    ? l10n.reverseHitSeedMatched
                    : l10n.reverseHitSeedMissed,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: seedMatched
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _ThreeColumnValues(
            values: [
              _ValueSpec(label: l10n.seed, value: hit.seedHex),
              _ValueSpec(
                label: l10n.reverseHitTargetAdvance,
                value: '$targetAdvance',
              ),
              _ValueSpec(
                label: l10n.reverseHitActualAdvance,
                value: '${hit.advance}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.reverseHitAdvanceDelta(_signedInt(advanceDelta)),
            style: theme.textTheme.labelSmall,
          ),
          Text(
            '${l10n.advanceOffset}: ${_signedInt(advanceOffset)}',
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _ObservedHitPanel extends StatelessWidget {
  const _ObservedHitPanel({
    required this.target,
    required this.data,
    required this.profile,
    required this.selectedSpeciesId,
    required this.levelController,
    required this.minAdvanceController,
    required this.maxAdvanceController,
    required this.statControllers,
    required this.natureId,
    required this.abilitySlot,
    required this.gender,
    required this.onSpeciesChanged,
    required this.onNatureChanged,
    required this.onAbilityChanged,
    required this.onGenderChanged,
    required this.onObservedChanged,
    required this.onReverseSearch,
  });

  final Gen4SearchResultRow? target;
  final _CalibrationData data;
  final AppProfile profile;
  final int? selectedSpeciesId;
  final TextEditingController levelController;
  final TextEditingController minAdvanceController;
  final TextEditingController maxAdvanceController;
  final List<TextEditingController> statControllers;
  final int natureId;
  final int? abilitySlot;
  final PokemonGender? gender;
  final ValueChanged<int?> onSpeciesChanged;
  final ValueChanged<int> onNatureChanged;
  final ValueChanged<int?> onAbilityChanged;
  final ValueChanged<PokemonGender?> onGenderChanged;
  final VoidCallback onObservedChanged;
  final VoidCallback onReverseSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final source = target?.source;
    final speciesOptions = _observedSpeciesOptions(data, target);
    final selectedSpecies = speciesOptions.contains(selectedSpeciesId)
        ? selectedSpeciesId
        : null;
    final personal = selectedSpecies == null
        ? null
        : data.personal.tableFor(profile.game)[selectedSpecies];
    final canSearch =
        target != null &&
        selectedSpecies != null &&
        levelController.text.trim().isNotEmpty &&
        minAdvanceController.text.trim().isNotEmpty &&
        maxAdvanceController.text.trim().isNotEmpty &&
        statControllers.every(
          (controller) => controller.text.trim().isNotEmpty,
        );

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.observedHit, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: selectedSpecies,
            decoration: InputDecoration(labelText: l10n.pokemon),
            items: [
              for (final speciesId in speciesOptions)
                DropdownMenuItem<int>(
                  value: speciesId,
                  child: Text(
                    '${speciesId.toString().padLeft(3, '0')} '
                    '${data.names.speciesName(speciesId)}',
                  ),
                ),
            ],
            onChanged: source == null ? null : onSpeciesChanged,
          ),
          const SizedBox(height: 8),
          _InputGrid(
            children: [
              _NumberField(
                label: l10n.levelShort,
                controller: levelController,
                onChanged: onObservedChanged,
              ),
              _NumberField(
                label: l10n.minAdvance,
                controller: minAdvanceController,
                onChanged: onObservedChanged,
              ),
              _NumberField(
                label: l10n.maxAdvance,
                controller: maxAdvanceController,
                onChanged: onObservedChanged,
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: natureId,
            decoration: InputDecoration(labelText: l10n.nature),
            items: [
              for (var id = 0; id < Nature.values.length; id += 1)
                DropdownMenuItem<int>(
                  value: id,
                  child: Text(_natureOptionLabel(l10n, data, id)),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                onNatureChanged(value);
              }
            },
          ),
          const SizedBox(height: 8),
          _InputGrid(
            children: [
              _NumberField(
                label: l10n.hpStat,
                controller: statControllers[0],
                clearOnFirstTap: true,
                onChanged: onObservedChanged,
              ),
              _NumberField(
                label: l10n.atkStat,
                controller: statControllers[1],
                clearOnFirstTap: true,
                onChanged: onObservedChanged,
              ),
              _NumberField(
                label: l10n.defStat,
                controller: statControllers[2],
                clearOnFirstTap: true,
                onChanged: onObservedChanged,
              ),
              _NumberField(
                label: l10n.spaStat,
                controller: statControllers[3],
                clearOnFirstTap: true,
                onChanged: onObservedChanged,
              ),
              _NumberField(
                label: l10n.spdStat,
                controller: statControllers[4],
                clearOnFirstTap: true,
                onChanged: onObservedChanged,
              ),
              _NumberField(
                label: l10n.speStat,
                controller: statControllers[5],
                clearOnFirstTap: true,
                onChanged: onObservedChanged,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  initialValue: abilitySlot,
                  decoration: InputDecoration(labelText: l10n.ability),
                  items: [
                    DropdownMenuItem<int?>(value: null, child: Text(l10n.any)),
                    if (personal != null)
                      for (
                        var slot = 0;
                        slot < personal.abilityIds.length;
                        slot += 1
                      )
                        DropdownMenuItem<int?>(
                          value: slot,
                          child: Text(
                            l10n.abilitySlot(
                              slot + 1,
                              data.names.abilityName(personal.abilityIds[slot]),
                            ),
                          ),
                        ),
                  ],
                  onChanged: onAbilityChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<PokemonGender?>(
                  initialValue: gender,
                  decoration: InputDecoration(labelText: l10n.gender),
                  items: [
                    DropdownMenuItem<PokemonGender?>(
                      value: null,
                      child: Text(l10n.any),
                    ),
                    for (final option in _legalGenders(personal?.genderRatio))
                      DropdownMenuItem<PokemonGender?>(
                        value: option,
                        child: Text(_genderLabel(l10n, option)),
                      ),
                  ],
                  onChanged: onGenderChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canSearch ? onReverseSearch : null,
              child: Text(l10n.reverseHitSearch),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarterObservedHitPanel extends StatelessWidget {
  const _StarterObservedHitPanel({
    required this.target,
    required this.data,
    required this.profile,
    required this.levelController,
    required this.delayWindowController,
    required this.minAdvanceController,
    required this.maxAdvanceController,
    required this.statControllers,
    required this.natureId,
    required this.abilitySlot,
    required this.gender,
    required this.characteristic,
    required this.onNatureChanged,
    required this.onAbilityChanged,
    required this.onGenderChanged,
    required this.onCharacteristicChanged,
    required this.onObservedChanged,
    required this.onReverseSearch,
  });

  final Gen4SearchResultRow? target;
  final _CalibrationData data;
  final AppProfile profile;
  final TextEditingController levelController;
  final TextEditingController delayWindowController;
  final TextEditingController minAdvanceController;
  final TextEditingController maxAdvanceController;
  final List<TextEditingController> statControllers;
  final int natureId;
  final int? abilitySlot;
  final PokemonGender? gender;
  final int? characteristic;
  final ValueChanged<int> onNatureChanged;
  final ValueChanged<int?> onAbilityChanged;
  final ValueChanged<PokemonGender?> onGenderChanged;
  final ValueChanged<int?> onCharacteristicChanged;
  final VoidCallback onObservedChanged;
  final VoidCallback onReverseSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final source = target?.source;
    final speciesId = source?.speciesId;
    final personal = speciesId == null
        ? null
        : data.personal.tableFor(profile.game)[speciesId];
    final canSearch =
        target != null &&
        speciesId != null &&
        levelController.text.trim().isNotEmpty &&
        delayWindowController.text.trim().isNotEmpty &&
        minAdvanceController.text.trim().isNotEmpty &&
        maxAdvanceController.text.trim().isNotEmpty &&
        statControllers.every(
          (controller) => controller.text.trim().isNotEmpty,
        );

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.starterObservedHit,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _InputGrid(
            children: [
              _NumberField(
                label: l10n.levelShort,
                controller: levelController,
                onChanged: onObservedChanged,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InputGrid(
            children: [
              _NumberField(
                label: l10n.calibrateDelayWindow,
                controller: delayWindowController,
                onChanged: onObservedChanged,
              ),
              _NumberField(
                label: l10n.minAdvance,
                controller: minAdvanceController,
                onChanged: onObservedChanged,
              ),
              _NumberField(
                label: l10n.maxAdvance,
                controller: maxAdvanceController,
                onChanged: onObservedChanged,
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: natureId,
            decoration: InputDecoration(labelText: l10n.nature),
            items: [
              for (var id = 0; id < Nature.values.length; id += 1)
                DropdownMenuItem<int>(
                  value: id,
                  child: Text(_natureOptionLabel(l10n, data, id)),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                onNatureChanged(value);
              }
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int?>(
            initialValue: characteristic,
            decoration: InputDecoration(labelText: l10n.characteristic),
            itemHeight: kMinInteractiveDimension,
            items: [
              DropdownMenuItem<int?>(value: null, child: Text(l10n.any)),
              for (var id = 0; id < 30; id += 1)
                DropdownMenuItem<int?>(
                  value: id,
                  child: _CharacteristicOptionLabel(id: id),
                ),
            ],
            onChanged: onCharacteristicChanged,
          ),
          const SizedBox(height: 8),
          _InputGrid(
            children: [
              _NumberField(
                label: l10n.hpStat,
                controller: statControllers[0],
                clearOnFirstTap: true,
                onChanged: onObservedChanged,
              ),
              _NumberField(
                label: l10n.atkStat,
                controller: statControllers[1],
                clearOnFirstTap: true,
                onChanged: onObservedChanged,
              ),
              _NumberField(
                label: l10n.defStat,
                controller: statControllers[2],
                clearOnFirstTap: true,
                onChanged: onObservedChanged,
              ),
              _NumberField(
                label: l10n.spaStat,
                controller: statControllers[3],
                clearOnFirstTap: true,
                onChanged: onObservedChanged,
              ),
              _NumberField(
                label: l10n.spdStat,
                controller: statControllers[4],
                clearOnFirstTap: true,
                onChanged: onObservedChanged,
              ),
              _NumberField(
                label: l10n.speStat,
                controller: statControllers[5],
                clearOnFirstTap: true,
                onChanged: onObservedChanged,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  initialValue: abilitySlot,
                  decoration: InputDecoration(labelText: l10n.ability),
                  items: [
                    DropdownMenuItem<int?>(value: null, child: Text(l10n.any)),
                    if (personal != null)
                      for (
                        var slot = 0;
                        slot < personal.abilityIds.length;
                        slot += 1
                      )
                        DropdownMenuItem<int?>(
                          value: slot,
                          child: Text(
                            l10n.abilitySlot(
                              slot + 1,
                              data.names.abilityName(personal.abilityIds[slot]),
                            ),
                          ),
                        ),
                  ],
                  onChanged: onAbilityChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<PokemonGender?>(
                  initialValue: gender,
                  decoration: InputDecoration(labelText: l10n.gender),
                  items: [
                    DropdownMenuItem<PokemonGender?>(
                      value: null,
                      child: Text(l10n.any),
                    ),
                    for (final option in _legalGenders(personal?.genderRatio))
                      DropdownMenuItem<PokemonGender?>(
                        value: option,
                        child: Text(_genderLabel(l10n, option)),
                      ),
                  ],
                  onChanged: onGenderChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canSearch ? onReverseSearch : null,
              child: Text(l10n.reverseHitSearch),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreeColumnValues extends StatelessWidget {
  const _ThreeColumnValues({required this.values});

  final List<_ValueSpec> values;

  @override
  Widget build(BuildContext context) {
    assert(values.length == 3);
    return Row(
      children: [
        for (var index = 0; index < values.length; index += 1) ...[
          Expanded(
            child: _ValueBox(
              label: values[index].label,
              value: values[index].value,
            ),
          ),
          if (index != values.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _ValueSpec {
  const _ValueSpec({required this.label, required this.value});

  final String label;
  final String value;
}

class _ValueBox extends StatelessWidget {
  const _ValueBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            Text(value, style: theme.textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
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
    this.clearOnFirstTap = false,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final bool enabled;
  final bool clearOnFirstTap;

  @override
  Widget build(BuildContext context) {
    if (!clearOnFirstTap) {
      return TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (_) => onChanged(),
      );
    }
    return _ClearOnFirstTapTextField(
      label: label,
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
    );
  }
}

class _SignedNumberField extends StatelessWidget {
  const _SignedNumberField({
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
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      inputFormatters: const [_SignedIntInputFormatter()],
      onChanged: (_) => onChanged(),
    );
  }
}

class _SignedIntInputFormatter extends TextInputFormatter {
  const _SignedIntInputFormatter();

  static final _signedIntPattern = RegExp(r'^-?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _signedIntPattern.hasMatch(newValue.text) ? newValue : oldValue;
  }
}

class _ClearOnFirstTapTextField extends StatefulWidget {
  const _ClearOnFirstTapTextField({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  State<_ClearOnFirstTapTextField> createState() =>
      _ClearOnFirstTapTextFieldState();
}

class _ClearOnFirstTapTextFieldState extends State<_ClearOnFirstTapTextField> {
  static const _tapMovementTolerance = 18.0;

  final _focusNode = FocusNode();
  Offset? _pointerDownPosition;
  bool _hadFocusOnPointerDown = false;
  bool _tapCandidate = false;
  bool _clearOnFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus && _clearOnFocus) {
      _clearOnFocus = false;
      _clearController();
    }
    if (!_focusNode.hasFocus) {
      _clearOnFocus = false;
    }
  }

  void _clearController() {
    widget.controller.clear();
    widget.onChanged();
  }

  void _resetPointerState() {
    _pointerDownPosition = null;
    _hadFocusOnPointerDown = false;
    _tapCandidate = false;
  }

  bool _isTapAt(Offset position) {
    final downPosition = _pointerDownPosition;
    return downPosition != null &&
        _tapCandidate &&
        (position - downPosition).distance <= _tapMovementTolerance;
  }

  void _requestClearAfterTap() {
    if (_focusNode.hasFocus) {
      _clearController();
    } else {
      _clearOnFocus = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _pointerDownPosition = event.position;
        _hadFocusOnPointerDown = _focusNode.hasFocus;
        _tapCandidate = widget.enabled;
      },
      onPointerMove: (event) {
        if (!_isTapAt(event.position)) {
          _tapCandidate = false;
        }
      },
      onPointerCancel: (_) {
        _resetPointerState();
      },
      onPointerUp: (event) {
        final shouldClear =
            widget.enabled &&
            !_hadFocusOnPointerDown &&
            _isTapAt(event.position);
        _resetPointerState();
        if (shouldClear) {
          _requestClearAfterTap();
        }
      },
      child: TextField(
        focusNode: _focusNode,
        controller: widget.controller,
        enabled: widget.enabled,
        decoration: InputDecoration(labelText: widget.label),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (_) => widget.onChanged(),
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(message, style: Theme.of(context).textTheme.bodySmall);
  }
}

class _CharacteristicOptionLabel extends StatelessWidget {
  const _CharacteristicOptionLabel({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!_usesChineseGameText(l10n)) {
      return Text(_characteristicLabel(l10n, id));
    }
    final japaneseL10n = lookupAppLocalizations(const Locale('ja'));
    final style = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontSize: 12, height: 1);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_characteristicLabel(l10n, id), style: style),
        Text(_characteristicLabel(japaneseL10n, id), style: style),
      ],
    );
  }
}

class _CalibrationData {
  const _CalibrationData({
    required this.names,
    required this.japaneseNames,
    required this.personal,
    required this.wild,
  });

  final Gen4NamedResources names;
  final Gen4NamedResources japaneseNames;
  final Gen4PersonalData personal;
  final Gen4WildEncounterRepository wild;

  static Future<_CalibrationData> load(String localeName) async {
    final values = await Future.wait([
      Gen4NamedResources.load(localeName),
      Gen4NamedResources.load('ja'),
      Gen4PersonalData.load(),
      Gen4WildEncounterRepository.load(),
    ]);
    return _CalibrationData(
      names: values[0] as Gen4NamedResources,
      japaneseNames: values[1] as Gen4NamedResources,
      personal: values[2] as Gen4PersonalData,
      wild: values[3] as Gen4WildEncounterRepository,
    );
  }
}

List<int> _observedSpeciesOptions(
  _CalibrationData data,
  Gen4SearchResultRow? target,
) {
  final source = target?.source;
  if (source == null) {
    return const [];
  }
  if (source.isStatic) {
    return [source.speciesId];
  }
  final locationId = source.locationId;
  final encounter = source.wildEncounter;
  if (locationId == null || encounter == null) {
    return [source.speciesId];
  }
  final game = gen4GameVersionFromJson(source.game);
  final species = <int>{};
  for (final area in data.wild.areasForLocation(
    game: game,
    locationId: locationId,
  )) {
    if (area.encounter.jsonName != encounter) {
      continue;
    }
    if (area.time?.jsonName != source.wildTime) {
      continue;
    }
    for (final slot in area.slots) {
      if (slot.species > 0) {
        species.add(slot.species);
      }
    }
    final modifier = source.wildModifier;
    if (modifier != null) {
      for (final slot in area.modifiers[modifier] ?? const []) {
        if (slot.species > 0) {
          species.add(slot.species);
        }
      }
    }
  }
  if (species.isEmpty) {
    species.add(source.speciesId);
  }
  return species.toList()..sort();
}

List<PokemonGender> _legalGenders(int? genderRatio) {
  if (genderRatio == null) {
    return const [PokemonGender.male, PokemonGender.female];
  }
  final fixed = PokemonGenderRatio.fixedGender(genderRatio);
  if (fixed != null) {
    return [fixed];
  }
  return const [PokemonGender.male, PokemonGender.female];
}

bool _isStarterTarget(Gen4SearchResultRow? target) {
  final source = target?.source;
  return source != null && source.isStatic && source.staticType == 'starter';
}

String _genderLabel(AppLocalizations l10n, PokemonGender gender) {
  return switch (gender) {
    PokemonGender.male => l10n.genderMale,
    PokemonGender.female => l10n.genderFemale,
    PokemonGender.genderless => l10n.genderGenderless,
  };
}

String _natureOptionLabel(
  AppLocalizations l10n,
  _CalibrationData data,
  int id,
) {
  final name = data.names.natureName(id);
  if (!_usesChineseGameText(l10n)) {
    return name;
  }
  final japaneseName = data.japaneseNames.natureName(id);
  if (name == japaneseName) {
    return name;
  }
  return '$name / $japaneseName';
}

String _characteristicLabel(AppLocalizations l10n, int id) {
  final options = l10n.characteristicOptions.split('|');
  if (id < 0 || id >= options.length) {
    return '$id';
  }
  return options[id];
}

bool _usesChineseGameText(AppLocalizations l10n) {
  return l10n.localeName.startsWith('zh');
}

int? _parseInt(TextEditingController controller) {
  return int.tryParse(controller.text.trim());
}

List<int>? _parseStatsText(String? text) {
  if (text == null) {
    return null;
  }
  final parts = text.split('/');
  if (parts.length != 6) {
    return null;
  }
  final values = <int>[];
  for (final part in parts) {
    final value = int.tryParse(part.trim());
    if (value == null) {
      return null;
    }
    values.add(value);
  }
  return values;
}

String _currentYear() {
  return DateTime.now().year.clamp(2000, 2099).toString();
}

String _dateTimeValue(DateTime dateTime) {
  return '${dateTime.year.toString().padLeft(4, '0')}-'
      '${dateTime.month.toString().padLeft(2, '0')}-'
      '${dateTime.day.toString().padLeft(2, '0')} '
      '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}:'
      '${dateTime.second.toString().padLeft(2, '0')}';
}

String _signedInt(int value) {
  if (value > 0) {
    return '+$value';
  }
  return '$value';
}

int nextReverseHitAdvanceOffset({
  required int currentOffset,
  required int targetAdvance,
  required int actualAdvance,
}) {
  return currentOffset + actualAdvance - targetAdvance;
}

Gen4SeedCheckMode _defaultSeedCheckMode(AppProfile profile) {
  return profile.game.isHgss
      ? Gen4SeedCheckMode.phoneCalls
      : Gen4SeedCheckMode.coinFlips;
}

bool _timerDefaultsChanged(AppProfile left, AppProfile right) {
  return left.calibratedDelay != right.calibratedDelay ||
      left.calibratedSecond != right.calibratedSecond ||
      left.delayWindow != right.delayWindow ||
      left.secondWindow != right.secondWindow ||
      left.maxPhoneCallSkip != right.maxPhoneCallSkip ||
      left.timerConsole != right.timerConsole ||
      left.timerCustomFrameRate != right.timerCustomFrameRate ||
      left.timerMinimumLengthSeconds != right.timerMinimumLengthSeconds ||
      left.timerPrecisionCalibration != right.timerPrecisionCalibration;
}

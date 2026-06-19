import 'package:flutter/material.dart';

import '../../core/gen4/gen4.dart';
import '../../data/gen4/gen4_game.dart';
import '../../data/gen4/named_resources.dart';
import '../../data/gen4/personal_data.dart';
import '../../l10n/app_localizations.dart';
import '../app_chrome.dart';
import '../app_profile.dart';
import '../dppt_egg_pickup_search_job.dart';
import '../dppt_egg_pid_search_job.dart';
import '../gen4_time_finder_job.dart';
import '../widgets/gen4_rng_timer_panel.dart';
import '../widgets/keyboard_dismiss_region.dart';
import 'dppt_egg_pickup_results_page.dart';
import 'dppt_egg_pid_results_page.dart';
import 'seed_check_page.dart';
import 'seed_to_time_page.dart';

const _genderRatioOptions = [
  _GenderRatioOption(0),
  _GenderRatioOption(31),
  _GenderRatioOption(63),
  _GenderRatioOption(127),
  _GenderRatioOption(191),
  _GenderRatioOption(254),
  _GenderRatioOption(255),
];

String _defaultYear() {
  return DateTime.now().year.clamp(2000, 2099).toString();
}

class DpptEggPage extends StatefulWidget {
  const DpptEggPage({
    super.key,
    required this.profile,
    required this.onProfileChanged,
  });

  final AppProfile profile;
  final ValueChanged<AppProfile> onProfileChanged;

  @override
  State<DpptEggPage> createState() => _DpptEggPageState();
}

enum _EggStage { held, pickup }

class _GenderRatioOption {
  const _GenderRatioOption(this.ratio);

  final int ratio;

  String label(AppLocalizations l10n) {
    if (ratio == PokemonGenderRatio.maleOnly) {
      return l10n.eggGenderRatioMaleOnly;
    }
    if (ratio == PokemonGenderRatio.femaleOnly) {
      return l10n.eggGenderRatioFemaleOnly;
    }
    if (ratio == PokemonGenderRatio.genderless) {
      return l10n.genderGenderless;
    }
    final female = ratio * 100 / 254;
    final male = 100 - female;
    return l10n.eggGenderRatioPercent(
      _formatPercent(male),
      _formatPercent(female),
    );
  }
}

class _EggCrossSaveIntro extends StatelessWidget {
  const _EggCrossSaveIntro({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodySmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.eggCrossSaveTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: bodyStyle,
            children: [
              TextSpan(text: l10n.eggCrossSaveNoteBefore),
              TextSpan(
                text: l10n.eggCrossSaveNoteEmphasis,
                style: bodyStyle?.copyWith(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: l10n.eggCrossSaveNoteAfter),
            ],
          ),
        ),
      ],
    );
  }
}

class _DpptEggPageState extends State<DpptEggPage> {
  late final _tidController = TextEditingController(
    text: '${widget.profile.tid}',
  );
  late final _sidController = TextEditingController(
    text: '${widget.profile.sid}',
  );
  final _heldYearController = TextEditingController(text: _defaultYear());
  final _heldMinDelayController = TextEditingController(text: '900');
  final _heldMaxDelayController = TextEditingController(text: '1500');
  final _heldMinEggFrameController = TextEditingController(text: '1');
  final _heldMaxEggFrameController = TextEditingController(text: '1');
  final _heldHitDelayWindowController = TextEditingController(text: '100');
  final _heldSecondWindowController = TextEditingController(text: '4');
  final _heldInitialAdvanceFilterController = TextEditingController();
  final _pickupYearController = TextEditingController(text: _defaultYear());
  final _pickupMinDelayController = TextEditingController(text: '900');
  final _pickupMaxDelayController = TextEditingController(text: '1500');
  final _pickupDelayWindowController = TextEditingController(text: '100');
  final _pickupSecondWindowController = TextEditingController(text: '4');
  final _pickupInitialAdvanceFilterController = TextEditingController();
  final _pickupMinAdvanceController = TextEditingController(text: '0');
  final _pickupMaxAdvanceController = TextEditingController(text: '100');
  final _pickupReverseMinAdvanceController = TextEditingController(text: '0');
  final _pickupReverseMaxAdvanceController = TextEditingController(text: '100');
  final _lockedPidController = TextEditingController();
  final _pickupSpeciesController = TextEditingController();
  final _pickupSpeciesFocusNode = FocusNode();
  final _parentAControllers = List.generate(
    6,
    (_) => TextEditingController(text: '31'),
  );
  final _parentBControllers = List.generate(
    6,
    (_) => TextEditingController(text: '31'),
  );
  final _minIvControllers = List.generate(
    6,
    (_) => TextEditingController(text: ''),
  );
  final _observedPickupStatControllers = List.generate(
    6,
    (_) => TextEditingController(text: ''),
  );

  _EggStage _stage = _EggStage.held;
  Gen4NamedResources? _names;
  Gen4PersonalData? _personal;
  int? _pickupSpeciesId;
  int _eggGenderRatio = 127;
  Nature? _heldNature;
  PokemonGender? _heldGender;
  int? _heldAbilitySlot;
  Nature? _heldHitNature;
  PokemonGender? _heldHitGender;
  int? _heldHitAbilitySlot;
  Shiny? _heldHitShiny;
  int? _observedPickupCharacteristic;
  bool _heldShinyOnly = false;
  bool _masuda = false;
  String? _error;
  Gen4EggHeldSearchResult? _selectedHeld;
  int? _selectedHeldYear;
  Gen4SeedTime? _selectedHeldSeedTime;
  Gen4SeedTimeCalibration? _selectedHeldSeedHit;
  DpptEggPidSearchResult? _selectedHeldHit;
  Gen4SeedTime? _selectedPickupSeedTime;
  Gen4SeedTimeCalibration? _selectedPickupSeedHit;
  Gen4EggSearchResult? _selectedPickupTarget;

  @override
  void initState() {
    super.initState();
    _heldYearController.addListener(_refreshHeldInputs);
    _heldMinDelayController.addListener(_refreshHeldInputs);
    _heldMaxDelayController.addListener(_refreshHeldInputs);
    _heldMinEggFrameController.addListener(_refreshHeldInputs);
    _heldMaxEggFrameController.addListener(_refreshHeldInputs);
    _pickupYearController.addListener(_refreshPickupSeed);
    _pickupMinDelayController.addListener(_refreshPickupSeed);
    _pickupMaxDelayController.addListener(_refreshPickupSeed);
    _pickupMinAdvanceController.addListener(_refreshPickupResults);
    _pickupMaxAdvanceController.addListener(_refreshPickupResults);
    _lockedPidController.addListener(_refreshPickupResults);
    _applyProfileEggSettings(widget.profile, includeLockedPid: true);
    _addPickupResultListeners(_parentAControllers);
    _addPickupResultListeners(_parentBControllers);
    _addPickupResultListeners(_minIvControllers);
    _addPickupResultListeners(_observedPickupStatControllers);
  }

  @override
  void didUpdateWidget(covariant DpptEggPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != oldWidget.profile) {
      final trainerIdsChanged =
          widget.profile.game != oldWidget.profile.game ||
          widget.profile.tid != oldWidget.profile.tid ||
          widget.profile.sid != oldWidget.profile.sid;
      _applyProfileEggSettings(
        widget.profile,
        includeTrainerIds: trainerIdsChanged,
        includeLockedPid:
            widget.profile.game != oldWidget.profile.game ||
            widget.profile.eggLockedPid != oldWidget.profile.eggLockedPid,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadNames();
  }

  @override
  void dispose() {
    _tidController.dispose();
    _sidController.dispose();
    _heldYearController.removeListener(_refreshHeldInputs);
    _heldMinDelayController.removeListener(_refreshHeldInputs);
    _heldMaxDelayController.removeListener(_refreshHeldInputs);
    _heldMinEggFrameController.removeListener(_refreshHeldInputs);
    _heldMaxEggFrameController.removeListener(_refreshHeldInputs);
    _pickupYearController.removeListener(_refreshPickupSeed);
    _pickupMinDelayController.removeListener(_refreshPickupSeed);
    _pickupMaxDelayController.removeListener(_refreshPickupSeed);
    _pickupMinAdvanceController.removeListener(_refreshPickupResults);
    _pickupMaxAdvanceController.removeListener(_refreshPickupResults);
    _lockedPidController.removeListener(_refreshPickupResults);
    _removePickupResultListeners(_parentAControllers);
    _removePickupResultListeners(_parentBControllers);
    _removePickupResultListeners(_minIvControllers);
    _removePickupResultListeners(_observedPickupStatControllers);
    _heldYearController.dispose();
    _heldMinDelayController.dispose();
    _heldMaxDelayController.dispose();
    _heldMinEggFrameController.dispose();
    _heldMaxEggFrameController.dispose();
    _heldHitDelayWindowController.dispose();
    _heldSecondWindowController.dispose();
    _heldInitialAdvanceFilterController.dispose();
    _pickupYearController.dispose();
    _pickupMinDelayController.dispose();
    _pickupMaxDelayController.dispose();
    _pickupDelayWindowController.dispose();
    _pickupSecondWindowController.dispose();
    _pickupInitialAdvanceFilterController.dispose();
    _pickupMinAdvanceController.dispose();
    _pickupMaxAdvanceController.dispose();
    _pickupReverseMinAdvanceController.dispose();
    _pickupReverseMaxAdvanceController.dispose();
    _lockedPidController.dispose();
    _pickupSpeciesController.dispose();
    _pickupSpeciesFocusNode.dispose();
    for (final controller in _parentAControllers) {
      controller.dispose();
    }
    for (final controller in _parentBControllers) {
      controller.dispose();
    }
    for (final controller in _minIvControllers) {
      controller.dispose();
    }
    for (final controller in _observedPickupStatControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadNames() async {
    final localeName = Localizations.localeOf(context).toString();
    final values = await Future.wait([
      Gen4NamedResources.load(localeName),
      Gen4PersonalData.load(),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _names = values[0] as Gen4NamedResources;
      _personal = values[1] as Gen4PersonalData;
      _refreshPickupSpeciesText();
    });
  }

  void _applyProfileEggSettings(
    AppProfile profile, {
    bool includeTrainerIds = true,
    bool includeLockedPid = false,
  }) {
    if (includeTrainerIds) {
      _tidController.text = '${profile.tid}';
      _sidController.text = '${profile.sid}';
    }
    _setIvControllers(_parentAControllers, profile.eggParentAIvs);
    _setIvControllers(_parentBControllers, profile.eggParentBIvs);
    _masuda = profile.eggMasuda;
    if (includeLockedPid) {
      _lockedPidController.text = profile.eggLockedPid;
    }
  }

  void _refreshHeldInputs() {
    if (mounted) {
      setState(() {});
    }
  }

  void _refreshPickupSeed() {
    if (mounted) {
      setState(() {
        _selectedPickupSeedTime = null;
        _selectedPickupSeedHit = null;
        _selectedPickupTarget = null;
      });
    }
  }

  void _refreshPickupResults() {
    if (mounted) {
      setState(() {
        _selectedPickupTarget = null;
      });
    }
  }

  void _addPickupResultListeners(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.addListener(_refreshPickupResults);
    }
  }

  void _removePickupResultListeners(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.removeListener(_refreshPickupResults);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return KeyboardDismissRegion(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _EggCrossSaveIntro(l10n: l10n),
          const SizedBox(height: 10),
          SegmentedButton<_EggStage>(
            segments: [
              ButtonSegment(
                value: _EggStage.held,
                label: Text(l10n.eggGenerateEggTab),
              ),
              ButtonSegment(
                value: _EggStage.pickup,
                label: Text(l10n.eggPickupEggTab),
              ),
            ],
            selected: {_stage},
            onSelectionChanged: (selected) {
              setState(() => _stage = selected.single);
            },
          ),
          const SizedBox(height: 14),
          if (_stage == _EggStage.held)
            _buildHeldCard(context)
          else
            _buildPickupCard(context),
        ],
      ),
    );
  }

  Widget _buildHeldCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Surface(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.eggHeldStage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.eggDpptHeldFrameNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            _ResponsiveGrid(
              children: [
                TextField(
                  controller: _tidController,
                  decoration: InputDecoration(labelText: l10n.trainerId),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
                TextField(
                  controller: _sidController,
                  decoration: InputDecoration(labelText: l10n.secretId),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
                TextField(
                  controller: _heldYearController,
                  decoration: InputDecoration(labelText: l10n.year),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
                TextField(
                  controller: _heldMinDelayController,
                  decoration: InputDecoration(labelText: l10n.minDelay),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
                TextField(
                  controller: _heldMaxDelayController,
                  decoration: InputDecoration(labelText: l10n.maxDelay),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: _eggGenderRatio,
                  decoration: InputDecoration(labelText: l10n.eggGenderRatio),
                  items: [
                    for (final option in _genderRatioOptions)
                      DropdownMenuItem(
                        value: option.ratio,
                        child: Text(option.label(l10n)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _eggGenderRatio = value);
                    }
                  },
                ),
                TextField(
                  controller: _heldMinEggFrameController,
                  decoration: InputDecoration(labelText: l10n.eggMinFrame),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
                TextField(
                  controller: _heldMaxEggFrameController,
                  decoration: InputDecoration(labelText: l10n.eggMaxFrame),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
                DropdownButtonFormField<Nature?>(
                  isExpanded: true,
                  initialValue: _heldNature,
                  decoration: InputDecoration(labelText: l10n.nature),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.any)),
                    for (final nature in Nature.values)
                      DropdownMenuItem(
                        value: nature,
                        child: Text(_natureName(nature)),
                      ),
                  ],
                  onChanged: (value) => setState(() => _heldNature = value),
                ),
                DropdownButtonFormField<PokemonGender?>(
                  isExpanded: true,
                  initialValue: _heldGender,
                  decoration: InputDecoration(labelText: l10n.gender),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.any)),
                    for (final gender in PokemonGender.values)
                      DropdownMenuItem(
                        value: gender,
                        child: Text(_genderLabel(l10n, gender)),
                      ),
                  ],
                  onChanged: (value) => setState(() => _heldGender = value),
                ),
                DropdownButtonFormField<int?>(
                  isExpanded: true,
                  initialValue: _heldAbilitySlot,
                  decoration: InputDecoration(labelText: l10n.ability),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.any)),
                    DropdownMenuItem(value: 0, child: Text('1')),
                    DropdownMenuItem(value: 1, child: Text('2')),
                  ],
                  onChanged: (value) =>
                      setState(() => _heldAbilitySlot = value),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.eggMasuda),
              value: _masuda,
              onChanged: (value) => setState(() => _masuda = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.shiny),
              secondary: const Icon(Icons.auto_awesome),
              value: _heldShinyOnly,
              onChanged: (value) => setState(() => _heldShinyOnly = value),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.eggTargetEggFrame}: $_eggFrameRangeValue',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 6),
            _EggSearchSpaceInfo(space: _heldSearchSpace),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: !_canSearchHeld ? null : _searchHeld,
                child: Text(l10n.eggSearchPid),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            if (_selectedHeld != null) ...[
              const SizedBox(height: 10),
              _SelectedHeldSummary(
                result: _selectedHeld!,
                natureName: _natureName(_selectedHeld!.state.nature),
                genderLabel: _genderLabel(l10n, _selectedHeld!.state.gender),
              ),
              const SizedBox(height: 8),
              _buildHeldTimer(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeldTimer(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedHeld = _selectedHeld!;
    final seedTime = _selectedHeldSeedTime;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _openHeldSeedToTime(selectedHeld),
            child: Text(l10n.seedToTime),
          ),
        ),
        if (seedTime != null) ...[
          const SizedBox(height: 8),
          _SelectedEggSeedTimeCard(time: seedTime),
          const SizedBox(height: 8),
          _buildHeldSeedSearchPanel(context, seedTime),
          if (_selectedHeldSeedHit != null) ...[
            const SizedBox(height: 8),
            _EggSeedHitCard(
              match: _selectedHeldSeedHit!,
              profile: widget.profile,
            ),
          ],
          const SizedBox(height: 8),
          Gen4RngTimerPanel(
            slot: Gen4TimerCalibrationSlot.egg,
            profile: widget.profile,
            targetDelay: seedTime.delay,
            targetSecond: seedTime.dateTime.second,
            targetDateTime: seedTime.dateTime,
            hitSecond: _selectedHeldSeedHit?.dateTime.second,
            delayHit:
                _selectedHeldHit?.seedInfo.delay ?? _selectedHeldSeedHit?.delay,
            delayHitToken: _selectedHeldHit ?? _selectedHeldSeedHit,
            lockDelayHit:
                _selectedHeldHit == null && _selectedHeldSeedHit != null,
            onCalibrationApplied: _saveEggTimerCalibration,
          ),
          const SizedBox(height: 10),
          _buildHeldReversePanel(context, seedTime),
        ],
      ],
    );
  }

  Widget _buildHeldSeedSearchPanel(
    BuildContext context,
    Gen4SeedTime seedTime,
  ) {
    final l10n = AppLocalizations.of(context);
    final request = _buildHeldSeedCheckRequest(seedTime);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResponsiveGrid(
          children: [
            TextField(
              controller: _heldHitDelayWindowController,
              decoration: InputDecoration(labelText: l10n.calibrateDelayWindow),
              keyboardType: TextInputType.number,
              inputFormatters: platformDigitOnlyInputFormatters(),
              onChanged: (_) => _refreshHeldSeedSearch(),
            ),
            TextField(
              controller: _heldSecondWindowController,
              decoration: InputDecoration(
                labelText: l10n.calibrateSecondWindow,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: platformDigitOnlyInputFormatters(),
              onChanged: (_) => _refreshHeldSeedSearch(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: request == null
                ? null
                : () => _openHeldSeedSearch(request),
            child: Text(l10n.seedSearch),
          ),
        ),
      ],
    );
  }

  Widget _buildPickupSeedSearchPanel(
    BuildContext context,
    Gen4SeedTime seedTime,
  ) {
    final l10n = AppLocalizations.of(context);
    final request = _buildPickupSeedCheckRequest(seedTime);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResponsiveGrid(
          children: [
            TextField(
              controller: _pickupDelayWindowController,
              decoration: InputDecoration(labelText: l10n.calibrateDelayWindow),
              keyboardType: TextInputType.number,
              inputFormatters: platformDigitOnlyInputFormatters(),
              onChanged: (_) => _refreshPickupSeedSearch(),
            ),
            TextField(
              controller: _pickupSecondWindowController,
              decoration: InputDecoration(
                labelText: l10n.calibrateSecondWindow,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: platformDigitOnlyInputFormatters(),
              onChanged: (_) => _refreshPickupSeedSearch(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: request == null
                ? null
                : () => _openPickupSeedSearch(request),
            child: Text(l10n.seedSearch),
          ),
        ),
      ],
    );
  }

  Widget _buildHeldReversePanel(BuildContext context, Gen4SeedTime seedTime) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(controlRadius),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.eggObservedPid,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            _ResponsiveGrid(
              children: [
                TextField(
                  controller: _heldHitDelayWindowController,
                  decoration: InputDecoration(
                    labelText: l10n.calibrateDelayWindow,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
                DropdownButtonFormField<Nature?>(
                  isExpanded: true,
                  initialValue: _heldHitNature,
                  decoration: InputDecoration(labelText: l10n.nature),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.any)),
                    for (final nature in Nature.values)
                      DropdownMenuItem(
                        value: nature,
                        child: Text(_natureName(nature)),
                      ),
                  ],
                  onChanged: (value) => setState(() => _heldHitNature = value),
                ),
                DropdownButtonFormField<PokemonGender?>(
                  isExpanded: true,
                  initialValue: _heldHitGender,
                  decoration: InputDecoration(labelText: l10n.gender),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.any)),
                    for (final gender in PokemonGender.values)
                      DropdownMenuItem(
                        value: gender,
                        child: Text(_genderLabel(l10n, gender)),
                      ),
                  ],
                  onChanged: (value) => setState(() => _heldHitGender = value),
                ),
                DropdownButtonFormField<int?>(
                  isExpanded: true,
                  initialValue: _heldHitAbilitySlot,
                  decoration: InputDecoration(labelText: l10n.ability),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.any)),
                    DropdownMenuItem(value: 0, child: Text('1')),
                    DropdownMenuItem(value: 1, child: Text('2')),
                  ],
                  onChanged: (value) =>
                      setState(() => _heldHitAbilitySlot = value),
                ),
                DropdownButtonFormField<Shiny?>(
                  isExpanded: true,
                  initialValue: _heldHitShiny,
                  decoration: InputDecoration(labelText: l10n.shiny),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.any)),
                    DropdownMenuItem(
                      value: Shiny.star,
                      child: Text(l10n.shiny),
                    ),
                    DropdownMenuItem(
                      value: Shiny.notShiny,
                      child: Text(l10n.notShiny),
                    ),
                  ],
                  onChanged: (value) => setState(() => _heldHitShiny = value),
                ),
              ],
            ),
            if (_selectedHeldHit != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.eggSelectedHitDelay}: '
                '${_selectedHeldHit!.seedInfo.delay}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _openHeldHitSearch(seedTime),
                child: Text(l10n.eggReversePidSearch),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Surface(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.eggPickupStage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.eggDpptPickupFrameNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            _ParentIvGrid(
              title: l10n.eggParentA,
              controllers: _parentAControllers,
            ),
            const SizedBox(height: 10),
            _ParentIvGrid(
              title: l10n.eggParentB,
              controllers: _parentBControllers,
            ),
            const SizedBox(height: 12),
            _buildLockedEggPanel(context),
            const SizedBox(height: 10),
            _ResponsiveGrid(
              children: [
                TextField(
                  controller: _pickupYearController,
                  decoration: InputDecoration(labelText: l10n.year),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
                TextField(
                  controller: _pickupMinDelayController,
                  decoration: InputDecoration(labelText: l10n.minDelay),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
                TextField(
                  controller: _pickupMaxDelayController,
                  decoration: InputDecoration(labelText: l10n.maxDelay),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
                TextField(
                  controller: _pickupMinAdvanceController,
                  decoration: InputDecoration(labelText: l10n.minAdvance),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
                TextField(
                  controller: _pickupMaxAdvanceController,
                  decoration: InputDecoration(labelText: l10n.maxAdvance),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _ParentIvGrid(
              title: l10n.eggMinIvsOptional,
              controllers: _minIvControllers,
              emptyAllowed: true,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: !_hasLockedEgg ? null : _generatePickup,
                child: Text(l10n.eggSearchIvs),
              ),
            ),
            const SizedBox(height: 10),
            if (_selectedPickupTarget != null) ...[
              _PickupResultCard(
                result: _selectedPickupTarget!,
                natureName: _natureName(_selectedPickupTarget!.state.nature),
                genderLabel: _genderLabel(
                  l10n,
                  _selectedPickupTarget!.state.gender,
                ),
                hiddenPowerLabel: _hiddenPowerTypeLabel(
                  l10n,
                  _selectedPickupTarget!.state.hiddenPowerType,
                ),
              ),
            ] else ...[
              _PickupPlaceholderCard(message: l10n.eggNoPickupTargetSelected),
            ],
            const SizedBox(height: 2),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _selectedPickupTarget == null
                    ? null
                    : _openPickupSeedToTime,
                child: Text(l10n.seedToTime),
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedPickupSeedTime != null)
              _SelectedEggSeedTimeCard(time: _selectedPickupSeedTime!),
            if (_selectedPickupSeedTime == null)
              _PickupPlaceholderCard(message: l10n.eggNoSeedTimeSelected),
            if (_selectedPickupSeedTime != null) ...[
              const SizedBox(height: 8),
              _buildPickupSeedSearchPanel(context, _selectedPickupSeedTime!),
              if (_selectedPickupSeedHit != null) ...[
                const SizedBox(height: 8),
                _EggSeedHitCard(
                  match: _selectedPickupSeedHit!,
                  profile: widget.profile,
                ),
              ],
              const SizedBox(height: 8),
            ],
            if (_selectedPickupSeedTime != null)
              Gen4RngTimerPanel(
                slot: Gen4TimerCalibrationSlot.egg,
                profile: widget.profile,
                targetDelay: _selectedPickupSeedTime!.delay,
                targetSecond: _selectedPickupSeedTime!.dateTime.second,
                targetDateTime: _selectedPickupSeedTime!.dateTime,
                hitSecond: _selectedPickupSeedHit?.dateTime.second,
                delayHit: _selectedPickupSeedHit?.delay,
                delayHitToken: _selectedPickupSeedHit,
                lockDelayHit: _selectedPickupSeedHit != null,
                onCalibrationApplied: _saveEggTimerCalibration,
              )
            else
              _PickupPlaceholderCard(message: l10n.eggTimerRequiresSeedTime),
            const SizedBox(height: 12),
            _ParentIvGrid(
              title: l10n.eggObservedStats,
              controllers: _observedPickupStatControllers,
              headerTrailing: _names == null
                  ? null
                  : _EggPokemonAutocomplete(
                      controller: _pickupSpeciesController,
                      focusNode: _pickupSpeciesFocusNode,
                      names: _names!,
                      game: widget.profile.game,
                      l10n: l10n,
                      onChanged: (_) {
                        setState(() {
                          _pickupSpeciesId = null;
                        });
                      },
                      onSelected: (speciesId) {
                        setState(() {
                          _pickupSpeciesId = speciesId;
                          _refreshPickupSpeciesText();
                        });
                      },
                    ),
            ),
            const SizedBox(height: 10),
            _ResponsiveGrid(
              children: [
                TextField(
                  controller: _pickupReverseMinAdvanceController,
                  decoration: InputDecoration(labelText: l10n.minAdvance),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
                TextField(
                  controller: _pickupReverseMaxAdvanceController,
                  decoration: InputDecoration(labelText: l10n.maxAdvance),
                  keyboardType: TextInputType.number,
                  inputFormatters: platformDigitOnlyInputFormatters(),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<int?>(
              isExpanded: true,
              initialValue: _observedPickupCharacteristic,
              decoration: InputDecoration(labelText: l10n.characteristic),
              items: [
                DropdownMenuItem<int?>(value: null, child: Text(l10n.any)),
                for (var id = 0; id < 30; id += 1)
                  DropdownMenuItem<int?>(
                    value: id,
                    child: _CharacteristicOptionLabel(id: id),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _observedPickupCharacteristic = value;
                });
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: !_hasLockedEgg ? null : _reversePickup,
                child: Text(l10n.eggReversePickupSearch),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _searchHeld() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _error = null;
      _selectedHeld = null;
      _selectedHeldYear = null;
      _selectedHeldSeedTime = null;
      _selectedHeldSeedHit = null;
      _selectedHeldHit = null;
      _selectedPickupSeedTime = null;
      _selectedPickupSeedHit = null;
      _selectedPickupTarget = null;
    });
    try {
      final year = _parseInt(_heldYearController.text, l10n.year);
      final tid = _parseU16(_tidController.text, l10n.trainerId);
      final sid = _parseU16(_sidController.text, l10n.secretId);
      final minDelay = _parseInt(_heldMinDelayController.text, l10n.minDelay);
      final maxDelay = _parseInt(_heldMaxDelayController.text, l10n.maxDelay);
      final eggFrameRange = _parseEggFrameRange(l10n);
      final result = await Navigator.of(context).push<DpptEggPidSearchResult>(
        MaterialPageRoute(
          builder: (_) => DpptEggPidResultsPage(
            request: DpptEggPidSearchRequest(
              year: year,
              minDelay: minDelay,
              maxDelay: maxDelay,
              tid: tid,
              sid: sid,
              genderRatio: _eggGenderRatio,
              masuda: _masuda,
              minEggFrame: eggFrameRange.min,
              maxEggFrame: eggFrameRange.max,
              nature: _heldNature,
              gender: _heldGender,
              abilitySlot: _heldAbilitySlot,
              shiny: _heldShinyOnly ? Shiny.star : null,
              resultLimit: 100,
            ),
          ),
        ),
      );
      if (!mounted || result == null) {
        return;
      }
      final selectedHeld = result.toHeldSearchResult();
      setState(() {
        _selectedHeld = selectedHeld;
        _selectedHeldYear = result.year;
        _selectedHeldSeedTime = null;
        _selectedHeldSeedHit = null;
        _selectedHeldHit = null;
        _selectedPickupSeedTime = null;
        _selectedPickupSeedHit = null;
        _selectedPickupTarget = null;
        _lockedPidController.text = _hex32(selectedHeld.state.pid.value);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = _errorMessage(error));
    }
  }

  Widget _buildLockedEggPanel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lockedEgg = _tryParseLockedEgg(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.eggLockedEgg, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        _HexSeedField(
          controller: _lockedPidController,
          label: l10n.eggLockedPid,
        ),
        const SizedBox(height: 6),
        Text(
          l10n.eggLockedEggNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (lockedEgg != null) ...[
          const SizedBox(height: 6),
          Text(
            '${l10n.pid}: ${_hex32(lockedEgg.pid.value)} · '
            '${_natureName(lockedEgg.nature)} · '
            '${_genderLabel(l10n, lockedEgg.gender)} · '
            '${l10n.ability}: ${lockedEgg.abilitySlot + 1} · '
            '${lockedEgg.shiny.isShiny ? l10n.shiny : l10n.notShiny}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Future<void> _generatePickup() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _error = null;
    });
    try {
      final lockedEgg = _parseLockedEgg(l10n);
      final year = _parseInt(_pickupYearController.text, l10n.year);
      final minDelay = _parseInt(_pickupMinDelayController.text, l10n.minDelay);
      final maxDelay = _parseInt(_pickupMaxDelayController.text, l10n.maxDelay);
      final minAdvance = _parseInt(
        _pickupMinAdvanceController.text,
        l10n.minAdvance,
      );
      final maxAdvance = _parseInt(
        _pickupMaxAdvanceController.text,
        l10n.maxAdvance,
      );
      if (maxAdvance < minAdvance) {
        throw ArgumentError(l10n.maxAdvance);
      }
      final minIvs = _parseOptionalIvs(_minIvControllers);
      final tid = _parseU16(_tidController.text, l10n.trainerId);
      final sid = _parseU16(_sidController.text, l10n.secretId);
      final result = await Navigator.of(context)
          .push<DpptEggPickupSearchResult>(
            MaterialPageRoute(
              builder: (_) => DpptEggPickupResultsPage(
                request: DpptEggPickupSearchRequest(
                  year: year,
                  minDelay: minDelay,
                  maxDelay: maxDelay,
                  heldAdvance: 0,
                  heldPid: lockedEgg.pid.value,
                  heldAbilitySlot: lockedEgg.abilitySlot,
                  heldGender: lockedEgg.gender,
                  heldNature: lockedEgg.nature,
                  heldShiny: lockedEgg.shiny,
                  parentIvs: [
                    _parseRequiredIvs(_parentAControllers),
                    _parseRequiredIvs(_parentBControllers),
                  ],
                  genderRatio: _eggGenderRatio,
                  masuda: _masuda,
                  tid: tid,
                  sid: sid,
                  minAdvance: minAdvance,
                  maxAdvance: maxAdvance,
                  minIvs: minIvs,
                  resultLimit: 100,
                ),
              ),
            ),
          );
      if (!mounted || result == null) {
        return;
      }
      final selected = result.toSearchResult();
      setState(() {
        _selectedPickupTarget = selected;
        _selectedPickupSeedTime = null;
        _selectedPickupSeedHit = null;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = _errorMessage(error));
    }
  }

  Future<void> _reversePickup() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _error = null;
    });
    try {
      final lockedEgg = _parseLockedEgg(l10n);
      final pickupSeed = _selectedPickupReverseSeed(l10n);
      final minAdvance = _parseInt(
        _pickupReverseMinAdvanceController.text,
        l10n.minAdvance,
      );
      final maxAdvance = _parseInt(
        _pickupReverseMaxAdvanceController.text,
        l10n.maxAdvance,
      );
      if (maxAdvance < minAdvance) {
        throw ArgumentError(l10n.maxAdvance);
      }
      final tid = _parseU16(_tidController.text, l10n.trainerId);
      final sid = _parseU16(_sidController.text, l10n.secretId);
      final speciesId = _selectedPickupSpeciesId(l10n);
      final personal = _personal?.tableFor(widget.profile.game);
      final baseStats = personal?.requireSpecies(speciesId).baseStats;
      if (baseStats == null) {
        throw FormatException(l10n.eggSelectHatchedPokemon);
      }
      final observedStats = _parseObservedStats(_observedPickupStatControllers);
      final ivOptions = Gen4StatCalculator.possibleIvValuesForStats(
        baseStats: baseStats,
        stats: observedStats,
        nature: lockedEgg.nature,
        level: 1,
      );
      if (ivOptions.any((options) => options.isEmpty)) {
        throw FormatException(l10n.eggObservedStatsNoIvRanges);
      }
      final result = await Navigator.of(context)
          .push<DpptEggPickupSearchResult>(
            MaterialPageRoute(
              builder: (_) => DpptEggPickupResultsPage(
                request: DpptEggPickupSearchRequest(
                  seed: pickupSeed,
                  heldAdvance: 0,
                  heldPid: lockedEgg.pid.value,
                  heldAbilitySlot: lockedEgg.abilitySlot,
                  heldGender: lockedEgg.gender,
                  heldNature: lockedEgg.nature,
                  heldShiny: lockedEgg.shiny,
                  parentIvs: [
                    _parseRequiredIvs(_parentAControllers),
                    _parseRequiredIvs(_parentBControllers),
                  ],
                  genderRatio: _eggGenderRatio,
                  masuda: _masuda,
                  tid: tid,
                  sid: sid,
                  minAdvance: minAdvance,
                  maxAdvance: maxAdvance,
                  minIvs: const [null, null, null, null, null, null],
                  ivOptions: ivOptions,
                  characteristic: _observedPickupCharacteristic,
                  resultLimit: 100,
                ),
              ),
            ),
          );
      if (!mounted || result == null) {
        return;
      }
      final selected = result.toSearchResult();
      setState(() {
        _selectedPickupTarget = selected;
        _selectedPickupSeedTime = null;
        _selectedPickupSeedHit = null;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = _errorMessage(error));
    }
  }

  Future<void> _openHeldSeedToTime(Gen4EggHeldSearchResult result) async {
    final year = _selectedHeldYear ?? _heldYear;
    if (year == null) {
      return;
    }
    final seedTime = await Navigator.of(context).push<Gen4SeedTime>(
      MaterialPageRoute(
        builder: (_) => SeedToTimePage(seed: result.seed, year: year),
      ),
    );
    if (!mounted || seedTime == null) {
      return;
    }
    setState(() {
      _selectedHeldSeedTime = seedTime;
      _selectedHeldSeedHit = null;
      _selectedHeldHit = null;
    });
  }

  Future<void> _openHeldSeedSearch(Gen4SeedCheckRequest request) async {
    final result = await Navigator.of(context).push<Gen4SeedTimeCalibration>(
      MaterialPageRoute(builder: (_) => SeedCheckPage(request: request)),
    );
    if (!mounted || result == null) {
      return;
    }
    setState(() {
      _selectedHeldSeedHit = result;
      _selectedHeldHit = null;
      _error = null;
    });
  }

  void _refreshHeldSeedSearch() {
    setState(() {
      _selectedHeldSeedHit = null;
      _selectedHeldHit = null;
    });
  }

  Future<void> _openPickupSeedToTime() async {
    final l10n = AppLocalizations.of(context);
    try {
      final target = _selectedPickupTarget;
      if (target == null) {
        return;
      }
      final year = _parseInt(_pickupYearController.text, l10n.year);
      final seedTime = await Navigator.of(context).push<Gen4SeedTime>(
        MaterialPageRoute(
          builder: (_) => SeedToTimePage(seed: target.seed, year: year),
        ),
      );
      if (!mounted || seedTime == null) {
        return;
      }
      setState(() {
        _selectedPickupSeedTime = seedTime;
        _selectedPickupSeedHit = null;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = _errorMessage(error));
    }
  }

  Future<void> _openHeldHitSearch(Gen4SeedTime seedTime) async {
    final l10n = AppLocalizations.of(context);
    try {
      final year = _selectedHeldYear ?? _heldYear;
      if (year == null) {
        return;
      }
      final tid = _parseU16(_tidController.text, l10n.trainerId);
      final sid = _parseU16(_sidController.text, l10n.secretId);
      final delayWindow = _parseInt(
        _heldHitDelayWindowController.text,
        l10n.calibrateDelayWindow,
      );
      if (delayWindow < 0) {
        throw ArgumentError(l10n.calibrateDelayWindow);
      }
      final eggFrameRange = _parseEggFrameRange(l10n);
      final result = await Navigator.of(context).push<DpptEggPidSearchResult>(
        MaterialPageRoute(
          builder: (_) => DpptEggPidResultsPage(
            request: DpptEggPidSearchRequest(
              year: year,
              minDelay: (seedTime.delay - delayWindow).clamp(0, 0xffffffff),
              maxDelay: (seedTime.delay + delayWindow).clamp(0, 0xffffffff),
              tid: tid,
              sid: sid,
              genderRatio: _eggGenderRatio,
              masuda: _masuda,
              minEggFrame: eggFrameRange.min,
              maxEggFrame: eggFrameRange.max,
              nature: _heldHitNature,
              gender: _heldHitGender,
              abilitySlot: _heldHitAbilitySlot,
              shiny: _heldHitShiny,
              resultLimit: 200,
            ),
          ),
        ),
      );
      if (!mounted || result == null) {
        return;
      }
      setState(() {
        _selectedHeldHit = result;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = _errorMessage(error));
    }
  }

  Future<void> _openPickupSeedSearch(Gen4SeedCheckRequest request) async {
    final result = await Navigator.of(context).push<Gen4SeedTimeCalibration>(
      MaterialPageRoute(builder: (_) => SeedCheckPage(request: request)),
    );
    if (!mounted || result == null) {
      return;
    }
    setState(() {
      _selectedPickupSeedHit = result;
      _error = null;
    });
  }

  void _refreshPickupSeedSearch() {
    setState(() => _selectedPickupSeedHit = null);
  }

  void _saveEggTimerCalibration(Gen4TimerCalibrationChange change) {
    widget.onProfileChanged(
      widget.profile.copyWith(
        eggCalibratedDelay: change.nextCalibratedDelay,
        calibratedSecond: change.nextCalibratedSecond,
      ),
    );
  }

  Gen4SeedCheckRequest? _buildHeldSeedCheckRequest(Gen4SeedTime seedTime) {
    final delayWindow = int.tryParse(_heldHitDelayWindowController.text.trim());
    final secondWindow = int.tryParse(_heldSecondWindowController.text.trim());
    final initialAdvanceFilter = int.tryParse(
      _heldInitialAdvanceFilterController.text.trim(),
    );
    if (delayWindow == null ||
        secondWindow == null ||
        delayWindow < 0 ||
        secondWindow < 0 ||
        initialAdvanceFilter != null && initialAdvanceFilter < 0 ||
        seedTime.delay - delayWindow < 0 ||
        seedTime.delay + delayWindow > u32Mask) {
      return null;
    }
    return Gen4SeedCheckRequest(
      target: seedTime,
      delayWindow: delayWindow,
      secondWindow: secondWindow,
      mode: Gen4SeedCheckMode.coinFlips,
      minPhoneCallSkip: initialAdvanceFilter ?? 0,
      maxPhoneCallSkip: initialAdvanceFilter ?? widget.profile.maxPhoneCallSkip,
    );
  }

  Gen4SeedCheckRequest? _buildPickupSeedCheckRequest(Gen4SeedTime seedTime) {
    final delayWindow = int.tryParse(_pickupDelayWindowController.text.trim());
    final secondWindow = int.tryParse(
      _pickupSecondWindowController.text.trim(),
    );
    final initialAdvanceFilter = int.tryParse(
      _pickupInitialAdvanceFilterController.text.trim(),
    );
    if (delayWindow == null ||
        secondWindow == null ||
        delayWindow < 0 ||
        secondWindow < 0 ||
        initialAdvanceFilter != null && initialAdvanceFilter < 0 ||
        seedTime.delay - delayWindow < 0 ||
        seedTime.delay + delayWindow > u32Mask) {
      return null;
    }
    return Gen4SeedCheckRequest(
      target: seedTime,
      delayWindow: delayWindow,
      secondWindow: secondWindow,
      mode: Gen4SeedCheckMode.coinFlips,
      minPhoneCallSkip: initialAdvanceFilter ?? 0,
      maxPhoneCallSkip: initialAdvanceFilter ?? widget.profile.maxPhoneCallSkip,
    );
  }

  int? get _heldYear => int.tryParse(_heldYearController.text.trim());

  int get _heldSearchSpace {
    final year = _heldYear;
    final minDelay = int.tryParse(_heldMinDelayController.text.trim());
    final maxDelay = int.tryParse(_heldMaxDelayController.text.trim());
    final eggFrameCount = _eggFrameCount;
    if (year == null ||
        minDelay == null ||
        maxDelay == null ||
        eggFrameCount == null ||
        year < 2000 ||
        year > 2099 ||
        minDelay < 0 ||
        maxDelay < minDelay) {
      return -1;
    }
    final rawMinDelay = minDelay + year - 2000;
    final rawMaxDelay = maxDelay + year - 2000;
    if (rawMinDelay < 0 || rawMaxDelay > 0xffff) {
      return -1;
    }
    return (maxDelay - minDelay + 1) * 256 * 24 * eggFrameCount;
  }

  bool get _canSearchHeld {
    final space = _heldSearchSpace;
    return space > 0 &&
        space <= gen4TimeFinderMaxGenerationSearchStates &&
        _eggFrameCount != null;
  }

  int? get _eggFrameCount {
    final minFrame = int.tryParse(_heldMinEggFrameController.text.trim());
    final maxFrame = int.tryParse(_heldMaxEggFrameController.text.trim());
    if (minFrame == null ||
        maxFrame == null ||
        minFrame < 1 ||
        maxFrame < minFrame ||
        maxFrame > 999) {
      return null;
    }
    return maxFrame - minFrame + 1;
  }

  String get _eggFrameRangeValue {
    final minFrame = int.tryParse(_heldMinEggFrameController.text.trim());
    final maxFrame = int.tryParse(_heldMaxEggFrameController.text.trim());
    if (_eggFrameCount == null || minFrame == null || maxFrame == null) {
      return '-';
    }
    if (minFrame == maxFrame) {
      return '$minFrame';
    }
    return '$minFrame - $maxFrame';
  }

  List<int> _parseRequiredIvs(List<TextEditingController> controllers) {
    return [
      for (var i = 0; i < controllers.length; i += 1)
        _parseInt(controllers[i].text, _statLabel(i)),
    ];
  }

  List<int?> _parseOptionalIvs(List<TextEditingController> controllers) {
    return [
      for (var i = 0; i < controllers.length; i += 1)
        controllers[i].text.trim().isEmpty
            ? null
            : _parseInt(controllers[i].text, _statLabel(i)),
    ];
  }

  PokemonStats _parseObservedStats(List<TextEditingController> controllers) {
    if (controllers.any((controller) => controller.text.trim().isEmpty)) {
      final l10n = AppLocalizations.of(context);
      throw FormatException(l10n.eggObservedStatsInputError);
    }
    final values = [
      for (var i = 0; i < controllers.length; i += 1)
        _parseInt(controllers[i].text, _statLabel(i)),
    ];
    return PokemonStats(
      hp: values[0],
      attack: values[1],
      defense: values[2],
      specialAttack: values[3],
      specialDefense: values[4],
      speed: values[5],
    );
  }

  int _selectedPickupSpeciesId(AppLocalizations l10n) {
    final selected = _pickupSpeciesId;
    if (selected != null) {
      return selected;
    }
    final text = _pickupSpeciesController.text.trim();
    final numeric = RegExp(r'^\d+').firstMatch(text)?.group(0);
    final speciesId = numeric == null ? null : int.tryParse(numeric);
    if (speciesId != null && speciesId >= 1 && speciesId <= 493) {
      return speciesId;
    }
    throw FormatException(l10n.eggSelectHatchedPokemon);
  }

  int _selectedPickupReverseSeed(AppLocalizations l10n) {
    final seed =
        _selectedPickupSeedHit?.seed ??
        _selectedPickupSeedTime?.seed ??
        _selectedPickupTarget?.seed;
    if (seed == null) {
      throw FormatException(l10n.eggPickupReverseSeedRequired);
    }
    return seed;
  }

  void _refreshPickupSpeciesText() {
    final speciesId = _pickupSpeciesId;
    final names = _names;
    if (speciesId == null || names == null) {
      return;
    }
    _pickupSpeciesController.text =
        '${speciesId.toString().padLeft(3, '0')} ${names.speciesName(speciesId)}';
  }

  int _parseInt(String value, String label) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      throw ArgumentError(label);
    }
    return parsed;
  }

  int _parseHexSeed(String value, String label) {
    final normalized = value.trim().replaceFirst(RegExp('^0x'), '');
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null || parsed < 0 || parsed > 0xffffffff) {
      throw ArgumentError(label);
    }
    return parsed;
  }

  int _parseU16(String value, String label) {
    final parsed = _parseInt(value, label);
    if (parsed < 0 || parsed > 65535) {
      throw ArgumentError(label);
    }
    return parsed;
  }

  ({int min, int max}) _parseEggFrameRange(AppLocalizations l10n) {
    final minFrame = _parseInt(
      _heldMinEggFrameController.text,
      l10n.eggMinFrame,
    );
    final maxFrame = _parseInt(
      _heldMaxEggFrameController.text,
      l10n.eggMaxFrame,
    );
    if (minFrame < 1 || maxFrame < minFrame || maxFrame > 999) {
      throw ArgumentError(l10n.eggTargetEggFrame);
    }
    return (min: minFrame, max: maxFrame);
  }

  bool get _hasLockedEgg {
    final normalizedPid = _lockedPidController.text.trim().replaceFirst(
      RegExp('^0x'),
      '',
    );
    final pid = int.tryParse(normalizedPid, radix: 16);
    return pid != null && pid >= 0 && pid <= 0xffffffff;
  }

  Gen4EggHeldState _parseLockedEgg(AppLocalizations l10n) {
    final pidValue = _parseHexSeed(_lockedPidController.text, l10n.pid);
    final tid = _parseU16(_tidController.text, l10n.trainerId);
    final sid = _parseU16(_sidController.text, l10n.secretId);
    final pid = PokemonPid(pidValue);
    return Gen4EggHeldState(
      advance: 0,
      pid: pid,
      abilitySlot: pid.abilitySlot,
      gender: pid.gender(genderRatio: _eggGenderRatio),
      nature: pid.nature,
      shiny: pid.shiny(tid: tid, sid: sid),
    );
  }

  Gen4EggHeldState? _tryParseLockedEgg(AppLocalizations l10n) {
    try {
      return _parseLockedEgg(l10n);
    } catch (_) {
      return null;
    }
  }

  String _natureName(Nature nature) {
    return _names?.natureName(nature.index) ?? nature.name;
  }

  String _statLabel(int index) {
    final l10n = AppLocalizations.of(context);
    return [
      l10n.hpStat,
      l10n.atkStat,
      l10n.defStat,
      l10n.spaStat,
      l10n.spdStat,
      l10n.speStat,
    ][index];
  }
}

class _SelectedHeldSummary extends StatelessWidget {
  const _SelectedHeldSummary({
    required this.result,
    required this.natureName,
    required this.genderLabel,
  });

  final Gen4EggHeldSearchResult result;
  final String natureName;
  final String genderLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Text(
      '${l10n.eggSelectedPid}: ${_hex32(result.state.pid.value)} · '
      '${l10n.eggTargetEggFrame} ${_eggFrame(result.advance)} · '
      '$natureName · $genderLabel',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _SelectedEggSeedTimeCard extends StatelessWidget {
  const _SelectedEggSeedTimeCard({required this.time});

  final Gen4SeedTime time;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(controlRadius),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            Text(l10n.eggSelectedSeedTime),
            Text(_dateTimeValue(time.dateTime)),
            Text('${l10n.delay}: ${time.delay}'),
            Text('${l10n.second}: ${time.dateTime.second}'),
          ],
        ),
      ),
    );
  }
}

class _PickupPlaceholderCard extends StatelessWidget {
  const _PickupPlaceholderCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(controlRadius),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _EggSeedHitCard extends StatelessWidget {
  const _EggSeedHitCard({required this.match, required this.profile});

  final Gen4SeedTimeCalibration match;
  final AppProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final seed = match.seed.toRadixString(16).padLeft(8, '0').toUpperCase();
    final hitSecond = match.dateTime.second;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(controlRadius),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
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
      ),
    );
  }
}

class _EggSearchSpaceInfo extends StatelessWidget {
  const _EggSearchSpaceInfo({required this.space});

  final int space;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final invalid = space < 0;
    final tooLarge = space > gen4TimeFinderMaxGenerationSearchStates;
    final text = invalid
        ? l10n.searchSpaceInvalid
        : tooLarge
        ? '${l10n.searchSpaceStates(_formatInt(space))} · '
              '${l10n.searchSpaceTooLarge(_formatInt(gen4TimeFinderMaxGenerationSearchStates))}'
        : l10n.searchSpaceStates(_formatInt(space));
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: invalid || tooLarge
            ? colorScheme.error
            : colorScheme.onSurfaceVariant,
      ),
    );
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

class _PickupResultCard extends StatelessWidget {
  const _PickupResultCard({
    required this.result,
    required this.natureName,
    required this.genderLabel,
    required this.hiddenPowerLabel,
  });

  final Gen4EggSearchResult result;
  final String natureName;
  final String genderLabel;
  final String hiddenPowerLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(controlRadius),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResultLine(
                children: [
                  '${l10n.seed}: ${result.seedHex}',
                  '${l10n.delay}: ${result.delay}',
                  '${l10n.eggPickupAdvance}: ${result.pickupFrame}',
                ],
              ),
              const SizedBox(height: 4),
              _ResultLine(
                children: [
                  '${l10n.pid}: ${_hex32(result.state.pid.value)}',
                  natureName,
                  genderLabel,
                  '${l10n.ability}: ${result.state.abilitySlot + 1}',
                ],
              ),
              const SizedBox(height: 4),
              Text('${l10n.ivs}: ${result.state.ivs}'),
              const SizedBox(height: 4),
              _ResultLine(
                children: [
                  '${l10n.hiddenPower}: $hiddenPowerLabel ${result.state.hiddenPowerStrength}',
                  '${l10n.eggInheritance}: ${_inheritance(result.state.inheritance)}',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParentIvGrid extends StatelessWidget {
  const _ParentIvGrid({
    required this.title,
    required this.controllers,
    this.emptyAllowed = false,
    this.headerTrailing,
  });

  final String title;
  final List<TextEditingController> controllers;
  final bool emptyAllowed;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.hpStat,
      l10n.atkStat,
      l10n.defStat,
      l10n.spaStat,
      l10n.spdStat,
      l10n.speStat,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        if (headerTrailing != null) ...[
          headerTrailing!,
          const SizedBox(height: 6),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 10) / 3;
            return Wrap(
              spacing: 5,
              runSpacing: 6,
              children: [
                for (var i = 0; i < controllers.length; i += 1)
                  SizedBox(
                    width: width,
                    child: TextField(
                      controller: controllers[i],
                      decoration: InputDecoration(labelText: labels[i]),
                      keyboardType: TextInputType.number,
                      inputFormatters: platformDigitOnlyInputFormatters(),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EggPokemonAutocomplete extends StatelessWidget {
  const _EggPokemonAutocomplete({
    required this.controller,
    required this.focusNode,
    required this.names,
    required this.game,
    required this.l10n,
    required this.onChanged,
    required this.onSelected,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Gen4NamedResources names;
  final Gen4GameVersion game;
  final AppLocalizations l10n;
  final ValueChanged<String> onChanged;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<_EggSpeciesOption>(
      textEditingController: controller,
      focusNode: focusNode,
      displayStringForOption: (option) => option.displayName,
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) {
          final start = _defaultSpeciesSuggestionStart(game);
          return _eggSpeciesOptions(names).skip(start - 1).take(50);
        }
        final numericStart = int.tryParse(query);
        if (numericStart != null) {
          if (numericStart < 1 || numericStart > 493) {
            return const Iterable<_EggSpeciesOption>.empty();
          }
          return _eggSpeciesOptions(names).skip(numericStart - 1).take(50);
        }
        return _eggSpeciesOptions(
          names,
        ).where((option) => option.searchText.contains(query)).take(50);
      },
      onSelected: (option) => onSelected(option.speciesId),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(labelText: l10n.pokemon),
          textInputAction: TextInputAction.next,
          onChanged: onChanged,
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final suggestions = options.toList(growable: false);
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360, maxHeight: 280),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final option = suggestions[index];
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(option.displayName),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EggSpeciesOption {
  const _EggSpeciesOption({
    required this.speciesId,
    required this.displayName,
    required this.searchText,
  });

  final int speciesId;
  final String displayName;
  final String searchText;
}

class _HexSeedField extends StatelessWidget {
  const _HexSeedField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      textCapitalization: TextCapitalization.characters,
      keyboardType: TextInputType.text,
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 520 ? 3 : 2;
        const spacing = 6.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: 8,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
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

String _errorMessage(Object error) {
  if (error is FormatException) {
    return error.message;
  }
  if (error is ArgumentError) {
    final message = error.message;
    if (message != null) {
      return message.toString();
    }
  }
  return error.toString();
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

List<_EggSpeciesOption> _eggSpeciesOptions(Gen4NamedResources names) {
  return List<_EggSpeciesOption>.generate(493, (index) {
    final speciesId = index + 1;
    final number = speciesId.toString().padLeft(3, '0');
    final name = names.speciesName(speciesId);
    return _EggSpeciesOption(
      speciesId: speciesId,
      displayName: '$number $name',
      searchText: '${names.speciesSearchText(speciesId)} $speciesId $number'
          .toLowerCase(),
    );
  }, growable: false);
}

int _defaultSpeciesSuggestionStart(Gen4GameVersion game) {
  return switch (game) {
    Gen4GameVersion.heartGold || Gen4GameVersion.soulSilver => 152,
    _ => 387,
  };
}

String _hex32(int value) {
  return value.toRadixString(16).toUpperCase().padLeft(8, '0');
}

String _dateTimeValue(DateTime dateTime) {
  return '${dateTime.year.toString().padLeft(4, '0')}-'
      '${dateTime.month.toString().padLeft(2, '0')}-'
      '${dateTime.day.toString().padLeft(2, '0')} '
      '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}:'
      '${dateTime.second.toString().padLeft(2, '0')}';
}

int _eggFrame(int advance) {
  return advance + 1;
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

String _formatPercent(double value) {
  final rounded = value.toStringAsFixed(1);
  return rounded.endsWith('.0')
      ? rounded.substring(0, rounded.length - 2)
      : rounded;
}

void _setIvControllers(List<TextEditingController> controllers, List<int> ivs) {
  for (var i = 0; i < controllers.length; i += 1) {
    controllers[i].text = (i < ivs.length ? ivs[i] : 31).toString();
  }
}

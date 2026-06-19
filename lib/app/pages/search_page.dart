import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/gen4/pokemon_attributes.dart';
import '../../core/gen4/static_generator.dart';
import '../../core/gen4/stat_calculator.dart';
import '../../core/gen4/wild_generator.dart';
import '../../data/gen4/encounter_catalog.dart';
import '../../data/gen4/encounter_targets.dart';
import '../../data/gen4/gen4_game.dart';
import '../../data/gen4/location_names.dart';
import '../../data/gen4/named_resources.dart';
import '../../data/gen4/personal_data.dart';
import '../../data/gen4/pokemon_sources.dart';
import '../../data/gen4/wild_encounters.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/gen4_target_localizations.dart';
import '../app_chrome.dart';
import '../app_profile.dart';
import '../gen4_time_finder_job.dart';

const _maxSpeciesSuggestions = 50;
const _defaultMinAdvance = 10;
const _defaultMaxAdvance = 60;

enum _TimeFilter { any, morning, day, night }

enum _SeedTimeConstraint { any, morning, day, night }

enum _GbaCartridgeFilter { none, ruby, sapphire, emerald, fireRed, leafGreen }

enum _IvComparison {
  lessOrEqual('<='),
  equal('='),
  greaterOrEqual('>=');

  const _IvComparison(this.symbol);

  final String symbol;
}

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    required this.profile,
    required this.isSearching,
    required this.onSearch,
  });

  final AppProfile profile;
  final bool isSearching;
  final ValueChanged<Gen4TimeFinderRequest> onSearch;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _pokemonController = TextEditingController();
  final _pokemonFocusNode = FocusNode();
  final _yearController = TextEditingController(text: _defaultYear());
  final _minDelayController = TextEditingController(text: '900');
  final _maxDelayController = TextEditingController(text: '3000');
  final _minAdvanceController = TextEditingController(
    text: '$_defaultMinAdvance',
  );
  final _maxAdvanceController = TextEditingController(
    text: '$_defaultMaxAdvance',
  );
  final _secondController = TextEditingController();
  final _minPowerController = TextEditingController();
  final _maxPowerController = TextEditingController();
  final _ivControllers = List.generate(6, (_) => TextEditingController());
  final _ivComparisons = List<_IvComparison>.filled(
    6,
    _IvComparison.greaterOrEqual,
  );

  Future<_SearchData>? _dataFuture;
  String? _localeName;
  int? _speciesId;
  String? _locationKey;
  bool _locationsQueried = false;
  _TimeFilter _timeFilter = _TimeFilter.any;
  _GbaCartridgeFilter _gbaCartridge = _GbaCartridgeFilter.none;
  String? _methodKey;
  int? _natureId;
  int? _abilitySlot;
  PokemonGender? _gender;
  _ShinyFilter _shiny = _ShinyFilter.any;
  int? _hiddenPowerType;
  int? _encounterSlot;
  int? _minLevelFilter;
  int? _maxLevelFilter;
  Gen4WildLead _lead = Gen4WildLead.none;
  int _syncNatureId = Nature.hardy.index;
  bool _forceSecond = false;

  @override
  void initState() {
    super.initState();
    _setTimerDefaultFields(widget.profile);
    for (final controller in [
      _pokemonController,
      _yearController,
      _minDelayController,
      _maxDelayController,
      _minAdvanceController,
      _maxAdvanceController,
      _secondController,
      _minPowerController,
      _maxPowerController,
      ..._ivControllers,
    ]) {
      controller.addListener(_refreshSearchSpace);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeName = Localizations.localeOf(context).toString();
    if (_localeName != localeName) {
      _localeName = localeName;
      _dataFuture = _SearchData.load(localeName);
    }
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.game != widget.profile.game) {
      _locationKey = null;
      _locationsQueried = false;
      _methodKey = null;
      _encounterSlot = null;
      _minLevelFilter = null;
      _maxLevelFilter = null;
      _lead = Gen4WildLead.none;
    }
    if (_timerDefaultsChanged(oldWidget.profile, widget.profile)) {
      _setTimerDefaultFields(widget.profile);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _pokemonController,
      _yearController,
      _minDelayController,
      _maxDelayController,
      _minAdvanceController,
      _maxAdvanceController,
      _secondController,
      _minPowerController,
      _maxPowerController,
      ..._ivControllers,
    ]) {
      controller.dispose();
    }
    _pokemonFocusNode.dispose();
    super.dispose();
  }

  void _setTimerDefaultFields(AppProfile profile) {
    _secondController.text = '${profile.calibratedSecond}';
  }

  @override
  Widget build(BuildContext context) {
    final dataFuture = _dataFuture;
    if (dataFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return FutureBuilder<_SearchData>(
      future: dataFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              snapshot.error.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildContent(context, snapshot.data!);
      },
    );
  }

  Widget _buildContent(BuildContext context, _SearchData data) {
    _syncSelectedSpeciesController(data);
    final l10n = AppLocalizations.of(context);
    final sources = _speciesId == null
        ? const <Gen4PokemonSource>[]
        : data.catalog.sourcesForSpecies(
            game: widget.profile.game,
            speciesId: _speciesId!,
          );
    final personalTable = data.personal.tableFor(widget.profile.game);
    final locationOptions = _locationsQueried
        ? _locationOptions(sources, personalTable)
        : const <_LocationOption>[];
    final selectedLocation = _selectedLocation(locationOptions);
    final selectedSource = selectedLocation?.primarySource;
    final methodOptions = _methodOptions(l10n, selectedLocation);
    final selectedMethodKey =
        methodOptions.any((option) => option.key == _methodKey)
        ? _methodKey
        : methodOptions.firstOrNull?.key;
    final personal = _speciesId == null ? null : personalTable[_speciesId!];
    final legalGenders = _legalGenders(personal);
    final selectedGender = legalGenders.contains(_gender) ? _gender : null;
    final leadOptions = _leadOptions(selectedSource, personalTable);
    final selectedLead = leadOptions.contains(_lead)
        ? _lead
        : Gen4WildLead.none;
    final levelCandidates = selectedLocation?.legalLevels ?? const <int>[];
    var selectedMinLevel = levelCandidates.contains(_minLevelFilter)
        ? _minLevelFilter
        : levelCandidates.firstOrNull;
    var selectedMaxLevel = levelCandidates.contains(_maxLevelFilter)
        ? _maxLevelFilter
        : levelCandidates.lastOrNull;
    if (selectedMinLevel != null &&
        selectedMaxLevel != null &&
        selectedMinLevel > selectedMaxLevel) {
      selectedMinLevel = levelCandidates.firstOrNull;
      selectedMaxLevel = levelCandidates.lastOrNull;
    }
    final minLevelOptions = selectedMaxLevel == null
        ? levelCandidates
        : levelCandidates
              .where((level) => level <= selectedMaxLevel!)
              .toList(growable: false);
    final maxLevelOptions = selectedMinLevel == null
        ? levelCandidates
        : levelCandidates
              .where((level) => level >= selectedMinLevel!)
              .toList(growable: false);
    final query = _buildSearchQuery(selectedLocation);
    final space = _searchSpace(query);
    final requestBuild = _buildTimeFinderRequest(
      l10n: l10n,
      data: data,
      query: query,
      location: selectedLocation,
      methodKey: selectedMethodKey,
      lead: selectedLead,
      gender: selectedGender,
      minLevel: selectedMinLevel,
      maxLevel: selectedMaxLevel,
    );
    final request = requestBuild.request;
    final canSearch = request != null && !space.tooLarge && !widget.isSearching;
    final disabledReason = canSearch
        ? null
        : _searchDisabledReason(
            l10n: l10n,
            requestBuild: requestBuild,
            space: space,
            isSearching: widget.isSearching,
          );

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(l10n.target, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _PokemonAutocomplete(
          controller: _pokemonController,
          focusNode: _pokemonFocusNode,
          data: data,
          game: widget.profile.game,
          l10n: l10n,
          onChanged: (text) => _handlePokemonInputChanged(data, text),
          onSelected: (species) => _selectSpecies(data, species),
        ),
        const SizedBox(height: 8),
        _ResponsiveFormGrid(
          children: [
            DropdownButtonFormField<_TimeFilter>(
              isExpanded: true,
              initialValue: _timeFilter,
              decoration: InputDecoration(labelText: l10n.timeCondition),
              items: [
                for (final filter in _TimeFilter.values)
                  DropdownMenuItem(
                    value: filter,
                    child: Text(_timeFilterLabel(l10n, filter)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _timeFilter = value;
                    _locationKey = null;
                    _locationsQueried = false;
                    _methodKey = null;
                    _encounterSlot = null;
                    _minLevelFilter = null;
                    _maxLevelFilter = null;
                    _lead = Gen4WildLead.none;
                  });
                }
              },
            ),
            DropdownButtonFormField<_GbaCartridgeFilter>(
              isExpanded: true,
              initialValue: _gbaCartridge,
              decoration: InputDecoration(labelText: l10n.gbaCartridge),
              items: [
                for (final filter in _GbaCartridgeFilter.values)
                  DropdownMenuItem(
                    value: filter,
                    child: Text(_gbaCartridgeLabel(l10n, filter)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _gbaCartridge = value;
                    _locationKey = null;
                    _locationsQueried = false;
                    _methodKey = null;
                    _encounterSlot = null;
                    _minLevelFilter = null;
                    _maxLevelFilter = null;
                    _lead = Gen4WildLead.none;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _speciesId == null
                ? null
                : () {
                    setState(() {
                      _locationsQueried = true;
                      _locationKey = null;
                      _methodKey = null;
                      _encounterSlot = null;
                      _minLevelFilter = null;
                      _maxLevelFilter = null;
                      _lead = Gen4WildLead.none;
                    });
                  },
            child: Text(l10n.queryLocations),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          key: ValueKey(
            'search-location-$_speciesId-${widget.profile.game}-'
            '$_timeFilter-$_gbaCartridge-$_locationsQueried',
          ),
          initialValue: selectedLocation?.key,
          decoration: InputDecoration(
            labelText: l10n.location,
            prefixIcon: const Icon(Icons.map),
          ),
          items: [
            for (final option in locationOptions)
              DropdownMenuItem(
                value: option.key,
                child: _FittedDropdownText(
                  text: _locationOptionLabel(
                    l10n: l10n,
                    option: option,
                    names: data.names,
                    locations: data.locations,
                  ),
                ),
              ),
          ],
          selectedItemBuilder: (context) => [
            for (final option in locationOptions)
              _FittedDropdownText(
                text: _locationOptionLabel(
                  l10n: l10n,
                  option: option,
                  names: data.names,
                  locations: data.locations,
                ),
              ),
          ],
          onChanged: locationOptions.isEmpty
              ? null
              : (key) {
                  setState(() {
                    _locationKey = key;
                    _methodKey = null;
                    _encounterSlot = null;
                    _minLevelFilter = null;
                    _maxLevelFilter = null;
                    _lead = Gen4WildLead.none;
                  });
                },
        ),
        if (_speciesId != null && _locationsQueried && sources.isEmpty) ...[
          const SizedBox(height: 6),
          Text(
            l10n.noAvailableLocationForGame,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        if (_speciesId != null &&
            _locationsQueried &&
            sources.isNotEmpty &&
            locationOptions.isEmpty) ...[
          const SizedBox(height: 6),
          Text(
            l10n.noMatchingLocations,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 14),
        Text(l10n.filters, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _ResponsiveFormGrid(
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              key: ValueKey('search-method-$selectedMethodKey'),
              initialValue: selectedMethodKey,
              decoration: InputDecoration(labelText: l10n.method),
              items: [
                for (final option in methodOptions)
                  DropdownMenuItem(
                    value: option.key,
                    child: Text(option.label),
                  ),
              ],
              onChanged: methodOptions.length <= 1
                  ? null
                  : (value) => setState(() => _methodKey = value),
            ),
            DropdownButtonFormField<int?>(
              isExpanded: true,
              initialValue: _natureId,
              decoration: InputDecoration(labelText: l10n.nature),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.any)),
                for (var nature = 0; nature < Nature.values.length; nature++)
                  DropdownMenuItem(
                    value: nature,
                    child: Text(data.names.natureName(nature)),
                  ),
              ],
              onChanged: (value) => setState(() => _natureId = value),
            ),
            DropdownButtonFormField<int?>(
              isExpanded: true,
              key: ValueKey('search-ability-$_speciesId-$_abilitySlot'),
              initialValue: _abilitySlot,
              decoration: InputDecoration(labelText: l10n.ability),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.any)),
                for (var slot = 0; slot < 2; slot += 1)
                  DropdownMenuItem(
                    value: slot,
                    child: Text(_abilityLabel(l10n, data, personal, slot)),
                  ),
              ],
              onChanged: personal == null
                  ? null
                  : (value) => setState(() => _abilitySlot = value),
            ),
            DropdownButtonFormField<PokemonGender?>(
              isExpanded: true,
              key: ValueKey('search-gender-$_speciesId-$selectedGender'),
              initialValue: selectedGender,
              decoration: InputDecoration(labelText: l10n.gender),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.any)),
                for (final gender in legalGenders)
                  DropdownMenuItem(
                    value: gender,
                    child: Text(_genderLabel(l10n, gender)),
                  ),
              ],
              onChanged: personal == null
                  ? null
                  : (value) => setState(() => _gender = value),
            ),
            DropdownButtonFormField<int?>(
              isExpanded: true,
              initialValue: _hiddenPowerType,
              decoration: InputDecoration(labelText: l10n.hiddenPower),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.any)),
                for (var type = 0; type < _hiddenPowerTypeCount; type += 1)
                  DropdownMenuItem(
                    value: type,
                    child: Text(_hiddenPowerTypeLabel(l10n, type)),
                  ),
              ],
              onChanged: (value) => setState(() => _hiddenPowerType = value),
            ),
            DropdownButtonFormField<int>(
              isExpanded: true,
              key: ValueKey('search-min-level-${selectedLocation?.key}'),
              initialValue: selectedMinLevel,
              decoration: InputDecoration(labelText: l10n.minLevel),
              items: [
                for (final level in minLevelOptions)
                  DropdownMenuItem(
                    value: level,
                    child: Text(l10n.gen4TargetLevel(level)),
                  ),
              ],
              onChanged: minLevelOptions.isEmpty
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _minLevelFilter = value;
                          if (_maxLevelFilter != null &&
                              _maxLevelFilter! < value) {
                            _maxLevelFilter = value;
                          }
                        });
                      }
                    },
            ),
            DropdownButtonFormField<int>(
              isExpanded: true,
              key: ValueKey('search-max-level-${selectedLocation?.key}'),
              initialValue: selectedMaxLevel,
              decoration: InputDecoration(labelText: l10n.maxLevel),
              items: [
                for (final level in maxLevelOptions)
                  DropdownMenuItem(
                    value: level,
                    child: Text(l10n.gen4TargetLevel(level)),
                  ),
              ],
              onChanged: maxLevelOptions.isEmpty
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _maxLevelFilter = value;
                          if (_minLevelFilter != null &&
                              _minLevelFilter! > value) {
                            _minLevelFilter = value;
                          }
                        });
                      }
                    },
            ),
            TextField(
              controller: _minPowerController,
              decoration: InputDecoration(labelText: l10n.minPower),
              keyboardType: TextInputType.number,
              inputFormatters: platformDigitOnlyInputFormatters(),
            ),
            TextField(
              controller: _maxPowerController,
              decoration: InputDecoration(labelText: l10n.maxPower),
              keyboardType: TextInputType.number,
              inputFormatters: platformDigitOnlyInputFormatters(),
            ),
            DropdownButtonFormField<int?>(
              isExpanded: true,
              key: ValueKey('search-slot-${selectedSource?.key}'),
              initialValue: _encounterSlot,
              decoration: InputDecoration(labelText: l10n.slot),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.any)),
                for (final slot in _encounterSlots(selectedSource))
                  DropdownMenuItem(value: slot, child: Text('$slot')),
              ],
              onChanged:
                  selectedSource?.hasControl(
                        Gen4PokemonSourceControl.encounterSlot,
                      ) ==
                      true
                  ? (value) => setState(() => _encounterSlot = value)
                  : null,
            ),
            DropdownButtonFormField<Gen4WildLead>(
              isExpanded: true,
              key: ValueKey('search-lead-${selectedSource?.key}-$selectedLead'),
              initialValue: selectedLead,
              decoration: InputDecoration(labelText: l10n.lead),
              items: [
                for (final lead in leadOptions)
                  DropdownMenuItem(
                    value: lead,
                    child: Text(_leadLabel(l10n, lead)),
                  ),
              ],
              onChanged: leadOptions.length <= 1
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _lead = value);
                      }
                    },
            ),
            if (selectedLead.isSynchronize)
              DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: _syncNatureId,
                decoration: InputDecoration(labelText: l10n.syncNature),
                items: [
                  for (var nature = 0; nature < Nature.values.length; nature++)
                    DropdownMenuItem(
                      value: nature,
                      child: Text(data.names.natureName(nature)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _syncNatureId = value);
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.shiny),
          secondary: const Icon(Icons.auto_awesome),
          value: _shiny == _ShinyFilter.shiny,
          onChanged: (value) {
            setState(() {
              _shiny = value ? _ShinyFilter.shiny : _ShinyFilter.any;
            });
          },
        ),
        const SizedBox(height: 6),
        _IvInputGrid(
          controllers: _ivControllers,
          comparisons: _ivComparisons,
          labels: [
            l10n.hpIv,
            l10n.atkIv,
            l10n.defIv,
            l10n.spaIv,
            l10n.spdIv,
            l10n.speIv,
          ],
          onComparisonChanged: (index, value) {
            setState(() => _ivComparisons[index] = value);
          },
        ),
        const SizedBox(height: 14),
        Text(l10n.searchRange, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _ResponsiveFormGrid(
          children: [
            TextField(
              controller: _yearController,
              decoration: InputDecoration(labelText: l10n.year),
              keyboardType: TextInputType.number,
              inputFormatters: platformDigitOnlyInputFormatters(),
            ),
            TextField(
              controller: _secondController,
              enabled: _forceSecond,
              decoration: InputDecoration(labelText: l10n.second),
              keyboardType: TextInputType.number,
              inputFormatters: platformDigitOnlyInputFormatters(),
            ),
            TextField(
              controller: _minDelayController,
              decoration: InputDecoration(labelText: l10n.minDelay),
              keyboardType: TextInputType.number,
              inputFormatters: platformDigitOnlyInputFormatters(),
            ),
            TextField(
              controller: _maxDelayController,
              decoration: InputDecoration(labelText: l10n.maxDelay),
              keyboardType: TextInputType.number,
              inputFormatters: platformDigitOnlyInputFormatters(),
            ),
            TextField(
              controller: _minAdvanceController,
              decoration: InputDecoration(labelText: l10n.minAdvance),
              keyboardType: TextInputType.number,
              inputFormatters: platformDigitOnlyInputFormatters(),
            ),
            TextField(
              controller: _maxAdvanceController,
              decoration: InputDecoration(labelText: l10n.maxAdvance),
              keyboardType: TextInputType.number,
              inputFormatters: platformDigitOnlyInputFormatters(),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.forceSecond),
          value: _forceSecond,
          onChanged: (value) => setState(() => _forceSecond = value),
        ),
        _SearchSpaceInfo(space: space),
        if (disabledReason != null) ...[
          const SizedBox(height: 6),
          Text(
            disabledReason,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: canSearch ? () => widget.onSearch(request) : null,
            child: Text(widget.isSearching ? l10n.searching : l10n.search),
          ),
        ),
      ],
    );
  }

  _LocationOption? _selectedLocation(List<_LocationOption> locations) {
    if (locations.isEmpty) {
      return null;
    }
    if (_locationKey != null) {
      for (final location in locations) {
        if (location.key == _locationKey) {
          return location;
        }
      }
    }
    return locations.first;
  }

  List<_MethodOption> _methodOptions(
    AppLocalizations l10n,
    _LocationOption? location,
  ) {
    if (location == null) {
      return const [];
    }
    final options = <String, _MethodOption>{};
    for (final entry in location.entries) {
      final source = entry.source;
      final wild = source.defaultWildMethod;
      if (wild != null) {
        options[wild.name] = _MethodOption(
          wild.name,
          l10n.gen4TargetLabel(wild.label),
        );
        continue;
      }
      final method = source.defaultStaticMethod;
      if (method == null) {
        options['event'] = _MethodOption('event', l10n.gen4TargetStaticEvent);
      } else {
        options[method.name] = _MethodOption(
          method.name,
          l10n.gen4TargetLabel(method.label),
        );
      }
    }
    return options.values.toList(growable: false);
  }

  List<_LocationOption> _locationOptions(
    List<Gen4PokemonSource> sources,
    Gen4PersonalTable personal,
  ) {
    final options = <_LocationOption>[];
    final groupedWild = <String, List<Gen4PokemonSource>>{};
    for (final source in sources) {
      final area = source.target.wildArea;
      if (area == null) {
        options.add(
          _LocationOption(
            key: source.key,
            entries: [_LocationEntry(source: source)],
          ),
        );
        continue;
      }
      groupedWild
          .putIfAbsent(_wildAreaGroupKey(area), () => <Gen4PokemonSource>[])
          .add(source);
    }

    for (final sources in groupedWild.values) {
      sources.sort((left, right) => left.compareTo(right));
      final area = sources.first.target.wildArea!;
      if (area.game.isDppt) {
        options.addAll(_dpptWildLocationOptions(area, sources, personal));
      } else {
        options.addAll(_nonDpptWildLocationOptions(sources, personal));
      }
    }
    return options..sort((left, right) => left.compareTo(right));
  }

  List<_LocationOption> _dpptWildLocationOptions(
    Gen4WildEncounterArea area,
    List<Gen4PokemonSource> sources,
    Gen4PersonalTable personal,
  ) {
    final options = <_LocationOption>[];
    final timeEntries = <_LocationEntry>[];
    for (final time in _dpptTimeVariants(area)) {
      final modifiers = <String>[
        if (time == _SeedTimeConstraint.day &&
            area.modifiers.containsKey('day'))
          'day',
        if (time == _SeedTimeConstraint.night &&
            area.modifiers.containsKey('night'))
          'night',
        ?_selectedGbaModifier(area),
      ];
      final coreArea = area.toCoreArea(personal, modifiers: modifiers);
      final stats = _targetSlotStats(
        area: coreArea,
        speciesId: sources.first.species,
        method: sources.first.defaultWildMethod!,
      );
      if (stats == null) {
        continue;
      }
      final source = _representativeWildSource(
        sources: sources,
        area: area,
        modifiers: modifiers,
        speciesId: sources.first.species,
      );
      if (source == null) {
        continue;
      }
      final entry = _LocationEntry(
        source: source,
        wildArea: coreArea,
        wildModifiers: List.unmodifiable(modifiers),
        minLevel: stats.minLevel,
        maxLevel: stats.maxLevel,
        legalLevels: stats.legalLevels,
        probability: stats.probability,
        timeConstraint: time,
      );
      if (_timeFilter == _TimeFilter.any) {
        timeEntries.add(entry);
      } else {
        options.add(
          _LocationOption(
            key: [
              'wild-final',
              source.game.jsonName,
              source.species,
              area.locationId,
              area.encounter.jsonName,
              time.name,
              ...modifiers,
            ].join(':'),
            entries: [entry],
          ),
        );
      }
    }
    if (timeEntries.isNotEmpty) {
      options.add(
        _LocationOption(
          key: [
            'wild-final',
            sources.first.game.jsonName,
            sources.first.species,
            area.locationId,
            area.encounter.jsonName,
            'any-time',
            ?_selectedGbaModifier(area),
          ].join(':'),
          entries: timeEntries,
        ),
      );
    }
    for (final source in sources) {
      if (source.wildModifier != null &&
          !_isDpptEnvironmentModifier(source.wildModifier) &&
          _sourceMatchesLocationFilters(source)) {
        options.add(_wildLocationOption(source, personal: personal));
      }
    }
    return options;
  }

  List<_LocationOption> _nonDpptWildLocationOptions(
    List<Gen4PokemonSource> sources,
    Gen4PersonalTable personal,
  ) {
    final visibleSources =
        sources.where(_sourceMatchesLocationFilters).toList(growable: false)
          ..sort((left, right) => left.compareTo(right));
    if (_timeFilter != _TimeFilter.any) {
      return [
        for (final source in visibleSources)
          _wildLocationOption(source, personal: personal),
      ];
    }

    final grouped = <String, List<Gen4PokemonSource>>{};
    for (final source in visibleSources) {
      grouped
          .putIfAbsent(_wildSourceMergeKey(source), () => <Gen4PokemonSource>[])
          .add(source);
    }
    return [
      for (final group in grouped.values)
        _mergedWildLocationOption(group, personal: personal),
    ];
  }

  _LocationOption _mergedWildLocationOption(
    List<Gen4PokemonSource> sources, {
    required Gen4PersonalTable personal,
  }) {
    final entries = <_LocationEntry>[];
    for (final source in sources) {
      entries.add(
        _wildLocationOption(source, personal: personal).entries.single,
      );
    }
    return _LocationOption(
      key: [
        'wild-merged',
        sources.first.game.jsonName,
        sources.first.species,
        sources.first.locationId,
        sources.first.wildEncounter?.jsonName,
        sources.first.wildModifier ?? 'base',
      ].join(':'),
      entries: entries,
    );
  }

  _LocationOption _wildLocationOption(
    Gen4PokemonSource source, {
    required Gen4PersonalTable personal,
  }) {
    final area = source.target.wildArea!;
    final coreArea = area.toCoreArea(personal, modifier: source.wildModifier);
    final stats = _targetSlotStats(
      area: coreArea,
      speciesId: source.species,
      method: source.defaultWildMethod!,
    );
    return _LocationOption(
      key: source.key,
      entries: [
        _LocationEntry(
          source: source,
          wildArea: coreArea,
          wildModifiers: source.wildModifier == null
              ? const []
              : [source.wildModifier!],
          minLevel: stats?.minLevel ?? source.minLevel,
          maxLevel: stats?.maxLevel ?? source.maxLevel,
          legalLevels: stats?.legalLevels,
          probability: stats?.probability,
          timeConstraint: _entryTimeConstraintForSource(source),
        ),
      ],
    );
  }

  bool _sourceMatchesLocationFilters(Gen4PokemonSource source) {
    final area = source.target.wildArea;
    if (area == null) {
      return true;
    }
    if (!_timeMatches(area.time, source.wildModifier)) {
      return false;
    }
    if (_isGbaModifier(source.wildModifier)) {
      return switch (_gbaCartridge) {
        _GbaCartridgeFilter.none => false,
        _GbaCartridgeFilter.ruby => source.wildModifier == 'ruby',
        _GbaCartridgeFilter.sapphire => source.wildModifier == 'sapphire',
        _GbaCartridgeFilter.emerald => source.wildModifier == 'emerald',
        _GbaCartridgeFilter.fireRed => source.wildModifier == 'fireRed',
        _GbaCartridgeFilter.leafGreen => source.wildModifier == 'leafGreen',
      };
    }
    return true;
  }

  bool _timeMatches(Gen4WildEncounterTime? time, String? modifier) {
    final selected = switch (_timeFilter) {
      _TimeFilter.any => null,
      _TimeFilter.morning => Gen4WildEncounterTime.morning,
      _TimeFilter.day => Gen4WildEncounterTime.day,
      _TimeFilter.night => Gen4WildEncounterTime.night,
    };
    if (selected != null && time != null && time != selected) {
      return false;
    }
    return switch (modifier) {
      'day' => _timeFilter == _TimeFilter.any || _timeFilter == _TimeFilter.day,
      'night' || 'fishNight' =>
        _timeFilter == _TimeFilter.any || _timeFilter == _TimeFilter.night,
      _ => true,
    };
  }

  List<_SeedTimeConstraint> _dpptTimeVariants(Gen4WildEncounterArea area) {
    final areaTime = area.time;
    if (areaTime != null) {
      final constraint = _seedTimeConstraintForWildTime(areaTime);
      return _timeConstraintMatchesFilter(constraint) ? [constraint] : const [];
    }
    final hasTimeModifiers =
        area.modifiers.containsKey('day') ||
        area.modifiers.containsKey('night');
    if (!hasTimeModifiers) {
      final fallback = switch (_timeFilter) {
        _TimeFilter.any => _SeedTimeConstraint.any,
        _TimeFilter.morning => _SeedTimeConstraint.morning,
        _TimeFilter.day => _SeedTimeConstraint.day,
        _TimeFilter.night => _SeedTimeConstraint.night,
      };
      return [fallback];
    }
    return switch (_timeFilter) {
      _TimeFilter.any => const [
        _SeedTimeConstraint.morning,
        _SeedTimeConstraint.day,
        _SeedTimeConstraint.night,
      ],
      _TimeFilter.morning => const [_SeedTimeConstraint.morning],
      _TimeFilter.day => const [_SeedTimeConstraint.day],
      _TimeFilter.night => const [_SeedTimeConstraint.night],
    };
  }

  bool _timeConstraintMatchesFilter(_SeedTimeConstraint constraint) {
    return switch (_timeFilter) {
      _TimeFilter.any => true,
      _TimeFilter.morning => constraint == _SeedTimeConstraint.morning,
      _TimeFilter.day => constraint == _SeedTimeConstraint.day,
      _TimeFilter.night => constraint == _SeedTimeConstraint.night,
    };
  }

  String? _selectedGbaModifier(Gen4WildEncounterArea area) {
    if (!area.game.isDppt) {
      return null;
    }
    final modifier = switch (_gbaCartridge) {
      _GbaCartridgeFilter.none => null,
      _GbaCartridgeFilter.ruby => 'ruby',
      _GbaCartridgeFilter.sapphire => 'sapphire',
      _GbaCartridgeFilter.emerald => 'emerald',
      _GbaCartridgeFilter.fireRed => 'fireRed',
      _GbaCartridgeFilter.leafGreen => 'leafGreen',
    };
    if (modifier == null || !area.modifiers.containsKey(modifier)) {
      return null;
    }
    return modifier;
  }

  bool _isDpptEnvironmentModifier(String? modifier) {
    return switch (modifier) {
      'day' ||
      'night' ||
      'ruby' ||
      'sapphire' ||
      'emerald' ||
      'fireRed' ||
      'leafGreen' => true,
      _ => false,
    };
  }

  Gen4PokemonSource? _representativeWildSource({
    required List<Gen4PokemonSource> sources,
    required Gen4WildEncounterArea area,
    required List<String> modifiers,
    required int speciesId,
  }) {
    for (final modifier in modifiers.reversed) {
      if (area.slotsForSpecies(speciesId, modifier: modifier).isEmpty) {
        continue;
      }
      for (final source in sources) {
        if (_sameWildArea(source.target.wildArea, area) &&
            source.wildModifier == modifier) {
          return source;
        }
      }
    }
    if (area.hasBaseSlotsForSpecies(speciesId)) {
      for (final source in sources) {
        if (_sameWildArea(source.target.wildArea, area) &&
            source.wildModifier == null) {
          return source;
        }
      }
    }
    for (final source in sources) {
      if (_sameWildArea(source.target.wildArea, area)) {
        return source;
      }
    }
    return null;
  }

  String _wildAreaGroupKey(Gen4WildEncounterArea area) {
    return [
      area.game.jsonName,
      area.locationId,
      area.encounter.jsonName,
      if (_timeFilter != _TimeFilter.any) area.time?.jsonName ?? 'any',
    ].join(':');
  }

  String _wildSourceMergeKey(Gen4PokemonSource source) {
    return [
      source.game.jsonName,
      source.locationId,
      source.wildEncounter?.jsonName ?? 'unknown',
      source.wildModifier ?? 'base',
    ].join(':');
  }

  List<int> _encounterSlots(Gen4PokemonSource? source) {
    if (source == null ||
        !source.hasControl(Gen4PokemonSourceControl.encounterSlot)) {
      return const [];
    }
    return List.generate(12, (index) => index);
  }

  List<Gen4WildLead> _leadOptions(
    Gen4PokemonSource? source,
    Gen4PersonalTable personal,
  ) {
    if (source == null) {
      return const [Gen4WildLead.none];
    }
    if (source.sourceType == Gen4PokemonSourceType.static) {
      final method = source.defaultStaticMethod;
      if (method == null || method == Gen4StaticMethod.method1) {
        return const [Gen4WildLead.none];
      }
      final info = personal[source.species];
      return Gen4WildLead.values
          .where(
            (lead) =>
                lead.supportsStaticSearch &&
                (!lead.isCuteCharm ||
                    (info != null &&
                        PokemonGenderRatio.isVariable(info.genderRatio))),
          )
          .toList(growable: false);
    }
    if (!source.hasControl(Gen4PokemonSourceControl.lead)) {
      return const [Gen4WildLead.none];
    }
    if (source.generator == Gen4PokemonSourceGenerator.honeyTree) {
      return Gen4WildLead.values
          .where((lead) => lead.supportsHoneyTree)
          .toList(growable: false);
    }
    if (source.generator == Gen4PokemonSourceGenerator.pokeRadar ||
        source.generator == Gen4PokemonSourceGenerator.pokeRadarShiny) {
      return Gen4WildLead.values
          .where((lead) => lead.supportsPokeRadar)
          .toList(growable: false);
    }
    final encounter = source.wildEncounter;
    if (encounter != null &&
        (encounter.isGrass || encounter.isBugCatchingContest)) {
      return Gen4WildLead.values
          .where((lead) => lead.supportsGrassWildSearch)
          .toList(growable: false);
    }
    return Gen4WildLead.values
        .where((lead) => lead.supportsBasicWildSearch)
        .toList(growable: false);
  }

  _SearchQuery _buildSearchQuery(_LocationOption? location) {
    final timeConstraint = _timeConstraintForLocation(location);
    return _SearchQuery(
      year: int.tryParse(_yearController.text.trim()),
      minDelay: int.tryParse(_minDelayController.text.trim()),
      maxDelay: int.tryParse(_maxDelayController.text.trim()),
      minAdvance: int.tryParse(_minAdvanceController.text.trim()),
      maxAdvance: int.tryParse(_maxAdvanceController.text.trim()),
      second: _forceSecond ? int.tryParse(_secondController.text.trim()) : null,
      timeConstraint: timeConstraint,
      allowedHours: _hoursForTimeConstraint(timeConstraint),
      location: location,
    );
  }

  _SeedTimeConstraint _timeConstraintForLocation(_LocationOption? location) {
    return switch (_timeFilter) {
      _TimeFilter.morning => _SeedTimeConstraint.morning,
      _TimeFilter.day => _SeedTimeConstraint.day,
      _TimeFilter.night => _SeedTimeConstraint.night,
      _TimeFilter.any => _implicitTimeConstraint(location),
    };
  }

  _SeedTimeConstraint _implicitTimeConstraint(_LocationOption? location) {
    if (location == null) {
      return _SeedTimeConstraint.any;
    }
    final constraints = <_SeedTimeConstraint>{};
    for (final entry in location.entries) {
      constraints.add(
        entry.timeConstraint ?? _implicitTimeConstraintForSource(entry.source),
      );
    }
    return constraints.length == 1 &&
            !constraints.contains(_SeedTimeConstraint.any)
        ? constraints.single
        : _SeedTimeConstraint.any;
  }

  _SearchSpace _searchSpace(_SearchQuery query) {
    if (!query.hasValidRange) {
      return const _SearchSpace.invalid();
    }
    final delayCount = query.maxDelay! - query.minDelay! + 1;
    final advanceCount = query.maxAdvance! - query.minAdvance! + 1;
    return _SearchSpace(query.searchHourUnits * delayCount * advanceCount);
  }

  _TimeFinderRequestBuild _buildTimeFinderRequest({
    required AppLocalizations l10n,
    required _SearchData data,
    required _SearchQuery query,
    required _LocationOption? location,
    required String? methodKey,
    required Gen4WildLead lead,
    required PokemonGender? gender,
    required int? minLevel,
    required int? maxLevel,
  }) {
    if (_speciesId == null) {
      return _TimeFinderRequestBuild.disabled(l10n.searchDisabledSelectPokemon);
    }
    if (!_locationsQueried) {
      return _TimeFinderRequestBuild.disabled(
        l10n.searchDisabledQueryLocations,
      );
    }
    if (location == null) {
      return _TimeFinderRequestBuild.disabled(
        l10n.searchDisabledSelectLocation,
      );
    }
    if (!query.hasValidRange) {
      return _TimeFinderRequestBuild.disabled(l10n.searchDisabledInvalidRange);
    }
    if (methodKey == null) {
      return _TimeFinderRequestBuild.disabled(
        l10n.searchDisabledUnsupportedSource,
      );
    }
    final ivRanges = _ivRangesFromInputs();
    if (ivRanges == null) {
      return _TimeFinderRequestBuild.disabled(l10n.searchDisabledInvalidIvs);
    }
    final minPower = _hiddenPowerStrength(_minPowerController.text);
    final maxPower = _hiddenPowerStrength(_maxPowerController.text);
    if (minPower == _invalidHiddenPowerStrength ||
        maxPower == _invalidHiddenPowerStrength ||
        (minPower != null && maxPower != null && minPower > maxPower)) {
      return _TimeFinderRequestBuild.disabled(
        l10n.searchDisabledInvalidHiddenPower,
      );
    }

    final personal = data.personal.tableFor(widget.profile.game);
    final sources = <Gen4TimeFinderSourceRequest>[];
    for (final entry in location.entries) {
      if (!_sourceMatchesMethod(entry.source, methodKey)) {
        continue;
      }
      final request = _sourceRequest(
        l10n: l10n,
        data: data,
        personal: personal,
        entry: entry,
        minLevelFilter: minLevel,
        maxLevelFilter: maxLevel,
        targetLabel: _locationOptionLabel(
          l10n: l10n,
          option: location,
          names: data.names,
          locations: data.locations,
        ),
        allowedHours: query.sourceAllowedHours(entry),
      );
      if (request != null) {
        sources.add(request);
      }
    }
    if (sources.isEmpty) {
      return _TimeFinderRequestBuild.disabled(
        l10n.searchDisabledUnsupportedSource,
      );
    }

    final request = Gen4TimeFinderRequest(
      year: query.year!,
      minDelay: query.minDelay!,
      maxDelay: query.maxDelay!,
      minAdvance: query.minAdvance!,
      maxAdvance: query.maxAdvance!,
      second: query.second,
      tid: widget.profile.tid,
      sid: widget.profile.sid,
      ivRanges: ivRanges,
      sources: sources,
      nature: _natureId == null ? null : Nature.values[_natureId!],
      abilitySlot: _abilitySlot,
      gender: gender,
      shiny: _shiny == _ShinyFilter.shiny ? Shiny.star : null,
      hiddenPowerType: _hiddenPowerType,
      minHiddenPowerStrength: minPower,
      maxHiddenPowerStrength: maxPower,
      encounterSlot: _encounterSlot,
      lead: lead,
      synchronizeNature: Nature.values[_syncNatureId],
    );
    if (request.rawMinDelay < 0 || request.rawMaxDelay > 0xffff) {
      return _TimeFinderRequestBuild.disabled(
        l10n.searchDisabledDelayYearOverflow,
      );
    }
    if (!request.canSearch) {
      return _TimeFinderRequestBuild.disabled(l10n.searchDisabledInvalidRange);
    }
    return _TimeFinderRequestBuild.ready(request);
  }

  Gen4TimeFinderSourceRequest? _sourceRequest({
    required AppLocalizations l10n,
    required _SearchData data,
    required Gen4PersonalTable personal,
    required _LocationEntry entry,
    required int? minLevelFilter,
    required int? maxLevelFilter,
    required String targetLabel,
    required Set<int> allowedHours,
  }) {
    final source = entry.source;
    final info = personal.requireSpecies(source.species);
    final wildMethod = source.defaultWildMethod;
    if (wildMethod != null) {
      final area = entry.wildArea;
      if (area == null) {
        return null;
      }
      final sourceMinLevel = entry.minLevel ?? source.minLevel;
      final sourceMaxLevel = entry.maxLevel ?? source.maxLevel;
      final effectiveMinLevel =
          minLevelFilter != null && minLevelFilter > sourceMinLevel
          ? minLevelFilter
          : sourceMinLevel;
      final effectiveMaxLevel =
          maxLevelFilter != null && maxLevelFilter < sourceMaxLevel
          ? maxLevelFilter
          : sourceMaxLevel;
      if (effectiveMinLevel > effectiveMaxLevel) {
        return null;
      }
      return Gen4TimeFinderSourceRequest.wild(
        game: source.game.jsonName,
        targetLabel: targetLabel,
        methodLabel: l10n.gen4TargetLabel(wildMethod.label),
        wildMethod: wildMethod,
        wildGame: _wildGameFor(source.game),
        wildArea: area,
        locationId: source.target.wildArea!.locationId,
        wildEncounter: source.target.wildArea!.encounter.jsonName,
        wildTime: source.target.wildArea!.time?.jsonName,
        wildModifier: source.wildModifier,
        wildModifiers: entry.wildModifiers,
        species: source.species,
        minLevel: effectiveMinLevel,
        maxLevel: effectiveMaxLevel,
        baseStats: info.baseStats,
        genderRatio: info.genderRatio,
        abilityIds: info.abilityIds,
        abilityNames: _abilityNames(data, info),
        form: source.form,
        allowedHours: allowedHours,
        feebasTile: source.wildModifier == 'feebasTile',
      );
    }

    final staticMethod = source.defaultStaticMethod;
    if (staticMethod == null) {
      return null;
    }
    if ((minLevelFilter != null && source.minLevel < minLevelFilter) ||
        (maxLevelFilter != null && source.minLevel > maxLevelFilter)) {
      return null;
    }
    return Gen4TimeFinderSourceRequest.static(
      game: source.game.jsonName,
      targetLabel: targetLabel,
      methodLabel: l10n.gen4TargetLabel(staticMethod.label),
      method: staticMethod,
      staticType: source.staticType?.jsonName,
      species: source.species,
      level: source.minLevel,
      baseStats: info.baseStats,
      genderRatio: info.genderRatio,
      abilityIds: info.abilityIds,
      abilityNames: _abilityNames(data, info),
      form: source.form,
      shinyPolicy: _staticShinyPolicy(source.shinyPolicy),
      allowedHours: allowedHours,
    );
  }

  Gen4IvRanges? _ivRangesFromInputs() {
    final ranges = <Gen4IvRange>[];
    for (var index = 0; index < _ivControllers.length; index += 1) {
      final text = _ivControllers[index].text.trim();
      if (text.isEmpty) {
        ranges.add(const Gen4IvRange(min: 0, max: 31));
        continue;
      }
      final value = int.tryParse(text);
      if (value == null || value < 0 || value > 31) {
        return null;
      }
      ranges.add(switch (_ivComparisons[index]) {
        _IvComparison.lessOrEqual => Gen4IvRange(min: 0, max: value),
        _IvComparison.equal => Gen4IvRange(min: value, max: value),
        _IvComparison.greaterOrEqual => Gen4IvRange(min: value, max: 31),
      });
    }
    return Gen4IvRanges(
      hp: ranges[0],
      attack: ranges[1],
      defense: ranges[2],
      specialAttack: ranges[3],
      specialDefense: ranges[4],
      speed: ranges[5],
    );
  }

  void _selectSpecies(_SearchData data, int speciesId) {
    final displayName = data.speciesDisplayName(speciesId);
    setState(() {
      _speciesId = speciesId;
      _pokemonController.value = TextEditingValue(
        text: displayName,
        selection: TextSelection.collapsed(offset: displayName.length),
      );
      _resetTargetControls();
    });
  }

  void _handlePokemonInputChanged(_SearchData data, String text) {
    final speciesId = _speciesId;
    if (speciesId == null || text == data.speciesDisplayName(speciesId)) {
      return;
    }
    setState(() {
      _speciesId = null;
      _resetTargetControls();
    });
  }

  void _resetTargetControls() {
    _locationKey = null;
    _locationsQueried = false;
    _methodKey = null;
    _encounterSlot = null;
    _minLevelFilter = null;
    _maxLevelFilter = null;
    _abilitySlot = null;
    _gender = null;
    _lead = Gen4WildLead.none;
  }

  void _syncSelectedSpeciesController(_SearchData data) {
    final speciesId = _speciesId;
    if (speciesId == null || _pokemonFocusNode.hasFocus) {
      return;
    }
    final displayName = data.speciesDisplayName(speciesId);
    if (_pokemonController.text == displayName) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _speciesId != speciesId || _pokemonFocusNode.hasFocus) {
        return;
      }
      _pokemonController.value = TextEditingValue(
        text: displayName,
        selection: TextSelection.collapsed(offset: displayName.length),
      );
    });
  }

  void _refreshSearchSpace() {
    if (mounted) {
      setState(() {});
    }
  }
}

class _SearchData {
  const _SearchData({
    required this.localeName,
    required this.names,
    required this.locations,
    required this.catalog,
    required this.personal,
    required this.speciesOptions,
  });

  final String localeName;
  final Gen4NamedResources names;
  final Gen4LocationNames locations;
  final Gen4EncounterCatalog catalog;
  final Gen4PersonalData personal;
  final List<_SpeciesOption> speciesOptions;

  static Future<_SearchData> load(String localeName) async {
    final values = await Future.wait([
      Gen4NamedResources.load(localeName),
      Gen4LocationNames.load(localeName),
      Gen4EncounterCatalog.load(),
      Gen4PersonalData.load(),
    ]);
    final names = values[0] as Gen4NamedResources;
    return _SearchData(
      localeName: localeName,
      names: names,
      locations: values[1] as Gen4LocationNames,
      catalog: values[2] as Gen4EncounterCatalog,
      personal: values[3] as Gen4PersonalData,
      speciesOptions: List<_SpeciesOption>.generate(493, (index) {
        final speciesId = index + 1;
        final numberText = speciesId.toString();
        final paddedNumber = numberText.padLeft(3, '0');
        final name = names.speciesName(speciesId);
        return _SpeciesOption(
          speciesId: speciesId,
          name: name,
          displayName: '$paddedNumber $name',
          numberText: numberText,
          searchText: names.speciesSearchText(speciesId),
        );
      }, growable: false),
    );
  }

  String speciesDisplayName(int speciesId) {
    return speciesOptions[speciesId - 1].displayName;
  }
}

class _SpeciesOption {
  const _SpeciesOption({
    required this.speciesId,
    required this.name,
    required this.displayName,
    required this.numberText,
    required this.searchText,
  });

  final int speciesId;
  final String name;
  final String displayName;
  final String numberText;
  final String searchText;
}

class _PokemonAutocomplete extends StatelessWidget {
  const _PokemonAutocomplete({
    required this.controller,
    required this.focusNode,
    required this.data,
    required this.game,
    required this.l10n,
    required this.onChanged,
    required this.onSelected,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final _SearchData data;
  final Gen4GameVersion game;
  final AppLocalizations l10n;
  final ValueChanged<String> onChanged;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return _AutocompleteOptionsPrimer(
      controller: controller,
      focusNode: focusNode,
      token: '${data.localeName}:${game.name}',
      child: RawAutocomplete<_SpeciesOption>(
        textEditingController: controller,
        focusNode: focusNode,
        displayStringForOption: (option) => option.displayName,
        optionsBuilder: (textEditingValue) {
          final query = textEditingValue.text.trim().toLowerCase();
          if (query.isEmpty) {
            final start = _defaultSpeciesSuggestionStart(game);
            return data.speciesOptions
                .skip(start - 1)
                .take(_maxSpeciesSuggestions);
          }
          final numericStart = _numericSpeciesStart(query);
          if (numericStart != null) {
            if (numericStart > data.speciesOptions.length) {
              return const Iterable<_SpeciesOption>.empty();
            }
            return data.speciesOptions
                .skip(numericStart - 1)
                .take(_maxSpeciesSuggestions);
          }
          return data.speciesOptions
              .where((option) => option.searchText.contains(query))
              .take(_maxSpeciesSuggestions);
        },
        onSelected: (option) => onSelected(option.speciesId),
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextField(
            key: const ValueKey('pokemon-field'),
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: l10n.pokemon,
              prefixIcon: const Icon(Icons.catching_pokemon),
            ),
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
                constraints: const BoxConstraints(
                  maxWidth: 360,
                  maxHeight: 280,
                ),
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
      ),
    );
  }
}

class _AutocompleteOptionsPrimer extends StatefulWidget {
  const _AutocompleteOptionsPrimer({
    required this.controller,
    required this.focusNode,
    required this.token,
    required this.child,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Object token;
  final Widget child;

  @override
  State<_AutocompleteOptionsPrimer> createState() =>
      _AutocompleteOptionsPrimerState();
}

class _AutocompleteOptionsPrimerState
    extends State<_AutocompleteOptionsPrimer> {
  @override
  void initState() {
    super.initState();
    _schedulePrime();
  }

  @override
  void didUpdateWidget(covariant _AutocompleteOptionsPrimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token ||
        oldWidget.controller != widget.controller) {
      _schedulePrime();
    }
  }

  void _schedulePrime() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.focusNode.hasFocus) {
        return;
      }
      _refreshAutocompleteOptions(widget.controller);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _SearchSpaceInfo extends StatelessWidget {
  const _SearchSpaceInfo({required this.space});

  final _SearchSpace space;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = space.invalid
        ? colorScheme.error
        : space.tooLarge
        ? colorScheme.error
        : space.value > 1000000
        ? const Color(0xffb26a00)
        : colorScheme.onSurfaceVariant;
    final text = space.invalid
        ? l10n.searchSpaceInvalid
        : space.tooLarge
        ? '${l10n.searchSpaceStates(_formatInt(space.value))} · '
              '${l10n.searchSpaceTooLarge(_formatInt(gen4TimeFinderMaxGenerationSearchStates))}'
        : l10n.searchSpaceStates(_formatInt(space.value));
    return Text(text, style: textTheme.labelSmall?.copyWith(color: color));
  }
}

class _FittedDropdownText extends StatelessWidget {
  const _FittedDropdownText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(text, maxLines: 1, softWrap: false),
        ),
      ),
    );
  }
}

class _ResponsiveFormGrid extends StatelessWidget {
  const _ResponsiveFormGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 260 ? 2 : 1;
        final spacing = columns == 1 ? 0.0 : 6.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: 8,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _IvInputGrid extends StatelessWidget {
  const _IvInputGrid({
    required this.controllers,
    required this.comparisons,
    required this.labels,
    required this.onComparisonChanged,
  });

  final List<TextEditingController> controllers;
  final List<_IvComparison> comparisons;
  final List<String> labels;
  final void Function(int index, _IvComparison value) onComparisonChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 500 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 64,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: controllers.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 2),
                  child: Text(
                    labels[index],
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 76,
                      child: DropdownButtonFormField<_IvComparison>(
                        isExpanded: true,
                        key: ValueKey('iv-comparison-$index'),
                        initialValue: comparisons[index],
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          for (final value in _IvComparison.values)
                            DropdownMenuItem(
                              value: value,
                              child: Text(value.symbol),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            onComparisonChanged(index, value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _ClearOnFirstTapTextField(
                        fieldKey: ValueKey('iv-input-$index'),
                        controller: controllers[index],
                        decoration: const InputDecoration(
                          hintText: '-1',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: platformDigitOnlyInputFormatters(),
                        textInputAction: index == controllers.length - 1
                            ? TextInputAction.done
                            : TextInputAction.next,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ClearOnFirstTapTextField extends StatefulWidget {
  const _ClearOnFirstTapTextField({
    required this.fieldKey,
    required this.controller,
    required this.decoration,
    required this.keyboardType,
    required this.inputFormatters,
    required this.textInputAction,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;

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
      widget.controller.clear();
    }
    if (!_focusNode.hasFocus) {
      _clearOnFocus = false;
    }
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
      widget.controller.clear();
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
        _tapCandidate = true;
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
        final shouldClear = !_hadFocusOnPointerDown && _isTapAt(event.position);
        _resetPointerState();
        if (shouldClear) {
          _requestClearAfterTap();
        }
      },
      child: TextField(
        key: widget.fieldKey,
        focusNode: _focusNode,
        controller: widget.controller,
        decoration: widget.decoration,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        textInputAction: widget.textInputAction,
      ),
    );
  }
}

class _MethodOption {
  const _MethodOption(this.key, this.label);

  final String key;
  final String label;
}

class _LocationOption {
  const _LocationOption({required this.key, required this.entries});

  final String key;
  final List<_LocationEntry> entries;

  Gen4PokemonSource get primarySource => entries.first.source;

  int get minLevel {
    var value = entries.first.minLevel ?? entries.first.source.minLevel;
    for (final entry in entries.skip(1)) {
      final level = entry.minLevel ?? entry.source.minLevel;
      if (level < value) {
        value = level;
      }
    }
    return value;
  }

  int get maxLevel {
    var value = entries.first.maxLevel ?? entries.first.source.maxLevel;
    for (final entry in entries.skip(1)) {
      final level = entry.maxLevel ?? entry.source.maxLevel;
      if (level > value) {
        value = level;
      }
    }
    return value;
  }

  int? get probability => entries.first.probability;

  _SeedTimeConstraint? get timeConstraint {
    final first = entries.first.timeConstraint;
    if (first == null || first == _SeedTimeConstraint.any) {
      return null;
    }
    for (final entry in entries.skip(1)) {
      if (entry.timeConstraint != first) {
        return null;
      }
    }
    return first;
  }

  List<int> get legalLevels {
    final levels = <int>{};
    for (final entry in entries) {
      final entryLevels = entry.legalLevels;
      if (entryLevels != null) {
        levels.addAll(entryLevels);
        continue;
      }
      final minLevel = entry.minLevel ?? entry.source.minLevel;
      final maxLevel = entry.maxLevel ?? entry.source.maxLevel;
      for (var level = minLevel; level <= maxLevel; level += 1) {
        levels.add(level);
      }
    }
    final sorted = levels.toList()..sort();
    return sorted;
  }

  int compareTo(_LocationOption other) {
    final comparisons = [
      primarySource.target.category.sortOrder.compareTo(
        other.primarySource.target.category.sortOrder,
      ),
      _swarmSortOrder(this).compareTo(_swarmSortOrder(other)),
      _specialAreaSortOrder(
        primarySource,
      ).compareTo(_specialAreaSortOrder(other.primarySource)),
      _nullableIntSort(
        primarySource.locationId,
      ).compareTo(_nullableIntSort(other.primarySource.locationId)),
      _wildEncounterSortOrder(
        primarySource.wildEncounter,
      ).compareTo(_wildEncounterSortOrder(other.primarySource.wildEncounter)),
      _timeConstraintSortOrder(
        timeConstraint,
      ).compareTo(_timeConstraintSortOrder(other.timeConstraint)),
      primarySource.compareTo(other.primarySource),
      key.compareTo(other.key),
    ];
    for (final comparison in comparisons) {
      if (comparison != 0) {
        return comparison;
      }
    }
    return 0;
  }
}

class _LocationEntry {
  const _LocationEntry({
    required this.source,
    this.wildArea,
    this.wildModifiers = const [],
    this.minLevel,
    this.maxLevel,
    this.legalLevels,
    this.probability,
    this.timeConstraint,
  });

  final Gen4PokemonSource source;
  final Gen4WildArea? wildArea;
  final List<String> wildModifiers;
  final int? minLevel;
  final int? maxLevel;
  final Set<int>? legalLevels;
  final int? probability;
  final _SeedTimeConstraint? timeConstraint;
}

class _SearchQuery {
  const _SearchQuery({
    required this.year,
    required this.minDelay,
    required this.maxDelay,
    required this.minAdvance,
    required this.maxAdvance,
    required this.second,
    required this.timeConstraint,
    required this.allowedHours,
    required this.location,
  });

  final int? year;
  final int? minDelay;
  final int? maxDelay;
  final int? minAdvance;
  final int? maxAdvance;
  final int? second;
  final _SeedTimeConstraint timeConstraint;
  final Set<int> allowedHours;
  final _LocationOption? location;

  int get searchHourUnits {
    final location = this.location;
    if (location == null) {
      return allowedHours.length;
    }
    var total = 0;
    for (final entry in location.entries) {
      total += sourceAllowedHours(entry).length;
    }
    return total;
  }

  Set<int> sourceAllowedHours(_LocationEntry entry) {
    final entryTimeConstraint = entry.timeConstraint;
    if (entryTimeConstraint != null) {
      return _hoursForTimeConstraint(entryTimeConstraint);
    }
    final explicit = _explicitTimeConstraint(timeConstraint);
    if (explicit != null) {
      return _hoursForTimeConstraint(explicit);
    }
    return _hoursForTimeConstraint(
      _implicitTimeConstraintForSource(entry.source),
    );
  }

  bool get hasValidRange {
    final year = this.year;
    final minDelay = this.minDelay;
    final maxDelay = this.maxDelay;
    final minAdvance = this.minAdvance;
    final maxAdvance = this.maxAdvance;
    final second = this.second;
    return year != null &&
        year >= 2000 &&
        year <= 2099 &&
        minDelay != null &&
        maxDelay != null &&
        minAdvance != null &&
        maxAdvance != null &&
        minDelay >= 0 &&
        maxDelay >= minDelay &&
        maxDelay <= 0xffff &&
        minAdvance >= 0 &&
        maxAdvance >= minAdvance &&
        (second == null || (second >= 0 && second <= 59)) &&
        searchHourUnits > 0;
  }
}

class _SearchSpace {
  const _SearchSpace(this.value) : invalid = false;

  const _SearchSpace.invalid() : value = 0, invalid = true;

  final int value;
  final bool invalid;

  bool get tooLarge =>
      !invalid && value > gen4TimeFinderMaxGenerationSearchStates;
}

class _TimeFinderRequestBuild {
  const _TimeFinderRequestBuild._({this.request, this.disabledReason});

  const _TimeFinderRequestBuild.ready(Gen4TimeFinderRequest request)
    : this._(request: request);

  const _TimeFinderRequestBuild.disabled(String reason)
    : this._(disabledReason: reason);

  final Gen4TimeFinderRequest? request;
  final String? disabledReason;
}

enum _ShinyFilter { any, shiny }

class _TargetSlotStats {
  const _TargetSlotStats({
    required this.minLevel,
    required this.maxLevel,
    required this.legalLevels,
    required this.probability,
  });

  final int minLevel;
  final int maxLevel;
  final Set<int> legalLevels;
  final int probability;
}

_TargetSlotStats? _targetSlotStats({
  required Gen4WildArea area,
  required int speciesId,
  required Gen4WildMethod method,
}) {
  final weights = _encounterSlotWeights(area.encounter, method);
  var probability = 0;
  int? minLevel;
  int? maxLevel;
  final legalLevels = <int>{};
  final slotCount = area.slots.length < weights.length
      ? area.slots.length
      : weights.length;
  for (var index = 0; index < slotCount; index += 1) {
    final slot = area.slots[index];
    if (slot.species != speciesId) {
      continue;
    }
    probability += weights[index];
    for (var level = slot.minLevel; level <= slot.maxLevel; level += 1) {
      legalLevels.add(level);
    }
    minLevel = minLevel == null || slot.minLevel < minLevel
        ? slot.minLevel
        : minLevel;
    maxLevel = maxLevel == null || slot.maxLevel > maxLevel
        ? slot.maxLevel
        : maxLevel;
  }
  if (probability == 0 || minLevel == null || maxLevel == null) {
    return null;
  }
  return _TargetSlotStats(
    minLevel: minLevel,
    maxLevel: maxLevel,
    legalLevels: Set.unmodifiable(legalLevels),
    probability: probability,
  );
}

List<int> _encounterSlotWeights(
  Gen4WildEncounter encounter,
  Gen4WildMethod method,
) {
  return switch (method) {
    Gen4WildMethod.methodJ => switch (encounter) {
      Gen4WildEncounter.goodRod || Gen4WildEncounter.superRod => _water2Rates,
      Gen4WildEncounter.oldRod || Gen4WildEncounter.surfing => _water4Rates,
      _ => _grassRates,
    },
    Gen4WildMethod.methodK => switch (encounter) {
      Gen4WildEncounter.oldRod ||
      Gen4WildEncounter.goodRod ||
      Gen4WildEncounter.superRod => _water3Rates,
      Gen4WildEncounter.surfing => _water4Rates,
      Gen4WildEncounter.headbutt ||
      Gen4WildEncounter.headbuttAlt ||
      Gen4WildEncounter.headbuttSpecial => _headbuttRates,
      Gen4WildEncounter.rockSmash => _rockSmashRates,
      _ => _grassRates,
    },
    Gen4WildMethod.honeyTree ||
    Gen4WildMethod.pokeRadar ||
    Gen4WildMethod.pokeRadarShiny => _grassRates,
  };
}

bool _sameWildArea(Gen4WildEncounterArea? left, Gen4WildEncounterArea right) {
  return left != null &&
      left.game == right.game &&
      left.locationId == right.locationId &&
      left.encounter == right.encounter &&
      left.time == right.time;
}

int _specialAreaSortOrder(Gen4PokemonSource source) {
  final area = source.target.wildArea;
  if (area == null) {
    return 0;
  }
  if (area.game.isDppt && area.locationId >= 23 && area.locationId <= 28) {
    return 1;
  }
  if (area.game.isHgss && area.locationId >= 148 && area.locationId <= 160) {
    return 1;
  }
  return 0;
}

int _swarmSortOrder(_LocationOption option) {
  return option.entries.any((entry) => entry.source.wildModifier == 'swarm')
      ? 1
      : 0;
}

int _nullableIntSort(int? value) {
  return value ?? 0x7fffffff;
}

int _wildEncounterSortOrder(Gen4WildEncounter? encounter) {
  return encounter?.sortOrder ?? 0x7fffffff;
}

const _grassRates = [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1];
const _rockSmashRates = [80, 20];
const _headbuttRates = [50, 15, 15, 10, 5, 5];
const _water2Rates = [40, 40, 15, 4, 1];
const _water3Rates = [40, 30, 15, 10, 5];
const _water4Rates = [60, 30, 5, 4, 1];

List<PokemonGender> _legalGenders(Gen4PersonalInfo? personal) {
  final ratio = personal?.genderRatio;
  if (ratio == null) {
    return const [];
  }
  if (PokemonGenderRatio.isGenderless(ratio)) {
    return const [PokemonGender.genderless];
  }
  if (PokemonGenderRatio.isMaleOnly(ratio)) {
    return const [PokemonGender.male];
  }
  if (PokemonGenderRatio.isFemaleOnly(ratio)) {
    return const [PokemonGender.female];
  }
  return const [PokemonGender.male, PokemonGender.female];
}

String _abilityLabel(
  AppLocalizations l10n,
  _SearchData data,
  Gen4PersonalInfo? personal,
  int slot,
) {
  final abilityId = personal?.abilityIds[slot];
  final name = abilityId == null ? '-' : data.names.abilityName(abilityId);
  return l10n.abilitySlot(slot + 1, name);
}

List<String> _abilityNames(_SearchData data, Gen4PersonalInfo personal) {
  return List<String>.generate(personal.abilityIds.length, (slot) {
    return data.names.abilityName(personal.abilityIds[slot]);
  }, growable: false);
}

String _locationOptionLabel({
  required AppLocalizations l10n,
  required _LocationOption option,
  required Gen4NamedResources names,
  required Gen4LocationNames locations,
}) {
  final source = option.primarySource;
  if (!source.target.isWild) {
    return l10n.gen4PokemonSourceLabel(
      source: source,
      names: names,
      locations: locations,
    );
  }
  final location = locations.name(
    group: source.game.locationGroup,
    locationId: source.locationId!,
  );
  final parts = [
    l10n.gen4TargetLabel(source.display.group),
    location,
    l10n.gen4TargetLabel(source.display.primary),
    ?_sourceModifierLabel(l10n, source),
    ?_locationTimeLabel(l10n, option.timeConstraint),
  ];
  return parts.join(' · ');
}

String? _locationTimeLabel(
  AppLocalizations l10n,
  _SeedTimeConstraint? constraint,
) {
  return switch (constraint) {
    null => null,
    _SeedTimeConstraint.any => l10n.any,
    _SeedTimeConstraint.morning => l10n.gen4TargetTimeMorning,
    _SeedTimeConstraint.day => l10n.gen4TargetTimeDay,
    _SeedTimeConstraint.night => l10n.gen4TargetTimeNight,
  };
}

String? _sourceModifierLabel(AppLocalizations l10n, Gen4PokemonSource source) {
  final modifier = source.wildModifier;
  final labelKey = switch (modifier) {
    null ||
    'day' ||
    'night' ||
    'ruby' ||
    'sapphire' ||
    'emerald' ||
    'fireRed' ||
    'leafGreen' => null,
    'swarm' => 'gen4.target.modifier.swarm',
    'radar' => 'gen4.target.modifier.radar',
    'feebasTile' => 'gen4.target.modifier.feebasTile',
    'hoennSound' => 'gen4.target.modifier.hoennSound',
    'sinnohSound' => 'gen4.target.modifier.sinnohSound',
    'fishNight' => 'gen4.target.modifier.fishNight',
    'fishSwarm' => 'gen4.target.modifier.fishSwarm',
    'safariBlocks' => 'gen4.target.modifier.safariBlocks',
    _ => 'gen4.target.modifier.unknown',
  };
  if (labelKey == null) {
    return null;
  }
  return l10n.gen4TargetLabel(Gen4EncounterTargetLabel(labelKey));
}

String _genderLabel(AppLocalizations l10n, PokemonGender gender) {
  return switch (gender) {
    PokemonGender.male => l10n.genderMale,
    PokemonGender.female => l10n.genderFemale,
    PokemonGender.genderless => l10n.genderGenderless,
  };
}

String _leadLabel(AppLocalizations l10n, Gen4WildLead lead) {
  return switch (lead) {
    Gen4WildLead.none => l10n.leadNone,
    Gen4WildLead.synchronize => l10n.leadSynchronize,
    Gen4WildLead.cuteCharmMale => l10n.leadCuteCharmMale,
    Gen4WildLead.cuteCharmFemale => l10n.leadCuteCharmFemale,
    Gen4WildLead.compoundEyes => l10n.leadCompoundEyes,
    Gen4WildLead.pressure => l10n.leadPressure,
    Gen4WildLead.suctionCups => l10n.leadSuctionCups,
    Gen4WildLead.arenaTrap => l10n.leadArenaTrap,
    Gen4WildLead.magnetPull => l10n.leadMagnetPull,
    Gen4WildLead.static => l10n.leadStatic,
  };
}

extension on Gen4WildLead {
  bool get supportsStaticSearch =>
      this == Gen4WildLead.none || isSynchronize || isCuteCharm;
}

String _timeFilterLabel(AppLocalizations l10n, _TimeFilter filter) {
  return switch (filter) {
    _TimeFilter.any => l10n.any,
    _TimeFilter.morning => l10n.gen4TargetTimeMorning,
    _TimeFilter.day => l10n.gen4TargetTimeDay,
    _TimeFilter.night => l10n.gen4TargetTimeNight,
  };
}

int _timeConstraintSortOrder(_SeedTimeConstraint? constraint) {
  return switch (constraint) {
    null || _SeedTimeConstraint.any => 0,
    _SeedTimeConstraint.morning => 1,
    _SeedTimeConstraint.day => 2,
    _SeedTimeConstraint.night => 3,
  };
}

_SeedTimeConstraint _seedTimeConstraintForWildTime(Gen4WildEncounterTime time) {
  return switch (time) {
    Gen4WildEncounterTime.morning => _SeedTimeConstraint.morning,
    Gen4WildEncounterTime.day => _SeedTimeConstraint.day,
    Gen4WildEncounterTime.night => _SeedTimeConstraint.night,
  };
}

_SeedTimeConstraint? _explicitTimeConstraint(_SeedTimeConstraint constraint) {
  return constraint == _SeedTimeConstraint.any ? null : constraint;
}

_SeedTimeConstraint _implicitTimeConstraintForSource(Gen4PokemonSource source) {
  final time = source.target.wildTime;
  if (time != null) {
    return _seedTimeConstraintForWildTime(time);
  }
  return switch (source.wildModifier) {
    'day' => _SeedTimeConstraint.day,
    'night' || 'fishNight' => _SeedTimeConstraint.night,
    _ => _SeedTimeConstraint.any,
  };
}

_SeedTimeConstraint? _entryTimeConstraintForSource(Gen4PokemonSource source) {
  final constraint = _implicitTimeConstraintForSource(source);
  return constraint == _SeedTimeConstraint.any ? null : constraint;
}

Set<int> _hoursForTimeConstraint(_SeedTimeConstraint constraint) {
  return switch (constraint) {
    _SeedTimeConstraint.any => const {
      0,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
    },
    _SeedTimeConstraint.morning => const {4, 5, 6, 7, 8, 9},
    _SeedTimeConstraint.day => const {10, 11, 12, 13, 14, 15, 16, 17, 18, 19},
    _SeedTimeConstraint.night => const {20, 21, 22, 23, 0, 1, 2, 3},
  };
}

String _gbaCartridgeLabel(AppLocalizations l10n, _GbaCartridgeFilter filter) {
  return switch (filter) {
    _GbaCartridgeFilter.none => l10n.none,
    _GbaCartridgeFilter.ruby => l10n.gbaRuby,
    _GbaCartridgeFilter.sapphire => l10n.gbaSapphire,
    _GbaCartridgeFilter.emerald => l10n.gbaEmerald,
    _GbaCartridgeFilter.fireRed => l10n.gbaFireRed,
    _GbaCartridgeFilter.leafGreen => l10n.gbaLeafGreen,
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

bool _isGbaModifier(String? modifier) {
  return switch (modifier) {
    'ruby' || 'sapphire' || 'emerald' || 'fireRed' || 'leafGreen' => true,
    _ => false,
  };
}

bool _sourceMatchesMethod(Gen4PokemonSource source, String methodKey) {
  final wildMethod = source.defaultWildMethod;
  if (wildMethod != null) {
    return wildMethod.name == methodKey;
  }
  final staticMethod = source.defaultStaticMethod;
  if (staticMethod != null) {
    return staticMethod.name == methodKey;
  }
  return methodKey == 'event';
}

String? _searchDisabledReason({
  required AppLocalizations l10n,
  required _TimeFinderRequestBuild requestBuild,
  required _SearchSpace space,
  required bool isSearching,
}) {
  if (isSearching) {
    return l10n.searchDisabledAlreadyRunning;
  }
  final reason = requestBuild.disabledReason;
  if (reason != null) {
    return reason;
  }
  if (space.tooLarge) {
    return l10n.searchDisabledSearchSpaceTooLarge(
      _formatInt(gen4TimeFinderMaxGenerationSearchStates),
    );
  }
  return null;
}

Gen4WildGame _wildGameFor(Gen4GameVersion game) {
  return switch (game) {
    Gen4GameVersion.diamond ||
    Gen4GameVersion.pearl => Gen4WildGame.diamondPearl,
    Gen4GameVersion.platinum => Gen4WildGame.platinum,
    Gen4GameVersion.heartGold ||
    Gen4GameVersion.soulSilver => Gen4WildGame.heartGoldSoulSilver,
  };
}

Gen4StaticShinyPolicy _staticShinyPolicy(Gen4EncounterShinyPolicy policy) {
  return switch (policy) {
    Gen4EncounterShinyPolicy.random => Gen4StaticShinyPolicy.random,
    Gen4EncounterShinyPolicy.always => Gen4StaticShinyPolicy.always,
    Gen4EncounterShinyPolicy.never => Gen4StaticShinyPolicy.never,
  };
}

int? _hiddenPowerStrength(String text) {
  final valueText = text.trim();
  if (valueText.isEmpty) {
    return null;
  }
  final value = int.tryParse(valueText);
  if (value == null || value < 30 || value > 70) {
    return _invalidHiddenPowerStrength;
  }
  return value;
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

void _refreshAutocompleteOptions(TextEditingController controller) {
  final value = controller.value;
  final transientText = '${value.text} ';
  controller.value = TextEditingValue(
    text: transientText,
    selection: TextSelection.collapsed(offset: transientText.length),
  );
  controller.value = value;
}

int? _numericSpeciesStart(String query) {
  if (!RegExp(r'^\d+$').hasMatch(query)) {
    return null;
  }
  final normalized = query.replaceFirst(RegExp(r'^0+'), '');
  final value = int.tryParse(normalized.isEmpty ? '0' : normalized);
  if (value == null || value <= 0) {
    return 1;
  }
  return value;
}

int _defaultSpeciesSuggestionStart(Gen4GameVersion game) {
  return switch (game) {
    Gen4GameVersion.diamond ||
    Gen4GameVersion.pearl ||
    Gen4GameVersion.platinum => 387,
    Gen4GameVersion.heartGold || Gen4GameVersion.soulSilver => 152,
  };
}

String _defaultYear() {
  return DateTime.now().year.clamp(2000, 2099).toString();
}

bool _timerDefaultsChanged(AppProfile left, AppProfile right) {
  return left.calibratedDelay != right.calibratedDelay ||
      left.calibratedSecond != right.calibratedSecond ||
      left.delayWindow != right.delayWindow ||
      left.secondWindow != right.secondWindow;
}

const _hiddenPowerTypeCount = 16;
const _invalidHiddenPowerStrength = -1;

extension on Gen4WildMethod {
  Gen4EncounterTargetLabel get label => Gen4EncounterTargetLabel(labelKey);
}

extension on Gen4StaticMethod {
  Gen4EncounterTargetLabel get label => Gen4EncounterTargetLabel(labelKey);
}

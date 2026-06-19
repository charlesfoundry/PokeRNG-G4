import '../../core/gen4/wild_generator.dart';
import 'gen4_game.dart';
import 'personal_data.dart';

enum Gen4WildEncounterTime {
  morning('morning'),
  day('day'),
  night('night');

  const Gen4WildEncounterTime(this.jsonName);

  final String jsonName;
}

extension Gen4WildEncounterJson on Gen4WildEncounter {
  String get jsonName {
    return switch (this) {
      Gen4WildEncounter.grass => 'grass',
      Gen4WildEncounter.surfing => 'surfing',
      Gen4WildEncounter.oldRod => 'oldRod',
      Gen4WildEncounter.goodRod => 'goodRod',
      Gen4WildEncounter.superRod => 'superRod',
      Gen4WildEncounter.rockSmash => 'rockSmash',
      Gen4WildEncounter.bugCatchingContest => 'bugCatchingContest',
      Gen4WildEncounter.headbutt => 'headbutt',
      Gen4WildEncounter.headbuttAlt => 'headbuttAlt',
      Gen4WildEncounter.headbuttSpecial => 'headbuttSpecial',
      Gen4WildEncounter.honeyTree => 'honeyTree',
    };
  }

  static Gen4WildEncounter parse(String value) {
    return Gen4WildEncounter.values.firstWhere(
      (encounter) => encounter.jsonName == value,
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'unknown encounter'),
    );
  }
}

class Gen4WildEncounterArea {
  const Gen4WildEncounterArea({
    required this.game,
    required this.locationId,
    required this.encounter,
    required this.rate,
    required this.slots,
    required this.availableSpecies,
    this.time,
    this.modifiers = const {},
  });

  factory Gen4WildEncounterArea.fromJson(Map<String, dynamic> json) {
    final time = json['time'] as String?;
    return Gen4WildEncounterArea(
      game: gen4GameVersionFromJson(json['game'] as String),
      locationId: json['locationId'] as int,
      encounter: Gen4WildEncounterJson.parse(json['encounter'] as String),
      rate: json['rate'] as int,
      time: time == null ? null : _parseTime(time),
      slots: (json['slots'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(Gen4WildEncounterSlot.fromJson)
          .toList(growable: false),
      availableSpecies: (json['availableSpecies'] as List<dynamic>)
          .cast<int>()
          .toSet(),
      modifiers: _parseModifiers(json['modifiers'] as Map<String, dynamic>?),
    );
  }

  final Gen4GameVersion game;
  final int locationId;
  final Gen4WildEncounter encounter;
  final int rate;
  final Gen4WildEncounterTime? time;
  final List<Gen4WildEncounterSlot> slots;
  final Set<int> availableSpecies;
  final Map<String, List<Gen4WildEncounterSlot>> modifiers;

  bool containsSpecies(int speciesId) {
    return availableSpecies.contains(speciesId);
  }

  List<Gen4WildEncounterSlot> slotsForSpecies(
    int speciesId, {
    String? modifier,
  }) {
    final sourceSlots = switch (modifier) {
      null => [
        ...slots,
        for (final modifierSlots in modifiers.values) ...modifierSlots,
      ],
      'base' => slots,
      _ => modifiers[modifier] ?? const <Gen4WildEncounterSlot>[],
    };
    return sourceSlots
        .where((slot) => slot.species == speciesId)
        .toList(growable: false);
  }

  bool hasBaseSlotsForSpecies(int speciesId) {
    return slotsForSpecies(speciesId, modifier: 'base').isNotEmpty;
  }

  List<String> modifiersForSpecies(int speciesId) {
    return [
      for (final entry in modifiers.entries)
        if (entry.value.any((slot) => slot.species == speciesId)) entry.key,
    ];
  }

  Gen4EncounterLevelRange levelRangeForSpecies(
    int speciesId, {
    String? modifier,
  }) {
    final matches = slotsForSpecies(speciesId, modifier: modifier);
    if (matches.isEmpty) {
      throw ArgumentError.value(
        speciesId,
        'speciesId',
        'species is not available in this encounter area',
      );
    }
    var min = matches.first.minLevel;
    var max = matches.first.maxLevel;
    for (final slot in matches.skip(1)) {
      if (slot.minLevel < min) {
        min = slot.minLevel;
      }
      if (slot.maxLevel > max) {
        max = slot.maxLevel;
      }
    }
    return Gen4EncounterLevelRange(min: min, max: max);
  }

  Gen4WildArea toCoreArea(
    Gen4PersonalTable personal, {
    String? modifier,
    List<String> modifiers = const [],
  }) {
    final coreSlots = slots.map((slot) => slot.toCoreSlot(personal)).toList();
    final targetLength = encounter.isHeadbutt ? 6 : 12;
    while (coreSlots.length < targetLength) {
      coreSlots.add(Gen4WildSlot.empty);
    }
    var coreArea = Gen4WildArea(
      rate: rate,
      encounter: encounter,
      slots: List.unmodifiable(coreSlots),
      location: locationId,
      greatMarsh: game.isDppt && locationId >= 23 && locationId <= 28,
      safariZone: game.isHgss && locationId >= 148 && locationId <= 160,
      feebasLocation: game.isDppt && locationId == 22,
    );
    for (final modifierKey in [?modifier, ...modifiers]) {
      final modifierSlots = this.modifiers[modifierKey]
          ?.map((slot) => slot.toCoreSlot(personal))
          .toList(growable: false);
      if (modifierSlots == null || modifierSlots.isEmpty) {
        continue;
      }
      if (game.isDppt) {
        coreArea = _applyDpptModifier(coreArea, modifierKey, modifierSlots);
      } else {
        coreArea = _applyHgssModifier(coreArea, modifierKey, modifierSlots);
      }
    }
    return coreArea;
  }
}

class Gen4WildEncounterSlot {
  const Gen4WildEncounterSlot({
    required this.species,
    required this.minLevel,
    required this.maxLevel,
  });

  factory Gen4WildEncounterSlot.fromJson(Map<String, dynamic> json) {
    return Gen4WildEncounterSlot(
      species: json['species'] as int,
      minLevel: json['minLevel'] as int,
      maxLevel: json['maxLevel'] as int,
    );
  }

  final int species;
  final int minLevel;
  final int maxLevel;

  Gen4WildSlot toCoreSlot(Gen4PersonalTable personal) {
    if (species == 0) {
      return Gen4WildSlot.empty;
    }
    final info = personal.requireSpecies(species);
    return Gen4WildSlot(
      species: species,
      minLevel: minLevel,
      maxLevel: maxLevel,
      genderRatio: info.genderRatio,
      item1: info.itemIds[0],
      item2: info.itemIds[1],
      primaryType: _pokemonType(info.typeIds[0]),
      secondaryType: _pokemonType(info.typeIds[1]),
    );
  }
}

class Gen4EncounterLevelRange {
  const Gen4EncounterLevelRange({required this.min, required this.max});

  final int min;
  final int max;
}

Gen4WildEncounterTime _parseTime(String value) {
  return Gen4WildEncounterTime.values.firstWhere(
    (time) => time.jsonName == value,
    orElse: () => throw ArgumentError.value(value, 'value', 'unknown time'),
  );
}

Map<String, List<Gen4WildEncounterSlot>> _parseModifiers(
  Map<String, dynamic>? json,
) {
  if (json == null) {
    return const {};
  }
  return json.map((key, value) {
    return MapEntry(
      key,
      (value as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(Gen4WildEncounterSlot.fromJson)
          .toList(growable: false),
    );
  });
}

Gen4PokemonType _pokemonType(int typeId) {
  if (typeId < 0 || typeId >= Gen4PokemonType.values.length) {
    throw ArgumentError.value(typeId, 'typeId', 'unknown Pokemon type');
  }
  return Gen4PokemonType.values[typeId];
}

Gen4WildArea _applyDpptModifier(
  Gen4WildArea area,
  String modifier,
  List<Gen4WildSlot> slots,
) {
  return switch (modifier) {
    'swarm' when slots.length >= 2 => area.applyDpptSwarm(
      slot0: slots[0],
      slot1: slots[1],
    ),
    'day' when slots.length >= 2 => area.applyDpptTime(
      time: Gen4DpptTimeModifier.day,
      slot2: slots[0],
      slot3: slots[1],
    ),
    'night' when slots.length >= 2 => area.applyDpptTime(
      time: Gen4DpptTimeModifier.night,
      slot2: slots[0],
      slot3: slots[1],
    ),
    'radar' when slots.length >= 4 => area.applyDpptPokeRadar(
      slot4: slots[0],
      slot5: slots[1],
      slot10: slots[2],
      slot11: slots[3],
    ),
    'ruby' || 'sapphire' || 'emerald' || 'fireRed' || 'leafGreen'
        when slots.length >= 2 =>
      area.applyDpptDualSlot(slot8: slots[0], slot9: slots[1]),
    _ => area,
  };
}

Gen4WildArea _applyHgssModifier(
  Gen4WildArea area,
  String modifier,
  List<Gen4WildSlot> slots,
) {
  return switch (modifier) {
    'hoennSound' when slots.length >= 2 => area.applyHgssRadio(
      radio: Gen4HgssRadioModifier.hoennSound,
      slot2And3: slots[0],
      slot4And5: slots[1],
    ),
    'sinnohSound' when slots.length >= 2 => area.applyHgssRadio(
      radio: Gen4HgssRadioModifier.sinnohSound,
      slot2And3: slots[0],
      slot4And5: slots[1],
    ),
    'fishNight' when slots.isNotEmpty => area.applyHgssTime(
      time: Gen4HgssTimeModifier.night,
      fishNight: slots[0],
    ),
    'swarm' ||
    'fishSwarm' when slots.isNotEmpty => area.applyHgssSwarm(slots[0]),
    _ => area,
  };
}

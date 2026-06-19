import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/gen4/pokemon_attributes.dart';
import 'gen4_game.dart';

class Gen4PersonalData {
  const Gen4PersonalData._(this._tables);

  final Map<Gen4GameVersion, Gen4PersonalTable> _tables;

  static Future<Gen4PersonalData> load() async {
    final raw = await rootBundle.loadString('assets/data/gen4/personal.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return Gen4PersonalData.fromJson(json);
  }

  factory Gen4PersonalData.fromJson(Map<String, dynamic> json) {
    final games = json['games'] as Map<String, dynamic>;
    final tables = games.map((key, value) {
      return MapEntry(
        gen4GameVersionFromJson(key),
        Gen4PersonalTable.fromJson(value as Map<String, dynamic>),
      );
    });
    return Gen4PersonalData._(Map.unmodifiable(tables));
  }

  Gen4PersonalTable tableFor(Gen4GameVersion game) {
    final table = _tables[game];
    if (table == null) {
      throw ArgumentError.value(game, 'game', 'missing personal data');
    }
    return table;
  }
}

class Gen4PersonalTable {
  const Gen4PersonalTable._({
    required this.recordCount,
    required Map<int, Gen4PersonalInfo> species,
  }) : _species = species;

  factory Gen4PersonalTable.fromJson(Map<String, dynamic> json) {
    final species = (json['species'] as Map<String, dynamic>).map((key, value) {
      return MapEntry(
        int.parse(key),
        Gen4PersonalInfo.fromJson(value as Map<String, dynamic>),
      );
    });
    return Gen4PersonalTable._(
      recordCount: json['recordCount'] as int,
      species: Map.unmodifiable(species),
    );
  }

  final int recordCount;
  final Map<int, Gen4PersonalInfo> _species;

  Iterable<int> get speciesIds => _species.keys;

  Gen4PersonalInfo? operator [](int speciesId) => _species[speciesId];

  Gen4PersonalInfo requireSpecies(int speciesId) {
    final info = _species[speciesId];
    if (info == null) {
      throw ArgumentError.value(speciesId, 'speciesId', 'missing species');
    }
    return info;
  }
}

class Gen4PersonalInfo {
  const Gen4PersonalInfo({
    required this.baseStats,
    required this.typeIds,
    required this.itemIds,
    required this.abilityIds,
    required this.genderRatio,
    required this.formCount,
    required this.formStatIndex,
    required this.hatchSpecies,
    required this.present,
  });

  factory Gen4PersonalInfo.fromJson(Map<String, dynamic> json) {
    return Gen4PersonalInfo(
      baseStats: _statsFromJson(json['baseStats'] as List<dynamic>),
      typeIds: (json['typeIds'] as List<dynamic>).cast<int>(),
      itemIds: (json['itemIds'] as List<dynamic>).cast<int>(),
      abilityIds: (json['abilityIds'] as List<dynamic>).cast<int>(),
      genderRatio: json['genderRatio'] as int,
      formCount: json['formCount'] as int,
      formStatIndex: json['formStatIndex'] as int,
      hatchSpecies: json['hatchSpecies'] as int,
      present: json['present'] as bool,
    );
  }

  final PokemonStats baseStats;
  final List<int> typeIds;
  final List<int> itemIds;
  final List<int> abilityIds;
  final int genderRatio;
  final int formCount;
  final int formStatIndex;
  final int hatchSpecies;
  final bool present;

  List<int> get distinctAbilityIds {
    return abilityIds.toSet().toList(growable: false);
  }

  bool get hasForms => formCount > 1;
}

PokemonStats _statsFromJson(List<dynamic> json) {
  final values = json.cast<int>();
  if (values.length != 6) {
    throw FormatException('Expected six base stats, got ${values.length}.');
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

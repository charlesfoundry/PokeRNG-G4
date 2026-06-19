import 'dart:convert';

import 'package:flutter/services.dart';

import 'gen4_game.dart';
import 'wild_encounters.dart';

class Gen4WildEncounterRepository {
  const Gen4WildEncounterRepository._(this.areas);

  final List<Gen4WildEncounterArea> areas;

  static Future<Gen4WildEncounterRepository> load() async {
    final raw = await rootBundle.loadString(
      'assets/data/gen4/wild_encounters.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final areas = (json['areas'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(Gen4WildEncounterArea.fromJson)
        .toList(growable: false);
    return Gen4WildEncounterRepository._(areas);
  }

  List<Gen4WildEncounterArea> areasForGame(Gen4GameVersion game) {
    return areas.where((area) => area.game == game).toList(growable: false);
  }

  List<Gen4WildEncounterArea> areasForSpecies({
    required Gen4GameVersion game,
    required int speciesId,
  }) {
    return areas
        .where((area) {
          return area.game == game && area.containsSpecies(speciesId);
        })
        .toList(growable: false);
  }

  List<Gen4WildEncounterArea> areasForLocation({
    required Gen4GameVersion game,
    required int locationId,
  }) {
    return areas
        .where((area) {
          return area.game == game && area.locationId == locationId;
        })
        .toList(growable: false);
  }
}

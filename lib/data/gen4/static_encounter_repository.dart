import 'dart:convert';

import 'package:flutter/services.dart';

import 'gen4_game.dart';
import 'static_encounters.dart';

class Gen4StaticEncounterRepository {
  const Gen4StaticEncounterRepository._(this.templates);

  final List<Gen4StaticEncounterTemplate> templates;

  static Future<Gen4StaticEncounterRepository> load() async {
    final raw = await rootBundle.loadString(
      'assets/data/gen4/static_encounters.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final templates = (json['encounters'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(Gen4StaticEncounterTemplate.fromJson)
        .toList(growable: false);
    return Gen4StaticEncounterRepository._(templates);
  }

  List<Gen4StaticEncounterTemplate> templatesForGame(Gen4GameVersion game) {
    return templates
        .where((template) => template.game == game)
        .toList(growable: false);
  }

  List<Gen4StaticEncounterTemplate> templatesForSpecies({
    required Gen4GameVersion game,
    required int speciesId,
  }) {
    return templates
        .where((template) {
          return template.game == game && template.species == speciesId;
        })
        .toList(growable: false);
  }
}

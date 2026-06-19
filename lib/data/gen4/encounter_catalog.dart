import '../../core/gen4/wild_generator.dart';
import 'encounter_targets.dart';
import 'gen4_game.dart';
import 'pokemon_sources.dart';
import 'static_encounter_repository.dart';
import 'static_encounters.dart';
import 'wild_encounter_repository.dart';
import 'wild_encounters.dart';

class Gen4EncounterCatalog {
  const Gen4EncounterCatalog({
    required this.wild,
    required this.staticEncounters,
  });

  final Gen4WildEncounterRepository wild;
  final Gen4StaticEncounterRepository staticEncounters;

  static Future<Gen4EncounterCatalog> load() async {
    final values = await Future.wait([
      Gen4WildEncounterRepository.load(),
      Gen4StaticEncounterRepository.load(),
    ]);
    return Gen4EncounterCatalog(
      wild: values[0] as Gen4WildEncounterRepository,
      staticEncounters: values[1] as Gen4StaticEncounterRepository,
    );
  }

  List<Gen4WildEncounterArea> wildAreasForSpecies({
    required Gen4GameVersion game,
    required int speciesId,
  }) {
    return wild.areasForSpecies(game: game, speciesId: speciesId);
  }

  List<Gen4StaticEncounterTemplate> staticTemplatesForSpecies({
    required Gen4GameVersion game,
    required int speciesId,
  }) {
    return staticEncounters.templatesForSpecies(
      game: game,
      speciesId: speciesId,
    );
  }

  List<Gen4EncounterTarget> targetsForSpecies({
    required Gen4GameVersion game,
    required int speciesId,
  }) {
    final targets = [
      for (final area in wildAreasForSpecies(game: game, speciesId: speciesId))
        ..._wildTargetsForArea(area: area, speciesId: speciesId),
      for (final template in staticTemplatesForSpecies(
        game: game,
        speciesId: speciesId,
      ))
        Gen4EncounterTarget.static(template: template),
    ];
    final uniqueTargets = {
      for (final target in targets) target.key: target,
    }.values.toList(growable: false);
    return uniqueTargets..sort((left, right) => left.compareTo(right));
  }

  List<Gen4PokemonSource> sourcesForSpecies({
    required Gen4GameVersion game,
    required int speciesId,
  }) {
    final sources = [
      for (final target in targetsForSpecies(game: game, speciesId: speciesId))
        Gen4PokemonSource.fromTarget(target),
    ];
    return sources..sort((left, right) => left.compareTo(right));
  }

  Gen4PokemonSource? sourceForKey({
    required Gen4GameVersion game,
    required int speciesId,
    required String key,
  }) {
    for (final source in sourcesForSpecies(game: game, speciesId: speciesId)) {
      if (source.key == key) {
        return source;
      }
    }
    return null;
  }

  Gen4PokemonSource? defaultSourceForSpecies({
    required Gen4GameVersion game,
    required int speciesId,
    String? preferredKey,
  }) {
    final sources = sourcesForSpecies(game: game, speciesId: speciesId);
    if (sources.isEmpty) {
      return null;
    }
    if (preferredKey != null) {
      for (final source in sources) {
        if (source.key == preferredKey) {
          return source;
        }
      }
    }
    return sources.first;
  }

  List<Gen4WildEncounter> wildEncounterTypesForSpecies({
    required Gen4GameVersion game,
    required int speciesId,
  }) {
    final seen = <Gen4WildEncounter>{};
    final result = <Gen4WildEncounter>[];
    for (final area in wildAreasForSpecies(game: game, speciesId: speciesId)) {
      if (seen.add(area.encounter)) {
        result.add(area.encounter);
      }
    }
    return result;
  }

  List<Gen4StaticEncounterType> staticEncounterTypesForSpecies({
    required Gen4GameVersion game,
    required int speciesId,
  }) {
    final seen = <Gen4StaticEncounterType>{};
    final result = <Gen4StaticEncounterType>[];
    for (final template in staticTemplatesForSpecies(
      game: game,
      speciesId: speciesId,
    )) {
      if (seen.add(template.type)) {
        result.add(template.type);
      }
    }
    return result;
  }

  bool hasTargetsForSpecies({
    required Gen4GameVersion game,
    required int speciesId,
  }) {
    return wildAreasForSpecies(game: game, speciesId: speciesId).isNotEmpty ||
        staticTemplatesForSpecies(game: game, speciesId: speciesId).isNotEmpty;
  }
}

List<Gen4EncounterTarget> _wildTargetsForArea({
  required Gen4WildEncounterArea area,
  required int speciesId,
}) {
  return [
    if (area.hasBaseSlotsForSpecies(speciesId))
      Gen4EncounterTarget.wild(area: area, species: speciesId),
    for (final modifier in area.modifiersForSpecies(speciesId))
      Gen4EncounterTarget.wild(
        area: area,
        species: speciesId,
        modifier: modifier,
      ),
  ];
}

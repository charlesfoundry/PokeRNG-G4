import '../data/gen4/encounter_targets.dart';
import '../data/gen4/location_names.dart';
import '../data/gen4/named_resources.dart';
import '../data/gen4/pokemon_sources.dart';
import 'app_localizations.dart';

extension Gen4TargetLocalizations on AppLocalizations {
  String gen4TargetLabel(Gen4EncounterTargetLabel label) {
    return switch (label.key) {
      'gen4.target.category.wild' => gen4TargetCategoryWild,
      'gen4.target.category.stationary' => gen4TargetCategoryStationary,
      'gen4.target.category.legend' => gen4TargetCategoryLegend,
      'gen4.target.category.gift' => gen4TargetCategoryGift,
      'gen4.target.category.starter' => gen4TargetCategoryStarter,
      'gen4.target.category.fossil' => gen4TargetCategoryFossil,
      'gen4.target.category.gameCorner' => gen4TargetCategoryGameCorner,
      'gen4.target.category.event' => gen4TargetCategoryEvent,
      'gen4.target.category.roamer' => gen4TargetCategoryRoamer,
      'gen4.target.wild.grass' => gen4TargetWildGrass,
      'gen4.target.wild.surfing' => gen4TargetWildSurfing,
      'gen4.target.wild.oldRod' => gen4TargetWildOldRod,
      'gen4.target.wild.goodRod' => gen4TargetWildGoodRod,
      'gen4.target.wild.superRod' => gen4TargetWildSuperRod,
      'gen4.target.wild.rockSmash' => gen4TargetWildRockSmash,
      'gen4.target.wild.bugCatchingContest' => gen4TargetWildBugCatchingContest,
      'gen4.target.wild.headbutt' => gen4TargetWildHeadbutt,
      'gen4.target.wild.headbuttAlt' => gen4TargetWildHeadbuttAlt,
      'gen4.target.wild.headbuttSpecial' => gen4TargetWildHeadbuttSpecial,
      'gen4.target.wild.honeyTree' => gen4TargetWildHoneyTree,
      'gen4.target.time.morning' => gen4TargetTimeMorning,
      'gen4.target.time.day' => gen4TargetTimeDay,
      'gen4.target.time.night' => gen4TargetTimeNight,
      'gen4.target.method.method1' => gen4TargetMethodMethod1,
      'gen4.target.method.methodJ' => gen4TargetMethodMethodJ,
      'gen4.target.method.methodK' => gen4TargetMethodMethodK,
      'gen4.target.method.honeyTree' => gen4TargetMethodHoneyTree,
      'gen4.target.method.pokeRadar' => gen4TargetMethodPokeRadar,
      'gen4.target.method.pokeRadarShiny' => gen4TargetMethodPokeRadarShiny,
      'gen4.target.static.starter' => gen4TargetStaticStarter,
      'gen4.target.static.fossil' => gen4TargetStaticFossil,
      'gen4.target.static.gift' => gen4TargetStaticGift,
      'gen4.target.static.gameCorner' => gen4TargetStaticGameCorner,
      'gen4.target.static.stationary' => gen4TargetStaticStationary,
      'gen4.target.static.legend' => gen4TargetStaticLegend,
      'gen4.target.static.event' => gen4TargetStaticEvent,
      'gen4.target.static.roamer' => gen4TargetStaticRoamer,
      'gen4.target.shiny.random' => gen4TargetShinyRandom,
      'gen4.target.shiny.always' => gen4TargetShinyAlways,
      'gen4.target.shiny.never' => gen4TargetShinyNever,
      'gen4.target.modifier.swarm' => gen4TargetModifierSwarm,
      'gen4.target.modifier.day' => gen4TargetModifierDay,
      'gen4.target.modifier.night' => gen4TargetModifierNight,
      'gen4.target.modifier.radar' => gen4TargetModifierRadar,
      'gen4.target.modifier.ruby' => gen4TargetModifierRuby,
      'gen4.target.modifier.sapphire' => gen4TargetModifierSapphire,
      'gen4.target.modifier.emerald' => gen4TargetModifierEmerald,
      'gen4.target.modifier.fireRed' => gen4TargetModifierFireRed,
      'gen4.target.modifier.leafGreen' => gen4TargetModifierLeafGreen,
      'gen4.target.modifier.feebasTile' => gen4TargetModifierFeebasTile,
      'gen4.target.modifier.hoennSound' => gen4TargetModifierHoennSound,
      'gen4.target.modifier.sinnohSound' => gen4TargetModifierSinnohSound,
      'gen4.target.modifier.fishNight' => gen4TargetModifierFishNight,
      'gen4.target.modifier.fishSwarm' => gen4TargetModifierFishSwarm,
      'gen4.target.modifier.safariBlocks' => gen4TargetModifierSafariBlocks,
      'gen4.target.modifier.unknown' => gen4TargetModifierUnknown,
      'gen4.target.level' => gen4TargetLevel(_intParam(label, 'level')),
      'gen4.target.levelRange' => gen4TargetLevelRange(
        _intParam(label, 'minLevel'),
        _intParam(label, 'maxLevel'),
      ),
      _ => label.key,
    };
  }

  String gen4PokemonSourceLabel({
    required Gen4PokemonSource source,
    required Gen4NamedResources names,
    required Gen4LocationNames locations,
  }) {
    final description = source.target.isWild
        ? _wildSourceDescription(source: source, locations: locations)
        : _staticSourceDescription(
            source: source,
            names: names,
            locations: locations,
          );
    return '${gen4TargetLabel(source.display.group)} · '
        '$description · ${_levelRangeLabel(source.minLevel, source.maxLevel)}';
  }

  String _wildSourceDescription({
    required Gen4PokemonSource source,
    required Gen4LocationNames locations,
  }) {
    final location = locations.name(
      group: source.game.locationGroup,
      locationId: source.locationId!,
    );
    final parts = [
      location,
      gen4TargetLabel(source.display.primary),
      for (final badge in source.display.badges)
        if (!_isMethodOrLevelLabel(badge)) gen4TargetLabel(badge),
    ];
    return parts.join(' · ');
  }

  String _staticSourceDescription({
    required Gen4PokemonSource source,
    required Gen4NamedResources names,
    required Gen4LocationNames locations,
  }) {
    final template = source.target.staticTemplate!;
    final speciesName = names.speciesName(template.species);
    final separator = template.description.indexOf(' @ ');
    if (separator < 0) {
      if (template.description.endsWith(' Egg')) {
        return '$speciesName Egg';
      }
      return speciesName;
    }
    final locationName = template.description.substring(separator + 3);
    return '$speciesName @ ${locations.staticLocationName(locationName)}';
  }

  String _levelRangeLabel(int minLevel, int maxLevel) {
    if (minLevel == maxLevel) {
      return gen4TargetLevel(minLevel);
    }
    return gen4TargetLevelRange(minLevel, maxLevel);
  }
}

int _intParam(Gen4EncounterTargetLabel label, String name) {
  final value = label.params[name];
  if (value is int) {
    return value;
  }
  throw ArgumentError.value(label.params, 'label.params', 'missing $name');
}

bool _isMethodOrLevelLabel(Gen4EncounterTargetLabel label) {
  return label.key.startsWith('gen4.target.method.') ||
      label.key == 'gen4.target.level' ||
      label.key == 'gen4.target.levelRange';
}

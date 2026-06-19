import '../../core/gen4/static_generator.dart';
import '../../core/gen4/wild_generator.dart';
import 'encounter_targets.dart';
import 'gen4_game.dart';
import 'static_encounters.dart';

enum Gen4PokemonSourceType { wild, static, gift, event, egg }

enum Gen4PokemonSourceGenerator {
  method1Static,
  methodJStatic,
  methodKStatic,
  event,
  methodJWild,
  methodKWild,
  honeyTree,
  pokeRadar,
  pokeRadarShiny,
  egg,
}

enum Gen4PokemonSourceControl {
  encounterSlot,
  levelRange,
  lead,
  synchronize,
  cuteCharm,
  shinyPolicy,
  swarm,
  dualSlot,
  radio,
  pokeRadar,
  honeyTree,
  safariBlocks,
  headbuttTree,
  unownForm,
  roamerSkip,
  eventNotes,
}

class Gen4PokemonSource {
  const Gen4PokemonSource({
    required this.key,
    required this.target,
    required this.sourceType,
    required this.generator,
    required this.controls,
  });

  factory Gen4PokemonSource.fromTarget(Gen4EncounterTarget target) {
    return Gen4PokemonSource(
      key: target.key,
      target: target,
      sourceType: _sourceType(target),
      generator: _generator(target),
      controls: _controls(target),
    );
  }

  final String key;
  final Gen4EncounterTarget target;
  final Gen4PokemonSourceType sourceType;
  final Gen4PokemonSourceGenerator generator;
  final Set<Gen4PokemonSourceControl> controls;

  Gen4GameVersion get game => target.game;

  int get species => target.species;

  int get form => target.form;

  int get minLevel => target.minLevel;

  int get maxLevel => target.maxLevel;

  int? get locationId => target.locationId;

  Gen4WildEncounter? get wildEncounter => target.wildEncounter;

  String? get wildModifier => target.wildModifier;

  Gen4StaticEncounterType? get staticType => target.staticType;

  Gen4WildMethod? get defaultWildMethod => target.defaultWildMethod;

  Gen4StaticMethod? get defaultStaticMethod => target.defaultStaticMethod;

  Gen4EncounterShinyPolicy get shinyPolicy => target.shinyPolicy;

  Gen4EncounterTargetDisplay get display => target.display;

  bool hasControl(Gen4PokemonSourceControl control) {
    return controls.contains(control);
  }

  int compareTo(Gen4PokemonSource other) {
    return target.compareTo(other.target);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Gen4PokemonSource && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;
}

Gen4PokemonSourceType _sourceType(Gen4EncounterTarget target) {
  if (target.isWild) {
    return Gen4PokemonSourceType.wild;
  }
  return switch (target.staticType!) {
    Gen4StaticEncounterType.gift ||
    Gen4StaticEncounterType.starter ||
    Gen4StaticEncounterType.fossil ||
    Gen4StaticEncounterType.gameCorner => Gen4PokemonSourceType.gift,
    Gen4StaticEncounterType.event => Gen4PokemonSourceType.event,
    Gen4StaticEncounterType.stationary ||
    Gen4StaticEncounterType.legend ||
    Gen4StaticEncounterType.roamer => Gen4PokemonSourceType.static,
  };
}

Gen4PokemonSourceGenerator _generator(Gen4EncounterTarget target) {
  final wildMethod = target.defaultWildMethod;
  if (wildMethod != null) {
    return switch (wildMethod) {
      Gen4WildMethod.methodJ => Gen4PokemonSourceGenerator.methodJWild,
      Gen4WildMethod.methodK => Gen4PokemonSourceGenerator.methodKWild,
      Gen4WildMethod.honeyTree => Gen4PokemonSourceGenerator.honeyTree,
      Gen4WildMethod.pokeRadar => Gen4PokemonSourceGenerator.pokeRadar,
      Gen4WildMethod.pokeRadarShiny =>
        Gen4PokemonSourceGenerator.pokeRadarShiny,
    };
  }
  if (target.staticType == Gen4StaticEncounterType.event) {
    return Gen4PokemonSourceGenerator.event;
  }
  return switch (target.defaultStaticMethod!) {
    Gen4StaticMethod.method1 => Gen4PokemonSourceGenerator.method1Static,
    Gen4StaticMethod.methodJ => Gen4PokemonSourceGenerator.methodJStatic,
    Gen4StaticMethod.methodK => Gen4PokemonSourceGenerator.methodKStatic,
  };
}

Set<Gen4PokemonSourceControl> _controls(Gen4EncounterTarget target) {
  final controls = <Gen4PokemonSourceControl>{};
  final wildEncounter = target.wildEncounter;
  if (wildEncounter != null) {
    controls
      ..add(Gen4PokemonSourceControl.encounterSlot)
      ..add(Gen4PokemonSourceControl.levelRange)
      ..add(Gen4PokemonSourceControl.lead);
    if (wildEncounter.isHoneyTree) {
      controls.add(Gen4PokemonSourceControl.honeyTree);
    }
    if (wildEncounter.isHeadbutt) {
      controls.add(Gen4PokemonSourceControl.headbuttTree);
    }
    if (target.species == 201) {
      controls.add(Gen4PokemonSourceControl.unownForm);
    }
    switch (target.wildModifier) {
      case 'swarm':
      case 'fishSwarm':
        controls.add(Gen4PokemonSourceControl.swarm);
      case 'radar':
        controls.add(Gen4PokemonSourceControl.pokeRadar);
      case 'ruby':
      case 'sapphire':
      case 'emerald':
      case 'fireRed':
      case 'leafGreen':
        controls.add(Gen4PokemonSourceControl.dualSlot);
      case 'hoennSound':
      case 'sinnohSound':
        controls.add(Gen4PokemonSourceControl.radio);
      case 'safariBlocks':
        controls.add(Gen4PokemonSourceControl.safariBlocks);
    }
    return Set.unmodifiable(controls);
  }

  controls
    ..add(Gen4PokemonSourceControl.synchronize)
    ..add(Gen4PokemonSourceControl.cuteCharm)
    ..add(Gen4PokemonSourceControl.shinyPolicy);
  if (target.staticType == Gen4StaticEncounterType.roamer) {
    controls.add(Gen4PokemonSourceControl.roamerSkip);
  }
  if (target.staticType == Gen4StaticEncounterType.event) {
    controls.add(Gen4PokemonSourceControl.eventNotes);
  }
  return Set.unmodifiable(controls);
}

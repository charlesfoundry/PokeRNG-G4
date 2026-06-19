import '../../core/gen4/static_generator.dart';
import '../../core/gen4/wild_generator.dart';
import 'gen4_game.dart';
import 'static_encounters.dart';
import 'wild_encounters.dart';

enum Gen4EncounterTargetKind { wild, static }

enum Gen4EncounterShinyPolicy { random, always, never }

enum Gen4EncounterSearchPage { wild, static }

enum Gen4EncounterTargetCategory {
  wild,
  stationary,
  legend,
  gift,
  starter,
  fossil,
  gameCorner,
  event,
  roamer,
}

class Gen4EncounterTargetDisplay {
  const Gen4EncounterTargetDisplay({
    required this.group,
    required this.primary,
    required this.badges,
    required this.params,
  });

  final Gen4EncounterTargetLabel group;
  final Gen4EncounterTargetLabel primary;
  final List<Gen4EncounterTargetLabel> badges;
  final Map<String, Object?> params;
}

class Gen4EncounterTargetLabel {
  const Gen4EncounterTargetLabel(this.key, [this.params = const {}]);

  final String key;
  final Map<String, Object?> params;
}

class Gen4EncounterTarget {
  const Gen4EncounterTarget._({
    required this.kind,
    required this.game,
    required this.species,
    required this.form,
    required this.minLevel,
    required this.maxLevel,
    required this.shinyPolicy,
    this.wildArea,
    this.staticTemplate,
    this.wildModifier,
    this.defaultWildMethod,
    this.defaultStaticMethod,
  });

  factory Gen4EncounterTarget.wild({
    required Gen4WildEncounterArea area,
    required int species,
    String? modifier,
  }) {
    final levels = area.levelRangeForSpecies(species, modifier: modifier);
    return Gen4EncounterTarget._(
      kind: Gen4EncounterTargetKind.wild,
      game: area.game,
      species: species,
      form: 0,
      minLevel: levels.min,
      maxLevel: levels.max,
      shinyPolicy: Gen4EncounterShinyPolicy.random,
      wildArea: area,
      wildModifier: modifier,
      defaultWildMethod: _defaultWildMethod(area, modifier: modifier),
    );
  }

  factory Gen4EncounterTarget.static({
    required Gen4StaticEncounterTemplate template,
  }) {
    return Gen4EncounterTarget._(
      kind: Gen4EncounterTargetKind.static,
      game: template.game,
      species: template.species,
      form: template.form,
      minLevel: template.level,
      maxLevel: template.level,
      shinyPolicy: _staticShinyPolicy(template.shinyPolicy),
      staticTemplate: template,
      defaultStaticMethod: template.method,
    );
  }

  final Gen4EncounterTargetKind kind;
  final Gen4GameVersion game;
  final int species;
  final int form;
  final int minLevel;
  final int maxLevel;
  final Gen4EncounterShinyPolicy shinyPolicy;
  final Gen4WildEncounterArea? wildArea;
  final Gen4StaticEncounterTemplate? staticTemplate;
  final String? wildModifier;
  final Gen4WildMethod? defaultWildMethod;
  final Gen4StaticMethod? defaultStaticMethod;

  bool get isWild => kind == Gen4EncounterTargetKind.wild;

  bool get isStatic => kind == Gen4EncounterTargetKind.static;

  Gen4EncounterSearchPage get searchPage {
    return switch (kind) {
      Gen4EncounterTargetKind.wild => Gen4EncounterSearchPage.wild,
      Gen4EncounterTargetKind.static => Gen4EncounterSearchPage.static,
    };
  }

  Gen4EncounterTargetCategory get category {
    final template = staticTemplate;
    if (template == null) {
      return Gen4EncounterTargetCategory.wild;
    }
    return switch (template.type) {
      Gen4StaticEncounterType.starter => Gen4EncounterTargetCategory.starter,
      Gen4StaticEncounterType.fossil => Gen4EncounterTargetCategory.fossil,
      Gen4StaticEncounterType.gift => Gen4EncounterTargetCategory.gift,
      Gen4StaticEncounterType.gameCorner =>
        Gen4EncounterTargetCategory.gameCorner,
      Gen4StaticEncounterType.stationary =>
        Gen4EncounterTargetCategory.stationary,
      Gen4StaticEncounterType.legend => Gen4EncounterTargetCategory.legend,
      Gen4StaticEncounterType.event => Gen4EncounterTargetCategory.event,
      Gen4StaticEncounterType.roamer => Gen4EncounterTargetCategory.roamer,
    };
  }

  int? get locationId => wildArea?.locationId;

  Gen4WildEncounter? get wildEncounter => wildArea?.encounter;

  Gen4WildEncounterTime? get wildTime => wildArea?.time;

  Gen4StaticEncounterType? get staticType => staticTemplate?.type;

  String? get staticDescription => staticTemplate?.description;

  Gen4EncounterTargetDisplay get display {
    final area = wildArea;
    final badges = <Gen4EncounterTargetLabel>[];
    if (area != null) {
      final time = area.time;
      if (time != null) {
        badges.add(Gen4EncounterTargetLabel(time.labelKey));
      }
      final modifier = wildModifier;
      if (modifier != null) {
        badges.add(Gen4EncounterTargetLabel(_wildModifierLabelKey(modifier)));
      }
      badges.add(Gen4EncounterTargetLabel(defaultWildMethod!.labelKey));
      badges.add(_levelLabel);
      return Gen4EncounterTargetDisplay(
        group: Gen4EncounterTargetLabel(category.labelKey),
        primary: Gen4EncounterTargetLabel(area.encounter.labelKey),
        badges: List.unmodifiable(badges),
        params: {
          'game': game.jsonName,
          'species': species,
          'form': form,
          'locationId': area.locationId,
          'encounter': area.encounter.jsonName,
          'time': area.time?.jsonName,
          'modifier': wildModifier,
          'method': defaultWildMethod!.labelKey,
          'minLevel': minLevel,
          'maxLevel': maxLevel,
          'shiny': shinyPolicy.labelKey,
        },
      );
    }

    final template = staticTemplate!;
    badges.add(Gen4EncounterTargetLabel(template.method.labelKey));
    if (shinyPolicy != Gen4EncounterShinyPolicy.random) {
      badges.add(Gen4EncounterTargetLabel(shinyPolicy.labelKey));
    }
    badges.add(_levelLabel);
    return Gen4EncounterTargetDisplay(
      group: Gen4EncounterTargetLabel(category.labelKey),
      primary: Gen4EncounterTargetLabel(template.type.labelKey),
      badges: List.unmodifiable(badges),
      params: {
        'game': game.jsonName,
        'species': species,
        'form': form,
        'staticType': template.type.jsonName,
        'method': template.method.labelKey,
        'minLevel': minLevel,
        'maxLevel': maxLevel,
        'shiny': shinyPolicy.labelKey,
      },
    );
  }

  Gen4EncounterTargetLabel get _levelLabel {
    if (minLevel == maxLevel) {
      return Gen4EncounterTargetLabel('gen4.target.level', {'level': minLevel});
    }
    return Gen4EncounterTargetLabel('gen4.target.levelRange', {
      'minLevel': minLevel,
      'maxLevel': maxLevel,
    });
  }

  List<int> get sortKey {
    final area = wildArea;
    if (area != null) {
      return [
        category.sortOrder,
        area.locationId,
        area.encounter.sortOrder,
        (area.time ?? Gen4WildEncounterTime.day).sortOrder,
        _wildModifierSortOrder(wildModifier),
        minLevel,
        maxLevel,
      ];
    }

    final template = staticTemplate!;
    return [
      category.sortOrder,
      template.level,
      template.form,
      template.method.sortOrder,
      template.shinyPolicy.sortOrder,
    ];
  }

  int compareTo(Gen4EncounterTarget other) {
    final left = sortKey;
    final right = other.sortKey;
    final length = left.length < right.length ? left.length : right.length;
    for (var i = 0; i < length; i += 1) {
      final comparison = left[i].compareTo(right[i]);
      if (comparison != 0) {
        return comparison;
      }
    }
    final lengthComparison = left.length.compareTo(right.length);
    if (lengthComparison != 0) {
      return lengthComparison;
    }
    return key.compareTo(other.key);
  }

  String get key {
    final area = wildArea;
    if (area != null) {
      final time = area.time?.jsonName ?? 'any';
      final modifier = wildModifier ?? 'base';
      return [
        game.jsonName,
        'wild',
        species,
        area.locationId,
        area.encounter.jsonName,
        time,
        modifier,
      ].join(':');
    }
    final template = staticTemplate!;
    return [
      game.jsonName,
      'static',
      species,
      template.type.jsonName,
      template.description,
      template.form,
      template.level,
      template.method.jsonName,
      template.shinyPolicy.jsonName,
    ].join(':');
  }
}

extension Gen4EncounterTargetCategorySort on Gen4EncounterTargetCategory {
  String get labelKey {
    return switch (this) {
      Gen4EncounterTargetCategory.wild => 'gen4.target.category.wild',
      Gen4EncounterTargetCategory.stationary =>
        'gen4.target.category.stationary',
      Gen4EncounterTargetCategory.legend => 'gen4.target.category.legend',
      Gen4EncounterTargetCategory.gift => 'gen4.target.category.gift',
      Gen4EncounterTargetCategory.starter => 'gen4.target.category.starter',
      Gen4EncounterTargetCategory.fossil => 'gen4.target.category.fossil',
      Gen4EncounterTargetCategory.gameCorner =>
        'gen4.target.category.gameCorner',
      Gen4EncounterTargetCategory.event => 'gen4.target.category.event',
      Gen4EncounterTargetCategory.roamer => 'gen4.target.category.roamer',
    };
  }

  int get sortOrder {
    return switch (this) {
      Gen4EncounterTargetCategory.wild => 0,
      Gen4EncounterTargetCategory.stationary => 100,
      Gen4EncounterTargetCategory.legend => 200,
      Gen4EncounterTargetCategory.gift => 300,
      Gen4EncounterTargetCategory.starter => 310,
      Gen4EncounterTargetCategory.fossil => 320,
      Gen4EncounterTargetCategory.gameCorner => 330,
      Gen4EncounterTargetCategory.event => 400,
      Gen4EncounterTargetCategory.roamer => 500,
    };
  }
}

extension Gen4WildEncounterSort on Gen4WildEncounter {
  String get labelKey {
    return switch (this) {
      Gen4WildEncounter.grass => 'gen4.target.wild.grass',
      Gen4WildEncounter.surfing => 'gen4.target.wild.surfing',
      Gen4WildEncounter.oldRod => 'gen4.target.wild.oldRod',
      Gen4WildEncounter.goodRod => 'gen4.target.wild.goodRod',
      Gen4WildEncounter.superRod => 'gen4.target.wild.superRod',
      Gen4WildEncounter.rockSmash => 'gen4.target.wild.rockSmash',
      Gen4WildEncounter.bugCatchingContest =>
        'gen4.target.wild.bugCatchingContest',
      Gen4WildEncounter.headbutt => 'gen4.target.wild.headbutt',
      Gen4WildEncounter.headbuttAlt => 'gen4.target.wild.headbuttAlt',
      Gen4WildEncounter.headbuttSpecial => 'gen4.target.wild.headbuttSpecial',
      Gen4WildEncounter.honeyTree => 'gen4.target.wild.honeyTree',
    };
  }

  int get sortOrder {
    return switch (this) {
      Gen4WildEncounter.grass => 0,
      Gen4WildEncounter.surfing => 10,
      Gen4WildEncounter.oldRod => 20,
      Gen4WildEncounter.goodRod => 30,
      Gen4WildEncounter.superRod => 40,
      Gen4WildEncounter.rockSmash => 50,
      Gen4WildEncounter.headbutt => 60,
      Gen4WildEncounter.headbuttAlt => 61,
      Gen4WildEncounter.headbuttSpecial => 62,
      Gen4WildEncounter.honeyTree => 70,
      Gen4WildEncounter.bugCatchingContest => 80,
    };
  }
}

extension Gen4WildEncounterTimeSort on Gen4WildEncounterTime {
  String get labelKey {
    return switch (this) {
      Gen4WildEncounterTime.morning => 'gen4.target.time.morning',
      Gen4WildEncounterTime.day => 'gen4.target.time.day',
      Gen4WildEncounterTime.night => 'gen4.target.time.night',
    };
  }

  int get sortOrder {
    return switch (this) {
      Gen4WildEncounterTime.morning => 0,
      Gen4WildEncounterTime.day => 1,
      Gen4WildEncounterTime.night => 2,
    };
  }
}

extension Gen4StaticMethodSort on Gen4StaticMethod {
  String get labelKey {
    return switch (this) {
      Gen4StaticMethod.method1 => 'gen4.target.method.method1',
      Gen4StaticMethod.methodJ => 'gen4.target.method.methodJ',
      Gen4StaticMethod.methodK => 'gen4.target.method.methodK',
    };
  }

  int get sortOrder {
    return switch (this) {
      Gen4StaticMethod.method1 => 0,
      Gen4StaticMethod.methodJ => 1,
      Gen4StaticMethod.methodK => 2,
    };
  }
}

extension Gen4StaticShinyPolicySort on Gen4StaticShinyPolicy {
  String get labelKey {
    return switch (this) {
      Gen4StaticShinyPolicy.random => 'gen4.target.shiny.random',
      Gen4StaticShinyPolicy.always => 'gen4.target.shiny.always',
      Gen4StaticShinyPolicy.never => 'gen4.target.shiny.never',
    };
  }

  int get sortOrder {
    return switch (this) {
      Gen4StaticShinyPolicy.random => 0,
      Gen4StaticShinyPolicy.always => 1,
      Gen4StaticShinyPolicy.never => 2,
    };
  }
}

extension Gen4WildMethodLabel on Gen4WildMethod {
  String get labelKey {
    return switch (this) {
      Gen4WildMethod.methodJ => 'gen4.target.method.methodJ',
      Gen4WildMethod.methodK => 'gen4.target.method.methodK',
      Gen4WildMethod.honeyTree => 'gen4.target.method.honeyTree',
      Gen4WildMethod.pokeRadar => 'gen4.target.method.pokeRadar',
      Gen4WildMethod.pokeRadarShiny => 'gen4.target.method.pokeRadarShiny',
    };
  }
}

extension Gen4StaticEncounterTypeLabel on Gen4StaticEncounterType {
  String get labelKey {
    return switch (this) {
      Gen4StaticEncounterType.starter => 'gen4.target.static.starter',
      Gen4StaticEncounterType.fossil => 'gen4.target.static.fossil',
      Gen4StaticEncounterType.gift => 'gen4.target.static.gift',
      Gen4StaticEncounterType.gameCorner => 'gen4.target.static.gameCorner',
      Gen4StaticEncounterType.stationary => 'gen4.target.static.stationary',
      Gen4StaticEncounterType.legend => 'gen4.target.static.legend',
      Gen4StaticEncounterType.event => 'gen4.target.static.event',
      Gen4StaticEncounterType.roamer => 'gen4.target.static.roamer',
    };
  }
}

extension Gen4EncounterShinyPolicyLabel on Gen4EncounterShinyPolicy {
  String get labelKey {
    return switch (this) {
      Gen4EncounterShinyPolicy.random => 'gen4.target.shiny.random',
      Gen4EncounterShinyPolicy.always => 'gen4.target.shiny.always',
      Gen4EncounterShinyPolicy.never => 'gen4.target.shiny.never',
    };
  }
}

Gen4WildMethod _defaultWildMethod(
  Gen4WildEncounterArea area, {
  required String? modifier,
}) {
  if (area.encounter.isHoneyTree) {
    return Gen4WildMethod.honeyTree;
  }
  if (modifier == 'radar') {
    return Gen4WildMethod.pokeRadar;
  }
  return area.game.isDppt ? Gen4WildMethod.methodJ : Gen4WildMethod.methodK;
}

Gen4EncounterShinyPolicy _staticShinyPolicy(Gen4StaticShinyPolicy policy) {
  return switch (policy) {
    Gen4StaticShinyPolicy.random => Gen4EncounterShinyPolicy.random,
    Gen4StaticShinyPolicy.always => Gen4EncounterShinyPolicy.always,
    Gen4StaticShinyPolicy.never => Gen4EncounterShinyPolicy.never,
  };
}

int _wildModifierSortOrder(String? modifier) {
  return switch (modifier) {
    null => 0,
    'swarm' => 10,
    'day' => 20,
    'night' => 30,
    'radar' => 40,
    'ruby' => 50,
    'sapphire' => 51,
    'emerald' => 52,
    'fireRed' => 53,
    'leafGreen' => 54,
    'feebasTile' => 60,
    'hoennSound' => 70,
    'sinnohSound' => 71,
    'fishNight' => 80,
    'fishSwarm' => 81,
    'safariBlocks' => 90,
    _ => 900,
  };
}

String _wildModifierLabelKey(String modifier) {
  return switch (modifier) {
    'swarm' => 'gen4.target.modifier.swarm',
    'day' => 'gen4.target.modifier.day',
    'night' => 'gen4.target.modifier.night',
    'radar' => 'gen4.target.modifier.radar',
    'ruby' => 'gen4.target.modifier.ruby',
    'sapphire' => 'gen4.target.modifier.sapphire',
    'emerald' => 'gen4.target.modifier.emerald',
    'fireRed' => 'gen4.target.modifier.fireRed',
    'leafGreen' => 'gen4.target.modifier.leafGreen',
    'feebasTile' => 'gen4.target.modifier.feebasTile',
    'hoennSound' => 'gen4.target.modifier.hoennSound',
    'sinnohSound' => 'gen4.target.modifier.sinnohSound',
    'fishNight' => 'gen4.target.modifier.fishNight',
    'fishSwarm' => 'gen4.target.modifier.fishSwarm',
    'safariBlocks' => 'gen4.target.modifier.safariBlocks',
    _ => 'gen4.target.modifier.unknown',
  };
}

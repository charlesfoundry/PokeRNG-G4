import '../../core/gen4/static_generator.dart';
import 'gen4_game.dart';

enum Gen4StaticEncounterType {
  starter('starter'),
  fossil('fossil'),
  gift('gift'),
  gameCorner('gameCorner'),
  stationary('stationary'),
  legend('legend'),
  event('event'),
  roamer('roamer');

  const Gen4StaticEncounterType(this.jsonName);

  final String jsonName;

  static Gen4StaticEncounterType parse(String value) {
    return Gen4StaticEncounterType.values.firstWhere(
      (type) => type.jsonName == value,
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'unknown static type'),
    );
  }
}

extension Gen4StaticMethodJson on Gen4StaticMethod {
  String get jsonName {
    return switch (this) {
      Gen4StaticMethod.method1 => 'method1',
      Gen4StaticMethod.methodJ => 'methodJ',
      Gen4StaticMethod.methodK => 'methodK',
    };
  }

  static Gen4StaticMethod parse(String value) {
    return Gen4StaticMethod.values.firstWhere(
      (method) => method.jsonName == value,
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'unknown static method'),
    );
  }
}

extension Gen4StaticShinyPolicyJson on Gen4StaticShinyPolicy {
  String get jsonName {
    return switch (this) {
      Gen4StaticShinyPolicy.random => 'random',
      Gen4StaticShinyPolicy.always => 'always',
      Gen4StaticShinyPolicy.never => 'never',
    };
  }

  static Gen4StaticShinyPolicy parse(String value) {
    return Gen4StaticShinyPolicy.values.firstWhere(
      (policy) => policy.jsonName == value,
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'unknown shiny policy'),
    );
  }
}

class Gen4StaticEncounterTemplate {
  const Gen4StaticEncounterTemplate({
    required this.game,
    required this.type,
    required this.description,
    required this.species,
    required this.form,
    required this.level,
    required this.method,
    required this.shinyPolicy,
  });

  factory Gen4StaticEncounterTemplate.fromJson(Map<String, dynamic> json) {
    return Gen4StaticEncounterTemplate(
      game: gen4GameVersionFromJson(json['game'] as String),
      type: Gen4StaticEncounterType.parse(json['type'] as String),
      description: json['description'] as String,
      species: json['species'] as int,
      form: json['form'] as int,
      level: json['level'] as int,
      method: Gen4StaticMethodJson.parse(json['method'] as String),
      shinyPolicy: Gen4StaticShinyPolicyJson.parse(json['shiny'] as String),
    );
  }

  final Gen4GameVersion game;
  final Gen4StaticEncounterType type;
  final String description;
  final int species;
  final int form;
  final int level;
  final Gen4StaticMethod method;
  final Gen4StaticShinyPolicy shinyPolicy;
}

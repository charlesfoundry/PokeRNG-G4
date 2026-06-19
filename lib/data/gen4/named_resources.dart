import 'dart:convert';

import 'package:flutter/services.dart';

class Gen4NamedResources {
  const Gen4NamedResources._({
    required this.species,
    required this.englishSpecies,
    required this.abilities,
    required this.englishAbilities,
    required this.natures,
    required this.englishNatures,
  });

  final Map<int, String> species;
  final Map<int, String> englishSpecies;
  final Map<int, String> abilities;
  final Map<int, String> englishAbilities;
  final Map<int, String> natures;
  final Map<int, String> englishNatures;

  static Future<Gen4NamedResources> load(String localeName) async {
    return loadAssetLocale(gen4AssetLocale(localeName));
  }

  static Future<Gen4NamedResources> loadAssetLocale(String locale) async {
    final species = await _loadNames('species', locale);
    final abilities = await _loadNames('abilities', locale);
    final natures = await _loadNames('natures', locale);
    final englishSpecies = locale == 'en'
        ? species
        : await _loadNames('species', 'en');
    final englishAbilities = locale == 'en'
        ? abilities
        : await _loadNames('abilities', 'en');
    final englishNatures = locale == 'en'
        ? natures
        : await _loadNames('natures', 'en');
    return Gen4NamedResources._(
      species: Map.unmodifiable(species),
      englishSpecies: Map.unmodifiable(englishSpecies),
      abilities: Map.unmodifiable(abilities),
      englishAbilities: Map.unmodifiable(englishAbilities),
      natures: Map.unmodifiable(natures),
      englishNatures: Map.unmodifiable(englishNatures),
    );
  }

  String speciesName(int speciesId) {
    return species[speciesId] ?? englishSpecies[speciesId] ?? '#$speciesId';
  }

  String speciesSearchText(int speciesId) {
    return '${species[speciesId] ?? ''} ${englishSpecies[speciesId] ?? ''}'
        .toLowerCase();
  }

  String abilityName(int abilityId) {
    return abilities[abilityId] ?? englishAbilities[abilityId] ?? '#$abilityId';
  }

  String natureName(int natureId) {
    return natures[natureId] ?? englishNatures[natureId] ?? '#$natureId';
  }
}

Future<Map<int, String>> _loadNames(String kind, String locale) async {
  final raw = await rootBundle.loadString(
    'assets/i18n/gen4/${kind}_$locale.json',
  );
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final names = json[kind] as Map<String, dynamic>;
  return names.map((key, value) => MapEntry(int.parse(key), value as String));
}

String gen4AssetLocale(String localeName) {
  return switch (localeName) {
    'zh' || 'zh_CN' || 'zh_Hans' || 'zh_Hans_CN' => 'zh',
    'ja' || 'ja_JP' => 'ja',
    _ => 'en',
  };
}

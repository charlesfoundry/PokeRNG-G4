import 'dart:convert';

import 'package:flutter/services.dart';

import 'named_resources.dart';

enum Gen4LocationGroup {
  dppt('dppt'),
  hgss('hgss');

  const Gen4LocationGroup(this.key);

  final String key;
}

class Gen4LocationNames {
  const Gen4LocationNames._(
    this.locations,
    this.englishLocations,
    this._englishToLocalizedNames,
    this._staticLocationNames,
  );

  final Map<String, String> locations;
  final Map<String, String> englishLocations;
  final Map<String, String> _englishToLocalizedNames;
  final Map<String, String> _staticLocationNames;

  static Future<Gen4LocationNames> load(String localeName) async {
    return loadAssetLocale(gen4AssetLocale(localeName));
  }

  static Future<Gen4LocationNames> loadAssetLocale(String locale) async {
    final locations = await _loadLocations(locale);
    final englishLocations = locale == 'en'
        ? locations
        : await _loadLocations('en');
    return Gen4LocationNames._(
      Map.unmodifiable(locations),
      Map.unmodifiable(englishLocations),
      Map.unmodifiable(
        _buildEnglishToLocalizedNames(
          englishLocations: englishLocations,
          localizedLocations: locations,
        ),
      ),
      _staticLocationNamesFor(locale),
    );
  }

  String name({
    required Gen4LocationGroup group,
    required int locationId,
    String? fallback,
  }) {
    final key = '${group.key}:$locationId';
    return locations[key] ?? englishLocations[key] ?? fallback ?? key;
  }

  String staticLocationName(String englishName) {
    final trimmed = englishName.trim();
    if (trimmed.contains(' / ')) {
      return trimmed.split(' / ').map(staticLocationName).join(' / ');
    }
    return _staticLocationNames[trimmed] ??
        _englishToLocalizedNames[trimmed] ??
        _localizedBaseLocationName(trimmed) ??
        trimmed;
  }

  String? _localizedBaseLocationName(String englishName) {
    for (final entry in _englishToLocalizedNames.entries) {
      if (entry.key.startsWith('$englishName ')) {
        return _stripDetailSuffix(entry.value);
      }
    }
    return null;
  }
}

Future<Map<String, String>> _loadLocations(String locale) async {
  final raw = await rootBundle.loadString(
    'assets/i18n/gen4/locations_$locale.json',
  );
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final names = json['locations'] as Map<String, dynamic>;
  return names.map((key, value) => MapEntry(key, value as String));
}

Map<String, String> _buildEnglishToLocalizedNames({
  required Map<String, String> englishLocations,
  required Map<String, String> localizedLocations,
}) {
  final result = <String, String>{};
  for (final entry in englishLocations.entries) {
    final localized = localizedLocations[entry.key];
    if (localized != null) {
      result[entry.value] = localized;
      result[_stripDetailSuffix(entry.value)] = _stripDetailSuffix(localized);
    }
  }
  return result;
}

String _stripDetailSuffix(String value) {
  return value
      .replaceFirst(RegExp(r'\s?(?:[1-9]F|B[1-9]F|Basement|Exterior)$'), '')
      .replaceFirst(RegExp(r'\s?(?:\(.+\)|（.+）)$'), '');
}

Map<String, String> _staticLocationNamesFor(String locale) {
  return switch (locale) {
    'zh' => const {
      'Acuity Cavern': '睿智湖洞窟',
      'Celadon City Game Corner': '玉虹市游戏中心',
      'Cynthia': '竹兰',
      'Distortion World': '毁坏的世界',
      'Dragon': '龙穴',
      'Embedded Tower': '埋藏之塔',
      'Flower Paradise': '花之乐园',
      'Goldenrod City': '满金市',
      'Goldenrod City Game Corner': '满金市游戏中心',
      'Hearthome City': '家缘市',
      'Iceberg Ruins': '冰山遗迹',
      'Iron Ruins': '钢铁遗迹',
      'Mining Museum': '黑金炭坑博物馆',
      'Mr. Pokemon': '宝可梦爷爷',
      'Newmoon Island': '新月岛',
      'Pokemon Ranger': '宝可梦巡护员',
      'Primo': '阿金',
      'Riley': '亚玄',
      'Rock Peak Ruins': '岩山遗迹',
      'Seafoam Islands': '双子岛',
      'Saffron City': '金黄市',
      'Sinjoh Ruins': '神都遗迹',
      'Snowpoint Temple': '切锋神殿',
      'Spear Pillar': '枪之柱',
      'Team Rocket HQ': '火箭队基地',
      'Team Rocket HQ Trap Floor': '火箭队基地陷阱地板',
      'Traveling Man': '旅行者',
      'Turnback Cave': '归途洞窟',
      'Valor Cavern': '立志湖洞窟',
      'Veilstone City': '帷幕市',
      'Whirl Islands': '漩涡岛',
    },
    'ja' => const {
      'Acuity Cavern': 'エイチこのくうどう',
      'Celadon City Game Corner': 'タマムシゲームコーナー',
      'Cynthia': 'シロナ',
      'Distortion World': 'やぶれたせかい',
      'Dragon': 'りゅうのあな',
      'Embedded Tower': 'うずもれのとう',
      'Flower Paradise': 'はなのらくえん',
      'Goldenrod City': 'コガネシティ',
      'Goldenrod City Game Corner': 'コガネゲームコーナー',
      'Hearthome City': 'ヨスガシティ',
      'Iceberg Ruins': 'ひょうざんのいせき',
      'Iron Ruins': 'くろがねのいせき',
      'Mining Museum': 'クロガネたんこうはくぶつかん',
      'Mr. Pokemon': 'ポケモンじいさん',
      'Newmoon Island': 'しんげつじま',
      'Pokemon Ranger': 'ポケモンレンジャー',
      'Primo': 'ハジメ',
      'Riley': 'ゲン',
      'Rock Peak Ruins': 'いわやまのいせき',
      'Seafoam Islands': 'ふたごじま',
      'Saffron City': 'ヤマブキシティ',
      'Sinjoh Ruins': 'シントいせき',
      'Snowpoint Temple': 'キッサキしんでん',
      'Spear Pillar': 'やりのはしら',
      'Team Rocket HQ': 'ロケットだんアジト',
      'Team Rocket HQ Trap Floor': 'ロケットだんアジト トラップフロア',
      'Traveling Man': 'たびのひと',
      'Turnback Cave': 'もどりのどうくつ',
      'Valor Cavern': 'リッシこのくうどう',
      'Veilstone City': 'トバリシティ',
      'Whirl Islands': 'うずまきじま',
    },
    _ => const {},
  };
}

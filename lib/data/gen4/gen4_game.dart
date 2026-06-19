import 'location_names.dart';

enum Gen4GameVersion {
  diamond('diamond', Gen4LocationGroup.dppt),
  pearl('pearl', Gen4LocationGroup.dppt),
  platinum('platinum', Gen4LocationGroup.dppt),
  heartGold('heartGold', Gen4LocationGroup.hgss),
  soulSilver('soulSilver', Gen4LocationGroup.hgss);

  const Gen4GameVersion(this.jsonName, this.locationGroup);

  final String jsonName;
  final Gen4LocationGroup locationGroup;

  bool get isDppt => locationGroup == Gen4LocationGroup.dppt;

  bool get isHgss => locationGroup == Gen4LocationGroup.hgss;
}

Gen4GameVersion gen4GameVersionFromJson(String value) {
  return Gen4GameVersion.values.firstWhere(
    (game) => game.jsonName == value,
    orElse: () => throw ArgumentError.value(value, 'value', 'unknown game'),
  );
}

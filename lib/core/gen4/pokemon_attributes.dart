enum Nature {
  hardy,
  lonely,
  brave,
  adamant,
  naughty,
  bold,
  docile,
  relaxed,
  impish,
  lax,
  timid,
  hasty,
  serious,
  jolly,
  naive,
  modest,
  mild,
  quiet,
  bashful,
  rash,
  calm,
  gentle,
  sassy,
  careful,
  quirky;

  int get raisedStatIndex => index ~/ 5;

  int get loweredStatIndex => index % 5;

  bool get isNeutral => raisedStatIndex == loweredStatIndex;

  bool raisesStatIndex(int statIndex) {
    _validateNatureStatIndex(statIndex);
    return !isNeutral && raisedStatIndex == statIndex;
  }

  bool lowersStatIndex(int statIndex) {
    _validateNatureStatIndex(statIndex);
    return !isNeutral && loweredStatIndex == statIndex;
  }

  int modifierPercentForStatIndex(int statIndex) {
    _validateNatureStatIndex(statIndex);
    if (raisesStatIndex(statIndex)) {
      return 110;
    }
    if (lowersStatIndex(statIndex)) {
      return 90;
    }
    return 100;
  }
}

enum PokemonGender { male, female, genderless }

class PokemonAbilitySlot {
  const PokemonAbilitySlot._();

  static const int first = 0;
  static const int second = 1;

  static int fromPersonalityValue(int personalityValue) {
    _validateU32(personalityValue, 'personalityValue');
    return personalityValue & 1;
  }

  static void validate(int abilitySlot, {String name = 'abilitySlot'}) {
    if (abilitySlot != first && abilitySlot != second) {
      throw ArgumentError.value(abilitySlot, name, 'must be 0 or 1');
    }
  }

  static void validateOptional(
    int? abilitySlot, {
    String name = 'abilitySlot',
  }) {
    if (abilitySlot != null) {
      validate(abilitySlot, name: name);
    }
  }
}

class PokemonGenderRatio {
  const PokemonGenderRatio._();

  static const int maleOnly = 0;
  static const int femaleOnly = 254;
  static const int genderless = 255;

  static void validate(int genderRatio) {
    _validateGenderRatio(genderRatio);
  }

  static bool isMaleOnly(int genderRatio) {
    validate(genderRatio);
    return genderRatio == maleOnly;
  }

  static bool isFemaleOnly(int genderRatio) {
    validate(genderRatio);
    return genderRatio == femaleOnly;
  }

  static bool isGenderless(int genderRatio) {
    validate(genderRatio);
    return genderRatio == genderless;
  }

  static bool isFixed(int genderRatio) {
    validate(genderRatio);
    return genderRatio == maleOnly ||
        genderRatio == femaleOnly ||
        genderRatio == genderless;
  }

  static bool isVariable(int genderRatio) {
    validate(genderRatio);
    return !isFixed(genderRatio);
  }

  static PokemonGender? fixedGender(int genderRatio) {
    validate(genderRatio);
    return switch (genderRatio) {
      genderless => PokemonGender.genderless,
      femaleOnly => PokemonGender.female,
      maleOnly => PokemonGender.male,
      _ => null,
    };
  }

  static PokemonGender genderForValue({
    required int genderValue,
    required int genderRatio,
  }) {
    validate(genderRatio);
    if (genderValue < 0 || genderValue > 0xff) {
      throw ArgumentError.value(
        genderValue,
        'genderValue',
        'must be in 0..255',
      );
    }
    return switch (genderRatio) {
      genderless => PokemonGender.genderless,
      femaleOnly => PokemonGender.female,
      maleOnly => PokemonGender.male,
      _ =>
        genderValue < genderRatio ? PokemonGender.female : PokemonGender.male,
    };
  }

  static int cuteCharmFemaleBuffer(int genderRatio) {
    validate(genderRatio);
    return 25 * ((genderRatio ~/ 25) + 1);
  }
}

enum Shiny {
  notShiny,
  star;

  bool get isShiny => this != Shiny.notShiny;
}

class PokemonTrainerIds {
  const PokemonTrainerIds._();

  static int fullShinyValue({required int tid, required int sid}) {
    _validateU16(tid, 'tid');
    _validateU16(sid, 'sid');
    return tid ^ sid;
  }

  static int trainerShinyValue({required int tid, required int sid}) {
    return fullShinyValue(tid: tid, sid: sid) >>> 3;
  }
}

enum Gen4HiddenPowerType {
  fighting,
  flying,
  poison,
  ground,
  rock,
  bug,
  ghost,
  steel,
  fire,
  water,
  grass,
  electric,
  psychic,
  ice,
  dragon,
  dark;

  static Gen4HiddenPowerType fromIndex(int index) {
    if (index < 0 || index >= Gen4HiddenPowerType.values.length) {
      throw ArgumentError.value(index, 'hiddenPowerType', 'must be in 0..15');
    }
    return Gen4HiddenPowerType.values[index];
  }
}

class PokemonStats {
  const PokemonStats({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
  });

  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;

  List<int> get ordered => [
    hp,
    attack,
    defense,
    specialAttack,
    specialDefense,
    speed,
  ];

  @override
  String toString() {
    return '$hp/$attack/$defense/$specialAttack/$specialDefense/$speed';
  }
}

class PokemonEffortValues {
  const PokemonEffortValues({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
  });

  static const zero = PokemonEffortValues(
    hp: 0,
    attack: 0,
    defense: 0,
    specialAttack: 0,
    specialDefense: 0,
    speed: 0,
  );

  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;

  List<int> get ordered => [
    hp,
    attack,
    defense,
    specialAttack,
    specialDefense,
    speed,
  ];

  int get total =>
      hp + attack + defense + specialAttack + specialDefense + speed;

  @override
  String toString() {
    return '$hp/$attack/$defense/$specialAttack/$specialDefense/$speed';
  }
}

class Ivs {
  const Ivs({
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
  });

  factory Ivs.fromWords(int word1, int word2) {
    return Ivs(
      hp: word1 & 0x1f,
      attack: (word1 >>> 5) & 0x1f,
      defense: (word1 >>> 10) & 0x1f,
      speed: word2 & 0x1f,
      specialAttack: (word2 >>> 5) & 0x1f,
      specialDefense: (word2 >>> 10) & 0x1f,
    );
  }

  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;

  List<int> get ordered => [
    hp,
    attack,
    defense,
    specialAttack,
    specialDefense,
    speed,
  ];

  int get total =>
      hp + attack + defense + specialAttack + specialDefense + speed;

  int get word1 {
    _validateIvs(this);
    return hp | (attack << 5) | (defense << 10);
  }

  int get word2 {
    _validateIvs(this);
    return speed | (specialAttack << 5) | (specialDefense << 10);
  }

  List<int> get words => [word1, word2];

  int get hiddenPowerType {
    _validateIvs(this);
    const order = [0, 1, 2, 5, 3, 4];
    final ivs = ordered;
    var value = 0;
    for (var i = 0; i < order.length; i++) {
      value |= (ivs[order[i]] & 1) << i;
    }
    return value * 15 ~/ 63;
  }

  Gen4HiddenPowerType get hiddenPower =>
      Gen4HiddenPowerType.fromIndex(hiddenPowerType);

  int get hiddenPowerStrength {
    _validateIvs(this);
    const order = [0, 1, 2, 5, 3, 4];
    final ivs = ordered;
    var value = 0;
    for (var i = 0; i < order.length; i++) {
      value |= ((ivs[order[i]] >>> 1) & 1) << i;
    }
    return 30 + (value * 40 ~/ 63);
  }

  int characteristic({required int personalityValue}) {
    _validateIvs(this);
    _validateU32(personalityValue, 'personalityValue');
    const order = [0, 1, 2, 5, 3, 4];
    const characteristicOrder = [0, 1, 2, 3, 4, 5, 0, 1, 2, 3, 4];
    final ivs = ordered;
    final ecIndex = personalityValue % 6;
    var characteristicIndex = ecIndex;
    var maxIv = 0;

    for (var i = 0; i < 6; i++) {
      final index = characteristicOrder[ecIndex + i];
      final iv = ivs[order[index]];
      if (iv > maxIv) {
        characteristicIndex = index;
        maxIv = iv;
      }
    }

    return (characteristicIndex * 5) + (maxIv % 5);
  }

  @override
  String toString() {
    return '$hp/$attack/$defense/$specialAttack/$specialDefense/$speed';
  }
}

class PokemonPid {
  const PokemonPid(this.value);

  final int value;

  int get low {
    _validateU32(value, 'pid');
    return value & 0xffff;
  }

  int get high {
    _validateU32(value, 'pid');
    return value >>> 16;
  }

  String get hex {
    _validateU32(value, 'pid');
    return value.toRadixString(16).padLeft(8, '0').toUpperCase();
  }

  Nature get nature {
    _validateU32(value, 'pid');
    return Nature.values[value % Nature.values.length];
  }

  int get abilitySlot {
    return PokemonAbilitySlot.fromPersonalityValue(value);
  }

  int get genderValue {
    _validateU32(value, 'pid');
    return value & 0xff;
  }

  int get fullPersonalityShinyValue {
    _validateU32(value, 'pid');
    return low ^ high;
  }

  int get personalityShinyValue => fullPersonalityShinyValue >>> 3;

  PokemonGender gender({required int genderRatio}) {
    _validateU32(value, 'pid');
    return PokemonGenderRatio.genderForValue(
      genderValue: genderValue,
      genderRatio: genderRatio,
    );
  }

  bool isShiny({required int tid, required int sid}) {
    return shinyValue(tid: tid, sid: sid) < 8;
  }

  int shinyValue({required int tid, required int sid}) {
    _validateU32(value, 'pid');
    return PokemonTrainerIds.fullShinyValue(tid: tid, sid: sid) ^
        fullPersonalityShinyValue;
  }

  Shiny shiny({required int tid, required int sid}) {
    return isShiny(tid: tid, sid: sid) ? Shiny.star : Shiny.notShiny;
  }

  @override
  String toString() {
    return hex;
  }
}

class Gen4HiddenPowerFilter {
  const Gen4HiddenPowerFilter({this.type, this.minStrength, this.maxStrength});

  final int? type;
  final int? minStrength;
  final int? maxStrength;

  void validate() {
    if (type != null && (type! < 0 || type! > 15)) {
      throw ArgumentError.value(type, 'hiddenPowerType', 'must be in 0..15');
    }
    if (minStrength != null && (minStrength! < 30 || minStrength! > 70)) {
      throw ArgumentError.value(
        minStrength,
        'minHiddenPowerStrength',
        'must be in 30..70',
      );
    }
    if (maxStrength != null && (maxStrength! < 30 || maxStrength! > 70)) {
      throw ArgumentError.value(
        maxStrength,
        'maxHiddenPowerStrength',
        'must be in 30..70',
      );
    }
    if (minStrength != null &&
        maxStrength != null &&
        minStrength! > maxStrength!) {
      throw ArgumentError(
        'minHiddenPowerStrength must be <= maxHiddenPowerStrength',
      );
    }
  }

  bool matches({required int hiddenPowerType, required int strength}) {
    validate();
    if (type != null && hiddenPowerType != type) {
      return false;
    }
    if (minStrength != null && strength < minStrength!) {
      return false;
    }
    if (maxStrength != null && strength > maxStrength!) {
      return false;
    }
    return true;
  }
}

class Gen4PokemonSearchFilter {
  const Gen4PokemonSearchFilter({
    this.abilitySlot,
    this.gender,
    this.shiny,
    this.hiddenPower = const Gen4HiddenPowerFilter(),
  });

  final int? abilitySlot;
  final PokemonGender? gender;
  final Shiny? shiny;
  final Gen4HiddenPowerFilter hiddenPower;

  void validate() {
    PokemonAbilitySlot.validateOptional(abilitySlot);
    hiddenPower.validate();
  }

  bool matches({
    required int abilitySlot,
    required PokemonGender gender,
    required Shiny shiny,
    required int hiddenPowerType,
    required int hiddenPowerStrength,
  }) {
    validate();
    PokemonAbilitySlot.validate(abilitySlot);
    if (this.abilitySlot != null && abilitySlot != this.abilitySlot) {
      return false;
    }
    if (this.gender != null && gender != this.gender) {
      return false;
    }
    if (this.shiny != null && shiny != this.shiny) {
      return false;
    }
    return hiddenPower.matches(
      hiddenPowerType: hiddenPowerType,
      strength: hiddenPowerStrength,
    );
  }
}

void _validateIvs(Ivs ivs) {
  final values = ivs.ordered;
  const names = [
    'hp',
    'attack',
    'defense',
    'specialAttack',
    'specialDefense',
    'speed',
  ];
  for (var index = 0; index < values.length; index++) {
    final value = values[index];
    if (value < 0 || value > 31) {
      throw ArgumentError.value(value, 'ivs.${names[index]}', 'must be 0..31');
    }
  }
}

void _validateU16(int value, String name) {
  if (value < 0 || value > 0xffff) {
    throw ArgumentError.value(value, name, 'must be in 0..65535');
  }
}

void _validateU32(int value, String name) {
  if (value < 0 || value > 0xffffffff) {
    throw ArgumentError.value(value, name, 'must be in 0..0xffffffff');
  }
}

void _validateGenderRatio(int genderRatio) {
  if (genderRatio < 0 || genderRatio > 255) {
    throw ArgumentError.value(genderRatio, 'genderRatio', 'must be in 0..255');
  }
}

void _validateNatureStatIndex(int statIndex) {
  if (statIndex < 0 || statIndex > 4) {
    throw ArgumentError.value(statIndex, 'statIndex', 'must be in 0..4');
  }
}

import 'lcrng.dart';
import 'lcrng_reverse.dart';
import 'pokemon_attributes.dart';

class Gen4ChainedSidCalculator {
  Gen4ChainedSidCalculator({required this.tid})
    : _sids = List<int>.generate(0x2000, (index) => index * 8) {
    _validateTid(tid);
  }

  final int tid;
  List<int> _sids;

  List<int> get sids => List<int>.unmodifiable(_sids);

  void addEntry({
    required Ivs ivs,
    required int observedAbility,
    required PokemonGender observedGender,
    required Nature nature,
    required int ability0,
    required int ability1,
    required int genderRatio,
  }) {
    _validateEntry(
      ivs: ivs,
      observedAbility: observedAbility,
      ability0: ability0,
      ability1: ability1,
      genderRatio: genderRatio,
    );

    final pids = <_ChainedPidParts>[];
    final ivSeeds = LcrngReverse.recoverPokeRngIvs(
      hp: ivs.hp,
      attack: ivs.attack,
      defense: ivs.defense,
      specialAttack: ivs.specialAttack,
      specialDefense: ivs.specialDefense,
      speed: ivs.speed,
    );

    for (final ivSeed in ivSeeds) {
      var rng = Lcrng.pokeRngReverse(ivSeed);
      var adjust = 0;
      for (var bit = 15; bit >= 3; bit--) {
        final result = rng.nextU16();
        rng = Lcrng.pokeRngReverse(result.seed);
        adjust |= (result.value & 1) << bit;
      }

      final pid2 = rng.nextU16();
      rng = Lcrng.pokeRngReverse(pid2.seed);
      final pid1 = rng.nextU16();

      final low = adjust | (pid1.value & 7);
      final ability = (low & 1) == 0 ? ability0 : ability1;
      final gender = _genderForLowPid(low, genderRatio: genderRatio);
      if (ability == observedAbility && gender == observedGender) {
        pids.add(_ChainedPidParts(low: low, highLowBits: pid2.value & 7));
      }
    }

    final newSids = <int>{};
    for (final sid in _sids) {
      for (final pid in pids) {
        final high = (((pid.low ^ tid ^ sid) & 0xfff8) | pid.highLowBits);
        final fullPid = (high << 16) | pid.low;
        if (fullPid % Nature.values.length == nature.index) {
          newSids.add(sid);
        }
      }
    }
    _sids = newSids.toList()..sort();
  }

  PokemonGender _genderForLowPid(int low, {required int genderRatio}) {
    return PokemonGenderRatio.genderForValue(
      genderValue: low & 0xff,
      genderRatio: genderRatio,
    );
  }
}

void _validateTid(int tid) {
  if (tid < 0 || tid > 0xffff) {
    throw ArgumentError.value(tid, 'tid', 'must be in 0..65535');
  }
}

void _validateEntry({
  required Ivs ivs,
  required int observedAbility,
  required int ability0,
  required int ability1,
  required int genderRatio,
}) {
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
      throw ArgumentError.value(value, names[index], 'must be in 0..31');
    }
  }

  if (ability0 < 0) {
    throw ArgumentError.value(ability0, 'ability0', 'must be non-negative');
  }
  if (ability1 < 0) {
    throw ArgumentError.value(ability1, 'ability1', 'must be non-negative');
  }
  if (observedAbility < 0) {
    throw ArgumentError.value(
      observedAbility,
      'observedAbility',
      'must be non-negative',
    );
  }
  if (observedAbility != ability0 && observedAbility != ability1) {
    throw ArgumentError.value(
      observedAbility,
      'observedAbility',
      'must match ability0 or ability1',
    );
  }
  PokemonGenderRatio.validate(genderRatio);
}

class _ChainedPidParts {
  const _ChainedPidParts({required this.low, required this.highLowBits});

  final int low;
  final int highLowBits;
}

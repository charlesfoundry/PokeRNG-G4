import 'lcrng.dart';
import 'pokemon_attributes.dart';
import 'seed_verification.dart';

class Gen4EventGenerator {
  const Gen4EventGenerator({
    required this.initialAdvances,
    required this.maxAdvances,
    required this.offset,
    required this.level,
    required this.nature,
    required this.genderRatio,
  });

  final int initialAdvances;
  final int maxAdvances;
  final int offset;
  final int level;
  final Nature nature;
  final int genderRatio;

  List<Gen4EventState> generate(int seed) {
    _validateConfiguration();

    final states = <Gen4EventState>[];
    var rng = Lcrng.pokeRng(seed).advance(initialAdvances);

    for (var cnt = 0; cnt <= maxAdvances; cnt++) {
      var go = rng.advance(offset);

      final iv1 = go.nextU16();
      go = Lcrng.pokeRng(iv1.seed);
      final iv2 = go.nextU16();

      final prng = rng.nextU16();
      final pid = const PokemonPid(0);
      states.add(
        Gen4EventState(
          prng: prng.value,
          prngSeed: prng.seed,
          advance: initialAdvances + cnt,
          pid: pid,
          ivs: Ivs.fromWords(iv1.value, iv2.value),
          abilitySlot: 0,
          gender: pid.gender(genderRatio: genderRatio),
          level: level,
          nature: nature,
          shiny: Shiny.notShiny,
        ),
      );
      rng = Lcrng.pokeRng(prng.seed);
    }

    return states;
  }

  void _validateConfiguration() {
    if (initialAdvances < 0 || maxAdvances < 0 || offset < 0) {
      throw ArgumentError('advance values must be non-negative');
    }
    if (level < 1 || level > 100) {
      throw ArgumentError.value(level, 'level', 'must be in 1..100');
    }
    PokemonGenderRatio.validate(genderRatio);
  }
}

class Gen4EventState {
  const Gen4EventState({
    required this.prng,
    required this.prngSeed,
    required this.advance,
    required this.pid,
    required this.ivs,
    required this.abilitySlot,
    required this.gender,
    required this.level,
    required this.nature,
    required this.shiny,
  });

  final int prng;
  final int prngSeed;
  final int advance;
  final PokemonPid pid;
  final Ivs ivs;
  final int abilitySlot;
  final PokemonGender gender;
  final int level;
  final Nature nature;
  final Shiny shiny;

  int get call => Gen4SeedVerification.callValue(prng);
  int get chatot => Gen4SeedVerification.chatotPitch(prng);
  int get frame => advance;
  int get hiddenPowerType => ivs.hiddenPowerType;
  Gen4HiddenPowerType get hiddenPower => ivs.hiddenPower;
  int get hiddenPowerStrength => ivs.hiddenPowerStrength;
  int get characteristic => ivs.characteristic(personalityValue: pid.value);
}

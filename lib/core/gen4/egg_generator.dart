import 'lcrng.dart';
import 'mt.dart';
import 'pokemon_attributes.dart';
import 'seed_verification.dart';

enum Gen4EggGame { diamondPearlPlatinum, heartGoldSoulSilver }

class Gen4EggGenerator {
  const Gen4EggGenerator({
    required this.initialAdvances,
    required this.maxAdvances,
    required this.offset,
    required this.initialPickupAdvances,
    required this.maxPickupAdvances,
    required this.pickupOffset,
    required this.daycare,
    required this.game,
    required this.tid,
    required this.sid,
  });

  final int initialAdvances;
  final int maxAdvances;
  final int offset;
  final int initialPickupAdvances;
  final int maxPickupAdvances;
  final int pickupOffset;
  final Gen4Daycare daycare;
  final Gen4EggGame game;
  final int tid;
  final int sid;

  int get tsv => tid ^ sid;

  void validateConfiguration() {
    _validateConfiguration();
  }

  List<Gen4EggState> generate({
    required int heldSeed,
    required int pickupSeed,
  }) {
    _validateConfiguration();
    _validateSeed(heldSeed, 'heldSeed');
    _validateSeed(pickupSeed, 'pickupSeed');
    final held = _generateHeld(heldSeed);
    final states = _generatePickup(pickupSeed, held);
    states.sort((left, right) {
      final advanceCompare = left.advance.compareTo(right.advance);
      if (advanceCompare != 0) {
        return advanceCompare;
      }
      return left.pickupAdvance.compareTo(right.pickupAdvance);
    });
    return states;
  }

  List<Gen4EggHeldState> generateHeld(int seed) {
    _validateConfiguration();
    _validateSeed(seed, 'seed');
    return _generateHeld(seed);
  }

  List<Gen4EggHeldState> _generateHeld(int seed) {
    final mt = Mt(seed, initialAdvances + offset);
    final states = <Gen4EggHeldState>[];

    for (var cnt = 0; cnt <= maxAdvances; cnt++) {
      var pid = mt.next();
      if (daycare.masuda) {
        var rng = Lcrng.arng(pid);
        for (var i = 0; i < 4; i++) {
          if (PokemonPid(pid).isShiny(tid: tid, sid: sid)) {
            break;
          }
          final next = rng.next();
          pid = next.value;
          rng = Lcrng.arng(next.value);
        }
      }

      final pokemonPid = PokemonPid(pid);
      states.add(
        Gen4EggHeldState(
          advance: initialAdvances + cnt,
          pid: pokemonPid,
          abilitySlot: pokemonPid.abilitySlot,
          gender: pokemonPid.gender(genderRatio: daycare.eggGenderRatio),
          nature: pokemonPid.nature,
          shiny: pokemonPid.shiny(tid: tid, sid: sid),
        ),
      );
    }

    return states;
  }

  List<Gen4EggState> generatePickup(
    int seed,
    List<Gen4EggHeldState> heldStates,
  ) {
    _validateConfiguration();
    _validateSeed(seed, 'seed');
    return _generatePickup(seed, heldStates);
  }

  List<Gen4EggState> _generatePickup(
    int seed,
    List<Gen4EggHeldState> heldStates,
  ) {
    final states = <Gen4EggState>[];
    var rng = Lcrng.pokeRng(seed).advance(initialPickupAdvances);

    for (var cnt = 0; cnt <= maxPickupAdvances; cnt++) {
      var go = rng.advance(pickupOffset);

      final iv1 = go.nextU16();
      go = Lcrng.pokeRng(iv1.seed);
      final iv2 = go.nextU16();
      go = Lcrng.pokeRng(iv2.seed);

      final randomIvs = Ivs.fromWords(iv1.value, iv2.value).ordered;

      final inheritedStats = <int>[0, 0, 0];
      var inheritedStat = go.nextU16Bounded(6);
      inheritedStats[0] = inheritedStat.value;
      go = Lcrng.pokeRng(inheritedStat.seed);

      inheritedStat = go.nextU16Bounded(5);
      inheritedStats[1] = inheritedStat.value;
      go = Lcrng.pokeRng(inheritedStat.seed);

      inheritedStat = go.nextU16Bounded(4);
      inheritedStats[2] = inheritedStat.value;
      go = Lcrng.pokeRng(inheritedStat.seed);

      final inheritedParents = <int>[0, 0, 0];
      var inheritedParent = go.nextU16Bounded(2);
      inheritedParents[0] = inheritedParent.value;
      go = Lcrng.pokeRng(inheritedParent.seed);

      inheritedParent = go.nextU16Bounded(2);
      inheritedParents[1] = inheritedParent.value;
      go = Lcrng.pokeRng(inheritedParent.seed);

      inheritedParent = go.nextU16Bounded(2);
      inheritedParents[2] = inheritedParent.value;

      final inheritance = List<int>.filled(6, 0);
      final ivs = List<int>.of(randomIvs);
      _setInheritance(
        ivs: ivs,
        inheritance: inheritance,
        inheritedStats: inheritedStats,
        inheritedParents: inheritedParents,
      );

      final prng = rng.nextU16();
      for (final held in heldStates) {
        states.add(
          Gen4EggState(
            prng: prng.value,
            prngSeed: prng.seed,
            advance: held.advance,
            pickupAdvance: initialPickupAdvances + cnt,
            pid: held.pid,
            ivs: Ivs(
              hp: ivs[0],
              attack: ivs[1],
              defense: ivs[2],
              specialAttack: ivs[3],
              specialDefense: ivs[4],
              speed: ivs[5],
            ),
            inheritance: inheritance,
            abilitySlot: held.abilitySlot,
            gender: held.gender,
            nature: held.nature,
            shiny: held.shiny,
          ),
        );
      }

      rng = Lcrng.pokeRng(prng.seed);
    }

    return states;
  }

  void _setInheritance({
    required List<int> ivs,
    required List<int> inheritance,
    required List<int> inheritedStats,
    required List<int> inheritedParents,
  }) {
    if (game == Gen4EggGame.diamondPearlPlatinum) {
      const available1 = [0, 1, 2, 5, 3, 4];
      const available2 = [1, 2, 5, 3, 4];
      const available3 = [1, 5, 3, 4];

      final stats = [
        available1[inheritedStats[0]],
        available2[inheritedStats[1]],
        available3[inheritedStats[2]],
      ];

      for (var i = 0; i < stats.length; i++) {
        final stat = stats[i];
        final parent = inheritedParents[i];
        ivs[stat] = daycare.parentIvs[parent][stat];
        inheritance[stat] = parent + 1;
      }
      return;
    }

    const order = [0, 1, 2, 5, 3, 4];
    final available = [0, 1, 2, 3, 4, 5];

    for (var i = 0; i < 3; i++) {
      final statIndex = available[inheritedStats[i]];
      final stat = order[statIndex];
      final parent = inheritedParents[i];
      ivs[stat] = daycare.parentIvs[parent][stat];
      inheritance[stat] = parent + 1;
      available.removeAt(inheritedStats[i]);
    }
  }

  void _validateConfiguration() {
    if (initialAdvances < 0 ||
        maxAdvances < 0 ||
        offset < 0 ||
        initialPickupAdvances < 0 ||
        maxPickupAdvances < 0 ||
        pickupOffset < 0) {
      throw ArgumentError('advance values must be non-negative');
    }
    if (daycare.parentIvs.length != 2) {
      throw ArgumentError.value(
        daycare.parentIvs.length,
        'daycare.parentIvs.length',
        'must contain two parents',
      );
    }
    for (var parent = 0; parent < daycare.parentIvs.length; parent++) {
      final ivs = daycare.parentIvs[parent];
      if (ivs.length != 6) {
        throw ArgumentError.value(
          ivs.length,
          'daycare.parentIvs[$parent].length',
          'must contain six IVs',
        );
      }
      for (var stat = 0; stat < ivs.length; stat++) {
        final iv = ivs[stat];
        if (iv < 0 || iv > 31) {
          throw ArgumentError.value(
            iv,
            'daycare.parentIvs[$parent][$stat]',
            'must be in 0..31',
          );
        }
      }
    }
    if (daycare.eggGenderRatio < 0 || daycare.eggGenderRatio > 255) {
      throw ArgumentError.value(
        daycare.eggGenderRatio,
        'daycare.eggGenderRatio',
        'must be in 0..255',
      );
    }
    _validateU16(tid, 'tid');
    _validateU16(sid, 'sid');
  }
}

void _validateSeed(int seed, String name) {
  if (seed < 0 || seed > u32Mask) {
    throw ArgumentError.value(seed, name, 'must be in 0..0xffffffff');
  }
}

void _validateU16(int value, String name) {
  if (value < 0 || value > 0xffff) {
    throw ArgumentError.value(value, name, 'must be in 0..65535');
  }
}

class Gen4Daycare {
  const Gen4Daycare({
    required this.parentIvs,
    required this.eggGenderRatio,
    this.masuda = false,
  });

  final List<List<int>> parentIvs;
  final int eggGenderRatio;
  final bool masuda;
}

class Gen4EggHeldState {
  const Gen4EggHeldState({
    required this.advance,
    required this.pid,
    required this.abilitySlot,
    required this.gender,
    required this.nature,
    required this.shiny,
  });

  final int advance;
  final PokemonPid pid;
  final int abilitySlot;
  final PokemonGender gender;
  final Nature nature;
  final Shiny shiny;

  int get frame => advance;
}

class Gen4EggState {
  const Gen4EggState({
    required this.prng,
    required this.prngSeed,
    required this.advance,
    required this.pickupAdvance,
    required this.pid,
    required this.ivs,
    required this.inheritance,
    required this.abilitySlot,
    required this.gender,
    required this.nature,
    required this.shiny,
  });

  final int prng;
  final int prngSeed;
  final int advance;
  final int pickupAdvance;
  final PokemonPid pid;
  final Ivs ivs;
  final List<int> inheritance;
  final int abilitySlot;
  final PokemonGender gender;
  final Nature nature;
  final Shiny shiny;

  int get call => Gen4SeedVerification.callValue(prng);
  int get chatot => Gen4SeedVerification.chatotPitch(prng);
  int get frame => advance;
  int get pickupFrame => pickupAdvance;
  int get hiddenPowerType => ivs.hiddenPowerType;
  Gen4HiddenPowerType get hiddenPower => ivs.hiddenPower;
  int get hiddenPowerStrength => ivs.hiddenPowerStrength;
  int get characteristic => ivs.characteristic(personalityValue: pid.value);
}

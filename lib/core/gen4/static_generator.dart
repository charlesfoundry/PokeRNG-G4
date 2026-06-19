import 'lcrng.dart';
import 'pokemon_attributes.dart';
import 'seed_verification.dart';

enum Gen4StaticMethod { method1, methodJ, methodK }

enum Gen4CuteCharmLead { none, male, female }

enum Gen4StaticShinyPolicy { random, always, never }

class Gen4StaticGenerator {
  const Gen4StaticGenerator({
    required this.initialAdvances,
    required this.maxAdvances,
    required this.offset,
    required this.method,
    required this.level,
    required this.tid,
    required this.sid,
    required this.genderRatio,
    this.fixedGender = false,
    this.synchronizeNature,
    this.cuteCharmLead = Gen4CuteCharmLead.none,
    this.shinyPolicy = Gen4StaticShinyPolicy.random,
  });

  final int initialAdvances;
  final int maxAdvances;
  final int offset;
  final Gen4StaticMethod method;
  final int level;
  final int tid;
  final int sid;
  final int genderRatio;
  final bool fixedGender;
  final Nature? synchronizeNature;
  final Gen4CuteCharmLead cuteCharmLead;
  final Gen4StaticShinyPolicy shinyPolicy;

  int get tsv => tid ^ sid;

  List<Gen4StaticState> generate(int seed) {
    _validateConfiguration();
    return switch (method) {
      Gen4StaticMethod.method1 => _generateMethod1(seed),
      Gen4StaticMethod.methodJ => _generateMethodJk(seed, methodJ: true),
      Gen4StaticMethod.methodK => _generateMethodJk(seed, methodJ: false),
    };
  }

  List<Gen4StaticState> _generateMethod1(int seed) {
    final states = <Gen4StaticState>[];
    var rng = Lcrng.pokeRng(seed).advance(initialAdvances);

    for (var cnt = 0; cnt <= maxAdvances; cnt++) {
      var go = rng.advance(offset);

      final pidResult = _createMethod1Pid(go);
      final pid = pidResult.pid;
      go = pidResult.rng;

      final iv1 = go.nextU16();
      go = Lcrng.pokeRng(iv1.seed);
      final iv2 = go.nextU16();

      states.add(
        _buildState(
          rng: rng,
          cnt: cnt,
          pid: pid,
          iv1: iv1.value,
          iv2: iv2.value,
        ),
      );
      rng = Lcrng.pokeRng(states.last.prngSeed);
    }

    return states;
  }

  List<Gen4StaticState> _generateMethodJk(int seed, {required bool methodJ}) {
    final states = <Gen4StaticState>[];
    var rng = Lcrng.pokeRng(seed).advance(initialAdvances);
    final modulo = !methodJ;

    final cuteCharm = cuteCharmLead != Gen4CuteCharmLead.none && !fixedGender;
    final cuteCharmBuffer = cuteCharmLead == Gen4CuteCharmLead.female
        ? PokemonGenderRatio.cuteCharmFemaleBuffer(genderRatio)
        : 0;

    for (var cnt = 0; cnt <= maxAdvances; cnt++) {
      var go = rng.advance(offset);

      var cuteCharmFlag = false;
      if (cuteCharm) {
        final result = go.nextU16Bounded(3, modulo: modulo);
        go = Lcrng.pokeRng(result.seed);
        cuteCharmFlag = result.value != 0;
      }

      final natureResult = _nextLeadNature(go, modulo: modulo);
      go = natureResult.rng;
      final nature = natureResult.nature;

      int pid;
      if (cuteCharmFlag) {
        pid = cuteCharmBuffer + nature.index;
      } else {
        while (true) {
          final low = go.nextU16();
          go = Lcrng.pokeRng(low.seed);
          final high = go.nextU16();
          go = Lcrng.pokeRng(high.seed);
          pid = (high.value << 16) | low.value;
          if (pid % Nature.values.length == nature.index) {
            break;
          }
        }
      }

      final iv1 = go.nextU16();
      go = Lcrng.pokeRng(iv1.seed);
      final iv2 = go.nextU16();

      states.add(
        _buildState(
          rng: rng,
          cnt: cnt,
          pid: pid,
          iv1: iv1.value,
          iv2: iv2.value,
        ),
      );
      rng = Lcrng.pokeRng(states.last.prngSeed);
    }

    return states;
  }

  _Method1PidResult _createMethod1Pid(Lcrng rng) {
    var go = rng;
    int pid;

    if (shinyPolicy == Gen4StaticShinyPolicy.always) {
      final lowBase = go.nextU16Bounded(8);
      go = Lcrng.pokeRng(lowBase.seed);
      final highBase = go.nextU16Bounded(8);
      go = Lcrng.pokeRng(highBase.seed);

      var low = lowBase.value;
      var high = highBase.value;
      for (var i = 3; i < 16; i++) {
        final bit = go.nextU16Bounded(2);
        go = Lcrng.pokeRng(bit.seed);
        low |= bit.value << i;
      }
      high |= (low ^ tsv) & 0xfff8;
      pid = (high << 16) | low;
    } else {
      final low = go.nextU16();
      go = Lcrng.pokeRng(low.seed);
      final high = go.nextU16();
      go = Lcrng.pokeRng(high.seed);
      pid = (high.value << 16) | low.value;

      if (shinyPolicy == Gen4StaticShinyPolicy.never) {
        while (PokemonPid(pid).isShiny(tid: tid, sid: sid)) {
          pid = Lcrng.arng(pid).next().value;
        }
      }
    }

    return _Method1PidResult(pid: pid, rng: go);
  }

  _NatureResult _nextLeadNature(Lcrng rng, {required bool modulo}) {
    var go = rng;
    if (synchronizeNature != null) {
      final sync = go.nextU16Bounded(2, modulo: modulo);
      go = Lcrng.pokeRng(sync.seed);
      if (sync.value == 0) {
        return _NatureResult(nature: synchronizeNature!, rng: go);
      }
    }

    final result = go.nextU16Bounded(Nature.values.length, modulo: modulo);
    return _NatureResult(
      nature: Nature.values[result.value],
      rng: Lcrng.pokeRng(result.seed),
    );
  }

  Gen4StaticState _buildState({
    required Lcrng rng,
    required int cnt,
    required int pid,
    required int iv1,
    required int iv2,
  }) {
    final prng = rng.nextU16();
    final pokemonPid = PokemonPid(pid);
    return Gen4StaticState(
      prng: prng.value,
      prngSeed: prng.seed,
      advance: initialAdvances + cnt,
      pid: pokemonPid,
      ivs: Ivs.fromWords(iv1, iv2),
      abilitySlot: pokemonPid.abilitySlot,
      gender: pokemonPid.gender(genderRatio: genderRatio),
      level: level,
      nature: pokemonPid.nature,
      shiny: pokemonPid.shiny(tid: tid, sid: sid),
    );
  }

  void _validateConfiguration() {
    if (initialAdvances < 0 || maxAdvances < 0 || offset < 0) {
      throw ArgumentError('advance values must be non-negative');
    }
    if (level < 1 || level > 100) {
      throw ArgumentError.value(level, 'level', 'must be in 1..100');
    }
    if (tid < 0 || tid > 0xffff) {
      throw ArgumentError.value(tid, 'tid', 'must be in 0..65535');
    }
    if (sid < 0 || sid > 0xffff) {
      throw ArgumentError.value(sid, 'sid', 'must be in 0..65535');
    }
    PokemonGenderRatio.validate(genderRatio);
    if (method != Gen4StaticMethod.method1 &&
        shinyPolicy != Gen4StaticShinyPolicy.random) {
      throw ArgumentError(
        'shinyPolicy is only supported by Method 1 encounters',
      );
    }
    if (synchronizeNature != null &&
        cuteCharmLead != Gen4CuteCharmLead.none &&
        !fixedGender) {
      throw ArgumentError('synchronizeNature and cuteCharmLead are exclusive');
    }
  }
}

class Gen4StaticState {
  const Gen4StaticState({
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

class _Method1PidResult {
  const _Method1PidResult({required this.pid, required this.rng});

  final int pid;
  final Lcrng rng;
}

class _NatureResult {
  const _NatureResult({required this.nature, required this.rng});

  final Nature nature;
  final Lcrng rng;
}

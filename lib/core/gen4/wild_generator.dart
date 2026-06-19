import 'lcrng.dart';
import 'pokemon_attributes.dart';
import 'seed_verification.dart';

enum Gen4WildMethod { methodJ, methodK, honeyTree, pokeRadar, pokeRadarShiny }

enum Gen4WildEncounter {
  grass,
  surfing,
  oldRod,
  goodRod,
  superRod,
  rockSmash,
  bugCatchingContest,
  headbutt,
  headbuttAlt,
  headbuttSpecial,
  honeyTree,
}

extension Gen4WildEncounterProperties on Gen4WildEncounter {
  bool get isGrass => this == Gen4WildEncounter.grass;

  bool get isFishing =>
      this == Gen4WildEncounter.oldRod ||
      this == Gen4WildEncounter.goodRod ||
      this == Gen4WildEncounter.superRod;

  bool get isRockSmash => this == Gen4WildEncounter.rockSmash;

  bool get isBugCatchingContest => this == Gen4WildEncounter.bugCatchingContest;

  bool get isHeadbutt =>
      this == Gen4WildEncounter.headbutt ||
      this == Gen4WildEncounter.headbuttAlt ||
      this == Gen4WildEncounter.headbuttSpecial;

  bool get isHoneyTree => this == Gen4WildEncounter.honeyTree;
}

enum Gen4WildLead {
  none,
  synchronize,
  cuteCharmMale,
  cuteCharmFemale,
  compoundEyes,
  pressure,
  suctionCups,
  arenaTrap,
  magnetPull,
  static,
}

extension Gen4WildLeadProperties on Gen4WildLead {
  bool get isSynchronize => this == Gen4WildLead.synchronize;

  bool get isCuteCharm =>
      this == Gen4WildLead.cuteCharmMale ||
      this == Gen4WildLead.cuteCharmFemale;

  bool get isCuteCharmFemale => this == Gen4WildLead.cuteCharmFemale;

  bool get isCompoundEyes => this == Gen4WildLead.compoundEyes;

  bool get isPressure => this == Gen4WildLead.pressure;

  bool get isSuctionCups => this == Gen4WildLead.suctionCups;

  bool get isArenaTrap => this == Gen4WildLead.arenaTrap;

  bool get usesTypeAttract =>
      this == Gen4WildLead.magnetPull || this == Gen4WildLead.static;

  bool get supportsBasicWildSearch =>
      this == Gen4WildLead.none ||
      isCompoundEyes ||
      isPressure ||
      isSuctionCups ||
      isArenaTrap ||
      usesTypeAttract;

  bool get supportsGrassWildSearch =>
      this == Gen4WildLead.none ||
      isSynchronize ||
      isCuteCharm ||
      usesTypeAttract;

  bool get supportsHoneyTree =>
      this == Gen4WildLead.none ||
      isCompoundEyes ||
      isPressure ||
      isSynchronize ||
      isCuteCharm;

  bool get supportsPokeRadar =>
      this == Gen4WildLead.none ||
      isCompoundEyes ||
      isSynchronize ||
      isCuteCharm;
}

enum Gen4WildGame { diamondPearl, platinum, heartGoldSoulSilver }

enum Gen4DpptTimeModifier { none, day, night }

enum Gen4HgssRadioModifier { none, hoennSound, sinnohSound }

enum Gen4HgssTimeModifier { morning, day, night }

enum Gen4PokemonType {
  normal,
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
  dark,
}

class Gen4WildGenerator {
  const Gen4WildGenerator({
    required this.initialAdvances,
    required this.maxAdvances,
    required this.offset,
    required this.method,
    required this.game,
    required this.area,
    required this.tid,
    required this.sid,
    this.lead = Gen4WildLead.none,
    this.synchronizeNature,
    this.happiness = 0,
    this.encounterSlot = 0,
    this.feebasTile = false,
    this.unownRadio = false,
  });

  final int initialAdvances;
  final int maxAdvances;
  final int offset;
  final Gen4WildMethod method;
  final Gen4WildGame game;
  final Gen4WildArea area;
  final int tid;
  final int sid;
  final Gen4WildLead lead;
  final Nature? synchronizeNature;
  final int happiness;
  final int encounterSlot;
  final bool feebasTile;
  final bool unownRadio;

  int get tsv => tid ^ sid;

  List<Gen4WildState> generate(int seed) {
    _validateSeed(seed, 'seed');
    _validateU16(tid, 'tid');
    _validateU16(sid, 'sid');
    if (initialAdvances < 0 || maxAdvances < 0 || offset < 0) {
      throw ArgumentError('advance values must be non-negative');
    }
    _validateArea(area);
    if (happiness < 0 || happiness > 255) {
      throw ArgumentError.value(happiness, 'happiness', 'must be in 0..255');
    }
    if (!area.validSlotCount) {
      throw ArgumentError(
        'Gen4 wild areas must provide 12 slots, or 6 slots for Headbutt',
      );
    }
    if (encounterSlot < 0 || encounterSlot >= area.slots.length) {
      throw ArgumentError.value(
        encounterSlot,
        'encounterSlot',
        'must be within area slots',
      );
    }
    _validateConfiguration();

    return switch (method) {
      Gen4WildMethod.methodJ => _generate(seed, methodJ: true),
      Gen4WildMethod.methodK => _generate(seed, methodJ: false),
      Gen4WildMethod.honeyTree => _generateHoneyTree(seed),
      Gen4WildMethod.pokeRadar => _generatePokeRadar(seed, forcedShiny: false),
      Gen4WildMethod.pokeRadarShiny => _generatePokeRadar(
        seed,
        forcedShiny: true,
      ),
    };
  }

  List<Gen4WildState> _generate(int seed, {required bool methodJ}) {
    final states = <Gen4WildState>[];
    var rng = Lcrng.pokeRng(seed).advance(initialAdvances);
    final battleConst = _battleAdvancesConst();

    for (var cnt = 0; cnt <= maxAdvances; cnt++) {
      var battleAdvances = battleConst + initialAdvances + offset + cnt;
      var go = rng.advance(offset);

      final rate = _encounterRate(methodJ: methodJ);
      if (_needsEncounterCheck) {
        final check = _nextBounded(go, 100, methodJ: methodJ);
        go = check.rng;
        battleAdvances++;
        if (check.value >= rate) {
          rng = Lcrng.pokeRng(rng.next().value);
          continue;
        }
      }

      final slotResult =
          _nextMethodJFeebasSlot(go) ??
          _nextEncounterSlot(go, methodJ: methodJ);
      go = slotResult.rng;
      battleAdvances += slotResult.advances;

      var encounterSlot = slotResult.slot;
      final levelResult = _calculateLevel(
        encounterSlot,
        go,
        battleAdvances,
        methodJ: methodJ,
      );
      encounterSlot = levelResult.encounterSlot;
      go = levelResult.rng;
      battleAdvances = levelResult.battleAdvances;

      final slot = area.slots[encounterSlot];
      final cuteCharmResult = _nextCuteCharmFlag(go, slot, methodJ: methodJ);
      go = cuteCharmResult.rng;
      battleAdvances += cuteCharmResult.advances;

      final naturePidIvs = _nextNaturePidIvs(
        go,
        slot,
        cuteCharmFlag: cuteCharmResult.flag,
        methodJ: methodJ,
      );
      go = naturePidIvs.rng;
      battleAdvances += naturePidIvs.advances;

      final itemResult = _nextItem(go, slot);
      go = itemResult.rng;
      battleAdvances++;

      final formResult = _nextUnownForm(go, slot, methodJ: methodJ);
      go = formResult.rng;
      battleAdvances += formResult.advances;

      final prng = rng.nextU16();
      final pid = PokemonPid(naturePidIvs.pid);
      states.add(
        Gen4WildState(
          prng: prng.value,
          prngSeed: prng.seed,
          advance: initialAdvances + cnt,
          battleAdvances: battleAdvances,
          encounterSlot: encounterSlot,
          species: slot.species,
          pid: pid,
          ivs: Ivs.fromWords(naturePidIvs.iv1, naturePidIvs.iv2),
          abilitySlot: pid.abilitySlot,
          gender: pid.gender(genderRatio: slot.genderRatio),
          level: levelResult.level,
          nature: Nature.values[naturePidIvs.nature],
          shiny: pid.shiny(tid: tid, sid: sid),
          item: itemResult.item,
          form: formResult.form,
          perfectIvRerollAttempts: naturePidIvs.perfectIvRerollAttempts,
        ),
      );

      rng = Lcrng.pokeRng(prng.seed);
    }

    return states;
  }

  List<Gen4WildState> _generateHoneyTree(int seed) {
    final states = <Gen4WildState>[];
    var rng = Lcrng.pokeRng(seed).advance(initialAdvances);
    final battleConst = _battleAdvancesConst();

    for (var cnt = 0; cnt <= maxAdvances; cnt++) {
      var battleAdvances = battleConst + initialAdvances + offset + cnt;
      var go = rng.advance(offset);
      var slotIndex = encounterSlot;

      final levelResult = _calculateLevel(
        slotIndex,
        go,
        battleAdvances,
        methodJ: true,
      );
      slotIndex = levelResult.encounterSlot;
      go = levelResult.rng;
      battleAdvances = levelResult.battleAdvances;

      final slot = area.slots[slotIndex];
      final cuteCharmResult = _nextCuteCharmFlag(go, slot, methodJ: true);
      go = cuteCharmResult.rng;
      battleAdvances += cuteCharmResult.advances;

      final naturePidIvs = _nextNaturePidIvs(
        go,
        slot,
        cuteCharmFlag: cuteCharmResult.flag,
        methodJ: true,
      );
      go = naturePidIvs.rng;
      battleAdvances += naturePidIvs.advances;

      final itemResult = _nextItem(go, slot);
      go = itemResult.rng;
      battleAdvances++;

      final prng = rng.nextU16();
      final pid = PokemonPid(naturePidIvs.pid);
      states.add(
        Gen4WildState(
          prng: prng.value,
          prngSeed: prng.seed,
          advance: initialAdvances + cnt,
          battleAdvances: battleAdvances,
          encounterSlot: slotIndex,
          species: slot.species,
          pid: pid,
          ivs: Ivs.fromWords(naturePidIvs.iv1, naturePidIvs.iv2),
          abilitySlot: pid.abilitySlot,
          gender: pid.gender(genderRatio: slot.genderRatio),
          level: levelResult.level,
          nature: Nature.values[naturePidIvs.nature],
          shiny: pid.shiny(tid: tid, sid: sid),
          item: itemResult.item,
          form: 0,
        ),
      );

      rng = Lcrng.pokeRng(prng.seed);
    }

    return states;
  }

  List<Gen4WildState> _generatePokeRadar(
    int seed, {
    required bool forcedShiny,
  }) {
    if (!area.encounter.isGrass) {
      throw ArgumentError('Poke Radar encounters must use grass areas');
    }

    final states = <Gen4WildState>[];
    var rng = Lcrng.pokeRng(seed).advance(initialAdvances);
    final battleConst = _battleAdvancesConst();

    for (var cnt = 0; cnt <= maxAdvances; cnt++) {
      var battleAdvances = battleConst + initialAdvances + offset + cnt;
      var go = rng.advance(offset);
      final slot = area.slots[encounterSlot];

      final radarResult = forcedShiny
          ? _nextPokeRadarShinyPidIvs(go, slot)
          : _nextPokeRadarPidIvs(go, slot);
      go = radarResult.rng;
      battleAdvances += radarResult.advances;

      final itemResult = _nextItem(go, slot);
      go = itemResult.rng;
      battleAdvances++;

      final prng = rng.nextU16();
      final pid = PokemonPid(radarResult.pid);
      states.add(
        Gen4WildState(
          prng: prng.value,
          prngSeed: prng.seed,
          advance: initialAdvances + cnt,
          battleAdvances: battleAdvances,
          encounterSlot: encounterSlot,
          species: slot.species,
          pid: pid,
          ivs: Ivs.fromWords(radarResult.iv1, radarResult.iv2),
          abilitySlot: pid.abilitySlot,
          gender: pid.gender(genderRatio: slot.genderRatio),
          level: slot.maxLevel,
          nature: Nature.values[radarResult.nature],
          shiny: pid.shiny(tid: tid, sid: sid),
          item: itemResult.item,
          form: 0,
        ),
      );

      rng = Lcrng.pokeRng(prng.seed);
    }

    return states;
  }

  _NaturePidIvsResult _nextPokeRadarPidIvs(Lcrng rng, Gen4WildSlot slot) {
    var go = rng;
    var advances = 0;

    final cuteCharmResult = _nextCuteCharmFlag(go, slot, methodJ: true);
    go = cuteCharmResult.rng;
    advances += cuteCharmResult.advances;

    final result = _nextNaturePidIvs(
      go,
      slot,
      cuteCharmFlag: cuteCharmResult.flag,
      methodJ: true,
    );
    return _NaturePidIvsResult(
      nature: result.nature,
      pid: result.pid,
      iv1: result.iv1,
      iv2: result.iv2,
      rng: result.rng,
      advances: advances + result.advances,
    );
  }

  _NaturePidIvsResult _nextPokeRadarShinyPidIvs(Lcrng rng, Gen4WildSlot slot) {
    var go = rng;
    var advances = 0;

    final cuteCharm = lead.isCuteCharm && !slot.fixedGender;

    int pid;
    if (cuteCharm) {
      final charm = _nextBounded(go, 3, methodJ: true);
      go = charm.rng;
      advances++;
      if (charm.value != 0) {
        do {
          final shinyPid = _nextPokeRadarShinyPid(go);
          pid = shinyPid.pid;
          go = shinyPid.rng;
          advances += shinyPid.advances;
        } while (!_cuteCharmGenderMatches(pid, slot));
      } else {
        final shinyPid = _nextPokeRadarShinyPid(go);
        pid = shinyPid.pid;
        go = shinyPid.rng;
        advances += shinyPid.advances;
      }
    } else if (lead.isSynchronize) {
      final sync = _nextBounded(go, 2, methodJ: true);
      go = sync.rng;
      advances++;
      if (sync.value == 0) {
        final targetNature = (synchronizeNature ?? Nature.hardy).index;
        do {
          final shinyPid = _nextPokeRadarShinyPid(go);
          pid = shinyPid.pid;
          go = shinyPid.rng;
          advances += shinyPid.advances;
        } while (pid % Nature.values.length != targetNature);
      } else {
        final shinyPid = _nextPokeRadarShinyPid(go);
        pid = shinyPid.pid;
        go = shinyPid.rng;
        advances += shinyPid.advances;
      }
    } else {
      final shinyPid = _nextPokeRadarShinyPid(go);
      pid = shinyPid.pid;
      go = shinyPid.rng;
      advances += shinyPid.advances;
    }

    final iv1 = go.nextU16();
    go = Lcrng.pokeRng(iv1.seed);
    final iv2 = go.nextU16();
    go = Lcrng.pokeRng(iv2.seed);
    advances += 2;

    return _NaturePidIvsResult(
      nature: pid % Nature.values.length,
      pid: pid,
      iv1: iv1.value,
      iv2: iv2.value,
      rng: go,
      advances: advances,
    );
  }

  _PokeRadarShinyPidResult _nextPokeRadarShinyPid(Lcrng rng) {
    var go = rng;
    var advances = 0;

    final lowBase = go.nextU16Bounded(8);
    go = Lcrng.pokeRng(lowBase.seed);
    advances++;
    var low = lowBase.value;

    final highBase = go.nextU16Bounded(8);
    go = Lcrng.pokeRng(highBase.seed);
    advances++;
    var high = highBase.value;

    for (var bit = 3; bit < 16; bit++) {
      final next = go.nextU16();
      go = Lcrng.pokeRng(next.seed);
      advances++;
      low |= (next.value & 1) << bit;
    }

    high |= (tsv ^ low) & 0xfff8;
    return _PokeRadarShinyPidResult(
      pid: (high << 16) | low,
      rng: go,
      advances: advances,
    );
  }

  bool _cuteCharmGenderMatches(int pid, Gen4WildSlot slot) {
    if (lead.isCuteCharmFemale) {
      return (pid & 0xff) >= slot.genderRatio;
    }
    return (pid & 0xff) < slot.genderRatio;
  }

  int _battleAdvancesConst() {
    var advances = 0;
    if (area.fishing) {
      advances += 1;
    }
    if (game == Gen4WildGame.diamondPearl) {
      advances += 4;
    }
    if (!area.greatMarsh && !area.safariZone) {
      advances += 1;
    }
    return advances;
  }

  int _encounterRate({required bool methodJ}) {
    var rate = area.rate;
    if (!methodJ && area.fishing) {
      rate += happiness;
      if (lead.isSuctionCups) {
        rate *= 2;
      }
    } else if (!methodJ && area.encounter.isRockSmash && lead.isArenaTrap) {
      rate *= 2;
    }
    return rate;
  }

  bool get _needsEncounterCheck => area.needsEncounterCheck(method: method);

  bool get _isMethodJ => method == Gen4WildMethod.methodJ;

  _SlotResult? _nextMethodJFeebasSlot(Lcrng rng) {
    if (!_isMethodJ || !area.feebasLocation || !feebasTile) {
      return null;
    }

    final check = _nextBounded(rng, 2, methodJ: true);
    if (check.value != 0) {
      final extraAdvances = _hasTypeAttractLead ? 2 : 1;
      return _SlotResult(
        slot: 5,
        rng: check.rng.advance(extraAdvances),
        advances: 1 + extraAdvances,
      );
    }

    final slot = _nextEncounterSlot(check.rng, methodJ: true);
    return _SlotResult(
      slot: slot.slot,
      rng: slot.rng,
      advances: slot.advances + 1,
    );
  }

  _SlotResult _nextEncounterSlot(Lcrng rng, {required bool methodJ}) {
    if (_hasTypeAttractLead) {
      final attract = _nextBounded(rng, 2, methodJ: methodJ);
      final modifiedSlots = area.modifiedLeadSlots(lead);
      if (attract.value == 0 && modifiedSlots.isNotEmpty) {
        final slot = _nextBounded(
          attract.rng,
          modifiedSlots.length,
          methodJ: false,
        );
        return _SlotResult(
          slot: modifiedSlots[slot.value],
          rng: slot.rng,
          advances: 2,
        );
      }

      final slot = _nextRegularEncounterSlot(attract.rng, methodJ: methodJ);
      return _SlotResult(
        slot: slot.slot,
        rng: slot.rng,
        advances: slot.advances + 1,
      );
    }

    return _nextRegularEncounterSlot(rng, methodJ: methodJ);
  }

  _SlotResult _nextRegularEncounterSlot(Lcrng rng, {required bool methodJ}) {
    if (!methodJ && area.safariZone) {
      final rand = _nextBounded(rng, 10, methodJ: false);
      return _SlotResult(slot: rand.value, rng: rand.rng, advances: 1);
    }

    final rand = _nextBounded(rng, 100, methodJ: methodJ);
    final slot = methodJ
        ? _jSlot(rand.value, area.encounter)
        : _kSlot(rand.value, area.encounter);
    return _SlotResult(slot: slot, rng: rand.rng, advances: 1);
  }

  bool get _hasTypeAttractLead => lead.usesTypeAttract;

  _LevelResult _calculateLevel(
    int encounterSlot,
    Lcrng rng,
    int battleAdvances, {
    required bool methodJ,
  }) {
    var go = rng;
    var slotIndex = encounterSlot;
    final pressure = lead.isPressure;
    final diff = !area.usesFixedSlotLevel;

    if (diff) {
      final slot = area.slots[slotIndex];
      final range = slot.maxLevel - slot.minLevel + 1;
      final levelRand = _nextBounded(go, range, methodJ: methodJ);
      go = levelRand.rng;
      battleAdvances++;

      if (pressure) {
        final force = _nextBounded(go, 2, methodJ: methodJ);
        go = force.rng;
        battleAdvances++;
        if (force.value != 0) {
          return _LevelResult(
            encounterSlot: slotIndex,
            level: slot.maxLevel,
            rng: go,
            battleAdvances: battleAdvances,
          );
        }
      }

      return _LevelResult(
        encounterSlot: slotIndex,
        level: slot.minLevel + levelRand.value,
        rng: go,
        battleAdvances: battleAdvances,
      );
    }

    if (pressure) {
      final force = _nextBounded(go, 2, methodJ: methodJ);
      go = force.rng;
      battleAdvances++;
      if (force.value != 0) {
        final current = area.slots[slotIndex];
        for (var i = 0; i < area.slots.length; i++) {
          final candidate = area.slots[i];
          if (candidate.species == current.species &&
              candidate.maxLevel > current.maxLevel) {
            slotIndex = i;
          }
        }
      }
    }

    return _LevelResult(
      encounterSlot: slotIndex,
      level: area.slots[slotIndex].maxLevel,
      rng: go,
      battleAdvances: battleAdvances,
    );
  }

  _CuteCharmResult _nextCuteCharmFlag(
    Lcrng rng,
    Gen4WildSlot slot, {
    required bool methodJ,
  }) {
    final cuteCharm = lead.isCuteCharm && !slot.fixedGender;
    if (!cuteCharm) {
      return _CuteCharmResult(flag: false, rng: rng, advances: 0);
    }

    final result = _nextBounded(rng, 3, methodJ: methodJ);
    return _CuteCharmResult(
      flag: result.value != 0,
      rng: result.rng,
      advances: 1,
    );
  }

  _NaturePidIvsResult _nextNaturePidIvs(
    Lcrng rng,
    Gen4WildSlot slot, {
    required bool cuteCharmFlag,
    required bool methodJ,
  }) {
    if (!methodJ && area.usesPerfectIvRerolls && !cuteCharmFlag) {
      return _nextSafariNaturePidIvs(rng);
    }

    var go = rng;
    var advances = 0;

    int nature;
    if (cuteCharmFlag && !methodJ) {
      final natureResult = _nextBounded(
        go,
        Nature.values.length,
        methodJ: false,
      );
      nature = natureResult.value;
      go = natureResult.rng;
      advances++;
    } else {
      final natureResult = _nextNature(go, methodJ: methodJ);
      nature = natureResult.nature;
      go = natureResult.rng;
      advances += natureResult.advances;
    }

    int pid;
    if (cuteCharmFlag) {
      var buffer = 0;
      if (lead.isCuteCharmFemale) {
        buffer = PokemonGenderRatio.cuteCharmFemaleBuffer(slot.genderRatio);
      }
      pid = buffer + nature;
    } else {
      while (true) {
        final low = go.nextU16();
        go = Lcrng.pokeRng(low.seed);
        final high = go.nextU16();
        go = Lcrng.pokeRng(high.seed);
        advances += 2;
        pid = (high.value << 16) | low.value;
        if (pid % Nature.values.length == nature) {
          break;
        }
      }
    }

    final iv1 = go.nextU16();
    go = Lcrng.pokeRng(iv1.seed);
    final iv2 = go.nextU16();
    go = Lcrng.pokeRng(iv2.seed);
    advances += 2;

    return _NaturePidIvsResult(
      nature: nature,
      pid: pid,
      iv1: iv1.value,
      iv2: iv2.value,
      rng: go,
      advances: advances,
    );
  }

  _NaturePidIvsResult _nextSafariNaturePidIvs(Lcrng rng) {
    var go = rng;
    var advances = 0;
    var nature = 0;
    var pid = 0;
    var iv1 = 0;
    var iv2 = 0;

    for (var attempt = 0; attempt < 4; attempt++) {
      final natureResult = _nextNature(go, methodJ: false);
      nature = natureResult.nature;
      go = natureResult.rng;
      advances += natureResult.advances;

      while (true) {
        final low = go.nextU16();
        go = Lcrng.pokeRng(low.seed);
        final high = go.nextU16();
        go = Lcrng.pokeRng(high.seed);
        advances += 2;
        pid = (high.value << 16) | low.value;
        if (pid % Nature.values.length == nature) {
          break;
        }
      }

      final nextIv1 = go.nextU16();
      go = Lcrng.pokeRng(nextIv1.seed);
      final nextIv2 = go.nextU16();
      go = Lcrng.pokeRng(nextIv2.seed);
      advances += 2;
      iv1 = nextIv1.value;
      iv2 = nextIv2.value;

      if (_hasPerfectIv(ivs: Ivs.fromWords(iv1, iv2))) {
        return _NaturePidIvsResult(
          nature: nature,
          pid: pid,
          iv1: iv1,
          iv2: iv2,
          rng: go,
          advances: advances,
          perfectIvRerollAttempts: attempt + 1,
        );
      }
    }

    return _NaturePidIvsResult(
      nature: nature,
      pid: pid,
      iv1: iv1,
      iv2: iv2,
      rng: go,
      advances: advances,
      perfectIvRerollAttempts: 4,
    );
  }

  _NatureResult _nextNature(Lcrng rng, {required bool methodJ}) {
    var go = rng;
    var advances = 0;
    if (synchronizeNature != null || lead.isSynchronize) {
      final sync = _nextBounded(go, 2, methodJ: methodJ);
      go = sync.rng;
      advances++;
      if (sync.value == 0) {
        return _NatureResult(
          nature: (synchronizeNature ?? Nature.hardy).index,
          rng: go,
          advances: advances,
        );
      }
    }

    final randomNature = _nextBounded(
      go,
      Nature.values.length,
      methodJ: methodJ,
    );
    return _NatureResult(
      nature: randomNature.value,
      rng: randomNature.rng,
      advances: advances + 1,
    );
  }

  _ItemResult _nextItem(Lcrng rng, Gen4WildSlot slot) {
    final result = _nextBounded(rng, 100, methodJ: false);
    final rand = result.value;
    if (slot.item1 == slot.item2 && slot.item1 != 0) {
      return _ItemResult(item: slot.item1, rng: result.rng);
    }

    final firstCutoff = lead.isCompoundEyes ? 20 : 45;
    final secondCutoff = lead.isCompoundEyes ? 80 : 95;
    if (rand < firstCutoff) {
      return _ItemResult(item: 0, rng: result.rng);
    }
    if (rand < secondCutoff) {
      return _ItemResult(item: slot.item1, rng: result.rng);
    }
    return _ItemResult(item: slot.item2, rng: result.rng);
  }

  _UnownFormResult _nextUnownForm(
    Lcrng rng,
    Gen4WildSlot slot, {
    required bool methodJ,
  }) {
    if (slot.species != 201) {
      return _UnownFormResult(form: 0, rng: rng, advances: 0);
    }

    if (methodJ) {
      final result = rng.nextU16();
      return _UnownFormResult(
        form: _methodJUnownForm(area.location, result.value),
        rng: Lcrng.pokeRng(result.seed),
        advances: 1,
      );
    }

    if (area.unownUnlockedForms.isEmpty) {
      return _UnownFormResult(form: 0, rng: rng, advances: 0);
    }

    var go = rng;
    var advances = 0;
    if (area.location == 10) {
      final result = _nextBounded(go, 2, methodJ: false);
      return _UnownFormResult(
        form: 26 + result.value,
        rng: result.rng,
        advances: 1,
      );
    }

    if (area.location == 11) {
      if (unownRadio && area.unownUndiscoveredForms.isNotEmpty) {
        final radio = _nextBounded(go, 100, methodJ: false);
        go = radio.rng;
        advances++;
        if (radio.value < 50) {
          final form = _nextBounded(
            go,
            area.unownUndiscoveredForms.length,
            methodJ: false,
          );
          return _UnownFormResult(
            form: area.unownUndiscoveredForms[form.value],
            rng: form.rng,
            advances: advances + 1,
          );
        }
      }

      final form = _nextBounded(
        go,
        area.unownUnlockedForms.length,
        methodJ: false,
      );
      return _UnownFormResult(
        form: area.unownUnlockedForms[form.value],
        rng: form.rng,
        advances: advances + 1,
      );
    }

    return _UnownFormResult(form: 0, rng: rng, advances: 0);
  }

  bool _hasPerfectIv({required Ivs ivs}) {
    return ivs.hp == 31 ||
        ivs.attack == 31 ||
        ivs.defense == 31 ||
        ivs.specialAttack == 31 ||
        ivs.specialDefense == 31 ||
        ivs.speed == 31;
  }

  _BoundedResult _nextBounded(Lcrng rng, int bound, {required bool methodJ}) {
    final result = rng.nextU16Bounded(bound, modulo: !methodJ);
    return _BoundedResult(value: result.value, rng: Lcrng.pokeRng(result.seed));
  }

  void _validateConfiguration() {
    if (synchronizeNature != null && !lead.isSynchronize) {
      throw ArgumentError(
        'synchronizeNature is only valid with synchronize lead',
      );
    }

    switch (method) {
      case Gen4WildMethod.methodJ:
      case Gen4WildMethod.methodK:
        if (area.encounter.isHoneyTree) {
          throw ArgumentError(
            'Honey Tree encounters must use honeyTree method',
          );
        }
      case Gen4WildMethod.honeyTree:
        if (!area.encounter.isHoneyTree) {
          throw ArgumentError('honeyTree method must use honey tree areas');
        }
        if (!_supportsHoneyTreeLead) {
          throw ArgumentError.value(
            lead,
            'lead',
            'unsupported honey tree lead',
          );
        }
      case Gen4WildMethod.pokeRadar:
      case Gen4WildMethod.pokeRadarShiny:
        if (!area.encounter.isGrass) {
          throw ArgumentError('Poke Radar encounters must use grass areas');
        }
        if (!_supportsPokeRadarLead) {
          throw ArgumentError.value(
            lead,
            'lead',
            'unsupported Poke Radar lead',
          );
        }
    }
  }

  bool get _supportsHoneyTreeLead => lead.supportsHoneyTree;

  bool get _supportsPokeRadarLead => lead.supportsPokeRadar;
}

class Gen4WildArea {
  const Gen4WildArea({
    required this.rate,
    required this.encounter,
    required this.slots,
    this.location = 0,
    this.greatMarsh = false,
    this.safariZone = false,
    this.feebasLocation = false,
    this.unownUnlockedForms = const [],
    this.unownUndiscoveredForms = const [],
  });

  factory Gen4WildArea.hgssSafari({
    required int location,
    required int rate,
    required Gen4WildEncounter encounter,
    required List<Gen4WildSlot> normalSlots,
    required List<Gen4HgssSafariBlockSlot> blockSlots,
    required List<int> placedBlocks,
  }) {
    if (normalSlots.length != 10) {
      throw ArgumentError.value(
        normalSlots.length,
        'normalSlots.length',
        'HGSS Safari areas must provide 10 normal slots',
      );
    }
    for (var index = 0; index < placedBlocks.length; index++) {
      final count = placedBlocks[index];
      if (count < 0) {
        throw ArgumentError.value(
          count,
          'placedBlocks[$index]',
          'must be non-negative',
        );
      }
    }
    for (var index = 0; index < blockSlots.length; index++) {
      final blockSlot = blockSlots[index];
      if (blockSlot.quantity1 < 0 || blockSlot.quantity2 < 0) {
        throw ArgumentError.value(
          index,
          'blockSlots[$index]',
          'block quantities must be non-negative',
        );
      }
    }

    final slots = <Gen4WildSlot>[];
    var block = 0;
    for (var slotIndex = 0; slotIndex < normalSlots.length; slotIndex++) {
      var slot = normalSlots[slotIndex];
      for (; block < blockSlots.length; block++) {
        final blockSlot = blockSlots[block];
        if (blockSlot.requirementsMet(placedBlocks)) {
          slot = blockSlot.slot;
          block++;
          break;
        }
      }
      slots.add(slot);
    }
    while (slots.length < 12) {
      slots.add(Gen4WildSlot.empty);
    }

    return Gen4WildArea(
      rate: rate,
      encounter: encounter,
      slots: List.unmodifiable(slots),
      location: location,
      safariZone: true,
    );
  }

  final int rate;
  final Gen4WildEncounter encounter;
  final List<Gen4WildSlot> slots;
  final int location;
  final bool greatMarsh;
  final bool safariZone;
  final bool feebasLocation;
  final List<int> unownUnlockedForms;
  final List<int> unownUndiscoveredForms;

  bool get fishing => encounter.isFishing;

  bool get headbutt => encounter.isHeadbutt;

  bool get usesFixedSlotLevel =>
      encounter.isGrass || encounter.isBugCatchingContest || safariZone;

  bool get usesPerfectIvRerolls => encounter.isBugCatchingContest || safariZone;

  bool get usesGenerationSearch => usesPerfectIvRerolls;

  bool needsEncounterCheck({required Gen4WildMethod method}) =>
      encounter.isFishing ||
      (method == Gen4WildMethod.methodK && encounter.isRockSmash);

  bool get validSlotCount =>
      headbutt ? slots.length == 6 || slots.length == 12 : slots.length == 12;

  List<int> modifiedLeadSlots(Gen4WildLead lead) {
    final type = switch (lead) {
      Gen4WildLead.magnetPull => Gen4PokemonType.steel,
      Gen4WildLead.static => Gen4PokemonType.electric,
      _ => null,
    };
    if (type == null) {
      return const [];
    }

    final indexes = <int>[];
    for (var i = 0; i < slots.length; i++) {
      final slot = slots[i];
      if (slot.primaryType == type || slot.secondaryType == type) {
        indexes.add(i);
      }
    }
    if (indexes.length == slots.length) {
      return const [];
    }
    return List.unmodifiable(indexes);
  }

  Gen4WildArea replaceSlotSpeciesInfo(Map<int, Gen4WildSlot> replacements) {
    final nextSlots = List<Gen4WildSlot>.of(slots);
    for (final entry in replacements.entries) {
      final index = entry.key;
      if (index < 0 || index >= nextSlots.length) {
        throw ArgumentError.value(index, 'slot index', 'must be within slots');
      }
      nextSlots[index] = nextSlots[index].withSpeciesInfo(entry.value);
    }
    return _copyWithSlots(nextSlots);
  }

  Gen4WildArea applyDpptSwarm({
    required Gen4WildSlot slot0,
    required Gen4WildSlot slot1,
  }) {
    return replaceSlotSpeciesInfo({0: slot0, 1: slot1});
  }

  Gen4WildArea applyDpptTime({
    required Gen4DpptTimeModifier time,
    required Gen4WildSlot slot2,
    required Gen4WildSlot slot3,
  }) {
    return switch (time) {
      Gen4DpptTimeModifier.none => this,
      Gen4DpptTimeModifier.day || Gen4DpptTimeModifier.night =>
        replaceSlotSpeciesInfo({2: slot2, 3: slot3}),
    };
  }

  Gen4WildArea applyDpptPokeRadar({
    required Gen4WildSlot slot4,
    required Gen4WildSlot slot5,
    required Gen4WildSlot slot10,
    required Gen4WildSlot slot11,
  }) {
    return replaceSlotSpeciesInfo({4: slot4, 5: slot5, 10: slot10, 11: slot11});
  }

  Gen4WildArea applyDpptDualSlot({
    required Gen4WildSlot slot8,
    required Gen4WildSlot slot9,
  }) {
    return replaceSlotSpeciesInfo({8: slot8, 9: slot9});
  }

  Gen4WildArea applyGreatMarshDaily(Gen4WildSlot replacement) {
    if (location < 23 || location > 28) {
      return this;
    }
    return replaceSlotSpeciesInfo({6: replacement, 7: replacement});
  }

  Gen4WildArea applyTrophyGardenDaily({
    required Gen4WildSlot today,
    required Gen4WildSlot yesterday,
  }) {
    if (location != 117) {
      return this;
    }
    return replaceSlotSpeciesInfo({6: today, 7: yesterday});
  }

  Gen4WildArea applyHgssRadio({
    required Gen4HgssRadioModifier radio,
    required Gen4WildSlot slot2And3,
    required Gen4WildSlot slot4And5,
  }) {
    return switch (radio) {
      Gen4HgssRadioModifier.none => this,
      Gen4HgssRadioModifier.hoennSound ||
      Gen4HgssRadioModifier.sinnohSound => replaceSlotSpeciesInfo({
        2: slot2And3,
        3: slot2And3,
        4: slot4And5,
        5: slot4And5,
      }),
    };
  }

  Gen4WildArea applyHgssTime({
    required Gen4HgssTimeModifier time,
    required Gen4WildSlot fishNight,
  }) {
    if (time != Gen4HgssTimeModifier.night) {
      return this;
    }
    return switch (encounter) {
      Gen4WildEncounter.goodRod => replaceSlotSpeciesInfo({3: fishNight}),
      Gen4WildEncounter.superRod => replaceSlotSpeciesInfo({1: fishNight}),
      _ => this,
    };
  }

  Gen4WildArea applyHgssSwarm(Gen4WildSlot replacement) {
    return switch (encounter) {
      Gen4WildEncounter.grass => replaceSlotSpeciesInfo({
        0: replacement,
        1: replacement,
      }),
      Gen4WildEncounter.surfing => replaceSlotSpeciesInfo({0: replacement}),
      Gen4WildEncounter.oldRod => replaceSlotSpeciesInfo({2: replacement}),
      Gen4WildEncounter.goodRod => replaceSlotSpeciesInfo({
        0: replacement,
        2: replacement,
        3: replacement,
      }),
      Gen4WildEncounter.superRod => replaceSlotSpeciesInfo({
        0: replacement,
        1: replacement,
        2: replacement,
        3: replacement,
        4: replacement,
      }),
      _ => this,
    };
  }

  Gen4WildArea _copyWithSlots(List<Gen4WildSlot> nextSlots) {
    return Gen4WildArea(
      rate: rate,
      encounter: encounter,
      slots: List.unmodifiable(nextSlots),
      location: location,
      greatMarsh: greatMarsh,
      safariZone: safariZone,
      feebasLocation: feebasLocation,
      unownUnlockedForms: unownUnlockedForms,
      unownUndiscoveredForms: unownUndiscoveredForms,
    );
  }
}

class Gen4HgssSafariBlockSlot {
  const Gen4HgssSafariBlockSlot({
    required this.slot,
    required this.type1,
    required this.quantity1,
    required this.type2,
    required this.quantity2,
  });

  final Gen4WildSlot slot;
  final int type1;
  final int quantity1;
  final int type2;
  final int quantity2;

  bool requirementsMet(List<int> placedBlocks) {
    return _placedBlockCount(placedBlocks, type1) >= quantity1 &&
        _placedBlockCount(placedBlocks, type2) >= quantity2;
  }

  int _placedBlockCount(List<int> placedBlocks, int type) {
    if (type < 0 || type >= placedBlocks.length) {
      throw ArgumentError.value(type, 'block type', 'must be within blocks');
    }
    return placedBlocks[type];
  }
}

class Gen4WildSlot {
  const Gen4WildSlot({
    required this.species,
    required this.minLevel,
    required this.maxLevel,
    required this.genderRatio,
    this.item1 = 0,
    this.item2 = 0,
    this.primaryType,
    this.secondaryType,
  });

  static const empty = Gen4WildSlot(
    species: 0,
    minLevel: 0,
    maxLevel: 0,
    genderRatio: 255,
  );

  final int species;
  final int minLevel;
  final int maxLevel;
  final int genderRatio;
  final int item1;
  final int item2;
  final Gen4PokemonType? primaryType;
  final Gen4PokemonType? secondaryType;

  bool get fixedGender => PokemonGenderRatio.isFixed(genderRatio);

  Gen4WildSlot withSpeciesInfo(Gen4WildSlot speciesInfo) {
    return Gen4WildSlot(
      species: speciesInfo.species,
      minLevel: minLevel,
      maxLevel: maxLevel,
      genderRatio: speciesInfo.genderRatio,
      item1: speciesInfo.item1,
      item2: speciesInfo.item2,
      primaryType: speciesInfo.primaryType,
      secondaryType: speciesInfo.secondaryType,
    );
  }
}

class Gen4WildState {
  const Gen4WildState({
    required this.prng,
    required this.prngSeed,
    required this.advance,
    required this.battleAdvances,
    required this.encounterSlot,
    required this.species,
    required this.pid,
    required this.ivs,
    required this.abilitySlot,
    required this.gender,
    required this.level,
    required this.nature,
    required this.shiny,
    required this.item,
    required this.form,
    this.perfectIvRerollAttempts = 0,
  });

  final int prng;
  final int prngSeed;
  final int advance;
  final int battleAdvances;
  final int encounterSlot;
  final int species;
  final PokemonPid pid;
  final Ivs ivs;
  final int abilitySlot;
  final PokemonGender gender;
  final int level;
  final Nature nature;
  final Shiny shiny;
  final int item;
  final int form;
  final int perfectIvRerollAttempts;

  int get call => Gen4SeedVerification.callValue(prng);
  int get chatot => Gen4SeedVerification.chatotPitch(prng);
  int get frame => advance;
  int get hiddenPowerType => ivs.hiddenPowerType;
  Gen4HiddenPowerType get hiddenPower => ivs.hiddenPower;
  int get hiddenPowerStrength => ivs.hiddenPowerStrength;
  int get characteristic => ivs.characteristic(personalityValue: pid.value);
}

void _validateArea(Gen4WildArea area) {
  if (area.rate < 0 || area.rate > 100) {
    throw ArgumentError.value(area.rate, 'area.rate', 'must be in 0..100');
  }
  if (area.location < 0) {
    throw ArgumentError.value(
      area.location,
      'area.location',
      'must be non-negative',
    );
  }
  for (var index = 0; index < area.slots.length; index++) {
    _validateSlot(area.slots[index], 'area.slots[$index]');
  }
  _validateUnownForms(area.unownUnlockedForms, 'area.unownUnlockedForms');
  _validateUnownForms(
    area.unownUndiscoveredForms,
    'area.unownUndiscoveredForms',
  );
}

void _validateSlot(Gen4WildSlot slot, String name) {
  if (slot.species < 0 || slot.species > 493) {
    throw ArgumentError.value(
      slot.species,
      '$name.species',
      'must be in 0..493',
    );
  }
  if (slot.species == 0) {
    if (slot.minLevel < 0 ||
        slot.maxLevel > 100 ||
        slot.minLevel > slot.maxLevel) {
      throw ArgumentError.value(
        '${slot.minLevel}-${slot.maxLevel}',
        '$name.level',
        'empty slots must stay within 0..100 with min <= max',
      );
    }
  } else {
    if (slot.minLevel < 1 ||
        slot.maxLevel > 100 ||
        slot.minLevel > slot.maxLevel) {
      throw ArgumentError.value(
        '${slot.minLevel}-${slot.maxLevel}',
        '$name.level',
        'must be in 1..100 with min <= max',
      );
    }
  }
  try {
    PokemonGenderRatio.validate(slot.genderRatio);
  } on ArgumentError catch (error) {
    throw ArgumentError.value(
      slot.genderRatio,
      '$name.genderRatio',
      error.message,
    );
  }
  if (slot.item1 < 0 || slot.item2 < 0) {
    throw ArgumentError.value(
      '${slot.item1}/${slot.item2}',
      '$name.items',
      'must be non-negative',
    );
  }
}

void _validateUnownForms(List<int> forms, String name) {
  final seen = <int>{};
  for (var index = 0; index < forms.length; index++) {
    final form = forms[index];
    if (form < 0 || form > 27) {
      throw ArgumentError.value(form, '$name[$index]', 'must be in 0..27');
    }
    if (!seen.add(form)) {
      throw ArgumentError.value(
        form,
        '$name[$index]',
        'must not be duplicated',
      );
    }
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

int _jSlot(int rand, Gen4WildEncounter encounter) {
  return switch (encounter) {
    Gen4WildEncounter.goodRod || Gen4WildEncounter.superRod => _water2[rand],
    Gen4WildEncounter.oldRod || Gen4WildEncounter.surfing => _water4[rand],
    _ => _grass[rand],
  };
}

int _kSlot(int rand, Gen4WildEncounter encounter) {
  return switch (encounter) {
    Gen4WildEncounter.oldRod ||
    Gen4WildEncounter.goodRod ||
    Gen4WildEncounter.superRod => _water3[rand],
    Gen4WildEncounter.surfing => _water4[rand],
    Gen4WildEncounter.headbutt ||
    Gen4WildEncounter.headbuttAlt ||
    Gen4WildEncounter.headbuttSpecial => _headbutt[rand],
    Gen4WildEncounter.rockSmash => _rockSmash[rand],
    _ => _grass[rand],
  };
}

final List<int> _grass = _computeTable([
  20,
  40,
  50,
  60,
  70,
  80,
  85,
  90,
  94,
  98,
  99,
  100,
]);
final List<int> _rockSmash = _computeTable([80, 100]);
final List<int> _headbutt = _computeTable([50, 65, 80, 90, 95, 100]);
final List<int> _water2 = _computeTable([40, 80, 95, 99, 100]);
final List<int> _water3 = _computeTable([40, 70, 85, 95, 100]);
final List<int> _water4 = _computeTable([60, 90, 95, 99, 100]);

const List<int> _unown0 = [
  0,
  1,
  2,
  6,
  7,
  9,
  10,
  11,
  12,
  14,
  15,
  16,
  18,
  19,
  20,
  21,
  22,
  23,
  24,
  25,
];
const List<int> _unown1 = [5];
const List<int> _unown2 = [17];
const List<int> _unown3 = [8];
const List<int> _unown4 = [13];
const List<int> _unown5 = [4];
const List<int> _unown6 = [3];
const List<int> _unown7 = [26, 27];

List<int> _computeTable(List<int> ranges) {
  final table = List<int>.filled(100, 0);
  var rand = 0;
  for (var i = 0; i < ranges.length; i++) {
    while (rand < ranges[i]) {
      table[rand] = i;
      rand++;
    }
  }
  return table;
}

int _methodJUnownForm(int location, int prng) {
  final forms = switch (location) {
    29 => _unown7,
    30 => _unown0,
    32 => _unown1,
    34 => _unown2,
    40 => _unown3,
    41 => _unown4,
    42 => _unown5,
    43 => _unown6,
    _ => const <int>[0],
  };
  return forms[prng % forms.length];
}

class _BoundedResult {
  const _BoundedResult({required this.value, required this.rng});

  final int value;
  final Lcrng rng;
}

class _SlotResult {
  const _SlotResult({
    required this.slot,
    required this.rng,
    required this.advances,
  });

  final int slot;
  final Lcrng rng;
  final int advances;
}

class _LevelResult {
  const _LevelResult({
    required this.encounterSlot,
    required this.level,
    required this.rng,
    required this.battleAdvances,
  });

  final int encounterSlot;
  final int level;
  final Lcrng rng;
  final int battleAdvances;
}

class _CuteCharmResult {
  const _CuteCharmResult({
    required this.flag,
    required this.rng,
    required this.advances,
  });

  final bool flag;
  final Lcrng rng;
  final int advances;
}

class _NatureResult {
  const _NatureResult({
    required this.nature,
    required this.rng,
    required this.advances,
  });

  final int nature;
  final Lcrng rng;
  final int advances;
}

class _NaturePidIvsResult {
  const _NaturePidIvsResult({
    required this.nature,
    required this.pid,
    required this.iv1,
    required this.iv2,
    required this.rng,
    required this.advances,
    this.perfectIvRerollAttempts = 0,
  });

  final int nature;
  final int pid;
  final int iv1;
  final int iv2;
  final Lcrng rng;
  final int advances;
  final int perfectIvRerollAttempts;
}

class _PokeRadarShinyPidResult {
  const _PokeRadarShinyPidResult({
    required this.pid,
    required this.rng,
    required this.advances,
  });

  final int pid;
  final Lcrng rng;
  final int advances;
}

class _ItemResult {
  const _ItemResult({required this.item, required this.rng});

  final int item;
  final Lcrng rng;
}

class _UnownFormResult {
  const _UnownFormResult({
    required this.form,
    required this.rng,
    required this.advances,
  });

  final int form;
  final Lcrng rng;
  final int advances;
}

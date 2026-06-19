import 'lcrng.dart';
import 'lcrng_reverse.dart';
import 'id_generator.dart';
import 'pokemon_attributes.dart';

class Gen4PidTargetSearcher {
  const Gen4PidTargetSearcher({
    required this.minIvs,
    this.maxIvs = const Ivs(
      hp: 31,
      attack: 31,
      defense: 31,
      specialAttack: 31,
      specialDefense: 31,
      speed: 31,
    ),
    this.natures = const {},
    this.maxIvCombinations = 4096,
  });

  final Ivs minIvs;
  final Ivs maxIvs;
  final Set<Nature> natures;
  final int maxIvCombinations;

  List<Gen4PidTarget> searchMethod1() {
    _validate();

    final targets = <Gen4PidTarget>{};
    for (final ivs in _enumerateIvs()) {
      final ivSeeds = LcrngReverse.recoverPokeRngIvs(
        hp: ivs.hp,
        attack: ivs.attack,
        defense: ivs.defense,
        specialAttack: ivs.specialAttack,
        specialDefense: ivs.specialDefense,
        speed: ivs.speed,
      );

      for (final ivSeed in ivSeeds) {
        var reverse = Lcrng.pokeRngReverse(ivSeed);
        final high = reverse.nextU16();
        reverse = Lcrng.pokeRngReverse(high.seed);
        final low = reverse.nextU16();
        reverse = Lcrng.pokeRngReverse(low.seed);

        final pid = PokemonPid((high.value << 16) | low.value);
        if (natures.isNotEmpty && !natures.contains(pid.nature)) {
          continue;
        }

        targets.add(
          Gen4PidTarget(
            method: Gen4PidTargetMethod.method1,
            encounterSeed: reverse.next().value,
            ivSeed: ivSeed,
            pid: pid,
            ivs: ivs,
          ),
        );
      }
    }

    return targets.toList()..sort((left, right) {
      final totalCompare = right.ivs.total.compareTo(left.ivs.total);
      if (totalCompare != 0) {
        return totalCompare;
      }
      final natureCompare = left.pid.nature.index.compareTo(
        right.pid.nature.index,
      );
      if (natureCompare != 0) {
        return natureCompare;
      }
      return left.pid.value.compareTo(right.pid.value);
    });
  }

  List<Gen4PidTargetGroup> searchMethod1Groups() {
    final byPsv = <int, List<Gen4PidTarget>>{};
    for (final target in searchMethod1()) {
      byPsv
          .putIfAbsent(target.personalityShinyValue, () => <Gen4PidTarget>[])
          .add(target);
    }

    return [
      for (final entry in byPsv.entries)
        Gen4PidTargetGroup(
          personalityShinyValue: entry.key,
          targets: entry.value,
        ),
    ]..sort((left, right) {
      final countCompare = right.targets.length.compareTo(left.targets.length);
      if (countCompare != 0) {
        return countCompare;
      }
      final totalCompare = right.bestIvTotal.compareTo(left.bestIvTotal);
      if (totalCompare != 0) {
        return totalCompare;
      }
      return left.personalityShinyValue.compareTo(right.personalityShinyValue);
    });
  }

  Iterable<Ivs> _enumerateIvs() sync* {
    var count = 0;
    for (var hp = minIvs.hp; hp <= maxIvs.hp; hp += 1) {
      for (var attack = minIvs.attack; attack <= maxIvs.attack; attack += 1) {
        for (
          var defense = minIvs.defense;
          defense <= maxIvs.defense;
          defense += 1
        ) {
          for (
            var specialAttack = minIvs.specialAttack;
            specialAttack <= maxIvs.specialAttack;
            specialAttack += 1
          ) {
            for (
              var specialDefense = minIvs.specialDefense;
              specialDefense <= maxIvs.specialDefense;
              specialDefense += 1
            ) {
              for (
                var speed = minIvs.speed;
                speed <= maxIvs.speed;
                speed += 1
              ) {
                count += 1;
                if (count > maxIvCombinations) {
                  throw ArgumentError(
                    'PID target search would scan more than '
                    '$maxIvCombinations IV combinations',
                  );
                }
                yield Ivs(
                  hp: hp,
                  attack: attack,
                  defense: defense,
                  specialAttack: specialAttack,
                  specialDefense: specialDefense,
                  speed: speed,
                );
              }
            }
          }
        }
      }
    }
  }

  void _validate() {
    _validateIvs(minIvs, name: 'minIvs');
    _validateIvs(maxIvs, name: 'maxIvs');
    final minValues = minIvs.ordered;
    final maxValues = maxIvs.ordered;
    for (var index = 0; index < minValues.length; index += 1) {
      if (minValues[index] > maxValues[index]) {
        throw ArgumentError('minIvs must be <= maxIvs');
      }
    }
    if (maxIvCombinations <= 0) {
      throw ArgumentError.value(
        maxIvCombinations,
        'maxIvCombinations',
        'must be positive',
      );
    }
  }
}

enum Gen4PidTargetMethod { method1 }

class Gen4PidTarget {
  const Gen4PidTarget({
    required this.method,
    required this.encounterSeed,
    required this.ivSeed,
    required this.pid,
    required this.ivs,
  });

  final Gen4PidTargetMethod method;
  final int encounterSeed;
  final int ivSeed;
  final PokemonPid pid;
  final Ivs ivs;

  Nature get nature => pid.nature;
  int get abilitySlot => pid.abilitySlot;
  int get personalityShinyValue => pid.personalityShinyValue;
  int get fullPersonalityShinyValue => pid.fullPersonalityShinyValue;

  Gen4ShinySidRange sidRangeForTid(int tid) {
    return Gen4ShinySidRange.fromTidPid(tid: tid, pid: pid.value);
  }

  @override
  bool operator ==(Object other) {
    return other is Gen4PidTarget &&
        other.method == method &&
        other.pid.value == pid.value &&
        other.ivs.hp == ivs.hp &&
        other.ivs.attack == ivs.attack &&
        other.ivs.defense == ivs.defense &&
        other.ivs.specialAttack == ivs.specialAttack &&
        other.ivs.specialDefense == ivs.specialDefense &&
        other.ivs.speed == ivs.speed;
  }

  @override
  int get hashCode => Object.hash(
    method,
    pid.value,
    ivs.hp,
    ivs.attack,
    ivs.defense,
    ivs.specialAttack,
    ivs.specialDefense,
    ivs.speed,
  );
}

class Gen4PidTargetGroup {
  const Gen4PidTargetGroup({
    required this.personalityShinyValue,
    required this.targets,
  });

  final int personalityShinyValue;
  final List<Gen4PidTarget> targets;

  int get bestIvTotal {
    var best = 0;
    for (final target in targets) {
      if (target.ivs.total > best) {
        best = target.ivs.total;
      }
    }
    return best;
  }

  Gen4ShinySidRange sidRangeForTid(int tid) {
    if (targets.isEmpty) {
      throw StateError('cannot calculate SID range for an empty PID group');
    }
    return targets.first.sidRangeForTid(tid);
  }
}

void _validateIvs(Ivs ivs, {required String name}) {
  final values = ivs.ordered;
  for (var index = 0; index < values.length; index += 1) {
    final value = values[index];
    if (value < 0 || value > 31) {
      throw ArgumentError.value(value, '$name[$index]', 'must be in 0..31');
    }
  }
}

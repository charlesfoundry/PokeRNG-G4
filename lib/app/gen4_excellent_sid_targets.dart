import '../core/gen4/gen4.dart';

final Set<Nature> attackLoweringNatures = Nature.values
    .where((nature) => !nature.isNeutral && nature.loweredStatIndex == 0)
    .toSet();

enum ExcellentSidSort { natureCount, targetCount }

List<Gen4PidTargetGroup> excellentSidTargetGroups({
  required int minIv,
  required ExcellentSidSort sort,
}) {
  final targets = [
    ...standardExcellentTargets(minIv),
    ...attackFlexibleExcellentTargets(minIv),
  ];
  return groupExcellentSidTargets(targets, sort);
}

List<Gen4PidTarget> standardExcellentTargets(int minIv) {
  final minIvs = Ivs(
    hp: minIv,
    attack: minIv,
    defense: minIv,
    specialAttack: minIv,
    specialDefense: minIv,
    speed: minIv,
  );
  return Gen4PidTargetSearcher(
    minIvs: minIvs,
    natures: Nature.values.toSet(),
    maxIvCombinations: 200000,
  ).searchMethod1();
}

List<Gen4PidTarget> attackFlexibleExcellentTargets(int minIv) {
  return Gen4PidTargetSearcher(
    minIvs: Ivs(
      hp: minIv,
      attack: 0,
      defense: minIv,
      specialAttack: minIv,
      specialDefense: minIv,
      speed: minIv,
    ),
    maxIvs: const Ivs(
      hp: 31,
      attack: 31,
      defense: 31,
      specialAttack: 31,
      specialDefense: 31,
      speed: 31,
    ),
    natures: attackLoweringNatures,
    maxIvCombinations: 200000,
  ).searchMethod1();
}

List<Gen4PidTargetGroup> groupExcellentSidTargets(
  List<Gen4PidTarget> targets,
  ExcellentSidSort sort,
) {
  final uniqueTargets = targets.toSet();
  final byPsv = <int, List<Gen4PidTarget>>{};
  for (final target in uniqueTargets) {
    byPsv
        .putIfAbsent(target.personalityShinyValue, () => <Gen4PidTarget>[])
        .add(target);
  }

  final groups = [
    for (final entry in byPsv.entries)
      Gen4PidTargetGroup(
        personalityShinyValue: entry.key,
        targets: entry.value..sort(compareExcellentSidTargets),
      ),
  ];
  return sortExcellentSidGroups(groups, sort);
}

List<Gen4PidTargetGroup> sortExcellentSidGroups(
  List<Gen4PidTargetGroup> groups,
  ExcellentSidSort sort,
) {
  return [...groups]..sort((left, right) {
    final primaryCompare = switch (sort) {
      ExcellentSidSort.natureCount => excellentSidNatureCount(
        right,
      ).compareTo(excellentSidNatureCount(left)),
      ExcellentSidSort.targetCount => right.targets.length.compareTo(
        left.targets.length,
      ),
    };
    if (primaryCompare != 0) {
      return primaryCompare;
    }
    final secondaryCompare = switch (sort) {
      ExcellentSidSort.natureCount => right.targets.length.compareTo(
        left.targets.length,
      ),
      ExcellentSidSort.targetCount => excellentSidNatureCount(
        right,
      ).compareTo(excellentSidNatureCount(left)),
    };
    if (secondaryCompare != 0) {
      return secondaryCompare;
    }
    return left.personalityShinyValue.compareTo(right.personalityShinyValue);
  });
}

int compareExcellentSidTargets(Gen4PidTarget left, Gen4PidTarget right) {
  final natureCompare = left.nature.index.compareTo(right.nature.index);
  if (natureCompare != 0) {
    return natureCompare;
  }
  final totalCompare = right.ivs.total.compareTo(left.ivs.total);
  if (totalCompare != 0) {
    return totalCompare;
  }
  return left.pid.value.compareTo(right.pid.value);
}

int excellentSidNatureCount(Gen4PidTargetGroup group) {
  return group.targets
      .map((target) => excellentSidNatureBucket(target.nature))
      .toSet()
      .length;
}

String excellentSidNatureBucket(Nature nature) {
  return nature.isNeutral ? 'neutral' : nature.name;
}

String excellentSidNatureModifier(Nature nature) {
  if (nature.isNeutral) {
    return 'neutral';
  }
  return '+${excellentSidNatureStatName(nature.raisedStatIndex)} / '
      '-${excellentSidNatureStatName(nature.loweredStatIndex)}';
}

String excellentSidNatureStatName(int index) {
  return switch (index) {
    0 => 'Atk',
    1 => 'Def',
    2 => 'Spe',
    3 => 'SpA',
    4 => 'SpD',
    _ => throw ArgumentError.value(index, 'index', 'unknown nature stat'),
  };
}

import '../core/gen4/gen4.dart';
import 'gen4_excellent_sid_targets.dart';
import 'gen4_id_search_job.dart';

class ReachableExcellentSidRequest {
  const ReachableExcellentSidRequest({
    required this.searchRequest,
    required this.groupsByTsv,
  });

  final Gen4IdSearchRequest searchRequest;
  final Map<int, Gen4PidTargetGroup> groupsByTsv;
}

class ReachableExcellentSidResult {
  const ReachableExcellentSidResult({required this.state, required this.group});

  final Gen4IdState state;
  final Gen4PidTargetGroup? group;
}

List<ReachableExcellentSidResult> matchReachableExcellentSidResults(
  List<Gen4IdState> states,
  Map<int, Gen4PidTargetGroup> groupsByTsv,
) {
  final results = <ReachableExcellentSidResult>[];
  for (final state in states) {
    if (groupsByTsv.isEmpty) {
      results.add(ReachableExcellentSidResult(state: state, group: null));
      continue;
    }
    final group = groupsByTsv[state.trainerShinyValue];
    if (group == null) {
      continue;
    }
    results.add(ReachableExcellentSidResult(state: state, group: group));
  }
  return results..sort(compareReachableExcellentSidResults);
}

int compareReachableExcellentSidResults(
  ReachableExcellentSidResult left,
  ReachableExcellentSidResult right,
) {
  final leftGroup = left.group;
  final rightGroup = right.group;
  final natureCompare =
      (rightGroup == null ? 0 : excellentSidNatureCount(rightGroup)).compareTo(
        leftGroup == null ? 0 : excellentSidNatureCount(leftGroup),
      );
  if (natureCompare != 0) {
    return natureCompare;
  }
  final countCompare = (rightGroup?.targets.length ?? 0).compareTo(
    leftGroup?.targets.length ?? 0,
  );
  if (countCompare != 0) {
    return countCompare;
  }
  final delayCompare = left.state.delay.compareTo(right.state.delay);
  if (delayCompare != 0) {
    return delayCompare;
  }
  return left.state.seed.compareTo(right.state.seed);
}

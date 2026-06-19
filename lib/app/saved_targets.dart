import 'dart:convert';

import 'search_results.dart';

const maxSavedGen4Targets = 20;

class SavedGen4Target {
  const SavedGen4Target({
    required this.id,
    required this.savedAt,
    required this.result,
  });

  factory SavedGen4Target.fromJson(Map<String, dynamic> json) {
    return SavedGen4Target(
      id: json['id'] as int,
      savedAt: DateTime.fromMillisecondsSinceEpoch(json['savedAtMs'] as int),
      result: Gen4SearchResultRow.fromJson(
        (json['result'] as Map).cast<String, dynamic>(),
      ),
    );
  }

  final int id;
  final DateTime savedAt;
  final Gen4SearchResultRow result;

  String get duplicateKey => jsonEncode(result.toJson());

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'savedAtMs': savedAt.millisecondsSinceEpoch,
      'result': result.toJson(),
    };
  }
}

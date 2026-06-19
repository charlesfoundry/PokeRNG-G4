import 'package:flutter/widgets.dart';

enum AppLanguage {
  system('system'),
  english('en'),
  japanese('ja'),
  chinese('zh');

  const AppLanguage(this.storageKey);

  final String storageKey;

  Locale? get locale {
    return switch (this) {
      AppLanguage.system => null,
      AppLanguage.english => const Locale('en'),
      AppLanguage.japanese => const Locale('ja'),
      AppLanguage.chinese => const Locale('zh'),
    };
  }
}

AppLanguage appLanguageFromStorage(String? value) {
  return AppLanguage.values.firstWhere(
    (language) => language.storageKey == value,
    orElse: () => AppLanguage.system,
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_language.dart';
import 'app_profile.dart';
import 'app_shell.dart';
import 'app_storage.dart';
import 'app_theme.dart';
import 'widgets/keyboard_dismiss_region.dart';
import '../data/gen4/gen4_game.dart';
import '../l10n/app_localizations.dart';

class PokeRngG4App extends StatefulWidget {
  const PokeRngG4App({super.key, AppStorage? storage}) : _storage = storage;

  final AppStorage? _storage;

  @override
  State<PokeRngG4App> createState() => _PokeRngG4AppState();
}

class _PokeRngG4AppState extends State<PokeRngG4App> {
  late final AppStorage _storage = widget._storage ?? AppStorage();
  AppLanguage _language = AppLanguage.system;
  AppProfile _profile = AppProfile.initial;
  Map<Gen4GameVersion, AppProfile> _profiles = {
    for (final game in Gen4GameVersion.values)
      game: AppProfile.defaultsFor(game),
  };
  var _shellEpoch = 0;
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: _language.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: _resolveAppLocale,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: const TextScaler.linear(0.95)),
          child: KeyboardDismissRegion(child: child ?? const SizedBox.shrink()),
        );
      },
      theme: buildAppTheme(),
      home: _loaded
          ? AppShell(
              key: ValueKey('app-shell-$_shellEpoch'),
              language: _language,
              profile: _profile,
              profiles: _profiles,
              storage: _storage,
              onLanguageChanged: _setLanguage,
              onProfileChanged: _setProfile,
            )
          : const _LoadingShell(),
    );
  }

  Future<void> _loadSettings() async {
    final language = await _storage.loadLanguage();
    final profiles = await _storage.loadProfiles();
    final game = await _storage.loadCurrentGame();
    if (!mounted) {
      return;
    }
    setState(() {
      _language = language;
      _profiles = profiles;
      _profile = profiles[game] ?? AppProfile.defaultsFor(game);
      _loaded = true;
    });
  }

  Future<void> _setLanguage(AppLanguage language) async {
    if (_language == language) {
      return;
    }
    setState(() {
      _language = language;
      _shellEpoch += 1;
    });
    await _storage.saveLanguage(language);
  }

  Future<void> _setProfile(AppProfile profile) async {
    setState(() {
      _profile = profile;
      _profiles = {..._profiles, profile.game: profile};
    });
    await _storage.saveProfile(profile);
  }
}

Locale _resolveAppLocale(
  List<Locale>? preferredLocales,
  Iterable<Locale> supportedLocales,
) {
  const english = Locale('en');
  const japanese = Locale('ja');
  const chinese = Locale('zh');

  final preferred = preferredLocales?.isEmpty ?? true
      ? null
      : preferredLocales!.first;
  if (preferred == null) {
    return english;
  }

  if (preferred.languageCode == 'en') {
    return english;
  }
  if (preferred.languageCode == 'ja') {
    return japanese;
  }
  if (preferred.languageCode == 'zh' &&
      (preferred.scriptCode == 'Hans' ||
          preferred.countryCode == 'CN' ||
          preferred.countryCode == 'SG' ||
          (preferred.scriptCode == null && preferred.countryCode == null))) {
    return chinese;
  }

  return english;
}

class _LoadingShell extends StatelessWidget {
  const _LoadingShell();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

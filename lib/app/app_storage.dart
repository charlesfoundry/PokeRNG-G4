import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/gen4/gen4_timer.dart';
import '../data/gen4/gen4_game.dart';
import 'app_language.dart';
import 'app_profile.dart';
import 'saved_targets.dart';

abstract interface class PreferencesStore {
  Future<String?> getString(String key);

  Future<int?> getInt(String key);

  Future<double?> getDouble(String key);

  Future<bool?> getBool(String key);

  Future<void> setString(String key, String value);

  Future<void> setInt(String key, int value);

  Future<void> setDouble(String key, double value);

  Future<void> setBool(String key, bool value);
}

class SharedPreferencesStore implements PreferencesStore {
  SharedPreferencesStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> getString(String key) => _preferences.getString(key);

  @override
  Future<int?> getInt(String key) => _preferences.getInt(key);

  @override
  Future<double?> getDouble(String key) => _preferences.getDouble(key);

  @override
  Future<bool?> getBool(String key) => _preferences.getBool(key);

  @override
  Future<void> setString(String key, String value) {
    return _preferences.setString(key, value);
  }

  @override
  Future<void> setInt(String key, int value) {
    return _preferences.setInt(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) {
    return _preferences.setDouble(key, value);
  }

  @override
  Future<void> setBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }
}

class AppStorage {
  AppStorage({PreferencesStore? store})
    : _store = store ?? SharedPreferencesStore();

  final PreferencesStore _store;

  static const _languageKey = 'app.language';
  static const _currentGameKey = 'app.currentGame';

  Future<AppLanguage> loadLanguage() async {
    return appLanguageFromStorage(await _store.getString(_languageKey));
  }

  Future<void> saveLanguage(AppLanguage language) {
    return _store.setString(_languageKey, language.storageKey);
  }

  Future<Gen4GameVersion> loadCurrentGame() async {
    final value = await _store.getString(_currentGameKey);
    if (value == null) {
      return Gen4GameVersion.diamond;
    }
    try {
      return gen4GameVersionFromJson(value);
    } on ArgumentError {
      return Gen4GameVersion.diamond;
    }
  }

  Future<void> saveCurrentGame(Gen4GameVersion game) {
    return _store.setString(_currentGameKey, game.jsonName);
  }

  Future<Map<Gen4GameVersion, AppProfile>> loadProfiles() async {
    final profiles = <Gen4GameVersion, AppProfile>{};
    for (final game in Gen4GameVersion.values) {
      profiles[game] = await loadProfile(game);
    }
    return profiles;
  }

  Future<AppProfile> loadProfile(Gen4GameVersion game) async {
    final tid = await _store.getInt(_profileKey(game, 'tid')) ?? 0;
    final sid = await _store.getInt(_profileKey(game, 'sid')) ?? 0;
    final defaults = AppProfile.defaultsFor(game);
    final calibratedDelay =
        await _store.getInt(_profileKey(game, 'calibratedDelay')) ??
        defaults.calibratedDelay;
    final idCalibratedDelay =
        await _store.getInt(_profileKey(game, 'idCalibratedDelay')) ??
        defaults.idCalibratedDelay;
    final eggCalibratedDelay =
        await _store.getInt(_profileKey(game, 'eggCalibratedDelay')) ??
        defaults.eggCalibratedDelay;
    final calibratedSecond =
        await _store.getInt(_profileKey(game, 'calibratedSecond')) ??
        defaults.calibratedSecond;
    final delayWindow =
        await _store.getInt(_profileKey(game, 'delayWindow')) ??
        defaults.delayWindow;
    final secondWindow =
        await _store.getInt(_profileKey(game, 'secondWindow')) ??
        defaults.secondWindow;
    final maxPhoneCallSkip =
        await _store.getInt(_profileKey(game, 'maxPhoneCallSkip')) ??
        defaults.maxPhoneCallSkip;
    final timerConsole = Gen4TimerConsole.fromStorageKey(
      await _store.getString(_profileKey(game, 'timerConsole')),
    );
    final timerCustomFrameRate =
        await _store.getDouble(_profileKey(game, 'timerCustomFrameRate')) ??
        defaults.timerCustomFrameRate;
    final timerMinimumLengthSeconds =
        await _store.getInt(_profileKey(game, 'timerMinimumLengthSeconds')) ??
        defaults.timerMinimumLengthSeconds;
    final timerPrecisionCalibration =
        await _store.getBool(_profileKey(game, 'timerPrecisionCalibration')) ??
        defaults.timerPrecisionCalibration;
    final phoneCaller = Gen4PhoneCaller.fromStorageKey(
      await _store.getString(_profileKey(game, 'phoneCaller')),
    );
    final eggParentAIvs = _decodeIvList(
      await _store.getString(_profileKey(game, 'eggParentAIvs')),
      defaults.eggParentAIvs,
    );
    final eggParentBIvs = _decodeIvList(
      await _store.getString(_profileKey(game, 'eggParentBIvs')),
      defaults.eggParentBIvs,
    );
    final eggMasuda =
        await _store.getBool(_profileKey(game, 'eggMasuda')) ??
        defaults.eggMasuda;
    final eggLockedPid =
        await _store.getString(_profileKey(game, 'eggLockedPid')) ??
        defaults.eggLockedPid;
    return AppProfile(
      game: game,
      tid: tid,
      sid: sid,
      calibratedDelay: calibratedDelay,
      idCalibratedDelay: idCalibratedDelay,
      eggCalibratedDelay: eggCalibratedDelay,
      calibratedSecond: calibratedSecond,
      delayWindow: delayWindow,
      secondWindow: secondWindow,
      maxPhoneCallSkip: maxPhoneCallSkip,
      timerConsole: timerConsole,
      timerCustomFrameRate: timerCustomFrameRate,
      timerMinimumLengthSeconds: timerMinimumLengthSeconds,
      timerPrecisionCalibration: timerPrecisionCalibration,
      phoneCaller: phoneCaller,
      eggParentAIvs: eggParentAIvs,
      eggParentBIvs: eggParentBIvs,
      eggMasuda: eggMasuda,
      eggLockedPid: eggLockedPid,
    );
  }

  Future<void> saveProfile(AppProfile profile) async {
    await _store.setInt(_profileKey(profile.game, 'tid'), profile.tid);
    await _store.setInt(_profileKey(profile.game, 'sid'), profile.sid);
    await _store.setInt(
      _profileKey(profile.game, 'calibratedDelay'),
      profile.calibratedDelay,
    );
    await _store.setInt(
      _profileKey(profile.game, 'idCalibratedDelay'),
      profile.idCalibratedDelay,
    );
    await _store.setInt(
      _profileKey(profile.game, 'eggCalibratedDelay'),
      profile.eggCalibratedDelay,
    );
    await _store.setInt(
      _profileKey(profile.game, 'calibratedSecond'),
      profile.calibratedSecond,
    );
    await _store.setInt(
      _profileKey(profile.game, 'delayWindow'),
      profile.delayWindow,
    );
    await _store.setInt(
      _profileKey(profile.game, 'secondWindow'),
      profile.secondWindow,
    );
    await _store.setInt(
      _profileKey(profile.game, 'maxPhoneCallSkip'),
      profile.maxPhoneCallSkip,
    );
    await _store.setString(
      _profileKey(profile.game, 'timerConsole'),
      profile.timerConsole.storageKey,
    );
    await _store.setDouble(
      _profileKey(profile.game, 'timerCustomFrameRate'),
      profile.timerCustomFrameRate,
    );
    await _store.setInt(
      _profileKey(profile.game, 'timerMinimumLengthSeconds'),
      profile.timerMinimumLengthSeconds,
    );
    await _store.setBool(
      _profileKey(profile.game, 'timerPrecisionCalibration'),
      profile.timerPrecisionCalibration,
    );
    await _store.setString(
      _profileKey(profile.game, 'phoneCaller'),
      profile.phoneCaller.storageKey,
    );
    await _store.setString(
      _profileKey(profile.game, 'eggParentAIvs'),
      jsonEncode(profile.eggParentAIvs),
    );
    await _store.setString(
      _profileKey(profile.game, 'eggParentBIvs'),
      jsonEncode(profile.eggParentBIvs),
    );
    await _store.setBool(
      _profileKey(profile.game, 'eggMasuda'),
      profile.eggMasuda,
    );
    await _store.setString(
      _profileKey(profile.game, 'eggLockedPid'),
      profile.eggLockedPid,
    );
    await saveCurrentGame(profile.game);
  }

  Future<List<SavedGen4Target>> loadTargets(Gen4GameVersion game) async {
    final raw = await _store.getString(_targetsKey(game));
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final json = jsonDecode(raw) as List<dynamic>;
      return json
          .cast<Map<String, dynamic>>()
          .map(SavedGen4Target.fromJson)
          .take(maxSavedGen4Targets)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveTargets(
    Gen4GameVersion game,
    List<SavedGen4Target> targets,
  ) {
    final json = targets
        .take(maxSavedGen4Targets)
        .map((target) => target.toJson())
        .toList(growable: false);
    return _store.setString(_targetsKey(game), jsonEncode(json));
  }

  static String _profileKey(Gen4GameVersion game, String field) {
    return 'profile.${game.jsonName}.$field';
  }

  static String _targetsKey(Gen4GameVersion game) {
    return 'targets.${game.jsonName}';
  }
}

List<int> _decodeIvList(String? raw, List<int> fallback) {
  if (raw == null || raw.isEmpty) {
    return List<int>.of(fallback);
  }
  try {
    final values = (jsonDecode(raw) as List<dynamic>).cast<int>();
    if (values.length != 6 || values.any((value) => value < 0 || value > 31)) {
      return List<int>.of(fallback);
    }
    return List<int>.of(values);
  } catch (_) {
    return List<int>.of(fallback);
  }
}

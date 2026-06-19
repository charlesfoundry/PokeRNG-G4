import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/gen4/gen4_timer.dart';
import '../../data/gen4/gen4_game.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/gen4_game_localizations.dart';
import '../app_chrome.dart';
import '../app_language.dart';
import '../app_profile.dart';

const _projectUrl = 'https://github.com/charlesfoundry/PokeRNG-G4';
const _privacyPolicyUrl =
    'https://github.com/charlesfoundry/PokeRNG-G4/blob/main/PRIVACY.md';
const _appLicense = 'GPL-3.0-only';
const _supportPurchaseChannel = MethodChannel('pokerng_g4/support_purchase');
const _supportProductIds = [
  'pokerngg4.support.snack',
  'pokerngg4.support.coffee',
  'pokerngg4.support.meal',
];

class _SupportProduct {
  const _SupportProduct({
    required this.id,
    required this.displayName,
    required this.price,
  });

  factory _SupportProduct.fromPlatform(Map<dynamic, dynamic> json) {
    return _SupportProduct(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      price: json['price'] as String,
    );
  }

  final String id;
  final String displayName;
  final String price;
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.language,
    required this.profile,
    required this.profiles,
    required this.onLanguageChanged,
    required this.onProfileChanged,
  });

  final AppLanguage language;
  final AppProfile profile;
  final Map<Gen4GameVersion, AppProfile> profiles;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final ValueChanged<AppProfile> onProfileChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AppLanguage _language = widget.language;
  late Gen4GameVersion _game = widget.profile.game;
  late final TextEditingController _tidController;
  late final TextEditingController _sidController;
  late final TextEditingController _calibratedDelayController;
  late final TextEditingController _idCalibratedDelayController;
  late final TextEditingController _eggCalibratedDelayController;
  late final TextEditingController _eggLockedPidController;
  late final TextEditingController _calibratedSecondController;
  late final TextEditingController _delayWindowController;
  late final TextEditingController _secondWindowController;
  late final TextEditingController _maxPhoneCallSkipController;
  late Gen4TimerConsole _timerConsole;
  late final TextEditingController _timerCustomFrameRateController;
  late final TextEditingController _timerMinimumLengthController;
  late bool _timerPrecisionCalibration;
  late Gen4PhoneCaller _phoneCaller;
  late final List<TextEditingController> _eggParentAControllers;
  late final List<TextEditingController> _eggParentBControllers;
  late bool _eggMasuda;
  String _appVersion = '-';
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _tidController = TextEditingController(text: widget.profile.tid.toString());
    _sidController = TextEditingController(text: widget.profile.sid.toString());
    _calibratedDelayController = TextEditingController(
      text: widget.profile.calibratedDelay.toString(),
    );
    _idCalibratedDelayController = TextEditingController(
      text: widget.profile.idCalibratedDelay.toString(),
    );
    _eggCalibratedDelayController = TextEditingController(
      text: widget.profile.eggCalibratedDelay.toString(),
    );
    _eggLockedPidController = TextEditingController(
      text: widget.profile.eggLockedPid,
    );
    _calibratedSecondController = TextEditingController(
      text: widget.profile.calibratedSecond.toString(),
    );
    _delayWindowController = TextEditingController(
      text: widget.profile.delayWindow.toString(),
    );
    _secondWindowController = TextEditingController(
      text: widget.profile.secondWindow.toString(),
    );
    _maxPhoneCallSkipController = TextEditingController(
      text: widget.profile.maxPhoneCallSkip.toString(),
    );
    _timerConsole = widget.profile.timerConsole;
    _timerCustomFrameRateController = TextEditingController(
      text: _formatFrameRate(widget.profile.timerCustomFrameRate),
    );
    _timerMinimumLengthController = TextEditingController(
      text: widget.profile.timerMinimumLengthSeconds.toString(),
    );
    _timerPrecisionCalibration = widget.profile.timerPrecisionCalibration;
    _phoneCaller = widget.profile.phoneCaller;
    _eggParentAControllers = _ivControllers(widget.profile.eggParentAIvs);
    _eggParentBControllers = _ivControllers(widget.profile.eggParentBIvs);
    _eggMasuda = widget.profile.eggMasuda;
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }
    setState(() {
      _appVersion = info.buildNumber.isEmpty
          ? info.version
          : '${info.version} (${info.buildNumber})';
    });
  }

  @override
  void didUpdateWidget(SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.language != oldWidget.language) {
      _language = widget.language;
    }
    if (widget.profile != oldWidget.profile) {
      _game = widget.profile.game;
      _setProfileFields(widget.profile);
    }
  }

  @override
  void dispose() {
    _tidController.dispose();
    _sidController.dispose();
    _calibratedDelayController.dispose();
    _idCalibratedDelayController.dispose();
    _eggCalibratedDelayController.dispose();
    _eggLockedPidController.dispose();
    _calibratedSecondController.dispose();
    _delayWindowController.dispose();
    _secondWindowController.dispose();
    _maxPhoneCallSkipController.dispose();
    _timerCustomFrameRateController.dispose();
    _timerMinimumLengthController.dispose();
    for (final controller in _eggParentAControllers) {
      controller.dispose();
    }
    for (final controller in _eggParentBControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      key: const ValueKey('settings-scroll'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _SectionHeader(icon: Icons.language, label: l10n.language),
        DropdownButtonFormField<AppLanguage>(
          key: ValueKey(_language),
          initialValue: _language,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.language,
            prefixIcon: const Icon(Icons.language),
          ),
          items: AppLanguage.values
              .map(
                (language) => DropdownMenuItem(
                  value: language,
                  child: Text(_languageLabel(l10n, language)),
                ),
              )
              .toList(growable: false),
          onChanged: (language) {
            if (language == null) {
              return;
            }
            setState(() => _language = language);
            widget.onLanguageChanged(language);
          },
        ),
        const SizedBox(height: 18),
        _SectionHeader(icon: Icons.videogame_asset, label: l10n.gameVersion),
        _GameVersionRow(
          key: const ValueKey('game-row-dppt'),
          games: const [
            Gen4GameVersion.pearl,
            Gen4GameVersion.diamond,
            Gen4GameVersion.platinum,
          ],
          selectedGame: _game,
          labelFor: (game) => gen4GameVersionLabel(l10n, game),
          onSelected: _selectGame,
        ),
        const SizedBox(height: 8),
        _GameVersionRow(
          key: const ValueKey('game-row-hgss'),
          games: const [Gen4GameVersion.heartGold, Gen4GameVersion.soulSilver],
          selectedGame: _game,
          labelFor: (game) => gen4GameVersionLabel(l10n, game),
          onSelected: _selectGame,
        ),
        const SizedBox(height: 18),
        _SectionHeader(icon: Icons.badge, label: l10n.trainerProfile),
        Row(
          key: const ValueKey('trainer-row'),
          children: [
            Expanded(
              child: TextField(
                controller: _tidController,
                decoration: InputDecoration(
                  labelText: l10n.trainerId,
                  prefixIcon: const Icon(Icons.badge),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: platformDigitOnlyInputFormatters(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _sidController,
                decoration: InputDecoration(
                  labelText: l10n.secretId,
                  prefixIcon: const Icon(Icons.fingerprint),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: platformDigitOnlyInputFormatters(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          key: const ValueKey('settings-save-row'),
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save),
            label: Text(l10n.save),
          ),
        ),
        _SettingsError(errorText: _errorText),
        const SizedBox(height: 22),
        _SectionHeader(icon: Icons.tune, label: l10n.settings),
        _SettingsEntryTile(
          icon: Icons.timer,
          title: l10n.timerDefaults,
          subtitle:
              '${l10n.timerCalibratedDelay} ${_calibratedDelayController.text} · '
              '${l10n.timerCalibratedSecond} ${_calibratedSecondController.text}',
          onTap: _openTimerDefaultsPage,
        ),
        const SizedBox(height: 8),
        _SettingsEntryTile(
          icon: Icons.badge_outlined,
          title: l10n.idRngSettings,
          subtitle:
              '${l10n.idRngCalibratedDelay} ${_idCalibratedDelayController.text}',
          onTap: _openIdRngSettingsPage,
        ),
        const SizedBox(height: 8),
        _SettingsEntryTile(
          icon: Icons.egg_alt_outlined,
          title: l10n.eggRngSettings,
          subtitle:
              '${l10n.eggRngCalibratedDelay} ${_eggCalibratedDelayController.text}',
          onTap: _openEggRngSettingsPage,
        ),
        const SizedBox(height: 8),
        _SettingsEntryTile(
          icon: Icons.egg_alt,
          title: l10n.eggParentsSettings,
          subtitle:
              '${l10n.eggParentA} ${_eggParentAControllers.map((c) => c.text).join('/')}',
          onTap: _openEggParentsSettingsPage,
        ),
        if (_supportsApplePurchases) ...[
          const SizedBox(height: 22),
          _SectionHeader(
            icon: Icons.favorite_border,
            label: l10n.supportDeveloper,
          ),
          _supportEntry(l10n),
        ],
        const SizedBox(height: 22),
        _aboutSection(l10n),
      ],
    );
  }

  bool get _supportsApplePurchases {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }

  void _openSupportPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const _SupportPage()));
  }

  Future<void> _openTimerDefaultsPage() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDetailState) {
              final l10n = AppLocalizations.of(context);
              return _SettingsDetailPage(
                title: l10n.timerDefaults,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _calibratedDelayController,
                          decoration: InputDecoration(
                            labelText: l10n.timerCalibratedDelay,
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: platformDigitOnlyInputFormatters(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _calibratedSecondController,
                          decoration: InputDecoration(
                            labelText: l10n.timerCalibratedSecond,
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: platformDigitOnlyInputFormatters(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _delayWindowController,
                          decoration: InputDecoration(
                            labelText: l10n.delayWindow,
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: platformDigitOnlyInputFormatters(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _secondWindowController,
                          decoration: InputDecoration(
                            labelText: l10n.secondWindow,
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          inputFormatters: platformDigitOnlyInputFormatters(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<Gen4TimerConsole>(
                    key: ValueKey(_timerConsole),
                    initialValue: _timerConsole,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.timerConsole),
                    items: Gen4TimerConsole.values
                        .map(
                          (console) => DropdownMenuItem(
                            value: console,
                            child: Text(_timerConsoleLabel(l10n, console)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (console) {
                      if (console == null) {
                        return;
                      }
                      setDetailState(() => _timerConsole = console);
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (_timerConsole == Gen4TimerConsole.custom) ...[
                        Expanded(
                          child: TextField(
                            controller: _timerCustomFrameRateController,
                            decoration: InputDecoration(
                              labelText: l10n.timerCustomFrameRate,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: TextField(
                          controller: _timerMinimumLengthController,
                          decoration: InputDecoration(
                            labelText: l10n.timerMinimumLength,
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          inputFormatters: platformDigitOnlyInputFormatters(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.timerPrecisionCalibration),
                    value: _timerPrecisionCalibration,
                    onChanged: (value) {
                      setDetailState(() => _timerPrecisionCalibration = value);
                    },
                  ),
                  if (_game.isHgss) ...[
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Gen4PhoneCaller>(
                      key: ValueKey(_phoneCaller),
                      initialValue: _phoneCaller,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.hgssPhoneCaller,
                      ),
                      items: Gen4PhoneCaller.values
                          .map(
                            (caller) => DropdownMenuItem(
                              value: caller,
                              child: Text(_phoneCallerLabel(l10n, caller)),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (caller) {
                        if (caller == null) {
                          return;
                        }
                        setDetailState(() => _phoneCaller = caller);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _maxPhoneCallSkipController,
                      decoration: InputDecoration(
                        labelText: l10n.maxPhoneCallSkip,
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: platformDigitOnlyInputFormatters(),
                    ),
                  ],
                  ..._settingsSaveControls(setDetailState),
                ],
              );
            },
          );
        },
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openIdRngSettingsPage() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDetailState) {
              final l10n = AppLocalizations.of(context);
              return _SettingsDetailPage(
                title: l10n.idRngSettings,
                children: [
                  TextField(
                    controller: _idCalibratedDelayController,
                    decoration: InputDecoration(
                      labelText: l10n.idRngCalibratedDelay,
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: platformDigitOnlyInputFormatters(),
                  ),
                  ..._settingsSaveControls(setDetailState),
                ],
              );
            },
          );
        },
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openEggRngSettingsPage() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDetailState) {
              final l10n = AppLocalizations.of(context);
              return _SettingsDetailPage(
                title: l10n.eggRngSettings,
                children: [
                  TextField(
                    controller: _eggCalibratedDelayController,
                    decoration: InputDecoration(
                      labelText: l10n.eggRngCalibratedDelay,
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: platformDigitOnlyInputFormatters(),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _eggLockedPidController,
                    decoration: InputDecoration(labelText: l10n.eggLockedPid),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                  ),
                  ..._settingsSaveControls(setDetailState),
                ],
              );
            },
          );
        },
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openEggParentsSettingsPage() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDetailState) {
              final l10n = AppLocalizations.of(context);
              return _SettingsDetailPage(
                title: l10n.eggParentsSettings,
                children: [
                  _SettingsIvGrid(
                    title: l10n.eggParentA,
                    controllers: _eggParentAControllers,
                  ),
                  const SizedBox(height: 10),
                  _SettingsIvGrid(
                    title: l10n.eggParentB,
                    controllers: _eggParentBControllers,
                  ),
                  const SizedBox(height: 6),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.eggMasuda),
                    value: _eggMasuda,
                    onChanged: (value) {
                      setDetailState(() => _eggMasuda = value);
                    },
                  ),
                  ..._settingsSaveControls(setDetailState),
                ],
              );
            },
          );
        },
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  List<Widget> _settingsSaveControls(StateSetter setDetailState) {
    final l10n = AppLocalizations.of(context);
    return [
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            _saveProfile();
            setDetailState(() {});
          },
          icon: const Icon(Icons.save),
          label: Text(l10n.save),
        ),
      ),
      _SettingsError(errorText: _errorText),
    ];
  }

  void _copyProjectUrl() {
    Clipboard.setData(const ClipboardData(text: _projectUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).projectUrlCopied)),
    );
  }

  Widget _aboutSection(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(icon: Icons.info_outline, label: l10n.about),
        Surface(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PokeRNG G4', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(l10n.aboutDescription),
                const SizedBox(height: 4),
                Text(l10n.unofficialNotice, style: theme.textTheme.labelMedium),
                const SizedBox(height: 14),
                _aboutRow(l10n.version, _appVersion),
                _aboutRow(l10n.license, _appLicense),
                _aboutRow(l10n.project, _projectUrl, selectable: true),
                _aboutRow(
                  l10n.privacyPolicy,
                  _privacyPolicyUrl,
                  selectable: true,
                ),
                const SizedBox(height: 10),
                Text(l10n.credits, style: theme.textTheme.labelLarge),
                const SizedBox(height: 6),
                Text(l10n.aboutCredits),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _copyProjectUrl,
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.copyProjectUrl),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _supportEntry(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Surface(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Icon(Icons.favorite_border, color: theme.colorScheme.primary),
        title: Text(l10n.supportDeveloper),
        subtitle: Text(l10n.supportNoUnlock),
        trailing: const Icon(Icons.chevron_right),
        onTap: _openSupportPage,
      ),
    );
  }

  Widget _aboutRow(String label, String value, {bool selectable = false}) {
    final theme = Theme.of(context);
    final valueStyle = theme.textTheme.bodyMedium;
    final valueWidget = selectable
        ? SelectableText(value, style: valueStyle)
        : Text(value, style: valueStyle);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
          ),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  void _selectGame(Gen4GameVersion game) {
    final profile = widget.profiles[game] ?? AppProfile.defaultsFor(game);
    setState(() {
      _game = game;
      _errorText = null;
      _setProfileFields(profile);
    });
  }

  void _saveProfile() {
    final l10n = AppLocalizations.of(context);
    final profile = _buildProfile(l10n);
    if (profile == null) {
      return;
    }

    setState(() => _errorText = null);
    widget.onProfileChanged(profile);
  }

  void _setProfileFields(AppProfile profile) {
    _tidController.text = profile.tid.toString();
    _sidController.text = profile.sid.toString();
    _calibratedDelayController.text = profile.calibratedDelay.toString();
    _idCalibratedDelayController.text = profile.idCalibratedDelay.toString();
    _eggCalibratedDelayController.text = profile.eggCalibratedDelay.toString();
    _eggLockedPidController.text = profile.eggLockedPid;
    _calibratedSecondController.text = profile.calibratedSecond.toString();
    _delayWindowController.text = profile.delayWindow.toString();
    _secondWindowController.text = profile.secondWindow.toString();
    _maxPhoneCallSkipController.text = profile.maxPhoneCallSkip.toString();
    _timerConsole = profile.timerConsole;
    _timerCustomFrameRateController.text = _formatFrameRate(
      profile.timerCustomFrameRate,
    );
    _timerMinimumLengthController.text = profile.timerMinimumLengthSeconds
        .toString();
    _timerPrecisionCalibration = profile.timerPrecisionCalibration;
    _phoneCaller = profile.phoneCaller;
    _setIvControllers(_eggParentAControllers, profile.eggParentAIvs);
    _setIvControllers(_eggParentBControllers, profile.eggParentBIvs);
    _eggMasuda = profile.eggMasuda;
  }

  AppProfile? _buildProfile(AppLocalizations l10n) {
    final tid = int.tryParse(_tidController.text.trim());
    final sid = int.tryParse(_sidController.text.trim());
    if (tid == null || sid == null || tid > 65535 || sid > 65535) {
      setState(() => _errorText = l10n.settingsInputError);
      return null;
    }

    final calibratedDelay = int.tryParse(
      _calibratedDelayController.text.trim(),
    );
    final idCalibratedDelay = int.tryParse(
      _idCalibratedDelayController.text.trim(),
    );
    final eggCalibratedDelay = int.tryParse(
      _eggCalibratedDelayController.text.trim(),
    );
    final calibratedSecond = int.tryParse(
      _calibratedSecondController.text.trim(),
    );
    final delayWindow = int.tryParse(_delayWindowController.text.trim());
    final secondWindow = int.tryParse(_secondWindowController.text.trim());
    final maxPhoneCallSkip = int.tryParse(
      _maxPhoneCallSkipController.text.trim(),
    );
    final customFrameRate = double.tryParse(
      _timerCustomFrameRateController.text.trim(),
    );
    final minimumLength = int.tryParse(
      _timerMinimumLengthController.text.trim(),
    );
    if (calibratedDelay == null ||
        idCalibratedDelay == null ||
        eggCalibratedDelay == null ||
        calibratedSecond == null ||
        delayWindow == null ||
        secondWindow == null ||
        maxPhoneCallSkip == null ||
        customFrameRate == null ||
        minimumLength == null ||
        calibratedDelay < 0 ||
        idCalibratedDelay < 0 ||
        eggCalibratedDelay < 0 ||
        calibratedSecond < 0 ||
        calibratedSecond > 59 ||
        delayWindow < 0 ||
        secondWindow < 0 ||
        secondWindow > 59 ||
        maxPhoneCallSkip < 0 ||
        maxPhoneCallSkip > 999 ||
        calibratedDelay - delayWindow < 0 ||
        customFrameRate <= 0 ||
        minimumLength <= 0) {
      setState(() => _errorText = l10n.settingsTimerInputError);
      return null;
    }
    final eggParentAIvs = _parseIvs(_eggParentAControllers);
    final eggParentBIvs = _parseIvs(_eggParentBControllers);
    if (eggParentAIvs == null || eggParentBIvs == null) {
      setState(() => _errorText = l10n.settingsEggParentInputError);
      return null;
    }
    final eggLockedPid = _normalizeOptionalHex32(_eggLockedPidController.text);
    if (eggLockedPid == null) {
      setState(() => _errorText = l10n.settingsEggLockedPidInputError);
      return null;
    }

    return AppProfile(
      game: _game,
      tid: tid,
      sid: sid,
      calibratedDelay: calibratedDelay,
      idCalibratedDelay: idCalibratedDelay,
      eggCalibratedDelay: eggCalibratedDelay,
      calibratedSecond: calibratedSecond,
      delayWindow: delayWindow,
      secondWindow: secondWindow,
      maxPhoneCallSkip: maxPhoneCallSkip,
      timerConsole: _timerConsole,
      timerCustomFrameRate: customFrameRate,
      timerMinimumLengthSeconds: minimumLength,
      timerPrecisionCalibration: _timerPrecisionCalibration,
      phoneCaller: _phoneCaller,
      eggParentAIvs: eggParentAIvs,
      eggParentBIvs: eggParentBIvs,
      eggMasuda: _eggMasuda,
      eggLockedPid: eggLockedPid,
    );
  }
}

class _SupportPage extends StatefulWidget {
  const _SupportPage();

  @override
  State<_SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<_SupportPage> {
  List<_SupportProduct> _products = const [];
  bool _loading = false;
  bool _purchasing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (_loading) {
      return;
    }
    if (kIsWeb) {
      setState(() {
        _products = const [];
        _error = AppLocalizations.of(context).supportUnavailable;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await _supportPurchaseChannel
          .invokeMethod<List<dynamic>>('products', {'ids': _supportProductIds});
      final parsed = (products ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map(_SupportProduct.fromPlatform)
          .toList(growable: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _products = parsed;
        _error = parsed.isEmpty
            ? AppLocalizations.of(context).supportUnavailable
            : null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _products = const [];
        _error = AppLocalizations.of(context).supportUnavailable;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _buy(_SupportProduct product) async {
    if (_purchasing) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() => _purchasing = true);
    try {
      final status = await _supportPurchaseChannel.invokeMethod<String>(
        'purchase',
        {'id': product.id},
      );
      if (!mounted) {
        return;
      }
      final message = switch (status) {
        'success' => l10n.supportThanks,
        'pending' => l10n.supportPending,
        'cancelled' => l10n.supportCancelled,
        _ => l10n.supportFailed,
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.supportFailed)));
    } finally {
      if (mounted) {
        setState(() => _purchasing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportDeveloper)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.supportDescription, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(l10n.supportNoUnlock, style: theme.textTheme.labelMedium),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_products.isEmpty) ...[
            Surface(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error ?? l10n.supportUnavailable),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ] else
            ..._products.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Surface(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    leading: Icon(
                      Icons.favorite_border,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(product.displayName),
                    subtitle: Text(product.price),
                    trailing: const Icon(Icons.chevron_right),
                    enabled: !_purchasing,
                    onTap: _purchasing ? null : () => _buy(product),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

List<TextEditingController> _ivControllers(List<int> ivs) {
  return [
    for (var i = 0; i < 6; i += 1)
      TextEditingController(text: (i < ivs.length ? ivs[i] : 31).toString()),
  ];
}

void _setIvControllers(List<TextEditingController> controllers, List<int> ivs) {
  for (var i = 0; i < controllers.length; i += 1) {
    controllers[i].text = (i < ivs.length ? ivs[i] : 31).toString();
  }
}

List<int>? _parseIvs(List<TextEditingController> controllers) {
  final ivs = <int>[];
  for (final controller in controllers) {
    final iv = int.tryParse(controller.text.trim());
    if (iv == null || iv < 0 || iv > 31) {
      return null;
    }
    ivs.add(iv);
  }
  return ivs;
}

String? _normalizeOptionalHex32(String value) {
  final normalized = value.trim().replaceFirst(RegExp('^0x'), '');
  if (normalized.isEmpty) {
    return '';
  }
  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null || parsed < 0 || parsed > 0xffffffff) {
    return null;
  }
  return parsed.toRadixString(16).padLeft(8, '0').toUpperCase();
}

class _SettingsIvGrid extends StatelessWidget {
  const _SettingsIvGrid({required this.title, required this.controllers});

  final String title;
  final List<TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.hpStat,
      l10n.atkStat,
      l10n.defStat,
      l10n.spaStat,
      l10n.spdStat,
      l10n.speStat,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 10) / 3;
            return Wrap(
              spacing: 5,
              runSpacing: 6,
              children: [
                for (var i = 0; i < controllers.length; i += 1)
                  SizedBox(
                    width: width,
                    child: TextField(
                      controller: controllers[i],
                      decoration: InputDecoration(labelText: labels[i]),
                      keyboardType: TextInputType.number,
                      textInputAction: i == controllers.length - 1
                          ? TextInputAction.done
                          : TextInputAction.next,
                      inputFormatters: platformDigitOnlyInputFormatters(),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

String _formatFrameRate(double value) {
  final text = value.toStringAsFixed(4);
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

String _timerConsoleLabel(AppLocalizations l10n, Gen4TimerConsole console) {
  return switch (console) {
    Gen4TimerConsole.gba => l10n.timerConsoleGba,
    Gen4TimerConsole.ndsSlot1 => l10n.timerConsoleNdsSlot1,
    Gen4TimerConsole.ndsSlot2 => l10n.timerConsoleNdsSlot2,
    Gen4TimerConsole.dsi => l10n.timerConsoleDsi,
    Gen4TimerConsole.threeDs => l10n.timerConsole3ds,
    Gen4TimerConsole.custom => l10n.timerConsoleCustom,
  };
}

String _phoneCallerLabel(AppLocalizations l10n, Gen4PhoneCaller caller) {
  return switch (caller) {
    Gen4PhoneCaller.elm => l10n.phoneCallerElm,
    Gen4PhoneCaller.irwin => l10n.phoneCallerIrwin,
  };
}

class _SettingsEntryTile extends StatelessWidget {
  const _SettingsEntryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Surface(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SettingsDetailPage extends StatelessWidget {
  const _SettingsDetailPage({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: children,
      ),
    );
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.errorText});

  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final text = errorText;
    if (text == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label, style: textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _GameVersionRow extends StatelessWidget {
  const _GameVersionRow({
    super.key,
    required this.games,
    required this.selectedGame,
    required this.labelFor,
    required this.onSelected,
  });

  final List<Gen4GameVersion> games;
  final Gen4GameVersion selectedGame;
  final String Function(Gen4GameVersion game) labelFor;
  final ValueChanged<Gen4GameVersion> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = games.contains(selectedGame)
        ? <Gen4GameVersion>{selectedGame}
        : <Gen4GameVersion>{};
    return LayoutBuilder(
      builder: (context, constraints) {
        final rowWidth = constraints.maxWidth;
        final segmentWidth = rowWidth / games.length;
        return SizedBox(
          width: double.infinity,
          child: SegmentedButton<Gen4GameVersion>(
            segments: games
                .map(
                  (game) =>
                      ButtonSegment(value: game, label: Text(labelFor(game))),
                )
                .toList(growable: false),
            selected: selected,
            onSelectionChanged: (selection) {
              if (selection.isEmpty) {
                return;
              }
              onSelected(selection.single);
            },
            multiSelectionEnabled: false,
            emptySelectionAllowed: true,
            showSelectedIcon: false,
            style: ButtonStyle(
              fixedSize: WidgetStatePropertyAll(Size(segmentWidth, 38)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 6),
              ),
            ),
          ),
        );
      },
    );
  }
}

String _languageLabel(AppLocalizations l10n, AppLanguage language) {
  return switch (language) {
    AppLanguage.system => l10n.languageSystem,
    AppLanguage.english => l10n.languageEnglish,
    AppLanguage.japanese => l10n.languageJapanese,
    AppLanguage.chinese => l10n.languageChinese,
  };
}

import 'package:flutter/material.dart';

import 'app_language.dart';
import 'app_page.dart';
import 'app_profile.dart';
import 'app_storage.dart';
import 'gen4_time_finder_job.dart';
import 'saved_targets.dart';
import 'search_results.dart';
import 'pages/calibrate_page.dart';
import 'pages/egg_router_page.dart';
import 'pages/id_rng_page.dart';
import 'pages/results_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'pages/tools_page.dart';
import '../data/gen4/gen4_game.dart';
import '../l10n/app_localizations.dart';
import '../l10n/gen4_game_localizations.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.language,
    required this.profile,
    required this.profiles,
    required this.storage,
    required this.onLanguageChanged,
    required this.onProfileChanged,
  });

  final AppLanguage language;
  final AppProfile profile;
  final Map<Gen4GameVersion, AppProfile> profiles;
  final AppStorage storage;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final ValueChanged<AppProfile> onProfileChanged;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  Gen4SearchResultsSnapshot _resultsSnapshot =
      const Gen4SearchResultsSnapshot.idle();
  Gen4TimeFinderJob? _searchJob;
  Gen4SearchResultRow? _calibrationTarget;
  List<SavedGen4Target> _savedTargets = const [];
  Gen4GameVersion? _loadedTargetsGame;
  var _targetLoadEpoch = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedTargetsIfNeeded(force: true);
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.game != widget.profile.game) {
      _loadSavedTargetsIfNeeded(force: true);
    }
  }

  @override
  void dispose() {
    _searchJob?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 860;
    final pages = [
      SearchPage(
        profile: widget.profile,
        isSearching: _resultsSnapshot.isRunning,
        onSearch: _startSearch,
      ),
      ResultsPage(
        snapshot: _resultsSnapshot,
        onCancelSearch: _searchJob == null ? null : _cancelSearch,
        onSendToCalibration: _sendToCalibration,
        onSaveTarget: _saveTarget,
      ),
      CalibratePage(
        profile: widget.profile,
        target: _calibrationTarget,
        onProfileChanged: widget.onProfileChanged,
      ),
      EggRouterPage(
        profile: widget.profile,
        onProfileChanged: widget.onProfileChanged,
      ),
      IdRngPage(
        profile: widget.profile,
        onProfileChanged: widget.onProfileChanged,
      ),
      ToolsPage(
        savedTargets: _savedTargets,
        onUseTarget: (target) => _sendToCalibration(target.result),
        onDeleteTarget: _deleteTarget,
      ),
      SettingsPage(
        language: widget.language,
        profile: widget.profile,
        profiles: widget.profiles,
        onLanguageChanged: widget.onLanguageChanged,
        onProfileChanged: widget.onProfileChanged,
      ),
    ];
    final pageStack = IndexedStack(index: _selectedIndex, children: pages);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: Center(
              child: Text(
                '${gen4GameVersionLabel(l10n, widget.profile.game)} · '
                '${widget.profile.tid}/${widget.profile.sid}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: wide
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _selectPage,
                    labelType: NavigationRailLabelType.all,
                    destinations: appPages
                        .map(
                          (page) => NavigationRailDestination(
                            icon: Icon(pageIcon(page)),
                            label: Text(pageLabel(l10n, page)),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: pageStack),
                ],
              )
            : pageStack,
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectPage,
              destinations: appPages
                  .map(
                    (page) => NavigationDestination(
                      icon: Icon(pageIcon(page)),
                      label: pageLabel(l10n, page),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }

  void _selectPage(int index) {
    setState(() => _selectedIndex = index);
  }

  void _cancelSearch() {
    _searchJob?.cancel();
    setState(() {
      _searchJob = null;
      _resultsSnapshot = _resultsSnapshot.cancelled();
    });
  }

  void _sendToCalibration(Gen4SearchResultRow result) {
    setState(() {
      _calibrationTarget = result;
      _selectedIndex = appPages.indexOf(AppPage.calibrate);
    });
  }

  void _loadSavedTargetsIfNeeded({bool force = false}) {
    final game = widget.profile.game;
    if (!force && _loadedTargetsGame == game) {
      return;
    }
    final previousGame = _loadedTargetsGame;
    _loadedTargetsGame = game;
    if (previousGame != null && previousGame != game) {
      setState(() {
        _savedTargets = const [];
      });
    }
    final epoch = _targetLoadEpoch + 1;
    _targetLoadEpoch = epoch;
    _loadSavedTargets(epoch: epoch, game: game);
  }

  Future<void> _loadSavedTargets({
    required int epoch,
    required Gen4GameVersion game,
  }) async {
    final targets = await widget.storage.loadTargets(game);
    if (!mounted || epoch != _targetLoadEpoch) {
      return;
    }
    setState(() {
      _savedTargets = targets;
    });
  }

  Future<void> _saveTarget(Gen4SearchResultRow result) async {
    final l10n = AppLocalizations.of(context);
    final game = widget.profile.game;
    final target = SavedGen4Target(
      id: DateTime.now().microsecondsSinceEpoch,
      savedAt: DateTime.now(),
      result: result,
    );
    final duplicate = _savedTargets.any(
      (saved) => saved.duplicateKey == target.duplicateKey,
    );
    if (duplicate) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.targetAlreadySaved)));
      return;
    }
    final nextTargets = [
      target,
      ..._savedTargets,
    ].take(maxSavedGen4Targets).toList(growable: false);
    setState(() {
      _savedTargets = nextTargets;
    });
    await widget.storage.saveTargets(game, nextTargets);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.targetSaved)));
  }

  Future<void> _deleteTarget(SavedGen4Target target) async {
    final game = widget.profile.game;
    final nextTargets = _savedTargets
        .where((saved) => saved.id != target.id)
        .toList(growable: false);
    setState(() {
      _savedTargets = nextTargets;
    });
    await widget.storage.saveTargets(game, nextTargets);
  }

  void _startSearch(Gen4TimeFinderRequest request) {
    _searchJob?.cancel();
    Gen4TimeFinderJob? job;
    job = Gen4TimeFinderJob.start(
      request: request,
      onProgress: (progress) {
        if (!mounted || job != _searchJob) {
          return;
        }
        setState(() {
          _resultsSnapshot = Gen4SearchResultsSnapshot.running(
            progress: progress,
          );
        });
      },
      onComplete: (result) {
        if (!mounted || job != _searchJob) {
          return;
        }
        setState(() {
          _searchJob = null;
          _resultsSnapshot = Gen4SearchResultsSnapshot.completed(
            results: result.results,
            progress: result.progress,
            resultLimitReached: result.resultLimitReached,
          );
        });
      },
      onError: (error) {
        if (!mounted || job != _searchJob) {
          return;
        }
        setState(() {
          _searchJob = null;
          _resultsSnapshot = Gen4SearchResultsSnapshot.failed(error: error);
        });
      },
    );
    setState(() {
      _searchJob = job;
      _selectedIndex = 1;
      _resultsSnapshot = Gen4SearchResultsSnapshot.running(
        progress: Gen4SearchProgress(
          scanned: 0,
          total: request.totalProgressUnits,
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum AppPage { target, search, egg, results, calibrate, idRng, tools, settings }

const appPages = [
  AppPage.search,
  AppPage.results,
  AppPage.calibrate,
  AppPage.egg,
  AppPage.idRng,
  AppPage.tools,
  AppPage.settings,
];

IconData pageIcon(AppPage page) {
  return switch (page) {
    AppPage.target => Icons.catching_pokemon,
    AppPage.search => Icons.search,
    AppPage.egg => Icons.egg_alt_outlined,
    AppPage.results => Icons.list_alt,
    AppPage.calibrate => Icons.tune,
    AppPage.idRng => Icons.badge_outlined,
    AppPage.tools => Icons.build,
    AppPage.settings => Icons.settings,
  };
}

String pageLabel(AppLocalizations l10n, AppPage page) {
  return switch (page) {
    AppPage.target => l10n.target,
    AppPage.search => l10n.search,
    AppPage.egg => l10n.egg,
    AppPage.results => l10n.results,
    AppPage.calibrate => l10n.calibrate,
    AppPage.idRng => l10n.idRng,
    AppPage.tools => l10n.tools,
    AppPage.settings => l10n.settings,
  };
}

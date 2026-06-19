import '../data/gen4/gen4_game.dart';
import 'app_localizations.dart';

String gen4GameVersionLabel(AppLocalizations l10n, Gen4GameVersion game) {
  return switch (game) {
    Gen4GameVersion.diamond => l10n.gameDiamond,
    Gen4GameVersion.pearl => l10n.gamePearl,
    Gen4GameVersion.platinum => l10n.gamePlatinum,
    Gen4GameVersion.heartGold => l10n.gameHeartGold,
    Gen4GameVersion.soulSilver => l10n.gameSoulSilver,
  };
}

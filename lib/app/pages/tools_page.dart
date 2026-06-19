import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../saved_targets.dart';
import '../search_results.dart';
import 'tutorials_page.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({
    required this.savedTargets,
    required this.onUseTarget,
    required this.onDeleteTarget,
    super.key,
  });

  final List<SavedGen4Target> savedTargets;
  final ValueChanged<SavedGen4Target> onUseTarget;
  final ValueChanged<SavedGen4Target> onDeleteTarget;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.savedTargets,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Text(
              '${savedTargets.length}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (savedTargets.isEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(l10n.noSavedTargets),
            ),
          )
        else
          for (final target in savedTargets) ...[
            _SavedTargetTile(
              target: target,
              onUse: () => onUseTarget(target),
              onDelete: () => onDeleteTarget(target),
            ),
            const SizedBox(height: 8),
          ],
        const SizedBox(height: 20),
        Text(l10n.helpSection, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _TutorialEntryCard(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const TutorialsPage()),
            );
          },
        ),
      ],
    );
  }
}

class _TutorialEntryCard extends StatelessWidget {
  const _TutorialEntryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 4),
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(l10n.tutorialsTitle),
            subtitle: Text(l10n.tutorialsOpen),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}

class _SavedTargetTile extends StatelessWidget {
  const _SavedTargetTile({
    required this.target,
    required this.onUse,
    required this.onDelete,
  });

  final SavedGen4Target target;
  final VoidCallback onUse;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final result = target.result;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onUse,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsetsDirectional.only(start: 12, end: 4),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    result.target,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (result.shiny) const _ShinyIcon(),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.seed} ${result.seed} · '
                  '${l10n.delay} ${result.delay} · '
                  '${l10n.advance} ${result.advance} · '
                  '${l10n.levelShort} ${_levelValue(result)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${l10n.ivs} ${result.ivs}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: IconButton(
              tooltip: l10n.deleteTarget,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShinyIcon extends StatelessWidget {
  const _ShinyIcon();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Tooltip(
        message: AppLocalizations.of(context).shiny,
        child: Icon(
          Icons.auto_awesome,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

String _levelValue(Gen4SearchResultRow result) {
  final level = result.level;
  return level == null ? '-' : '$level';
}

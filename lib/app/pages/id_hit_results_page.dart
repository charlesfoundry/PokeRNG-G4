import 'package:flutter/material.dart';

import '../../core/gen4/gen4.dart';
import '../../l10n/app_localizations.dart';

class IdHitResultsPage extends StatelessWidget {
  const IdHitResultsPage({super.key, required this.hits});

  final List<Gen4IdHit> hits;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.idRngHitResults)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        children: [
          Text(
            l10n.resultCount(hits.length.toString()),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          for (final hit in hits) ...[
            _IdHitCard(hit: hit),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _IdHitCard extends StatelessWidget {
  const _IdHitCard({required this.hit});

  final Gen4IdHit hit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = hit.state;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(hit),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Text('${l10n.seed}: ${_seedHex(state.seed)}'),
                Text('${l10n.delay}: ${state.delay}'),
                Text('${l10n.second}: ${hit.seedTime.dateTime.second}'),
                Text('${l10n.trainerId}: ${_padId(state.tid)}'),
                Text('${l10n.secretId}: ${_padId(state.sid)}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _seedHex(int seed) {
  return seed.toRadixString(16).padLeft(8, '0').toUpperCase();
}

String _padId(int value) {
  return value.toString().padLeft(5, '0');
}

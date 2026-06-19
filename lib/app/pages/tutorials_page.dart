import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../l10n/app_localizations.dart';

class TutorialsPage extends StatelessWidget {
  const TutorialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = _tutorialSections(l10n);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tutorialsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        children: [
          const SizedBox(height: 4),
          _TutorialNoticeCard(
            title: l10n.tutorialNoticeTitle,
            body: l10n.tutorialNoticeBody,
          ),
          const SizedBox(height: 4),
          for (final section in sections) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 12, 2, 8),
              child: Text(
                section.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final topic in section.topics) ...[
              _TutorialTile(topic: topic),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _TutorialNoticeCard extends StatelessWidget {
  const _TutorialNoticeCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _TutorialDetailPage extends StatelessWidget {
  const _TutorialDetailPage({required this.topic});

  final _TutorialTopic topic;

  @override
  Widget build(BuildContext context) {
    final locale = _tutorialLocale(context);
    final path = 'assets/tutorials/$locale/${topic.assetName}.md';
    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(path),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(AppLocalizations.of(context).searchFailed),
              ),
            );
          }
          return Markdown(
            data: snapshot.data!,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            styleSheet: _markdownStyle(context),
          );
        },
      ),
    );
  }
}

class _TutorialTile extends StatelessWidget {
  const _TutorialTile({required this.topic});

  final _TutorialTopic topic;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _TutorialDetailPage(topic: topic),
            ),
          );
        },
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
            title: Text(topic.title),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}

MarkdownStyleSheet _markdownStyle(BuildContext context) {
  final theme = Theme.of(context);
  final textTheme = theme.textTheme;
  return MarkdownStyleSheet.fromTheme(theme).copyWith(
    h1: textTheme.titleLarge?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    h2: textTheme.titleMedium?.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    h3: textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    p: textTheme.bodyMedium?.copyWith(height: 1.45),
    listBullet: textTheme.bodyMedium?.copyWith(height: 1.45),
    blockSpacing: 12,
    listIndent: 24,
  );
}

String _tutorialLocale(BuildContext context) {
  return switch (Localizations.localeOf(context).languageCode) {
    'zh' => 'zh',
    'ja' => 'ja',
    _ => 'en',
  };
}

List<_TutorialSection> _tutorialSections(AppLocalizations l10n) {
  return [
    _TutorialSection(
      title: l10n.tutorialCategoryIntroduction,
      topics: [
        _TutorialTopic(
          title: l10n.rngBeginnerHelpTitle,
          assetName: 'rng_beginner',
        ),
        _TutorialTopic(
          title: l10n.gen4RngPrinciplesHelpTitle,
          assetName: 'gen4_rng_principles',
        ),
      ],
    ),
    _TutorialSection(
      title: l10n.tutorialCategoryBasics,
      topics: [
        _TutorialTopic(
          title: l10n.delayParityHelpTitle,
          assetName: 'delay_parity',
        ),
        _TutorialTopic(title: l10n.timerTimingHelpTitle, assetName: 'timer'),
        _TutorialTopic(
          title: l10n.leadAbilityHelpTitle,
          assetName: 'lead_ability',
        ),
        _TutorialTopic(title: l10n.chatotAdvanceHelpTitle, assetName: 'chatot'),
      ],
    ),
    _TutorialSection(
      title: l10n.tutorialCategoryId,
      topics: [
        _TutorialTopic(
          title: l10n.platinumIdRngHelpTitle,
          assetName: 'platinum_id_rng',
        ),
      ],
    ),
    _TutorialSection(
      title: l10n.tutorialCategoryStarter,
      topics: [
        _TutorialTopic(
          title: l10n.platinumStarterHelpTitle,
          assetName: 'platinum_starter',
        ),
      ],
    ),
    _TutorialSection(
      title: l10n.tutorialCategoryStationary,
      topics: [
        _TutorialTopic(
          title: l10n.hgssStationaryHelpTitle,
          assetName: 'hgss_stationary',
        ),
        _TutorialTopic(title: l10n.honeyTreeHelpTitle, assetName: 'honey_tree'),
      ],
    ),
    _TutorialSection(
      title: l10n.tutorialCategoryWild,
      topics: [
        _TutorialTopic(
          title: l10n.wildSweetScentHelpTitle,
          assetName: 'wild_sweet_scent',
        ),
      ],
    ),
    _TutorialSection(
      title: l10n.tutorialCategoryEgg,
      topics: [
        _TutorialTopic(title: l10n.eggHeldHelpTitle, assetName: 'egg_held'),
        _TutorialTopic(title: l10n.eggPickupHelpTitle, assetName: 'egg_pickup'),
      ],
    ),
  ];
}

class _TutorialSection {
  const _TutorialSection({required this.title, required this.topics});

  final String title;
  final List<_TutorialTopic> topics;
}

class _TutorialTopic {
  const _TutorialTopic({required this.title, required this.assetName});

  final String title;
  final String assetName;
}

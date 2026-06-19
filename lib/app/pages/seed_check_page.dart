import 'package:flutter/material.dart';

import '../../core/gen4/gen4.dart';
import '../../l10n/app_localizations.dart';
import '../app_profile.dart';

enum Gen4SeedCheckMode { coinFlips, phoneCalls }

class Gen4SeedCheckRequest {
  const Gen4SeedCheckRequest({
    required this.target,
    required this.delayWindow,
    required this.secondWindow,
    required this.mode,
    this.targetAdvance,
    this.advanceOffset = 0,
    this.phoneCaller = Gen4PhoneCaller.elm,
    this.minPhoneCallSkip = 0,
    this.maxPhoneCallSkip = 30,
  });

  final Gen4SeedTime target;
  final int delayWindow;
  final int secondWindow;
  final Gen4SeedCheckMode mode;
  final int? targetAdvance;
  final int advanceOffset;
  final Gen4PhoneCaller phoneCaller;
  final int minPhoneCallSkip;
  final int maxPhoneCallSkip;

  int? get adjustedTargetAdvance {
    final advance = targetAdvance;
    if (advance == null) {
      return null;
    }
    final adjusted = advance - advanceOffset;
    return adjusted < 0 ? 0 : adjusted;
  }
}

class SeedCheckPage extends StatefulWidget {
  const SeedCheckPage({super.key, required this.request});

  final Gen4SeedCheckRequest request;

  @override
  State<SeedCheckPage> createState() => _SeedCheckPageState();
}

class _SeedCheckPageState extends State<SeedCheckPage> {
  late Gen4SeedCheckMode _mode;
  final _coinFlips = <CoinFlip>[];
  final _phoneCalls = <PhoneCall>[];
  int? _calibratedAdvanceOffset;
  int _manualAdvances = 0;

  @override
  void initState() {
    super.initState();
    _mode = widget.request.mode;
  }

  int get _activeSequenceLength {
    return switch (_mode) {
      Gen4SeedCheckMode.coinFlips => _coinFlips.length,
      Gen4SeedCheckMode.phoneCalls => _phoneCalls.length,
    };
  }

  int get _verificationAdvanceCost {
    return switch (_mode) {
      Gen4SeedCheckMode.coinFlips => 0,
      Gen4SeedCheckMode.phoneCalls => _phoneCalls.length,
    };
  }

  int get _activeAdvanceOffset {
    return _calibratedAdvanceOffset ?? widget.request.advanceOffset;
  }

  int? get _remainingAdvances {
    final targetAdvance = widget.request.targetAdvance;
    if (targetAdvance == null || _calibratedAdvanceOffset == null) {
      return null;
    }
    final remaining =
        targetAdvance -
        _activeAdvanceOffset -
        _verificationAdvanceCost -
        _manualAdvances;
    return remaining < 0 ? 0 : remaining;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final matches = _searchMatches();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.seedSearchTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        children: [
          SegmentedButton<Gen4SeedCheckMode>(
            segments: [
              ButtonSegment(
                value: Gen4SeedCheckMode.coinFlips,
                label: Text(l10n.calibrateCoinFlips),
              ),
              ButtonSegment(
                value: Gen4SeedCheckMode.phoneCalls,
                label: Text(l10n.calibratePhoneCalls),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) {
              setState(() {
                _mode = selection.single;
                _coinFlips.clear();
                _phoneCalls.clear();
                _calibratedAdvanceOffset = null;
                _manualAdvances = 0;
              });
            },
          ),
          const SizedBox(height: 12),
          Text(
            l10n.calibrateObservedSequence,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          if (_mode == Gen4SeedCheckMode.phoneCalls) ...[
            const SizedBox(height: 4),
            Text(
              l10n.calibratePhoneCallerHelp(
                _phoneCallerLabel(l10n, widget.request.phoneCaller),
              ),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
          const SizedBox(height: 8),
          _VerificationButtons(
            mode: _mode,
            phoneCaller: widget.request.phoneCaller,
            onCoinFlip: _addCoinFlip,
            onPhoneCall: _addPhoneCall,
          ),
          if (_calibratedAdvanceOffset != null &&
              widget.request.targetAdvance != null) ...[
            const SizedBox(height: 10),
            _AdvancePlanPanel(
              request: widget.request,
              advanceOffset: _activeAdvanceOffset,
              verificationAdvanceCost: _verificationAdvanceCost,
              manualAdvances: _manualAdvances,
              remainingAdvances: _remainingAdvances!,
              onAdvance: _remainingAdvances! <= 0
                  ? null
                  : () => setState(() => _manualAdvances += 1),
            ),
          ],
          const SizedBox(height: 10),
          _SequencePanel(
            mode: _mode,
            coinFlips: _coinFlips,
            phoneCalls: _phoneCalls,
            onUndo: _activeSequenceLength == 0 ? null : _undoLast,
            onClear: _activeSequenceLength == 0 ? null : _clearSequence,
          ),
          const SizedBox(height: 16),
          _TargetSeedCard(target: widget.request.target),
          const SizedBox(height: 10),
          Text(l10n.matches, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          if (_activeSequenceLength == 0)
            _MessagePanel(message: l10n.calibrateNoSequence)
          else if (matches == null || matches.isEmpty)
            _MessagePanel(message: l10n.calibrateNoMatches)
          else
            for (final entry
                in matches
                    .take(20)
                    .toList(growable: false)
                    .asMap()
                    .entries) ...[
              _SeedMatchCard(
                key: ValueKey('seed-match-card-${entry.key}'),
                match: entry.value,
                targetSeed: widget.request.target.seed,
                canCalibrateTargetSeed: widget.request.targetAdvance != null,
                onSelected: () => _selectMatch(entry.value),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }

  void _addCoinFlip(CoinFlip flip) {
    setState(() {
      _coinFlips.add(flip);
      _calibratedAdvanceOffset = null;
      _manualAdvances = 0;
    });
  }

  void _addPhoneCall(PhoneCall call) {
    setState(() {
      _phoneCalls.add(call);
      _calibratedAdvanceOffset = null;
      _manualAdvances = 0;
    });
  }

  void _undoLast() {
    setState(() {
      switch (_mode) {
        case Gen4SeedCheckMode.coinFlips:
          _coinFlips.removeLast();
        case Gen4SeedCheckMode.phoneCalls:
          _phoneCalls.removeLast();
      }
      _calibratedAdvanceOffset = null;
      _manualAdvances = 0;
    });
  }

  void _clearSequence() {
    setState(() {
      switch (_mode) {
        case Gen4SeedCheckMode.coinFlips:
          _coinFlips.clear();
        case Gen4SeedCheckMode.phoneCalls:
          _phoneCalls.clear();
      }
      _calibratedAdvanceOffset = null;
      _manualAdvances = 0;
    });
  }

  void _selectMatch(Gen4SeedTimeCalibration match) {
    if (_isTargetSeed(match) && widget.request.targetAdvance != null) {
      setState(() {
        _calibratedAdvanceOffset = switch (_mode) {
          Gen4SeedCheckMode.coinFlips => 0,
          Gen4SeedCheckMode.phoneCalls => match.totalPhoneCallSkip,
        };
        _manualAdvances = 0;
      });
      return;
    }
    Navigator.of(context).pop(match);
  }

  bool _isTargetSeed(Gen4SeedTimeCalibration match) {
    return match.seed == widget.request.target.seed;
  }

  List<Gen4SeedTimeCalibration>? _searchMatches() {
    if (_activeSequenceLength == 0) {
      return null;
    }
    try {
      return switch (_mode) {
        Gen4SeedCheckMode.coinFlips => Gen4SeedTime.searchByCoinFlips(
          target: widget.request.target,
          delayCalibration: widget.request.delayWindow,
          secondCalibration: widget.request.secondWindow,
          observed: _coinFlips,
        ),
        Gen4SeedCheckMode.phoneCalls => Gen4SeedTime.searchByPhoneCalls(
          target: widget.request.target,
          delayCalibration: widget.request.delayWindow,
          secondCalibration: widget.request.secondWindow,
          observed: _phoneCalls,
          minPhoneCallSkip: widget.request.minPhoneCallSkip,
          maxPhoneCallSkip: widget.request.maxPhoneCallSkip,
        ),
      };
    } on ArgumentError {
      return null;
    }
  }
}

class _TargetSeedCard extends StatelessWidget {
  const _TargetSeedCard({required this.target});

  final Gen4SeedTime target;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final seed = target.seed.toRadixString(16).padLeft(8, '0').toUpperCase();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.target, style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text('${l10n.seed}: $seed'),
                  Text('${l10n.delay}: ${target.delay}'),
                  Text('${l10n.second}: ${target.dateTime.second}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdvancePlanPanel extends StatelessWidget {
  const _AdvancePlanPanel({
    required this.request,
    required this.advanceOffset,
    required this.verificationAdvanceCost,
    required this.manualAdvances,
    required this.remainingAdvances,
    required this.onAdvance,
  });

  final Gen4SeedCheckRequest request;
  final int advanceOffset;
  final int verificationAdvanceCost;
  final int manualAdvances;
  final int remainingAdvances;
  final VoidCallback? onAdvance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final targetAdvance = request.targetAdvance ?? 0;
    final adjusted = targetAdvance - advanceOffset;
    final safeAdjusted = adjusted < 0 ? 0 : adjusted;
    final currentAdvance =
        advanceOffset + verificationAdvanceCost + manualAdvances;
    final totalChatotAdvances = remainingAdvances + manualAdvances;
    final chatotAdvanceCount = remainingAdvances <= 0 ? 0 : remainingAdvances;
    final pitches = chatotAdvanceCount == 0
        ? const <int>[]
        : Gen4SeedVerification.chatotPitches(
            request.target.seed,
            count: chatotAdvanceCount,
            skips: currentAdvance,
          );
    final visiblePitches = pitches.take(59).toList(growable: false);
    final showPressA = visiblePitches.length == pitches.length;
    final pressALabel = l10n.targetAction;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Text('${l10n.targetAdvance}: ${request.targetAdvance}'),
                Text('${l10n.currentAdvance}: $currentAdvance'),
                Text('${l10n.remainingAdvance}: $remainingAdvances'),
                Text(l10n.chatotTotalAdvances(totalChatotAdvances)),
              ],
            ),
            if (advanceOffset != 0) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.advance}: $safeAdjusted',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.chatotPitches,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                FilledButton.tonal(
                  onPressed: onAdvance,
                  child: Text(l10n.advanceOneFrame),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _PitchGrid(
              pitches: visiblePitches,
              showPressA: showPressA,
              pressALabel: pressALabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _PitchGrid extends StatelessWidget {
  const _PitchGrid({
    required this.pitches,
    required this.showPressA,
    required this.pressALabel,
  });

  final List<int> pitches;
  final bool showPressA;
  final String pressALabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tiles = <Widget>[
      for (var index = 0; index < pitches.length; index += 1)
        _PitchTile(
          label: l10n.advanceAhead(index + 1),
          value: '${_pitchToneLabel(l10n, pitches[index])} · ${pitches[index]}',
        ),
      if (showPressA) _PitchTile(label: pressALabel, value: l10n.pressA),
    ];

    return Column(
      children: [
        for (var index = 0; index < tiles.length; index += 3)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 6),
            child: Row(
              children: [
                for (var column = 0; column < 3; column += 1) ...[
                  Expanded(
                    child: index + column < tiles.length
                        ? tiles[index + column]
                        : const SizedBox.shrink(),
                  ),
                  if (column < 2) const SizedBox(width: 6),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _PitchTile extends StatelessWidget {
  const _PitchTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

String _pitchToneLabel(AppLocalizations l10n, int pitch) {
  return pitch >= 50 ? l10n.chatotPitchHigh : l10n.chatotPitchLow;
}

class _VerificationButtons extends StatelessWidget {
  const _VerificationButtons({
    required this.mode,
    required this.phoneCaller,
    required this.onCoinFlip,
    required this.onPhoneCall,
  });

  final Gen4SeedCheckMode mode;
  final Gen4PhoneCaller phoneCaller;
  final ValueChanged<CoinFlip> onCoinFlip;
  final ValueChanged<PhoneCall> onPhoneCall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (mode) {
      Gen4SeedCheckMode.coinFlips => Row(
        children: [
          Expanded(
            child: FilledButton.tonal(
              onPressed: () => onCoinFlip(CoinFlip.heads),
              child: Text(l10n.coinMagikarp),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.tonal(
              onPressed: () => onCoinFlip(CoinFlip.tails),
              child: Text(l10n.coinPokeBall),
            ),
          ),
        ],
      ),
      Gen4SeedCheckMode.phoneCalls => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.tonal(
            onPressed: () => onPhoneCall(PhoneCall.elm),
            child: Text(_phoneMessage(l10n, phoneCaller, PhoneCall.elm)),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => onPhoneCall(PhoneCall.kanto),
            child: Text(_phoneMessage(l10n, phoneCaller, PhoneCall.kanto)),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => onPhoneCall(PhoneCall.pokerus),
            child: Text(_phoneMessage(l10n, phoneCaller, PhoneCall.pokerus)),
          ),
        ],
      ),
    };
  }
}

String _phoneMessage(
  AppLocalizations l10n,
  Gen4PhoneCaller caller,
  PhoneCall call,
) {
  return switch (caller) {
    Gen4PhoneCaller.elm => switch (call) {
      PhoneCall.elm => l10n.phoneElmMessage,
      PhoneCall.kanto => l10n.phoneKantoMessage,
      PhoneCall.pokerus => l10n.phonePokerusMessage,
    },
    Gen4PhoneCaller.irwin => switch (call) {
      PhoneCall.elm => l10n.phoneIrwinElmMessage,
      PhoneCall.kanto => l10n.phoneIrwinKantoMessage,
      PhoneCall.pokerus => l10n.phoneIrwinPokerusMessage,
    },
  };
}

String _phoneCallerLabel(AppLocalizations l10n, Gen4PhoneCaller caller) {
  return switch (caller) {
    Gen4PhoneCaller.elm => l10n.phoneCallerElm,
    Gen4PhoneCaller.irwin => l10n.phoneCallerIrwin,
  };
}

class _SequencePanel extends StatelessWidget {
  const _SequencePanel({
    required this.mode,
    required this.coinFlips,
    required this.phoneCalls,
    required this.onUndo,
    required this.onClear,
  });

  final Gen4SeedCheckMode mode;
  final List<CoinFlip> coinFlips;
  final List<PhoneCall> phoneCalls;
  final VoidCallback? onUndo;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = switch (mode) {
      Gen4SeedCheckMode.coinFlips => [
        for (final flip in coinFlips) _coinFlipLabel(l10n, flip),
      ],
      Gen4SeedCheckMode.phoneCalls => [
        for (final call in phoneCalls) _phoneCallLabel(l10n, call),
      ],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labels.isEmpty)
          Text(
            l10n.calibrateNoSequence,
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var index = 0; index < labels.length; index += 1)
                InputChip(label: Text('${index + 1}. ${labels[index]}')),
            ],
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton(onPressed: onUndo, child: Text(l10n.undo)),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: onClear, child: Text(l10n.clear)),
          ],
        ),
      ],
    );
  }
}

class _SeedMatchCard extends StatelessWidget {
  const _SeedMatchCard({
    super.key,
    required this.match,
    required this.targetSeed,
    required this.canCalibrateTargetSeed,
    required this.onSelected,
  });

  final Gen4SeedTimeCalibration match;
  final int targetSeed;
  final bool canCalibrateTargetSeed;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final seed = match.seed.toRadixString(16).padLeft(8, '0').toUpperCase();
    final isTargetSeed = match.seed == targetSeed;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSelected,
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
                Text('${l10n.seed}: $seed'),
                Text('${l10n.delay}: ${match.delay}'),
                Text('${l10n.second}: ${match.dateTime.second}'),
                if (match.observedPhoneCallCount > 0)
                  Text('${l10n.initialAdvance}: ${match.totalPhoneCallSkip}'),
                if (isTargetSeed && canCalibrateTargetSeed)
                  Text(l10n.reverseHitTargetSeed),
                Text(_dateTimeValue(match.dateTime)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(message, style: Theme.of(context).textTheme.bodySmall);
  }
}

String _coinFlipLabel(AppLocalizations l10n, CoinFlip flip) {
  return switch (flip) {
    CoinFlip.heads => l10n.coinMagikarpShort,
    CoinFlip.tails => l10n.coinPokeBallShort,
  };
}

String _phoneCallLabel(AppLocalizations l10n, PhoneCall call) {
  return switch (call) {
    PhoneCall.elm => l10n.phoneElmShort,
    PhoneCall.kanto => l10n.phoneKantoShort,
    PhoneCall.pokerus => l10n.phonePokerusShort,
  };
}

String _dateTimeValue(DateTime dateTime) {
  return '${dateTime.year.toString().padLeft(4, '0')}-'
      '${dateTime.month.toString().padLeft(2, '0')}-'
      '${dateTime.day.toString().padLeft(2, '0')} '
      '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')}:'
      '${dateTime.second.toString().padLeft(2, '0')}';
}

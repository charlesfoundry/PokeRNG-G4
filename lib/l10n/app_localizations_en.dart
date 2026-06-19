// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PokeRNG G4';

  @override
  String get target => 'Target';

  @override
  String get search => 'Search';

  @override
  String get egg => 'Egg';

  @override
  String get eggHgssTitle => 'HGSS Egg RNG Algorithm';

  @override
  String get eggHgssAlgorithmNote =>
      'This page always uses the HGSS egg algorithm. TID/SID default to the current game\'s saved values and can be changed temporarily; the egg must be generated in HGSS.';

  @override
  String get eggDpptTitle => 'DPPt Egg RNG Algorithm';

  @override
  String get eggDpptAlgorithmNote =>
      'This is an isolated copy for DPPt egg RNG. DPPt-specific egg generation and pickup algorithms will be wired here without changing the verified HGSS egg page.';

  @override
  String get eggDpptHeldFrameNote =>
      'The DPPt egg generation stage decides PID, nature, gender, ability, and shininess. Use coin flips to verify the seed; coin flips do not advance Egg Frame.';

  @override
  String get eggDpptPickupFrameNote =>
      'The DPPt egg pickup stage decides IVs and inheritance. DPPt uses the original inheritance bug, so this page intentionally searches a separate DPPt path from the verified HGSS page.';

  @override
  String get eggHgssOnlyTitle => 'HGSS egg RNG only';

  @override
  String get eggHgssOnlyBody =>
      'DPPt eggs use a separate inheritance path. This page is currently limited to HeartGold and SoulSilver.';

  @override
  String get eggGenerateEggTab => 'Generate egg';

  @override
  String get eggPickupEggTab => 'Pick up egg';

  @override
  String get eggDaycare => 'Daycare';

  @override
  String get eggGenderRatio => 'Gender ratio';

  @override
  String eggGenderRatioPercent(String male, String female) {
    return '$male% ♂ : $female% ♀';
  }

  @override
  String get eggGenderRatioMaleOnly => '100% ♂';

  @override
  String get eggGenderRatioFemaleOnly => '100% ♀';

  @override
  String get eggMasuda => 'Masuda method';

  @override
  String get eggParentsSettings => 'Egg parents';

  @override
  String get eggParentA => 'Parent A IVs';

  @override
  String get eggParentB => 'Parent B IVs';

  @override
  String get eggHeldStage => 'Egg PID';

  @override
  String get eggFrameOneNote =>
      'Simple mode only supports Egg Frame 1. Hit this seed, then make the Day-Care Man generate the first egg.';

  @override
  String get eggPhoneFrameNote =>
      'The egg generation stage decides PID, nature, gender, ability, and shininess. Egg Frame is the PID frame used when the Day-Care Man generates the egg; Elm/Irwin calls only verify the seed and are not automatically treated as Egg Frame advances.';

  @override
  String get eggPickupFrameNote =>
      'The egg pickup stage decides IVs and inheritance. Generate IVs searches by year, Delay range, and Pickup Advance range. Reverse search assumes the Seed was hit and only searches Pickup Advances inside the selected or verified Pickup Seed.';

  @override
  String get eggPhoneCalls => 'Phone calls';

  @override
  String get eggMinFrame => 'Min Egg Frame';

  @override
  String get eggMaxFrame => 'Max Egg Frame';

  @override
  String get eggTargetEggFrame => 'Egg Frame';

  @override
  String get eggPickupStage => 'Egg pickup';

  @override
  String get eggHeldSeed => 'PID Seed';

  @override
  String get eggPickupSeed => 'Pickup Seed';

  @override
  String get eggSearchPid => 'Generate PID';

  @override
  String get eggPidResultsTitle => 'Egg PID Results';

  @override
  String get eggSearchIvs => 'Generate IVs';

  @override
  String get eggObservedIvs => 'Observed IVs';

  @override
  String get eggObservedStats => 'Observed stats (Lv. 1)';

  @override
  String get eggSelectHatchedPokemon => 'Select the hatched Pokemon.';

  @override
  String get eggObservedStatsInputError =>
      'Enter the hatched Pokemon\'s observed level 1 stats.';

  @override
  String get eggObservedStatsNoIvRanges =>
      'Pokemon, nature, stats, or characteristic do not match. Check the inputs.';

  @override
  String get eggPickupReverseSeedRequired =>
      'Select a target pickup result first, or verify the hit Pickup Seed with Seed Search.';

  @override
  String get eggReversePickupSearch => 'Reverse Search Pickup';

  @override
  String get eggPickupResultsTitle => 'Egg IV Results';

  @override
  String get eggLockedEgg => 'Locked egg';

  @override
  String get eggLockedPid => 'Locked PID';

  @override
  String get eggLockedEggNote =>
      'Egg pickup only uses this PID identity. The Delay and Egg Frame used to generate the egg do not participate in pickup IV RNG; Pickup Seed and Pickup Advance independently decide IVs and inheritance.';

  @override
  String get eggNoPickupTargetSelected =>
      'No generated IV result selected yet.';

  @override
  String get eggNoSeedTimeSelected => 'No Seed Time selected yet.';

  @override
  String get eggTimerRequiresSeedTime =>
      'Select a Seed Time to show the timer.';

  @override
  String get eggNoPidResults => 'No matching PID.';

  @override
  String eggResultLimitReached(String count) {
    return 'Showing the first $count results. Narrow the range.';
  }

  @override
  String get eggNoIvResults => 'No matching pickup result.';

  @override
  String get eggSelectPidFirst => 'Select an egg PID above first.';

  @override
  String get eggSelectedPid => 'Selected PID';

  @override
  String get eggSelectedSeedTime => 'Selected Seed Time';

  @override
  String get eggObservedPid => 'Observed PID Reverse Search';

  @override
  String get eggReversePidSearch => 'Reverse Search PID';

  @override
  String get eggSelectedHitDelay => 'Selected Hit Delay';

  @override
  String get eggMinIvsOptional => 'Minimum IVs (optional)';

  @override
  String get eggPidAdvance => 'PID adv.';

  @override
  String get eggPickupAdvance => 'Pickup adv.';

  @override
  String get eggInheritance => 'Inheritance';

  @override
  String get results => 'Results';

  @override
  String get calibrate => 'Calibrate';

  @override
  String get tools => 'Tools';

  @override
  String get settings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get gameVersion => 'Game Version';

  @override
  String get gameDiamond => 'Diamond';

  @override
  String get gamePearl => 'Pearl';

  @override
  String get gamePlatinum => 'Platinum';

  @override
  String get gameHeartGold => 'HeartGold';

  @override
  String get gameSoulSilver => 'SoulSilver';

  @override
  String get trainerProfile => 'Trainer Profile';

  @override
  String get trainerId => 'TID';

  @override
  String get secretId => 'SID';

  @override
  String get timerDefaults => 'Timer Defaults';

  @override
  String get delayWindow => 'Delay Window';

  @override
  String get secondWindow => 'Second Window';

  @override
  String get hgssPhoneCaller => 'HGSS Phone Text';

  @override
  String get maxPhoneCallSkip => 'Max Initial Advance';

  @override
  String get phoneCallerElm => 'Professor Elm';

  @override
  String get phoneCallerIrwin => 'Juggler Irwin';

  @override
  String get save => 'Save';

  @override
  String get settingsInputError => 'Enter a value from 0 to 65535.';

  @override
  String get settingsTimerInputError =>
      'Check delay, second, and initial advance defaults.';

  @override
  String get settingsEggParentInputError =>
      'Check parent IVs. Each value must be from 0 to 31.';

  @override
  String get settingsEggLockedPidInputError =>
      'Check the locked PID. Leave it empty or enter an 8-digit hexadecimal PID.';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get license => 'License';

  @override
  String get project => 'Project';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get credits => 'Credits';

  @override
  String get aboutDescription =>
      'A multi-platform RNG tool for Gen 4 Diamond, Pearl, Platinum, HeartGold, and SoulSilver.';

  @override
  String get unofficialNotice => 'Unofficial fan-made RNG utility.';

  @override
  String get aboutCredits =>
      'References PokeFinder, EonTimer, and PokemonRNG community research.';

  @override
  String get copyProjectUrl => 'Copy project URL';

  @override
  String get projectUrlCopied => 'Project URL copied';

  @override
  String get searchMode => 'Search Mode';

  @override
  String get timeFinder => 'Time Finder';

  @override
  String get generator => 'Generator';

  @override
  String get generatorPlaceholder =>
      'Generator controls will be added after Time Finder is wired.';

  @override
  String get pokemon => 'Pokemon';

  @override
  String get location => 'Location';

  @override
  String get timeCondition => 'Time';

  @override
  String get gbaCartridge => 'GBA Cartridge';

  @override
  String get queryLocations => 'Query Locations';

  @override
  String get noMatchingLocations =>
      'No matching source for the current time and cartridge filters.';

  @override
  String get noAvailableLocationForGame =>
      'No available source for this Pokemon in the current game.';

  @override
  String get filters => 'Filters';

  @override
  String get method => 'Method';

  @override
  String get nature => 'Nature';

  @override
  String get ability => 'Ability';

  @override
  String abilitySlot(int slot, String name) {
    return 'Ability $slot: $name';
  }

  @override
  String get gender => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderGenderless => '-';

  @override
  String get hiddenPower => 'Hidden Power';

  @override
  String get levelShort => 'Lv.';

  @override
  String get minLevel => 'Min Level';

  @override
  String get maxLevel => 'Max Level';

  @override
  String get minPower => 'Min Power';

  @override
  String get maxPower => 'Max Power';

  @override
  String get slot => 'Slot';

  @override
  String get lead => 'Lead';

  @override
  String get syncNature => 'Sync Nature';

  @override
  String get shiny => 'Shiny';

  @override
  String get notShiny => 'Not Shiny';

  @override
  String get hpIv => 'HP IV';

  @override
  String get atkIv => 'Atk IV';

  @override
  String get defIv => 'Def IV';

  @override
  String get spaIv => 'SpA IV';

  @override
  String get spdIv => 'SpD IV';

  @override
  String get speIv => 'Spe IV';

  @override
  String get searchRange => 'Search Range';

  @override
  String get year => 'Year';

  @override
  String get minDelay => 'Min Delay';

  @override
  String get maxDelay => 'Max Delay';

  @override
  String get minAdvance => 'Min Advance';

  @override
  String get maxAdvance => 'Max Advance';

  @override
  String get second => 'Second';

  @override
  String get forceSecond => 'Force Second';

  @override
  String get searchSpaceInvalid => 'Search space: invalid range';

  @override
  String searchSpaceStates(String states) {
    return 'Search space: $states states';
  }

  @override
  String searchSpaceTooLarge(String max) {
    return 'narrow to $max or fewer';
  }

  @override
  String get searching => 'Searching...';

  @override
  String get searchComplete => 'Search complete.';

  @override
  String get searchResultsPlaceholder => 'Search results will appear here.';

  @override
  String get noResults => 'No results.';

  @override
  String get searchCancelled => 'Search cancelled.';

  @override
  String get searchFailed => 'Search failed.';

  @override
  String get resultLimitReached => 'Result limit reached.';

  @override
  String get sendToCalibration => 'Send to calibration';

  @override
  String get saveTarget => 'Save target';

  @override
  String get targetSaved => 'Target saved';

  @override
  String get targetAlreadySaved => 'This target is already saved.';

  @override
  String get savedTargets => 'Saved targets';

  @override
  String get helpSection => 'Help';

  @override
  String get tutorialsTitle => 'Tutorials';

  @override
  String get tutorialsOpen => 'View tutorials';

  @override
  String get tutorialCategoryBasics => 'Basics';

  @override
  String get tutorialCategoryStarter => 'Starters';

  @override
  String get tutorialCategoryStationary => 'Stationary';

  @override
  String get tutorialCategoryWild => 'Wild';

  @override
  String get tutorialCategoryEgg => 'Eggs';

  @override
  String get leadAbilityHelpTitle => 'DP/Pt/HGSS Lead Abilities';

  @override
  String get wildSweetScentHelpTitle => 'HGSS Sweet Scent';

  @override
  String get noSavedTargets =>
      'Tap a result on the results page to save a target.';

  @override
  String get deleteTarget => 'Delete target';

  @override
  String resultCount(String count) {
    return '$count results';
  }

  @override
  String searchProgress(String scanned, String total) {
    return '$scanned / $total';
  }

  @override
  String get seed => 'Seed';

  @override
  String get pid => 'PID';

  @override
  String get delay => 'Delay';

  @override
  String get advance => 'Advance';

  @override
  String get hour => 'Hour';

  @override
  String get time => 'Time';

  @override
  String get ivs => 'IVs';

  @override
  String get stats => 'Stats';

  @override
  String get hpStat => 'HP';

  @override
  String get atkStat => 'Atk';

  @override
  String get defStat => 'Def';

  @override
  String get spaStat => 'SpA';

  @override
  String get spdStat => 'SpD';

  @override
  String get speStat => 'Spe';

  @override
  String get month => 'Month';

  @override
  String get day => 'Day';

  @override
  String get minute => 'Minute';

  @override
  String get calibrateSeedCheck => 'Seed Check';

  @override
  String get calibrateCoinFlips => 'DPPt Coin Flips';

  @override
  String get calibratePhoneCalls => 'HGSS Phone Calls';

  @override
  String get calibrateParameterHelp =>
      'Target Delay and Target Second come from the selected result and identify the seed for this run. Calibrated Delay and Calibrated Second come from Settings and describe your console and input timing; they are not extra waiting time.';

  @override
  String get calibrateQuickGuide =>
      'Quick guide: first verify the seed with coin flips or phone calls, then compare the second and delay you actually hit. Update Calibrated Second when the second is consistently off, and use Hit Delay to recalculate Calibrated Delay. For a formal target run, do not verify the seed first; follow the timer, perform the target action, then reverse-check the Pokemon afterward.';

  @override
  String get calibrationTarget => 'Current Target';

  @override
  String get noCalibrationTarget =>
      'No calibration target. Send a target from the results page.';

  @override
  String get seedToTime => 'Get Seed Time';

  @override
  String get seedToTimeTitle => 'Seed to Time';

  @override
  String get seedToTimeSearch => 'Get Time';

  @override
  String get seedToTimeInvalidFilter =>
      'Year must be 2000 to 2099, month 1 to 12, and day 1 to 31.';

  @override
  String get noSeedTimeResults => 'No matching time.';

  @override
  String get selectedSeedTime => 'Selected Seed Time';

  @override
  String get seedSearch => 'Search Seed';

  @override
  String get seedSearchTitle => 'Seed Search';

  @override
  String get selectedSeedHit => 'Selected Seed Hit';

  @override
  String get selectedSeedHitHelp =>
      'This result has filled Delay Hit in the timer. Tap Apply Calibration to update Calibrated Delay and adjust Calibrated Second by the hit-second offset.';

  @override
  String get initialAdvance => 'Initial Advance';

  @override
  String get currentAdvance => 'Current Advance';

  @override
  String get targetAdvance => 'Target Advance';

  @override
  String get remainingAdvance => 'Remaining Advance';

  @override
  String get advanceOffset => 'Offset';

  @override
  String get initialAdvanceFilter => 'Initial Advance';

  @override
  String get advanceOffsetHelp =>
      'DPPt: use reverse search after catching the Pokemon to calculate offset. HGSS: phone calls can calculate offset directly; reverse search is still available.';

  @override
  String get chatotPitches => 'Chatot Pitches';

  @override
  String get chatotPitchHigh => 'High';

  @override
  String get chatotPitchLow => 'Low';

  @override
  String chatotTotalAdvances(int count) {
    return 'Chatot cries: $count';
  }

  @override
  String advanceAhead(int count) {
    return 'Next +$count';
  }

  @override
  String get targetAction => 'Target';

  @override
  String get advanceOneFrame => 'Advance';

  @override
  String get pressA => 'Press A';

  @override
  String get timerTimingHelpTitle => 'DP/Pt/HGSS Timer Input Timing';

  @override
  String get eggHeldHelpTitle => 'HGSS Egg Generation';

  @override
  String get eggPickupHelpTitle => 'HGSS Egg Pickup';

  @override
  String get chatotAdvanceHelpTitle => 'Pt/HGSS Chatot and Target Frames';

  @override
  String get hgssStationaryHelpTitle => 'HGSS Stationary Shiny';

  @override
  String get honeyTreeHelpTitle => 'Pt Honey Tree Shiny';

  @override
  String get platinumStarterHelpTitle => 'Pt Starter Shiny';

  @override
  String calibratedSecondCurrent(String second) {
    return 'Current calibrated second: $second';
  }

  @override
  String calibratedSecondHit(String second) {
    return 'Hit second: $second';
  }

  @override
  String get calibrateTargetTime => 'Target Time';

  @override
  String get calibrateSearchWindow => 'Search Window';

  @override
  String get calibrateTargetDelay => 'Target Delay';

  @override
  String get calibrateDelayWindow => 'Delay +/-';

  @override
  String get calibrateSecondWindow => 'Second +/-';

  @override
  String get calibrateObservedSequence => 'Observed Sequence';

  @override
  String calibratePhoneCallerHelp(String caller) {
    return 'Current phone text: $caller. Change it in Settings.';
  }

  @override
  String get calibrateNoSequence => 'Tap results in order.';

  @override
  String get calibrateInvalidTarget => 'Fix the target time and window values.';

  @override
  String get calibrateTargetSeedTimeRequired =>
      'Tap Get Seed Time and select a time that generates the target seed before searching seed.';

  @override
  String get calibrateNoMatches => 'No matching seed.';

  @override
  String get coinMagikarp => 'Magikarp';

  @override
  String get coinPokeBall => 'Poke Ball';

  @override
  String get coinMagikarpShort => 'M';

  @override
  String get coinPokeBallShort => 'P';

  @override
  String get phoneElmShort => 'E';

  @override
  String get phoneKantoShort => 'K';

  @override
  String get phonePokerusShort => 'P';

  @override
  String get phoneElmMessage =>
      'E - There are so many different ways that Pokémon evolve...';

  @override
  String get phoneKantoMessage =>
      'K - I expect there are some Pokémon in the Kanto region...';

  @override
  String get phonePokerusMessage =>
      'P - It seems that Pokémon that have been infected with Pokérus...';

  @override
  String get phoneIrwinElmMessage =>
      'E - Hearing about your escapades rocks my soul...';

  @override
  String get phoneIrwinKantoMessage => 'K - I\'m so glad you called...';

  @override
  String get phoneIrwinPokerusMessage => 'P - How are you? What are you doing?';

  @override
  String get matches => 'Matches';

  @override
  String get undo => 'Undo';

  @override
  String get clear => 'Clear';

  @override
  String get retailTimer => 'Retail Timer';

  @override
  String get timerPreparation => 'Preparation';

  @override
  String get timerFirstCountdown => 'First Timer';

  @override
  String get timerSecondCountdown => 'Second Timer';

  @override
  String get timerCurrentCountdown => 'Countdown';

  @override
  String get timerReady => 'Ready';

  @override
  String get timerFinished => 'Finished';

  @override
  String get timerStart => 'Start';

  @override
  String get timerStop => 'Stop';

  @override
  String get timerTargetDelay => 'Target Delay';

  @override
  String get timerTargetSecond => 'Target Second';

  @override
  String get timerCalibratedDelay => 'Calibrated Delay';

  @override
  String get timerCalibratedSecond => 'Calibrated Second';

  @override
  String get idRngSettings => 'ID RNG Settings';

  @override
  String get idRngCalibratedDelay => 'ID Calibrated Delay';

  @override
  String get eggRngSettings => 'Egg RNG Settings';

  @override
  String get eggRngCalibratedDelay => 'Egg Calibrated Delay';

  @override
  String get timerDelayHit => 'Delay Hit';

  @override
  String get timerApplyCalibration => 'Apply Calibration';

  @override
  String get timerCalibrationAppliedTitle => 'Calibration Applied';

  @override
  String timerCalibrationDelayChange(String before, String after) {
    return 'Calibrated Delay: $before -> $after';
  }

  @override
  String timerCalibrationSecondChange(String before, String after) {
    return 'Calibrated Second: $before -> $after';
  }

  @override
  String timerCalibrationFirstCountdownChange(String before, String after) {
    return 'First Timer: $before -> $after';
  }

  @override
  String timerCalibrationSecondCountdownChange(String before, String after) {
    return 'Second Timer: $before -> $after';
  }

  @override
  String get timerConsole => 'Console';

  @override
  String get timerConsoleGba => 'GBA';

  @override
  String get timerConsoleNdsSlot1 => 'NDS - Slot 1';

  @override
  String get timerConsoleNdsSlot2 => 'NDS - Slot 2';

  @override
  String get timerConsoleDsi => 'DSi';

  @override
  String get timerConsole3ds => '3DS';

  @override
  String get timerConsoleCustom => 'Custom';

  @override
  String get timerCustomFrameRate => 'Custom Frame Rate';

  @override
  String get timerMinimumLength => 'Minimum Length';

  @override
  String get timerPrecisionCalibration => 'Precision Calibration';

  @override
  String timerMinutesBeforeTarget(String minutes) {
    return 'Set clock $minutes min before target';
  }

  @override
  String timerNdsSetTime(String time) {
    return 'Set NDS time to $time';
  }

  @override
  String timerPhase(String phase) {
    return 'Phase $phase';
  }

  @override
  String get timerInputError => 'Check timer values.';

  @override
  String get timerWebSoundUnsupported =>
      'The web timer does not support countdown audio yet.';

  @override
  String get reverseHitFeedback => 'Reverse Hit Feedback';

  @override
  String get reverseHitSeedMatched => 'Seed Hit';

  @override
  String get reverseHitSeedMissed => 'Seed Missed';

  @override
  String get reverseHitTargetAdvance => 'Target Adv';

  @override
  String get reverseHitActualAdvance => 'Actual Adv';

  @override
  String reverseHitAdvanceDelta(String delta) {
    return 'Advance delta: $delta';
  }

  @override
  String get observedHit => 'Observed Hit';

  @override
  String get starterObservedHit => 'Starter Hit';

  @override
  String get characteristic => 'Characteristic';

  @override
  String get characteristicOptions =>
      'Loves to eat|Takes plenty of siestas|Nods off a lot|Scatters things often|Likes to relax|Proud of its power|Likes to thrash about|A little quick tempered|Likes to fight|Quick tempered|Sturdy body|Capable of taking hits|Highly persistent|Good endurance|Good perseverance|Likes to run|Alert to sounds|Impetuous and silly|Somewhat of a clown|Quick to flee|Highly curious|Mischievous|Thoroughly cunning|Often lost in thought|Very finicky|Strong willed|Somewhat vain|Strongly defiant|Hates to lose|Somewhat stubborn';

  @override
  String get reverseHitSearch => 'Reverse Search Pokemon';

  @override
  String get reverseHitTitle => 'Reverse Search';

  @override
  String get reverseHitNoResults => 'No matching results.';

  @override
  String get reverseHitTargetSeed => 'Target Seed';

  @override
  String get reverseHitNearbySeed => 'Nearby Seed';

  @override
  String get searchDisabledSelectPokemon => 'Select a Pokemon first.';

  @override
  String get searchDisabledQueryLocations =>
      'Query locations after choosing a Pokemon.';

  @override
  String get searchDisabledSelectLocation => 'Select a location.';

  @override
  String get searchDisabledInvalidRange => 'Fix the search range values.';

  @override
  String searchDisabledSearchSpaceTooLarge(String max) {
    return 'Narrow the search space to $max or fewer states.';
  }

  @override
  String get searchDisabledInvalidIvs => 'Enter IV values from 0 to 31.';

  @override
  String searchDisabledIvRangeTooLarge(String max) {
    return 'Narrow IV ranges to $max or fewer combinations.';
  }

  @override
  String get searchDisabledInvalidHiddenPower =>
      'Enter Hidden Power strength from 30 to 70.';

  @override
  String get searchDisabledUnsupportedSource =>
      'This source cannot be searched yet.';

  @override
  String get searchDisabledDelayYearOverflow =>
      'Delay range is outside this year\'s valid seed range.';

  @override
  String get searchDisabledAlreadyRunning => 'A search is already running.';

  @override
  String get any => 'Any';

  @override
  String get none => 'None';

  @override
  String get gbaRuby => 'Ruby';

  @override
  String get gbaSapphire => 'Sapphire';

  @override
  String get gbaEmerald => 'Emerald';

  @override
  String get gbaFireRed => 'FireRed';

  @override
  String get gbaLeafGreen => 'LeafGreen';

  @override
  String get leadNone => 'None';

  @override
  String get leadSynchronize => 'Synchronize';

  @override
  String get leadCuteCharmMale => 'Cute Charm Male';

  @override
  String get leadCuteCharmFemale => 'Cute Charm Female';

  @override
  String get leadCompoundEyes => 'CompoundEyes';

  @override
  String get leadPressure => 'Pressure';

  @override
  String get leadSuctionCups => 'Suction Cups';

  @override
  String get leadArenaTrap => 'Arena Trap';

  @override
  String get leadMagnetPull => 'Magnet Pull';

  @override
  String get leadStatic => 'Static';

  @override
  String get typeFighting => 'Fighting';

  @override
  String get typeFlying => 'Flying';

  @override
  String get typePoison => 'Poison';

  @override
  String get typeGround => 'Ground';

  @override
  String get typeRock => 'Rock';

  @override
  String get typeBug => 'Bug';

  @override
  String get typeGhost => 'Ghost';

  @override
  String get typeSteel => 'Steel';

  @override
  String get typeFire => 'Fire';

  @override
  String get typeWater => 'Water';

  @override
  String get typeGrass => 'Grass';

  @override
  String get typeElectric => 'Electric';

  @override
  String get typePsychic => 'Psychic';

  @override
  String get typeIce => 'Ice';

  @override
  String get typeDragon => 'Dragon';

  @override
  String get typeDark => 'Dark';

  @override
  String get idRng => 'ID RNG';

  @override
  String get idRngTarget => 'Target ID';

  @override
  String get idRngSearch => 'Search IDs';

  @override
  String get idRngSearchAll => 'Search IDs (All)';

  @override
  String get idRngResults => 'ID Results';

  @override
  String get idRngTimer => 'ID Timer';

  @override
  String get idRngHitCheck => 'Actual ID Check';

  @override
  String get idRngMinSid => 'Min SID';

  @override
  String get idRngMaxSid => 'Max SID';

  @override
  String get idRngTargetPid => 'Target PID';

  @override
  String get idRngTargetTsv => 'Target TSV';

  @override
  String get idRngExtraTargetFilters => 'Extra Target Filters';

  @override
  String get cuteCharmIdTarget => 'Cute Charm ID Target';

  @override
  String get idRngPidTargetFinder => 'PID Target Finder';

  @override
  String get idRngExcellentSidFinder => 'Excellent SID Finder';

  @override
  String get idRngReachableExcellentSidFinder => 'Find SID';

  @override
  String get idRngReachableExcellentSidSearch => 'Search SID';

  @override
  String get idRngQuickGuide => 'Guide';

  @override
  String get idRngQuickGuideBody =>
      'Enter the TID you want. Min SID and Max SID can be left blank.\nTap Excellent SID Finder, review the displayed PIDs, choose the SID range you want, then tap a card to return and fill the fields automatically.\nEnter the year next. A minimum Delay of at least 5000 is recommended, because a new game usually needs that much time for setup.\nTap Search SID and choose the desired result. The page returns to ID RNG and shows the timer.\nUse the timer to set the DS time, start the game, finish character creation, then wait on the TV screen. Press A exactly when the timer countdown ends.\nUse the TID you actually received to calibrate the timer, then repeat the attempt.';

  @override
  String get idRngExcellentSidSearch => 'Search Excellent SID';

  @override
  String get idRngExcellentSidResults => 'Best Target TSV Groups';

  @override
  String get idRngIncludeNeutralNatures => 'Show neutral natures';

  @override
  String get idRngSortByNatureCount => 'Most Natures';

  @override
  String get idRngSortByTargetCount => 'Most Targets';

  @override
  String idRngExcellentSidGroup(String tsv) {
    return 'TSV $tsv';
  }

  @override
  String idRngPidTargetCount(String count) {
    return '$count targets';
  }

  @override
  String idRngNatureCount(String count) {
    return '$count natures';
  }

  @override
  String idRngSidRangeShort(String range) {
    return 'SID $range';
  }

  @override
  String get idRngPidTargetNatures => 'Target Natures';

  @override
  String get idRngPidTargetMinIvs => 'Minimum IVs';

  @override
  String get idRngPidTargetSearch => 'Search PID Targets';

  @override
  String get idRngPidTargetResults => 'PID Target Results';

  @override
  String get idRngPidTargetNoResults => 'No PID targets.';

  @override
  String get idRngPidTargetInvalidInput => 'Check the nature and IV filters.';

  @override
  String idRngPidTargetGroup(String psv, String count) {
    return 'PSV $psv · $count targets';
  }

  @override
  String idRngPidTargetGroupWithSid(String psv, String count, String sidRange) {
    return 'PSV $psv · $count targets · SID $sidRange';
  }

  @override
  String idRngPidTargetResult(
    String pid,
    String nature,
    String ivs,
    String ability,
  ) {
    return 'PID $pid · $nature · IVs $ivs · Ability $ability';
  }

  @override
  String get genderRatio => 'Gender Ratio';

  @override
  String cuteCharmIdSummary(
    String pid,
    String tsv,
    String ability,
    String gender,
  ) {
    return 'PID $pid · TSV $tsv · Ability $ability · Target Gender $gender';
  }

  @override
  String get cuteCharmApplyIdTarget => 'Apply to ID Search';

  @override
  String idRngSearchSpace(String states) {
    return 'Search space: $states seeds';
  }

  @override
  String get idRngNeedFilter =>
      'Enter at least one TID, SID, TSV, or PID filter.';

  @override
  String get idRngInvalidInput => 'Check the ID RNG parameters.';

  @override
  String idRngPidSummary(String psv, String nature) {
    return 'PSV $psv · Nature $nature';
  }

  @override
  String idRngSidRange(String range) {
    return 'Shiny SID: $range';
  }

  @override
  String idRngSidCandidates(String values) {
    return 'SID Candidates: $values';
  }

  @override
  String get idRngSelectedState => 'Selected ID Result';

  @override
  String get idRngSelectResultFirst => 'Select an ID result first.';

  @override
  String get idRngNoSeedTime => 'Get and select a seed time first.';

  @override
  String idRngResultSubtitle(String tid, String sid, String tsv) {
    return 'TID $tid · SID $sid · TSV $tsv';
  }

  @override
  String get idRngSearchHit => 'Reverse Hit Delay';

  @override
  String get idRngHitDelayWindow => 'Delay +/-';

  @override
  String get idRngHitResults => 'ID Hit Results';

  @override
  String get idRngSelectedHit => 'Selected ID Hit';

  @override
  String get idRngNoHit => 'No matching TID/SID.';

  @override
  String get idRngHitHelp =>
      'This result has filled Delay Hit in the ID timer. Tap Apply Calibration to update ID Calibrated Delay only; the encounter timer delay is not changed.';

  @override
  String get gen4TargetCategoryWild => 'Wild';

  @override
  String get gen4TargetCategoryStationary => 'Stationary';

  @override
  String get gen4TargetCategoryLegend => 'Legendary';

  @override
  String get gen4TargetCategoryGift => 'Gift';

  @override
  String get gen4TargetCategoryStarter => 'Starter';

  @override
  String get gen4TargetCategoryFossil => 'Fossil';

  @override
  String get gen4TargetCategoryGameCorner => 'Game Corner';

  @override
  String get gen4TargetCategoryEvent => 'Event';

  @override
  String get gen4TargetCategoryRoamer => 'Roamer';

  @override
  String get gen4TargetWildGrass => 'Grass';

  @override
  String get gen4TargetWildSurfing => 'Surfing';

  @override
  String get gen4TargetWildOldRod => 'Old Rod';

  @override
  String get gen4TargetWildGoodRod => 'Good Rod';

  @override
  String get gen4TargetWildSuperRod => 'Super Rod';

  @override
  String get gen4TargetWildRockSmash => 'Rock Smash';

  @override
  String get gen4TargetWildBugCatchingContest => 'Bug-Catching Contest';

  @override
  String get gen4TargetWildHeadbutt => 'Headbutt';

  @override
  String get gen4TargetWildHeadbuttAlt => 'Headbutt Alt';

  @override
  String get gen4TargetWildHeadbuttSpecial => 'Headbutt Special';

  @override
  String get gen4TargetWildHoneyTree => 'Honey Tree';

  @override
  String get gen4TargetTimeMorning => 'Morning';

  @override
  String get gen4TargetTimeDay => 'Day';

  @override
  String get gen4TargetTimeNight => 'Night';

  @override
  String get gen4TargetMethodMethod1 => 'Method 1';

  @override
  String get gen4TargetMethodMethodJ => 'Method J';

  @override
  String get gen4TargetMethodMethodK => 'Method K';

  @override
  String get gen4TargetMethodHoneyTree => 'Honey Tree';

  @override
  String get gen4TargetMethodPokeRadar => 'Poke Radar';

  @override
  String get gen4TargetMethodPokeRadarShiny => 'Poke Radar Shiny';

  @override
  String get gen4TargetStaticStarter => 'Starter';

  @override
  String get gen4TargetStaticFossil => 'Fossil';

  @override
  String get gen4TargetStaticGift => 'Gift';

  @override
  String get gen4TargetStaticGameCorner => 'Game Corner';

  @override
  String get gen4TargetStaticStationary => 'Stationary';

  @override
  String get gen4TargetStaticLegend => 'Legendary';

  @override
  String get gen4TargetStaticEvent => 'Event';

  @override
  String get gen4TargetStaticRoamer => 'Roamer';

  @override
  String get gen4TargetShinyRandom => 'Random shiny';

  @override
  String get gen4TargetShinyAlways => 'Always shiny';

  @override
  String get gen4TargetShinyNever => 'Shiny locked';

  @override
  String get gen4TargetModifierSwarm => 'Swarm';

  @override
  String get gen4TargetModifierDay => 'Day slot';

  @override
  String get gen4TargetModifierNight => 'Night slot';

  @override
  String get gen4TargetModifierRadar => 'Poke Radar';

  @override
  String get gen4TargetModifierRuby => 'Ruby inserted';

  @override
  String get gen4TargetModifierSapphire => 'Sapphire inserted';

  @override
  String get gen4TargetModifierEmerald => 'Emerald inserted';

  @override
  String get gen4TargetModifierFireRed => 'FireRed inserted';

  @override
  String get gen4TargetModifierLeafGreen => 'LeafGreen inserted';

  @override
  String get gen4TargetModifierFeebasTile => 'Feebas tile';

  @override
  String get gen4TargetModifierHoennSound => 'Hoenn Sound';

  @override
  String get gen4TargetModifierSinnohSound => 'Sinnoh Sound';

  @override
  String get gen4TargetModifierFishNight => 'Night fishing';

  @override
  String get gen4TargetModifierFishSwarm => 'Fishing swarm';

  @override
  String get gen4TargetModifierSafariBlocks => 'Safari blocks';

  @override
  String get gen4TargetModifierUnknown => 'Special slot';

  @override
  String gen4TargetLevel(int level) {
    return 'Lv. $level';
  }

  @override
  String gen4TargetLevelRange(int minLevel, int maxLevel) {
    return 'Lv. $minLevel-$maxLevel';
  }
}

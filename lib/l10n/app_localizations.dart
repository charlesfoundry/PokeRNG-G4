import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PokeRNG G4'**
  String get appTitle;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @egg.
  ///
  /// In en, this message translates to:
  /// **'Egg'**
  String get egg;

  /// No description provided for @eggHgssTitle.
  ///
  /// In en, this message translates to:
  /// **'HGSS Egg RNG Algorithm'**
  String get eggHgssTitle;

  /// No description provided for @eggHgssAlgorithmNote.
  ///
  /// In en, this message translates to:
  /// **'This page always uses the HGSS egg algorithm. TID/SID default to the current game\'s saved values and can be changed temporarily; the egg must be generated in HGSS.'**
  String get eggHgssAlgorithmNote;

  /// No description provided for @eggDpptTitle.
  ///
  /// In en, this message translates to:
  /// **'DPPt Egg RNG Algorithm'**
  String get eggDpptTitle;

  /// No description provided for @eggDpptAlgorithmNote.
  ///
  /// In en, this message translates to:
  /// **'This is an isolated copy for DPPt egg RNG. DPPt-specific egg generation and pickup algorithms will be wired here without changing the verified HGSS egg page.'**
  String get eggDpptAlgorithmNote;

  /// No description provided for @eggDpptHeldFrameNote.
  ///
  /// In en, this message translates to:
  /// **'The DPPt egg generation stage decides PID, nature, gender, ability, and shininess. Use coin flips to verify the seed; coin flips do not advance Egg Frame.'**
  String get eggDpptHeldFrameNote;

  /// No description provided for @eggDpptPickupFrameNote.
  ///
  /// In en, this message translates to:
  /// **'The DPPt egg pickup stage decides IVs and inheritance. DPPt uses the original inheritance bug, so this page intentionally searches a separate DPPt path from the verified HGSS page.'**
  String get eggDpptPickupFrameNote;

  /// No description provided for @eggHgssOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'HGSS egg RNG only'**
  String get eggHgssOnlyTitle;

  /// No description provided for @eggHgssOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'DPPt eggs use a separate inheritance path. This page is currently limited to HeartGold and SoulSilver.'**
  String get eggHgssOnlyBody;

  /// No description provided for @eggGenerateEggTab.
  ///
  /// In en, this message translates to:
  /// **'Generate egg'**
  String get eggGenerateEggTab;

  /// No description provided for @eggPickupEggTab.
  ///
  /// In en, this message translates to:
  /// **'Pick up egg'**
  String get eggPickupEggTab;

  /// No description provided for @eggDaycare.
  ///
  /// In en, this message translates to:
  /// **'Daycare'**
  String get eggDaycare;

  /// No description provided for @eggGenderRatio.
  ///
  /// In en, this message translates to:
  /// **'Gender ratio'**
  String get eggGenderRatio;

  /// No description provided for @eggGenderRatioPercent.
  ///
  /// In en, this message translates to:
  /// **'{male}% ♂ : {female}% ♀'**
  String eggGenderRatioPercent(String male, String female);

  /// No description provided for @eggGenderRatioMaleOnly.
  ///
  /// In en, this message translates to:
  /// **'100% ♂'**
  String get eggGenderRatioMaleOnly;

  /// No description provided for @eggGenderRatioFemaleOnly.
  ///
  /// In en, this message translates to:
  /// **'100% ♀'**
  String get eggGenderRatioFemaleOnly;

  /// No description provided for @eggMasuda.
  ///
  /// In en, this message translates to:
  /// **'Masuda method'**
  String get eggMasuda;

  /// No description provided for @eggParentsSettings.
  ///
  /// In en, this message translates to:
  /// **'Egg parents'**
  String get eggParentsSettings;

  /// No description provided for @eggParentA.
  ///
  /// In en, this message translates to:
  /// **'Parent A IVs'**
  String get eggParentA;

  /// No description provided for @eggParentB.
  ///
  /// In en, this message translates to:
  /// **'Parent B IVs'**
  String get eggParentB;

  /// No description provided for @eggHeldStage.
  ///
  /// In en, this message translates to:
  /// **'Egg PID'**
  String get eggHeldStage;

  /// No description provided for @eggFrameOneNote.
  ///
  /// In en, this message translates to:
  /// **'Simple mode only supports Egg Frame 1. Hit this seed, then make the Day-Care Man generate the first egg.'**
  String get eggFrameOneNote;

  /// No description provided for @eggPhoneFrameNote.
  ///
  /// In en, this message translates to:
  /// **'The egg generation stage decides PID, nature, gender, ability, and shininess. Egg Frame is the PID frame used when the Day-Care Man generates the egg; Elm/Irwin calls only verify the seed and are not automatically treated as Egg Frame advances.'**
  String get eggPhoneFrameNote;

  /// No description provided for @eggPickupFrameNote.
  ///
  /// In en, this message translates to:
  /// **'The egg pickup stage decides IVs and inheritance. Generate IVs searches by year, Delay range, and Pickup Advance range. Reverse search assumes the Seed was hit and only searches Pickup Advances inside the selected or verified Pickup Seed.'**
  String get eggPickupFrameNote;

  /// No description provided for @eggPhoneCalls.
  ///
  /// In en, this message translates to:
  /// **'Phone calls'**
  String get eggPhoneCalls;

  /// No description provided for @eggMinFrame.
  ///
  /// In en, this message translates to:
  /// **'Min Egg Frame'**
  String get eggMinFrame;

  /// No description provided for @eggMaxFrame.
  ///
  /// In en, this message translates to:
  /// **'Max Egg Frame'**
  String get eggMaxFrame;

  /// No description provided for @eggTargetEggFrame.
  ///
  /// In en, this message translates to:
  /// **'Egg Frame'**
  String get eggTargetEggFrame;

  /// No description provided for @eggPickupStage.
  ///
  /// In en, this message translates to:
  /// **'Egg pickup'**
  String get eggPickupStage;

  /// No description provided for @eggHeldSeed.
  ///
  /// In en, this message translates to:
  /// **'PID Seed'**
  String get eggHeldSeed;

  /// No description provided for @eggPickupSeed.
  ///
  /// In en, this message translates to:
  /// **'Pickup Seed'**
  String get eggPickupSeed;

  /// No description provided for @eggSearchPid.
  ///
  /// In en, this message translates to:
  /// **'Generate PID'**
  String get eggSearchPid;

  /// No description provided for @eggPidResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Egg PID Results'**
  String get eggPidResultsTitle;

  /// No description provided for @eggSearchIvs.
  ///
  /// In en, this message translates to:
  /// **'Generate IVs'**
  String get eggSearchIvs;

  /// No description provided for @eggObservedIvs.
  ///
  /// In en, this message translates to:
  /// **'Observed IVs'**
  String get eggObservedIvs;

  /// No description provided for @eggObservedStats.
  ///
  /// In en, this message translates to:
  /// **'Observed stats (Lv. 1)'**
  String get eggObservedStats;

  /// No description provided for @eggSelectHatchedPokemon.
  ///
  /// In en, this message translates to:
  /// **'Select the hatched Pokemon.'**
  String get eggSelectHatchedPokemon;

  /// No description provided for @eggObservedStatsInputError.
  ///
  /// In en, this message translates to:
  /// **'Enter the hatched Pokemon\'s observed level 1 stats.'**
  String get eggObservedStatsInputError;

  /// No description provided for @eggObservedStatsNoIvRanges.
  ///
  /// In en, this message translates to:
  /// **'Pokemon, nature, stats, or characteristic do not match. Check the inputs.'**
  String get eggObservedStatsNoIvRanges;

  /// No description provided for @eggPickupReverseSeedRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a target pickup result first, or verify the hit Pickup Seed with Seed Search.'**
  String get eggPickupReverseSeedRequired;

  /// No description provided for @eggReversePickupSearch.
  ///
  /// In en, this message translates to:
  /// **'Reverse Search Pickup'**
  String get eggReversePickupSearch;

  /// No description provided for @eggPickupResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Egg IV Results'**
  String get eggPickupResultsTitle;

  /// No description provided for @eggLockedEgg.
  ///
  /// In en, this message translates to:
  /// **'Locked egg'**
  String get eggLockedEgg;

  /// No description provided for @eggLockedPid.
  ///
  /// In en, this message translates to:
  /// **'Locked PID'**
  String get eggLockedPid;

  /// No description provided for @eggLockedEggNote.
  ///
  /// In en, this message translates to:
  /// **'Egg pickup only uses this PID identity. The Delay and Egg Frame used to generate the egg do not participate in pickup IV RNG; Pickup Seed and Pickup Advance independently decide IVs and inheritance.'**
  String get eggLockedEggNote;

  /// No description provided for @eggNoPickupTargetSelected.
  ///
  /// In en, this message translates to:
  /// **'No generated IV result selected yet.'**
  String get eggNoPickupTargetSelected;

  /// No description provided for @eggNoSeedTimeSelected.
  ///
  /// In en, this message translates to:
  /// **'No Seed Time selected yet.'**
  String get eggNoSeedTimeSelected;

  /// No description provided for @eggTimerRequiresSeedTime.
  ///
  /// In en, this message translates to:
  /// **'Select a Seed Time to show the timer.'**
  String get eggTimerRequiresSeedTime;

  /// No description provided for @eggNoPidResults.
  ///
  /// In en, this message translates to:
  /// **'No matching PID.'**
  String get eggNoPidResults;

  /// No description provided for @eggResultLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Showing the first {count} results. Narrow the range.'**
  String eggResultLimitReached(String count);

  /// No description provided for @eggNoIvResults.
  ///
  /// In en, this message translates to:
  /// **'No matching pickup result.'**
  String get eggNoIvResults;

  /// No description provided for @eggSelectPidFirst.
  ///
  /// In en, this message translates to:
  /// **'Select an egg PID above first.'**
  String get eggSelectPidFirst;

  /// No description provided for @eggSelectedPid.
  ///
  /// In en, this message translates to:
  /// **'Selected PID'**
  String get eggSelectedPid;

  /// No description provided for @eggSelectedSeedTime.
  ///
  /// In en, this message translates to:
  /// **'Selected Seed Time'**
  String get eggSelectedSeedTime;

  /// No description provided for @eggObservedPid.
  ///
  /// In en, this message translates to:
  /// **'Observed PID Reverse Search'**
  String get eggObservedPid;

  /// No description provided for @eggReversePidSearch.
  ///
  /// In en, this message translates to:
  /// **'Reverse Search PID'**
  String get eggReversePidSearch;

  /// No description provided for @eggSelectedHitDelay.
  ///
  /// In en, this message translates to:
  /// **'Selected Hit Delay'**
  String get eggSelectedHitDelay;

  /// No description provided for @eggMinIvsOptional.
  ///
  /// In en, this message translates to:
  /// **'Minimum IVs (optional)'**
  String get eggMinIvsOptional;

  /// No description provided for @eggPidAdvance.
  ///
  /// In en, this message translates to:
  /// **'PID adv.'**
  String get eggPidAdvance;

  /// No description provided for @eggPickupAdvance.
  ///
  /// In en, this message translates to:
  /// **'Pickup adv.'**
  String get eggPickupAdvance;

  /// No description provided for @eggInheritance.
  ///
  /// In en, this message translates to:
  /// **'Inheritance'**
  String get eggInheritance;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @calibrate.
  ///
  /// In en, this message translates to:
  /// **'Calibrate'**
  String get calibrate;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @gameVersion.
  ///
  /// In en, this message translates to:
  /// **'Game Version'**
  String get gameVersion;

  /// No description provided for @gameDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get gameDiamond;

  /// No description provided for @gamePearl.
  ///
  /// In en, this message translates to:
  /// **'Pearl'**
  String get gamePearl;

  /// No description provided for @gamePlatinum.
  ///
  /// In en, this message translates to:
  /// **'Platinum'**
  String get gamePlatinum;

  /// No description provided for @gameHeartGold.
  ///
  /// In en, this message translates to:
  /// **'HeartGold'**
  String get gameHeartGold;

  /// No description provided for @gameSoulSilver.
  ///
  /// In en, this message translates to:
  /// **'SoulSilver'**
  String get gameSoulSilver;

  /// No description provided for @trainerProfile.
  ///
  /// In en, this message translates to:
  /// **'Trainer Profile'**
  String get trainerProfile;

  /// No description provided for @trainerId.
  ///
  /// In en, this message translates to:
  /// **'TID'**
  String get trainerId;

  /// No description provided for @secretId.
  ///
  /// In en, this message translates to:
  /// **'SID'**
  String get secretId;

  /// No description provided for @timerDefaults.
  ///
  /// In en, this message translates to:
  /// **'Timer Defaults'**
  String get timerDefaults;

  /// No description provided for @delayWindow.
  ///
  /// In en, this message translates to:
  /// **'Delay Window'**
  String get delayWindow;

  /// No description provided for @secondWindow.
  ///
  /// In en, this message translates to:
  /// **'Second Window'**
  String get secondWindow;

  /// No description provided for @hgssPhoneCaller.
  ///
  /// In en, this message translates to:
  /// **'HGSS Phone Text'**
  String get hgssPhoneCaller;

  /// No description provided for @maxPhoneCallSkip.
  ///
  /// In en, this message translates to:
  /// **'Max Initial Advance'**
  String get maxPhoneCallSkip;

  /// No description provided for @phoneCallerElm.
  ///
  /// In en, this message translates to:
  /// **'Professor Elm'**
  String get phoneCallerElm;

  /// No description provided for @phoneCallerIrwin.
  ///
  /// In en, this message translates to:
  /// **'Juggler Irwin'**
  String get phoneCallerIrwin;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @settingsInputError.
  ///
  /// In en, this message translates to:
  /// **'Enter a value from 0 to 65535.'**
  String get settingsInputError;

  /// No description provided for @settingsTimerInputError.
  ///
  /// In en, this message translates to:
  /// **'Check delay, second, and initial advance defaults.'**
  String get settingsTimerInputError;

  /// No description provided for @settingsEggParentInputError.
  ///
  /// In en, this message translates to:
  /// **'Check parent IVs. Each value must be from 0 to 31.'**
  String get settingsEggParentInputError;

  /// No description provided for @settingsEggLockedPidInputError.
  ///
  /// In en, this message translates to:
  /// **'Check the locked PID. Leave it empty or enter an 8-digit hexadecimal PID.'**
  String get settingsEggLockedPidInputError;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A multi-platform RNG tool for Gen 4 Diamond, Pearl, Platinum, HeartGold, and SoulSilver.'**
  String get aboutDescription;

  /// No description provided for @unofficialNotice.
  ///
  /// In en, this message translates to:
  /// **'Unofficial fan-made RNG utility.'**
  String get unofficialNotice;

  /// No description provided for @aboutCredits.
  ///
  /// In en, this message translates to:
  /// **'References PokeFinder, EonTimer, and PokemonRNG community research.'**
  String get aboutCredits;

  /// No description provided for @copyProjectUrl.
  ///
  /// In en, this message translates to:
  /// **'Copy project URL'**
  String get copyProjectUrl;

  /// No description provided for @projectUrlCopied.
  ///
  /// In en, this message translates to:
  /// **'Project URL copied'**
  String get projectUrlCopied;

  /// No description provided for @searchMode.
  ///
  /// In en, this message translates to:
  /// **'Search Mode'**
  String get searchMode;

  /// No description provided for @timeFinder.
  ///
  /// In en, this message translates to:
  /// **'Time Finder'**
  String get timeFinder;

  /// No description provided for @generator.
  ///
  /// In en, this message translates to:
  /// **'Generator'**
  String get generator;

  /// No description provided for @generatorPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Generator controls will be added after Time Finder is wired.'**
  String get generatorPlaceholder;

  /// No description provided for @pokemon.
  ///
  /// In en, this message translates to:
  /// **'Pokemon'**
  String get pokemon;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @timeCondition.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeCondition;

  /// No description provided for @gbaCartridge.
  ///
  /// In en, this message translates to:
  /// **'GBA Cartridge'**
  String get gbaCartridge;

  /// No description provided for @queryLocations.
  ///
  /// In en, this message translates to:
  /// **'Query Locations'**
  String get queryLocations;

  /// No description provided for @noMatchingLocations.
  ///
  /// In en, this message translates to:
  /// **'No matching source for the current time and cartridge filters.'**
  String get noMatchingLocations;

  /// No description provided for @noAvailableLocationForGame.
  ///
  /// In en, this message translates to:
  /// **'No available source for this Pokemon in the current game.'**
  String get noAvailableLocationForGame;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @nature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get nature;

  /// No description provided for @ability.
  ///
  /// In en, this message translates to:
  /// **'Ability'**
  String get ability;

  /// No description provided for @abilitySlot.
  ///
  /// In en, this message translates to:
  /// **'Ability {slot}: {name}'**
  String abilitySlot(int slot, String name);

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderGenderless.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get genderGenderless;

  /// No description provided for @hiddenPower.
  ///
  /// In en, this message translates to:
  /// **'Hidden Power'**
  String get hiddenPower;

  /// No description provided for @levelShort.
  ///
  /// In en, this message translates to:
  /// **'Lv.'**
  String get levelShort;

  /// No description provided for @minLevel.
  ///
  /// In en, this message translates to:
  /// **'Min Level'**
  String get minLevel;

  /// No description provided for @maxLevel.
  ///
  /// In en, this message translates to:
  /// **'Max Level'**
  String get maxLevel;

  /// No description provided for @minPower.
  ///
  /// In en, this message translates to:
  /// **'Min Power'**
  String get minPower;

  /// No description provided for @maxPower.
  ///
  /// In en, this message translates to:
  /// **'Max Power'**
  String get maxPower;

  /// No description provided for @slot.
  ///
  /// In en, this message translates to:
  /// **'Slot'**
  String get slot;

  /// No description provided for @lead.
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get lead;

  /// No description provided for @syncNature.
  ///
  /// In en, this message translates to:
  /// **'Sync Nature'**
  String get syncNature;

  /// No description provided for @shiny.
  ///
  /// In en, this message translates to:
  /// **'Shiny'**
  String get shiny;

  /// No description provided for @notShiny.
  ///
  /// In en, this message translates to:
  /// **'Not Shiny'**
  String get notShiny;

  /// No description provided for @hpIv.
  ///
  /// In en, this message translates to:
  /// **'HP IV'**
  String get hpIv;

  /// No description provided for @atkIv.
  ///
  /// In en, this message translates to:
  /// **'Atk IV'**
  String get atkIv;

  /// No description provided for @defIv.
  ///
  /// In en, this message translates to:
  /// **'Def IV'**
  String get defIv;

  /// No description provided for @spaIv.
  ///
  /// In en, this message translates to:
  /// **'SpA IV'**
  String get spaIv;

  /// No description provided for @spdIv.
  ///
  /// In en, this message translates to:
  /// **'SpD IV'**
  String get spdIv;

  /// No description provided for @speIv.
  ///
  /// In en, this message translates to:
  /// **'Spe IV'**
  String get speIv;

  /// No description provided for @searchRange.
  ///
  /// In en, this message translates to:
  /// **'Search Range'**
  String get searchRange;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @minDelay.
  ///
  /// In en, this message translates to:
  /// **'Min Delay'**
  String get minDelay;

  /// No description provided for @maxDelay.
  ///
  /// In en, this message translates to:
  /// **'Max Delay'**
  String get maxDelay;

  /// No description provided for @minAdvance.
  ///
  /// In en, this message translates to:
  /// **'Min Advance'**
  String get minAdvance;

  /// No description provided for @maxAdvance.
  ///
  /// In en, this message translates to:
  /// **'Max Advance'**
  String get maxAdvance;

  /// No description provided for @second.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get second;

  /// No description provided for @forceSecond.
  ///
  /// In en, this message translates to:
  /// **'Force Second'**
  String get forceSecond;

  /// No description provided for @searchSpaceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Search space: invalid range'**
  String get searchSpaceInvalid;

  /// No description provided for @searchSpaceStates.
  ///
  /// In en, this message translates to:
  /// **'Search space: {states} states'**
  String searchSpaceStates(String states);

  /// No description provided for @searchSpaceTooLarge.
  ///
  /// In en, this message translates to:
  /// **'narrow to {max} or fewer'**
  String searchSpaceTooLarge(String max);

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @searchComplete.
  ///
  /// In en, this message translates to:
  /// **'Search complete.'**
  String get searchComplete;

  /// No description provided for @searchResultsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search results will appear here.'**
  String get searchResultsPlaceholder;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get noResults;

  /// No description provided for @searchCancelled.
  ///
  /// In en, this message translates to:
  /// **'Search cancelled.'**
  String get searchCancelled;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed.'**
  String get searchFailed;

  /// No description provided for @resultLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Result limit reached.'**
  String get resultLimitReached;

  /// No description provided for @sendToCalibration.
  ///
  /// In en, this message translates to:
  /// **'Send to calibration'**
  String get sendToCalibration;

  /// No description provided for @saveTarget.
  ///
  /// In en, this message translates to:
  /// **'Save target'**
  String get saveTarget;

  /// No description provided for @targetSaved.
  ///
  /// In en, this message translates to:
  /// **'Target saved'**
  String get targetSaved;

  /// No description provided for @targetAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'This target is already saved.'**
  String get targetAlreadySaved;

  /// No description provided for @savedTargets.
  ///
  /// In en, this message translates to:
  /// **'Saved targets'**
  String get savedTargets;

  /// No description provided for @helpSection.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpSection;

  /// No description provided for @tutorialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tutorials'**
  String get tutorialsTitle;

  /// No description provided for @tutorialsOpen.
  ///
  /// In en, this message translates to:
  /// **'View tutorials'**
  String get tutorialsOpen;

  /// No description provided for @tutorialCategoryBasics.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get tutorialCategoryBasics;

  /// No description provided for @tutorialCategoryId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get tutorialCategoryId;

  /// No description provided for @tutorialCategoryStarter.
  ///
  /// In en, this message translates to:
  /// **'Starters'**
  String get tutorialCategoryStarter;

  /// No description provided for @tutorialCategoryStationary.
  ///
  /// In en, this message translates to:
  /// **'Stationary'**
  String get tutorialCategoryStationary;

  /// No description provided for @tutorialCategoryWild.
  ///
  /// In en, this message translates to:
  /// **'Wild'**
  String get tutorialCategoryWild;

  /// No description provided for @tutorialCategoryEgg.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get tutorialCategoryEgg;

  /// No description provided for @leadAbilityHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'DP/Pt/HGSS Lead Abilities'**
  String get leadAbilityHelpTitle;

  /// No description provided for @wildSweetScentHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'HGSS Sweet Scent'**
  String get wildSweetScentHelpTitle;

  /// No description provided for @noSavedTargets.
  ///
  /// In en, this message translates to:
  /// **'Tap a result on the results page to save a target.'**
  String get noSavedTargets;

  /// No description provided for @deleteTarget.
  ///
  /// In en, this message translates to:
  /// **'Delete target'**
  String get deleteTarget;

  /// No description provided for @resultCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultCount(String count);

  /// No description provided for @searchProgress.
  ///
  /// In en, this message translates to:
  /// **'{scanned} / {total}'**
  String searchProgress(String scanned, String total);

  /// No description provided for @seed.
  ///
  /// In en, this message translates to:
  /// **'Seed'**
  String get seed;

  /// No description provided for @pid.
  ///
  /// In en, this message translates to:
  /// **'PID'**
  String get pid;

  /// No description provided for @delay.
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get delay;

  /// No description provided for @advance.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get advance;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get hour;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @ivs.
  ///
  /// In en, this message translates to:
  /// **'IVs'**
  String get ivs;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @hpStat.
  ///
  /// In en, this message translates to:
  /// **'HP'**
  String get hpStat;

  /// No description provided for @atkStat.
  ///
  /// In en, this message translates to:
  /// **'Atk'**
  String get atkStat;

  /// No description provided for @defStat.
  ///
  /// In en, this message translates to:
  /// **'Def'**
  String get defStat;

  /// No description provided for @spaStat.
  ///
  /// In en, this message translates to:
  /// **'SpA'**
  String get spaStat;

  /// No description provided for @spdStat.
  ///
  /// In en, this message translates to:
  /// **'SpD'**
  String get spdStat;

  /// No description provided for @speStat.
  ///
  /// In en, this message translates to:
  /// **'Spe'**
  String get speStat;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get minute;

  /// No description provided for @calibrateSeedCheck.
  ///
  /// In en, this message translates to:
  /// **'Seed Check'**
  String get calibrateSeedCheck;

  /// No description provided for @calibrateCoinFlips.
  ///
  /// In en, this message translates to:
  /// **'DPPt Coin Flips'**
  String get calibrateCoinFlips;

  /// No description provided for @calibratePhoneCalls.
  ///
  /// In en, this message translates to:
  /// **'HGSS Phone Calls'**
  String get calibratePhoneCalls;

  /// No description provided for @calibrateParameterHelp.
  ///
  /// In en, this message translates to:
  /// **'Target Delay and Target Second come from the selected result and identify the seed for this run. Calibrated Delay and Calibrated Second come from Settings and describe your console and input timing; they are not extra waiting time.'**
  String get calibrateParameterHelp;

  /// No description provided for @calibrateQuickGuide.
  ///
  /// In en, this message translates to:
  /// **'Quick guide: first verify the seed with coin flips or phone calls, then compare the second and delay you actually hit. Update Calibrated Second when the second is consistently off, and use Hit Delay to recalculate Calibrated Delay. For a formal target run, do not verify the seed first; follow the timer, perform the target action, then reverse-check the Pokemon afterward.'**
  String get calibrateQuickGuide;

  /// No description provided for @calibrationTarget.
  ///
  /// In en, this message translates to:
  /// **'Current Target'**
  String get calibrationTarget;

  /// No description provided for @noCalibrationTarget.
  ///
  /// In en, this message translates to:
  /// **'No calibration target. Send a target from the results page.'**
  String get noCalibrationTarget;

  /// No description provided for @seedToTime.
  ///
  /// In en, this message translates to:
  /// **'Get Seed Time'**
  String get seedToTime;

  /// No description provided for @seedToTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Seed to Time'**
  String get seedToTimeTitle;

  /// No description provided for @seedToTimeSearch.
  ///
  /// In en, this message translates to:
  /// **'Get Time'**
  String get seedToTimeSearch;

  /// No description provided for @seedToTimeInvalidFilter.
  ///
  /// In en, this message translates to:
  /// **'Year must be 2000 to 2099, month 1 to 12, and day 1 to 31.'**
  String get seedToTimeInvalidFilter;

  /// No description provided for @noSeedTimeResults.
  ///
  /// In en, this message translates to:
  /// **'No matching time.'**
  String get noSeedTimeResults;

  /// No description provided for @selectedSeedTime.
  ///
  /// In en, this message translates to:
  /// **'Selected Seed Time'**
  String get selectedSeedTime;

  /// No description provided for @seedSearch.
  ///
  /// In en, this message translates to:
  /// **'Search Seed'**
  String get seedSearch;

  /// No description provided for @seedSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Seed Search'**
  String get seedSearchTitle;

  /// No description provided for @selectedSeedHit.
  ///
  /// In en, this message translates to:
  /// **'Selected Seed Hit'**
  String get selectedSeedHit;

  /// No description provided for @selectedSeedHitHelp.
  ///
  /// In en, this message translates to:
  /// **'This result has filled Delay Hit in the timer. Tap Apply Calibration to update Calibrated Delay and adjust Calibrated Second by the hit-second offset.'**
  String get selectedSeedHitHelp;

  /// No description provided for @initialAdvance.
  ///
  /// In en, this message translates to:
  /// **'Initial Advance'**
  String get initialAdvance;

  /// No description provided for @currentAdvance.
  ///
  /// In en, this message translates to:
  /// **'Current Advance'**
  String get currentAdvance;

  /// No description provided for @targetAdvance.
  ///
  /// In en, this message translates to:
  /// **'Target Advance'**
  String get targetAdvance;

  /// No description provided for @remainingAdvance.
  ///
  /// In en, this message translates to:
  /// **'Remaining Advance'**
  String get remainingAdvance;

  /// No description provided for @advanceOffset.
  ///
  /// In en, this message translates to:
  /// **'Offset'**
  String get advanceOffset;

  /// No description provided for @initialAdvanceFilter.
  ///
  /// In en, this message translates to:
  /// **'Initial Advance'**
  String get initialAdvanceFilter;

  /// No description provided for @advanceOffsetHelp.
  ///
  /// In en, this message translates to:
  /// **'DPPt: use reverse search after catching the Pokemon to calculate offset. HGSS: phone calls can calculate offset directly; reverse search is still available.'**
  String get advanceOffsetHelp;

  /// No description provided for @chatotPitches.
  ///
  /// In en, this message translates to:
  /// **'Chatot Pitches'**
  String get chatotPitches;

  /// No description provided for @chatotPitchHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get chatotPitchHigh;

  /// No description provided for @chatotPitchLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get chatotPitchLow;

  /// No description provided for @chatotTotalAdvances.
  ///
  /// In en, this message translates to:
  /// **'Chatot cries: {count}'**
  String chatotTotalAdvances(int count);

  /// No description provided for @advanceAhead.
  ///
  /// In en, this message translates to:
  /// **'Next +{count}'**
  String advanceAhead(int count);

  /// No description provided for @targetAction.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get targetAction;

  /// No description provided for @advanceOneFrame.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get advanceOneFrame;

  /// No description provided for @pressA.
  ///
  /// In en, this message translates to:
  /// **'Press A'**
  String get pressA;

  /// No description provided for @timerTimingHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'DP/Pt/HGSS Timer Input Timing'**
  String get timerTimingHelpTitle;

  /// No description provided for @eggHeldHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'HGSS Egg Generation'**
  String get eggHeldHelpTitle;

  /// No description provided for @eggPickupHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'HGSS Egg Pickup'**
  String get eggPickupHelpTitle;

  /// No description provided for @chatotAdvanceHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Pt/HGSS Chatot and Target Frames'**
  String get chatotAdvanceHelpTitle;

  /// No description provided for @hgssStationaryHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'HGSS Stationary Shiny'**
  String get hgssStationaryHelpTitle;

  /// No description provided for @honeyTreeHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Pt Honey Tree Shiny'**
  String get honeyTreeHelpTitle;

  /// No description provided for @platinumStarterHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Pt Starter Shiny'**
  String get platinumStarterHelpTitle;

  /// No description provided for @platinumIdRngHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Pt ID RNG'**
  String get platinumIdRngHelpTitle;

  /// No description provided for @calibratedSecondCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current calibrated second: {second}'**
  String calibratedSecondCurrent(String second);

  /// No description provided for @calibratedSecondHit.
  ///
  /// In en, this message translates to:
  /// **'Hit second: {second}'**
  String calibratedSecondHit(String second);

  /// No description provided for @calibrateTargetTime.
  ///
  /// In en, this message translates to:
  /// **'Target Time'**
  String get calibrateTargetTime;

  /// No description provided for @calibrateSearchWindow.
  ///
  /// In en, this message translates to:
  /// **'Search Window'**
  String get calibrateSearchWindow;

  /// No description provided for @calibrateTargetDelay.
  ///
  /// In en, this message translates to:
  /// **'Target Delay'**
  String get calibrateTargetDelay;

  /// No description provided for @calibrateDelayWindow.
  ///
  /// In en, this message translates to:
  /// **'Delay +/-'**
  String get calibrateDelayWindow;

  /// No description provided for @calibrateSecondWindow.
  ///
  /// In en, this message translates to:
  /// **'Second +/-'**
  String get calibrateSecondWindow;

  /// No description provided for @calibrateObservedSequence.
  ///
  /// In en, this message translates to:
  /// **'Observed Sequence'**
  String get calibrateObservedSequence;

  /// No description provided for @calibratePhoneCallerHelp.
  ///
  /// In en, this message translates to:
  /// **'Current phone text: {caller}. Change it in Settings.'**
  String calibratePhoneCallerHelp(String caller);

  /// No description provided for @calibrateNoSequence.
  ///
  /// In en, this message translates to:
  /// **'Tap results in order.'**
  String get calibrateNoSequence;

  /// No description provided for @calibrateInvalidTarget.
  ///
  /// In en, this message translates to:
  /// **'Fix the target time and window values.'**
  String get calibrateInvalidTarget;

  /// No description provided for @calibrateTargetSeedTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Tap Get Seed Time and select a time that generates the target seed before searching seed.'**
  String get calibrateTargetSeedTimeRequired;

  /// No description provided for @calibrateNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matching seed.'**
  String get calibrateNoMatches;

  /// No description provided for @coinMagikarp.
  ///
  /// In en, this message translates to:
  /// **'Magikarp'**
  String get coinMagikarp;

  /// No description provided for @coinPokeBall.
  ///
  /// In en, this message translates to:
  /// **'Poke Ball'**
  String get coinPokeBall;

  /// No description provided for @coinMagikarpShort.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get coinMagikarpShort;

  /// No description provided for @coinPokeBallShort.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get coinPokeBallShort;

  /// No description provided for @phoneElmShort.
  ///
  /// In en, this message translates to:
  /// **'E'**
  String get phoneElmShort;

  /// No description provided for @phoneKantoShort.
  ///
  /// In en, this message translates to:
  /// **'K'**
  String get phoneKantoShort;

  /// No description provided for @phonePokerusShort.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get phonePokerusShort;

  /// No description provided for @phoneElmMessage.
  ///
  /// In en, this message translates to:
  /// **'E - There are so many different ways that Pokémon evolve...'**
  String get phoneElmMessage;

  /// No description provided for @phoneKantoMessage.
  ///
  /// In en, this message translates to:
  /// **'K - I expect there are some Pokémon in the Kanto region...'**
  String get phoneKantoMessage;

  /// No description provided for @phonePokerusMessage.
  ///
  /// In en, this message translates to:
  /// **'P - It seems that Pokémon that have been infected with Pokérus...'**
  String get phonePokerusMessage;

  /// No description provided for @phoneIrwinElmMessage.
  ///
  /// In en, this message translates to:
  /// **'E - Hearing about your escapades rocks my soul...'**
  String get phoneIrwinElmMessage;

  /// No description provided for @phoneIrwinKantoMessage.
  ///
  /// In en, this message translates to:
  /// **'K - I\'m so glad you called...'**
  String get phoneIrwinKantoMessage;

  /// No description provided for @phoneIrwinPokerusMessage.
  ///
  /// In en, this message translates to:
  /// **'P - How are you? What are you doing?'**
  String get phoneIrwinPokerusMessage;

  /// No description provided for @matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @retailTimer.
  ///
  /// In en, this message translates to:
  /// **'Retail Timer'**
  String get retailTimer;

  /// No description provided for @timerPreparation.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get timerPreparation;

  /// No description provided for @timerFirstCountdown.
  ///
  /// In en, this message translates to:
  /// **'First Timer'**
  String get timerFirstCountdown;

  /// No description provided for @timerSecondCountdown.
  ///
  /// In en, this message translates to:
  /// **'Second Timer'**
  String get timerSecondCountdown;

  /// No description provided for @timerCurrentCountdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get timerCurrentCountdown;

  /// No description provided for @timerReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get timerReady;

  /// No description provided for @timerFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get timerFinished;

  /// No description provided for @timerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get timerStart;

  /// No description provided for @timerStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get timerStop;

  /// No description provided for @timerTargetDelay.
  ///
  /// In en, this message translates to:
  /// **'Target Delay'**
  String get timerTargetDelay;

  /// No description provided for @timerTargetSecond.
  ///
  /// In en, this message translates to:
  /// **'Target Second'**
  String get timerTargetSecond;

  /// No description provided for @timerCalibratedDelay.
  ///
  /// In en, this message translates to:
  /// **'Calibrated Delay'**
  String get timerCalibratedDelay;

  /// No description provided for @timerCalibratedSecond.
  ///
  /// In en, this message translates to:
  /// **'Calibrated Second'**
  String get timerCalibratedSecond;

  /// No description provided for @idRngSettings.
  ///
  /// In en, this message translates to:
  /// **'ID RNG Settings'**
  String get idRngSettings;

  /// No description provided for @idRngCalibratedDelay.
  ///
  /// In en, this message translates to:
  /// **'ID Calibrated Delay'**
  String get idRngCalibratedDelay;

  /// No description provided for @eggRngSettings.
  ///
  /// In en, this message translates to:
  /// **'Egg RNG Settings'**
  String get eggRngSettings;

  /// No description provided for @eggRngCalibratedDelay.
  ///
  /// In en, this message translates to:
  /// **'Egg Calibrated Delay'**
  String get eggRngCalibratedDelay;

  /// No description provided for @timerDelayHit.
  ///
  /// In en, this message translates to:
  /// **'Delay Hit'**
  String get timerDelayHit;

  /// No description provided for @timerApplyCalibration.
  ///
  /// In en, this message translates to:
  /// **'Apply Calibration'**
  String get timerApplyCalibration;

  /// No description provided for @timerCalibrationAppliedTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibration Applied'**
  String get timerCalibrationAppliedTitle;

  /// No description provided for @timerCalibrationDelayChange.
  ///
  /// In en, this message translates to:
  /// **'Calibrated Delay: {before} -> {after}'**
  String timerCalibrationDelayChange(String before, String after);

  /// No description provided for @timerCalibrationSecondChange.
  ///
  /// In en, this message translates to:
  /// **'Calibrated Second: {before} -> {after}'**
  String timerCalibrationSecondChange(String before, String after);

  /// No description provided for @timerCalibrationFirstCountdownChange.
  ///
  /// In en, this message translates to:
  /// **'First Timer: {before} -> {after}'**
  String timerCalibrationFirstCountdownChange(String before, String after);

  /// No description provided for @timerCalibrationSecondCountdownChange.
  ///
  /// In en, this message translates to:
  /// **'Second Timer: {before} -> {after}'**
  String timerCalibrationSecondCountdownChange(String before, String after);

  /// No description provided for @timerConsole.
  ///
  /// In en, this message translates to:
  /// **'Console'**
  String get timerConsole;

  /// No description provided for @timerConsoleGba.
  ///
  /// In en, this message translates to:
  /// **'GBA'**
  String get timerConsoleGba;

  /// No description provided for @timerConsoleNdsSlot1.
  ///
  /// In en, this message translates to:
  /// **'NDS - Slot 1'**
  String get timerConsoleNdsSlot1;

  /// No description provided for @timerConsoleNdsSlot2.
  ///
  /// In en, this message translates to:
  /// **'NDS - Slot 2'**
  String get timerConsoleNdsSlot2;

  /// No description provided for @timerConsoleDsi.
  ///
  /// In en, this message translates to:
  /// **'DSi'**
  String get timerConsoleDsi;

  /// No description provided for @timerConsole3ds.
  ///
  /// In en, this message translates to:
  /// **'3DS'**
  String get timerConsole3ds;

  /// No description provided for @timerConsoleCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get timerConsoleCustom;

  /// No description provided for @timerCustomFrameRate.
  ///
  /// In en, this message translates to:
  /// **'Custom Frame Rate'**
  String get timerCustomFrameRate;

  /// No description provided for @timerMinimumLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum Length'**
  String get timerMinimumLength;

  /// No description provided for @timerPrecisionCalibration.
  ///
  /// In en, this message translates to:
  /// **'Precision Calibration'**
  String get timerPrecisionCalibration;

  /// No description provided for @timerMinutesBeforeTarget.
  ///
  /// In en, this message translates to:
  /// **'Set clock {minutes} min before target'**
  String timerMinutesBeforeTarget(String minutes);

  /// No description provided for @timerNdsSetTime.
  ///
  /// In en, this message translates to:
  /// **'Set NDS time to {time}'**
  String timerNdsSetTime(String time);

  /// No description provided for @timerPhase.
  ///
  /// In en, this message translates to:
  /// **'Phase {phase}'**
  String timerPhase(String phase);

  /// No description provided for @timerInputError.
  ///
  /// In en, this message translates to:
  /// **'Check timer values.'**
  String get timerInputError;

  /// No description provided for @timerWebSoundUnsupported.
  ///
  /// In en, this message translates to:
  /// **'The web timer does not support countdown audio yet.'**
  String get timerWebSoundUnsupported;

  /// No description provided for @reverseHitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Reverse Hit Feedback'**
  String get reverseHitFeedback;

  /// No description provided for @reverseHitSeedMatched.
  ///
  /// In en, this message translates to:
  /// **'Seed Hit'**
  String get reverseHitSeedMatched;

  /// No description provided for @reverseHitSeedMissed.
  ///
  /// In en, this message translates to:
  /// **'Seed Missed'**
  String get reverseHitSeedMissed;

  /// No description provided for @reverseHitTargetAdvance.
  ///
  /// In en, this message translates to:
  /// **'Target Adv'**
  String get reverseHitTargetAdvance;

  /// No description provided for @reverseHitActualAdvance.
  ///
  /// In en, this message translates to:
  /// **'Actual Adv'**
  String get reverseHitActualAdvance;

  /// No description provided for @reverseHitAdvanceDelta.
  ///
  /// In en, this message translates to:
  /// **'Advance delta: {delta}'**
  String reverseHitAdvanceDelta(String delta);

  /// No description provided for @observedHit.
  ///
  /// In en, this message translates to:
  /// **'Observed Hit'**
  String get observedHit;

  /// No description provided for @starterObservedHit.
  ///
  /// In en, this message translates to:
  /// **'Starter Hit'**
  String get starterObservedHit;

  /// No description provided for @characteristic.
  ///
  /// In en, this message translates to:
  /// **'Characteristic'**
  String get characteristic;

  /// No description provided for @characteristicOptions.
  ///
  /// In en, this message translates to:
  /// **'Loves to eat|Takes plenty of siestas|Nods off a lot|Scatters things often|Likes to relax|Proud of its power|Likes to thrash about|A little quick tempered|Likes to fight|Quick tempered|Sturdy body|Capable of taking hits|Highly persistent|Good endurance|Good perseverance|Likes to run|Alert to sounds|Impetuous and silly|Somewhat of a clown|Quick to flee|Highly curious|Mischievous|Thoroughly cunning|Often lost in thought|Very finicky|Strong willed|Somewhat vain|Strongly defiant|Hates to lose|Somewhat stubborn'**
  String get characteristicOptions;

  /// No description provided for @reverseHitSearch.
  ///
  /// In en, this message translates to:
  /// **'Reverse Search Pokemon'**
  String get reverseHitSearch;

  /// No description provided for @reverseHitTitle.
  ///
  /// In en, this message translates to:
  /// **'Reverse Search'**
  String get reverseHitTitle;

  /// No description provided for @reverseHitNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching results.'**
  String get reverseHitNoResults;

  /// No description provided for @reverseHitTargetSeed.
  ///
  /// In en, this message translates to:
  /// **'Target Seed'**
  String get reverseHitTargetSeed;

  /// No description provided for @reverseHitNearbySeed.
  ///
  /// In en, this message translates to:
  /// **'Nearby Seed'**
  String get reverseHitNearbySeed;

  /// No description provided for @searchDisabledSelectPokemon.
  ///
  /// In en, this message translates to:
  /// **'Select a Pokemon first.'**
  String get searchDisabledSelectPokemon;

  /// No description provided for @searchDisabledQueryLocations.
  ///
  /// In en, this message translates to:
  /// **'Query locations after choosing a Pokemon.'**
  String get searchDisabledQueryLocations;

  /// No description provided for @searchDisabledSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select a location.'**
  String get searchDisabledSelectLocation;

  /// No description provided for @searchDisabledInvalidRange.
  ///
  /// In en, this message translates to:
  /// **'Fix the search range values.'**
  String get searchDisabledInvalidRange;

  /// No description provided for @searchDisabledSearchSpaceTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Narrow the search space to {max} or fewer states.'**
  String searchDisabledSearchSpaceTooLarge(String max);

  /// No description provided for @searchDisabledInvalidIvs.
  ///
  /// In en, this message translates to:
  /// **'Enter IV values from 0 to 31.'**
  String get searchDisabledInvalidIvs;

  /// No description provided for @searchDisabledIvRangeTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Narrow IV ranges to {max} or fewer combinations.'**
  String searchDisabledIvRangeTooLarge(String max);

  /// No description provided for @searchDisabledInvalidHiddenPower.
  ///
  /// In en, this message translates to:
  /// **'Enter Hidden Power strength from 30 to 70.'**
  String get searchDisabledInvalidHiddenPower;

  /// No description provided for @searchDisabledUnsupportedSource.
  ///
  /// In en, this message translates to:
  /// **'This source cannot be searched yet.'**
  String get searchDisabledUnsupportedSource;

  /// No description provided for @searchDisabledDelayYearOverflow.
  ///
  /// In en, this message translates to:
  /// **'Delay range is outside this year\'s valid seed range.'**
  String get searchDisabledDelayYearOverflow;

  /// No description provided for @searchDisabledAlreadyRunning.
  ///
  /// In en, this message translates to:
  /// **'A search is already running.'**
  String get searchDisabledAlreadyRunning;

  /// No description provided for @any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @gbaRuby.
  ///
  /// In en, this message translates to:
  /// **'Ruby'**
  String get gbaRuby;

  /// No description provided for @gbaSapphire.
  ///
  /// In en, this message translates to:
  /// **'Sapphire'**
  String get gbaSapphire;

  /// No description provided for @gbaEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald'**
  String get gbaEmerald;

  /// No description provided for @gbaFireRed.
  ///
  /// In en, this message translates to:
  /// **'FireRed'**
  String get gbaFireRed;

  /// No description provided for @gbaLeafGreen.
  ///
  /// In en, this message translates to:
  /// **'LeafGreen'**
  String get gbaLeafGreen;

  /// No description provided for @leadNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get leadNone;

  /// No description provided for @leadSynchronize.
  ///
  /// In en, this message translates to:
  /// **'Synchronize'**
  String get leadSynchronize;

  /// No description provided for @leadCuteCharmMale.
  ///
  /// In en, this message translates to:
  /// **'Cute Charm Male'**
  String get leadCuteCharmMale;

  /// No description provided for @leadCuteCharmFemale.
  ///
  /// In en, this message translates to:
  /// **'Cute Charm Female'**
  String get leadCuteCharmFemale;

  /// No description provided for @leadCompoundEyes.
  ///
  /// In en, this message translates to:
  /// **'CompoundEyes'**
  String get leadCompoundEyes;

  /// No description provided for @leadPressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get leadPressure;

  /// No description provided for @leadSuctionCups.
  ///
  /// In en, this message translates to:
  /// **'Suction Cups'**
  String get leadSuctionCups;

  /// No description provided for @leadArenaTrap.
  ///
  /// In en, this message translates to:
  /// **'Arena Trap'**
  String get leadArenaTrap;

  /// No description provided for @leadMagnetPull.
  ///
  /// In en, this message translates to:
  /// **'Magnet Pull'**
  String get leadMagnetPull;

  /// No description provided for @leadStatic.
  ///
  /// In en, this message translates to:
  /// **'Static'**
  String get leadStatic;

  /// No description provided for @typeFighting.
  ///
  /// In en, this message translates to:
  /// **'Fighting'**
  String get typeFighting;

  /// No description provided for @typeFlying.
  ///
  /// In en, this message translates to:
  /// **'Flying'**
  String get typeFlying;

  /// No description provided for @typePoison.
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get typePoison;

  /// No description provided for @typeGround.
  ///
  /// In en, this message translates to:
  /// **'Ground'**
  String get typeGround;

  /// No description provided for @typeRock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get typeRock;

  /// No description provided for @typeBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get typeBug;

  /// No description provided for @typeGhost.
  ///
  /// In en, this message translates to:
  /// **'Ghost'**
  String get typeGhost;

  /// No description provided for @typeSteel.
  ///
  /// In en, this message translates to:
  /// **'Steel'**
  String get typeSteel;

  /// No description provided for @typeFire.
  ///
  /// In en, this message translates to:
  /// **'Fire'**
  String get typeFire;

  /// No description provided for @typeWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get typeWater;

  /// No description provided for @typeGrass.
  ///
  /// In en, this message translates to:
  /// **'Grass'**
  String get typeGrass;

  /// No description provided for @typeElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get typeElectric;

  /// No description provided for @typePsychic.
  ///
  /// In en, this message translates to:
  /// **'Psychic'**
  String get typePsychic;

  /// No description provided for @typeIce.
  ///
  /// In en, this message translates to:
  /// **'Ice'**
  String get typeIce;

  /// No description provided for @typeDragon.
  ///
  /// In en, this message translates to:
  /// **'Dragon'**
  String get typeDragon;

  /// No description provided for @typeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get typeDark;

  /// No description provided for @idRng.
  ///
  /// In en, this message translates to:
  /// **'ID RNG'**
  String get idRng;

  /// No description provided for @idRngTarget.
  ///
  /// In en, this message translates to:
  /// **'Target ID'**
  String get idRngTarget;

  /// No description provided for @idRngSearch.
  ///
  /// In en, this message translates to:
  /// **'Search IDs'**
  String get idRngSearch;

  /// No description provided for @idRngSearchAll.
  ///
  /// In en, this message translates to:
  /// **'Search IDs (All)'**
  String get idRngSearchAll;

  /// No description provided for @idRngResults.
  ///
  /// In en, this message translates to:
  /// **'ID Results'**
  String get idRngResults;

  /// No description provided for @idRngTimer.
  ///
  /// In en, this message translates to:
  /// **'ID Timer'**
  String get idRngTimer;

  /// No description provided for @idRngHitCheck.
  ///
  /// In en, this message translates to:
  /// **'Actual ID Check'**
  String get idRngHitCheck;

  /// No description provided for @idRngMinSid.
  ///
  /// In en, this message translates to:
  /// **'Min SID'**
  String get idRngMinSid;

  /// No description provided for @idRngMaxSid.
  ///
  /// In en, this message translates to:
  /// **'Max SID'**
  String get idRngMaxSid;

  /// No description provided for @idRngTargetPid.
  ///
  /// In en, this message translates to:
  /// **'Target PID'**
  String get idRngTargetPid;

  /// No description provided for @idRngTargetTsv.
  ///
  /// In en, this message translates to:
  /// **'Target TSV'**
  String get idRngTargetTsv;

  /// No description provided for @idRngExtraTargetFilters.
  ///
  /// In en, this message translates to:
  /// **'Extra Target Filters'**
  String get idRngExtraTargetFilters;

  /// No description provided for @cuteCharmIdTarget.
  ///
  /// In en, this message translates to:
  /// **'Cute Charm ID Target'**
  String get cuteCharmIdTarget;

  /// No description provided for @idRngPidTargetFinder.
  ///
  /// In en, this message translates to:
  /// **'PID Target Finder'**
  String get idRngPidTargetFinder;

  /// No description provided for @idRngExcellentSidFinder.
  ///
  /// In en, this message translates to:
  /// **'Excellent SID Finder'**
  String get idRngExcellentSidFinder;

  /// No description provided for @idRngReachableExcellentSidFinder.
  ///
  /// In en, this message translates to:
  /// **'Find SID'**
  String get idRngReachableExcellentSidFinder;

  /// No description provided for @idRngReachableExcellentSidSearch.
  ///
  /// In en, this message translates to:
  /// **'Search SID'**
  String get idRngReachableExcellentSidSearch;

  /// No description provided for @idRngQuickGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get idRngQuickGuide;

  /// No description provided for @idRngQuickGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the TID you want. Min SID and Max SID can be left blank.\nTap Excellent SID Finder, review the displayed PIDs, choose the SID range you want, then tap a card to return and fill the fields automatically.\nEnter the year next. A minimum Delay of at least 5000 is recommended, because a new game usually needs that much time for setup.\nTap Search SID and choose the desired result. The page returns to ID RNG and shows the timer.\nUse the timer to set the DS time, start the game, finish character creation, then wait on the TV screen. Press A exactly when the timer countdown ends.\nUse the TID you actually received to calibrate the timer, then repeat the attempt.'**
  String get idRngQuickGuideBody;

  /// No description provided for @idRngExcellentSidSearch.
  ///
  /// In en, this message translates to:
  /// **'Search Excellent SID'**
  String get idRngExcellentSidSearch;

  /// No description provided for @idRngExcellentSidResults.
  ///
  /// In en, this message translates to:
  /// **'Best Target TSV Groups'**
  String get idRngExcellentSidResults;

  /// No description provided for @idRngIncludeNeutralNatures.
  ///
  /// In en, this message translates to:
  /// **'Show neutral natures'**
  String get idRngIncludeNeutralNatures;

  /// No description provided for @idRngSortByNatureCount.
  ///
  /// In en, this message translates to:
  /// **'Most Natures'**
  String get idRngSortByNatureCount;

  /// No description provided for @idRngSortByTargetCount.
  ///
  /// In en, this message translates to:
  /// **'Most Targets'**
  String get idRngSortByTargetCount;

  /// No description provided for @idRngExcellentSidGroup.
  ///
  /// In en, this message translates to:
  /// **'TSV {tsv}'**
  String idRngExcellentSidGroup(String tsv);

  /// No description provided for @idRngPidTargetCount.
  ///
  /// In en, this message translates to:
  /// **'{count} targets'**
  String idRngPidTargetCount(String count);

  /// No description provided for @idRngNatureCount.
  ///
  /// In en, this message translates to:
  /// **'{count} natures'**
  String idRngNatureCount(String count);

  /// No description provided for @idRngSidRangeShort.
  ///
  /// In en, this message translates to:
  /// **'SID {range}'**
  String idRngSidRangeShort(String range);

  /// No description provided for @idRngPidTargetNatures.
  ///
  /// In en, this message translates to:
  /// **'Target Natures'**
  String get idRngPidTargetNatures;

  /// No description provided for @idRngPidTargetMinIvs.
  ///
  /// In en, this message translates to:
  /// **'Minimum IVs'**
  String get idRngPidTargetMinIvs;

  /// No description provided for @idRngPidTargetSearch.
  ///
  /// In en, this message translates to:
  /// **'Search PID Targets'**
  String get idRngPidTargetSearch;

  /// No description provided for @idRngPidTargetResults.
  ///
  /// In en, this message translates to:
  /// **'PID Target Results'**
  String get idRngPidTargetResults;

  /// No description provided for @idRngPidTargetNoResults.
  ///
  /// In en, this message translates to:
  /// **'No PID targets.'**
  String get idRngPidTargetNoResults;

  /// No description provided for @idRngPidTargetInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Check the nature and IV filters.'**
  String get idRngPidTargetInvalidInput;

  /// No description provided for @idRngPidTargetGroup.
  ///
  /// In en, this message translates to:
  /// **'PSV {psv} · {count} targets'**
  String idRngPidTargetGroup(String psv, String count);

  /// No description provided for @idRngPidTargetGroupWithSid.
  ///
  /// In en, this message translates to:
  /// **'PSV {psv} · {count} targets · SID {sidRange}'**
  String idRngPidTargetGroupWithSid(String psv, String count, String sidRange);

  /// No description provided for @idRngPidTargetResult.
  ///
  /// In en, this message translates to:
  /// **'PID {pid} · {nature} · IVs {ivs} · Ability {ability}'**
  String idRngPidTargetResult(
    String pid,
    String nature,
    String ivs,
    String ability,
  );

  /// No description provided for @genderRatio.
  ///
  /// In en, this message translates to:
  /// **'Gender Ratio'**
  String get genderRatio;

  /// No description provided for @cuteCharmIdSummary.
  ///
  /// In en, this message translates to:
  /// **'PID {pid} · TSV {tsv} · Ability {ability} · Target Gender {gender}'**
  String cuteCharmIdSummary(
    String pid,
    String tsv,
    String ability,
    String gender,
  );

  /// No description provided for @cuteCharmApplyIdTarget.
  ///
  /// In en, this message translates to:
  /// **'Apply to ID Search'**
  String get cuteCharmApplyIdTarget;

  /// No description provided for @idRngSearchSpace.
  ///
  /// In en, this message translates to:
  /// **'Search space: {states} seeds'**
  String idRngSearchSpace(String states);

  /// No description provided for @idRngNeedFilter.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one TID, SID, TSV, or PID filter.'**
  String get idRngNeedFilter;

  /// No description provided for @idRngInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Check the ID RNG parameters.'**
  String get idRngInvalidInput;

  /// No description provided for @idRngPidSummary.
  ///
  /// In en, this message translates to:
  /// **'PSV {psv} · Nature {nature}'**
  String idRngPidSummary(String psv, String nature);

  /// No description provided for @idRngSidRange.
  ///
  /// In en, this message translates to:
  /// **'Shiny SID: {range}'**
  String idRngSidRange(String range);

  /// No description provided for @idRngSidCandidates.
  ///
  /// In en, this message translates to:
  /// **'SID Candidates: {values}'**
  String idRngSidCandidates(String values);

  /// No description provided for @idRngSelectedState.
  ///
  /// In en, this message translates to:
  /// **'Selected ID Result'**
  String get idRngSelectedState;

  /// No description provided for @idRngSelectResultFirst.
  ///
  /// In en, this message translates to:
  /// **'Select an ID result first.'**
  String get idRngSelectResultFirst;

  /// No description provided for @idRngNoSeedTime.
  ///
  /// In en, this message translates to:
  /// **'Get and select a seed time first.'**
  String get idRngNoSeedTime;

  /// No description provided for @idRngResultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'TID {tid} · SID {sid} · TSV {tsv}'**
  String idRngResultSubtitle(String tid, String sid, String tsv);

  /// No description provided for @idRngSearchHit.
  ///
  /// In en, this message translates to:
  /// **'Reverse Hit Delay'**
  String get idRngSearchHit;

  /// No description provided for @idRngHitDelayWindow.
  ///
  /// In en, this message translates to:
  /// **'Delay +/-'**
  String get idRngHitDelayWindow;

  /// No description provided for @idRngHitResults.
  ///
  /// In en, this message translates to:
  /// **'ID Hit Results'**
  String get idRngHitResults;

  /// No description provided for @idRngSelectedHit.
  ///
  /// In en, this message translates to:
  /// **'Selected ID Hit'**
  String get idRngSelectedHit;

  /// No description provided for @idRngNoHit.
  ///
  /// In en, this message translates to:
  /// **'No matching TID/SID.'**
  String get idRngNoHit;

  /// No description provided for @idRngHitHelp.
  ///
  /// In en, this message translates to:
  /// **'This result has filled Delay Hit in the ID timer. Tap Apply Calibration to update ID Calibrated Delay only; the encounter timer delay is not changed.'**
  String get idRngHitHelp;

  /// No description provided for @gen4TargetCategoryWild.
  ///
  /// In en, this message translates to:
  /// **'Wild'**
  String get gen4TargetCategoryWild;

  /// No description provided for @gen4TargetCategoryStationary.
  ///
  /// In en, this message translates to:
  /// **'Stationary'**
  String get gen4TargetCategoryStationary;

  /// No description provided for @gen4TargetCategoryLegend.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get gen4TargetCategoryLegend;

  /// No description provided for @gen4TargetCategoryGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get gen4TargetCategoryGift;

  /// No description provided for @gen4TargetCategoryStarter.
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get gen4TargetCategoryStarter;

  /// No description provided for @gen4TargetCategoryFossil.
  ///
  /// In en, this message translates to:
  /// **'Fossil'**
  String get gen4TargetCategoryFossil;

  /// No description provided for @gen4TargetCategoryGameCorner.
  ///
  /// In en, this message translates to:
  /// **'Game Corner'**
  String get gen4TargetCategoryGameCorner;

  /// No description provided for @gen4TargetCategoryEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get gen4TargetCategoryEvent;

  /// No description provided for @gen4TargetCategoryRoamer.
  ///
  /// In en, this message translates to:
  /// **'Roamer'**
  String get gen4TargetCategoryRoamer;

  /// No description provided for @gen4TargetWildGrass.
  ///
  /// In en, this message translates to:
  /// **'Grass'**
  String get gen4TargetWildGrass;

  /// No description provided for @gen4TargetWildSurfing.
  ///
  /// In en, this message translates to:
  /// **'Surfing'**
  String get gen4TargetWildSurfing;

  /// No description provided for @gen4TargetWildOldRod.
  ///
  /// In en, this message translates to:
  /// **'Old Rod'**
  String get gen4TargetWildOldRod;

  /// No description provided for @gen4TargetWildGoodRod.
  ///
  /// In en, this message translates to:
  /// **'Good Rod'**
  String get gen4TargetWildGoodRod;

  /// No description provided for @gen4TargetWildSuperRod.
  ///
  /// In en, this message translates to:
  /// **'Super Rod'**
  String get gen4TargetWildSuperRod;

  /// No description provided for @gen4TargetWildRockSmash.
  ///
  /// In en, this message translates to:
  /// **'Rock Smash'**
  String get gen4TargetWildRockSmash;

  /// No description provided for @gen4TargetWildBugCatchingContest.
  ///
  /// In en, this message translates to:
  /// **'Bug-Catching Contest'**
  String get gen4TargetWildBugCatchingContest;

  /// No description provided for @gen4TargetWildHeadbutt.
  ///
  /// In en, this message translates to:
  /// **'Headbutt'**
  String get gen4TargetWildHeadbutt;

  /// No description provided for @gen4TargetWildHeadbuttAlt.
  ///
  /// In en, this message translates to:
  /// **'Headbutt Alt'**
  String get gen4TargetWildHeadbuttAlt;

  /// No description provided for @gen4TargetWildHeadbuttSpecial.
  ///
  /// In en, this message translates to:
  /// **'Headbutt Special'**
  String get gen4TargetWildHeadbuttSpecial;

  /// No description provided for @gen4TargetWildHoneyTree.
  ///
  /// In en, this message translates to:
  /// **'Honey Tree'**
  String get gen4TargetWildHoneyTree;

  /// No description provided for @gen4TargetTimeMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get gen4TargetTimeMorning;

  /// No description provided for @gen4TargetTimeDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get gen4TargetTimeDay;

  /// No description provided for @gen4TargetTimeNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get gen4TargetTimeNight;

  /// No description provided for @gen4TargetMethodMethod1.
  ///
  /// In en, this message translates to:
  /// **'Method 1'**
  String get gen4TargetMethodMethod1;

  /// No description provided for @gen4TargetMethodMethodJ.
  ///
  /// In en, this message translates to:
  /// **'Method J'**
  String get gen4TargetMethodMethodJ;

  /// No description provided for @gen4TargetMethodMethodK.
  ///
  /// In en, this message translates to:
  /// **'Method K'**
  String get gen4TargetMethodMethodK;

  /// No description provided for @gen4TargetMethodHoneyTree.
  ///
  /// In en, this message translates to:
  /// **'Honey Tree'**
  String get gen4TargetMethodHoneyTree;

  /// No description provided for @gen4TargetMethodPokeRadar.
  ///
  /// In en, this message translates to:
  /// **'Poke Radar'**
  String get gen4TargetMethodPokeRadar;

  /// No description provided for @gen4TargetMethodPokeRadarShiny.
  ///
  /// In en, this message translates to:
  /// **'Poke Radar Shiny'**
  String get gen4TargetMethodPokeRadarShiny;

  /// No description provided for @gen4TargetStaticStarter.
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get gen4TargetStaticStarter;

  /// No description provided for @gen4TargetStaticFossil.
  ///
  /// In en, this message translates to:
  /// **'Fossil'**
  String get gen4TargetStaticFossil;

  /// No description provided for @gen4TargetStaticGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get gen4TargetStaticGift;

  /// No description provided for @gen4TargetStaticGameCorner.
  ///
  /// In en, this message translates to:
  /// **'Game Corner'**
  String get gen4TargetStaticGameCorner;

  /// No description provided for @gen4TargetStaticStationary.
  ///
  /// In en, this message translates to:
  /// **'Stationary'**
  String get gen4TargetStaticStationary;

  /// No description provided for @gen4TargetStaticLegend.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get gen4TargetStaticLegend;

  /// No description provided for @gen4TargetStaticEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get gen4TargetStaticEvent;

  /// No description provided for @gen4TargetStaticRoamer.
  ///
  /// In en, this message translates to:
  /// **'Roamer'**
  String get gen4TargetStaticRoamer;

  /// No description provided for @gen4TargetShinyRandom.
  ///
  /// In en, this message translates to:
  /// **'Random shiny'**
  String get gen4TargetShinyRandom;

  /// No description provided for @gen4TargetShinyAlways.
  ///
  /// In en, this message translates to:
  /// **'Always shiny'**
  String get gen4TargetShinyAlways;

  /// No description provided for @gen4TargetShinyNever.
  ///
  /// In en, this message translates to:
  /// **'Shiny locked'**
  String get gen4TargetShinyNever;

  /// No description provided for @gen4TargetModifierSwarm.
  ///
  /// In en, this message translates to:
  /// **'Swarm'**
  String get gen4TargetModifierSwarm;

  /// No description provided for @gen4TargetModifierDay.
  ///
  /// In en, this message translates to:
  /// **'Day slot'**
  String get gen4TargetModifierDay;

  /// No description provided for @gen4TargetModifierNight.
  ///
  /// In en, this message translates to:
  /// **'Night slot'**
  String get gen4TargetModifierNight;

  /// No description provided for @gen4TargetModifierRadar.
  ///
  /// In en, this message translates to:
  /// **'Poke Radar'**
  String get gen4TargetModifierRadar;

  /// No description provided for @gen4TargetModifierRuby.
  ///
  /// In en, this message translates to:
  /// **'Ruby inserted'**
  String get gen4TargetModifierRuby;

  /// No description provided for @gen4TargetModifierSapphire.
  ///
  /// In en, this message translates to:
  /// **'Sapphire inserted'**
  String get gen4TargetModifierSapphire;

  /// No description provided for @gen4TargetModifierEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald inserted'**
  String get gen4TargetModifierEmerald;

  /// No description provided for @gen4TargetModifierFireRed.
  ///
  /// In en, this message translates to:
  /// **'FireRed inserted'**
  String get gen4TargetModifierFireRed;

  /// No description provided for @gen4TargetModifierLeafGreen.
  ///
  /// In en, this message translates to:
  /// **'LeafGreen inserted'**
  String get gen4TargetModifierLeafGreen;

  /// No description provided for @gen4TargetModifierFeebasTile.
  ///
  /// In en, this message translates to:
  /// **'Feebas tile'**
  String get gen4TargetModifierFeebasTile;

  /// No description provided for @gen4TargetModifierHoennSound.
  ///
  /// In en, this message translates to:
  /// **'Hoenn Sound'**
  String get gen4TargetModifierHoennSound;

  /// No description provided for @gen4TargetModifierSinnohSound.
  ///
  /// In en, this message translates to:
  /// **'Sinnoh Sound'**
  String get gen4TargetModifierSinnohSound;

  /// No description provided for @gen4TargetModifierFishNight.
  ///
  /// In en, this message translates to:
  /// **'Night fishing'**
  String get gen4TargetModifierFishNight;

  /// No description provided for @gen4TargetModifierFishSwarm.
  ///
  /// In en, this message translates to:
  /// **'Fishing swarm'**
  String get gen4TargetModifierFishSwarm;

  /// No description provided for @gen4TargetModifierSafariBlocks.
  ///
  /// In en, this message translates to:
  /// **'Safari blocks'**
  String get gen4TargetModifierSafariBlocks;

  /// No description provided for @gen4TargetModifierUnknown.
  ///
  /// In en, this message translates to:
  /// **'Special slot'**
  String get gen4TargetModifierUnknown;

  /// No description provided for @gen4TargetLevel.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level}'**
  String gen4TargetLevel(int level);

  /// No description provided for @gen4TargetLevelRange.
  ///
  /// In en, this message translates to:
  /// **'Lv. {minLevel}-{maxLevel}'**
  String gen4TargetLevelRange(int minLevel, int maxLevel);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

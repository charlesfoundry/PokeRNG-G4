// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'PokeRNG G4';

  @override
  String get target => 'ターゲット';

  @override
  String get search => '検索';

  @override
  String get egg => 'タマゴ';

  @override
  String get eggCrossSaveTitle => '別のセーブ用の色違いタマゴを生成';

  @override
  String get eggCrossSaveNoteBefore =>
      '第4世代のタマゴ乱数では、別のセーブデータのTID/SIDを一時的に入力してタマゴを生成できます。そのタマゴを相手のセーブに渡した場合、';

  @override
  String get eggCrossSaveNoteEmphasis => '必ずそのセーブで孵化する必要があります';

  @override
  String get eggCrossSaveNoteAfter =>
      '。そうすると、そのトレーナーIDの色違いポケモンになります。なお、孵化演出はタマゴ受取時に決まっています。タマゴを受け取ったセーブのIDでは色違いにならない場合、あとで対象のセーブへ渡して孵化しても、孵化演出は通常色のまま表示されることがあります。孵化後に手持ちの詳細を確認すれば、色違いであることを確認できます。';

  @override
  String get eggHgssTitle => 'HGSSタマゴ乱数アルゴリズム';

  @override
  String get eggHgssAlgorithmNote =>
      'このページは常にHGSSのタマゴ乱数アルゴリズムを使用します。TID/SIDは現在のゲームの保存値を初期表示し、一時的に変更できます。実際のタマゴ生成はHGSSで行います。';

  @override
  String get eggDpptTitle => 'DPPtタマゴ乱数アルゴリズム';

  @override
  String get eggDpptAlgorithmNote =>
      'これはDPPtタマゴ乱数用の独立したコピーです。DPPt専用のタマゴ生成・受取アルゴリズムはここに接続し、検証済みのHGSSページは変更しません。';

  @override
  String get eggDpptHeldFrameNote =>
      'DPPtのタマゴ生成ではPID、性格、性別、特性、色違いが決まります。Seed確認にはコイントスを使います。コイントスではEgg Frameは進みません。';

  @override
  String get eggDpptPickupFrameNote =>
      'DPPtのタマゴ受取では個体値と遺伝が決まります。DPPtは初期版の遺伝バグを使うため、このページは検証済みHGSSページとは別のDPPt経路で検索します。';

  @override
  String get eggHgssOnlyTitle => 'HGSSタマゴ乱数のみ対応';

  @override
  String get eggHgssOnlyBody =>
      'DPPtのタマゴは別の遺伝処理です。現在このページはハートゴールド・ソウルシルバー専用です。';

  @override
  String get eggGenerateEggTab => 'タマゴ生成';

  @override
  String get eggPickupEggTab => 'タマゴ受取';

  @override
  String get eggDaycare => '育て屋';

  @override
  String get eggGenderRatio => '性別比';

  @override
  String eggGenderRatioPercent(String male, String female) {
    return '$male% ♂ : $female% ♀';
  }

  @override
  String get eggGenderRatioMaleOnly => '100% ♂';

  @override
  String get eggGenderRatioFemaleOnly => '100% ♀';

  @override
  String get eggMasuda => '国際孵化';

  @override
  String get eggParentsSettings => 'タマゴの親';

  @override
  String get eggParentA => '親A個体値';

  @override
  String get eggParentB => '親B個体値';

  @override
  String get eggHeldStage => 'タマゴPID';

  @override
  String get eggFrameOneNote =>
      '簡易モードではEgg Frame 1のみ対応します。このSeedを狙い、育て屋じいさんに最初のタマゴを生成させます。';

  @override
  String get eggPhoneFrameNote =>
      'タマゴ生成ではPID、性格、性別、特性、色違いが決まります。Egg Frameは育て屋じいさんがタマゴを生成するときのPID消費です。ウツギ/マイクの電話はSeed確認用で、Egg Frame消費として自動扱いしません。';

  @override
  String get eggPickupFrameNote =>
      'タマゴ受取では個体値と遺伝が決まります。個体生成では年、Delay範囲、受取消費範囲で検索します。逆算はSeed命中済みとして、選択済みまたは確認済みの受取Seed内の受取消費だけを検索します。';

  @override
  String get eggPhoneCalls => '電話回数';

  @override
  String get eggMinFrame => '最小Egg Frame';

  @override
  String get eggMaxFrame => '最大Egg Frame';

  @override
  String get eggTargetEggFrame => 'Egg Frame';

  @override
  String get eggPickupStage => '受取';

  @override
  String get eggHeldSeed => 'PID Seed';

  @override
  String get eggPickupSeed => '受取Seed';

  @override
  String get eggSearchPid => 'PID生成';

  @override
  String get eggPidResultsTitle => 'タマゴPID結果';

  @override
  String get eggSearchIvs => '個体生成';

  @override
  String get eggObservedIvs => '実測個体値';

  @override
  String get eggObservedStats => '実測能力値（Lv.1）';

  @override
  String get eggSelectHatchedPokemon => '孵化したポケモンを選択してください。';

  @override
  String get eggObservedStatsInputError => '孵化したポケモンのLv.1実測能力値を入力してください。';

  @override
  String get eggObservedStatsNoIvRanges =>
      'ポケモン、性格、能力値、または個性が一致しません。入力を確認してください。';

  @override
  String get eggPickupReverseSeedRequired =>
      '先に目標の受取結果を選択するか、Seed検索で命中した受取Seedを確認してください。';

  @override
  String get eggReversePickupSearch => '受取を逆算';

  @override
  String get eggPickupResultsTitle => '受取個体結果';

  @override
  String get eggLockedEgg => '固定済みタマゴ';

  @override
  String get eggLockedPid => '固定PID';

  @override
  String get eggLockedEggNote =>
      'タマゴ受取ではこのPIDの情報だけを使います。タマゴ生成時のDelayとEgg Frameは受取個体乱数には関与せず、受取Seedと受取消費が個体値と遺伝を別に決めます。';

  @override
  String get eggNoPickupTargetSelected => '個体生成結果がまだ選択されていません。';

  @override
  String get eggNoSeedTimeSelected => 'Seed時刻がまだ選択されていません。';

  @override
  String get eggTimerRequiresSeedTime => 'Seed時刻を選択するとタイマーを表示します。';

  @override
  String get eggNoPidResults => '一致するPIDがありません。';

  @override
  String eggResultLimitReached(String count) {
    return '先頭の$count件を表示しています。範囲を絞ってください。';
  }

  @override
  String get eggNoIvResults => '一致する受取結果がありません。';

  @override
  String get eggSelectPidFirst => '先に上のタマゴPIDを選択してください。';

  @override
  String get eggSelectedPid => '選択中PID';

  @override
  String get eggSelectedSeedTime => '選択中Seed時刻';

  @override
  String get eggObservedPid => '実機PID逆算';

  @override
  String get eggReversePidSearch => 'PIDを逆算';

  @override
  String get eggSelectedHitDelay => '選択中の命中Delay';

  @override
  String get eggMinIvsOptional => '最低個体値（空欄可）';

  @override
  String get eggPidAdvance => 'PID消費';

  @override
  String get eggPickupAdvance => '受取消費';

  @override
  String get eggInheritance => '遺伝';

  @override
  String get results => '結果';

  @override
  String get calibrate => '調整';

  @override
  String get tools => 'ツール';

  @override
  String get settings => '設定';

  @override
  String get cancel => 'キャンセル';

  @override
  String get ok => 'OK';

  @override
  String get language => '言語';

  @override
  String get languageSystem => 'システム';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get gameVersion => 'ゲーム';

  @override
  String get gameDiamond => 'ダイヤモンド';

  @override
  String get gamePearl => 'パール';

  @override
  String get gamePlatinum => 'プラチナ';

  @override
  String get gameHeartGold => 'ハートゴールド';

  @override
  String get gameSoulSilver => 'ソウルシルバー';

  @override
  String get trainerProfile => 'トレーナー';

  @override
  String get trainerId => 'TID';

  @override
  String get secretId => 'SID';

  @override
  String get timerDefaults => 'タイマー初期値';

  @override
  String get delayWindow => 'Delay範囲';

  @override
  String get secondWindow => '秒範囲';

  @override
  String get hgssPhoneCaller => 'HGSS電話文';

  @override
  String get maxPhoneCallSkip => '最大初期消費';

  @override
  String get phoneCallerElm => 'ウツギはかせ';

  @override
  String get phoneCallerIrwin => 'ジャグラーのマイク';

  @override
  String get save => '保存';

  @override
  String get settingsInputError => '0から65535までの値を入力してください。';

  @override
  String get settingsTimerInputError => 'Delay、秒、初期消費の初期値を確認してください。';

  @override
  String get settingsEggParentInputError =>
      '親の個体値を確認してください。0から31までの値を入力してください。';

  @override
  String get settingsEggLockedPidInputError =>
      '固定PIDを確認してください。空欄、または8桁の16進数PIDを入力してください。';

  @override
  String get about => 'このアプリについて';

  @override
  String get version => 'バージョン';

  @override
  String get license => 'ライセンス';

  @override
  String get project => 'プロジェクト';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get credits => 'クレジット';

  @override
  String get aboutDescription =>
      '第4世代のダイヤモンド、パール、プラチナ、ハートゴールド、ソウルシルバー向けのマルチプラットフォーム乱数ツールです。';

  @override
  String get unofficialNotice => '非公式の乱数補助ツールです。';

  @override
  String get aboutCredits =>
      'PokeFinder、EonTimer、PokemonRNG コミュニティの研究を参考にしています。';

  @override
  String get copyProjectUrl => 'プロジェクトURLをコピー';

  @override
  String get projectUrlCopied => 'プロジェクトURLをコピーしました';

  @override
  String get supportDeveloper => '開発者を支援';

  @override
  String get supportDescription => '任意のアプリ内課金で継続開発を支援できます。';

  @override
  String get supportNoUnlock => '購入しても追加機能は解放されません。';

  @override
  String get supportUnavailable => '支援購入は現在利用できません。';

  @override
  String get supportThanks => 'ご支援ありがとうございます。';

  @override
  String get supportCancelled => '購入をキャンセルしました。';

  @override
  String get supportPending => '購入は承認待ちです。';

  @override
  String get supportFailed => '購入に失敗しました。あとでもう一度お試しください。';

  @override
  String get retry => '再試行';

  @override
  String get searchMode => '検索モード';

  @override
  String get timeFinder => 'タイムファインダー';

  @override
  String get generator => 'ジェネレーター';

  @override
  String get generatorPlaceholder => 'ジェネレーターの項目はタイムファインダー接続後に追加します。';

  @override
  String get pokemon => 'ポケモン';

  @override
  String get location => '場所';

  @override
  String get timeCondition => '時間';

  @override
  String get gbaCartridge => 'GBAカートリッジ';

  @override
  String get queryLocations => '場所を検索';

  @override
  String get noMatchingLocations => '現在の時間とカートリッジ条件に一致する入手先がありません。';

  @override
  String get noAvailableLocationForGame => '現在のゲームではこのポケモンの入手先がありません。';

  @override
  String get filters => '条件';

  @override
  String get method => 'Method';

  @override
  String get nature => '性格';

  @override
  String get ability => '特性';

  @override
  String abilitySlot(int slot, String name) {
    return '特性 $slot: $name';
  }

  @override
  String get gender => '性別';

  @override
  String get genderMale => '♂';

  @override
  String get genderFemale => '♀';

  @override
  String get genderGenderless => '-';

  @override
  String get hiddenPower => 'めざめるパワー';

  @override
  String get levelShort => 'Lv.';

  @override
  String get minLevel => '最小レベル';

  @override
  String get maxLevel => '最大レベル';

  @override
  String get minPower => '最小威力';

  @override
  String get maxPower => '最大威力';

  @override
  String get slot => 'スロット';

  @override
  String get lead => '先頭';

  @override
  String get syncNature => 'シンクロ性格';

  @override
  String get shiny => '色違い';

  @override
  String get notShiny => '通常色';

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
  String get searchRange => '検索範囲';

  @override
  String get year => '年';

  @override
  String get minDelay => '最小Delay';

  @override
  String get maxDelay => '最大Delay';

  @override
  String get minAdvance => '最小消費';

  @override
  String get maxAdvance => '最大消費';

  @override
  String get second => '秒';

  @override
  String get forceSecond => '秒を固定';

  @override
  String get searchSpaceInvalid => '検索量: 範囲が無効です';

  @override
  String searchSpaceStates(String states) {
    return '検索量: $states states';
  }

  @override
  String searchSpaceTooLarge(String max) {
    return '$max以下に絞ってください';
  }

  @override
  String get searching => '検索中...';

  @override
  String get searchComplete => '検索完了。';

  @override
  String get searchResultsPlaceholder => '検索結果はここに表示されます。';

  @override
  String get noResults => '結果がありません。';

  @override
  String get searchCancelled => '検索をキャンセルしました。';

  @override
  String get searchFailed => '検索に失敗しました。';

  @override
  String get resultLimitReached => '結果の上限に達しました。';

  @override
  String get sendToCalibration => '調整へ送る';

  @override
  String get saveTarget => '目標を保存';

  @override
  String get targetSaved => '目標を保存しました';

  @override
  String get targetAlreadySaved => 'この目標は保存済みです。';

  @override
  String get savedTargets => '保存した目標';

  @override
  String get helpSection => '説明';

  @override
  String get tutorialsTitle => 'チュートリアル';

  @override
  String get tutorialsOpen => 'チュートリアルを見る';

  @override
  String get tutorialNoticeTitle => 'はじめに';

  @override
  String get tutorialNoticeBody =>
      '下のチュートリアルは、作者が実機手順で確認済みの乱数です。載っていないゲームや場面でも、App が対応していないとは限りません。まだ追加検証が必要な場合があります。';

  @override
  String get tutorialCategoryBasics => '基礎';

  @override
  String get tutorialCategoryId => 'ID';

  @override
  String get tutorialCategoryStarter => '御三家';

  @override
  String get tutorialCategoryStationary => '固定';

  @override
  String get tutorialCategoryWild => '野生';

  @override
  String get tutorialCategoryEgg => 'タマゴ';

  @override
  String get leadAbilityHelpTitle => 'DP/Pt/HGSS先頭特性';

  @override
  String get wildSweetScentHelpTitle => 'HGSSあまいかおり';

  @override
  String get noSavedTargets => '結果ページで結果をタップして目標を保存できます。';

  @override
  String get deleteTarget => '目標を削除';

  @override
  String resultCount(String count) {
    return '$count件';
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
  String get advance => '消費';

  @override
  String get hour => '時';

  @override
  String get time => '時刻';

  @override
  String get ivs => '個体値';

  @override
  String get stats => '能力値';

  @override
  String get hpStat => 'HP';

  @override
  String get atkStat => 'こうげき';

  @override
  String get defStat => 'ぼうぎょ';

  @override
  String get spaStat => 'とくこう';

  @override
  String get spdStat => 'とくぼう';

  @override
  String get speStat => 'すばやさ';

  @override
  String get month => '月';

  @override
  String get day => '日';

  @override
  String get minute => '分';

  @override
  String get calibrateSeedCheck => 'Seed確認';

  @override
  String get calibrateCoinFlips => 'DPPtコイン';

  @override
  String get calibratePhoneCalls => 'HGSS電話';

  @override
  String get calibrateParameterHelp =>
      '目標Delayと目標秒は検索結果から入り、今回狙うseedを表します。校準Delayと校準秒は設定ページの値で、本体と入力タイミングの基準です。追加で待つ秒数ではありません。';

  @override
  String get calibrateQuickGuide =>
      '簡易手順：まずコイントスまたは電話でseedを逆算し、実際に当たった秒とDelayを確認します。秒が安定してずれる場合は校準秒を更新し、DelayのずれはHit Delayで校準Delayを再計算します。本番では先にseed確認をせず、タイマー通りに起動して目標操作を行い、捕獲後に実際の命中結果を逆算します。';

  @override
  String get calibrationTarget => '今回の目標';

  @override
  String get noCalibrationTarget => '校準目標がありません。結果ページから目標を校準ページへ送ってください。';

  @override
  String get seedToTime => 'Seed時間を取得';

  @override
  String get seedToTimeTitle => 'Seed to Time';

  @override
  String get seedToTimeSearch => '時間を取得';

  @override
  String get seedToTimeInvalidFilter =>
      '年は2000から2099、月は1から12、日は1から31で入力してください。';

  @override
  String get noSeedTimeResults => '一致する時間がありません。';

  @override
  String get selectedSeedTime => '選択したSeed時間';

  @override
  String get seedSearch => 'Seed検索';

  @override
  String get seedSearchTitle => 'Seed検索';

  @override
  String get selectedSeedHit => '選択した命中Seed';

  @override
  String get selectedSeedHitHelp =>
      'この結果のDelayはタイマーの命中Delayに入力されました。調整を反映すると、校準Delayを更新し、命中秒のずれで校準秒を微調整します。';

  @override
  String get initialAdvance => '初期消費';

  @override
  String get currentAdvance => '現在消費';

  @override
  String get targetAdvance => '目標消費';

  @override
  String get remainingAdvance => '残り消費';

  @override
  String get advanceOffset => 'Offset';

  @override
  String get initialAdvanceFilter => '初期消費';

  @override
  String get advanceOffsetHelp =>
      'DPPtは捕獲後の逆算でoffsetを計算します。HGSSは電話で直接offsetを計算できます。逆算もそのまま使えます。';

  @override
  String get chatotPitches => 'ペラップ音程';

  @override
  String get chatotPitchHigh => '高';

  @override
  String get chatotPitchLow => '低';

  @override
  String chatotTotalAdvances(int count) {
    return 'ペラップ: $count回';
  }

  @override
  String advanceAhead(int count) {
    return 'あと$count消費';
  }

  @override
  String get targetAction => '目標';

  @override
  String get advanceOneFrame => '消費';

  @override
  String get pressA => 'Aを押す';

  @override
  String get delayParityHelpTitle => 'Delayの奇偶切り替え';

  @override
  String get timerTimingHelpTitle => 'DP/Pt/HGSSタイマー入力のタイミング';

  @override
  String get eggHeldHelpTitle => 'HGSSタマゴ生成';

  @override
  String get eggPickupHelpTitle => 'HGSSタマゴ受取';

  @override
  String get chatotAdvanceHelpTitle => 'Pt/HGSSペラップと目標消費';

  @override
  String get hgssStationaryHelpTitle => 'HGSS固定シンボル色違い';

  @override
  String get honeyTreeHelpTitle => 'Ptあまいミツの木色違い';

  @override
  String get platinumStarterHelpTitle => 'Pt御三家色違い';

  @override
  String get platinumIdRngHelpTitle => 'Pt ID乱数';

  @override
  String calibratedSecondCurrent(String second) {
    return '現在の校準秒：$second';
  }

  @override
  String calibratedSecondHit(String second) {
    return '命中秒：$second';
  }

  @override
  String get calibrateTargetTime => '目標時刻';

  @override
  String get calibrateSearchWindow => '確認範囲';

  @override
  String get calibrateTargetDelay => '目標Delay';

  @override
  String get calibrateDelayWindow => 'Delay +/-';

  @override
  String get calibrateSecondWindow => '秒 +/-';

  @override
  String get calibrateObservedSequence => '実測順';

  @override
  String calibratePhoneCallerHelp(String caller) {
    return '現在の電話文：$caller。変更は設定ページで行います。';
  }

  @override
  String get calibrateNoSequence => '実際の結果を順番に押してください。';

  @override
  String get calibrateInvalidTarget => '目標時刻と範囲を修正してください。';

  @override
  String get calibrateTargetSeedTimeRequired =>
      '先にSeed時間を取得し、目標seedを生成する時間を選択してからSeed検索してください。';

  @override
  String get calibrateNoMatches => '一致するseedがありません。';

  @override
  String get coinMagikarp => 'コイキング';

  @override
  String get coinPokeBall => 'モンスターボール';

  @override
  String get coinMagikarpShort => 'コ';

  @override
  String get coinPokeBallShort => '球';

  @override
  String get phoneElmShort => 'E';

  @override
  String get phoneKantoShort => 'K';

  @override
  String get phonePokerusShort => 'P';

  @override
  String get phoneElmMessage => 'E - ポケモンの　しんかというのは';

  @override
  String get phoneKantoMessage => 'K - カントーには　まだ　ぼくの';

  @override
  String get phonePokerusMessage => 'P - ポケルスが　くっついた';

  @override
  String get phoneIrwinElmMessage => 'E - きみの　かつやくを　きいて';

  @override
  String get phoneIrwinKantoMessage => 'K - でんわ　うれしいなあ!';

  @override
  String get phoneIrwinPokerusMessage => 'P - げんきかい?';

  @override
  String get matches => '一致結果';

  @override
  String get undo => '戻す';

  @override
  String get clear => '消去';

  @override
  String get retailTimer => '実機タイマー';

  @override
  String get timerPreparation => '準備';

  @override
  String get timerFirstCountdown => '1回目タイマー';

  @override
  String get timerSecondCountdown => '2回目タイマー';

  @override
  String get timerCurrentCountdown => 'カウント';

  @override
  String get timerReady => '待機中';

  @override
  String get timerFinished => '完了';

  @override
  String get timerStart => '開始';

  @override
  String get timerStop => '停止';

  @override
  String get timerTargetDelay => '目標Delay';

  @override
  String get timerTargetSecond => '目標秒';

  @override
  String get timerCalibratedDelay => '調整済みDelay';

  @override
  String get timerCalibratedSecond => '調整済み秒';

  @override
  String get idRngSettings => 'ID乱数設定';

  @override
  String get idRngCalibratedDelay => 'ID調整済みDelay';

  @override
  String get eggRngSettings => 'タマゴ乱数設定';

  @override
  String get eggRngCalibratedDelay => 'タマゴ調整済みDelay';

  @override
  String get timerDelayHit => '命中Delay';

  @override
  String get timerApplyCalibration => '調整を反映';

  @override
  String get timerCalibrationAppliedTitle => '調整を反映しました';

  @override
  String timerCalibrationDelayChange(String before, String after) {
    return '校準 Delay: $before -> $after';
  }

  @override
  String timerCalibrationSecondChange(String before, String after) {
    return '校準秒: $before -> $after';
  }

  @override
  String timerCalibrationFirstCountdownChange(String before, String after) {
    return '第1段階: $before -> $after';
  }

  @override
  String timerCalibrationSecondCountdownChange(String before, String after) {
    return '第2段階: $before -> $after';
  }

  @override
  String get timerConsole => '本体';

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
  String get timerConsoleCustom => 'カスタム';

  @override
  String get timerCustomFrameRate => 'カスタムフレームレート';

  @override
  String get timerMinimumLength => '最短時間';

  @override
  String get timerPrecisionCalibration => '精密調整';

  @override
  String timerMinutesBeforeTarget(String minutes) {
    return '目標時刻の$minutes分前に時計を設定';
  }

  @override
  String timerNdsSetTime(String time) {
    return 'NDSの時計を$timeに設定';
  }

  @override
  String timerPhase(String phase) {
    return 'Phase $phase';
  }

  @override
  String get timerInputError => 'タイマーの値を確認してください。';

  @override
  String get timerWebSoundUnsupported => 'Web版タイマーは現在、カウントダウン音に対応していません。';

  @override
  String get reverseHitFeedback => '逆算フィードバック';

  @override
  String get reverseHitSeedMatched => 'Seed命中';

  @override
  String get reverseHitSeedMissed => 'Seed不一致';

  @override
  String get reverseHitTargetAdvance => '目標フレーム';

  @override
  String get reverseHitActualAdvance => '実際フレーム';

  @override
  String reverseHitAdvanceDelta(String delta) {
    return 'フレーム差：$delta';
  }

  @override
  String get observedHit => '実際の命中';

  @override
  String get starterObservedHit => '御三家命中';

  @override
  String get characteristic => '個性';

  @override
  String get characteristicOptions =>
      'たべるのが だいすき|ひるねを よくする|いねむりが おおい|ものを よく ちらかす|のんびりするのが すき|ちからが じまん|あばれることが すき|ちょっと おこりっぽい|ケンカを するのが すき|ちのけが おおい|からだが じょうぶ|うたれ づよい|ねばり づよい|しんぼう づよい|がまん づよい|かけっこが すき|ものおとに びんかん|おっちょこちょい|すこし おちょうしもの|にげるのが はやい|こうきしんが つよい|イタズラが すき|ぬけめが ない|かんがえごとが おおい|とても きちょうめん|きが つよい|ちょっぴり みえっぱり|まけんきが つよい|まけずぎらい|ちょっぴり ごうじょう';

  @override
  String get reverseHitSearch => 'ポケモンを逆算';

  @override
  String get reverseHitTitle => '逆算';

  @override
  String get reverseHitNoResults => '一致する結果がありません。';

  @override
  String get reverseHitTargetSeed => '目標Seed';

  @override
  String get reverseHitNearbySeed => '近くのSeed';

  @override
  String get searchDisabledSelectPokemon => '先にポケモンを選択してください。';

  @override
  String get searchDisabledQueryLocations => 'ポケモンを選んだ後、場所を検索してください。';

  @override
  String get searchDisabledSelectLocation => '場所を選択してください。';

  @override
  String get searchDisabledInvalidRange => '検索範囲の値を修正してください。';

  @override
  String searchDisabledSearchSpaceTooLarge(String max) {
    return '検索量を$max以下に絞ってください。';
  }

  @override
  String get searchDisabledInvalidIvs => '個体値は0から31までの値を入力してください。';

  @override
  String searchDisabledIvRangeTooLarge(String max) {
    return '個体値の組み合わせを$max以下に絞ってください。';
  }

  @override
  String get searchDisabledInvalidHiddenPower =>
      'めざめるパワーの威力は30から70までの値を入力してください。';

  @override
  String get searchDisabledUnsupportedSource => 'この入手先はまだ検索できません。';

  @override
  String get searchDisabledDelayYearOverflow => 'Delay範囲がこの年の有効なseed範囲外です。';

  @override
  String get searchDisabledAlreadyRunning => '検索を実行中です。';

  @override
  String get any => '任意';

  @override
  String get none => 'なし';

  @override
  String get gbaRuby => 'ルビー';

  @override
  String get gbaSapphire => 'サファイア';

  @override
  String get gbaEmerald => 'エメラルド';

  @override
  String get gbaFireRed => 'ファイアレッド';

  @override
  String get gbaLeafGreen => 'リーフグリーン';

  @override
  String get leadNone => 'なし';

  @override
  String get leadSynchronize => 'シンクロ';

  @override
  String get leadCuteCharmMale => 'メロメロボディ♂';

  @override
  String get leadCuteCharmFemale => 'メロメロボディ♀';

  @override
  String get leadCompoundEyes => 'ふくがん';

  @override
  String get leadPressure => 'プレッシャー';

  @override
  String get leadSuctionCups => 'きゅうばん';

  @override
  String get leadArenaTrap => 'ありじごく';

  @override
  String get leadMagnetPull => 'じりょく';

  @override
  String get leadStatic => 'せいでんき';

  @override
  String get typeFighting => 'かくとう';

  @override
  String get typeFlying => 'ひこう';

  @override
  String get typePoison => 'どく';

  @override
  String get typeGround => 'じめん';

  @override
  String get typeRock => 'いわ';

  @override
  String get typeBug => 'むし';

  @override
  String get typeGhost => 'ゴースト';

  @override
  String get typeSteel => 'はがね';

  @override
  String get typeFire => 'ほのお';

  @override
  String get typeWater => 'みず';

  @override
  String get typeGrass => 'くさ';

  @override
  String get typeElectric => 'でんき';

  @override
  String get typePsychic => 'エスパー';

  @override
  String get typeIce => 'こおり';

  @override
  String get typeDragon => 'ドラゴン';

  @override
  String get typeDark => 'あく';

  @override
  String get idRng => 'ID乱数';

  @override
  String get idRngTarget => '目標ID';

  @override
  String get idRngSearch => 'ID検索';

  @override
  String get idRngSearchAll => 'ID検索（全て）';

  @override
  String get idRngResults => 'ID結果';

  @override
  String get idRngTimer => 'IDタイマー';

  @override
  String get idRngHitCheck => '実際ID確認';

  @override
  String get idRngMinSid => '最小SID';

  @override
  String get idRngMaxSid => '最大SID';

  @override
  String get idRngTargetPid => '目標PID';

  @override
  String get idRngTargetTsv => '目標TSV';

  @override
  String get idRngExtraTargetFilters => '追加目標条件';

  @override
  String get cuteCharmIdTarget => 'メロメロボディID目標';

  @override
  String get idRngPidTargetFinder => 'PID目標検索';

  @override
  String get idRngExcellentSidFinder => '優秀SID検索';

  @override
  String get idRngTidRequired => 'TIDを入力してください。';

  @override
  String get idRngReachableExcellentSidFinder => 'SID検索';

  @override
  String get idRngReachableExcellentSidSearch => '結果検索';

  @override
  String get idRngReachableExcellentSidNoResults =>
      '現在のTID/SIDの組み合わせは、このDelay範囲内では到達できる結果が見つかりません。別のSID範囲を試すか、最小/最大Delayを調整して再検索してください。';

  @override
  String get idRngQuickGuide => '説明';

  @override
  String get idRngQuickGuideBody =>
      '優秀SID検索を押し、表示されたPIDを見て、狙いたいSID範囲のカードを選ぶと自動で戻って入力されます。\n次に年を入力します。新規ゲームでは操作時間が必要なため、最小Delayは5500以上を推奨します。\n結果検索を押し、狙いたい結果を選ぶとID乱数ページに戻り、タイマーが表示されます。\nタイマーに従ってDSの時刻を設定し、ゲームを開始して主人公作成を終えたら、テレビ画面で待機します。カウントダウン終了の瞬間にAを押します。\n実際に出たTIDでタイマーを補正し、再度試行します。';

  @override
  String get idRngExcellentSidSearch => '優秀SIDを検索';

  @override
  String get idRngExcellentSidResults => '最良目標TSVグループ';

  @override
  String get idRngIncludeNeutralNatures => '無補正性格を表示';

  @override
  String get idRngExcellentSidMethodHelp =>
      'Method 1：御三家・ギフト系。Method J：DP/Ptの固定伝説系。';

  @override
  String get idRngExcellentSidMethodHelpDppt =>
      'Method 1：御三家・ギフト・化石系。Method J：DP/Ptの固定伝説系。';

  @override
  String get idRngExcellentSidMethodHelpHgss =>
      'Method 1：御三家・ギフト・化石系。Method K：HGSSの固定伝説系。';

  @override
  String get idRngSortByNatureCount => '性格最多';

  @override
  String get idRngSortByTargetCount => '結果最多';

  @override
  String idRngExcellentSidGroup(String tsv) {
    return 'TSV $tsv';
  }

  @override
  String idRngPidTargetCount(String count) {
    return '$count件';
  }

  @override
  String idRngNatureCount(String count) {
    return '$count性格';
  }

  @override
  String idRngSidRangeShort(String range) {
    return 'SID $range';
  }

  @override
  String get idRngPidTargetNatures => '目標性格';

  @override
  String get idRngPidTargetMinIvs => '最低IV';

  @override
  String get idRngPidTargetSearch => 'PID目標を検索';

  @override
  String get idRngPidTargetResults => 'PID目標結果';

  @override
  String get idRngPidTargetNoResults => 'PID目標がありません。';

  @override
  String get idRngPidTargetInvalidInput => '性格とIV条件を確認してください。';

  @override
  String idRngPidTargetGroup(String psv, String count) {
    return 'PSV $psv · $count件';
  }

  @override
  String idRngPidTargetGroupWithSid(String psv, String count, String sidRange) {
    return 'PSV $psv · $count件 · SID $sidRange';
  }

  @override
  String idRngPidTargetResult(
    String pid,
    String nature,
    String ivs,
    String ability,
  ) {
    return 'PID $pid · $nature · IV $ivs · 特性 $ability';
  }

  @override
  String get genderRatio => '性別比';

  @override
  String cuteCharmIdSummary(
    String pid,
    String tsv,
    String ability,
    String gender,
  ) {
    return 'PID $pid · TSV $tsv · 特性 $ability · 目標性別 $gender';
  }

  @override
  String get cuteCharmApplyIdTarget => 'ID検索に反映';

  @override
  String idRngSearchSpace(String states) {
    return '検索量: $states seeds';
  }

  @override
  String get idRngNeedFilter => 'TID、SID、TSV、PIDのいずれかを入力してください。';

  @override
  String get idRngInvalidInput => 'ID乱数の値を確認してください。';

  @override
  String idRngPidSummary(String psv, String nature) {
    return 'PSV $psv · 性格 $nature';
  }

  @override
  String idRngSidRange(String range) {
    return '色違いSID: $range';
  }

  @override
  String idRngSidCandidates(String values) {
    return 'SID候補: $values';
  }

  @override
  String get idRngSelectedState => '選択したID結果';

  @override
  String get idRngSelectResultFirst => '先にID結果を選択してください。';

  @override
  String get idRngNoSeedTime => '先にSeed時間を取得して選択してください。';

  @override
  String idRngResultSubtitle(String tid, String sid, String tsv) {
    return 'TID $tid · SID $sid · TSV $tsv';
  }

  @override
  String get idRngSearchHit => '命中Delayを逆算';

  @override
  String get idRngHitDelayWindow => 'Delay +/-';

  @override
  String get idRngHitResults => 'ID命中結果';

  @override
  String get idRngSelectedHit => '選択した命中ID';

  @override
  String get idRngNoHit => '一致するTID/SIDがありません。';

  @override
  String get idRngHitHelp =>
      'この結果のDelayはIDタイマーの命中Delayに入力されました。調整を反映するとID調整済みDelayのみ更新し、遭遇用タイマーのDelayは変更しません。';

  @override
  String get gen4TargetCategoryWild => '野生';

  @override
  String get gen4TargetCategoryStationary => '固定';

  @override
  String get gen4TargetCategoryLegend => '伝説';

  @override
  String get gen4TargetCategoryGift => 'もらう';

  @override
  String get gen4TargetCategoryStarter => '最初のポケモン';

  @override
  String get gen4TargetCategoryFossil => '化石';

  @override
  String get gen4TargetCategoryGameCorner => 'ゲームコーナー';

  @override
  String get gen4TargetCategoryEvent => 'イベント';

  @override
  String get gen4TargetCategoryRoamer => '徘徊';

  @override
  String get gen4TargetWildGrass => '草むら';

  @override
  String get gen4TargetWildSurfing => 'なみのり';

  @override
  String get gen4TargetWildOldRod => 'ボロのつりざお';

  @override
  String get gen4TargetWildGoodRod => 'いいつりざお';

  @override
  String get gen4TargetWildSuperRod => 'すごいつりざお';

  @override
  String get gen4TargetWildRockSmash => 'いわくだき';

  @override
  String get gen4TargetWildBugCatchingContest => '虫取り大会';

  @override
  String get gen4TargetWildHeadbutt => 'ずつき';

  @override
  String get gen4TargetWildHeadbuttAlt => 'ずつき別枠';

  @override
  String get gen4TargetWildHeadbuttSpecial => '特別なずつき';

  @override
  String get gen4TargetWildHoneyTree => 'あまいミツの木';

  @override
  String get gen4TargetTimeMorning => '朝';

  @override
  String get gen4TargetTimeDay => '昼';

  @override
  String get gen4TargetTimeNight => '夜';

  @override
  String get gen4TargetMethodMethod1 => 'Method 1';

  @override
  String get gen4TargetMethodMethodJ => 'Method J';

  @override
  String get gen4TargetMethodMethodK => 'Method K';

  @override
  String get gen4TargetMethodHoneyTree => 'あまいミツの木';

  @override
  String get gen4TargetMethodPokeRadar => 'ポケトレ';

  @override
  String get gen4TargetMethodPokeRadarShiny => 'ポケトレ色違い';

  @override
  String get gen4TargetStaticStarter => '最初のポケモン';

  @override
  String get gen4TargetStaticFossil => '化石';

  @override
  String get gen4TargetStaticGift => 'もらう';

  @override
  String get gen4TargetStaticGameCorner => 'ゲームコーナー';

  @override
  String get gen4TargetStaticStationary => '固定';

  @override
  String get gen4TargetStaticLegend => '伝説';

  @override
  String get gen4TargetStaticEvent => 'イベント';

  @override
  String get gen4TargetStaticRoamer => '徘徊';

  @override
  String get gen4TargetShinyRandom => '色違いランダム';

  @override
  String get gen4TargetShinyAlways => '色違い固定';

  @override
  String get gen4TargetShinyNever => '色違い不可';

  @override
  String get gen4TargetModifierSwarm => '大量発生';

  @override
  String get gen4TargetModifierDay => '昼の枠';

  @override
  String get gen4TargetModifierNight => '夜の枠';

  @override
  String get gen4TargetModifierRadar => 'ポケトレ';

  @override
  String get gen4TargetModifierRuby => 'ルビー挿入';

  @override
  String get gen4TargetModifierSapphire => 'サファイア挿入';

  @override
  String get gen4TargetModifierEmerald => 'エメラルド挿入';

  @override
  String get gen4TargetModifierFireRed => 'ファイアレッド挿入';

  @override
  String get gen4TargetModifierLeafGreen => 'リーフグリーン挿入';

  @override
  String get gen4TargetModifierFeebasTile => 'ヒンバスのマス';

  @override
  String get gen4TargetModifierHoennSound => 'ホウエンサウンド';

  @override
  String get gen4TargetModifierSinnohSound => 'シンオウサウンド';

  @override
  String get gen4TargetModifierFishNight => '夜の釣り';

  @override
  String get gen4TargetModifierFishSwarm => '釣り大量発生';

  @override
  String get gen4TargetModifierSafariBlocks => 'サファリブロック';

  @override
  String get gen4TargetModifierUnknown => '特殊枠';

  @override
  String gen4TargetLevel(int level) {
    return 'Lv. $level';
  }

  @override
  String gen4TargetLevelRange(int minLevel, int maxLevel) {
    return 'Lv. $minLevel-$maxLevel';
  }
}

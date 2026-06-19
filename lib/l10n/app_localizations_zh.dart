// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'PokeRNG G4';

  @override
  String get target => '目标';

  @override
  String get search => '检索';

  @override
  String get egg => '孵蛋';

  @override
  String get eggCrossSaveTitle => '为别的存档生成闪光蛋';

  @override
  String get eggCrossSaveNoteBefore =>
      '在第四世代孵蛋时，可以临时输入另一个存档的TID/SID来乱数生成蛋。把这颗蛋传给那个存档后，';

  @override
  String get eggCrossSaveNoteEmphasis => '必须在那个存档孵化';

  @override
  String get eggCrossSaveNoteAfter =>
      '，才能获得属于那个训练家ID的闪光宝可梦。需要注意，破壳动画在领取蛋时已经决定；如果这颗蛋对领取蛋的存档ID不闪，即使之后传给目标存档孵化，孵化动画仍会显示原色。孵化后进入队伍查看详情，即可确认它是闪光宝可梦。';

  @override
  String get eggHgssTitle => 'HGSS算法孵蛋';

  @override
  String get eggHgssAlgorithmNote =>
      '本页始终使用HGSS孵蛋算法。TID/SID默认读取当前游戏保存值，也可临时修改；实际生成蛋需要在HGSS中操作。';

  @override
  String get eggDpptTitle => 'DPPt算法孵蛋';

  @override
  String get eggDpptAlgorithmNote =>
      '本页是DPPt孵蛋页面的独立副本，后续只在这里接入DPPt专用生成蛋、领取蛋算法；HGSS孵蛋页面不会受影响。';

  @override
  String get eggDpptHeldFrameNote =>
      'DPPt生成蛋阶段决定PID、性格、性别、特性和闪光。使用抛硬币确认Seed；抛硬币不会推进Egg Frame。';

  @override
  String get eggDpptPickupFrameNote =>
      'DPPt领取蛋阶段决定个体值和遗传。DPPt使用原版遗传bug，本页会走独立的DPPt检索路径，不影响已验证的HGSS页面。';

  @override
  String get eggHgssOnlyTitle => '暂时只支持HGSS孵蛋';

  @override
  String get eggHgssOnlyBody => 'DPPt孵蛋有独立的遗传机制，当前页面先只开放心金、魂银。';

  @override
  String get eggGenerateEggTab => '生成蛋';

  @override
  String get eggPickupEggTab => '领取蛋';

  @override
  String get eggDaycare => '寄放屋';

  @override
  String get eggGenderRatio => '性别比例';

  @override
  String eggGenderRatioPercent(String male, String female) {
    return '$male% ♂ : $female% ♀';
  }

  @override
  String get eggGenderRatioMaleOnly => '100% ♂';

  @override
  String get eggGenderRatioFemaleOnly => '100% ♀';

  @override
  String get eggMasuda => '国际孵蛋';

  @override
  String get eggParentsSettings => '孵蛋父母';

  @override
  String get eggParentA => '父母A个体值';

  @override
  String get eggParentB => '父母B个体值';

  @override
  String get eggHeldStage => '蛋PID';

  @override
  String get eggFrameOneNote => '简单模式固定只支持Egg Frame 1。命中这个Seed后，让老爷爷第一次生成蛋即可。';

  @override
  String get eggPhoneFrameNote =>
      '生成蛋阶段决定PID、性格、性别、特性和闪光。Egg Frame是老爷爷生成蛋时使用的PID帧；Elm/Irwin电话只用于确认Seed，不自动等同于Egg Frame推进。';

  @override
  String get eggPickupFrameNote =>
      '领取蛋阶段决定个体值和遗传。生成个体时会按年份、Delay范围和领取帧范围检索。反向查找默认Seed已经命中，只在已选择或已校验的领取Seed内查找不同领取帧。';

  @override
  String get eggPhoneCalls => '电话次数';

  @override
  String get eggMinFrame => '最小Egg Frame';

  @override
  String get eggMaxFrame => '最大Egg Frame';

  @override
  String get eggTargetEggFrame => 'Egg Frame';

  @override
  String get eggPickupStage => '领取蛋';

  @override
  String get eggHeldSeed => 'PID Seed';

  @override
  String get eggPickupSeed => '领取Seed';

  @override
  String get eggSearchPid => '生成PID';

  @override
  String get eggPidResultsTitle => '蛋PID结果';

  @override
  String get eggSearchIvs => '生成个体';

  @override
  String get eggObservedIvs => '实际个体值';

  @override
  String get eggObservedStats => '实际能力值（1级）';

  @override
  String get eggSelectHatchedPokemon => '请选择孵出的宝可梦。';

  @override
  String get eggObservedStatsInputError => '请填写孵出宝可梦的1级实际能力值。';

  @override
  String get eggObservedStatsNoIvRanges => '宝可梦、性格、能力值或个性不匹配，请检查输入。';

  @override
  String get eggPickupReverseSeedRequired => '请先选择目标领取结果，或通过检索Seed确认命中的领取Seed。';

  @override
  String get eggReversePickupSearch => '反向查找领取';

  @override
  String get eggPickupResultsTitle => '领取个体结果';

  @override
  String get eggLockedEgg => '已锁定的蛋';

  @override
  String get eggLockedPid => '锁定PID';

  @override
  String get eggLockedEggNote =>
      '领取蛋只使用这里的PID身份信息。生成蛋时的Delay和Egg Frame不参与领取个体；领取Seed和领取帧独立决定个体值与遗传。';

  @override
  String get eggNoPickupTargetSelected => '尚未选择生成个体结果。';

  @override
  String get eggNoSeedTimeSelected => '尚未选择Seed时间。';

  @override
  String get eggTimerRequiresSeedTime => '选择Seed时间后显示定时器。';

  @override
  String get eggNoPidResults => '没有匹配的PID。';

  @override
  String eggResultLimitReached(String count) {
    return '已显示前 $count 个结果，请缩小范围。';
  }

  @override
  String get eggNoIvResults => '没有匹配的领取结果。';

  @override
  String get eggSelectPidFirst => '请先在上方选择一个蛋PID。';

  @override
  String get eggSelectedPid => '已选择PID';

  @override
  String get eggSelectedSeedTime => '已选择Seed时间';

  @override
  String get eggObservedPid => '实机PID反查';

  @override
  String get eggReversePidSearch => '反向查询PID';

  @override
  String get eggSelectedHitDelay => '已选择命中Delay';

  @override
  String get eggMinIvsOptional => '最低个体值（可留空）';

  @override
  String get eggPidAdvance => 'PID帧';

  @override
  String get eggPickupAdvance => '领取帧';

  @override
  String get eggInheritance => '遗传';

  @override
  String get results => '结果';

  @override
  String get calibrate => '校准';

  @override
  String get tools => '工具';

  @override
  String get settings => '设置';

  @override
  String get cancel => '取消';

  @override
  String get ok => '确定';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageChinese => '中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get gameVersion => '游戏版本';

  @override
  String get gameDiamond => '钻石';

  @override
  String get gamePearl => '珍珠';

  @override
  String get gamePlatinum => '白金';

  @override
  String get gameHeartGold => '心金';

  @override
  String get gameSoulSilver => '魂银';

  @override
  String get trainerProfile => '训练家资料';

  @override
  String get trainerId => 'TID';

  @override
  String get secretId => 'SID';

  @override
  String get timerDefaults => '定时器默认值';

  @override
  String get delayWindow => 'Delay范围';

  @override
  String get secondWindow => '秒数范围';

  @override
  String get hgssPhoneCaller => 'HGSS电话文字';

  @override
  String get maxPhoneCallSkip => '最大初始帧';

  @override
  String get phoneCallerElm => 'ウツギはかせ';

  @override
  String get phoneCallerIrwin => 'ジャグラーのマイク';

  @override
  String get save => '保存';

  @override
  String get settingsInputError => '请输入0到65535之间的数值。';

  @override
  String get settingsTimerInputError => '请检查Delay、秒数、初始帧默认值。';

  @override
  String get settingsEggParentInputError => '请检查父母个体值，需要输入0到31之间的数值。';

  @override
  String get settingsEggLockedPidInputError => '请检查锁定PID，需要留空或输入8位十六进制PID。';

  @override
  String get about => '关于';

  @override
  String get version => '版本';

  @override
  String get license => '许可证';

  @override
  String get project => '项目';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get credits => '致谢';

  @override
  String get aboutDescription => '面向第四世代钻石、珍珠、白金、心金和魂银的多平台乱数工具。';

  @override
  String get unofficialNotice => '非官方乱数辅助工具。';

  @override
  String get aboutCredits => '参考 PokeFinder、EonTimer 与 PokemonRNG 社区研究。';

  @override
  String get copyProjectUrl => '复制项目地址';

  @override
  String get projectUrlCopied => '项目地址已复制';

  @override
  String get supportDeveloper => '支持作者';

  @override
  String get supportDescription => '可通过自愿内购支持后续开发。';

  @override
  String get supportNoUnlock => '购买不会解锁额外功能。';

  @override
  String get supportUnavailable => '支持作者暂不可用。';

  @override
  String get supportThanks => '感谢支持。';

  @override
  String get supportCancelled => '已取消购买。';

  @override
  String get supportPending => '购买正在等待批准。';

  @override
  String get supportFailed => '购买失败，请稍后再试。';

  @override
  String get retry => '重试';

  @override
  String get searchMode => '检索模式';

  @override
  String get timeFinder => '时间检索';

  @override
  String get generator => '生成器';

  @override
  String get generatorPlaceholder => '生成器设置会在时间检索接好后补充。';

  @override
  String get pokemon => '宝可梦';

  @override
  String get location => '地点';

  @override
  String get timeCondition => '时间';

  @override
  String get gbaCartridge => 'GBA卡带';

  @override
  String get queryLocations => '查询地点';

  @override
  String get noMatchingLocations => '当前时间和卡带条件下没有匹配来源。';

  @override
  String get noAvailableLocationForGame => '当前游戏没有这只宝可梦的可用来源。';

  @override
  String get filters => '筛选';

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
  String get gender => '性别';

  @override
  String get genderMale => '♂';

  @override
  String get genderFemale => '♀';

  @override
  String get genderGenderless => '-';

  @override
  String get hiddenPower => '觉醒力量';

  @override
  String get levelShort => '等级';

  @override
  String get minLevel => '最低等级';

  @override
  String get maxLevel => '最高等级';

  @override
  String get minPower => '最低威力';

  @override
  String get maxPower => '最高威力';

  @override
  String get slot => '槽位';

  @override
  String get lead => '队首';

  @override
  String get syncNature => '同步性格';

  @override
  String get shiny => '闪光';

  @override
  String get notShiny => '非闪光';

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
  String get searchRange => '检索范围';

  @override
  String get year => '年份';

  @override
  String get minDelay => '最小Delay';

  @override
  String get maxDelay => '最大Delay';

  @override
  String get minAdvance => '最小帧';

  @override
  String get maxAdvance => '最大帧';

  @override
  String get second => '秒';

  @override
  String get forceSecond => '固定秒数';

  @override
  String get searchSpaceInvalid => '检索量：范围无效';

  @override
  String searchSpaceStates(String states) {
    return '检索量：$states states';
  }

  @override
  String searchSpaceTooLarge(String max) {
    return '请缩小到 $max 以下';
  }

  @override
  String get searching => '检索中...';

  @override
  String get searchComplete => '检索完成。';

  @override
  String get searchResultsPlaceholder => '检索结果会显示在这里。';

  @override
  String get noResults => '没有结果。';

  @override
  String get searchCancelled => '检索已取消。';

  @override
  String get searchFailed => '检索失败。';

  @override
  String get resultLimitReached => '已达到结果上限。';

  @override
  String get sendToCalibration => '发送到校准';

  @override
  String get saveTarget => '保存目标';

  @override
  String get targetSaved => '目标已保存';

  @override
  String get targetAlreadySaved => '这个目标已经保存过。';

  @override
  String get savedTargets => '目标记录';

  @override
  String get helpSection => '说明';

  @override
  String get tutorialsTitle => '教程';

  @override
  String get tutorialsOpen => '查看教程';

  @override
  String get tutorialNoticeTitle => '阅读说明';

  @override
  String get tutorialNoticeBody =>
      '下列教程记录的是作者已经在实机流程中验证过的乱数。没有出现在教程里的游戏或场景，并不代表 App 不支持，只是仍需要进一步尝试与确认。';

  @override
  String get tutorialCategoryIntroduction => '介绍';

  @override
  String get tutorialCategoryBasics => '基础';

  @override
  String get tutorialCategoryId => 'ID';

  @override
  String get tutorialCategoryStarter => '初始';

  @override
  String get tutorialCategoryStationary => '定点';

  @override
  String get tutorialCategoryWild => '野生';

  @override
  String get tutorialCategoryEgg => '孵蛋';

  @override
  String get leadAbilityHelpTitle => 'DP/Pt/HGSS队首特性';

  @override
  String get wildSweetScentHelpTitle => 'HGSS甜甜香气';

  @override
  String get noSavedTargets => '在结果页点击某个结果，可以保存目标。';

  @override
  String get deleteTarget => '删除目标';

  @override
  String resultCount(String count) {
    return '$count 个结果';
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
  String get advance => '帧';

  @override
  String get hour => '小时';

  @override
  String get time => '时间';

  @override
  String get ivs => '个体值';

  @override
  String get stats => '能力值';

  @override
  String get hpStat => 'HP';

  @override
  String get atkStat => '攻击';

  @override
  String get defStat => '防御';

  @override
  String get spaStat => '特攻';

  @override
  String get spdStat => '特防';

  @override
  String get speStat => '速度';

  @override
  String get month => '月份';

  @override
  String get day => '日期';

  @override
  String get minute => '分钟';

  @override
  String get calibrateSeedCheck => 'Seed校验';

  @override
  String get calibrateCoinFlips => 'DPPt硬币';

  @override
  String get calibratePhoneCalls => 'HGSS电话';

  @override
  String get calibrateParameterHelp =>
      '目标Delay/目标秒来自搜索结果，是这次要命中的seed。校准Delay/校准秒来自设置页，是你的机器和按键节奏基准，不是额外等待时间。';

  @override
  String get calibrateQuickGuide =>
      '简易流程：先用硬币或电话反查seed，确认自己实际命中的秒和Delay；秒长期偏差时更新校准秒，Delay偏差时用Hit Delay重算校准Delay。正式命中目标时不要再校验seed，按定时器进游戏后直接操作目标，捕获后再反查实际命中结果。';

  @override
  String get calibrationTarget => '本次目标';

  @override
  String get noCalibrationTarget => '没有校准目标。请从结果页点击一个目标发送到校准页。';

  @override
  String get seedToTime => '获取Seed时间';

  @override
  String get seedToTimeTitle => 'Seed to Time';

  @override
  String get seedToTimeSearch => '获取时间';

  @override
  String get seedToTimeInvalidFilter => '年份请输入2000到2099，月份请输入1到12，日期请输入1到31。';

  @override
  String get noSeedTimeResults => '没有符合条件的时间。';

  @override
  String get selectedSeedTime => '已选择Seed时间';

  @override
  String get seedSearch => '检索Seed';

  @override
  String get seedSearchTitle => 'Seed检索';

  @override
  String get selectedSeedHit => '已选择命中Seed';

  @override
  String get selectedSeedHitHelp =>
      '该结果的Delay已填入定时器的实际Delay。点击应用校准后，会更新校准Delay，并按命中秒偏差微调校准秒。';

  @override
  String get initialAdvance => '环境帧';

  @override
  String get currentAdvance => '当前帧';

  @override
  String get targetAdvance => '目标帧';

  @override
  String get remainingAdvance => '推进帧';

  @override
  String get advanceOffset => 'Offset';

  @override
  String get initialAdvanceFilter => '初始环境帧';

  @override
  String get advanceOffsetHelp =>
      'DPPt用捕获后的反向查找计算offset。HGSS可以直接用电话计算offset；反向查找仍然可用。';

  @override
  String get chatotPitches => '喋喋不休音准';

  @override
  String get chatotPitchHigh => '高';

  @override
  String get chatotPitchLow => '低';

  @override
  String chatotTotalAdvances(int count) {
    return '喋喋不休: $count次';
  }

  @override
  String advanceAhead(int count) {
    return '后$count帧';
  }

  @override
  String get targetAction => '目标';

  @override
  String get advanceOneFrame => '推进';

  @override
  String get pressA => '按A';

  @override
  String get rngBeginnerHelpTitle => '什么是乱数';

  @override
  String get gen4RngPrinciplesHelpTitle => 'Gen4乱数原理';

  @override
  String get delayParityHelpTitle => 'Delay的奇偶切换';

  @override
  String get timerTimingHelpTitle => 'DP/Pt/HGSS定时器按键时机';

  @override
  String get eggHeldHelpTitle => 'HGSS生成蛋';

  @override
  String get eggPickupHelpTitle => 'HGSS领取蛋';

  @override
  String get chatotAdvanceHelpTitle => 'Pt/HGSS聒噪鸟与目标帧';

  @override
  String get hgssStationaryHelpTitle => 'HGSS定点闪';

  @override
  String get honeyTreeHelpTitle => 'Pt甜甜蜜树闪';

  @override
  String get platinumStarterHelpTitle => 'Pt初始闪';

  @override
  String get platinumIdRngHelpTitle => 'Pt乱数ID';

  @override
  String calibratedSecondCurrent(String second) {
    return '当前校准秒：$second';
  }

  @override
  String calibratedSecondHit(String second) {
    return '命中秒：$second';
  }

  @override
  String get calibrateTargetTime => '目标时间';

  @override
  String get calibrateSearchWindow => '校验范围';

  @override
  String get calibrateTargetDelay => '目标Delay';

  @override
  String get calibrateDelayWindow => 'Delay +/-';

  @override
  String get calibrateSecondWindow => '秒 +/-';

  @override
  String get calibrateObservedSequence => '实际序列';

  @override
  String calibratePhoneCallerHelp(String caller) {
    return '当前电话文字：$caller。如需修改，请前往设置页面。';
  }

  @override
  String get calibrateNoSequence => '按实际结果顺序点击。';

  @override
  String get calibrateInvalidTarget => '请修正目标时间和范围。';

  @override
  String get calibrateTargetSeedTimeRequired =>
      '请先点击获取Seed时间，选择能生成目标seed的时间后再检索Seed。';

  @override
  String get calibrateNoMatches => '没有匹配的seed。';

  @override
  String get coinMagikarp => '鲤鱼王';

  @override
  String get coinPokeBall => '精灵球';

  @override
  String get coinMagikarpShort => '鲤';

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
  String get matches => '匹配结果';

  @override
  String get undo => '撤销';

  @override
  String get clear => '清空';

  @override
  String get retailTimer => '实机定时器';

  @override
  String get timerPreparation => '准备阶段';

  @override
  String get timerFirstCountdown => '第一段计时';

  @override
  String get timerSecondCountdown => '第二段计时';

  @override
  String get timerCurrentCountdown => '倒计时';

  @override
  String get timerReady => '等待开始';

  @override
  String get timerFinished => '完成';

  @override
  String get timerStart => '开始';

  @override
  String get timerStop => '停止';

  @override
  String get timerTargetDelay => '目标Delay';

  @override
  String get timerTargetSecond => '目标秒';

  @override
  String get timerCalibratedDelay => '校准Delay';

  @override
  String get timerCalibratedSecond => '校准秒';

  @override
  String get idRngSettings => 'ID乱数设置';

  @override
  String get idRngCalibratedDelay => 'ID校准Delay';

  @override
  String get eggRngSettings => '孵蛋乱数设置';

  @override
  String get eggRngCalibratedDelay => '孵蛋校准Delay';

  @override
  String get timerDelayHit => '实际Delay';

  @override
  String get timerApplyCalibration => '应用校准';

  @override
  String get timerCalibrationAppliedTitle => '校准已应用';

  @override
  String timerCalibrationDelayChange(String before, String after) {
    return '校准 Delay: $before -> $after';
  }

  @override
  String timerCalibrationSecondChange(String before, String after) {
    return '校准秒: $before -> $after';
  }

  @override
  String timerCalibrationFirstCountdownChange(String before, String after) {
    return '第一阶段: $before -> $after';
  }

  @override
  String timerCalibrationSecondCountdownChange(String before, String after) {
    return '第二阶段: $before -> $after';
  }

  @override
  String get timerConsole => '机型';

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
  String get timerConsoleCustom => '自定义';

  @override
  String get timerCustomFrameRate => '自定义帧率';

  @override
  String get timerMinimumLength => '最短计时';

  @override
  String get timerPrecisionCalibration => '精确校准';

  @override
  String timerMinutesBeforeTarget(String minutes) {
    return '把NDS时间设置到目标时间前$minutes分钟';
  }

  @override
  String timerNdsSetTime(String time) {
    return '把NDS时间设置为$time';
  }

  @override
  String timerPhase(String phase) {
    return '第$phase段';
  }

  @override
  String get timerInputError => '请检查定时器参数。';

  @override
  String get timerWebSoundUnsupported => 'Web 版本的定时器暂时不支持倒计时提示音。';

  @override
  String get reverseHitFeedback => '反查反馈';

  @override
  String get reverseHitSeedMatched => 'Seed已命中';

  @override
  String get reverseHitSeedMissed => 'Seed未命中';

  @override
  String get reverseHitTargetAdvance => '目标帧';

  @override
  String get reverseHitActualAdvance => '实际帧';

  @override
  String reverseHitAdvanceDelta(String delta) {
    return '帧差：$delta';
  }

  @override
  String get observedHit => '实际命中';

  @override
  String get starterObservedHit => '御三家命中';

  @override
  String get characteristic => '个性';

  @override
  String get characteristicOptions =>
      '非常喜欢吃东西|经常睡午觉|常常打瞌睡|经常乱扔东西|喜欢悠然自在|以力气大为傲|喜欢胡闹|有点容易生气|喜欢打架|血气方刚|身体强壮|抗打能力强|顽强不屈|能吃苦耐劳|善于忍耐|喜欢比谁跑得快|对声音敏感|冒冒失失|有点容易得意忘形|逃得快|好奇心强|喜欢恶作剧|做事万无一失|经常思考|一丝不苟|性格强势|有一点点爱慕虚荣|争强好胜|不服输|有一点点固执';

  @override
  String get reverseHitSearch => '反向查找宝可梦';

  @override
  String get reverseHitTitle => '反向查找';

  @override
  String get reverseHitNoResults => '没有匹配结果。';

  @override
  String get reverseHitTargetSeed => '目标Seed';

  @override
  String get reverseHitNearbySeed => '附近Seed';

  @override
  String get searchDisabledSelectPokemon => '请先选择宝可梦。';

  @override
  String get searchDisabledQueryLocations => '选择宝可梦后，请先查询地点。';

  @override
  String get searchDisabledSelectLocation => '请选择地点。';

  @override
  String get searchDisabledInvalidRange => '请修正检索范围。';

  @override
  String searchDisabledSearchSpaceTooLarge(String max) {
    return '请把检索量缩小到 $max 以下。';
  }

  @override
  String get searchDisabledInvalidIvs => '个体值请输入0到31之间的数值。';

  @override
  String searchDisabledIvRangeTooLarge(String max) {
    return '请把个体组合缩小到 $max 以下。';
  }

  @override
  String get searchDisabledInvalidHiddenPower => '觉醒力量威力请输入30到70之间的数值。';

  @override
  String get searchDisabledUnsupportedSource => '这个来源暂时还不能检索。';

  @override
  String get searchDisabledDelayYearOverflow => 'Delay范围超出了当前年份可用的seed范围。';

  @override
  String get searchDisabledAlreadyRunning => '检索正在运行。';

  @override
  String get any => '任意';

  @override
  String get none => '无';

  @override
  String get gbaRuby => '红宝石';

  @override
  String get gbaSapphire => '蓝宝石';

  @override
  String get gbaEmerald => '绿宝石';

  @override
  String get gbaFireRed => '火红';

  @override
  String get gbaLeafGreen => '叶绿';

  @override
  String get leadNone => '无';

  @override
  String get leadSynchronize => '同步';

  @override
  String get leadCuteCharmMale => '迷人之躯♂';

  @override
  String get leadCuteCharmFemale => '迷人之躯♀';

  @override
  String get leadCompoundEyes => '复眼';

  @override
  String get leadPressure => '压迫感';

  @override
  String get leadSuctionCups => '吸盘';

  @override
  String get leadArenaTrap => '沙穴';

  @override
  String get leadMagnetPull => '磁力';

  @override
  String get leadStatic => '静电';

  @override
  String get typeFighting => '格斗';

  @override
  String get typeFlying => '飞行';

  @override
  String get typePoison => '毒';

  @override
  String get typeGround => '地面';

  @override
  String get typeRock => '岩石';

  @override
  String get typeBug => '虫';

  @override
  String get typeGhost => '幽灵';

  @override
  String get typeSteel => '钢';

  @override
  String get typeFire => '火';

  @override
  String get typeWater => '水';

  @override
  String get typeGrass => '草';

  @override
  String get typeElectric => '电';

  @override
  String get typePsychic => '超能力';

  @override
  String get typeIce => '冰';

  @override
  String get typeDragon => '龙';

  @override
  String get typeDark => '恶';

  @override
  String get idRng => 'ID乱数';

  @override
  String get idRngTarget => '目标ID';

  @override
  String get idRngSearch => '检索ID';

  @override
  String get idRngSearchAll => '检索ID（全部）';

  @override
  String get idRngResults => 'ID结果';

  @override
  String get idRngTimer => 'ID定时器';

  @override
  String get idRngHitCheck => '实际ID校验';

  @override
  String get idRngMinSid => '最小SID';

  @override
  String get idRngMaxSid => '最大SID';

  @override
  String get idRngTargetPid => '目标PID';

  @override
  String get idRngTargetTsv => '目标TSV';

  @override
  String get idRngExtraTargetFilters => '额外目标条件';

  @override
  String get cuteCharmIdTarget => '迷人之躯ID目标';

  @override
  String get idRngPidTargetFinder => 'PID目标检索';

  @override
  String get idRngExcellentSidFinder => '寻找优秀SID';

  @override
  String get idRngTidRequired => '请填写TID。';

  @override
  String get idRngReachableExcellentSidFinder => '寻找SID';

  @override
  String get idRngReachableExcellentSidSearch => '检索结果';

  @override
  String get idRngReachableExcellentSidNoResults =>
      '当前TID/SID组合在此Delay范围内没有可到达结果。请尝试其他SID范围，或调整最小/最大Delay后重新检索。';

  @override
  String get idRngQuickGuide => '说明';

  @override
  String get idRngQuickGuideBody =>
      '点击寻找优秀SID，根据展示出来的PID，选择心仪的SID范围，点击卡片后会自动返回并填充数据。\n然后输入年份。最小Delay建议至少5500，再小的话新游戏通常来不及操作。\n点击检索结果，选择期望的结果后会回到ID乱数页并显示定时器。\n根据定时器设置DS时间、进入游戏、创建完成人物后，在电视机画面等待，在定时器倒计时结束瞬间按A。\n根据实际获得的TID校准定时器，然后重复操作。';

  @override
  String get idRngExcellentSidSearch => '检索优秀SID';

  @override
  String get idRngExcellentSidResults => '最佳目标TSV组';

  @override
  String get idRngIncludeNeutralNatures => '显示平衡性格';

  @override
  String get idRngExcellentSidMethodHelp =>
      'Method 1：御三家、礼物类。Method J：DP/Pt 定点传说类。';

  @override
  String get idRngExcellentSidMethodHelpDppt =>
      'Method 1：御三家、礼物、化石类。Method J：DP/Pt 定点传说类。';

  @override
  String get idRngExcellentSidMethodHelpHgss =>
      'Method 1：御三家、礼物、化石类。Method K：HGSS 定点传说类。';

  @override
  String get idRngSortByNatureCount => '性格最多';

  @override
  String get idRngSortByTargetCount => '结果最多';

  @override
  String idRngExcellentSidGroup(String tsv) {
    return 'TSV $tsv';
  }

  @override
  String idRngPidTargetCount(String count) {
    return '$count个目标';
  }

  @override
  String idRngNatureCount(String count) {
    return '$count种性格';
  }

  @override
  String idRngSidRangeShort(String range) {
    return 'SID $range';
  }

  @override
  String get idRngPidTargetNatures => '目标性格';

  @override
  String get idRngPidTargetMinIvs => '最低个体值';

  @override
  String get idRngPidTargetSearch => '检索PID目标';

  @override
  String get idRngPidTargetResults => 'PID目标结果';

  @override
  String get idRngPidTargetNoResults => '没有PID目标。';

  @override
  String get idRngPidTargetInvalidInput => '请检查性格和个体值筛选。';

  @override
  String idRngPidTargetGroup(String psv, String count) {
    return 'PSV $psv · $count个目标';
  }

  @override
  String idRngPidTargetGroupWithSid(String psv, String count, String sidRange) {
    return 'PSV $psv · $count个目标 · SID $sidRange';
  }

  @override
  String idRngPidTargetResult(
    String pid,
    String nature,
    String ivs,
    String ability,
  ) {
    return 'PID $pid · $nature · 个体值 $ivs · 特性 $ability';
  }

  @override
  String get genderRatio => '性别比例';

  @override
  String cuteCharmIdSummary(
    String pid,
    String tsv,
    String ability,
    String gender,
  ) {
    return 'PID $pid · TSV $tsv · 特性 $ability · 目标性别 $gender';
  }

  @override
  String get cuteCharmApplyIdTarget => '应用到ID检索';

  @override
  String idRngSearchSpace(String states) {
    return '检索量：$states seeds';
  }

  @override
  String get idRngNeedFilter => '至少输入TID、SID、TSV或PID。';

  @override
  String get idRngInvalidInput => '请检查ID乱数参数。';

  @override
  String idRngPidSummary(String psv, String nature) {
    return 'PSV $psv · 性格 $nature';
  }

  @override
  String idRngSidRange(String range) {
    return '可闪SID：$range';
  }

  @override
  String idRngSidCandidates(String values) {
    return 'SID候选：$values';
  }

  @override
  String get idRngSelectedState => '已选择ID结果';

  @override
  String get idRngSelectResultFirst => '请先选择一个ID结果。';

  @override
  String get idRngNoSeedTime => '请先获取并选择Seed时间。';

  @override
  String idRngResultSubtitle(String tid, String sid, String tsv) {
    return 'TID $tid · SID $sid · TSV $tsv';
  }

  @override
  String get idRngSearchHit => '反查命中Delay';

  @override
  String get idRngHitDelayWindow => 'Delay偏差';

  @override
  String get idRngHitResults => 'ID命中结果';

  @override
  String get idRngSelectedHit => '已选择命中ID';

  @override
  String get idRngNoHit => '没有找到匹配的TID/SID。';

  @override
  String get idRngHitHelp =>
      '该结果的Delay已填入ID定时器的实际Delay。点击应用校准后，仅更新ID校准Delay，不会改动遇敌定时器Delay。';

  @override
  String get gen4TargetCategoryWild => '野生';

  @override
  String get gen4TargetCategoryStationary => '定点';

  @override
  String get gen4TargetCategoryLegend => '传说';

  @override
  String get gen4TargetCategoryGift => '礼物';

  @override
  String get gen4TargetCategoryStarter => '御三家';

  @override
  String get gen4TargetCategoryFossil => '化石';

  @override
  String get gen4TargetCategoryGameCorner => '游戏中心';

  @override
  String get gen4TargetCategoryEvent => '事件';

  @override
  String get gen4TargetCategoryRoamer => '游走';

  @override
  String get gen4TargetWildGrass => '草丛';

  @override
  String get gen4TargetWildSurfing => '冲浪';

  @override
  String get gen4TargetWildOldRod => '破旧钓竿';

  @override
  String get gen4TargetWildGoodRod => '好钓竿';

  @override
  String get gen4TargetWildSuperRod => '厉害钓竿';

  @override
  String get gen4TargetWildRockSmash => '碎岩';

  @override
  String get gen4TargetWildBugCatchingContest => '捕虫大会';

  @override
  String get gen4TargetWildHeadbutt => '撞树';

  @override
  String get gen4TargetWildHeadbuttAlt => '撞树候补';

  @override
  String get gen4TargetWildHeadbuttSpecial => '特殊撞树';

  @override
  String get gen4TargetWildHoneyTree => '甜甜蜜树';

  @override
  String get gen4TargetTimeMorning => '早晨';

  @override
  String get gen4TargetTimeDay => '白天';

  @override
  String get gen4TargetTimeNight => '夜晚';

  @override
  String get gen4TargetMethodMethod1 => 'Method 1';

  @override
  String get gen4TargetMethodMethodJ => 'Method J';

  @override
  String get gen4TargetMethodMethodK => 'Method K';

  @override
  String get gen4TargetMethodHoneyTree => '甜甜蜜树';

  @override
  String get gen4TargetMethodPokeRadar => '宝可追踪';

  @override
  String get gen4TargetMethodPokeRadarShiny => '宝可追踪闪光';

  @override
  String get gen4TargetStaticStarter => '御三家';

  @override
  String get gen4TargetStaticFossil => '化石';

  @override
  String get gen4TargetStaticGift => '礼物';

  @override
  String get gen4TargetStaticGameCorner => '游戏中心';

  @override
  String get gen4TargetStaticStationary => '定点';

  @override
  String get gen4TargetStaticLegend => '传说';

  @override
  String get gen4TargetStaticEvent => '事件';

  @override
  String get gen4TargetStaticRoamer => '游走';

  @override
  String get gen4TargetShinyRandom => '随机闪光';

  @override
  String get gen4TargetShinyAlways => '必定闪光';

  @override
  String get gen4TargetShinyNever => '锁定不闪';

  @override
  String get gen4TargetModifierSwarm => '大量出现';

  @override
  String get gen4TargetModifierDay => '白天槽位';

  @override
  String get gen4TargetModifierNight => '夜晚槽位';

  @override
  String get gen4TargetModifierRadar => '宝可追踪';

  @override
  String get gen4TargetModifierRuby => '插入红宝石';

  @override
  String get gen4TargetModifierSapphire => '插入蓝宝石';

  @override
  String get gen4TargetModifierEmerald => '插入绿宝石';

  @override
  String get gen4TargetModifierFireRed => '插入火红';

  @override
  String get gen4TargetModifierLeafGreen => '插入叶绿';

  @override
  String get gen4TargetModifierFeebasTile => '丑丑鱼格子';

  @override
  String get gen4TargetModifierHoennSound => '丰缘音乐';

  @override
  String get gen4TargetModifierSinnohSound => '神奥音乐';

  @override
  String get gen4TargetModifierFishNight => '夜晚钓鱼';

  @override
  String get gen4TargetModifierFishSwarm => '钓鱼大量出现';

  @override
  String get gen4TargetModifierSafariBlocks => '狩猎地带摆设';

  @override
  String get gen4TargetModifierUnknown => '特殊槽位';

  @override
  String gen4TargetLevel(int level) {
    return '$level级';
  }

  @override
  String gen4TargetLevelRange(int minLevel, int maxLevel) {
    return '$minLevel-$maxLevel级';
  }
}

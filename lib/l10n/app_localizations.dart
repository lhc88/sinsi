import 'package:flutter/widgets.dart';

/// 간단한 코드 내장 다국어 지원 — 한국어(기본) / 영어
class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('ko'),
    Locale('en'),
  ];

  bool get _isKo => locale.languageCode == 'ko';

  // ──────── 타이틀 화면 ────────
  String get appTitle => _isKo ? '퇴마록' : 'TOEMALOK';
  String get appSubtitle => _isKo ? '百鬼夜行' : 'Parade of a Hundred Demons';
  String get appSubtitleEn => 'PARADE OF A HUNDRED DEMONS';
  String get startGame => _isKo ? '퇴마 시작' : 'Start';
  String get shop => _isKo ? '강화 상점' : 'Shop';
  String get codex => _isKo ? '도감' : 'Codex';
  String get settings => _isKo ? '설정' : 'Settings';

  // ──────── 일일 보상 ────────
  String dailyDay(int day) => _isKo ? '출석 $day일차' : 'Day $day';
  String dailyStreak(int streak) =>
      _isKo ? '연속 $streak일 출석!' : '$streak day streak!';
  String get claim => _isKo ? '받기' : 'Claim';

  // ──────── HUD ────────
  String get synergy => _isKo ? '시너지' : 'Synergy';
  String get achievement => _isKo ? '업적 달성' : 'Achievement';
  String get timeWarning => _isKo ? '최종 퇴마 시간! 30초 남았습니다!' : 'Final exorcism! 30 seconds left!';

  // ──────── 게임오버 / 승리 ────────
  String get gameOver => _isKo ? '퇴마 실패' : 'Game Over';
  String get victory => _isKo ? '퇴마 성공!' : 'Victory!';
  String get retry => _isKo ? '재도전' : 'Retry';
  String get toTitle => _isKo ? '타이틀로' : 'Title';
  String get result => _isKo ? '결과' : 'Result';
  String get killCount => _isKo ? '처치 수' : 'Kills';
  String get survivalTime => _isKo ? '생존 시간' : 'Time';
  String get coinsEarned => _isKo ? '획득 엽전' : 'Coins';
  String get doryeokEarned => _isKo ? '획득 도력' : 'Doryeok';

  // ──────── 일시정지 ────────
  String get paused => _isKo ? '일시정지' : 'Paused';
  String get resume => _isKo ? '계속' : 'Resume';
  String get quit => _isKo ? '포기' : 'Quit';

  // ──────── 레벨업 ────────
  String get levelUp => _isKo ? '레벨 업!' : 'Level Up!';
  String get chooseOne => _isKo ? '하나를 선택하세요' : 'Choose one';

  // ──────── 캐릭터 선택 ────────
  String get characterSelect => _isKo ? '퇴마사 선택' : 'Select Character';
  String get locked => _isKo ? '미해금' : 'Locked';

  // ──────── 스테이지 선택 ────────
  String get stageSelect => _isKo ? '출동 지역' : 'Select Stage';

  // ──────── 도감 ────────
  String get monsters => _isKo ? '요괴' : 'Monsters';
  String get weapons => _isKo ? '무기' : 'Weapons';
  String get bosses => _isKo ? '보스' : 'Bosses';
  String get achievements => _isKo ? '업적' : 'Achievements';
  String get undiscovered => _isKo ? '미발견' : 'Undiscovered';

  // ──────── 상점 ────────
  String get powerUp => _isKo ? '영구 강화' : 'Power Up';
  String get maxLevel => _isKo ? '최대' : 'MAX';

  // ──────── 설정 ────────
  String get sfxVolume => _isKo ? 'SFX' : 'SFX';
  String get bgmVolume => _isKo ? 'BGM' : 'BGM';
  String get language => _isKo ? '언어' : 'Language';
  String get colorBlind => _isKo ? '색약 모드' : 'Color Blind';
  String get resetData => _isKo ? '데이터 초기화' : 'Reset Data';

  // ──────── 재화 ────────
  String get coinName => _isKo ? '엽전' : 'Coins';
  String get soulStoneName => _isKo ? '귀혼석' : 'Soul Stones';
  String get doryeokName => _isKo ? '도력' : 'Doryeok';

  // ──────── 튜토리얼 ────────
  String get tutorialTitle => _isKo ? '조작법' : 'Controls';
  String get tutorialMove => _isKo ? '조이스틱으로 이동' : 'Move with joystick';
  String get tutorialAuto => _isKo ? '무기는 자동 공격' : 'Weapons fire automatically';
  String get tutorialExp => _isKo ? '기운을 수집하여 레벨업!' : 'Collect exp gems to level up!';
  String get tutorialOk => _isKo ? '알겠습니다!' : 'Got it!';

  // ──────── 스킬 트리 ────────
  String get skillTree => _isKo ? '스킬 트리' : 'Skill Tree';

  // ──────── 일일 도전 ────────
  String get dailyChallenge => _isKo ? '일일 도전' : 'Daily Challenge';
  String get dailyChallengeCompleted => _isKo ? '오늘 완료!' : 'Completed today!';
  String get dailyChallengeStart => _isKo ? '도전 시작' : 'Start Challenge';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ko', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate old) => false;
}

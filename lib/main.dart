import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'game/toemalok_game.dart';
import 'l10n/app_localizations.dart';
import 'services/save_service.dart';
import 'data/daily_challenge.dart';
import 'services/audio_service.dart';
import 'ui/shared/page_transition.dart';
import 'ui/overlays/hud_overlay.dart';
import 'ui/overlays/level_up_overlay.dart';
import 'ui/overlays/game_over_overlay.dart';
import 'ui/overlays/pause_overlay.dart';
import 'ui/overlays/debug_panel.dart';
import 'ui/overlays/tutorial_overlay.dart';
import 'ui/overlays/victory_overlay.dart';
import 'ui/screens/title_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await SaveService.instance.init();
  await AudioService.init();
  // SaveService → AudioService 볼륨 동기화
  AudioService.sfxVolume = SaveService.instance.sfxVolume;
  AudioService.bgmVolume = SaveService.instance.bgmVolume;
  runApp(const ToemalokApp());
}

class ToemalokApp extends StatefulWidget {
  const ToemalokApp({super.key});

  /// 언어 변경 시 앱 리빌드용
  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_ToemalokAppState>();
    state?._setLocale(locale);
  }

  @override
  State<ToemalokApp> createState() => _ToemalokAppState();
}

class _ToemalokAppState extends State<ToemalokApp> {
  Locale _locale = Locale(SaveService.instance.language);

  void _setLocale(Locale locale) {
    setState(() => _locale = locale);
    SaveService.instance.language = locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '퇴마록: 백귀야행',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        GamePageRoute(page: const TitleScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '퇴마록',
              style: TextStyle(
                color: Color(0xFFFFD166),
                fontSize: 48,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 20, color: Color(0xFFFFD166))],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '백귀야행',
              style: TextStyle(color: Color(0xFFA8DADC), fontSize: 18),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFFFD166),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  final String characterId;
  final String stageId;
  final String modeId;
  final DailyChallengeData? dailyChallenge;

  const GamePage({
    super.key,
    this.characterId = 'lee_taeyang',
    this.stageId = 'stage1',
    this.modeId = 'normal',
    this.dailyChallenge,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final ToemalokGame game;

  @override
  void initState() {
    super.initState();
    game = ToemalokGame(
      characterId: widget.characterId,
      stageId: widget.stageId,
      modeId: widget.modeId,
      dailyChallenge: widget.dailyChallenge,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'hud': (context, game) => HudOverlay(game: game as ToemalokGame),
          'levelUp': (context, game) =>
              LevelUpOverlay(game: game as ToemalokGame),
          'gameOver': (context, game) =>
              GameOverOverlay(game: game as ToemalokGame),
          'pause': (context, game) =>
              PauseOverlay(game: game as ToemalokGame),
          'debug': (context, game) =>
              DebugPanel(game: game as ToemalokGame),
          'tutorial': (context, game) =>
              TutorialOverlay(game: game as ToemalokGame),
          'victory': (context, game) =>
              VictoryOverlay(game: game as ToemalokGame),
        },
        initialActiveOverlays: const ['hud'],
      ),
    );
  }
}

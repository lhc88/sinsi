import 'package:flutter/material.dart';
import '../../data/daily_challenge.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../services/audio_service.dart';
import '../../services/save_service.dart';
import '../shared/page_transition.dart';
import 'character_select_screen.dart';
import 'shop_screen.dart';
import 'codex_screen.dart';
import 'achievement_screen.dart';
import 'settings_screen.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  @override
  void initState() {
    super.initState();
    AudioService.playBgm('title');
    // 일일 보상 체크
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyReward();
    });
  }

  void _checkDailyReward() {
    final result = SaveService.instance.claimDailyReward();
    if (result == null || !mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DailyRewardDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 게임 로고
            FadeSlideIn(
              slideFrom: const Offset(0, -0.2),
              child: Text(
                l.appTitle,
              style: const TextStyle(
                color: Color(0xFFFFD166),
                fontSize: 52,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
                shadows: [
                  Shadow(blurRadius: 20, color: Color(0xFFFFD166)),
                  Shadow(blurRadius: 40, color: Color(0xFFE63946)),
                ],
              ),
            ),
            ),
            const SizedBox(height: 4),
            Text(
              l.appSubtitle,
              style: const TextStyle(
                color: Color(0xFFA8DADC),
                fontSize: 20,
                letterSpacing: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.appSubtitleEn,
              style: const TextStyle(
                color: Color(0xFF808080),
                fontSize: 10,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 60),
            // 시작 버튼
            FadeSlideIn(
              delayMs: 100,
              child: _MenuButton(
                text: l.startGame,
                color: const Color(0xFFE63946),
                onTap: () {
                  Navigator.of(context).push(
                    GamePageRoute(page: const CharacterSelectScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            FadeSlideIn(delayMs: 200, child: _DailyChallengeButton()),
            const SizedBox(height: 12),
            FadeSlideIn(
              delayMs: 300,
              child: _MenuButton(
                text: l.shop,
                color: const Color(0xFF457B9D),
                onTap: () {
                  Navigator.of(context).push(
                    GamePageRoute(page: const ShopScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            FadeSlideIn(
              delayMs: 400,
              child: _MenuButton(
                text: l.codex,
                color: const Color(0xFF3E8948),
                onTap: () {
                  Navigator.of(context).push(
                    GamePageRoute(page: const CodexScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            FadeSlideIn(
              delayMs: 500,
              child: _MenuButton(
                text: l.achievements,
                color: const Color(0xFFC9A96E),
                onTap: () {
                  Navigator.of(context).push(
                    GamePageRoute(page: const AchievementScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            FadeSlideIn(
              delayMs: 600,
              child: _MenuButton(
                text: l.settings,
                color: const Color(0xFF404040),
                onTap: () {
                  Navigator.of(context).push(
                    GamePageRoute(page: const SettingsScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Sinsi Games',
              style: TextStyle(color: Color(0xFF808080), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyRewardDialog extends StatelessWidget {
  final DailyRewardResult result;
  const _DailyRewardDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rewards = <String>[];
    if (result.coins > 0) rewards.add('${result.coins} ${l.coinName}');
    if (result.soulStones > 0) rewards.add('${result.soulStones} ${l.soulStoneName}');
    if (result.doryeok > 0) rewards.add('${result.doryeok} ${l.doryeokName}');

    return Dialog(
      backgroundColor: const Color(0xFF1D3557),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard, color: Color(0xFFFFD166), size: 48),
            const SizedBox(height: 12),
            Text(
              l.dailyDay(result.day),
              style: const TextStyle(color: Color(0xFFFFD166), fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              l.dailyStreak(result.streak),
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...rewards.map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(r, style: const TextStyle(color: Color(0xFF7EC850), fontSize: 16)),
            )),
            const SizedBox(height: 20),
            // 7일 보상 일러스트 (주간 표시)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(7, (i) {
                final dayNum = i + 1;
                final isToday = dayNum == result.day;
                final isPast = dayNum < result.day;
                return Container(
                  width: 28, height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isToday
                        ? const Color(0xFFFFD166)
                        : isPast
                            ? const Color(0xFF7EC850)
                            : const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        color: isToday || isPast ? Colors.black : Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE63946),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(l.claim, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyChallengeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final today = DateTime.now();
    final challenge = getDailyChallenge(today);
    final dateStr = '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
    final completed = SaveService.instance.isDailyChallengeCompleted(dateStr);

    return GestureDetector(
      onTap: completed ? null : () {
        showDialog(
          context: context,
          builder: (ctx) => _DailyChallengeDialog(challenge: challenge),
        );
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: completed ? const Color(0xFF333333) : const Color(0xFFFF8C42),
          borderRadius: BorderRadius.circular(8),
          boxShadow: completed ? null : [
            BoxShadow(color: const Color(0xFFFF8C42).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: Text(
            completed ? l.dailyChallengeCompleted : l.dailyChallenge,
            style: TextStyle(
              color: completed ? Colors.white38 : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyChallengeDialog extends StatelessWidget {
  final DailyChallengeData challenge;
  const _DailyChallengeDialog({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: const Color(0xFF1D3557),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department, color: Color(0xFFFF8C42), size: 48),
            const SizedBox(height: 12),
            Text(
              challenge.name,
              style: const TextStyle(color: Color(0xFFFFD166), fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '보상: ${challenge.rewardCoins} 엽전${challenge.rewardSoulStones > 0 ? ' + ${challenge.rewardSoulStones} 귀혼석' : ''}',
              style: const TextStyle(color: Color(0xFF7EC850), fontSize: 14),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  GamePageRoute(page: GamePage(
                    stageId: 'stage1',
                    dailyChallenge: challenge,
                  )),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE63946),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(l.dailyChallengeStart,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({required this.text, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AudioService.uiClick();
        onTap();
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flame_audio/flame_audio.dart';

/// 오디오 서비스 래퍼 — BGM/SFX 관리
class AudioService {
  static double sfxVolume = 1.0;
  static double bgmVolume = 0.7;
  static bool _bgmPlaying = false;

  // SFX 쓰로틀링: 프레임당 최대 3개, 같은 사운드 최소 간격 50ms
  static int _sfxThisFrame = 0;
  static const int _maxSfxPerFrame = 3;
  static final Map<String, int> _lastPlayTime = {};
  static const int _minIntervalMs = 50;

  /// 매 프레임 시작 시 호출
  static void resetFrameThrottle() {
    _sfxThisFrame = 0;
  }

  static Future<void> init() async {
    await FlameAudio.audioCache.loadAll([
      'sfx/enemy_hit.wav',
      'sfx/enemy_death.wav',
      'sfx/exp_collect.wav',
      'sfx/level_up.wav',
      'sfx/chest_open.wav',
      'sfx/boss_appear.wav',
      'sfx/evolution.wav',
      'sfx/player_hit.wav',
      'sfx/ui_click.wav',
      'sfx/weapon_generic.wav',
      'sfx/weapon_toema_bujeok.wav',
      'sfx/weapon_binyeo_geom.wav',
      'sfx/weapon_dokkaebi_bul.wav',
      'sfx/weapon_cheondung.wav',
      'sfx/weapon_punggyeong.wav',
      'sfx/weapon_cheongryongdo.wav',
      'sfx/weapon_geumgangeo.wav',
      'sfx/weapon_sinseong_bangul.wav',
      'sfx/weapon_pungmul_buk.wav',
      'sfx/weapon_yogi_baltop.wav',
      'sfx/weapon_palgwaejin.wav',
      'sfx/weapon_hwasal.wav',
      'sfx/weapon_dokangae.wav',
      'sfx/weapon_dolpalmae.wav',
      'sfx/crit_hit.wav',
      'sfx/elite_spawn.wav',
      'sfx/milestone.wav',
      'sfx/wave_start.wav',
      'sfx/ui_back.wav',
      'sfx/daily_reward.wav',
    ]);
  }

  static void playSfx(String name) {
    if (sfxVolume <= 0) return;
    if (_sfxThisFrame >= _maxSfxPerFrame) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _lastPlayTime[name] ?? 0;
    if (now - last < _minIntervalMs) return;

    _sfxThisFrame++;
    _lastPlayTime[name] = now;
    try {
      FlameAudio.play('sfx/$name.wav', volume: sfxVolume);
    } catch (_) {
      // 에셋 없으면 무시 (개발 중)
    }
  }

  static void playBgm(String name) {
    if (bgmVolume <= 0) return;
    try {
      if (_bgmPlaying) FlameAudio.bgm.stop();
      FlameAudio.bgm.play('bgm/$name.wav', volume: bgmVolume);
      _bgmPlaying = true;
    } catch (_) {}
  }

  static void stopBgm() {
    try {
      FlameAudio.bgm.stop();
      _bgmPlaying = false;
    } catch (_) {}
  }

  static void pauseBgm() {
    try {
      FlameAudio.bgm.pause();
    } catch (_) {}
  }

  static void resumeBgm() {
    try {
      FlameAudio.bgm.resume();
    } catch (_) {}
  }

  // ──────── BGM 동적 강도 ────────
  static double _bgmIntensity = 0.5; // 0=평화, 1=전투 최고조
  static double _targetIntensity = 0.5;

  /// 적 수에 따라 BGM 볼륨/속도 조절
  static void updateBgmIntensity(int activeEnemyCount, bool bossActive) {
    _targetIntensity = bossActive
        ? 1.0
        : (activeEnemyCount / 150).clamp(0.2, 0.9);

    // 부드럽게 전환
    _bgmIntensity += (_targetIntensity - _bgmIntensity) * 0.02;

    // 볼륨 조절 (기본 볼륨의 70~100%)
    if (_bgmPlaying && bgmVolume > 0) {
      try {
        FlameAudio.bgm.audioPlayer.setVolume(
          bgmVolume * (0.7 + _bgmIntensity * 0.3));
      } catch (_) {}
    }
  }

  // SFX 이벤트 이름
  static void weaponFire(String weaponId) {
    // 전용 SFX가 있으면 사용, 없으면 generic
    final specific = 'sfx/weapon_$weaponId.wav';
    if (FlameAudio.audioCache.loadedFiles.containsKey(specific)) {
      playSfx('weapon_$weaponId');
    } else {
      playSfx('weapon_generic');
    }
  }
  static void enemyHit() => playSfx('enemy_hit');
  static void enemyDeath() => playSfx('enemy_death');
  static void levelUp() => playSfx('level_up');
  static void chestOpen() => playSfx('chest_open');
  static void bossAppear() => playSfx('boss_appear');
  static void expCollect() => playSfx('exp_collect');
  static void evolution() => playSfx('evolution');
  static void critHit() => playSfx('crit_hit');
  static void eliteSpawn() => playSfx('elite_spawn');
  static void milestone() => playSfx('milestone');
  static void waveStart() => playSfx('wave_start');
  static void uiClick() => playSfx('ui_click');
  static void uiBack() => playSfx('ui_back');
  static void dailyReward() => playSfx('daily_reward');
  static void prestige() => playSfx('evolution'); // 진화와 같은 사운드 재활용
}

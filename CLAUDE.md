# 퇴마록: 백귀야행 (TOEMALOK)

뱀파이어 서바이버즈류 한국 신화 테마 로그라이크 서바이벌. Flutter + Flame Engine. Android (Google Play).

## 디렉토리 구조

```
lib/
  main.dart                    — GameWidget 초기화
  game/toemalok_game.dart      — FlameGame (게임 루프, 카메라)
  components/player/           — Player, Movement, Stats
  components/enemies/          — BaseEnemy, 각 적, EnemyPool, EnemyBatchRenderer
  components/weapons/          — BaseWeapon, 각 무기, WeaponManager
  components/projectiles/      — BaseProjectile, ProjectilePool, ProjectileBatchRenderer
  components/items/            — ExpGem, TreasureChest, DropItem
  components/effects/          — ParticleEffects, DamageNumber, ScreenShake
  systems/                     — WaveSpawner, LevelUpSystem, EvolutionSystem, ElementalSystem, CollisionGrid
  ui/overlays/                 — LevelUpOverlay, PauseMenu, ResultScreen, DebugPanel
  ui/screens/                  — TitleScreen, CharacterSelect, StageSelect, ShopScreen
  data/                        — characters.dart, weapons.dart, enemies.dart, stages.dart, passives.dart, evolutions.dart
  services/                    — SaveService(Hive), AdService, AudioService
  utils/                       — constants.dart, object_pool.dart, collision_grid.dart, tuning_params.dart
```

## 코딩 컨벤션

- Dart 네이밍: camelCase 변수, PascalCase 클래스, snake_case 파일명
- 컴포넌트 기반 아키텍처
- 데이터 주도: data/ 폴더에 const로 정의. 하드코딩 수치 금지
- 오브젝트 풀링 필수 (적, 투사체, 기운)

## 렌더링 규칙

- 적/투사체/기운은 SpriteComponent 상속 금지 → SpriteBatch로 일괄 렌더링
- 보스만 개별 SpriteComponent 허용 (수가 적으므로)
- 이펙트는 Canvas 직접 draw로 경량 구현

## 충돌 시스템

- Flame 기본 CollisionCallbacks 사용 금지
- 커스텀 CollisionGrid (64px 셀) 사용
- 같은 셀 + 인접 8셀만 비교

## 성능 목표

- 고사양: 300적 60fps
- 저사양(Galaxy A23): 150적 30fps
- 적 AI: 5그룹 로테이션 (프레임당 1그룹)
- 화면 밖 적: 5프레임마다만 갱신

## 테스트

- systems/ 내 로직은 반드시 유닛 테스트 작성
- 데미지 계산, 상성, 진화 조건 검증

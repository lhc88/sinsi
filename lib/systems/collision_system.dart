import 'dart:math';
import 'dart:ui' show Color;
import 'package:flame/components.dart';
import '../components/enemies/enemy_instance.dart';
import '../game/toemalok_game.dart';
import '../systems/elemental_system.dart';
import '../utils/collision_grid.dart';
import '../utils/tuning_params.dart';
import '../services/audio_service.dart';
import '../services/save_service.dart';

class CollisionSystem {
  final CollisionGrid _grid = CollisionGrid();
  final Random _rng = Random();

  void update(ToemalokGame game, double dt) {
    _grid.clear();

    final player = game.player;
    final enemies = game.enemyManager.activeEnemies;
    final projectiles = game.projectileManager.activeProjectiles;
    final gems = game.expGemManager.activeGems;

    // 적 등록
    for (int i = 0; i < enemies.length; i++) {
      final e = enemies[i];
      if (!e.isActive) continue;
      _grid.insert(CollisionEntity(
        position: e.position,
        radius: e.size / 2,
        layer: CollisionLayer.enemy,
        id: i,
      ));
    }

    // 투사체-적 충돌
    for (final proj in projectiles.toList()) {
      if (!proj.isActive) continue;

      final hits = _grid.query(proj.position, proj.area, CollisionLayer.enemy);
      for (final hit in hits) {
        if (hit.id >= enemies.length) continue;
        final enemy = enemies[hit.id];
        if (!enemy.isActive) continue;

        // 데미지 적용 (오행 상성 + 시너지 + 모드 상극 배율 + 스킬 보너스)
        var elemMulti = ElementalSystem.getMultiplier(proj.element, enemy.element);
        // 모드 상극 배율: 기본 1.5x → modeData.counterMultiplier
        if (elemMulti > 1.0) {
          elemMulti = game.modeData.counterMultiplier + game.player.stats.skillCounterMultiplier;
        }
        final synergyMulti = 1.0 + game.player.stats.synergyDamageBonus;
        final skillMulti = 1.0 + game.player.stats.skillDamageBonus;
        var damage = proj.damage * game.player.stats.effectiveMight * elemMulti * synergyMulti * skillMulti;

        // 치명타 판정
        final critChance = game.player.stats.skillCritChance;
        bool isCrit = false;
        if (critChance > 0 && _rng.nextDouble() < critChance) {
          damage *= (1.5 + game.player.stats.skillCritDamage);
          isCrit = true;
        } else if (game.player.stats.skillCritPenalty) {
          damage *= 0.5; // 일일 도전: 비치명타 절반
          // 소연 1-3: 치명타 시 2초 은신
          if (game.player.stats.skillCritStealth) {
            game.player.stats.skillStealthTimer = 2.0;
          }
        }

        game.enemyManager.applyDamage(enemy, damage);
        game.player.stats.totalDamageDealt += damage;
        game.effectManager.spawnDamageNumber(enemy.position, damage, isCrit: isCrit);
        if (isCrit) {
          // 치명타 이펙트: 작은 폭발 + 화면 미세 번쩍
          game.effectManager.spawnExplosion(enemy.position, enemy.size * 0.6);
          game.triggerScreenFlash(const Color(0x22FFFFFF), 0.1);
          AudioService.critHit();
        }
        // 오버킬 (데미지가 적 최대HP의 3배 이상)
        if (damage >= enemy.maxHp * 3) {
          game.effectManager.spawnExplosion(enemy.position, enemy.size * 1.2);
        }
        AudioService.enemyHit();

        // 독 부여 (소연 3-1)
        if (game.player.stats.skillPoisonOnHit) {
          enemy.poisonTimer = 3.0;
          enemy.poisonDamage = damage * 0.1 * (1 + game.player.stats.skillPoisonDamage);
        }

        // 슬로우 부여 (월희 1-2)
        if (game.player.stats.skillSlowOnHit) {
          enemy.slowTimer = 2.0;
        }

        // 흡혈
        final lifesteal = game.player.stats.skillLifesteal;
        if (lifesteal > 0) {
          game.player.stats.heal(damage * lifesteal);
        }

        proj.hitCount++;

        // skillSplitOnPierce: 관통 시 분열 투사체 생성
        if (game.player.stats.skillSplitOnPierce && proj.hitCount <= proj.pierce) {
          final perpAngle = atan2(proj.velocity.y, proj.velocity.x) + pi / 2;
          final splitSpeed = proj.velocity.length * 0.7;
          game.projectileManager.spawn(
            weaponId: proj.weaponId,
            position: proj.position.clone(),
            velocity: Vector2(cos(perpAngle), sin(perpAngle)) * splitSpeed,
            damage: proj.damage * 0.4,
            pierce: 0,
            maxLifetime: 1.0,
            area: proj.area * 0.8,
            size: proj.size * 0.7,
            element: proj.element,
          );
        }

        if (proj.hitCount > proj.pierce) {
          game.projectileManager.killProjectile(proj);
          break;
        }
      }
    }

    // 적-플레이어 충돌 (접촉 쿨다운 적용)
    for (final enemy in enemies.toList()) {
      if (!enemy.isActive) continue;
      if (enemy.contactCooldown > 0) continue;
      final dist = enemy.position.distanceTo(player.position);
      if (dist < enemy.size / 2 + 24) {
        enemy.contactCooldown = TuningParams.enemyContactCooldown;
        player.onHit(enemy.damage);
        // 흡혈 엘리트: 접촉 데미지의 50% HP 회복
        if (enemy.eliteType == EliteType.vampiric) {
          enemy.hp = (enemy.hp + enemy.damage * 0.5).clamp(0, enemy.maxHp);
        }
        if (player.stats.isDead) {
          game.onPlayerDeath();
          return;
        }
      }
    }

    // 적 사망 처리
    for (final enemy in enemies.toList()) {
      if (!enemy.isActive) continue;
      if (enemy.isDead) {
        // 독 사망 시 폭발 전파 (소연 3-3)
        if (game.player.stats.skillPoisonExplode && enemy.poisonTimer > 0) {
          for (final nearby in enemies) {
            if (!nearby.isActive || nearby == enemy) continue;
            if (nearby.position.distanceTo(enemy.position) < 60) {
              game.enemyManager.applyDamage(nearby, enemy.poisonDamage * 3);
              nearby.poisonTimer = 3.0;
              nearby.poisonDamage = enemy.poisonDamage;
            }
          }
          game.effectManager.spawnExplosion(enemy.position, 60);
        }

        // 연쇄 폭발 20% (단비 1-2)
        if (game.player.stats.skillChainExplosion && _rng.nextDouble() < 0.2) {
          for (final nearby in enemies) {
            if (!nearby.isActive || nearby == enemy) continue;
            if (nearby.position.distanceTo(enemy.position) < 80) {
              game.enemyManager.applyDamage(nearby, 20);
              // 슬로우 (단비 1-3)
              if (game.player.stats.skillExplosionSlow) {
                nearby.slowTimer = 2.0;
              }
            }
          }
          game.effectManager.spawnExplosion(enemy.position, 80);
        }

        // 엘리트 사망 특수 효과
        if (enemy.isElite) {
          game.onEliteKilled();
          switch (enemy.eliteType) {
            case EliteType.splitter:
              // 2마리 분열
              for (int i = 0; i < 2; i++) {
                final offset = Vector2(_rng.nextDouble() * 30 - 15, _rng.nextDouble() * 30 - 15);
                game.enemyManager.spawnEnemy(
                  enemy.type, enemy.position + offset, game.gameTime / 60);
              }
            case EliteType.explosive:
              // 주변 100px 폭발 (플레이어 데미지)
              if (game.player.position.distanceTo(enemy.position) < 100) {
                game.player.onHit(enemy.damage * 0.5);
              }
              game.effectManager.spawnExplosion(enemy.position, 100);
              game.triggerScreenShake(5, 0.2);
            default:
              break;
          }
        }

        // 기운 드롭
        final gemMulti = game.eventSystem.gemDropMultiplier;
        game.expGemManager.spawnGem(enemy.position, enemy.expDrop * gemMulti);
        // 사망 이펙트
        game.effectManager.spawnDeathEffect(enemy.position, enemy.size * (enemy.isElite ? 1.5 : 1.0));
        AudioService.enemyDeath();
        // 킬 카운트 (스킬 트리 연동)
        game.player.stats.onKill();
        // 도감 발견
        SaveService.instance.discover(enemy.type.name);
        // 풀에 반환
        game.enemyManager.killEnemy(enemy);

        _recentKills++;
      }
    }

    // 대량 처치 피드백 스케일링
    if (_recentKills > 0) {
      _killStreakTimer = 2.0; // 2초 윈도우
      _killStreak += _recentKills;

      if (_killStreak > game.player.stats.bestKillStreak) {
        game.player.stats.bestKillStreak = _killStreak;
      }
      if (_killStreak >= 50) {
        // 50킬+: 대폭발 + 강진동 + 슬로우
        game.triggerScreenShake(8, 0.4);
        game.effectManager.spawnExplosion(game.player.position, 200);
        game.effectManager.spawnKillStreakText(game.player.position, _killStreak);
        game.triggerMassKillSlowMo();
        game.triggerScreenFlash(const Color(0x33FF4444), 0.2);
      } else if (_killStreak >= 25) {
        game.triggerScreenShake(6, 0.3);
        game.effectManager.spawnKillStreakText(game.player.position, _killStreak);
        game.triggerMassKillSlowMo();
      } else if (_killStreak >= 10) {
        game.triggerScreenShake();
        game.effectManager.spawnKillStreakText(game.player.position, _killStreak);
      }
      _recentKills = 0;
    }

    // 투사체-파괴물 충돌
    final destructibles = game.destructibleManager.activeDestructibles;
    for (final d in destructibles.toList()) {
      if (!d.isActive || d.isDestroyed) continue;
      for (final proj in projectiles.toList()) {
        if (!proj.isActive) continue;
        final dx = proj.position.x - d.x;
        final dy = proj.position.y - d.y;
        if (dx * dx + dy * dy < (proj.area + d.size / 2) * (proj.area + d.size / 2)) {
          d.takeDamage(proj.damage * player.stats.effectiveMight);
          proj.hitCount++;
          if (proj.hitCount > proj.pierce) {
            game.projectileManager.killProjectile(proj);
          }
          if (d.isDestroyed) {
            // 드롭 처리
            if (d.dropsExp) {
              game.expGemManager.spawnGem(Vector2(d.x, d.y), d.expDrop);
            }
            if (d.dropsHeal) {
              player.stats.heal(d.healAmount);
              game.effectManager.spawnDamageNumber(Vector2(d.x, d.y), d.healAmount, isHeal: true);
            }
            // 파괴 이펙트
            game.effectManager.spawnDeathEffect(Vector2(d.x, d.y), d.size);
            game.destructibleManager.kill(d);
            break;
          }
        }
      }
    }

    // 기운-플레이어 수집
    for (final gem in gems.toList()) {
      if (!gem.isActive) continue;
      final dist = gem.position.distanceTo(player.position);

      // 수집 범위 내 → 자석 활성화
      if (dist < player.stats.pickupRange && !gem.isBeingCollected) {
        game.expGemManager.startCollecting(gem);
      }

      // 수집 중이면 플레이어 방향으로 이동
      if (gem.isBeingCollected) {
        gem.collectSpeed += TuningParams.magnetAccel * dt;
        final dir = player.position - gem.position;
        if (dir.length < 12) {
          // 수집 완료
          final expMulti = game.eventSystem.expMultiplier * (1.0 + SaveService.instance.prestigeExpBonus) * (1.0 + player.stats.skillExpDropBonus);
          final leveledUp = player.stats.addExp(gem.value * expMulti);
          game.effectManager.spawnGemCollectEffect(player.position, gem.tier);
          game.expGemManager.collectGem(gem);
          AudioService.expCollect();
          if (leveledUp) {
            game.onPlayerLevelUp();
          }
        } else {
          gem.position += dir.normalized() * gem.collectSpeed * dt;
        }
      }
    }
  }

  int _recentKills = 0;
  int _killStreak = 0;
  double _killStreakTimer = 0;

  void updateTimers(double dt) {
    if (_killStreakTimer > 0) {
      _killStreakTimer -= dt;
      if (_killStreakTimer <= 0) {
        _killStreak = 0;
      }
    }
  }
}

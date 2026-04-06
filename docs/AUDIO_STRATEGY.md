# 퇴마록: 백귀야행 — 오디오 제작 전략 v1.0

> 최종 업데이트: 2026-04-05
> 코드 기준: `lib/services/audio_service.dart` + `lib/data/stages.dart`
> 총 오디오: SFX 30종 + BGM 9종 = 39종
> 현재 상태: SFX 24/30 존재, BGM 3/9 존재 — **미생성 12종**

---

## 1. 오디오 디렉션

### 1-1. 핵심 스타일
- **장르**: 16-bit 레트로 + 한국 전통 악기 퓨전
- **테마**: 조선시대 퇴마 + 한국 신화 요괴
- **톤**: 긴장감 있되 과하지 않은, 반복 재생에 피로하지 않은 사운드
- **참고작**: Vampire Survivors (미니멀 레트로), Hades (동양 퓨전), 리듬세상 (8bit)

### 1-2. 기술 사양
```
포맷:      WAV (PCM 16-bit)
샘플레이트: 22050 Hz (기존 파일과 통일)
채널:      Mono
비트뎁스:   16-bit
```

> **중요**: 기존 24종 파일이 모두 `PCM 16-bit, mono, 22050Hz`로 통일되어 있으므로
> 신규 파일도 반드시 같은 사양으로 제작해야 합니다.

### 1-3. 볼륨 밸런스 기준
- SFX 기본 볼륨: `sfxVolume = 1.0` (사용자 설정)
- BGM 기본 볼륨: `bgmVolume = 0.7` (사용자 설정)
- BGM 동적 범위: `bgmVolume × (0.7 + intensity × 0.3)` — 평화 시 70%, 보스전 100%
- SFX 쓰로틀링: 프레임당 최대 3개, 같은 SFX 최소 50ms 간격

### 1-4. 파일 크기 가이드
```
SFX: 0.1~1.0초 → 2~44KB (현재 파일 기준)
BGM: 4~8초 루프 → 200~700KB (현재 ~345KB/곡)
전체 예상: SFX ~500KB + BGM ~3MB = ~3.5MB
```

---

## 2. SFX 상세 사양 — 존재하는 파일 (24종)

### 2-1. 무기 SFX (15종) — 모두 존재 ✅

코드 호출: `AudioService.weaponFire(weaponId)` → `weapon_$weaponId.wav` 또는 `weapon_generic.wav`

| 파일명 | 무기 | 원소 | 사운드 특성 | 길이 | 크기 |
|--------|------|------|------------|------|------|
| `weapon_toema_bujeok.wav` | 퇴마부적 | 화 | 종이 펄럭+불꽃 딱 | 0.15s | 6.5KB |
| `weapon_binyeo_geom.wav` | 비녀검 | 금 | 금속 칼날 슉+반짝임 | 0.2s | 8.7KB |
| `weapon_cheongryongdo.wav` | 청룡도 | 목 | 무거운 칼바람 휘이익 | 0.25s | 10.8KB |
| `weapon_geumgangeo.wav` | 금강저 | 토 | 금속 울림+충격파 웅 | 0.3s | 13KB |
| `weapon_sinseong_bangul.wav` | 신성 방울 | 수 | 맑은 방울 딸랑+음파 확산 | 0.4s | 17.3KB |
| `weapon_pungmul_buk.wav` | 풍물북 | 화 | 북 둥둥+폭발 | 0.25s | 10.8KB |
| `weapon_yogi_baltop.wav` | 요기 발톱 | 목 | 발톱 긁기 스윽+에너지 | 0.12s | 5.2KB |
| `weapon_palgwaejin.wav` | 팔괘진 | 토 | 기 모으기+8방향 발사 | 0.3s | 13KB |
| `weapon_hwasal.wav` | 화살 | 금 | 활시위 통+화살 슉 | 0.15s | 6.5KB |
| `weapon_dokangae.wav` | 독안개 | 수 | 연기 쉬이+독 찌직 | 0.2s | 8.7KB |
| `weapon_dolpalmae.wav` | 돌팔매 | 토 | 돌 회전 윙+투척 | 0.18s | 7.8KB |
| `weapon_cheondung.wav` | 천둥 | 금 | 번개 찌지직+천둥 우르릉 | 0.4s | 17.3KB |
| `weapon_punggyeong.wav` | 풍경 | 목 | 풍경 종소리 딸랑딸랑 | 0.35s | 15.2KB |
| `weapon_dokkaebi_bul.wav` | 도깨비불 | 화 | 도깨비불 보오+흐릿한 불꽃 | 0.3s | 13KB |
| `weapon_generic.wav` | (공통 폴백) | - | 일반적 에너지 발사 | 0.12s | 5.2KB |

### 2-2. 게임 이벤트 SFX (9종) — 모두 존재 ✅

| 파일명 | 트리거 | 코드 호출 | 사운드 특성 | 길이 | 크기 |
|--------|--------|----------|------------|------|------|
| `enemy_hit.wav` | 적 피격 | `AudioService.enemyHit()` | 짧은 타격 탁 | 0.1s | 4.4KB |
| `enemy_death.wav` | 적 사망 | `AudioService.enemyDeath()` | 퍼지는 소멸 푸웃 | 0.25s | 10.8KB |
| `exp_collect.wav` | EXP 수집 | `AudioService.expCollect()` | 반짝이는 띵 | 0.08s | 3.5KB |
| `level_up.wav` | 레벨업 | `AudioService.levelUp()` | 상승 팡파레 띠리링 | 0.6s | 25.9KB |
| `boss_appear.wav` | 보스 등장 | `AudioService.bossAppear()` | 위압 쿵+경고음 | 1.0s | 43.1KB |
| `chest_open.wav` | 상자 열기 | `AudioService.chestOpen()` | 뚜껑 딸깍+반짝임 | 0.5s | 21.6KB |
| `evolution.wav` | 무기 진화 / 프레스티지 | `AudioService.evolution()` | 화려한 파워업 | 1.2s | 51.8KB |
| `player_hit.wav` | 플레이어 피격 | `AudioService.playSfx('player_hit')` | 고통 억+플래시 | 0.15s | 6.5KB |
| `ui_click.wav` | UI 버튼 클릭 | `AudioService.uiClick()` | 깔끔한 딸깍 | 0.06s | 2.6KB |

---

## 3. SFX 상세 사양 — 미생성 파일 (6종)

### SFX-NEW-01. `crit_hit.wav` — 치명타 적중

**코드 호출:** `AudioService.critHit()`
**트리거 위치:** `collision_system.dart:77` — 투사체가 치명타 발생 시

**사운드 설계:**
```
특성: enemy_hit.wav보다 더 강렬하고 임팩트 있는 타격
구성: [금속 충격 쨍] + [타격 쾅] + 잔향
느낌: "결정타를 날렸다" — 만족스러운 타격감
참고: Vampire Survivors의 크리티컬 — 더 날카롭고 강한 타격음
```

**제작 가이드:**
```
sfxr.me 파라미터:
  Type: Hit/Hurt 기본에서 시작
  Attack: 0 (즉시 시작)
  Sustain: 0.08 (짧게)
  Decay: 0.15 (잔향 약간)
  Frequency: 500-800Hz (중저음)
  + 금속 하모닉스 레이어 추가

대안: enemy_hit.wav를 기반으로:
  피치 약간 낮추기 (-2~3 semitones)
  볼륨 1.3x
  짧은 리버브 추가
  금속성 하이 레이어 합성
```

**기술 사양:** WAV, 16-bit, mono, 22050Hz, ~0.15s, ~7KB

---

### SFX-NEW-02. `elite_spawn.wav` — 엘리트 적 생성

**코드 호출:** `AudioService.eliteSpawn()`
**트리거 위치:** `wave_spawner.dart:107` — 엘리트 변형 적 스폰 시

**사운드 설계:**
```
특성: "강한 놈이 왔다" 경고성 사운드. boss_appear보다 짧고 가벼움
구성: [저음 쿵] + [빛나는 윙~] + 짧은 에코
느낌: 위협적이지만 짧아서 게임 방해 안 됨
참고: Vampire Survivors 엘리트 스폰 — 짧은 경고 사운드
```

**제작 가이드:**
```
sfxr.me 파라미터:
  Type: Power Up 기본에서 시작
  Attack: 0.02
  Sustain: 0.15
  Decay: 0.2
  Frequency: 200-400Hz (위협적 저음)
  Frequency Slide: 약간 하강 (위압감)
  
대안: boss_appear.wav를 기반으로:
  앞부분 0.3초만 잘라내기
  피치 올리기 (+3 semitones)
  볼륨 0.7x (보스보다 약하게)
```

**기술 사양:** WAV, 16-bit, mono, 22050Hz, ~0.3s, ~13KB

---

### SFX-NEW-03. `milestone.wav` — 마일스톤 달성

**코드 호출:** `AudioService.milestone()`
**트리거 위치:** `toemalok_game.dart:885,895` — 킬 마일스톤 (100, 500, 1000…) 달성 시

**사운드 설계:**
```
특성: 업적 달성 축하 사운드. 긍정적이고 기분 좋은 알림
구성: [상승 아르페지오 띠리링~] + [반짝임 효과]
느낌: "잘 하고 있어!" — level_up보다 짧고 부담 없는
참고: 모바일 게임 업적 팝업 사운드
```

**제작 가이드:**
```
sfxr.me 파라미터:
  Type: Power Up 기본에서 시작
  Attack: 0
  Sustain: 0.2
  Decay: 0.3
  Frequency: 800-1200Hz (밝은 고음)
  Frequency Slide: 상승 (+)
  Vibrato: 약간 (반짝임 느낌)

대안: level_up.wav를 기반으로:
  길이 50% 잘라내기 (뒷부분)
  피치 약간 올리기 (+2 semitones)
  볼륨 0.8x
```

**기술 사양:** WAV, 16-bit, mono, 22050Hz, ~0.4s, ~18KB

---

### SFX-NEW-04. `wave_start.wav` — 웨이브 시작

**코드 호출:** `AudioService.waveStart()`
**트리거 위치:** `wave_spawner.dart:58` — 새 웨이브 시작 시

**사운드 설계:**
```
특성: 전투 시작 신호. 긴장감 고조. 짧은 경고/전환 사운드
구성: [북소리 둥] + [금속 날카로운 찡] 
느낌: "다음 물결이 온다" — 전투 전환 알림
참고: 타워 디펜스 웨이브 시작음
```

**제작 가이드:**
```
sfxr.me 파라미터:
  Type: Laser/Shoot 기본에서 시작
  Attack: 0.01
  Sustain: 0.1
  Decay: 0.2
  Frequency: 300-500Hz (중음)
  Change Amount: 약간의 하강
  Square Duty: 0.5 (풍성한 음색)

대안: boss_appear.wav 앞부분 + 자체 제작:
  두둥 소리 0.2초 
  뒤에 날카로운 찡 0.1초 합성
```

**기술 사양:** WAV, 16-bit, mono, 22050Hz, ~0.25s, ~11KB

---

### SFX-NEW-05. `ui_back.wav` — UI 뒤로가기

**코드 호출:** `AudioService.uiBack()`
**트리거 위치:** (현재 직접 호출 코드 없음, 향후 UI 네비게이션에서 사용)

**사운드 설계:**
```
특성: ui_click.wav의 반대 느낌. 부드럽게 물러나는 소리
구성: [하강 톤 뚜] — 클릭보다 약간 길고 음이 내려감
느낌: "취소/뒤로" — 부정적이지 않고 자연스러운 전환
참고: iOS 뒤로가기 햅틱 사운드 느낌
```

**제작 가이드:**
```
sfxr.me 파라미터:
  Type: Blip/Select 기본에서 시작
  Attack: 0
  Sustain: 0.05
  Decay: 0.1
  Frequency: 600Hz → 400Hz (하강)
  Frequency Slide: 하강 (-)
  Volume: ui_click의 90%

대안: ui_click.wav를 기반으로:
  피치 낮추기 (-3 semitones)
  리버스는 X (자연스럽지 않음)
  약간 더 긴 디케이
```

**기술 사양:** WAV, 16-bit, mono, 22050Hz, ~0.08s, ~3.5KB

---

### SFX-NEW-06. `daily_reward.wav` — 일일 보상

**코드 호출:** `AudioService.dailyReward()`
**트리거 위치:** (title_screen.dart에서 일일 보상 다이얼로그 표시 시)

**사운드 설계:**
```
특성: 선물/보상 받는 즐거운 사운드. 화려하고 축하하는 느낌
구성: [코인 쨍쨍] + [상승 팡파레 빠바밤~] + [반짝임]
느낌: "보상이다!" — chest_open + level_up 중간 느낌
참고: 모바일 가챠/일일 보상 사운드
```

**제작 가이드:**
```
sfxr.me 파라미터:
  Type: Power Up에서 시작
  Attack: 0
  Sustain: 0.3
  Decay: 0.4
  Frequency: 600-1000Hz (밝고 화려)
  Frequency Slide: 상승 (+)
  Vibrato: 중간 (풍성한 느낌)

대안: 
  chest_open.wav + evolution.wav 앞부분 합성
  밝은 톤으로 피치 조정
```

**기술 사양:** WAV, 16-bit, mono, 22050Hz, ~0.6s, ~26KB

---

## 4. BGM 상세 사양 — 존재하는 파일 (3종)

### 4-1. 현재 BGM 분석

| 파일명 | 용도 | 스테이지 | 크기 | 길이 |
|--------|------|---------|------|------|
| `bgm/title.wav` | 타이틀 화면 | - | 345KB | ~4s 루프 |
| `bgm/stage_1.wav` | 대나무 숲 + 한옥 마을 (기본) | stage1, (stage2 폴백) | 345KB | ~4s 루프 |
| `bgm/stage_boss.wav` | 보스전 (도깨비 대장, 구미호) | stage1~2 보스 | 345KB | ~4s 루프 |

> 모두 345KB로 동일 → 약 4초 루프 @ 22050Hz/16-bit/mono
> BGM은 `FlameAudio.bgm.play()`로 자동 루프 재생됩니다.

---

## 5. BGM 상세 사양 — 미생성 파일 (6종)

### 5-1. 코드 내 BGM 매핑

```dart
// stages.dart
stage1: bgm='stage_1',     bossBgm='stage_boss'         // 대나무 숲
stage2: bgm='stage_2',     bossBgm='stage_boss'         // 한옥 마을
stage3: bgm='stage_3',     bossBgm='stage_boss_2'       // 지하 궁궐
stage4: bgm='stage_4',     bossBgm='stage_boss_2'       // 귀문관
stage5: bgm='stage_5',     bossBgm='stage_boss_final'   // 황천길
bonus1/2: (기본값) bgm='stage_1', bossBgm='stage_boss'  // 보너스 스테이지
```

```
title_screen.dart:25 → AudioService.playBgm('title')
toemalok_game.dart:228 → AudioService.playBgm(_stageData.bgm)
toemalok_game.dart:630 → AudioService.playBgm(_stageData.bossBgm)  // 보스 등장 시 전환
toemalok_game.dart:603 → AudioService.playBgm(_stageData.bgm)      // 보스 처치 후 복귀
```

---

### BGM-NEW-01. `bgm/stage_2.wav` — 한옥 마을

**매핑:** stage2 (`hanok_village`), duration 1800s(30분)
**전환:** 보스 등장 시 `stage_boss.wav`로 전환

**사운드 설계:**
```
분위기: 한적한 마을이 요괴에 습격당한 긴장감
       stage_1보다 약간 어둡고 긴장감 UP
테마:   한옥 골목, 달빛, 숨어있는 위험
BPM:    120-130 (stage_1보다 약간 빠름)
키:     D minor 또는 A minor

구성:
  베이스: 가야금 또는 거문고 저음 리프 반복
  리듬: 장구 패턴 (쿵딱쿵딱) + 8bit 드럼
  멜로디: 대금 풍 신스 — 단조, 긴장감 있는 멜로디
  분위기: 밤 마을 느낌, 기와 위의 달빛

루프: 4-8초, 자연스러운 루프 포인트
```

**Suno AI 프롬프트:**
```
Korean traditional fusion game music, retro 8-bit chiptune blended with 
gayageum and daegeum flute, D minor, 125 BPM, dark atmospheric night village 
theme, mysterious and slightly tense, loopable 8 seconds, pixel art game 
soundtrack style, no vocals
```

**jsfxr/대안:**
```
8bit 작곡 도구에서:
  채널 1 (멜로디): Square wave, D minor 스케일, 불안한 아르페지오
  채널 2 (베이스): Triangle wave, 루트-5th 반복
  채널 3 (드럼): Noise, 쿵딱 패턴 120BPM
  채널 4 (pad): Saw wave, 낮은 볼륨 화음
```

**기술 사양:** WAV, 16-bit, mono, 22050Hz, ~4-8s 루프, ~350-700KB

---

### BGM-NEW-02. `bgm/stage_3.wav` — 지하 궁궐

**매핑:** stage3 (`underground_palace`), duration 1800s(30분)
**전환:** 보스 등장 시 `stage_boss_2.wav`로 전환

**사운드 설계:**
```
분위기: 어둡고 웅장한 지하 궁궐, 에코 느낌
       stage_2보다 더 무겁고 위압적
테마:   지하 석실, 보물, 고대의 저주
BPM:    100-110 (느리고 무거운)
키:     E minor 또는 B minor

구성:
  베이스: 깊은 저음 드론 + 묵직한 북소리
  리듬: 느린 궁중 북 (둥—둥—) + 금속성 리듬
  멜로디: 피리/해금 풍 신스 — 으스스한 멜로디, 넓은 에코
  분위기: 촛불, 석조 벽, 먼지, 위엄
  효과: 물방울 떨어지는 느낌의 장식음

루프: 6-8초
```

**Suno AI 프롬프트:**
```
Korean royal palace dungeon game music, retro chiptune with deep drums and 
haegeum fiddle synth, E minor, 105 BPM, dark majestic underground atmosphere, 
echoing stone halls, mysterious ancient curse, loopable 8 seconds, 8-bit game 
soundtrack, no vocals
```

**기술 사양:** WAV, 16-bit, mono, 22050Hz, ~6-8s 루프, ~500-700KB

---

### BGM-NEW-03. `bgm/stage_4.wav` — 귀문관

**매핑:** stage4 (`gwimungwan`), duration 1500s(25분)
**전환:** 보스 등장 시 `stage_boss_2.wav`로 전환

**사운드 설계:**
```
분위기: 귀문(鬼門) — 저승과 이승의 경계, 극도의 긴장
       가장 어둡고 불안한 스테이지 음악
테마:   부적으로 봉인된 문, 귀신 울음, 피비린내
BPM:    130-140 (빠르고 위협적)
키:     C# minor 또는 F# minor

구성:
  베이스: 불안한 저음 펄스, 심장박동 같은 리듬
  리듬: 빠른 타격 + 불규칙한 엑센트
  멜로디: 불협화음 포함한 멜로디, 귀신 울음 느낌
  분위기: 공포, 긴장, 봉인이 풀리는 느낌
  효과: 바람 소리, 찢어지는 느낌의 노이즈

루프: 4-6초
```

**Suno AI 프롬프트:**
```
Korean horror game music, intense retro chiptune with dissonant notes, 
fast 135 BPM, C# minor, ghost gate demon portal atmosphere, heartbeat-like 
bass pulse, eerie wind effects, terrifying and urgent, loopable 6 seconds, 
8-bit pixel game soundtrack, no vocals
```

**기술 사양:** WAV, 16-bit, mono, 22050Hz, ~4-6s 루프, ~350-500KB

---

### BGM-NEW-04. `bgm/stage_5.wav` — 황천길

**매핑:** stage5 (`hwangcheon`), duration 1500s(25분)
**전환:** 보스 등장 시 `stage_boss_final.wav`로 전환

**사운드 설계:**
```
분위기: 황천(黃泉) — 저승길, 초월적 공간
       공포보다는 비장하고 숙연한 분위기
테마:   죽음의 강, 혼백, 최후의 여정
BPM:    90-100 (느리고 비장한)
키:     G minor

구성:
  베이스: 깊은 드론, 물 흐르는 듯한 저음 패드
  리듬: 느린 북소리 + 방울 소리 (무속 느낌)
  멜로디: 슬프고 비장한 멜로디, 피리/소금 풍
  분위기: 안개, 강, 떠도는 혼, 비장한 결의
  효과: 물소리, 방울 딸랑, 먼 곳의 독경

루프: 8초
```

**Suno AI 프롬프트:**
```
Korean underworld afterlife game music, solemn retro chiptune with shamanic 
bells and sorrowful piri flute synth, G minor, 95 BPM, misty river of the dead 
atmosphere, bittersweet and heroic, ethereal and otherworldly, loopable 
8 seconds, 8-bit game soundtrack, no vocals
```

**기술 사양:** WAV, 16-bit, mono, 22050Hz, ~8s 루프, ~700KB

---

### BGM-NEW-05. `bgm/stage_boss_2.wav` — 중반 보스전

**매핑:** stage3, stage4 보스전 (장산범, 불가사리)
**전환:** `AudioService.playBgm(_stageData.bossBgm)` — 보스 등장 시 자동 전환

**사운드 설계:**
```
분위기: stage_boss.wav보다 더 위협적이고 강렬한 보스 테마
       중반 보스 (장산범 HP3000, 불가사리 HP5000) 대응
테마:   절체절명, 거대한 괴물과의 대결
BPM:    150-160 (매우 빠름, 긴박감)
키:     D minor 또는 A minor

구성:
  베이스: 무거운 파워 베이스, 연속 8분음표
  리듬: 빠른 더블 킥 느낌 + 팀파니풍 둥둥
  멜로디: 강렬한 금속성 리프 + 비장한 멜로디
  분위기: "이건 진짜다" — stage_boss의 강화 버전
  효과: 타격음 같은 엑센트

루프: 4-6초
```

**Suno AI 프롬프트:**
```
Epic Korean boss battle game music, intense retro chiptune, heavy bass and 
fast drums 155 BPM, D minor, powerful and menacing, life-or-death combat 
atmosphere, metallic aggressive melody, loopable 6 seconds, 8-bit pixel game 
boss fight soundtrack, no vocals
```

**기술 사양:** WAV, 16-bit, mono, 22050Hz, ~4-6s 루프, ~350-500KB

---

### BGM-NEW-06. `bgm/stage_boss_final.wav` — 최종 보스전 (용왕)

**매핑:** stage5 보스전 (용왕 HP8000)
**전환:** 황천길에서 용왕 등장 시

**사운드 설계:**
```
분위기: 게임 전체 클라이막스. 가장 웅장하고 감동적인 곡
       용왕(최종보스)과의 결전
테마:   바다의 왕, 물의 힘, 최후의 결전, 영웅의 각오
BPM:    140-150
키:     E minor (비장) 또는 C minor (웅장)

구성:
  인트로: 물결치는 아르페지오 + 용의 울음
  베이스: 파워풀한 저음 + 물 흐르는 패드
  리듬: 웅장한 오케스트라 타격 + 빠른 8bit 드럼
  멜로디: 영웅적이고 비장한 메인 멜로디 — 가장 인상적인 테마
  분위기: "이 세상의 운명이 걸렸다"
  효과: 물소리, 파도, 용의 포효 느낌

루프: 6-8초 (가능하면 가장 긴 루프)
```

**Suno AI 프롬프트:**
```
Ultimate Korean dragon king final boss battle music, epic retro chiptune 
orchestra fusion, E minor, 145 BPM, majestic and heroic with water and ocean 
motifs, powerful climactic melody, most dramatic and emotionally charged, 
dragon roar undertones, loopable 8 seconds, 8-bit pixel game final boss 
soundtrack, no vocals
```

**기술 사양:** WAV, 16-bit, mono, 22050Hz, ~6-8s 루프, ~500-700KB

---

## 6. 제작 도구 가이드

### 6-1. SFX 도구

#### sfxr.me (무료 웹, 추천도 ★★★★★)
- **접속:** https://sfxr.me
- **용도:** 레트로 게임 SFX 즉석 생성 (가장 빠름)
- **워크플로우:**
  ```
  1. 카테고리 선택 (Hit, Power Up, Blip 등)
  2. Randomize로 시작점 찾기
  3. 파라미터 미세 조정
  4. Export → WAV
  5. Audacity에서 22050Hz mono로 변환 (필요 시)
  ```
- **장점:** 완전 무료, 설치 불필요, 즉시 생성
- **단점:** 복잡한 다층 사운드 불가 (단일 오실레이터)

#### jfxr (무료 웹, 추천도 ★★★★)
- **접속:** https://jfxr.frozenfractal.com
- **용도:** sfxr.me의 확장 버전, 더 많은 파라미터
- **장점:** 더 세밀한 컨트롤, 프리셋 풍부

#### Audacity (무료 데스크탑, 추천도 ★★★★★)
- **다운로드:** https://www.audacityteam.org
- **용도:** WAV 편집, 포맷 변환, 믹싱, 이펙트
- **필수 작업:**
  ```
  1. 파일 → Import로 생성된 WAV 로드
  2. Tracks → Resample → 22050Hz
  3. Tracks → Mix → Stereo to Mono (필요 시)
  4. Export → WAV (Signed 16-bit PCM)
  ```

#### Freesound.org (무료 소스, 추천도 ★★★★)
- **접속:** https://freesound.org
- **용도:** CC0/CC-BY 라이센스 효과음 검색
- **검색 키워드:**
  ```
  crit_hit: "critical hit retro" "impact 8bit"
  elite_spawn: "warning alert retro" "boss spawn"
  milestone: "achievement chime" "level up 8bit"
  wave_start: "battle start" "drum hit retro"
  ui_back: "menu back" "button cancel"
  daily_reward: "reward chime" "treasure open"
  ```
- **주의:** 다운로드 후 반드시 22050Hz/16-bit/mono로 변환

### 6-2. BGM 도구

#### Suno (AI 생성, 추천도 ★★★★★)
- **접속:** https://suno.com
- **무료:** 일 50크레딧 (~10곡)
- **워크플로우:**
  ```
  1. Custom Mode ON
  2. 프롬프트 입력 (본 문서의 프롬프트 사용)
  3. Style: "retro chiptune", "8-bit game music" 포함
  4. 여러 번 생성 → 가장 맞는 것 선택
  5. 다운로드 (MP3/WAV)
  6. Audacity에서 루프 포인트 편집
  7. 22050Hz/16-bit/mono 변환
  ```
- **주의:** Suno 무료 플랜은 상업 이용 불가. 유료 플랜($10/월) 필요
- **대안:** Udio (https://udio.com) — 비슷한 AI 음악 생성

#### BeepBox (무료 웹, 추천도 ★★★★)
- **접속:** https://www.beepbox.co
- **용도:** 브라우저에서 8bit/chiptune 작곡
- **장점:** 완전 무료, 저작권 문제 없음 (직접 작곡)
- **워크플로우:**
  ```
  1. 4채널 설정 (멜로디/하모니/베이스/드럼)
  2. BPM, 키 설정
  3. 패턴 입력 → 루프 구성
  4. File → Export WAV
  5. Audacity에서 포맷 통일
  ```

#### FamiTracker (무료 데스크탑, 추천도 ★★★)
- **용도:** NES/Famicom 스타일 정통 chiptune 작곡
- **장점:** 가장 정통 8bit 사운드
- **단점:** 학습 곡선 높음, Windows만 지원

---

## 7. 제작 우선순위

### Phase 1: 즉시 필요 (게임 에러 제거)

| 순번 | 에셋 | 파일명 | 도구 추천 | 예상 시간 |
|------|------|--------|----------|-----------|
| 1 | 치명타 적중 | `sfx/crit_hit.wav` | sfxr.me | 5분 |
| 2 | 엘리트 스폰 | `sfx/elite_spawn.wav` | sfxr.me | 5분 |
| 3 | 마일스톤 | `sfx/milestone.wav` | sfxr.me | 5분 |
| 4 | 웨이브 시작 | `sfx/wave_start.wav` | sfxr.me | 5분 |
| 5 | UI 뒤로가기 | `sfx/ui_back.wav` | sfxr.me | 3분 |
| 6 | 일일 보상 | `sfx/daily_reward.wav` | sfxr.me | 5분 |

**소계: ~30분 (sfxr.me만으로 전부 가능)**

### Phase 2: 스테이지 확장 BGM

| 순번 | 에셋 | 파일명 | 도구 추천 | 예상 시간 |
|------|------|--------|----------|-----------|
| 7 | 한옥 마을 BGM | `bgm/stage_2.wav` | Suno/BeepBox | 30분 |
| 8 | 지하 궁궐 BGM | `bgm/stage_3.wav` | Suno/BeepBox | 30분 |
| 9 | 귀문관 BGM | `bgm/stage_4.wav` | Suno/BeepBox | 30분 |
| 10 | 황천길 BGM | `bgm/stage_5.wav` | Suno/BeepBox | 30분 |

**소계: ~2시간**

### Phase 3: 보스전 BGM

| 순번 | 에셋 | 파일명 | 도구 추천 | 예상 시간 |
|------|------|--------|----------|-----------|
| 11 | 중반 보스전 | `bgm/stage_boss_2.wav` | Suno/BeepBox | 30분 |
| 12 | 최종 보스전 | `bgm/stage_boss_final.wav` | Suno/BeepBox | 45분 |

**소계: ~1시간 15분**

**총 예상: ~4시간**

---

## 8. 포맷 변환 + 후처리 가이드

### Audacity 변환 워크플로우
```
모든 오디오 파일에 동일하게 적용:

1. 파일 열기: File → Import → Audio
2. 샘플레이트: Tracks → Resample → 22050
3. 모노 변환: Tracks → Mix → Mix Stereo Down to Mono
4. 노멀라이즈: Effect → Normalize → -1.0dB
5. 노이즈 제거: Effect → Noise Reduction (필요 시)
6. 트림: 앞뒤 무음 제거 (선택 → Delete)
7. BGM 루프 확인: 시작점과 끝점이 자연스럽게 이어지는지 확인
8. 내보내기: File → Export → Export as WAV
   - Format: WAV (Microsoft)
   - Encoding: Signed 16-bit PCM
```

### BGM 루프 편집 팁
```
1. 전체 곡에서 자연스러운 루프 구간 찾기 (4-8초)
2. 루프 시작/끝의 파형이 0-crossing에서 만나도록 조정
3. 크로스페이드: 끝 0.05초와 시작 0.05초를 겹쳐서 부드럽게
4. 루프 테스트: Audacity에서 구간 반복 재생으로 확인
5. 팝/클릭 노이즈 없는지 확인
```

### 볼륨 레벨 기준
```
SFX 볼륨 우선순위 (상대적):
  boss_appear, evolution: 100% (가장 크게)
  level_up, daily_reward: 90%
  milestone, wave_start:  80%
  weapon_*, crit_hit:     70%
  enemy_hit, enemy_death: 60%
  exp_collect:            50%
  ui_click, ui_back:      40% (가장 작게)

BGM: 모두 동일 기준 볼륨 (-3dB)
     AudioService에서 동적 볼륨 조절하므로 파일 자체는 균일하게
```

---

## 9. 품질 체크리스트

### 기술 검증
- [ ] WAV (Microsoft PCM) 포맷
- [ ] 16-bit signed
- [ ] Mono 채널
- [ ] 22050Hz 샘플레이트
- [ ] 파일명이 코드 매핑과 정확히 일치 (대소문자 포함)
- [ ] 앞뒤 불필요한 무음 없음

### SFX 검증
- [ ] 길이 적절 (0.05~1.2초)
- [ ] 반복 재생 시 피로하지 않음 (50ms 간격으로 3회 연속 테스트)
- [ ] 다른 SFX와 동시 재생 시 간섭 없음
- [ ] 기존 SFX들과 볼륨 밸런스 맞음
- [ ] 팝/클릭 노이즈 없음

### BGM 검증
- [ ] 루프 포인트에서 끊김/튐 없음 (최소 10회 루프 테스트)
- [ ] 30분 연속 재생에도 피로하지 않음
- [ ] 스테이지 분위기와 부합
- [ ] stage_bgm → boss_bgm 전환 시 어색하지 않음
- [ ] 동적 볼륨 (0.7~1.0 범위)에서 자연스러운지

### 게임 내 검증
- [ ] `flutter run`으로 실제 재생 확인
- [ ] 웹/안드로이드 모두에서 재생됨
- [ ] SFX 쓰로틀링 (프레임당 3개) 시 중요 사운드가 씹히지 않는지
- [ ] BGM intensity 전환 (평화→전투→보스) 자연스러운지
- [ ] 볼륨 슬라이더 0~1 범위에서 정상 작동

---

## 10. 총 오디오 현황 대시보드

### SFX (30종)

| 카테고리 | 수량 | 존재 | 미생성 |
|----------|------|------|--------|
| 무기 SFX | 15종 | ✅ 15 | 0 |
| 게임 이벤트 | 9종 | ✅ 9 | 0 |
| 추가 이벤트 | 6종 | 0 | ❌ 6 |
| **소계** | **30종** | **24** | **6** |

### BGM (9종)

| 용도 | 파일명 | 존재 |
|------|--------|------|
| 타이틀 | title.wav | ✅ |
| 대나무 숲 | stage_1.wav | ✅ |
| 한옥 마을 | stage_2.wav | ❌ |
| 지하 궁궐 | stage_3.wav | ❌ |
| 귀문관 | stage_4.wav | ❌ |
| 황천길 | stage_5.wav | ❌ |
| 초반 보스전 | stage_boss.wav | ✅ |
| 중반 보스전 | stage_boss_2.wav | ❌ |
| 최종 보스전 | stage_boss_final.wav | ❌ |

### 요약
```
SFX:  24/30 존재 (80%) — 미생성 6종은 sfxr.me로 30분 내 제작 가능
BGM:   3/9  존재 (33%) — 미생성 6종은 Suno/BeepBox로 3시간 내 제작 가능
총 예상 제작 시간: ~4시간
```

# 퇴마록: 백귀야행 — 에셋 제작 전략 v3.0 (현행화)

> 최종 업데이트: 2026-04-06
> 코드 기준: 현재 `lib/` 소스 전수 조사 완료
> 총 에셋: 59종 이미지 + 8종 초상화 + UI 세트 + 오디오 31종
> 현재 상태: placeholder 이미지 46종 존재, 진화투사체 12종 + 초상화 8종 + 오디오 일부 미생성
> **v3.1 추가**: GPT 이미지 생성 파이프라인 (섹션 1-5) + `tools/sprite_cleanup.py` 후처리 스크립트

---

## 1. 아트 디렉션 바이블

### 1-1. 핵심 스타일 정의
- **장르**: 16-bit 탑뷰 픽셀아트 (뱀파이어 서바이버즈 스타일)
- **테마**: 조선시대 퇴마사 + 한국 신화 요괴
- **시점**: 3/4 탑다운 (약간 위에서 내려다보는 각도)
- **룩**: 선명한 아웃라인(1px 검정) + 밝은 내부 + 제한된 팔레트
- **조명**: 좌상단 광원 통일 (하이라이트 좌상, 그림자 우하)
- **참고작**: Vampire Survivors, Halls of Torment, 크로노 트리거(캐릭터 비율)

### 1-2. 캐릭터 비율 규칙
```
32x32 캐릭터 기준:
- 머리: 10~12px (2.5~3등신, 귀여운 SD 비율)
- 몸통: 8~10px
- 다리: 6~8px
- 전체 높이: 24~28px (상하 여백 2~4px)
- 전체 폭: 14~18px (좌우 여백 7~9px)
```

### 1-3. 마스터 컬러 팔레트 (32색 제한)

**오행 원소 (각 4색: 밝음/기본/어둠/깊은)**
```
목(木) 초록:  #A8E6A3  #4A8C3F  #2D5A27  #1A3A18
화(火) 빨강:  #FF9B7A  #D4483B  #8B1A1A  #5C0E0E
토(土) 황금:  #F5E6C8  #C9A84C  #8B6914  #5C4A12
금(金) 은백:  #E8E8F0  #8888A0  #4A4A5A  #2D2D3A
수(水) 파랑:  #88CCEE  #3366AA  #1A3A5C  #0D1F33
```

**공통색 (12색)**
```
피부:      #EBC8A0  #C8A582  #A08060
머리/갓:   #1E140F  #4B3728  #755540
하이라이트: #FFFFFF  #FFD166
아웃라인:   #1A1A2E  #2D2D44
배경참조:   #0D1B2A  #1D3557
```

### 1-4. 애니메이션 규칙
- **보행 사이클**: 4프레임 (접지→전진→접지→후진)
- **아이들**: 4프레임 (미세 상하 흔들림 1px, 호흡 느낌)
- **방향**: 오른쪽 보기가 기본. 왼쪽은 코드에서 `flipX` 처리
- **프레임간 변화**: 최대 2~3px 이동 (부드러운 느낌)

**프레임 타이머 (코드 기준):**
| 대상 | 간격 | FPS |
|------|------|-----|
| 플레이어 | 0.15초 | ~6.67fps |
| 적 | 0.20초 | 5fps |
| 투사체 | 0.10초 | 10fps |
| 경험치 기운 | 0.25초 | 4fps |

---

## 1-5. GPT 이미지 생성 파이프라인

> **2026-04-06 추가**: GPT(ChatGPT 이미지 생성)로 스프라이트를 만들 때의 통합 워크플로우.

### 파이프라인 흐름

```
┌──────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  1. GPT 이미지    │ ──→ │  2. sprite_       │ ──→ │  3. assets/      │
│  생성 (raw/)      │     │  cleanup.py       │     │  images/         │
│                  │     │  후처리            │     │  최종 PNG        │
└──────────────────┘     └──────────────────┘     └─────────────────┘
```

### 작업 폴더

```
tools/
  sprite_cleanup.py      ← 후처리 스크립트 (pip install Pillow 필요)
  raw/                   ← GPT 생성 원본 (.gitignore 추가)
    players/
    enemies/
    bosses/
    projectiles/
assets/images/           ← 최종 게임 에셋
```

### GPT 프롬프트 — 통합 베이스 (모든 에셋에 삽입)

```
GAME SPRITE STRIP — PRODUCTION READY

Pixel Style (CRITICAL):
- true 16-bit SNES pixel art
- NO anti-aliasing, NO smoothing, NO gradients
- hard pixel edges only, visible square pixels
- clean color clusters (no noise pixels)
- 2~3 step shading only

LAYOUT RULE (ABSOLUTELY CRITICAL):
All frames MUST be in ONE single horizontal row.
There is NO second row. There are NO labels. There are NO grid lines.
This is NOT a reference sheet. This is a GAME ATLAS STRIP.

FORBIDDEN:
- text labels, grid lines, borders, decorative elements
- multiple rows or reference sheet layout
- semi-realistic rendering, soft shading, color banding
- anti-aliased edges

REFERENCE STYLE:
- classic SNES / GBA RPG sprite sheets
- same clarity and pixel discipline as commercial game assets
```

### GPT 프롬프트 — 타입별 포맷 블록

**플레이어 (player):**
```
Format:
- 256x32 PNG, transparent or solid black background
- 8 frames in a single horizontal row, each exactly 32x32
- NO gaps, NO padding between frames
- Frames 0-3: idle animation (subtle breathing/sway, front-facing)
- Frames 4-7: walk cycle (clear leg movement, front-facing)
- chibi SD proportions (head ≈60%), max 12 colors
- front-facing ONLY (game handles left/right via code flipX)
```

**일반적 (enemy):**
```
Format:
- 128x32 PNG, transparent or solid black background
- 4 frames in a single horizontal row, each exactly 32x32
- Walk/float animation cycle, front-facing only
- chibi SD proportions, max 10 colors, menacing but readable at 32x32
```

**보스 (boss):**
```
Format:
- 256x64 PNG, transparent or solid black background
- 4 frames in a single horizontal row, each exactly 64x64
- Frames 0-1: idle/breathing, Frames 2-3: attack pose with effect
- max 16 colors, boss-level visual impact, front-facing only
```

**투사체 (projectile):**
```
Format:
- 64x16 PNG, transparent or solid black background
- 4 frames in a single horizontal row, each exactly 16x16
- Spin or fly animation, max 6 colors
- bright, high contrast, clear silhouette even at 16x16
```

### sprite_cleanup.py 사용법

```bash
# 설치 (최초 1회)
pip install Pillow

# 개별 처리 (참조 시트 → 게임 스트립)
python tools/sprite_cleanup.py tools/raw/players/wolhui_raw.png \
  -o assets/images/player_wolhui.png --type player --debug

# 이미 스트립인 경우 (정리만)
python tools/sprite_cleanup.py tools/raw/players/wolhui_strip.png \
  -o assets/images/player_wolhui.png --type player

# 참조 시트 강제 모드
python tools/sprite_cleanup.py tools/raw/wolhui_sheet.png \
  -o assets/images/player_wolhui.png --type player --reference --debug

# 일괄 처리
python tools/sprite_cleanup.py tools/raw/enemies/ \
  --type enemy --batch -o assets/images/ --debug

# 색상 축소 (노이즈 심할 때)
python tools/sprite_cleanup.py input.png -o output.png --type enemy --reduce-colors
```

### GPT 프롬프트 팁

| 잘 되는 것 | 안 되는 것 |
|---|---|
| "single horizontal row" 강조 | "reference sheet" 요구 |
| 프레임 수+크기 숫자로 명시 | "developer layout" |
| "NO labels, NO borders" 반복 | 캐릭터 설명 없이 생성 |
| "SNES pixel art" 레퍼런스 | 4방향 요구 (정면만 필요) |
| 배경색 "transparent or black" | 복잡한 구도/포즈 |

**GPT가 시트를 줄 때 대처:**
1. `--reference` 플래그로 후처리 → 자동 프레임 추출
2. 프롬프트에 `LAYOUT RULE` 블록 재강조
3. 여러 번 재생성 → 가장 스트립에 가까운 것 선택

### 생산 우선순위

```
Phase 1 (MVP): player_lee_taeyang, player_wolhui
Phase 2 (적):  enemy_jabgwi, enemy_dokkaebi_jol, enemy_cheonyeo_gwisin
Phase 3 (무기): proj_bujeok, proj_bangul
Phase 4 (보스): boss_dokkaebi
Phase 5 (나머지): 전체 확장
```

---

## 2. 전체 에셋 목록 + 정밀 사양

### 2-1. 플레이어 캐릭터 (8종)

**공통 사양:**
- 시트 크기: 256x32 (32x32 x 8프레임, 행 1개)
- 레이아웃: `[idle0][idle1][idle2][idle3][walk0][walk1][walk2][walk3]`
- 코드: `player.dart` — `spriteFrame = _isWalking ? (_frameIndex + 4) : _frameIndex`
- 렌더 크기: 64x64px (2배 스케일, `destW: 64, destH: 64`)
- flipX: `facingDirection.x < 0`일 때 활성
- 스킨 틴트: `ColorFilter.mode srcATop` 35% alpha 오버레이
- 피격 플래시: `drawFrameFlash()` 흰색 오버레이
- 폴백: `SpritePainter.drawPlayer()` (스프라이트 미로드 시)

---

#### PC-01. 이태양 (퇴마사) — `player_lee_taeyang.png`

**캐릭터 설정:**
- 직업: 퇴마사 (주인공, 기본 해금)
- 시작무기: 퇴마부적 (`toema_bujeok`, 화속성, fan 패턴)
- 스탯: HP 100, 공격 110%, 이속 100%, 쿨 100%, 범위 100%

**비주얼 상세:**
```
머리: 검은 갓(gat) — 조선 선비 모자, 넓은 챙, 높은 모자부
      갓 아래 검은 상투머리 살짝 보임
얼굴: 단정한 남성, 눈 2px(흰+검정), 결의에 찬 표정
상의: 흰색 도포(dopo) — 넉넉한 소매, V자 깃
      남색(#1D3557) 허리띠로 묶음, 가슴에 붉은 부적 문양 1개
하의: 흰색 바지, 밑단 남색 테두리, 검은 신발
소품: 오른손에 빛나는 황금 부적 1장 (idle에서 반짝임)
색상: 주조 — 흰(#F0EEE6), 남색(#1D3557), 갓 갈색(#322519)
      포인트 — 부적 금색(#FFD166), 붉은 문양(#E63946)
```

**프레임별 상세:**
```
idle0: 기본 자세. 부적 든 오른손 가슴 높이
idle1: 미세하게 1px 위로 (호흡 올림)
idle2: 기본 자세로 복귀
idle3: 미세하게 1px 아래 (호흡 내림)
walk0: 오른발 앞, 왼발 뒤. 팔 자연스럽게 반대
walk1: 양발 모임 (패싱 포지션). 몸 1px 위
walk2: 왼발 앞, 오른발 뒤
walk3: 양발 모임. 몸 1px 위
```

**GPT 프롬프트:** (섹션 1-5의 통합 베이스 + 플레이어 포맷 블록 + 아래 Character 블록)
```
Character:
- Korean Joseon dynasty exorcist (퇴마사), male, determined expression
- Black gat (traditional hat with wide brim and tall crown) over black topknot
- White dopo (overcoat) with wide sleeves, V-neck collar
- Navy blue (#1D3557) belt tied at waist, small red talisman symbol on chest
- White pants with navy trim at hem, black shoes
- Right hand holding glowing golden talisman paper
- Colors: white (#F0EEE6), navy (#1D3557), gat brown (#322519), gold (#FFD166), red (#E63946)
```

**후처리:** `python tools/sprite_cleanup.py raw.png -o assets/images/player_lee_taeyang.png --type player --debug`

---

#### PC-02. 월희 (무녀) — `player_wolhui.png`

**캐릭터 설정:**
- 직업: 무녀 (기본 해금)
- 시작무기: 신성 방울 (`sinseong_bangul`, 수속성, radial 패턴)
- 스탯: HP 90, 공격 100%, 이속 100%, 쿨 100%, 범위 100%

**비주얼 상세:**
```
머리: 긴 흑발 — 등까지 내려오는 긴 생머리, 약간 물결
      이마에 흰색 천(무녀 머리띠) 묶음, 머리띠에 작은 방울 장식 1개
얼굴: 우아한 여성, 반달 눈, 붉은 입술 1px
상의: 붉은색(#D4483B) 치마저고리 — 저고리 위에 흰 고름, 소매 넓고 우아
하의: 흰색 치마, 길게 내려옴, 밑단 붉은 테두리, 붉은 허리띠
소품: 양손에 금색 방울 2개, 목에 파란 구슬 목걸이
색상: 주조 — 빨강(#D4483B), 흰색, 검은 머리카락
      포인트 — 금방울(#FFD166), 파란 구슬(#3366AA)
```

**GPT 프롬프트:** (통합 베이스 + 플레이어 포맷 + 아래)
```
Character:
- Korean shrine maiden (무녀), female, elegant and mystical expression
- Long flowing straight black hair down to back, white headband with small bell ornament
- Red (#D4483B) jeogori (jacket) with white goreum (ribbon tie), wide elegant sleeves
- White chima (skirt) flowing long, red trim at hem, red waist sash
- Golden bells in both hands, blue bead necklace
- Colors: red (#D4483B), white, black hair, gold bells (#FFD166), blue beads (#3366AA)
```

**후처리:** `python tools/sprite_cleanup.py raw.png -o assets/images/player_wolhui.png --type player --debug`

---

#### PC-03. 철웅 (장군) — `player_cheolwoong.png`

**캐릭터 설정:**
- 직업: 장군 (스테이지 1 클리어 해금)
- 시작무기: 청룡도 (`cheongryongdo`, 목속성, spin 패턴)
- 스탯: HP 130, 공격 100%, 이속 90% (느림), 쿨 100%, 범위 100%

**비주얼 상세:**
```
머리: 조선 장군 투구(벼슬갓 + 정자관 느낌), 투구에 붉은 깃 1개
얼굴: 넓은 턱, 굵은 눈썹, 근엄한 남성, 작은 수염
상의: 은백색(#C0C0D0) 두정갑(갑옷), 가슴에 호심경 금색 1개, 어깨보호대 양쪽
하의: 진한 남색 하의, 금속 다리보호대, 무거운 검은 군화
소품: 오른손에 청룡도(큰 언월도) — 칼날 은색, 자루 녹색 (캐릭터 키의 80%)
색상: 주조 — 은백(#C0C0D0), 남색(#1D3557)
      포인트 — 투구 빨강(#D4483B), 청룡도 녹색(#4A8C3F)
```

**GPT 프롬프트:** (통합 베이스 + 플레이어 포맷 + 아래)
```
Character:
- Korean Joseon general warrior, male, fierce stern expression, broad-shouldered
- Military helmet with red plume, topknot visible beneath
- Silver-white armor (#C0C0D0) with gold chest mirror, shoulder guards on both sides
- Dark navy pants, metal leg guards, heavy black military boots
- Right hand wielding large blue crescent blade (청룡도), green handle (80% of body height)
- Colors: silver (#C0C0D0), navy (#1D3557), red plume (#D4483B), green handle (#4A8C3F)
```

**후처리:** `python tools/sprite_cleanup.py raw.png -o assets/images/player_cheolwoong.png --type player --debug`

---

#### PC-04. 소연 (궁녀 암살자) — `player_soyeon.png`

**캐릭터 설정:**
- 직업: 궁녀 암살자 (적 1000마리 처치 해금)
- 시작무기: 비녀검 (`binyeo_geom`, 금속성, homing 패턴)
- 스탯: HP 80 (낮음), 공격 100%, 이속 110% (빠름), 쿨 100%, 범위 100%

**비주얼 상세:**
```
머리: 궁녀 족두리 스타일의 검은 올림머리, 은색 비녀검이 꽂혀있음
얼굴: 날카로운 눈매, 차가운 표정, 여성
상의: 검정(#282832) 궁녀복 변형 — 활동적으로 짧은 소매, 보라색(#6B3A78) 가슴끈
      팔에 검은 팔토시 (닌자풍)
하의: 검은 바지, 무릎 아래까지, 검은 천으로 감싼 발
소품: 왼손에 단도 1개 (은색), 허리에 소형 주머니
색상: 주조 — 검정(#282832), 짙은 보라(#6B3A78)
      포인트 — 은색 비녀/칼(#E8E8F0), 피부색 대비
```

**GPT 프롬프트:** (통합 베이스 + 플레이어 포맷 + 아래)
```
Character:
- Korean palace assassin woman (궁녀 암살자), female, sharp cold eyes, slim agile build
- Black updo hair with silver binyeo (hairpin dagger) sticking out
- Dark black (#282832) court lady robes modified for combat, short sleeves
- Dark purple (#6B3A78) chest ribbon, black arm wraps (ninja-style)
- Black pants, knee-length, feet wrapped in dark cloth
- Left hand holding silver short blade, small pouch at waist
- Colors: black (#282832), dark purple (#6B3A78), silver (#E8E8F0)
```

**후처리:** `python tools/sprite_cleanup.py raw.png -o assets/images/player_soyeon.png --type player --debug`

---

#### PC-05. 법운 (승려) — `player_beopwoon.png`

**캐릭터 설정:**
- 직업: 승려 (스테이지 2 클리어 해금)
- 시작무기: 금강저 (`geumgangeo`, 토속성, straight 패턴)
- 스탯: HP 110, 공격 90%, 이속 100%, 쿨 100%, 범위 100%

**비주얼 상세:**
```
머리: 삭발(민머리), 이마에 금색 사리 표시(1px)
얼굴: 둥근 얼굴, 자비로운 눈, 온화한 표정
상의: 회색(#A0A098) 승복 — 한쪽 어깨가 드러난 가사 스타일
      어깨에서 대각선으로 내려오는 주황(#C9A84C) 가사끈
      왼손에 108염주
하의: 회색 바지, 짚신
소품: 오른손에 금강저(vajra) — 양쪽 끝이 갈라진 금색 법기
색상: 주조 — 회색(#A0A098), 주황 가사(#C9A84C)
      포인트 — 금강저 금색(#FFD166), 이마 사리(#FFD166)
```

**GPT 프롬프트:** (통합 베이스 + 플레이어 포맷 + 아래)
```
Character:
- Korean Buddhist monk warrior (승려), male, bald head, serene compassionate eyes
- Golden dot (사리) on forehead (1px)
- Grey (#A0A098) monk robes, one shoulder exposed (kasa style)
- Orange-gold (#C9A84C) diagonal sash across shoulder
- 108-bead prayer bracelet on left wrist
- Grey pants, straw sandals
- Right hand holding golden vajra (금강저) with split ends
- Colors: grey (#A0A098), orange-gold (#C9A84C), vajra gold (#FFD166)
```

**후처리:** `python tools/sprite_cleanup.py raw.png -o assets/images/player_beopwoon.png --type player --debug`

---

#### PC-06. 단비 (풍물패) — `player_danbi.png`

**캐릭터 설정:**
- 직업: 풍물패 (상자 50개 획득 해금)
- 시작무기: 풍물북 (`pungmul_buk`, 화속성, random 패턴)
- 스탯: HP 90, 공격 100%, 이속 100%, 쿨 95%, 범위 125%

**비주얼 상세:**
```
머리: 상모(sangmo) — 흰색 긴 리본이 달린 회전 모자 (idle에서 살짝 흔들림)
얼굴: 밝고 활기찬 젊은 여성, 웃는 눈
상의: 색동(saekdong) 한복 — 빨/파/노 줄무늬 저고리, 하얀 동정
하의: 흰 치마 (짧은 길이, 활동적), 흰 버선+짚신
소품: 등에 메고 있는 큰 북(buk), 양손에 북채 2개
색상: 주조 — 빨(#D4483B)/파(#3366AA)/노(#FFD166) 색동
      포인트 — 북 빨강, 상모 흰색
```

**GPT 프롬프트:** (통합 베이스 + 플레이어 포맷 + 아래)
```
Character:
- Korean traditional drummer girl (풍물패), female, cheerful bright smile
- Sangmo hat with long spinning white ribbon on top
- Colorful saekdong hanbok: red/blue/yellow striped jacket, white collar (동정)
- White short skirt (활동적), white socks (버선) and straw sandals
- Large red drum strapped on back, two drumsticks in hands
- Colors: red (#D4483B), blue (#3366AA), yellow (#FFD166), white, drum red
```

**후처리:** `python tools/sprite_cleanup.py raw.png -o assets/images/player_danbi.png --type player --debug`

---

#### PC-07. 귀손 (반요) — `player_gwison.png`

**캐릭터 설정:**
- 직업: 반요(반인반요) (도깨비 대장 처치 해금)
- 시작무기: 요기 발톱 (`yogi_baltop`, 목속성, melee 패턴)
- 스탯: HP 95, 공격 105%, 이속 100%, 쿨 100%, 범위 100%

**비주얼 상세:**
```
머리: 산발한 검은 머리, 오른쪽 이마에 작은 뿔 1개(붉은 갈색)
얼굴: 한쪽 눈 붉은색(#E63946), 다른 쪽 정상, 송곳니 1px
      얼굴 한쪽에 어두운 문양/흉터
상의: 찢어진 남색 한복 — 한쪽 어깨 드러남, 보라빛(#6B3A78) 기운
      가슴에 봉인 부적 1장 (황금색)
하의: 찢어진 바지, 맨발, 발에 어두운 기운
소품: 양손에서 보라빛 발톱(에너지 클로) 3개 이펙트
색상: 주조 — 남색 찢어짐, 보라 기운(#6B3A78)
      포인트 — 붉은 눈(#E63946), 봉인 부적 금(#FFD166)
```

**GPT 프롬프트:** (통합 베이스 + 플레이어 포맷 + 아래)
```
Character:
- Korean half-demon youth (반요), male, fierce smirk with one fang
- Wild messy black hair, small reddish-brown horn on right forehead
- One glowing red eye (#E63946), one normal black eye
- Dark scar/marking on one side of face
- Torn navy hanbok, one shoulder exposed, purple (#6B3A78) dark energy wisps
- Golden seal talisman stuck on chest
- Torn pants, barefoot with dark energy around feet
- Both hands showing purple energy claws (3 claw marks)
- Colors: navy torn, purple aura (#6B3A78), red eye (#E63946), gold seal (#FFD166)
```

**후처리:** `python tools/sprite_cleanup.py raw.png -o assets/images/player_gwison.png --type player --debug`

---

#### PC-08. 천무 (도사) — `player_cheonmoo.png`

**캐릭터 설정:**
- 직업: 도사 (무기 5종 진화 해금)
- 시작무기: 팔괘진 (`palgwaejin`, 토속성, radial8 패턴)
- 스탯: HP 85, 공격 100%, 이속 100%, 쿨 90%, 범위 100%

**비주얼 상세:**
```
머리: 도사 상투 — 높이 올린 상투, 비녀로 고정, 태극 문양 천(파/빨) 감김
얼굴: 수염 있는 중년 남성, 현명한 눈
상의: 청색(#3366AA) 도복 — 넓은 소매, 가슴에 태극 문양(4x4px), 흰 안감
하의: 청색 바지, 흰 각반, 검은 신발
소품: 오른손에 팔괘 나침반/부채, 허리에 두루마리
색상: 주조 — 청색(#3366AA), 흰색
      포인트 — 태극 빨/파, 나침반 금(#FFD166)
```

**GPT 프롬프트:** (통합 베이스 + 플레이어 포맷 + 아래)
```
Character:
- Korean Taoist sage (도사), middle-aged male, wise calm expression, small beard
- High topknot secured with binyeo, wrapped in blue and red taeguk cloth
- Blue (#3366AA) Taoist robes with wide sleeves, white inner lining
- Large taeguk (yin-yang, 4x4px) symbol on chest in red and blue
- Blue pants, white leg wraps, black shoes
- Right hand holding golden bagua compass/fan, scroll at waist
- Colors: blue (#3366AA), white, taeguk red+blue, gold compass (#FFD166)
```

**후처리:** `python tools/sprite_cleanup.py raw.png -o assets/images/player_cheonmoo.png --type player --debug`

---

### 2-2. 일반 적 (10종)

**공통 사양:**
- 시트 크기: 128x32 (32x32 x 4프레임)
- 프레임: 4프레임 보행 사이클 `[walk0][walk1][walk2][walk3]`
- 코드: `enemy_manager.dart` — `SpriteLoader.enemyImageName(enemy.type.name)`
- 렌더 크기: `enemy.size * 1.8` (enemies.dart의 size 필드)
- 방향: 이동방향 기반 flipX
- 피격 플래시: `drawFrameFlash()`
- 컬링: 카메라 중심 ±480/±320 밖 적은 렌더링 생략
- 상태 이펙트 시각화: 독(녹색 점), 슬로우(파란 링), 엘리트 글로우, HP바
- 폴백: `SpritePainter` 캔버스 드로잉

> **중요**: 모든 적은 32x32 프레임으로 처리됩니다.
> 크기 차이는 렌더 시 `destSize = enemy.size * 1.8`로 스케일링.
> 적의 시각적 크기감은 32x32 안에서 실루엣 크기로 표현합니다.

> **GPT 프롬프트 사용법**: 섹션 1-5의 **통합 베이스** + **enemy 포맷 블록**을 먼저 붙이고,
> 아래 각 적의 `AI 프롬프트` 내용을 `Monster:` 블록으로 넣으세요.
> 후처리: `python tools/sprite_cleanup.py raw.png -o assets/images/enemy_{id}.png --type enemy --debug`

---

#### EN-01. 잡귀 (雜鬼) — `enemy_jabgwi.png` | 128x32

**설정:** 원소 없음 | HP 5 | DMG 2 | 속도 60 | 크기 32 | EXP 1

**비주얼:**
```
형태: 작고 희미한 유령 — 하체가 연기처럼 흐릿
크기: 20x24px 실루엣 (32x32 안에서 작게)
머리: 둥근 머리, 간단한 눈 2개 (흰 점 2px), 입 없거나 작은 검은 점
몸: 위는 둥글고 아래로 갈수록 연기처럼 사라짐
    투명도 그라데이션 (위 80% → 아래 40%)
색상: 회색(#C8C8DC, #9898AC), 눈 흰색
```

**프레임:**
```
walk0: 기본, 약간 왼쪽 기울기
walk1: 위로 1px 떠오름, 연기 꼬리 흔들림
walk2: 기본, 약간 오른쪽 기울기
walk3: 아래로 1px, 연기 꼬리 반대로
```

**AI 프롬프트:**
```
A 32x32 pixel art sprite sheet of a small Korean ghost (jabgwi) for a top-down 
2D game. A tiny, translucent grey spirit with a round head, two white dot eyes, 
and a wispy smoke-like lower body that fades to transparent. Simple, weak-looking. 
4 frames in a horizontal row showing floating/bobbing animation. 16-bit style, 
black outline, transparent background.
```

---

#### EN-02. 도깨비졸 (兵卒) — `enemy_dokkaebi_jol.png` | 128x32

**설정:** 목(木) | HP 12 | DMG 3 | 속도 80 | 크기 36 | EXP 2

**비주얼:**
```
형태: 작은 녹색 도깨비 — 한국 도깨비 (뿔 1개, 인간형)
크기: 22x26px 실루엣
머리: 둥근 얼굴, 짧은 뿔 1개(갈색), 큰 눈 2개(노란 동공), 넓은 입+이빨 2개
몸: 녹색(#4A8C3F) 근육질 작은 몸, 호피무늬 허리감개
소품: 오른손에 작은 방망이 (갈색 나무)
색상: 피부 녹색, 호피 노랑/갈색, 뿔 갈색
```

**AI 프롬프트:**
```
A 32x32 pixel art sprite sheet of a small Korean dokkaebi (goblin soldier) 
for a top-down 2D game. Green-skinned small humanoid with one horn on top, 
big yellow eyes, wide grin with fangs, wearing tiger-print loincloth, 
carrying a small wooden club. Mischievous and aggressive look. 4 frames 
walking animation, horizontal row. 16-bit style, black outline, transparent 
background.
```

---

#### EN-03. 처녀귀신 — `enemy_cheonyeo_gwisin.png` | 128x32

**설정:** 수(水) | HP 18 | DMG 5 | 속도 40 (느림) | 크기 34 | EXP 3

**비주얼:**
```
형태: 흰 소복 입은 여자 귀신 — 한국 전통 원혼
크기: 18x28px 실루엣 (가늘고 길게)
머리: 매우 긴 검은 생머리가 얼굴을 완전히 가림, 사이로 빨간 눈 1개(1px)
몸: 흰 소복(#E8E8F0), 옷 끝이 물결치듯 퍼짐, 하체가 약간 투명
효과: 주변에 푸른 기운 1-2px
색상: 흰색 옷, 검은 머리카락, 빨간 눈
```

**AI 프롬프트:**
```
A 32x32 pixel art sprite sheet of a Korean virgin ghost (cheonyeo gwisin) 
for a top-down 2D game. A haunting figure in white funeral clothes (sobok) 
with extremely long black hair completely covering her face. One glowing 
red eye barely visible through the hair. The lower body fades into mist. 
4 frames floating animation, horizontal row. 16-bit style, black outline, 
transparent background.
```

---

#### EN-04. 해태 석상 — `enemy_haetae.png` | 128x32

**설정:** 토(土) | HP 35 | DMG 4 | 속도 30 (매우 느림) | 크기 44 | EXP 5

**비주얼:**
```
형태: 돌로 된 해태(사자+기린 혼합 수호수)
크기: 26x26px (정사각에 가까운 덩어리)
머리: 돌 사자 얼굴, 갈기, 넓은 코, 둥근 눈, 이마에 돌 뿔 1개
몸: 네모난 돌 몸통, 짧고 굵은 다리 4개, 곳곳에 초록 이끼
    금이 간 돌 텍스처(밝은 갈색/어두운 갈색)
색상: 돌 회갈색(#B08C64, #8B6914), 이끼 녹색(#4A8C3F)
```

**AI 프롬프트:**
```
A 32x32 pixel art sprite sheet of a Korean haetae stone statue monster for 
a top-down 2D game. A bulky lion-like mythical stone guardian with a small 
horn, mossy patches on its rocky body, cracked stone texture. Short thick 
legs, heavy and slow-looking. 4 frames walking with slight body rocking. 
16-bit style, brown-grey stone colors, black outline, transparent background.
```

---

#### EN-05. 불여우 — `enemy_bulyeou.png` | 128x32

**설정:** 화(火) | HP 20 | DMG 6 | 속도 100 (빠름) | 크기 34 | EXP 3

**비주얼:**
```
형태: 불타는 붉은 여우 — 꼬리 3개
크기: 24x20px (가로로 긴 네발동물)
머리: 뾰족한 여우 얼굴, 날카로운 노란 눈, 뾰족한 귀 2개
몸: 붉은(#D4483B) 여우 몸통, 배 부분 밝은 주황(#FF9B7A)
꼬리: 3개 — 끝이 불꽃처럼 주황→노랑
다리: 가는 4다리, 빠른 달리기 자세
색상: 빨강, 주황, 노란 불꽃, 검은 코/눈동자
```

**AI 프롬프트:**
```
A 32x32 pixel art sprite sheet of a Korean fire fox (bulyeou) with 3 tails 
for a top-down 2D game. A sleek red fox with sharp yellow eyes, three 
flame-tipped tails. Orange belly, fire particles around tails. Fast and agile. 
4 frames running animation, horizontal row. 16-bit style, red-orange-yellow 
fire palette, black outline, transparent background.
```

---

#### EN-06. 갑옷 귀신 — `enemy_gapot_gwisin.png` | 128x32

**설정:** 금(金) | HP 50 | DMG 7 | 속도 25 (매우 느림) | 크기 48 | EXP 8

**비주얼:**
```
형태: 녹슨 조선 갑옷에 깃든 귀신 — 갑옷만 움직임
크기: 26x28px (큰 편)
머리: 조선 투구(주발 형태), 녹슨 금속 색, 투구 안에 푸른 불빛 눈 2개
몸: 녹슨(#8B6914+#4A4A5A) 금속 갑옷, 가슴판 크고 네모남
    갑옷 틈새에서 푸른 유령불 새어나옴
소품: 한손에 녹슨 칼
색상: 녹슨 금속(갈색+회색), 푸른 유령불(#5599DD)
```

**AI 프롬프트:**
```
A 32x32 pixel art sprite sheet of a Korean haunted armor ghost for a top-down 
2D game. A rusty Joseon dynasty suit of armor moving on its own, with glowing 
blue ghost fire eyes inside the empty helmet. Rusted brown-grey metal, ghostly 
blue energy seeping through armor gaps. Carries a rusted sword. 4 frames slow 
walking, horizontal row. 16-bit style, black outline, transparent background.
```

---

#### EN-07. 야차 (夜叉) — `enemy_yacha.png` | 128x32

**설정:** 화(火) | HP 30 | DMG 10 (고데미지) | 속도 90 | 크기 40 | EXP 5

**비주얼:**
```
형태: 붉은 피부의 거대 도깨비/악귀
크기: 24x28px (크고 위협적)
머리: 붉은(#D4483B) 얼굴, 큰 뿔 2개, 노란 눈, 큰 입+송곳니 4개
      불꽃 같은 검은 머리카락
몸: 근육질 붉은 상체, 검은 문양, 호피 허리감개
다리: 굵은 다리, 맨발
소품: 양손에 불꽃 주먹
색상: 붉은 피부, 검은 뿔/문양, 노란 눈, 호피
```

**AI 프롬프트:**
```
A 32x32 pixel art sprite sheet of a Korean yaksha (yacha) demon for a top-down 
2D game. A muscular red-skinned ogre demon with two large horns, fierce yellow 
eyes, prominent fangs, and wild black hair. Tiger-print loincloth, black tattoo 
markings. Aggressive, powerful stance with flaming fists. 4 frames walking, 
horizontal row. 16-bit style, black outline, transparent background.
```

---

#### EN-08. 구렁이 (大蛇) — `enemy_gureongi.png` | 128x32

**설정:** 수(水) | HP 28 | DMG 4 | 속도 50 | 크기 38 | EXP 4

**비주얼:**
```
형태: 큰 푸른 뱀 — 이무기에 가까운 큰 뱀
크기: 28x20px (가로로 매우 긴)
머리: 삼각형 뱀 머리, 노란 눈(세로 동공), 갈라진 혀(빨간 1px), 용 수염
몸: S자 곡선, 푸른(#3366AA) 비늘, 배 부분 밝은 청색(#88CCEE)
꼬리: 끝이 뾰족하게 가늘어짐
색상: 청색 비늘, 밝은 배, 노란 눈, 빨간 혀
```

**AI 프롬프트:**
```
A 32x32 pixel art sprite sheet of a Korean great serpent (gureongi/imugi) 
for a top-down 2D game. A large blue-scaled snake with yellow slit-pupil eyes, 
forked red tongue, and small whiskers. S-curved body with lighter blue belly. 
4 frames slithering animation, horizontal row. 16-bit style, blue palette, 
black outline, transparent background.
```

---

#### EN-09. 날쌘돌이 — `enemy_nalssaen.png` | 128x32

**설정:** 목(木) | HP 8 (낮음) | DMG 3 | 속도 130 (최고속) | 크기 28 | EXP 1

**비주얼:**
```
형태: 매우 작고 빠른 녹색 도깨비
크기: 16x20px (가장 작음)
머리: 작고 둥근 머리, 짧은 뿔 1개, 큰 동그란 눈, 씩 웃는 입
몸: 작고 마른 녹색 몸, 나뭇잎 허리감개
다리: 긴 다리(몸 대비), 과장된 달리기 자세
효과: 뒤에 속도선/먼지(1-2px)
색상: 밝은 녹색(#7BC96F), 잎사귀 어두운 녹색
```

**AI 프롬프트:**
```
A 32x32 pixel art sprite sheet of a tiny fast Korean goblin imp (nalssaendoli) 
for a top-down 2D game. Very small green creature with oversized round eyes, 
one tiny horn, a wide grin, wearing a leaf loincloth. Long legs for its body 
size, running at high speed with speed lines. 4 frames fast running, horizontal 
row. 16-bit style, bright green, black outline, transparent background.
```

---

#### EN-10. 강시 (殭屍) — `enemy_gangsi.png` | 128x32

**설정:** 토(土) | HP 60 (최고) | DMG 10 | 속도 35 | 크기 44 | EXP 10

**비주얼:**
```
형태: 중국풍 좀비(강시) — 조선 해석
크기: 22x28px (키가 큼)
머리: 청나라/조선식 관모, 모자에 황색 부적 1장, 창백한 녹색(#88A088) 피부
      감긴 눈, 입 벌림+송곳니
몸: 청색(#1D3557) 관복, 양팔을 앞으로 쭉 뻗은 자세 (강시 특유)
    금색 단추/줄 장식
다리: 뻣뻣한 점프 이동 (양발 모아 깡충)
색상: 창백한 녹색 피부, 청색 옷, 금장식, 황색 부적
```

**프레임 특수:**
```
walk0: 착지 자세, 팔 앞으로 뻗음
walk1: 점프 준비, 1px 아래로 웅크림
walk2: 점프 중, 3px 위로 (강시 특유 깡충)
walk3: 공중, 2px 위 (내려오는 중)
```

**AI 프롬프트:**
```
A 32x32 pixel art sprite sheet of a Korean gangsi (jiangshi/hopping vampire) 
for a top-down 2D game. Pale green-skinned undead in dark blue Joseon official 
robes with gold trim, wearing a square hat with a yellow talisman on forehead. 
Arms stretched forward rigidly. 4 frames showing hopping movement. 16-bit style, 
black outline, transparent background.
```

---

### 2-3. 보스 (5종)

**공통 사양:**
- 시트: 256x64 (64x64 x 4프레임)
- 코드: `boss.dart`에서 개별 관리 (적 풀에 들어가지 않음)
- HP 스케일링: `maxHp = data.hp * (1 + gameTimeMinutes * bossHpScale)`
- 스텔스: alpha 0.3 (보이기 단계에서 1.0으로 복귀)

> ⚠️ **현재 상태**: Boss.dart는 스프라이트를 전혀 사용하지 않습니다.
> 렌더링은 100% Canvas 프리미티브 (색상 RRect + 빨간 원 눈 + TextPainter)로 처리.
> SpriteLoader가 보스 PNG를 로드하지만, boss.dart에서 참조하는 코드가 없습니다.
> **보스 스프라이트 렌더링 코드 작성이 필요합니다.**

> ⚠️ **이름 불일치**: 보스 데이터 ID와 SpriteLoader 파일명 사이에 매핑 함수가 없음.
> - `dokkaebi_daejang` → `boss_dokkaebi` (불일치)
> - `gumiho` → `boss_gumiho` (일치)
> - `jangsanbeom` → `boss_jangsan` (불일치)
> - `bulgasari_boss` → `boss_bulgasari` (불일치)
> - `yongwang` → `boss_yongwang` (일치)
> **SpriteLoader에 `bossImageName()` 매핑 함수 추가 필요.**

> **GPT 프롬프트 사용법**: 섹션 1-5의 **통합 베이스** + **boss 포맷 블록**을 먼저 붙이고,
> 아래 각 보스의 `AI 프롬프트` 내용을 `Boss:` 블록으로 넣으세요.
> 후처리: `python tools/sprite_cleanup.py raw.png -o assets/images/boss_{id}.png --type boss --debug`

---

#### BOSS-01. 도깨비 대장 — `boss_dokkaebi.png` | 256x64

**설정:** 목(木) | HP 500 | 속도 50 | 크기 96 | 드롭 iron상자
**패턴:** rotate(방망이 360도), summon(졸개 소환), enrage(광폭화)

**비주얼:**
```
형태: 거대한 적색 도깨비 — 졸개의 대형 보스 버전
크기: 54x58px (64x64 거의 꽉 참)
머리: 큰 붉은(#D4483B) 얼굴, 거대한 뿔 2개 (금색 고리)
      부릅뜬 노란 눈, 금니, 불꽃 같은 검은 갈기
몸: 거대한 근육질 적색 상체, 호피 갑옷+금장식, 가슴에 금색 메달리온
다리: 굵은 다리, 호피 바지, 큰 신발
소품: 오른손에 거대한 금색 방망이 (도깨비 방망이, 금빛 파티클)
색상: 적색 피부, 금색 방망이/장식, 호피, 검정
```

**AI 프롬프트:**
```
A 64x64 pixel art sprite sheet of a Korean dokkaebi (goblin king) boss for a 
top-down 2D game. A massive red-skinned demon king with two large horns adorned 
with gold rings, fierce yellow eyes, gold teeth, wild black hair. Tiger-print 
armor with gold decorations, huge golden magic club. 4 frames idle animation, 
horizontal row. 16-bit detailed pixel art, black outline, transparent background.
```

---

#### BOSS-02. 구미호 (九尾狐) — `boss_gumiho.png` | 256x64

**설정:** 화(火) | HP 1500 | 속도 60 | 크기 112 | 드롭 gold상자
**패턴:** charm(매혹 파동), radial8(여우불 8방향), clone(분신 2체)

**비주얼:**
```
형태: 반변신 구미호 — 상반신 아름다운 여인, 하반신 여우
크기: 56x60px
상반신: 아름다운 창백한 얼굴, 붉은 입술, 뾰족한 여우 귀
        긴 흰색+빨간색 머리카락, 붉은 비단 저고리
하반신: 흰색→붉은색 여우 몸통 + 4다리
        9개의 꼬리, 각 끝에 작은 파란 여우불
색상: 흰+빨강 모피, 파란 여우불, 금 장식
```

**AI 프롬프트:**
```
A 64x64 pixel art sprite sheet of a Korean gumiho (nine-tailed fox) boss. 
Upper body is a beautiful pale-faced woman with fox ears, red silk jeogori. 
Lower body is a white-to-red fox with nine magnificent tails tipped with blue 
foxfire. 4 frames idle, horizontal row. 16-bit detailed pixel art, black outline, 
transparent background.
```

---

#### BOSS-03. 장산범 — `boss_jangsan.png` | 256x64

**설정:** 금(金) | HP 3000 | 속도 45 | 크기 120 | 드롭 jade상자
**패턴:** soundWave(음파 직선), buffAllies(주변 적 강화), stealth(투명화+기습)

**비주얼:**
```
형태: 흰 장모의 거대한 괴물 — 사람 목소리를 흉내내는 산짐승
크기: 58x60px
머리: 흰색 모피로 덮인 둥근 머리, 거대한 빨간 입(얼굴의 80%)
      이빨 수십 개, 눈은 모피에 가려짐
몸: 흰색(#E8E8F0) 긴 모피, 바닥까지 늘어짐 (다리 안 보임)
효과: 입에서 음파 링 이펙트, 주변 안개/연무
색상: 흰색 모피, 빨간 입, 은색 이빨, 회색 그림자
```

**AI 프롬프트:**
```
A 64x64 pixel art sprite sheet of a Korean jangsan-beom (mountain monster) boss. 
Massive creature covered in long white fur, enormous gaping red mouth with countless 
teeth, no visible eyes. Fur drapes to the ground hiding legs. Sound wave rings 
from mouth. 4 frames idle, horizontal row. 16-bit pixel art, black outline, 
transparent background.
```

---

#### BOSS-04. 불가사리 — `boss_bulgasari.png` | 256x64

**설정:** 토(土) | HP 5000 | 속도 35 | 크기 128 | 드롭 jade상자
**패턴:** charge(화면 횡단 돌진), quake(지진/전체 슬로우), invincible(5초 무적)

**비주얼:**
```
형태: 금속+돌 혼합 거대 괴수 — 쇠를 먹는 전설의 괴물
크기: 60x58px (가로로 큼)
머리: 코뿔소+곰 혼합, 금속 뿔 1개, 주황 눈, 금속 이빨
몸: 돌(회갈색)+금속(은색) 혼합 텍스처, 등에 금속 돌기들
다리: 굵고 짧은 4다리, 금속 발굽
효과: 발밑 균열/먼지, 금속 반짝임
색상: 돌 회갈색 + 금속 은색, 주황 눈
```

**AI 프롬프트:**
```
A 64x64 pixel art sprite sheet of a Korean bulgasari (iron-eating beast) boss. 
Massive rhino-bear hybrid with mixed stone and metal body, one metallic horn, 
glowing orange eyes. Metal plates and spikes. Incredibly heavy with thick legs 
and metal hooves. 4 frames idle, horizontal row. 16-bit pixel art, stone-grey 
and metallic silver, black outline, transparent background.
```

---

#### BOSS-05. 용왕 (龍王) — `boss_yongwang.png` | 256x64

**설정:** 수(水) | HP 8000 | 속도 30 | 크기 140 | 드롭 dragon상자 (최종 보스)
**패턴:** waterPillar(물기둥 3개), whirlpool(소용돌이), tsunami(해일/화면 50%)

**비주얼:**
```
형태: 동양 용+인간 혼합 — 용의 갑옷을 입은 왕
크기: 60x62px (최대 보스)
머리: 금색 용 뿔 2개(사슴뿔형), 용왕관, 흰 수염/머리카락 (물처럼 흐름)
몸: 청색(#1A3A5C) 용비늘 갑옷, 가슴에 여의주(청색 발광), 양 어깨에 용 장식
하반신: 용 비늘 하의, 물결 효과, 발 주변에 물 파동 링
소품: 오른손에 용왕 삼지창(금+청색)
색상: 청색+금색 주조, 흰 수염/머리, 여의주 발광
```

**AI 프롬프트:**
```
A 64x64 pixel art sprite sheet of the Korean Dragon King (Yongwang) boss. 
Imposing elderly figure in blue dragon-scale armor with golden crown and antler 
horns. Glowing blue dragon pearl on chest, gold trident, flowing white beard. 
Water effects surround him. 4 frames idle, horizontal row. 16-bit pixel art, 
blue and gold, black outline, transparent background.
```

---

### 2-4. 투사체 — 기본 무기 (8종)

**공통 사양:**
- 시트: 64x16 (16x16 x 4프레임)
- 코드: `projectile_manager.dart` — `SpriteLoader.projectileImageName(proj.weaponId)`
- 렌더 크기: `proj.size * 2.5` (기본 size=12 → 30px)
- 프레임 타이머: 0.1초 간격
- 컬링: 카메라 중심 ±480/±320 밖 생략
- 폴백: `SpritePainter` per-weaponId 캔버스 드로잉

> **GPT 프롬프트 사용법**: 섹션 1-5의 **통합 베이스** + **projectile 포맷 블록**을 먼저 붙이고,
> 아래 표의 비주얼 열 내용을 `Projectile:` 블록으로 넣으세요.
> 후처리: `python tools/sprite_cleanup.py raw.png -o assets/images/proj_{id}.png --type projectile --debug`

| ID | 파일명 | weaponId | 무기 | 비주얼 | 색상 |
|----|--------|----------|------|--------|------|
| PJ-01 | `proj_bujeok.png` | toema_bujeok | 퇴마부적 | 노란 직사각 종이, 붉은 글씨, 회전 비행 | 황(#FFD166)+적(#E63946) |
| PJ-02 | `proj_binyeo.png` | binyeo_geom | 비녀검 | 은색 비녀, 날카로운 끝, 은빛 궤적 | 은(#E8E8F0)+백(#FFFFFF) |
| PJ-03 | `proj_bangul.png` | sinseong_bangul | 신성 방울 | 금색 둥근 방울, 음파 링 확산 | 금(#FFD166)+청(#88CCEE) |
| PJ-04 | `proj_geumgangeo.png` | geumgangeo | 금강저 | 금빛 양끝 갈라진 법기, 번개 이펙트 | 금(#FFD166)+황(#F5E6C8) |
| PJ-05 | `proj_hwasal.png` | hwasal | 화살 | 갈색 대나무 화살+흰 깃털, 직선 비행 | 갈(#755540)+백 |
| PJ-06 | `proj_dokkaebi_bul.png` | dokkaebi_bul | 도깨비불 | 파란+녹색 도깨비불, 일렁이는 불꽃 | 청(#3366AA)+녹(#4A8C3F) |
| PJ-07 | `proj_dolpalmae.png` | dolpalmae | 돌팔매 | 둥근 회색 돌, 회전, 잔상 효과 | 회(#8888A0)+갈 |
| PJ-08 | `proj_explosion.png` | pungmul_buk | 폭발 | 주황→빨강 폭발, 팽창→소멸 | 주황→빨강→연기 |

> ⚠️ **매핑 누락 무기 3종**: `cheondung`, `punggyeong`, `cheongryongdo`는 `projectileImageName()` switch에 없음.
> 기본값 `proj_bujeok`으로 폴백되지만, 실제 렌더는 `SpritePainter`가 weaponId별로 처리.
> **이 3종의 전용 투사체 스프라이트 + 매핑 코드 추가가 필요합니다.**

**투사체별 AI 프롬프트:**

**PJ-01 부적:**
```
A 16x16 pixel art sprite sheet of a Korean talisman projectile. Small rectangular 
yellow paper with red mystical writing, spinning as it flies. 4 frames rotation. 
Golden aura. 16-bit style, transparent background.
```

**PJ-02 비녀검:**
```
A 16x16 pixel art sprite sheet of a Korean binyeo (hairpin dagger) projectile. 
Silver ornate hairpin blade spinning with sparkle trail. 4 frames rotation. 
Metallic silver. 16-bit style, transparent background.
```

**PJ-03 방울:**
```
A 16x16 pixel art sprite sheet of a Korean sacred bell projectile. Small golden 
bell with expanding blue sound wave rings. 4 frames ring expansion. 16-bit style, 
transparent background.
```

**PJ-04 금강저:**
```
A 16x16 pixel art sprite sheet of a Korean vajra (geumgangeo) projectile. Golden 
double-pronged ritual weapon with lightning sparks. 4 frames with lightning flash. 
16-bit style, transparent background.
```

**PJ-05 화살:**
```
A 16x16 pixel art sprite sheet of a Korean bamboo arrow projectile. Brown bamboo 
shaft with white feather fletching. 4 frames with slight vibration. 16-bit style, 
transparent background.
```

**PJ-06 도깨비불:**
```
A 16x16 pixel art sprite sheet of a Korean dokkaebi fire (ghost flame) projectile. 
Blue-green spirit flame that flickers. 4 frames flickering. 16-bit style, 
transparent background.
```

**PJ-07 돌팔매:**
```
A 16x16 pixel art sprite sheet of a round grey sling stone spinning through air. 
4 frames rotation with blur trail. 16-bit style, transparent background.
```

**PJ-08 폭발:**
```
A 16x16 pixel art sprite sheet of an explosion effect. 4 frames: small spark, 
expanding orange fireball, large red explosion, fading smoke. 16-bit style, 
transparent background.
```

---

### 2-5. 투사체 — 진화 무기 (12종)

**사양:** 64x16 (16x16 x 4프레임) — 기본과 동일하되 더 화려

> ⚠️ **현재 상태**: 12종 모두 파일이 `assets/images/`에 없음. SpriteLoader에 매핑은 있으나
> 실제 파일 미존재 → Canvas 폴백으로 렌더링 중.

| 파일명 | weaponId | 진화무기 | 원본무기 | 필요 패시브 | 비주얼 | 색상 |
|--------|----------|---------|---------|------------|--------|------|
| `proj_cheonloe.png` | cheonloe_bujeok | 천뢰부적 | 퇴마부적 | 화톳불 | 번개 감싼 부적, 전기 아크 | 금+백+청 |
| `proj_yongcheon.png` | yongcheon_geom | 용천검 | 비녀검 | 부채 | 푸른 빛 검, 용 실루엣 잔상 | 청+백 |
| `proj_cheongryong_eon.png` | cheongryong_eonwoldo | 청룡언월도 | 청룡도 | 두루마리 | 녹색 빛 초승달 참격파 | 녹+백 |
| `proj_hangma.png` | hangma_geumgangeo | 항마금강저 | 금강저 | 인삼 | 3갈래 금빛 법기, 폭발 기운 | 금+주황 |
| `proj_cheonji.png` | cheonji_bangul | 천지방울 | 신성 방울 | 향로 | 거대 음파 링, 무지개빛 | 무지개 |
| `proj_samulnori.png` | samulnori | 사물놀이 | 풍물북 | 장구 | 4색 폭발 (빨파노녹) | 4색 |
| `proj_gumiho.png` | gumiho_baltop | 구미호 발톱 | 요기 발톱 | 여우구슬 | 보라빛 에너지 클로 3개 | 보라+빨강 |
| `proj_taegeuk.png` | taegeukjin | 태극진 | 팔괘진 | 나침반 | 태극 문양 회전 구슬 | 빨+파 |
| `proj_singung.png` | singung | 신궁 | 화살 | 매 깃털 | 금빛 광선 화살, 관통 궤적 | 금+백 |
| `proj_hwangcheon.png` | hwangcheon_dokmu | 황천독무 | 독안개 | 독사 이빨 | 보라 독구름, 해골 실루엣 | 보라+녹 |
| `proj_bulgasari.png` | bulgasari | 불가사리 | 돌팔매 | 두꺼비 석상 | 거대 금속 덩어리, 충격파 | 은+갈색 |
| `proj_sammae.png` | sammae_jinhwa | 삼매진화 | 도깨비불 | 등잔 | 큰 푸른 불꽃+분열 파편 | 청+금 |

---

### 2-6. 아이템

#### `exp_gems.png` — 경험치 기운 | 시트: 최소 192x16 (16x16 x 12프레임)

코드: `exp_gem_manager.dart` — `spriteIndex = gem.tier * 4 + _frameIndex`

> **참고**: 코드상 tier는 0/1/2 (3등급), 4프레임씩 = 총 12프레임.
> 기존 문서의 4행(64x64) 구조가 아닌 **1행 12프레임 가로 구조**가 맞음.
> `drawFrame`의 `row` 파라미터는 사용되지 않으므로 spriteIndex로 가로 접근.

```
프레임 0-3  (tier 0, 소): 작은 파란 구슬 (8x8px 내부), 반짝임 애니, EXP<5
프레임 4-7  (tier 1, 대): 중간 녹색 구슬 (10x10px), 빛나는 코어, EXP≥5
프레임 8-11 (tier 2, 결정): 큰 황금 구슬 (12x12px), 금빛 발광, EXP≥25
```

렌더 크기: `gem.size * 2` (tier 0: 16px, tier 1: 24px, tier 2: 32px)

**AI 프롬프트:**
```
A 192x16 pixel art sprite sheet of experience gem orbs for a 2D game. 
12 frames in a single horizontal row (16x16 per frame). Frames 1-4: tiny blue 
crystal orb with sparkle animation. Frames 5-8: medium green crystal orb glowing. 
Frames 9-12: large golden crystal orb with bright shine. Each set of 4 shows 
pulsing/shimmering animation. 16-bit style, transparent background.
```

#### `chests.png` — 보물상자 | 128x32 (32x32 x 4)

코드: `treasure_chest.dart` — `_gradeIndex`로 프레임 선택

```
프레임0 (wood/iron): 나무 상자, 철 장식 — wood과 iron 모두 이 프레임 공유
프레임1 (gold): 금 테두리 상자, 빛남
프레임2 (jade): 옥색 상자, 보석 장식
프레임3 (dragon): 용 문양 상자, 보라빛 발광
```

렌더 크기: destW=40, destH=36 (약간 스케일업)

**AI 프롬프트:**
```
A 128x32 pixel art sprite sheet of 4 treasure chests for a 2D Korean mythology 
game, each 32x32. Left to right: 1) Simple wooden chest with iron bands. 
2) Gold-trimmed chest with golden glow. 3) Jade-colored chest with gemstone 
decorations. 4) Dragon-carved chest with purple magical glow. Top-down 3/4 view. 
16-bit style, transparent background.
```

---

### 2-7. 배경 타일 | `tiles.png`

**현재 사양:** 128x64 (64x64 x 2프레임)
- 코드: `background_renderer.dart` — `tileIndex = hash % 2` (2종 변형)
- 타일 화면 크기: 128x128px (2배 스케일, `destW: 128, destH: 128`)
- 월드 크기: 4000x4000
- 폴백: `SpritePainter.drawGroundTile()`

**확장 계획 (스테이지별 2종 변형):**

| 프레임 | 스테이지 ID | 스테이지명 | 비주얼 |
|--------|-----------|-----------|--------|
| 0-1 | bamboo_forest | 대나무 숲 | 초록 풀밭+대나무 그림자, 변형: 돌+꽃 |
| 2-3 | hanok_village | 한옥 마을 | 마당 돌바닥+기와 조각, 변형: 나무마루 |
| 4-5 | underground_palace | 지하 궁궐 | 어두운 돌바닥+금장식, 변형: 이끼 돌 |
| 6-7 | gwimungwan | 귀문관 | 붉은 바닥+부적 조각, 변형: 피 얼룩 |
| 8-9 | hwangcheon | 황천길 | 검은 바닥+뼈, 변형: 보라 안개 |
| 10-11 | dokkaebi_market | 도깨비 시장 | 나무판자+등불, 변형: 포장마차 바닥 |
| 12-13 | infinite_tower | 무한의 탑 | 석조 타일+마법진, 변형: 균열 |

→ 확장 시 시트 크기: 896x64 (64x64 x 14프레임)
→ **스테이지별 타일 인덱스 매핑 코드 수정 필요** (현재 hash % 2 고정)

**타일 AI 프롬프트 (대나무 숲):**
```
A 128x64 pixel art tileset of 2 ground tile variations for a Korean bamboo 
forest in a top-down 2D game. Each tile 64x64 pixels. Tile 1: green grass 
with bamboo shadows and small plants. Tile 2: similar but with small stones 
and flowers. Dark green palette, subtle pattern, tileable. 16-bit style.
```

---

### 2-8. UI 요소 | `ui_elements.png`

> ⚠️ **현재 상태**: `ui_elements.png`는 SpriteLoader에서 로드되지만,
> **코드 어디에서도 `drawFrame`으로 참조하지 않습니다.**
> HUD(`hud_overlay.dart`)는 100% Flutter 위젯으로 렌더링:
> - HP바: Container + LinearGradient
> - 타이머: Text 위젯
> - 킬 카운트: Icons.dangerous + Text
> - 무기 슬롯: 32x32 색상 박스 + 무기명 첫 글자
> - EXP바: 녹색 그라데이션 Container
> - 미니맵: 80x80 CustomPaint (캔버스 직접 렌더)
> - 버튼: Flutter 위젯

**향후 스프라이트 UI로 전환 시 레이아웃:**
```
행0 (y:0-15):    오행 원소 아이콘 16x16 x 5 (목/화/토/금/수)
행1 (y:16-39):   패시브 아이콘 24x24 x 12 (모든 패시브)
행2 (y:40-55):   HP바 프레임 128x16, HP바 채움 128x16
행3 (y:56-71):   EXP바 프레임 128x16, EXP바 채움 128x16
행4 (y:72-103):  무기 슬롯 프레임 32x32 x 6
행5 (y:104-135): 레벨업 카드 배경 64x32 x 4
행6 (y:136-159): 버튼들 (일시정지, 재개, 설정) 24x24 x 3
행7 (y:160-191): 캐릭터 초상 아이콘 32x32 x 8
```

---

### 2-9. 캐릭터 초상화 (캐릭터 선택 화면용)

> ⚠️ **현재 상태**: 캐릭터 선택은 `Text(c.name[0])` (이름 첫 글자)로만 표시.
> 초상화 파일 미생성, 코드 미구현.

| 파일명 | 캐릭터 | 크기 |
|--------|--------|------|
| `portrait_lee_taeyang.png` | 이태양 | 48x48 |
| `portrait_wolhui.png` | 월희 | 48x48 |
| `portrait_cheolwoong.png` | 철웅 | 48x48 |
| `portrait_soyeon.png` | 소연 | 48x48 |
| `portrait_beopwoon.png` | 법운 | 48x48 |
| `portrait_danbi.png` | 단비 | 48x48 |
| `portrait_gwison.png` | 귀손 | 48x48 |
| `portrait_cheonmoo.png` | 천무 | 48x48 |

---

## 3. 오디오 에셋 목록

### 3-1. SFX (효과음)

**코드 참조:** `audio_service.dart`

#### 존재하는 파일 (assets/audio/sfx/)

| 파일명 | 트리거 | 상태 |
|--------|--------|------|
| `weapon_toema_bujeok.wav` | 퇴마부적 발사 | ✅ |
| `weapon_binyeo_geom.wav` | 비녀검 발사 | ✅ |
| `weapon_dokkaebi_bul.wav` | 도깨비불 발사 | ✅ |
| `weapon_cheondung.wav` | 천둥 발사 | ✅ |
| `weapon_punggyeong.wav` | 풍경 발사 | ✅ |
| `weapon_cheongryongdo.wav` | 청룡도 발사 | ✅ |
| `weapon_geumgangeo.wav` | 금강저 발사 | ✅ |
| `weapon_sinseong_bangul.wav` | 신성 방울 발사 | ✅ |
| `weapon_pungmul_buk.wav` | 풍물북 발사 | ✅ |
| `weapon_dokangae.wav` | 독안개 발사 | ✅ |
| `weapon_dolpalmae.wav` | 돌팔매 발사 | ✅ |
| `weapon_hwasal.wav` | 화살 발사 | ✅ |
| `weapon_palgwaejin.wav` | 팔괘진 발사 | ✅ |
| `weapon_yogi_baltop.wav` | 요기 발톱 발사 | ✅ |
| `weapon_generic.wav` | 매핑 없는 무기 폴백 | ✅ |
| `enemy_hit.wav` | 적 피격 | ✅ |
| `enemy_death.wav` | 적 사망 | ✅ |
| `level_up.wav` | 레벨업 | ✅ |
| `boss_appear.wav` | 보스 등장 | ✅ |
| `chest_open.wav` | 상자 열기 | ✅ |
| `exp_collect.wav` | 경험치 수집 | ✅ |
| `evolution.wav` | 무기 진화 / 프레스티지 | ✅ |
| `player_hit.wav` | 플레이어 피격 | ✅ |
| `ui_click.wav` | UI 클릭 | ✅ |

#### 코드에서 참조하지만 미생성 파일

| 파일명 | 트리거 | 상태 |
|--------|--------|------|
| `crit_hit.wav` | 치명타 적중 | ❌ 미생성 |
| `elite_spawn.wav` | 엘리트 적 생성 | ❌ 미생성 |
| `milestone.wav` | 마일스톤 달성 | ❌ 미생성 |
| `wave_start.wav` | 웨이브 시작 | ❌ 미생성 |
| `ui_back.wav` | UI 뒤로가기 | ❌ 미생성 |
| `daily_reward.wav` | 일일 보상 | ❌ 미생성 |

### 3-2. BGM (배경음악)

**코드 참조:** `audio_service.dart` + `stages.dart`

| 파일명 | 용도 | 상태 |
|--------|------|------|
| `bgm/title.wav` | 타이틀 화면 | ✅ |
| `bgm/stage_1.wav` | 대나무 숲 / 한옥 마을 | ✅ |
| `bgm/stage_boss.wav` | 도깨비 대장 / 구미호 보스전 | ✅ |
| `bgm/stage_2.wav` | 지하 궁궐 / 귀문관 | ❌ 미생성 |
| `bgm/stage_3.wav` | 황천길 | ❌ 미생성 |
| `bgm/stage_4.wav` | 도깨비 시장 | ❌ 미생성 |
| `bgm/stage_5.wav` | 무한의 탑 | ❌ 미생성 |
| `bgm/stage_boss_2.wav` | 장산범 / 불가사리 보스전 | ❌ 미생성 |
| `bgm/stage_boss_final.wav` | 용왕 최종 보스전 | ❌ 미생성 |

**BGM 볼륨 동적 조정:**
- 기본 볼륨: `bgmVolume × (0.7 + intensity × 0.3)`
- 보스전: intensity → 1.0
- 일반: 적 수에 비례 스케일링

---

## 4. 코드 매핑 + 파일명 정리 (완전판)

### 4-1. SpriteLoader 매핑

**플레이어:** `playerImageName(characterId)` = `'player_$characterId'`
```
lee_taeyang  → player_lee_taeyang.png   ✅ 파일 존재
wolhui       → player_wolhui.png        ✅ 파일 존재
cheolwoong   → player_cheolwoong.png    ✅ 파일 존재
soyeon       → player_soyeon.png        ✅ 파일 존재
beopwoon     → player_beopwoon.png      ✅ 파일 존재
danbi        → player_danbi.png         ✅ 파일 존재
gwison       → player_gwison.png        ✅ 파일 존재
cheonmoo     → player_cheonmoo.png      ✅ 파일 존재
```

**적:** `enemyImageName(type.name)` switch 매핑
```
jabgwi          → enemy_jabgwi.png          ✅ 파일 존재
dokkaebiJol     → enemy_dokkaebi_jol.png    ✅ 파일 존재
cheonyeoGwisin  → enemy_cheonyeo_gwisin.png ✅ 파일 존재
haetaeSeoksang  → enemy_haetae.png          ✅ 파일 존재
bulyeou         → enemy_bulyeou.png         ✅ 파일 존재
gapotGwisin     → enemy_gapot_gwisin.png    ✅ 파일 존재
yacha           → enemy_yacha.png           ✅ 파일 존재
gureongi        → enemy_gureongi.png        ✅ 파일 존재
nalssaenDoli    → enemy_nalssaen.png        ✅ 파일 존재
gangsi          → enemy_gangsi.png          ✅ 파일 존재
(default)       → enemy_jabgwi.png          (폴백)
```

**보스:** SpriteLoader에 하드코딩된 로드 목록
```
boss_dokkaebi.png    ✅ 파일 존재 (⚠️ 코드에서 미사용)
boss_gumiho.png      ✅ 파일 존재 (⚠️ 코드에서 미사용)
boss_jangsan.png     ✅ 파일 존재 (⚠️ 코드에서 미사용)
boss_bulgasari.png   ✅ 파일 존재 (⚠️ 코드에서 미사용)
boss_yongwang.png    ✅ 파일 존재 (⚠️ 코드에서 미사용)
```

**투사체 (기본):** `projectileImageName(weaponId)` switch 매핑
```
toema_bujeok     → proj_bujeok.png       ✅ 파일 존재
binyeo_geom      → proj_binyeo.png       ✅ 파일 존재
sinseong_bangul  → proj_bangul.png       ✅ 파일 존재
geumgangeo       → proj_geumgangeo.png   ✅ 파일 존재
hwasal           → proj_hwasal.png       ✅ 파일 존재
dokkaebi_bul     → proj_dokkaebi_bul.png ✅ 파일 존재
dolpalmae        → proj_dolpalmae.png    ✅ 파일 존재
pungmul_buk      → proj_explosion.png    ✅ 파일 존재
(default)        → proj_bujeok.png       (폴백)
```

> ⚠️ 매핑 누락: `cheondung`, `punggyeong`, `cheongryongdo` → default 폴백

**투사체 (진화):** `projectileImageName(weaponId)` switch 매핑
```
cheonloe_bujeok       → proj_cheonloe.png         ❌ 파일 없음
yongcheon_geom        → proj_yongcheon.png         ❌ 파일 없음
cheongryong_eonwoldo  → proj_cheongryong_eon.png   ❌ 파일 없음
hangma_geumgangeo     → proj_hangma.png            ❌ 파일 없음
cheonji_bangul        → proj_cheonji.png           ❌ 파일 없음
samulnori             → proj_samulnori.png         ❌ 파일 없음
gumiho_baltop         → proj_gumiho.png            ❌ 파일 없음
taegeukjin            → proj_taegeuk.png           ❌ 파일 없음
singung               → proj_singung.png           ❌ 파일 없음
hwangcheon_dokmu      → proj_hwangcheon.png        ❌ 파일 없음
bulgasari             → proj_bulgasari.png         ❌ 파일 없음
sammae_jinhwa         → proj_sammae.png            ❌ 파일 없음
```

### 4-2. 기타 에셋 매핑
```
exp_gems    → exp_gems.png      ✅ 파일 존재
chests      → chests.png        ✅ 파일 존재
tiles       → tiles.png         ✅ 파일 존재
ui_elements → ui_elements.png   ✅ 파일 존재 (⚠️ 코드에서 미사용)
```

---

## 5. 제작 우선순위

### Phase 1: MVP 비주얼 (스테이지 1 플레이 가능)

| 순번 | 에셋 | 파일명 | 현재 상태 | 난이도 |
|------|------|--------|----------|--------|
| 1 | 이태양 (주인공) | `player_lee_taeyang.png` | placeholder | ★★★ |
| 2 | 잡귀 | `enemy_jabgwi.png` | placeholder | ★ |
| 3 | 도깨비졸 | `enemy_dokkaebi_jol.png` | placeholder | ★★ |
| 4 | 처녀귀신 | `enemy_cheonyeo_gwisin.png` | placeholder | ★★ |
| 5 | 부적 투사체 | `proj_bujeok.png` | placeholder | ★ |
| 6 | 방울 투사체 | `proj_bangul.png` | placeholder | ★ |
| 7 | 경험치 기운 | `exp_gems.png` | placeholder | ★ |
| 8 | 대나무 숲 타일 | `tiles.png` (프레임 0-1) | placeholder | ★★ |

### Phase 2: 전투 확장 (적+보스+무기)

| 순번 | 에셋 | 파일명 | 현재 상태 | 난이도 |
|------|------|--------|----------|--------|
| 9 | 해태 석상 | `enemy_haetae.png` | placeholder | ★★ |
| 10 | 불여우 | `enemy_bulyeou.png` | placeholder | ★★ |
| 11 | 갑옷 귀신 | `enemy_gapot_gwisin.png` | placeholder | ★★★ |
| 12 | 야차 | `enemy_yacha.png` | placeholder | ★★ |
| 13 | 구렁이 | `enemy_gureongi.png` | placeholder | ★★ |
| 14 | 날쌘돌이 | `enemy_nalssaen.png` | placeholder | ★ |
| 15 | 강시 | `enemy_gangsi.png` | placeholder | ★★★ |
| 16 | 도깨비 대장 보스 | `boss_dokkaebi.png` | placeholder (미사용) | ★★★★ |
| 17 | 구미호 보스 | `boss_gumiho.png` | placeholder (미사용) | ★★★★ |
| 18-23 | 나머지 투사체 6종 | `proj_*.png` | placeholder | ★ 각각 |
| 24 | 보물상자 | `chests.png` | placeholder | ★★ |

### Phase 3: 캐릭터+스테이지 확장

| 순번 | 에셋 | 파일명 | 현재 상태 | 난이도 |
|------|------|--------|----------|--------|
| 25-31 | 플레이어 7종 | `player_*.png` | placeholder | ★★★ 각각 |
| 32-34 | 나머지 보스 3종 | `boss_*.png` | placeholder (미사용) | ★★★★ 각각 |
| 35 | 배경 타일 확장 | `tiles.png` 전체 14프레임 | placeholder (2프레임) | ★★ |

### Phase 4: 폴리시+진화+오디오

| 순번 | 에셋 | 파일명 | 현재 상태 | 난이도 |
|------|------|--------|----------|--------|
| 36-47 | 진화 투사체 12종 | `proj_*.png` | ❌ 미생성 | ★★ 각각 |
| 48 | UI 요소 | `ui_elements.png` | placeholder (미사용) | ★★★ |
| 49-56 | 캐릭터 초상화 8종 | `portrait_*.png` | ❌ 미생성 | ★★★ 각각 |
| 57 | 미생성 SFX 6종 | `*.wav` | ❌ 미생성 | ★ 각각 |
| 58 | 미생성 BGM 6종 | `bgm/*.wav` | ❌ 미생성 | ★★★ 각각 |

---

## 6. 코드 수정 필요사항 (에셋 연동)

에셋 제작과 병행하여 코드 수정이 필요한 항목:

### 6-1. 보스 스프라이트 렌더링 (높은 우선순위)
- **파일**: `boss.dart`
- **내용**: Canvas 프리미티브 → SpriteLoader.drawFrame() 호출로 교체
- **추가**: SpriteLoader에 `bossImageName()` 매핑 함수 생성
  ```
  dokkaebi_daejang → boss_dokkaebi
  gumiho → boss_gumiho
  jangsanbeom → boss_jangsan
  bulgasari_boss → boss_bulgasari
  yongwang → boss_yongwang
  ```

### 6-2. 투사체 매핑 누락 3종 (중간 우선순위)
- **파일**: `sprite_loader.dart` → `projectileImageName()`
- **추가 매핑**:
  ```
  cheondung → (전용 투사체 파일명 필요)
  punggyeong → (전용 투사체 파일명 필요)
  cheongryongdo → (전용 투사체 파일명 필요)
  ```

### 6-3. 배경 타일 스테이지별 분기 (Phase 3)
- **파일**: `background_renderer.dart`
- **내용**: `hash % 2` → 스테이지 ID 기반 타일 인덱스 매핑

### 6-4. UI 스프라이트 전환 (Phase 4, 선택)
- **파일**: `hud_overlay.dart`
- **내용**: Flutter 위젯 → SpriteLoader.drawFrame() 기반으로 전환
- **우선순위**: 낮음 (현재 Flutter 위젯 방식도 충분히 동작)

### 6-5. 캐릭터 초상화 표시 (Phase 4)
- **파일**: 캐릭터 선택 화면
- **내용**: `Text(c.name[0])` → 초상화 이미지 표시로 교체

### 6-6. exp_gems 시트 구조 확인 (Phase 1)
- **현재 코드**: `spriteIndex = tier * 4 + frameIndex` (가로 1행 12프레임)
- **기존 문서**: 4행 64x64 구조를 설명 — **코드와 불일치**
- **확인 필요**: 실제 placeholder PNG가 어떤 구조인지 확인 후, 코드 또는 에셋 통일

---

## 7. AI 도구 상세 가이드

### 7-1. Bing Image Creator (무료, 추천도 ★★★★★)

**접속:** https://www.bing.com/images/create
**엔진:** DALL-E 3 (무료)
**제한:** 일일 ~15회 빠른 생성, 이후 느린 생성 (무제한)

**최적 프롬프트 구조:**
```
[미디어 타입] [스타일] [주제 설명] [기술 스펙] [분위기] [제외사항]
```

**핵심 규칙:**
1. "sprite sheet"를 반드시 포함
2. "pixel art" + "16-bit" 조합이 가장 효과적
3. "transparent background"는 완벽 지원 안됨 → 후처리 필요
4. 구체적 색상명 포함하면 결과 개선
5. "top-down RPG" 시점 명시
6. 프레임 수와 레이아웃 명시

**주의사항:**
- DALL-E는 정확한 픽셀 수를 지키지 못함 → 참고 이미지로만 사용
- 스프라이트 시트 레이아웃이 불균일할 수 있음
- 한글보다 영문 프롬프트가 품질 좋음
- 생성 후 반드시 Aseprite에서 재작업 필요

### 7-2. Leonardo.ai (무료 크레딧, 추천도 ★★★★)

**접속:** https://leonardo.ai
**무료:** 일일 150토큰 (~30회 생성)

**추천 설정:**
```
Model: DreamShaper v7 또는 Pixel Art 모델
Size: 256x32 (플레이어) 또는 128x32 (적)
Guidance Scale: 7-9
Steps: 30
Negative Prompt: 3D, realistic, blurry, anti-aliased, smooth, 
                 high resolution, modern, photograph
```

### 7-3. Piskel (무료 웹, 추천도 ★★★★)

**접속:** https://www.piskelapp.com
**용도:** 브라우저에서 픽셀아트 제작/편집
**워크플로우:**
```
1. New Sprite → 32x32
2. AI 참고 이미지를 옆에 띄워놓고 따라 그리기
3. Frames 패널에서 프레임 추가
4. Export → PNG Spritesheet → Horizontal, 1 row
```

### 7-4. Aseprite ($19.99, 추천도 ★★★★★)

**구매:** https://www.aseprite.org 또는 Steam
**무료 대안:** LibreSprite (https://libresprite.github.io)

**이 프로젝트용 설정:**
```
1. File → New → 256x32 (플레이어) / 128x32 (적)
2. Sprite → Color Mode → Indexed (32색 팔레트)
3. 팔레트: Section 1-3의 마스터 팔레트 로드
4. View → Grid → 32x32 (프레임 가이드)
5. Export: Horizontal Strip, PNG, Trim Cells OFF
```

### 7-5. 워크플로우 (에셋 1종 완성 과정)

```
┌──────────────────────────────────────────────────┐
│ Step 1: AI 참고 이미지 생성 (5분)                   │
│   Bing에서 프롬프트 입력 → 4장 생성 → 최선 선택       │
├──────────────────────────────────────────────────┤
│ Step 2: 기본 프레임 제작 (15-30분)                  │
│   Aseprite/Piskel에서 캔버스 생성                   │
│   → 실루엣 → 채색 → 디테일 → 하이라이트/그림자       │
├──────────────────────────────────────────────────┤
│ Step 3: 애니메이션 (15-20분)                       │
│   Frame 1 복사 → 차이점만 수정 (1-2px 변경)          │
│   → Onion Skin 비교 → Preview 확인                 │
├──────────────────────────────────────────────────┤
│ Step 4: Export (2분)                              │
│   Horizontal Strip → assets/images/에 저장         │
│   → 파일명 규칙 확인                               │
├──────────────────────────────────────────────────┤
│ Step 5: 게임 내 테스트 (5분)                       │
│   flutter run → 스프라이트 로드/크기/애니 확인        │
│   → 필요 시 수정                                   │
└──────────────────────────────────────────────────┘

예상 시간: 에셋 1종당 약 40-60분
Phase 1 (8종): ~6-8시간
전체 (59종 이미지 + 오디오): ~50-60시간
```

---

## 8. 품질 체크리스트 (에셋 완성 시)

### 기술 검증
- [ ] PNG 파일 형식, 투명 배경
- [ ] 정확한 시트 크기 (256x32, 128x32, 256x64, 64x16)
- [ ] 프레임 간 정확한 간격 (32px, 64px, 16px)
- [ ] 1px 검정 아웃라인 일관성
- [ ] 안티앨리어싱 없음 (순수 픽셀)
- [ ] 파일명이 SpriteLoader 매핑과 정확히 일치

### 아트 검증
- [ ] 마스터 팔레트 32색 이내
- [ ] 광원 방향 일관성 (좌상단)
- [ ] 3/4 탑다운 시점 일관성
- [ ] 캐릭터 비율 일관성 (2.5~3등신)
- [ ] 원소별 색상 일관성 (오행 팔레트)
- [ ] 같은 카테고리 내 스타일 통일

### 애니메이션 검증
- [ ] idle: 미세한 움직임 (1-2px), 자연스러운 루프
- [ ] walk: 다리 교차 명확, 무한 루프 자연스러움
- [ ] flipX 시 부자연스러운 부분 없음 (비대칭 소품 주의)
- [ ] 각 대상의 프레임 타이머에서 자연스럽게 보이는지

### 게임 내 검증
- [ ] `flutter run`으로 실제 렌더링 확인
- [ ] 스케일링 후 깨짐 없음 (Nearest Neighbor 필터링)
- [ ] 다른 에셋과 어울리는지 (크기, 색감)
- [ ] 60fps에서 애니메이션 속도 적절한지
- [ ] 피격 플래시(흰색 틴트) 적용 시 자연스러운지

---

## 9. 성능 및 용량 가이드

| 항목 | 단일 파일 | 전체 예상 |
|------|----------|-----------|
| 플레이어 (256x32, 8종) | ~2-8KB | ~40KB |
| 적 (128x32, 10종) | ~1-4KB | ~30KB |
| 보스 (256x64, 5종) | ~5-15KB | ~50KB |
| 투사체 기본 (64x16, 8종) | ~0.5-1KB | ~6KB |
| 투사체 진화 (64x16, 12종) | ~0.5-1KB | ~9KB |
| 아이템 (2종) | ~2-5KB | ~7KB |
| 타일 (1종, 확장) | ~10-30KB | ~30KB |
| UI (1종) | ~5-15KB | ~15KB |
| 초상화 (48x48, 8종) | ~1-3KB | ~16KB |
| SFX (30종) | ~10-50KB | ~1MB |
| BGM (9종) | ~1-5MB | ~20MB |
| **합계** | | **~21MB** |

→ APK 크기 영향: ~20MB (주로 BGM)
→ 메모리: 전체 텍스처 언팩 ~2MB (RGBA) — 모바일에서 문제없음

**최적화 팁:**
- PNG 저장 시 Indexed Color (8-bit) → 용량 30-50% 절감
- OptiPNG 또는 TinyPNG로 추가 압축
- BGM은 OGG로 변환 시 WAV 대비 90% 절감 가능
- Flame은 로드 시 GPU 텍스처로 변환하므로 PNG 압축률은 로드 속도에만 영향

---

## 10. 총 에셋 수량 최종 정리

### 이미지 에셋

| 카테고리 | 수량 | 시트 크기 | 프레임 | 디스크 상태 | 코드 연동 |
|----------|------|-----------|--------|------------|----------|
| 플레이어 | 8종 | 256x32 | 32x32 x8 | ✅ placeholder 8종 | ✅ 매핑 완료 |
| 일반 적 | 10종 | 128x32 | 32x32 x4 | ✅ placeholder 10종 | ✅ 매핑 완료 |
| 보스 | 5종 | 256x64 | 64x64 x4 | ✅ placeholder 5종 | ⚠️ 로드만, 렌더 미구현 |
| 투사체(기본) | 8종 | 64x16 | 16x16 x4 | ✅ placeholder 8종 | ✅ 매핑 완료 (3종 누락) |
| 투사체(진화) | 12종 | 64x16 | 16x16 x4 | ❌ 미생성 | ✅ 매핑 완료 |
| 경험치 기운 | 1종 | 192x16 | 16x16 x12 | ✅ placeholder | ✅ 연동 |
| 보물상자 | 1종 | 128x32 | 32x32 x4 | ✅ placeholder | ✅ 연동 |
| 배경 타일 | 1종 | 128x64 (현재) | 64x64 x2 | ✅ placeholder | ✅ 연동 (스테이지별 미분기) |
| UI 요소 | 1종 | 160x64 (현재) | 혼합 | ✅ placeholder | ⚠️ 로드만, 미사용 |
| 캐릭터 초상화 | 8종 | 48x48 단일 | - | ❌ 미생성 | ❌ 코드 미구현 |

### 오디오 에셋

| 카테고리 | 수량 | 디스크 상태 | 코드 연동 |
|----------|------|------------|----------|
| 무기 SFX | 15종 | ✅ 15종 존재 | ✅ 연동 |
| 게임 SFX | 9종 | ✅ 9종 존재 | ✅ 연동 |
| 추가 SFX | 6종 | ❌ 6종 미생성 | ⚠️ 코드 참조만 |
| BGM | 9종 | ✅ 3종 / ❌ 6종 미생성 | ⚠️ 3종만 작동 |

### 요약 대시보드

```
이미지:  46/59 파일 존재 (placeholder) — 진화투사체 12종 + 초상화 8종 미생성 (-1은 맞게)
오디오:  27/30 SFX 존재 (6종 미생성), 3/9 BGM 존재 (6종 미생성)
코드:    보스 렌더링 미연결, 투사체 매핑 3종 누락, 타일 스테이지 분기 미구현
```

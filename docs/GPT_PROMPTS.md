# GPT 이미지 생성 프롬프트 — 복사-붙여넣기용

> **워크플로우**: GPT에 프롬프트 복사 → 생성된 PNG를 `tools/raw/` 에 저장 → sprite_cleanup.py 실행
> 
> 코드 요구사항: 플레이어 256x32(32x32×8), 적 128x32(32x32×4), 보스 256x64(64x64×4), 투사체 64x16(16x16×4)
> GPT는 64x64 레퍼런스 시트로 생성 → sprite_cleanup.py가 게임 포맷으로 변환

---

## 🔧 고정 베이스 프롬프트 (모든 에셋에 공통)

아래 베이스를 **항상 맨 위에** 붙이고, 그 아래에 캐릭터별 블록을 추가합니다.

```
STRICT SNES PIXEL ART SPRITE SHEET — DO NOT DEVIATE

Canvas & Layout:
- solid pure black background (#000000)
- developer reference sheet layout
- perfectly aligned grid
- each frame EXACTLY 64x64 pixels
- equal spacing between frames
- no overlap, no misalignment

Pixel Style (CRITICAL):
- true 16-bit SNES pixel art
- NO anti-aliasing, NO smoothing, NO gradients
- hard pixel edges only, visible square pixels
- 2~3 step shading only
- clean color clusters (no noise pixels)

Animation Rules:
- clear motion between frames (no duplicates)
- proper walk cycle (weight shift visible)
- consistent timing progression
- no missing frames
- consistent proportions across ALL frames (no deformation)
- same face, same head size, same eye position in every frame

Effects:
- pixel-based only (no glow, no blur)
- attack effect uses limited palette and hard edges

Text Labels:
- pixel font only, white color (#FFFFFF), aligned left of each row

FORBIDDEN:
- semi-realistic rendering, high resolution painting style
- soft shading, color banding gradients
- inconsistent proportions, blurry pixels

REFERENCE STYLE:
- classic SNES / GBA RPG sprite sheets
- same clarity and pixel discipline as commercial game assets

OUTPUT:
- must look like a commercial RPG sprite sheet
- must be production-ready
```

---

## 📋 레이아웃 블록 (타입별로 선택)

### 플레이어용 레이아웃
```
Animation Sheet Layout (MANDATORY):

LEFT SIDE:
Top:
Label "IDLE"
→ 4 frames horizontally (front view idle, subtle breathing 1px up/down)

Middle:
Label "WALK CYCLES"
→ "DOWN" → 4 frames (front-facing walk, this is the MAIN direction used in-game)
→ "LEFT" → 4 frames
→ "RIGHT" → 4 frames
→ "UP" → 4 frames

Bottom:
Label "CAST/ATTACK"
→ 4 frames horizontally (last frame includes pixelated effect ring)

RIGHT SIDE:
Label "WALK CYCLES"
→ Same 4 directions × 4 frames

Character Style:
- chibi SD proportions (large head ~60% of height, small body)
- max 12 colors
```

### 적용 레이아웃
```
Animation Sheet Layout (MANDATORY):

LEFT SIDE:
Label "IDLE"
→ 4 frames horizontally

RIGHT SIDE:
Label "WALK"
→ 4 frames horizontally

Character Style:
- chibi SD proportions, menacing but readable at small size
- max 10 colors
```

### 보스용 레이아웃
```
Animation Sheet Layout (MANDATORY):

LEFT SIDE:
Label "IDLE"
→ 4 frames horizontally (breathing/hover/sway)

RIGHT SIDE:
Label "ATTACK"
→ 4 frames horizontally (attack pose with pixelated effect)

Character Style:
- detailed boss-level visual impact
- max 16 colors
- imposing presence, fills most of the 64x64 frame
```

---

## ═══════════════════════════════════════════
## Phase 1: MVP (스테이지1 플레이 가능) — 8종
## ═══════════════════════════════════════════

---

### PC-01. 이태양 (퇴마사) — `player_lee_taeyang.png`

> 주인공. 조선시대 퇴마사. 귀신과 요괴를 물리치는 젊은 남성 퇴마 전문가.
> 부적을 무기로 사용하며, 정의감이 넘치고 결의에 찬 표정이 특징.
> 흰 도포에 검은 갓을 쓴 전형적인 조선 선비 차림이지만, 허리에 묶은 부적 주머니와
> 손에 든 빛나는 황금 부적이 퇴마사로서의 정체성을 드러냄.

**프롬프트**: 베이스 + 플레이어 레이아웃 + 아래

```
Character:
- Korean Joseon dynasty exorcist (퇴마사), young male protagonist
- Determined, righteous expression — eyebrows slightly furrowed, firm jaw
- Eyes: 2px wide (white + black pupil), showing resolve

HEAD:
- Black gat (갓): traditional Korean hat with wide circular brim and tall cylindrical crown
- Under the gat: black topknot hair (상투) peeking out at sides
- The gat is THE defining silhouette feature — must be prominent

UPPER BODY:
- White dopo (도포): traditional overcoat with wide V-neck collar
- Sleeves are wide and flowing, reaching past the wrists
- Navy blue (#1D3557) belt/sash tied at waist, ends dangling
- One small red (#E63946) talisman symbol embroidered on chest (2x2px)

LOWER BODY:
- White pants (바지), loose fitting
- Navy blue (#1D3557) trim at ankle hem
- Black shoes (흑혜)

ACCESSORIES:
- Right hand holding a glowing golden (#FFD166) talisman paper (부적)
- The talisman has a faint sparkle effect in idle animation

COLOR PALETTE (max 12):
- White (#F0EEE6) — dopo, pants
- Navy (#1D3557) — belt, trim
- Gat dark brown (#322519) — hat
- Black (#1A1A2E) — hair, shoes, outline
- Gold (#FFD166) — talisman glow
- Red (#E63946) — chest symbol
- Skin (#EBC8A0, #C8A582) — face, hands

FRAME-BY-FRAME (IDLE):
- idle0: Standing straight, talisman held at chest height in right hand, slight sparkle on talisman
- idle1: Body shifts 1px UP (inhale), talisman sparkle moves
- idle2: Returns to base position
- idle3: Body shifts 1px DOWN (exhale), talisman sparkle dims

FRAME-BY-FRAME (WALK — front-facing "DOWN"):
- walk0: Right foot forward, left foot back. Arms swing opposite to legs. Dopo sleeves sway right
- walk1: Feet together (passing position). Body 1px UP. Dopo settles
- walk2: Left foot forward, right foot back. Arms swing opposite. Dopo sleeves sway left
- walk3: Feet together. Body 1px UP. Dopo settles

CAST/ATTACK:
- cast0: Wind-up — pulls talisman back behind shoulder
- cast1: Forward thrust — arm extends, talisman flies forward
- cast2: Follow-through — arm fully extended, golden energy trail
- cast3: Recovery + golden holy ring effect (원형 파동) expanding outward from hand
```

**후처리:**
```bash
python tools/sprite_cleanup.py tools/raw/players/lee_taeyang_raw.png \
  -o assets/images/player_lee_taeyang.png --type player --reference --debug
```

---

### PC-02. 월희 (무녀) — `player_wolhui.png`

> 신비로운 무녀(巫女). 신과 소통하는 영매이자 퇴마 동료.
> 방울을 흔들어 성스러운 음파로 요괴를 정화하는 원거리 딜러.
> 길고 곧은 흑발에 무녀 머리띠, 붉은 저고리에 흰 치마의 전통 무녀복 차림.
> 우아하면서도 신성한 분위기. 양손의 금색 방울이 상징적 소품.

**프롬프트**: 베이스 + 플레이어 레이아웃 + 아래

```
Character:
- Korean shrine maiden (무녀), female, spiritual healer
- Elegant and mystical expression — half-moon shaped eyes, calm gentle smile
- Small red lips (1px)
- Graceful, flowing movement style

HEAD:
- Long straight black hair flowing down to lower back, slight wave at ends
- White cloth headband (무녀 머리띠) tied across forehead
- One small golden bell ornament dangling from the headband center
- Hair sways gently during walk animation

UPPER BODY:
- Red (#D4483B) jeogori (저고리, Korean jacket)
- White goreum (고름, ribbon ties) at chest
- Wide elegant sleeves that billow when walking
- Blue (#3366AA) bead necklace visible at neckline

LOWER BODY:
- White chima (치마, long skirt) flowing to ankles
- Red (#D4483B) trim at skirt hem
- Red waist sash (허리띠)
- White beoseon socks (버선) and straw sandals

ACCESSORIES:
- BOTH hands each holding a golden (#FFD166) ritual bell (방울)
- Bells have small handles and round bodies
- Bells produce tiny pixel sparkle particles during animation

COLOR PALETTE (max 12):
- Red (#D4483B) — jeogori, trim, sash
- White (#F0EEE6) — headband, chima, goreum
- Black (#1A1A2E) — hair, outline
- Gold (#FFD166) — bells, headband ornament
- Blue (#3366AA) — bead necklace
- Skin (#EBC8A0, #C8A582) — face, hands

FRAME-BY-FRAME (IDLE):
- idle0: Standing gracefully, bells held at waist height, hair still
- idle1: 1px UP, hair sways slightly left, bells tilt
- idle2: Return to base, hair settles
- idle3: 1px DOWN, hair sways slightly right, bells tilt other way

FRAME-BY-FRAME (WALK):
- walk0: Right foot peeks from under skirt, skirt sways right, hair flows left
- walk1: Passing position, body 1px UP, skirt settles, hair centered
- walk2: Left foot peeks, skirt sways left, hair flows right
- walk3: Passing position, body 1px UP, skirt and hair settle

CAST/ATTACK:
- cast0: Raises both bells above head
- cast1: Shakes bells outward to sides — small pixel sparkles appear
- cast2: Bells swing forward, blue-gold sound wave rings emanate
- cast3: Holy ring of purifying light (청백색 원형 파동) expands, bells return to rest
```

**후처리:**
```bash
python tools/sprite_cleanup.py tools/raw/players/wolhui_raw.png \
  -o assets/images/player_wolhui.png --type player --reference --debug
```

---

### EN-01. 잡귀 (雜鬼) — `enemy_jabgwi.png`

> 가장 약한 잡몹. 이승을 떠돌지 못한 미약한 잡귀.
> 실체가 거의 없어 하체가 연기처럼 흐릿하게 사라지며, 둥근 머리에 흰 점 눈만 있는 단순한 형태.
> 위협적이지 않고 불쌍해 보이기까지 하는, 가장 기본적인 원혼.
> 무리 지어 나타나지만 한 방에 죽는 캐논포더.

**프롬프트**: 베이스 + 적 레이아웃 + 아래

```
Monster:
- Tiny Korean wandering ghost (잡귀), the weakest fodder enemy
- Pathetically weak, almost pitiable — NOT scary, just sad
- Very simple design, minimal detail

SHAPE:
- Small 20x24px silhouette within 64x64 frame (lots of empty space around)
- Round blobby head on top (about 12px diameter)
- Body tapers down from head, becoming wispy smoke
- Lower half completely dissolves into transparent smoke/mist
- NO legs, NO arms — just a head trailing into vapor

FACE:
- Two small white dot eyes (2px each), slightly uneven height for personality
- No mouth, or just a tiny dark dot
- Eyes have a dim, vacant stare

BODY:
- Upper portion: semi-solid grey, you can see the round shape
- Mid portion: becoming translucent, edges breaking into wisps
- Lower portion: smoke tendrils, almost fully transparent
- Slight transparency gradient from top (80% opacity) to bottom (20% opacity)

COLOR PALETTE (max 6):
- Light grey (#C8C8DC) — head, upper body
- Medium grey (#9898AC) — shading, mid body
- Dark grey (#6868780) — deep shadow
- White (#FFFFFF) — eyes
- Black (#1A1A2E) — outline

ANIMATION (floating/bobbing):
- frame0: Neutral position, leaning slightly left, smoke tail center
- frame1: Floats 1px UP, smoke tail swings right
- frame2: Neutral position, leaning slightly right, smoke tail center
- frame3: Sinks 1px DOWN, smoke tail swings left
- Movement should feel like drifting aimlessly, no purpose
```

**후처리:**
```bash
python tools/sprite_cleanup.py tools/raw/enemies/jabgwi_raw.png \
  -o assets/images/enemy_jabgwi.png --type enemy --reference --debug
```

---

### EN-02. 도깨비졸 (兵卒) — `enemy_dokkaebi_jol.png`

> 도깨비 대장의 졸개 병사. 한국 전통 도깨비의 하급 전투원.
> 작고 녹색 피부에 뿔 하나, 호피 허리감개를 두르고 나무 방망이를 든 장난꾸러기.
> 도깨비 특유의 장난스럽고 공격적인 성격이 표정에 드러남.
> 무리 지어 돌진하며, 도깨비 대장 보스의 소환 스킬로도 등장.

**프롬프트**: 베이스 + 적 레이아웃 + 아래

```
Monster:
- Small Korean dokkaebi goblin foot soldier (도깨비졸)
- Mischievous, aggressive personality — troublemaker energy
- Compact, energetic little warrior

SHAPE:
- 22x26px silhouette, stocky and round
- Humanoid but cartoonish, stubby proportions

HEAD:
- Round green face with ONE short brown horn on top center of head
- Big round yellow eyes (노란 동공) with excited/aggressive look
- Wide grin stretching across face, showing 2 prominent white fangs
- No nose, or just a tiny bump
- Expressive eyebrows (angry/eager)

BODY:
- Green (#4A8C3F) skin, muscular but small — like a green gnome
- Bare-chested showing round green belly
- Tiger-print (#FFD166 yellow / #8B6914 brown stripe) loincloth around waist
- Short stubby arms and legs, 3-fingered hands

WEAPON:
- Right hand gripping a small wooden club (방망이)
- Club is brown (#755540), simple round-ended stick
- Holds it over shoulder in idle, swings it while walking

COLOR PALETTE (max 10):
- Green skin (#4A8C3F, #2D5A27) — body, shading
- Brown (#755540, #4B3728) — horn, club
- Yellow-brown (#FFD166, #8B6914) — tiger print
- White (#FFFFFF) — fangs, eye whites
- Yellow (#FFD166) — pupils
- Black (#1A1A2E) — outline

ANIMATION (aggressive march):
- frame0: Standing with club on right shoulder, left foot forward, mouth grinning
- frame1: Mid-step, body bounces 1px UP, club sways back
- frame2: Right foot forward, club swings slightly forward, horn bobs
- frame3: Mid-step, body bounces 1px UP, club returns to shoulder
- Walk should feel bouncy and energetic, like an eager little warrior
```

**후처리:**
```bash
python tools/sprite_cleanup.py tools/raw/enemies/dokkaebi_jol_raw.png \
  -o assets/images/enemy_dokkaebi_jol.png --type enemy --reference --debug
```

---

### EN-03. 처녀귀신 — `enemy_cheonyeo_gwisin.png`

> 한국 공포의 대표 아이콘. 한을 품고 죽은 처녀의 원혼.
> 흰 소복(장례복)을 입고, 극도로 긴 검은 머리카락이 얼굴 전체를 가림.
> 머리카락 사이로 겨우 보이는 빨간 눈 하나가 섬뜩함의 핵심.
> 느리지만 고데미지, 수(水) 속성. 떠다니듯 미끄러지며 접근.

**프롬프트**: 베이스 + 적 레이아웃 + 아래

```
Monster:
- Korean virgin ghost (처녀귀신), classic Korean horror icon
- Eerie, unsettling, tragic — moves like she's gliding on air
- The hair IS the character — it dominates the silhouette

SHAPE:
- Tall and thin: 18x28px silhouette (narrow, elongated)
- Upper body somewhat visible, lower body dissolves into mist
- Hair creates a curtain-like drape over the entire front

HEAD & HAIR:
- Extremely long straight BLACK hair, falls from top of head all the way past feet
- Hair completely covers the face — NO facial features visible except one eye
- ONE glowing red (#E63946) eye barely visible through a gap in the hair (just 1px red dot)
- The eye is the focal point of horror — a single red pixel peering through darkness
- Hair strands hang in parallel lines, slightly uneven

BODY:
- White funeral clothes (소복, sobok) — #E8E8F0
- The sobok is a simple white robe/dress, traditional Korean mourning wear
- Clothes billow at the edges as if blown by an unseen wind
- Lower body: dress hem dissolves into translucent mist/vapor
- She does NOT walk — she floats. No visible feet.

EFFECTS:
- 1-2px faint blue-white aura around the body
- Subtle cold mist particles near the bottom

COLOR PALETTE (max 8):
- White (#E8E8F0) — sobok dress
- Black (#1A1A2E, #2D2D44) — hair (2 shades for depth)
- Red (#E63946) — single eye glow
- Pale blue (#88CCEE) — aura, mist
- Grey (#9898AC) — hair highlight, shadow
- Black (#1A1A2E) — outline

ANIMATION (ghostly float):
- frame0: Floating straight, hair hangs still, red eye visible in center-left gap
- frame1: Drifts 1px UP, hair sways slightly left, red eye shifts
- frame2: At peak height, hair swings right, sobok hem ripples
- frame3: Sinks 1px DOWN, hair settles, mist particles appear below
- Movement should feel SLOW, deliberate, creepy — NOT bouncy
```

**후처리:**
```bash
python tools/sprite_cleanup.py tools/raw/enemies/cheonyeo_gwisin_raw.png \
  -o assets/images/enemy_cheonyeo_gwisin.png --type enemy --reference --debug
```

---

### PJ-01. 퇴마부적 투사체 — `proj_bujeok.png`

> 이태양의 시작 무기. 불타는 황금 부적이 회전하며 날아감.

```
STRICT SNES PIXEL ART — DO NOT DEVIATE

Canvas: 256x64 PNG, solid black background (#000000)
Layout: 4 frames in a single horizontal row, each exactly 64x64
NO labels, NO borders, NO grid lines — game atlas strip only

Projectile:
- Small rectangular Korean exorcism talisman paper (퇴마부적)
- Bright yellow-gold (#FFD166) paper, about 8x12px within frame
- Red (#E63946) mystical writing/symbols on the paper face (한자 or 부적 문양)
- Spinning rotation as it flies through air
- Golden aura glow: 1-2px pixel halo around the paper
- Frame 1: talisman facing front (full rectangle visible, red writing shown)
- Frame 2: rotated 90° (thin side view, just a line)
- Frame 3: rotated 180° (back side, plain gold)
- Frame 4: rotated 270° (thin side again, opposite direction)
- Max 6 colors: gold, red, white spark, dark outline
- 16-bit pixel art, hard edges, transparent background
```

**후처리:**
```bash
python tools/sprite_cleanup.py tools/raw/projectiles/bujeok_raw.png \
  -o assets/images/proj_bujeok.png --type projectile --debug
```

---

### PJ-03. 신성 방울 투사체 — `proj_bangul.png`

> 월희의 시작 무기. 금색 방울에서 파란 음파 링이 퍼져나감.

```
STRICT SNES PIXEL ART — DO NOT DEVIATE

Canvas: 256x64 PNG, solid black background (#000000)
Layout: 4 frames in a single horizontal row, each exactly 64x64
NO labels, NO borders, NO grid lines — game atlas strip only

Projectile:
- Small golden (#FFD166) Korean sacred ritual bell (방울)
- Round bell body (6x6px) with small loop handle on top
- Blue (#88CCEE) sound wave rings expanding outward
- Frame 1: bell center, first small ring close to bell
- Frame 2: bell center, ring expanded to 12px radius
- Frame 3: bell center, ring at 20px radius, second small ring appears
- Frame 4: first ring at edge fading, second ring mid-size
- Max 6 colors: gold bell, blue rings, white highlight
- 16-bit pixel art, hard edges
```

**후처리:**
```bash
python tools/sprite_cleanup.py tools/raw/projectiles/bangul_raw.png \
  -o assets/images/proj_bangul.png --type projectile --debug
```

---

### ITEM-01. 경험치 기운 — `exp_gems.png`

> 적 처치 시 드롭되는 경험치 구슬. 3단계 티어 (소/중/대).

```
STRICT SNES PIXEL ART — DO NOT DEVIATE

Canvas: 768x64 PNG, solid black background (#000000)
Layout: 12 frames in a single horizontal row, each exactly 64x64
NO labels, NO borders — game atlas strip only

Experience Gem Orbs (3 tiers × 4 animation frames):

TIER 0 — Small Blue Orb (frames 1-4):
- Tiny blue (#3366AA) crystal orb, 8x8px in center of frame
- Simple round gem shape, dim glow
- Frame 1: base shine (small white pixel at top-left)
- Frame 2: shine pixel moves to top-right
- Frame 3: shine pixel moves to bottom-right, faint sparkle
- Frame 4: shine pixel moves to bottom-left, sparkle fades

TIER 1 — Medium Green Orb (frames 5-8):
- Medium green (#4A8C3F) crystal orb, 10x10px in center
- Brighter than tier 0, visible inner light core (lighter green center)
- Frame 5-8: same shine rotation but with pulsing core (core brightens/dims)

TIER 2 — Large Golden Orb (frames 9-12):
- Large golden (#FFD166) crystal orb, 12x12px in center
- Radiant, impressive, bright white core
- Frame 9-12: shine rotation + golden rays (1px lines radiating outward, appear/disappear)

16-bit pixel art style, max 8 colors per tier.
```

**후처리:**
```bash
python tools/sprite_cleanup.py tools/raw/items/exp_gems_raw.png \
  -o assets/images/exp_gems.png --type item --debug
```

---

### TILE-01. 대나무 숲 배경 — `tiles.png`

> 스테이지 1 배경. 어두운 대나무 숲 바닥. 반복 배치(타일링)되므로 이음새 없어야 함.

```
STRICT SNES PIXEL ART — DO NOT DEVIATE

Canvas: 128x64 PNG
Layout: 2 tiles side by side, each exactly 64x64
NO labels, NO borders

Ground Tiles for Korean bamboo forest (top-down 3/4 view):
- Tile 1: dark green grass base, scattered bamboo shadow strips (vertical dark lines),
  small green sprouts, occasional fallen bamboo leaf (yellow-green)
- Tile 2: similar grass base but with small grey pebbles and tiny pink wild flowers,
  slightly different grass pattern

CRITICAL — TILEABLE:
- All 4 edges must connect seamlessly when tiles are placed adjacent
- Pattern should not be too repetitive or too busy (subtle variation)

COLOR PALETTE:
- Dark green (#2D5A27) — base grass
- Medium green (#4A8C3F) — grass highlights, sprouts
- Deep green (#1A3A18) — bamboo shadows
- Grey-brown (#8B6914) — pebbles
- Yellow-green (#A8E6A3) — fallen leaves
- Pink (#FF9B7A) — tiny flowers (tile 2 only)

16-bit SNES style, max 12 colors total.
```

**후처리:**
```bash
python tools/sprite_cleanup.py tools/raw/tiles/bamboo_raw.png \
  -o assets/images/tiles.png --type tile --debug
```

---

## ═══════════════════════════════════════════
## Phase 2: 전투 확장 — 적 7종 + 보스 2종 + 투사체 6종 + 상자
## ═══════════════════════════════════════════

---

### EN-04. 해태 석상 — `enemy_haetae.png`

> 경복궁 앞을 지키는 상상의 수호수 해태(獬豸)가 움직이기 시작한 석상.
> 돌로 만들어진 사자+기린 혼합 외형. 극도로 느리지만(속도 30) 체력이 매우 높음(HP 35).
> 토(土) 속성. 돌 균열 텍스처와 이끼가 핵심 비주얼.
> 네모지고 묵직한 실루엣으로 "탱크형 잡몹" 느낌.

**프롬프트**: 베이스 + 적 레이아웃 + 아래

```
Monster:
- Korean haetae (해태) stone statue come to life
- Ancient stone guardian beast, heavy and immovable
- NOT cute — weathered, cracked, ancient, heavy

SHAPE:
- Blocky, square-ish silhouette: 26x26px (wide and heavy)
- Four short thick legs, like stone pillars
- Dense, compact body — feels like it weighs a ton

HEAD:
- Stone lion face with a flat broad nose
- Round simple eyes (carved stone look, not expressive)
- Stone mane/ruff around head (carved wavy lines)
- One small stone horn on forehead
- Closed mouth with slight underbite

BODY:
- Cracked stone texture: base color stone brown (#B08C64) with darker crack lines (#8B6914)
- Random patches of GREEN moss (#4A8C3F) growing in crevices (2-3 patches)
- Stubby thick tail, also stone
- Legs are thick rectangles, barely articulated

COLOR PALETTE (max 10):
- Stone light (#B08C64) — base body
- Stone dark (#8B6914) — cracks, shading
- Stone shadow (#5C4A12) — deep cracks
- Moss green (#4A8C3F) — moss patches
- Dark green (#2D5A27) — moss shadow
- Black (#1A1A2E) — outline, deepest cracks

ANIMATION (slow rocky waddle):
- frame0: Standing square, all 4 legs planted, head slightly left
- frame1: Right legs lift barely 1px, body rocks right, stone dust pixel falls
- frame2: Standing square, head slightly right, settle back
- frame3: Left legs lift 1px, body rocks left, stone dust pixel
- Movement should feel HEAVY and GRINDING — like stone scraping stone
```

---

### EN-05. 불여우 — `enemy_bulyeou.png`

> 불을 품은 세 꼬리 여우. 구미호의 하위 버전이자 화(火) 속성 적.
> 가장 빠른 적 중 하나(속도 100). 날렵하고 공격적.
> 세 개의 불꽃 꼬리가 트레이드마크. 붉은 모피에 주황 배.
> 빠르게 달려와 물어뜯는 근접 공격형.

**프롬프트**: 베이스 + 적 레이아웃 + 아래

```
Monster:
- Korean fire fox (불여우) with THREE flaming tails
- Sleek, fast, aggressive — a predator mid-hunt
- Fox anatomy: elongated body, pointed snout, lean build

SHAPE:
- Horizontal silhouette: 24x20px (wider than tall, four-legged)
- Lean and aerodynamic, built for speed

HEAD:
- Pointed fox snout, sharp and angular
- Two pointed ears standing up alert
- Sharp yellow eyes with slit pupils — predatory gaze
- Small black nose at tip of snout
- Mouth slightly open, one tiny fang visible

BODY:
- Main body: red (#D4483B) sleek fur
- Belly/underside: lighter orange (#FF9B7A)
- Slim, muscular build — you can sense the speed

TAILS (KEY FEATURE):
- THREE tails fanning out behind
- Each tail: red base transitioning to orange, tips are yellow (#FFD166) flame
- Tails should look like actual fire at the tips — flickering pixel flames
- Tails sway independently during animation

LEGS:
- Four thin agile legs, dark red/brown paws
- Running pose with legs extended

COLOR PALETTE (max 10):
- Red (#D4483B) — main fur
- Orange (#FF9B7A) — belly, mid-tail
- Yellow (#FFD166) — flame tips
- Black (#1A1A2E) — nose, pupils, outline
- Dark red (#8B1A1A) — paw, shadow

ANIMATION (fast sprint):
- frame0: Full gallop stretch — front legs forward, back legs behind, tails streaming back
- frame1: Legs tucked under body (bound position), body compressed, tails whip up
- frame2: Opposite stretch — back legs push off, front legs reach, tails stream
- frame3: Tucked again, opposite phase, flame tips flicker differently
- Must look FAST — exaggerated stretch/compress cycle
```

---

### EN-06. 갑옷 귀신 — `enemy_gapot_gwisin.png`

> 전장에서 죽은 병사의 혼이 깃든 빈 갑옷. 갑옷만 혼자 움직임.
> 금(金) 속성. 극도로 느리지만(속도 25) 체력 최상위(HP 50), 고데미지(DMG 7).
> 녹슨 조선시대 갑옷에서 푸른 유령불이 새어나오는 것이 핵심 비주얼.
> 투구 안에 얼굴 없이 푸른 불빛 눈만 보이는 공포 연출.

**프롬프트**: 베이스 + 적 레이아웃 + 아래

```
Monster:
- Korean haunted armor (갑옷 귀신) — an empty suit of armor possessed by a ghost
- NO person inside — the armor moves on its own
- Creepy, imposing, rusty, ancient military relic

SHAPE:
- Large silhouette: 26x28px (tall and broad-shouldered)
- Classic Korean warrior armor shape but weathered and decrepit

HEAD:
- Joseon military helmet (투구): bowl-shaped with neck guard
- The helmet is EMPTY inside — only darkness within
- TWO glowing blue (#5599DD) ghost fire eyes floating inside the dark helmet void
- No face, no skin — just blue fire where eyes should be

BODY:
- Full Joseon dynasty armor set, heavily RUSTED
- Chest plate: large square/rectangular, brown-grey rust (#8B6914 + #4A4A5A mixed)
- Shoulder guards on both sides, also rusted
- Arm guards, gauntlets — all corroded
- BLUE ghost energy (#5599DD) visibly seeping through gaps between armor pieces
  (at joints, between plates, through cracks)

WEAPON:
- One rusted sword in right hand, blade is dark and pitted
- Sword held at side, slightly forward

LEGS:
- Armored leg guards, rusted
- Heavy armored boots, barely lifting off ground

COLOR PALETTE (max 10):
- Rusty brown (#8B6914) — primary armor color
- Dark grey (#4A4A5A) — secondary armor, deep rust
- Metallic dark (#2D2D3A) — deepest shadows
- Ghost blue (#5599DD) — eye fire, energy seepage
- Light blue (#88CCEE) — ghost fire highlights
- Black (#1A1A2E) — helmet void, outline

ANIMATION (heavy, lurching walk):
- frame0: Standing, both feet planted, sword at side, blue eyes steady
- frame1: Right leg drags forward 1px, armor creaks (body tilts 1px right), ghost fire flickers
- frame2: Weight shifts, left leg drags, body tilts left, blue energy pulses from chest gap
- frame3: Settling step, armor pieces rattle (shoulder guards shift 1px), eyes flare brighter
- Must feel MECHANICAL, STIFF, HEAVY — like rusted metal grinding
```

---

### EN-07. 야차 (夜叉) — `enemy_yacha.png`

> 한국 불교 설화의 사나운 야차 악귀. 붉은 피부의 거대한 도깨비/오우거.
> 화(火) 속성 고데미지 적(DMG 10). 뿔 2개, 송곳니 4개의 위협적 외형.
> 도깨비졸의 상위 호환. 분노에 찬 전투 본능만 남은 존재.
> 불꽃 주먹으로 맨손 격투하는 근접 파이터.

**프롬프트**: 베이스 + 적 레이아웃 + 아래

```
Monster:
- Korean yaksha demon (야차), a raging fire ogre
- ANGRY, VIOLENT, POWERFUL — pure aggression incarnate
- Much larger and more threatening than the dokkaebi soldier

SHAPE:
- Big threatening silhouette: 24x28px (tall, muscular)
- Top-heavy build — huge upper body, proportionally smaller legs

HEAD:
- Red (#D4483B) skin, fierce angular face
- TWO large curved dark horns sweeping backward
- Fierce yellow eyes (#FFD166) with angry brow ridge, eyes are sharp and slanted
- Huge mouth with FOUR prominent white fangs (2 upper, 2 lower)
- Wild black hair rising up like flames behind the head

BODY:
- Massively muscular red upper body — visible chest and arm muscles
- Black (#1A1A2E) tattoo/tribal markings across chest and arms (war paint patterns)
- Tiger-print (#FFD166/#8B6914) loincloth at waist
- Bare red skin everywhere else — this is a savage berserker

FISTS:
- Both fists clenched and wreathed in pixel fire
- Flames around fists: orange (#FF9B7A) → yellow (#FFD166) tips
- Fists are large (exaggerated for punching power)

LEGS:
- Thick red legs, bare feet, spread in aggressive stance
- Toes gripping the ground

COLOR PALETTE (max 10):
- Red skin (#D4483B, #8B1A1A) — body, shading
- Black (#1A1A2E) — horns, tattoos, hair, outline
- Yellow (#FFD166) — eyes, tiger print, flame tips
- Orange (#FF9B7A) — fist flames
- Brown (#8B6914) — tiger print dark
- White (#FFFFFF) — fangs

ANIMATION (aggressive stomping march):
- frame0: Power stance, fists up and flaming, chest puffed, mouth snarling
- frame1: Left foot stomps forward, body lurches, fist flames flare, head dips aggressively
- frame2: Right fist pumps forward (punching air), body shifts forward, flames trail
- frame3: Right foot stomps, body rocks back to stance, flames resettle
- Must feel HEAVY and ANGRY — each step is a threatening stomp
```

---

### EN-08. 구렁이 (大蛇) — `enemy_gureongi.png`

> 이무기에 가까운 거대한 푸른 뱀. 수(水) 속성.
> 용이 되지 못한 천년 묵은 대사(大蛇). 용의 수염이 있는 것이 특징.
> S자 곡선으로 미끄러지듯 이동. 가로로 긴 독특한 실루엣.
> 중간 정도의 속도와 체력, 무리로 나오면 화면을 가득 채움.

**프롬프트**: 베이스 + 적 레이아웃 + 아래

```
Monster:
- Korean great serpent (구렁이/이무기), a pre-dragon ancient snake
- Majestic yet dangerous — this is a creature that ALMOST became a dragon
- Serpentine, flowing, sinuous movement

SHAPE:
- Horizontal elongated: 28x20px (very wide, snake-shaped)
- Classic S-curve body from left to right
- No legs — pure snake body

HEAD:
- Triangular snake head, slightly wider than neck
- Two yellow eyes with vertical slit pupils — cold, calculating reptile gaze
- Forked red tongue (1px, flickering out of mouth)
- Small whisker/barbel on each side of snout (dragon ancestry, distinguishes from plain snake)
- Slight hood/frill behind head

BODY:
- Long S-curved body with visible SCALES
- Top/sides: blue (#3366AA) scales with subtle pattern
- Belly/underside: lighter blue (#88CCEE)
- Body thickness: about 6-8px, consistent along length
- Tail tapers to a thin point at the end

COLOR PALETTE (max 8):
- Blue (#3366AA) — main scales
- Light blue (#88CCEE) — belly scales
- Dark blue (#1A3A5C) — scale shadows, pattern
- Yellow (#FFD166) — eyes
- Red (#E63946) — tongue
- Black (#1A1A2E) — outline, pupils

ANIMATION (slithering):
- frame0: S-curve standard, head pointing right, tongue out
- frame1: S-curve shifts — the curves move backward along body (wave motion), tongue in
- frame2: S-curve shifted more, head dips slightly, tongue out again
- frame3: S-curve completes one cycle, head rises, tongue in
- Movement = the S-wave propagates along the body, head stays relatively stable
```

---

### EN-09. 날쌘돌이 — `enemy_nalssaen.png`

> 가장 작고 가장 빠른 적(속도 130). 체력은 바닥(HP 8).
> 작고 밝은 녹색의 초소형 도깨비. 눈이 비정상적으로 크고 씩 웃는 장난꾸러기.
> 다리가 몸 대비 과장되게 길어서 빠른 속도를 시각적으로 표현.
> 뒤에 속도선/먼지가 남는 것이 특징.

**프롬프트**: 베이스 + 적 레이아웃 + 아래

```
Monster:
- Tiny hyperfast Korean goblin imp (날쌘돌이)
- Comically fast, annoyingly small — a speed gremlin
- The SMALLEST enemy, easily missed if not for its speed

SHAPE:
- Tiny silhouette: 16x20px (the smallest in the game)
- Head is 50% of total height — extreme chibi proportions
- Body is just a small blob under the huge head
- Legs are disproportionately LONG for the body (designed for speed)

HEAD:
- Round head, bright green (#7BC96F) skin
- OVERSIZED round eyes — each eye is 3x3px, almost filling the face
- White eyes with big black pupils, giving a hyperactive/crazy look
- ONE tiny horn on top (barely 2px tall)
- Wide Cheshire-cat grin stretching ear to ear, mischievous

BODY:
- Tiny bright green torso, barely visible under the head
- A dark green leaf loincloth (나뭇잎 허리감개) — just 2-3 dark pixels
- Thin arms, barely there

LEGS:
- Long thin legs (longer than the entire torso)
- Designed to convey "this thing is FAST"
- Feet are small, always in exaggerated running stride

EFFECTS:
- Speed lines: 1-2px white/grey horizontal dashes behind the body
- Dust puff: tiny grey pixels at feet (1-2px)

COLOR PALETTE (max 8):
- Bright green (#7BC96F) — skin
- Dark green (#2D5A27) — leaf, shadow
- White (#FFFFFF) — eyes, speed lines
- Black (#1A1A2E) — pupils, outline, grin
- Grey (#9898AC) — dust, speed lines

ANIMATION (frantic sprint):
- frame0: Full sprint stretch — legs split wide apart, body tilted forward, speed lines long
- frame1: Legs cross under body (tuck), body pops 2px UP (bouncing run), dust puff
- frame2: Opposite leg split, body tilted, speed lines shift
- frame3: Legs tuck again, body pops UP, different dust puff pattern
- Must look FRANTIC and COMICAL — like Looney Tunes running
```

---

### EN-10. 강시 (殭屍) — `enemy_gangsi.png`

> 중국계 좀비 "강시"의 한국식 해석. 토(土) 속성.
> 게임 내 최고 체력(HP 60) + 고데미지(DMG 10)의 엘리트 잡몹.
> 특유의 양팔 앞으로 뻗기 + 깡충깡충 점프 이동이 핵심 비주얼.
> 이마에 붙은 황색 부적이 트레이드마크. 조선 관복 차림.

**프롬프트**: 베이스 + 적 레이아웃 + 아래

```
Monster:
- Korean gangsi (강시), a hopping vampire/zombie (jiangshi Korean version)
- Stiff, rigid, undead — moves by HOPPING, arms stretched forward
- The most elite regular enemy — imposing and dangerous

SHAPE:
- Tall silhouette: 22x28px (upright, rigid posture)
- Perfectly stiff vertical posture — no slouching, no bending
- Arms permanently stretched straight forward (the iconic gangsi pose)

HEAD:
- Wears a traditional square official hat (관모/사모)
- YELLOW talisman paper (부적) stuck on forehead — dangling down over face
- The talisman is THE iconic feature — a rectangular yellow strip
- Skin: pale sickly green (#88A088) — undead complexion
- Eyes closed (dead), mouth slightly open showing 2 small fangs
- Rigid, expressionless face

BODY:
- Dark blue (#1D3557) Joseon official court robes (관복)
- Gold (#FFD166) button details and trim lines on the robe
- Robe is formal and symmetrical — this was once a dignified official
- Arms: stretched straight forward at shoulder height, stiff as boards
- Fingers rigid, slightly curled (rigor mortis)

LEGS:
- Hidden under long robe, but feet visible
- Legs are TOGETHER — gangsi don't walk, they HOP
- Traditional black shoes peek under robe hem

COLOR PALETTE (max 10):
- Pale green (#88A088) — skin
- Dark blue (#1D3557) — robes
- Gold (#FFD166) — trim, buttons, talisman
- Yellow (#F5E6C8) — talisman paper
- Black (#1A1A2E) — hat, shoes, outline
- White (#E8E8F0) — fang, eye whites

ANIMATION (hopping — UNIQUE):
- frame0: LANDING — feet on ground, body straight, arms forward, talisman hangs still
- frame1: CROUCH — body compresses 1px DOWN (preparing to jump), knees bend under robe
- frame2: JUMP — body shoots 3px UP, feet leave ground, robe flares slightly, talisman flutters
- frame3: AIRBORNE — still 2px UP but descending, robe settling, talisman swings
- This is NOT a walk cycle — it's a HOP cycle. Feet never alternate.
```

---

### BOSS-01. 도깨비 대장 — `boss_dokkaebi.png`

> 스테이지 1 보스. 도깨비졸들의 왕. 목(木) 속성.
> 졸개를 거대하고 위엄있게 확대한 느낌. 거대한 금색 도깨비 방망이가 핵심.
> 방망이를 360도 회전시키고, 졸개를 소환하며, 광폭화하는 패턴.
> 졸개의 장난스러움과 달리 왕답게 위엄있고 강력한 분위기.

**프롬프트**: 베이스 + 보스 레이아웃 + 아래

```
Boss:
- Korean dokkaebi king (도깨비 대장), the goblin overlord
- MASSIVE, POWERFUL, REGAL — the undisputed king of all goblins
- Same species as the small dokkaebi soldier but 3x the size and infinitely more imposing
- Fills nearly the entire 64x64 frame (54x58px silhouette)

HEAD:
- Large red (#D4483B) face, broader and more angular than the soldiers
- TWO LARGE curved horns (not one small one) — each adorned with a gold (#FFD166) ring
- Fierce, commanding yellow eyes — not mischievous like soldiers, but ROYAL AUTHORITY
- Gold teeth visible in a confident snarl (not a playful grin)
- Wild black mane/hair that rises like dark flames — a fiery crown of darkness
- Thick jaw, prominent brow ridge

BODY:
- Enormous muscular red torso — this is a warrior king
- Tiger-print ARMOR (not just a loincloth) — full chest piece with gold rivets
- Large gold (#FFD166) medallion/emblem on center of chest — royal crest
- Broad powerful shoulders, thick arms
- The sheer size difference from the soldier should be immediately apparent

WEAPON (KEY FEATURE):
- RIGHT hand gripping a MASSIVE golden magic club (도깨비 방망이)
- The club is nearly as tall as he is — oversized, legendary weapon
- Club head is large and rounded with golden glow
- Tiny golden particle/sparkle pixels around the club (magic energy)

LEGS:
- Tiger-print pants, thick powerful legs
- Large dark boots/foot wraps

COLOR PALETTE (max 16):
- Red skin (#D4483B, #8B1A1A) — body
- Gold (#FFD166) — club, rings, medallion, teeth, trim
- Black (#1A1A2E) — hair, horns, outline
- Tiger yellow (#FFD166) / brown (#8B6914) — armor print
- Dark red (#5C0E0E) — deep shadows

ANIMATION:
IDLE (4 frames):
- idle0: Standing tall, club resting on right shoulder, chin up, dominant pose
- idle1: Chest expands 1px (power breath), club glows slightly brighter, hair sways
- idle2: Returns to base, medallion catches light (white pixel flash)
- idle3: Slight lean forward 1px, club shifts, intimidation micro-gesture

ATTACK (4 frames):
- attack0: Raises club high overhead with both hands, muscles tense
- attack1: Swinging club down in an arc, golden trail behind club head
- attack2: Club SLAMS down, impact shockwave (gold pixel ring on ground), screen-shake implied
- attack3: Recovery, pulls club back to shoulder, dust/debris pixels settle
```

**후처리:**
```bash
python tools/sprite_cleanup.py tools/raw/bosses/dokkaebi_raw.png \
  -o assets/images/boss_dokkaebi.png --type boss --reference --debug
```

---

### BOSS-02. 구미호 (九尾狐) — `boss_gumiho.png`

> 스테이지 2 보스. 천년 묵은 아홉 꼬리 여우 요괴. 화(火) 속성.
> 상반신은 아름다운 여인, 하반신은 여우로 변신 중인 반변신 상태.
> 매혹 파동으로 유인하고, 여우불 8방향 공격, 분신 2체 소환.
> 아름답지만 치명적. 한국 요괴 중 가장 유명한 존재.

**프롬프트**: 베이스 + 보스 레이아웃 + 아래

```
Boss:
- Korean gumiho (구미호), the legendary nine-tailed fox
- Half-transformed state: upper body = beautiful woman, lower body = fox
- Seductive yet LETHAL — beauty that kills
- The most iconic Korean mythical creature

UPPER BODY (HUMAN):
- Stunningly beautiful pale face — porcelain skin
- Sharp, calculating eyes with vertical slit pupils (fox nature showing)
- Red (#D4483B) painted lips, slight cruel smile
- Long flowing hair: white at roots transitioning to red at tips
- Hair moves like it's alive — floating, swaying independently
- TWO pointed fox ears poking through hair on top of head
- Red silk jeogori (저고리) with elegant gold embroidery
- Delicate but dangerous hands with sharp nails

LOWER BODY (FOX):
- Below the waist: white fur fox body with four fox legs
- Fur color: white transitioning to red at the paws
- Elegant, cat-like posture — front paws visible, back legs tucked
- The human-to-fox transition is seamless at the waist — no harsh line

TAILS (THE DEFINING FEATURE):
- NINE magnificent fox tails spreading out behind like a fan
- Each tail: white fur → red tip → small blue (#3366AA) foxfire flame at the very end
- The nine flames create a semicircle of blue fire behind her
- Tails should take up significant visual space — they ARE the boss silhouette

COLOR PALETTE (max 16):
- White (#E8E8F0) — fur, hair roots
- Red (#D4483B) — jeogori, hair tips, paw fur
- Pale skin (#EBC8A0) — face, hands
- Blue (#3366AA) — foxfire at tail tips
- Gold (#FFD166) — embroidery, jewelry
- Black (#1A1A2E) — pupils, outline
- Dark red (#8B1A1A) — shadows

ANIMATION:
IDLE (4 frames):
- idle0: Seated elegantly on fox haunches, tails fanned, foxfires steady, sly smile
- idle1: Hair sways left, 3 tails shift right, foxfires flicker (blue intensity changes)
- idle2: Slight head tilt, one hand raised gracefully, tails settle
- idle3: Hair sways right, other tails shift, foxfires pulse brighter then dim

ATTACK (4 frames):
- attack0: Eyes flash bright, mouth opens in a foxlike snarl, tails raise aggressively
- attack1: Both hands thrust forward, blue-red energy ball forming between palms
- attack2: Energy releases — multiple blue foxfire projectiles scatter outward from her
- attack3: Recovery pose, tails wrap protectively, cruel satisfied expression
```

**후처리:**
```bash
python tools/sprite_cleanup.py tools/raw/bosses/gumiho_raw.png \
  -o assets/images/boss_gumiho.png --type boss --reference --debug
```

---

### PJ-02. 비녀검 투사체 — `proj_binyeo.png`

> 소연의 시작 무기. 은색 비녀 형태의 암기가 회전하며 적을 추적(homing).

```
STRICT SNES PIXEL ART — DO NOT DEVIATE
Canvas: 256x64 PNG, solid black background
Layout: 4 frames horizontal row, each 64x64, NO labels/borders

Projectile:
- Silver (#E8E8F0) ornate Korean hairpin dagger (비녀검)
- Elegant curved blade with decorative flower-shaped handle end
- Spinning rotation with white sparkle trail pixels (2-3 trailing sparkle dots)
- Frame 1: horizontal orientation, blade pointing right, sparkle at handle
- Frame 2: 90° rotated (diagonal), sparkle trails behind
- Frame 3: vertical, blade pointing up, sparkle shifts
- Frame 4: 270° (opposite diagonal), sparkle trail complete
- Max 6 colors: silver, white sparkle, light purple tint, dark outline
```

---

### PJ-04. 금강저 투사체 — `proj_geumgangeo.png`

> 법운의 시작 무기. 불교 법기 금강저(vajra). 양쪽 끝이 갈라진 금빛 번개 무기.

```
STRICT SNES PIXEL ART — DO NOT DEVIATE
Canvas: 256x64 PNG, solid black background
Layout: 4 frames horizontal row, each 64x64, NO labels/borders

Projectile:
- Golden (#FFD166) Buddhist vajra weapon (금강저)
- Central grip with split prongs on BOTH ends (3 prongs each side, fork-shaped)
- Symmetrical sacred weapon shape
- Lightning (#88CCEE) spark effects alternating between frames
- Frame 1: vajra horizontal, small lightning spark on left prongs
- Frame 2: spark jumps to right prongs, left side clear
- Frame 3: both sides spark simultaneously, brightest frame
- Frame 4: sparks dissipate, golden afterglow
- Max 6 colors: gold, light gold, lightning blue-white, dark outline
```

---

### PJ-05. 화살 투사체 — `proj_hwasal.png`

> 범용 화살 무기. 대나무 화살에 흰 깃털. 직선 비행.

```
STRICT SNES PIXEL ART — DO NOT DEVIATE
Canvas: 256x64 PNG, solid black background
Layout: 4 frames horizontal row, each 64x64, NO labels/borders

Projectile:
- Korean traditional bamboo arrow (화살)
- Brown (#755540) bamboo shaft, straight and thin
- Silver (#E8E8F0) pointed arrowhead at front
- White feather fletching (깃) at tail end — 3 small feather pixels
- Arrow flies horizontally, slight vibration between frames
- Frame 1: arrow straight, feathers neat
- Frame 2: shaft vibrates 1px up, feathers flutter
- Frame 3: shaft straight again, feathers opposite flutter
- Frame 4: shaft vibrates 1px down, feathers settle
- Max 6 colors: brown shaft, silver tip, white feathers, dark outline
```

---

### PJ-06. 도깨비불 투사체 — `proj_dokkaebi_bul.png`

> 도깨비불 무기의 투사체. 파란색+녹색 유령불. 일렁이는 불꽃.

```
STRICT SNES PIXEL ART — DO NOT DEVIATE
Canvas: 256x64 PNG, solid black background
Layout: 4 frames horizontal row, each 64x64, NO labels/borders

Projectile:
- Korean ghost flame (도깨비불), an eerie spirit fire
- NOT regular fire — otherworldly, cold-feeling flame
- Blue (#3366AA) core with green (#4A8C3F) outer flame wisps
- Flame shape: teardrop/irregular, flickering edges
- Frame 1: flame leans left, green wisps right, blue core center-left
- Frame 2: flame stands tall, green wisps rise, core centered
- Frame 3: flame leans right, green wisps left, core center-right
- Frame 4: flame shrinks slightly then pulses, wisps scatter
- Max 6 colors: blue, dark blue, green, light green, white core pixel
```

---

### PJ-07. 돌팔매 투사체 — `proj_dolpalmae.png`

> 돌팔매 무기의 투사체. 회전하는 둥근 돌.

```
STRICT SNES PIXEL ART — DO NOT DEVIATE
Canvas: 256x64 PNG, solid black background
Layout: 4 frames horizontal row, each 64x64, NO labels/borders

Projectile:
- Round grey sling stone (돌팔매)
- Simple round rock shape, about 8x8px, slightly irregular (not perfect circle)
- Grey (#8888A0) base with lighter (#C0C0D0) highlight and darker (#4A4A5A) shadow
- Spinning through air with 1-2px motion blur trail behind
- Frame 1: highlight at top-left (light source), trail right
- Frame 2: highlight shifts to top-right (rotated 90°), trail adjusts
- Frame 3: highlight at bottom-right, trail shifts
- Frame 4: highlight at bottom-left, completing rotation
- Max 6 colors: grey shades, white highlight dot, dark outline
```

---

### PJ-08. 폭발 이펙트 — `proj_explosion.png`

> 풍물북 무기의 착탄 이펙트. 폭발 시퀀스.

```
STRICT SNES PIXEL ART — DO NOT DEVIATE
Canvas: 256x64 PNG, solid black background
Layout: 4 frames horizontal row, each 64x64, NO labels/borders

Effect:
- Drum weapon (풍물북) explosion impact sequence
- Frame 1 — SPARK: small yellow (#FFD166) flash, 6x6px, sharp star shape, white center pixel
- Frame 2 — FIREBALL: expanding orange (#FF9B7A) ball, 16x16px, yellow core, red (#D4483B) edges
- Frame 3 — PEAK EXPLOSION: large red (#D4483B) blast, 24x24px, orange inner ring, scattered pixel debris
- Frame 4 — SMOKE: fading grey (#9898AC) smoke cloud, 20x20px, dissipating edges, last orange embers
- Each frame should be dramatically different — clear progression from small to big to fade
- Max 8 colors: yellow, orange, red, grey smoke, white flash, dark outline
```

---

### ITEM-02. 보물상자 — `chests.png`

> 보스/엘리트 처치 시 드롭. 4등급 (나무/금/옥/용).

```
STRICT SNES PIXEL ART — DO NOT DEVIATE
Canvas: 256x64 PNG, solid black background
Layout: 4 chests in a single horizontal row, each 64x64, NO labels

Korean mythology themed treasure chests (top-down 3/4 view, closed):

CHEST 1 — WOOD/IRON (기본):
- Simple wooden chest, brown (#755540) planks visible
- Iron (#4A4A5A) bands/straps across front, simple iron lock
- Unimpressive, common loot feeling
- No glow, no special effects

CHEST 2 — GOLD (골드):
- Polished wooden chest with gold (#FFD166) trim on all edges
- Gold lock and hinges, gold corner reinforcements
- Subtle golden glow: 1-2px yellow pixels around edges
- Feels valuable and desirable

CHEST 3 — JADE (옥):
- Jade green (#4A8C3F) stone/lacquer chest body
- Silver (#E8E8F0) metal fittings, small gemstone decorations (colored dots)
- Faint green magical aura (1px green halo)
- Rare, mystical, precious feeling

CHEST 4 — DRAGON (용):
- Dark ornate chest with carved dragon (#D4483B) relief on front face
- Purple (#6B3A78) magical glow radiating outward (2-3px aura)
- Gold and purple color scheme, most impressive
- Legendary, endgame, ultimate treasure feeling

Max 10 colors per chest, 16-bit style.
```

---

## ═══════════════════════════════════════════
## Phase 3: 캐릭터 확장 — 플레이어 6종 + 보스 3종
## ═══════════════════════════════════════════

---

### PC-03. 철웅 (장군) — `player_cheolwoong.png`

> 조선의 전장을 누빈 역전의 장군. 탱커형 캐릭터.
> HP 최고(130)이지만 이속 최저(90%). 묵직하고 강인한 전사.
> 투구에 붉은 깃, 은백색 갑옷, 거대한 청룡도(언월도)를 든 위풍당당한 차림.
> 무겁고 강력한 일격을 날리는 스타일. 방어와 공격을 겸비.

**프롬프트**: 베이스 + 플레이어 레이아웃 + 아래

```
Character:
- Korean Joseon dynasty general (장군), male heavy warrior tank
- Fierce, stern, commanding expression — a veteran of many battles
- BROAD-SHOULDERED, heavyset, armored to the teeth
- Moves slowly but powerfully — every step has weight

HEAD:
- Joseon military helmet (투구) — round bowl shape with neck flap
- ONE red (#D4483B) plume/tassel rising from the top of the helmet
- Black topknot hair visible at the sides beneath the helmet
- Thick eyebrows, small stern eyes, square jaw
- Short stubble/beard (2-3 dark pixels on chin)

UPPER BODY:
- Silver-white (#C0C0D0) scale armor (두정갑) — small rivet dots visible on surface
- Gold (#FFD166) circular mirror (호심경) on center of chest — protective charm
- Shoulder guards (어깨받이) on BOTH sides — curved metal plates
- Armor is bulky, adding to the wide silhouette

WEAPON (DEFINING FEATURE):
- RIGHT hand wielding a massive blue crescent blade (청룡도/언월도)
- The weapon is 80% of the character's height — huge curved blade on a long pole
- Blade: silver (#E8E8F0) crescent moon shape
- Handle/shaft: green (#4A8C3F) wrapped grip
- The weapon makes the silhouette immediately recognizable

LOWER BODY:
- Dark navy (#1D3557) pants/leg armor
- Metal (#8888A0) shin guards
- Heavy black military boots — flat, wide

COLOR PALETTE (max 12):
- Silver (#C0C0D0) — armor, blade
- Navy (#1D3557) — pants
- Red (#D4483B) — helmet plume
- Green (#4A8C3F) — weapon handle
- Gold (#FFD166) — chest mirror
- Black (#1A1A2E) — hair, boots, outline
- Skin (#EBC8A0) — face

FRAME-BY-FRAME (IDLE):
- idle0: Standing firm, crescent blade resting at side, chin up, authoritative
- idle1: 1px UP (armor barely shifts), plume sways slightly
- idle2: Returns, gold chest mirror catches light (pixel flash)
- idle3: 1px DOWN, blade shifts slightly, heavy exhale

FRAME-BY-FRAME (WALK):
- walk0: Heavy right step forward, armor rattles (shoulder guards shift 1px), blade drags
- walk1: Passing, body 1px UP, blade swings slightly
- walk2: Left step, opposite shoulder guard shift, plume bounces
- walk3: Passing, body settles, armor clinks

CAST/ATTACK:
- cast0: Grips crescent blade with both hands, pulls back
- cast1: HUGE horizontal sweep — blade arcs in a wide crescent
- cast2: Full extension, green energy trail follows the blade arc
- cast3: Recovery, blade returns to side, green wind slash effect fades
```

---

### PC-04. 소연 (궁녀 암살자) — `player_soyeon.png`

> 궁궐의 어둠 속에서 활동하는 암살자. HP 최저(80)이지만 이속 최고(110%).
> 원래 궁녀였으나 암살 기술을 익힌 이중생활자.
> 검은 옷에 보라 포인트, 은색 비녀검. 닌자풍 팔토시.
> 날카로운 눈매와 차가운 표정. 빠르고 치명적인 히트앤런 스타일.

**프롬프트**: 베이스 + 플레이어 레이아웃 + 아래

```
Character:
- Korean palace assassin (궁녀 암살자), female, agile stealth fighter
- Sharp, cold, calculating expression — she has killed before
- SLIM, athletic build — speed over strength
- Moves with fluid, cat-like grace

HEAD:
- Black hair in a tight updo bun (궁녀 올림머리)
- Silver (#E8E8F0) binyeo hairpin dagger visibly sticking out of the hair bun
  (this IS her weapon — a hidden blade disguised as a hair ornament)
- Sharp narrow eyes — cold, assassin's gaze
- No smile — neutral or slightly menacing expression

UPPER BODY:
- Dark black (#282832) modified court lady robes — shortened for mobility
- NOT the flowing elegant court dress — this is a combat-modified version
- Short sleeves exposing forearms
- Dark purple (#6B3A78) chest ribbon/sash (가슴끈) — the only color accent on top
- BLACK arm wraps (팔토시) on both forearms — ninja-style bindings

LOWER BODY:
- Black (#282832) pants, tight-fitting, knee length
- Feet wrapped in dark cloth — silent footwear for stealth
- No shoes — cloth-wrapped feet for silent movement

ACCESSORIES:
- LEFT hand holding a small silver (#E8E8F0) short blade/dagger
- Small leather pouch at waist (tools/poisons)

COLOR PALETTE (max 10):
- Black (#282832) — robes, pants, arm wraps
- Dark purple (#6B3A78) — chest ribbon
- Silver (#E8E8F0) — binyeo, dagger
- Skin (#EBC8A0, #C8A582) — face, arms
- Black (#1A1A2E) — hair, outline

FRAME-BY-FRAME (IDLE):
- idle0: Crouched slightly (combat stance), dagger forward, weight on balls of feet
- idle1: Shifts weight right, dagger hand adjusts, binyeo catches light
- idle2: Returns to center, eyes seem to scan
- idle3: Shifts weight left, subtle ready-to-spring tension

FRAME-BY-FRAME (WALK):
- walk0: Light, quick step — right foot, body low, dagger leading
- walk1: Glide forward, body barely rises, cloth wraps flutter
- walk2: Left foot, silent step, arm swings with dagger
- walk3: Glide, almost no vertical bounce — assassin walks WITHOUT bobbing

CAST/ATTACK:
- cast0: Reaches up to hair bun, fingers on binyeo
- cast1: Pulls binyeo out in a flash — silver streak
- cast2: Throws binyeo forward — silver spinning blur with sparkle trail
- cast3: Draws second dagger, combat stance, binyeo disappears (launched as projectile)
```

---

### PC-05. 법운 (승려) — `player_beopwoon.png`

> 수행을 통해 퇴마 능력을 얻은 불교 승려. 토(土) 속성.
> HP 높음(110), 공격력 낮음(90%). 서포트형 탱커.
> 삭발에 이마 사리 표시, 회색 승복에 주황 가사끈. 금강저와 108염주.
> 자비로운 표정이지만 악에 대해서는 단호한 이중성.

**프롬프트**: 베이스 + 플레이어 레이아웃 + 아래

```
Character:
- Korean Buddhist warrior monk (승려), male, serene yet powerful
- Calm, compassionate expression — but with underlying steel resolve
- BALD head — completely shaved, smooth dome
- Balanced build — not thin, not bulky, disciplined body

HEAD:
- Completely bald (민머리) — smooth, round
- Small golden dot (사리 mark) on center of forehead — 1px gold (#FFD166)
  (this represents spiritual enlightenment)
- Round, gentle face with kind eyes — but focused, not spacey
- Compassionate half-smile

UPPER BODY:
- Grey (#A0A098) monk robes (승복) — simple, humble fabric
- ONE SHOULDER EXPOSED (left shoulder bare) — kasa draping style
- Orange-gold (#C9A84C) diagonal sash (가사끈) going from right shoulder across chest to left hip
- The sash is the main color accent on the grey robes
- Left wrist: 108-bead prayer bracelet (염주) — small brown dots in a loop

WEAPON:
- RIGHT hand holding a golden (#FFD166) vajra (금강저)
- The vajra has a central grip and SPLIT ENDS (2-3 prongs) on BOTH tips
- Classic Buddhist ritual weapon — symmetrical, ornate

LOWER BODY:
- Grey (#A0A098) pants matching the robes
- Straw sandals (짚신) on feet — simple, humble

COLOR PALETTE (max 10):
- Grey (#A0A098) — robes, pants
- Orange-gold (#C9A84C) — sash
- Gold (#FFD166) — vajra, forehead mark
- Brown (#755540) — prayer beads, sandals
- Skin (#EBC8A0, #C8A582) — face, exposed shoulder, hands
- Black (#1A1A2E) — outline

FRAME-BY-FRAME (IDLE):
- idle0: Standing in prayer-like calm, vajra held loosely at side, peaceful expression
- idle1: 1px UP (meditation breath), sash shifts, prayer beads sway
- idle2: Returns, forehead mark glows briefly (gold pixel pulse)
- idle3: 1px DOWN, vajra tilts slightly, at peace

FRAME-BY-FRAME (WALK):
- walk0: Measured step forward, robes sway gently, sandals shuffle
- walk1: Passing, body 1px UP, sash bounces slightly
- walk2: Other foot, robes sway opposite, calm unhurried pace
- walk3: Passing, settles — monk walks with deliberate, mindful steps

CAST/ATTACK:
- cast0: Raises vajra overhead, prayer beads glow
- cast1: Brings vajra forward with both hands, golden energy charges at the tips
- cast2: Vajra launches golden beam/bolt, lightning-like golden streak
- cast3: Recovery, clasps hands in prayer briefly, golden circle fades
```

---

### PC-06. 단비 (풍물패) — `player_danbi.png`

> 풍물놀이 북 연주자. 밝고 활기찬 캐릭터.
> 쿨타임 최저(95%), 범위 최대(125%). 광역 폭발 딜러.
> 상모(회전 리본 모자), 색동 한복이 화려한 비주얼 포인트.
> 축제의 에너지로 요괴를 쫓아내는 밝은 분위기의 캐릭터.

**프롬프트**: 베이스 + 플레이어 레이아웃 + 아래

```
Character:
- Korean traditional festival drummer girl (풍물패), female
- BRIGHT, CHEERFUL, ENERGETIC — she's having the time of her life
- The most colorful character in the entire game
- Bouncy, festive movement style

HEAD:
- Sangmo hat (상모) — a round hat with a LONG white spinning ribbon attached to the top
- The white ribbon (about 20px long) trails and spins during animation — signature feature
- Underneath: black hair tied up to fit under the hat
- Bright, big smile — cheerful eyes, happy expression
- Young female face, full of energy

UPPER BODY:
- Saekdong (색동) striped jeogori jacket — Korean rainbow stripes
- Stripes alternate: red (#D4483B), blue (#3366AA), yellow (#FFD166)
- White collar (동정) at the neckline
- Sleeves match the striped pattern
- This is the MOST colorful outfit — a walking rainbow

LOWER BODY:
- White short skirt (치마) — shorter than traditional for mobility
- White beoseon socks (버선) and straw sandals
- Active, dance-ready posture

ACCESSORIES:
- Large red drum (북) strapped to her BACK — visible behind the body
- Both hands holding drumsticks (북채) — simple brown wooden sticks with round ends
- The drum is her most important prop — circular, red body, leather top

COLOR PALETTE (max 12):
- Red (#D4483B) — stripe, drum
- Blue (#3366AA) — stripe
- Yellow (#FFD166) — stripe
- White (#F0EEE6) — ribbon, skirt, collar, socks
- Brown (#755540) — drumsticks
- Skin (#EBC8A0) — face, hands
- Black (#1A1A2E) — hair, outline

FRAME-BY-FRAME (IDLE):
- idle0: Standing with drumsticks raised, sangmo ribbon hanging left, smile
- idle1: 1px UP (bounce), ribbon swings right, drumsticks tap together
- idle2: Returns, ribbon overhead, slight head bob
- idle3: 1px DOWN, ribbon swings left, readying next beat

FRAME-BY-FRAME (WALK):
- walk0: Dancing step right, sangmo ribbon trails left, drumstick swings
- walk1: Hop UP 1px, ribbon whips overhead, energy in every step
- walk2: Dancing step left, ribbon trails right, opposite drumstick
- walk3: Hop UP, ribbon whips other way — she DANCES, not walks

CAST/ATTACK:
- cast0: Raises both drumsticks high
- cast1: SLAMS drumsticks onto back-drum — impact lines radiate
- cast2: Drum produces shockwave — red/yellow/blue concentric rings expand
- cast3: Celebration pose, drumsticks up in V-shape, colorful confetti pixels
```

---

### PC-07. 귀손 (반요) — `player_gwison.png`

> 반인반요(半人半妖). 도깨비의 피가 섞인 인간 청년.
> 도깨비 대장 보스를 처치해야 해금되는 히든 캐릭터.
> 한쪽 눈만 붉고, 이마에 작은 뿔, 찢어진 옷에서 보라빛 요기(妖氣)가 새어나옴.
> 가슴의 봉인 부적이 요기를 억누르고 있는 설정. 내면의 갈등을 표현.

**프롬프트**: 베이스 + 플레이어 레이아웃 + 아래

```
Character:
- Korean half-demon youth (반요), male, torn between human and demon
- Fierce, conflicted expression — NOT fully evil, NOT fully good
- One side is human, the other shows demon nature
- Wild, untamed appearance with dark energy

HEAD:
- Wild messy black hair — uncombed, sticking up in all directions (spiky/unkempt)
- Small REDDISH-BROWN horn on RIGHT side of forehead (only one — asymmetric, half-demon)
- LEFT eye: normal black human eye
- RIGHT eye: glowing RED (#E63946) — demon eye, unsettling
- One visible fang (송곳니) poking from upper lip on the right side
- Dark scar/marking pattern on right side of face (demon markings)
- Conflicted, fierce expression — snarl mixed with sadness

UPPER BODY:
- TORN navy hanbok — ripped at shoulders, sleeves ragged
- LEFT shoulder completely exposed (ripped away), showing skin with dark veins
- Purple (#6B3A78) dark energy wisps floating around the exposed areas
  (demon energy leaking through the tears in clothing)
- Golden (#FFD166) seal talisman (봉인 부적) stuck on CENTER of chest
  — this talisman SEALS his demon power, keeping him partly human
  — it's cracked/glowing, struggling to contain the power

HANDS:
- Both hands wreathed in purple (#6B3A78) energy claws
- Three claw marks (slash lines) of purple energy extend from each hand
- These are NOT physical claws — they are energy manifestations

LOWER BODY:
- Torn navy pants, ripped at the knees
- BAREFOOT — feet surrounded by dark purple wisps at ground level
- No shoes — feral, wild nature

COLOR PALETTE (max 12):
- Navy torn (#1D3557) — hanbok remains
- Purple (#6B3A78) — demon energy, claws, wisps
- Red (#E63946) — right eye glow
- Gold (#FFD166) — seal talisman on chest
- Skin (#EBC8A0, #C8A582) — face, exposed shoulder
- Black (#1A1A2E) — hair, outline, markings
- Dark purple (#3D1F4A) — energy shadows

FRAME-BY-FRAME (IDLE):
- idle0: Tense stance, claws flickering, seal talisman glowing steady, demon eye bright
- idle1: 1px shift, purple energy flares on left hand, talisman flickers (seal weakening)
- idle2: Returns, energy flares on right hand, talisman brightens (seal holding)
- idle3: Horn seems to pulse 1px, dark wisps intensify at feet, eye glows brighter

FRAME-BY-FRAME (WALK):
- walk0: Aggressive forward lean, claws leading, bare feet slap ground, wisps trail
- walk1: Mid-step, body springs UP, energy claws flare outward
- walk2: Other foot, wild stride, torn clothes flutter, wisps follow movement
- walk3: Mid-step, feral energy — he PROWLS, not walks

CAST/ATTACK:
- cast0: Seal talisman cracks/glows bright — power surging
- cast1: Purple energy explodes from both hands — massive claw slash forward
- cast2: Three huge purple energy claw marks tear across the frame
- cast3: Energy recedes, talisman re-seals with golden flash, panting recovery
```

---

### PC-08. 천무 (도사) — `player_cheonmoo.png`

> 도교의 도사(道士). 태극과 팔괘를 다루는 현인.
> 무기 5종 진화 완료 해금 — 최종 해금 캐릭터.
> 쿨타임 최저(90%). 8방향 팔괘진을 시전하는 전략형 캐스터.
> 수염 있는 중년 남성. 태극 문양과 청색 도복이 특징.
> 지혜롭고 초연한 분위기의 현자.

**프롬프트**: 베이스 + 플레이어 레이아웃 + 아래

```
Character:
- Korean Taoist sage (도사), middle-aged male, wise mystical strategist
- Calm, all-knowing expression — he has seen beyond the mortal veil
- Composed, dignified presence — moves with deliberate grace
- Small neat beard, wise eyes

HEAD:
- High topknot (상투) secured with a binyeo (비녀, hairpin)
- The topknot is wrapped in a blue-and-red cloth (태극 천)
  — small blue (#3366AA) and red (#D4483B) pixels visible in the wrap
- Middle-aged face, slight wrinkles at eyes (wisdom lines)
- Small neat beard (수염) — a few dark pixels at chin
- Wise, calm eyes — all-seeing but gentle

UPPER BODY:
- Blue (#3366AA) Taoist robes (도복) — flowing, dignified
- WIDE flowing sleeves — billowing elegantly when moving
- White (#F0EEE6) inner lining visible at collar and sleeve edges
- Large TAEGUK symbol (태극, yin-yang) on center of chest
  — a 4x4px circle, left half red (#D4483B), right half blue (#3366AA)
  — this is his most important visual symbol

WEAPON/ACCESSORY:
- RIGHT hand holding golden (#FFD166) bagua compass/fan (팔괘 나침반)
  — octagonal shape with golden glow
- A scroll (두루마리) tucked at the waist sash — rolled paper cylinder

LOWER BODY:
- Blue (#3366AA) pants matching the robes
- White (#F0EEE6) leg wraps (각반) from knee down
- Black shoes (흑혜)

COLOR PALETTE (max 12):
- Blue (#3366AA) — robes, pants, taeguk half
- White (#F0EEE6) — inner lining, leg wraps
- Red (#D4483B) — taeguk half, topknot wrap
- Gold (#FFD166) — compass, binyeo
- Skin (#EBC8A0, #C8A582) — face, hands
- Black (#1A1A2E) — shoes, hair, beard, outline
- Brown (#755540) — scroll

FRAME-BY-FRAME (IDLE):
- idle0: Standing with compass held before him in right hand, serene, robes still
- idle1: 1px UP (deep breath), wide sleeves sway outward, compass glows
- idle2: Returns, taeguk on chest seems to slowly rotate (pixel shift of red/blue)
- idle3: 1px DOWN, sleeves sway inward, compass dims, scroll shifts at waist

FRAME-BY-FRAME (WALK):
- walk0: Measured dignified step, robes flow like water, sleeves billow right
- walk1: Passing position, body 1px UP, sleeves catch air
- walk2: Other foot, robes flow opposite, sleeves billow left
- walk3: Passing, body settles — sage walks with absolute calm, no rushing

CAST/ATTACK:
- cast0: Raises compass overhead, taeguk symbol on chest begins to GLOW
- cast1: Compass spins in hand, 8 directional lines appear around him (팔괘진 formation)
- cast2: Energy releases in 8 directions — golden beams radiating like a compass rose
- cast3: Recovery, compass returns to hand, 8 directional lines fade, taeguk settles
```

---

### BOSS-03. 장산범 — `boss_jangsan.png`

> 스테이지 3 보스. 장산(부산 장산)에 사는 전설의 괴물. 금(金) 속성.
> 사람 목소리를 흉내내어 산에서 사람을 유인하는 공포의 존재.
> 흰 장모(긴 털)로 뒤덮인 거대한 몸체, 거대한 빨간 입이 유일한 얼굴.
> 눈이 보이지 않는 것이 핵심 공포 요소. 음파 공격+투명화가 특기.

**프롬프트**: 베이스 + 보스 레이아웃 + 아래

```
Boss:
- Korean jangsan-beom (장산범), the mountain voice-mimicking monster
- TERRIFYING, ALIEN, UNKNOWABLE — the scariest boss design
- Think "a pile of white fur with a giant mouth" — Lovecraftian simplicity
- Fills most of the 64x64 frame (58x60px)

BODY SHAPE:
- Amorphous mound covered entirely in LONG white fur
- The fur is so long it drapes all the way to the ground
- NO visible limbs — legs completely hidden under fur curtain
- NO visible body shape — just a massive furry dome/mountain
- The creature appears to GLIDE, not walk (no leg movement visible)

FACE (THE HORROR):
- NO visible eyes — fur hangs over where eyes should be
  (this is the KEY horror element — you can't see where it's looking)
- ENORMOUS gaping mouth — takes up 80% of the visible "face" area
- Mouth is deep RED (#D4483B) inside — a dark crimson void
- COUNTLESS small silver (#E8E8F0) teeth lining the mouth — dozens of tiny sharp teeth
- The mouth is always slightly open — ready to swallow
- This is a creature that IS a mouth with fur around it

EFFECTS:
- Sound wave rings emanating FROM the mouth outward
  — concentric pixel circles (silver/white) expanding from the mouth
  — these represent the mimicked human voice it uses to lure victims
- Faint mist/fog pixels around the base (mountain fog)

COLOR PALETTE (max 12):
- White fur (#E8E8F0, #C8C8DC) — primary body (2 shades for depth)
- Grey (#9898AC) — fur shadows
- Red (#D4483B) — mouth interior
- Dark red (#8B1A1A) — deep mouth void
- Silver (#C0C0D0) — teeth, sound waves
- Mist blue (#88CCEE) — fog pixels

ANIMATION:
IDLE (4 frames):
- idle0: Mound of fur sitting, mouth slightly open, no sound waves, still and ominous
- idle1: Fur ripples (1px shifts on surface), mouth opens wider, first sound wave ring appears
- idle2: Fur settles, mouth at medium open, sound wave ring expands to mid-distance
- idle3: Slight sway of entire body mass, mouth closes slightly, new sound wave starts

ATTACK (4 frames):
- attack0: Mouth GAPES wide open — enormous red void, teeth glinting
- attack1: Sound waves BLAST outward — 3-4 concentric rings rapidly expanding
- attack2: Peak scream — screen-filling rings, fur blows back from the force, teeth visible fully
- attack3: Mouth snaps partially shut, rings dissipate, fur settles back over body
```

---

### BOSS-04. 불가사리 — `boss_bulgasari.png`

> 스테이지 4 보스. 쇠를 먹는 전설의 괴물. 토(土) 속성.
> HP 5000으로 역대급 체력. 돌진/지진/무적 패턴을 가진 초탱크 보스.
> 코뿔소+곰 혼합 외형에 돌과 금속이 뒤섞인 몸체.
> 파괴불가능한 느낌의 거대한 괴수. 게임 내 가장 "단단해 보이는" 적.

**프롬프트**: 베이스 + 보스 레이아웃 + 아래

```
Boss:
- Korean bulgasari (불가사리), the legendary iron-eating indestructible beast
- IMMOVABLE, UNSTOPPABLE, INDESTRUCTIBLE — a living fortress
- Rhino-bear hybrid made of STONE and METAL fused together
- Wide and heavy: 60x58px (fills the frame horizontally)

HEAD:
- Rhinoceros-bear hybrid face — broad, flat, brutish
- ONE large metallic (#C0C0D0) horn protruding from the snout
- Glowing orange (#FF9B7A) eyes — furnace-like heat (this creature eats metal)
- Metallic teeth visible in a closed-jaw snarl
- Head is low-set, aggressive charging posture

BODY:
- MIXED texture: half stone (rough brown-grey), half metal (smooth silver)
- Stone portions: cracked, rough, brown-grey (#B08C64, #8B6914) with visible fissures
- Metal portions: smooth, silvery (#C0C0D0, #8888A0) plates on shoulders, spine, flanks
- Rows of metallic SPIKES/PLATES along the spine (dorsal ridge)
- Absolutely MASSIVE torso — barrel-chested, impenetrably thick

LEGS:
- Four THICK short legs — like tree trunks, barely bending
- Metal hooves — shiny (#E8E8F0) at the bottom of each leg
- The legs convey that this creature is unimaginably heavy
- Ground CRACKS and DEBRIS beneath the hooves (2-3px crack lines and dust)

COLOR PALETTE (max 14):
- Stone brown (#B08C64) — rocky body portions
- Stone dark (#8B6914) — cracks, texture
- Stone deep (#5C4A12) — deepest fissures
- Metal silver (#C0C0D0) — metal plates, horn
- Metal dark (#8888A0) — metal shading
- Metal bright (#E8E8F0) — hooves, highlights
- Orange (#FF9B7A) — eye glow
- Black (#1A1A2E) — outline

ANIMATION:
IDLE (4 frames):
- idle0: Standing like an immovable mountain, all four hooves planted, breathing visible (chest 1px expand)
- idle1: Nostrils flare (tiny pixel), orange eyes pulse brighter, ground debris settles
- idle2: Slight weight shift right, metal plates on back catch light (silver flash)
- idle3: Weight shifts left, stone cracks seem to glow faintly (internal heat)

ATTACK (4 frames):
- attack0: Lowers head, horn pointing forward — CHARGING stance, back legs tense
- attack1: CHARGES forward — body launches 3px, dust cloud behind, horn leading
- attack2: IMPACT — horn hits, shockwave ring on ground, debris everywhere, ground cracks radiate
- attack3: Skids to halt, dust settles, raises head triumphantly, eyes blazing
```

---

### BOSS-05. 용왕 (龍王) — `boss_yongwang.png`

> 최종 보스. 동해 용궁의 용왕. 수(水) 속성. HP 8000.
> 동양 용+인간 왕의 혼합. 용비늘 갑옷을 입은 위엄있는 노왕.
> 물기둥/소용돌이/해일 등 수속성 광역 공격 패턴.
> 금색 용뿔, 흰 수염, 여의주, 삼지창 — 동양 용왕의 모든 상징을 집약.
> 게임의 피날레를 장식하는 최강의 존재.

**프롬프트**: 베이스 + 보스 레이아웃 + 아래

```
Boss:
- Korean Dragon King (용왕), THE FINAL BOSS of the entire game
- MAJESTIC, DIVINE, OVERWHELMING — a god among monsters
- Elderly but radiating absolute power — not frail, REGAL
- The most detailed and impressive sprite in the game
- Fills the entire 64x64 frame to maximum (60x62px)

HEAD:
- TWO golden antler-like dragon horns (사슴뿔형 용뿔) branching upward
  — ornate, majestic, crown-like
- Dragon King crown/headpiece between the horns — gold and blue
- Elderly male face — wise, stern, powerful
- Long flowing white beard AND white hair — moves as if underwater
  (hair and beard sway like they're submerged, flowing like water currents)
- Piercing blue eyes — ancient, all-knowing, judgmental

UPPER BODY:
- Blue (#1A3A5C) dragon-scale armor covering entire torso
  — individual scale texture visible (small overlapping curved shapes)
- GLOWING blue dragon pearl (여의주) embedded in center of chest
  — the pearl PULSES with light (brightest feature on the sprite)
  — 3x3px blue orb with white center pixel
- Gold (#FFD166) dragon ornaments on BOTH shoulders
  — small dragon heads facing outward on each shoulder guard

WEAPON:
- RIGHT hand holding a grand trident (삼지창)
  — gold (#FFD166) shaft with blue (#3366AA) energy at the three prong tips
  — weapon of a sea god — ornate and deadly

LOWER BODY:
- Blue dragon-scale pants/leg armor matching upper body
- Water effects: ripple rings around his feet/base
  — concentric blue-white circles on the ground beneath him
- He appears to stand ON water, not ground

COLOR PALETTE (max 16):
- Deep blue (#1A3A5C) — armor scales
- Medium blue (#3366AA) — trident energy, pearl glow
- Light blue (#88CCEE) — water effects, highlights
- Gold (#FFD166) — horns, crown, shoulder dragons, trident shaft
- White (#E8E8F0) — beard, hair, pearl core
- Skin (#C8A582) — aged face
- Black (#1A1A2E) — outline, deep shadows

ANIMATION:
IDLE (4 frames):
- idle0: Standing in imperial pose, trident at side, beard flowing right, water ripples steady, pearl glowing
- idle1: Beard flows left, hair shifts, dragon pearl PULSES brighter, water rings expand
- idle2: Trident shifts slightly, shoulder dragons seem to breathe, pearl dims to base, new water ring
- idle3: Full regal presence, beard flows right again, pearl pulses, water rings overlap

ATTACK (4 frames):
- attack0: Raises trident overhead with both hands, pearl blazes bright, water surges upward around him
- attack1: STRIKES trident down — three blue energy pillars erupt from the prong tips
- attack2: Water TSUNAMI wave rolls outward from him — blue wall of water pixels, pearl at maximum brightness
- attack3: Water recedes, trident returns to side, lingering water drops/spray pixels, pearl settles
```

---

## ═══════════════════════════════════════════
## Phase 4: 진화 투사체 12종
## ═══════════════════════════════════════════

> 모든 진화 투사체: 256x64 PNG, 4프레임 × 64x64, 검정 배경, 라벨 없음.
> 기본 투사체의 강화 버전 — 더 크고, 더 화려하고, 더 강력한 느낌.

---

### EVO-01. 천뢰부적 (퇴마부적 → 진화) — `proj_cheonloe.png`

> 퇴마부적 + 화톳불 패시브 = 천뢰(天雷)부적. 번개를 두른 부적.

```
STRICT SNES PIXEL ART — DO NOT DEVIATE
Canvas: 256x64 PNG, black background, 4 frames × 64x64, NO labels

Projectile: Evolved thunder talisman (천뢰부적)
- The basic golden talisman, but now WRAPPED in crackling lightning
- Golden (#FFD166) talisman paper center (same as basic but slightly larger)
- Electric blue-white (#88CCEE) lightning arcs surrounding and arcing around the paper
- White (#FFFFFF) spark pixels at lightning tips
- Much more intense energy than basic — this is DIVINE THUNDER
- Frame 1: lightning arcs at 12 o'clock and 6 o'clock positions
- Frame 2: arcs rotate to 3 and 9 o'clock, sparks fly
- Frame 3: arcs at 1 and 7, maximum brightness, electric crackling
- Frame 4: arcs at 10 and 4, sparks dissipate slightly before cycling
- Max 8 colors: gold, electric blue, white, light blue, dark outline
```

### EVO-02. 용천검 (비녀검 → 진화) — `proj_yongcheon.png`

> 비녀검 + 부채 패시브 = 용천(龍泉)검. 용의 기운이 깃든 검.

```
Canvas: 256x64 PNG, black background, 4 frames × 64x64, NO labels

Projectile: Evolved dragon sword (용천검)
- A luminous blue (#3366AA) spirit sword — no longer a small hairpin, now a full BLADE
- The blade itself GLOWS with inner blue light, white (#FFFFFF) edge highlight
- DRAGON silhouette: a faint serpentine dragon shape trails BEHIND the sword as afterimage
  (the dragon ghost is translucent, only 2-3 pixels suggesting the shape)
- Frame 1: sword horizontal, dragon trail begins at hilt
- Frame 2: sword same, dragon trail extends behind, head visible
- Frame 3: dragon trail at full length, body S-curve visible
- Frame 4: dragon trail fades, sword pulses, new dragon begins
- Max 8 colors: blue, dark blue, white edge, faint dragon grey-blue
```

### EVO-03. 청룡언월도 (청룡도 → 진화) — `proj_cheongryong_eon.png`

> 청룡도 + 두루마리 패시브 = 청룡언월도(靑龍偃月刀). 녹색 참격파.

```
Canvas: 256x64 PNG, black background, 4 frames × 64x64, NO labels

Projectile: Evolved green dragon crescent blade (청룡언월도)
- NOT a physical weapon — this is a crescent-shaped ENERGY SLASH WAVE
- Green (#4A8C3F) glowing crescent arc, like a horizontal moon slice
- Bright green (#A8E6A3) leading edge, darker green trailing
- White (#FFFFFF) pixel core along the crescent's edge
- The slash wave EXPANDS as it travels
- Frame 1: thin crescent, compact, bright green core
- Frame 2: crescent widens, green energy trail appears behind
- Frame 3: maximum size crescent, energy crackling at edges
- Frame 4: crescent begins to fade/dissolve into green particles
- Max 6 colors: green, bright green, white, dark green, outline
```

### EVO-04. 항마금강저 (금강저 → 진화) — `proj_hangma.png`

> 금강저 + 인삼 패시브 = 항마(降魔)금강저. 파괴적 법기.

```
Canvas: 256x64 PNG, black background, 4 frames × 64x64, NO labels

Projectile: Evolved anti-demon vajra (항마금강저)
- TRIPLE-pronged golden (#FFD166) vajra — larger and more ornate than basic
- Each prong end has a small explosion/burst effect
- Explosive orange (#FF9B7A) energy aura surrounding the entire weapon
- White (#FFFFFF) core glow at the center grip
- Frame 1: vajra spinning, orange burst on left prongs
- Frame 2: burst shifts to right prongs, left side trails
- Frame 3: ALL prongs burst simultaneously — maximum energy output
- Frame 4: energy contracts back to core, golden afterglow pulse
- Max 8 colors: gold, bright gold, orange, white, dark outline
```

### EVO-05. 천지방울 (신성 방울 → 진화) — `proj_cheonji.png`

> 신성 방울 + 향로 패시브 = 천지(天地)방울. 무지개빛 음파.

```
Canvas: 256x64 PNG, black background, 4 frames × 64x64, NO labels

Projectile: Evolved cosmic bell (천지방울)
- Large golden bell center — bigger than basic (10x10px vs 6x6px)
- RAINBOW iridescent sound wave rings expanding outward
- Each ring is a DIFFERENT color as they expand:
  - innermost ring: gold (#FFD166)
  - next: red (#D4483B)
  - next: blue (#3366AA)
  - outermost: green (#4A8C3F)
- Frame 1: bell at center, first gold ring close
- Frame 2: gold ring expands, red ring appears inside
- Frame 3: all 4 color rings visible at different radii
- Frame 4: outer rings fade, new cycle begins from bell
- Max 8 colors: gold bell, rainbow ring cycle (gold/red/blue/green), white highlight
```

### EVO-06. 사물놀이 (풍물북 → 진화) — `proj_samulnori.png`

> 풍물북 + 장구 패시브 = 사물놀이(四物놀이). 4색 폭발.

```
Canvas: 256x64 PNG, black background, 4 frames × 64x64, NO labels

Projectile: Evolved four-instrument festival explosion (사물놀이)
- NOT a single-color explosion — a FOUR-COLOR celebratory blast
- Each of the 4 traditional instruments represented by a color:
  꽹과리=yellow, 징=blue, 장구=red, 북=green
- Frame 1: RED dominant explosion burst — red center, other colors at edges
- Frame 2: BLUE dominant — blue takes over center, red recedes, yellow/green edges
- Frame 3: YELLOW dominant — golden flash at center, blue recedes
- Frame 4: GREEN dominant — green fills center, then all 4 colors flash together briefly
- Each frame is a dramatic color shift — festive, chaotic, celebratory destruction
- Max 8 colors: red (#D4483B), blue (#3366AA), yellow (#FFD166), green (#4A8C3F), white center
```

### EVO-07. 구미호 발톱 (요기 발톱 → 진화) — `proj_gumiho.png`

> 요기 발톱 + 여우구슬 패시브 = 구미호 발톱. 보라빛 에너지 클로.

```
Canvas: 256x64 PNG, black background, 4 frames × 64x64, NO labels

Projectile: Evolved nine-tail fox claws (구미호 발톱)
- THREE diagonal slash marks made of purple (#6B3A78) energy
- Like claw scratch marks torn through the air itself
- Red (#E63946) foxfire wisps flickering between the claw lines
- White (#FFFFFF) sharp leading edge on each claw mark
- Frame 1: three claws appear mid-slash (diagonal lines, top-left to bottom-right)
- Frame 2: claws at full extension, foxfire sparks between them
- Frame 3: claws begin to fade, foxfire intensifies, energy trails
- Frame 4: fading scratch marks remain, foxfire dissipates into purple particles
- Max 8 colors: purple, dark purple, red foxfire, white edges, outline
```

### EVO-08. 태극진 (팔괘진 → 진화) — `proj_taegeuk.png`

> 팔괘진 + 나침반 패시브 = 태극진(太極陣). 회전하는 태극 문양.

```
Canvas: 256x64 PNG, black background, 4 frames × 64x64, NO labels

Projectile: Evolved taeguk formation orb (태극진)
- Spinning TAEGUK (yin-yang / 태극) symbol — the Korean flag symbol
- Circle divided into two halves: red (#D4483B) and blue (#3366AA)
- The S-curve dividing line between red and blue is visible
- White (#FFFFFF) border ring around the taeguk circle
- Small golden (#FFD166) particles orbiting around the spinning symbol
- Frame 1: taeguk at 0° — red on left, blue on right (standard orientation)
- Frame 2: rotated 90° clockwise — red on top, blue on bottom
- Frame 3: rotated 180° — red on right, blue on left
- Frame 4: rotated 270° — red on bottom, blue on top
- Orbiting particles shift position with each frame
- Max 8 colors: red, blue, white border, gold particles, dark outline
```

### EVO-09. 신궁 (화살 → 진화) — `proj_singung.png`

> 화살 + 매 깃털 패시브 = 신궁(神弓). 관통하는 금빛 광선 화살.

```
Canvas: 256x64 PNG, black background, 4 frames × 64x64, NO labels

Projectile: Evolved divine bow arrow (신궁)
- No longer a simple bamboo arrow — this is a GOLDEN LIGHT ARROW
- Elongated golden (#FFD166) beam of light shaped like an arrow
- White (#FFFFFF) blazing tip — the brightest point
- Golden energy trail streaming behind the arrow (long tail, 20+ px)
- Faint blue (#88CCEE) glow halo around the arrow body
- This arrow PENETRATES — the trail shows it keeps going through targets
- Frame 1: arrow with short trail, tip blazing
- Frame 2: trail extends longer, tip white-hot
- Frame 3: trail at maximum length, energy pulsing along the shaft
- Frame 4: trail shimmers, tip flares, ready for next penetration
- Max 6 colors: gold, white, light blue glow, dark gold, outline
```

### EVO-10. 황천독무 (독안개 → 진화) — `proj_hwangcheon.png`

> 독안개 + 독사 이빨 패시브 = 황천독무(黃泉毒霧). 저승의 독안개.

```
Canvas: 256x64 PNG, black background, 4 frames × 64x64, NO labels

Projectile: Evolved underworld poison mist (황천독무)
- Toxic purple (#6B3A78) cloud/mist — larger and deadlier than basic poison fog
- A ghostly SKULL silhouette faintly visible INSIDE the cloud
  (the skull is made of slightly different purple shade, subtle, ominous)
- Green (#4A8C3F) poison drip pixels falling from the bottom edges of the cloud
- Dark, otherworldly — this is poison from the UNDERWORLD (황천, realm of the dead)
- Frame 1: cloud forms, skull barely visible, no drips yet
- Frame 2: cloud swirls clockwise, skull becomes clearer, first green drips appear
- Frame 3: cloud at peak density, skull fully visible, multiple drips
- Frame 4: cloud swirls counter-clockwise, skull fades, drips reduce
- Max 8 colors: purple, dark purple, green drips, light green, skull shade, outline
```

### EVO-11. 불가사리 투사체 (돌팔매 → 진화) — `proj_bulgasari.png`

> 돌팔매 + 두꺼비 석상 패시브 = 불가사리 투사체. 금속 덩어리+충격파.

```
Canvas: 256x64 PNG, black background, 4 frames × 64x64, NO labels

Projectile: Evolved iron beast boulder (불가사리 투사체)
- Massive metallic boulder — NOT a small stone, a CHUNK of iron and rock
- Silver (#C0C0D0) metal and brown (#B08C64) stone mixed texture
- Much larger than the basic sling stone (14x14px vs 8x8px)
- Shockwave ring on impact — white/grey concentric ring expanding from the boulder
- Frame 1: boulder spinning, metal glints at top-left highlight
- Frame 2: rotated, glint shifts, first shockwave ring appears
- Frame 3: maximum spin, shockwave ring expanded, debris pixels scatter
- Frame 4: shockwave fades, new rotation cycle, debris settles
- Max 8 colors: silver metal, stone brown, white shockwave, grey, dark outline
```

### EVO-12. 삼매진화 (도깨비불 → 진화) — `proj_sammae.png`

> 도깨비불 + 등잔 패시브 = 삼매진화(三昧眞火). 분열하는 큰 불꽃.

```
Canvas: 256x64 PNG, black background, 4 frames × 64x64, NO labels

Projectile: Evolved samadhi true flame (삼매진화)
- Large blue (#3366AA) spirit flame — 2x the size of basic dokkaebi fire
- The main flame SPLITS into smaller golden (#FFD166) fragment flames
- Blue core with golden satellite flames orbiting/splitting off
- White (#FFFFFF) hottest core pixel at the flame center
- Frame 1: single large blue flame, golden sparks gathering at edges
- Frame 2: flame begins to SPLIT — 2-3 golden fragments separate from the main body
- Frame 3: fragments fully separated, orbiting around main blue flame, scattered formation
- Frame 4: fragments converge back into main flame, merge, blue flame pulses larger
- Max 8 colors: blue, dark blue, gold fragments, white core, light blue, outline
```

---

## ═══════════════════════════════════════════
## 후처리 요약 (sprite_cleanup.py)
## ═══════════════════════════════════════════

```bash
# 1. Pillow 설치 (최초 1회)
pip install Pillow

# 2. 플레이어 (레퍼런스 시트 → 256x32 스트립)
python tools/sprite_cleanup.py tools/raw/players/XXX_raw.png \
  -o assets/images/player_XXX.png --type player --reference --debug

# 3. 적 (레퍼런스 시트 → 128x32 스트립)
python tools/sprite_cleanup.py tools/raw/enemies/XXX_raw.png \
  -o assets/images/enemy_XXX.png --type enemy --reference --debug

# 4. 보스 (레퍼런스 시트 → 256x64 스트립)
python tools/sprite_cleanup.py tools/raw/bosses/XXX_raw.png \
  -o assets/images/boss_XXX.png --type boss --reference --debug

# 5. 투사체 (이미 스트립 형태 → 정리만)
python tools/sprite_cleanup.py tools/raw/projectiles/XXX_raw.png \
  -o assets/images/proj_XXX.png --type projectile --debug

# 6. 일괄 처리
python tools/sprite_cleanup.py tools/raw/enemies/ --type enemy --batch --reference -o assets/images/ --debug
```

**GPT가 스트립 대신 시트를 줄 때**: `--reference` 플래그 사용 → 자동 프레임 추출
**색상 노이즈가 심할 때**: `--reduce-colors` 플래그 추가
**배경 제거 안 될 때**: `--bg-threshold 30` (기본 20, 올리면 더 공격적 제거)

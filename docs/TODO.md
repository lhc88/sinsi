# 다음 작업 목록 (2026-04-06 기준)

## A. 스프라이트 에셋 작업

### A-1. 나머지 raw 7개 후처리 (tools/raw/ → assets/images/)
sprite_cleanup.py 투영 기반 분석 완성됨. 아래 파일들 처리 필요:
- players: player_wolhui.png, player_cheolwoong.png (--type player)
- enemies: enemy_jabgwi.png, enemy_dokkaebi_jol.png (--type enemy)
- projectiles: proj_bujeok.png, proj_bangul.png (--type projectile)
- items: exp_gems.png (--type exp_gems, 12프레임)

### A-2. GPT로 미생성 스프라이트 생성
프롬프트는 docs/GPT_PROMPTS.md에 완성됨. GPT에서 생성 후 tools/raw/에 저장.
- 플레이어 5명: PC-04 단비, PC-05 소연, PC-06 법운, PC-07 천무, PC-08 귀손
- 적 7종 (처녀귀신, 강시, 구렁이, 날쌘, 부려우, 갑옷귀신, 해태)
- 보스 5종 (구미호, 불가사리, 장산범, 용왕, 도깨비왕)
- 투사체 6종 + 진화 투사체 12종
- 타일, 상자

## B. 기능 통합 작업 (12개 미연결 항목)

24개 기능 구현 완료했으나 ~40%가 게임플레이에 미연결 상태.

### 우선순위 1: 게임플레이 핵심 연결
1. 파괴 오브젝트 스폰+충돌 — WaveSpawner 스폰, CollisionSystem 충돌, 드롭 로직
2. 일일 도전 UI+규칙 적용 — 화면+규칙 강제+보상 지급
3. 위세(Prestige) 시스템 적용 — _applyPowerUps() 반영 + UI
4. 진화 힌트 표시 — 일시정지/HUD에 getEvolutionHints() 표시

### 우선순위 2: UI/UX 연결
5. 도전과제 화면 네비게이션 — AchievementScreen → title_screen 버튼 추가
6. 페이지 전환 애니메이션 교체 — MaterialPageRoute → GamePageRoute
7. 스킨 시스템 연결 — cosmetics.dart → 캐릭터 선택 스킨 피커 + player tint 렌더링

### 우선순위 3: 사운드+피드백
8. AudioService 신규 메서드 연결 — critHit/eliteSpawn/milestone/waveStart 등 호출 지점 추가
9. UI 클릭 사운드 전체 적용 — 모든 버튼에 AudioService.uiClick()

### 우선순위 4: 검증+안정화
10. flutter analyze 전체 실행 — import 충돌, 미사용 변수 정리
11. 통합 테스트 — 엘리트 스폰율, 이벤트 타이밍, 킬 스트릭 유닛 테스트
12. 실기기 성능 테스트 — 300적+파괴물+이펙트 동시 fps 확인

**권장 순서:** 1→5→6→8 (빠른 연결) → 2→3→4→7 (복잡한 연결) → 9→10→11→12 (마무리)

## C. 참고사항
- 에셋 작업(A)과 기능 통합(B)은 독립적으로 진행 가능
- GPT 스프라이트 생성 대기 시간에 B 작업 진행 권장
- GitHub remote: https://github.com/lhc88/sinsi

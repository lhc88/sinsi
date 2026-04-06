# 개발 환경 설정 가이드

## 1. 필수 설치

| 도구 | 버전 | 용도 |
|------|------|------|
| **Flutter SDK** | 3.x (stable) | 프레임워크 |
| **Dart SDK** | Flutter에 포함 | 언어 |
| **Android Studio** | 최신 | Android SDK, 에뮬레이터 |
| **Git** | 최신 | 소스 관리 |
| **Python 3.12+** | 3.12 권장 | 스프라이트 후처리 도구 |
| **Pillow** (Python) | `pip install Pillow` | 이미지 처리 라이브러리 |

## 2. 클론 및 의존성 설치

```bash
git clone https://github.com/lhc88/sinsi.git
cd sinsi
flutter pub get
```

## 3. Android 빌드/실행

```bash
flutter run                    # 연결된 기기/에뮬레이터에서 실행
flutter build apk              # APK 빌드
```

## 4. 스프라이트 후처리 (GPT 이미지 → 게임 스트립)

```bash
pip install Pillow

# 개별 처리
python tools/sprite_cleanup.py tools/raw/players/파일.png \
  -o assets/images/파일.png --type player --reference --debug

# 배치 처리
python tools/sprite_cleanup.py tools/raw/players/ \
  --type player --batch --reference
```

- GPT 생성 원본은 `tools/raw/`에 저장 (gitignore됨, 각 환경에서 직접 생성 필요)
- 프롬프트는 `docs/GPT_PROMPTS.md`에 정리되어 있음

## 5. 플레이스홀더 스프라이트 재생성 (필요 시)

```bash
dart run tools/generate_sprites.dart
```

## 6. 테스트

```bash
flutter test
```

## 7. 주요 문서 위치

| 파일 | 내용 |
|------|------|
| `CLAUDE.md` | 코딩 컨벤션, 아키텍처 규칙 |
| `docs/GPT_PROMPTS.md` | GPT 스프라이트 생성 프롬프트 |
| `docs/ASSET_STRATEGY.md` | 에셋 스펙, 파일명, 코드 매핑 |
| `docs/AUDIO_STRATEGY.md` | 오디오 전략 |
| `GDD_퇴마록_v3.0_Final.docx` | 게임 기획서 |

## 8. 참고

- `tools/raw/` 폴더는 gitignore — GPT 원본 이미지는 환경마다 수동 배치 필요
- `*_debug.png`도 gitignore — 후처리 디버그 파일은 자동 제외
- Android 타겟 전용 (iOS는 구조만 존재)

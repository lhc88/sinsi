"""
sprite_cleanup.py - GPT 생성 스프라이트 시트 후처리 도구

GPT 레퍼런스 시트를 게임용 스트립으로 변환합니다.
그리드 셀 기반으로 스프라이트 행을 감지하여 올바른 프레임을 추출합니다.

사용법:
  pip install Pillow
  python tools/sprite_cleanup.py <입력파일> -t <타입> [옵션]
"""

import argparse
import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Pillow가 필요합니다: pip install Pillow")
    sys.exit(1)


ASSET_SPECS = {
    "player":     {"frame_w": 32, "frame_h": 32, "frames": 8, "max_colors": 12},
    "enemy":      {"frame_w": 32, "frame_h": 32, "frames": 4, "max_colors": 10},
    "boss":       {"frame_w": 64, "frame_h": 64, "frames": 4, "max_colors": 16},
    "projectile": {"frame_w": 16, "frame_h": 16, "frames": 4, "max_colors": 6},
    "item":       {"frame_w": 16, "frame_h": 16, "frames": 4, "max_colors": 8},
    "exp_gems":   {"frame_w": 16, "frame_h": 16, "frames": 12, "max_colors": 8},
    "chest":      {"frame_w": 32, "frame_h": 32, "frames": 4, "max_colors": 10},
    "tile":       {"frame_w": 64, "frame_h": 64, "frames": 4, "max_colors": 12},
}


# ── 유틸리티 ────────────────────────────────────────────────────

def remove_background(img: Image.Image, threshold: int = 20) -> Image.Image:
    """검정/근검정 배경을 투명으로 변환."""
    img = img.convert("RGBA")
    pixels = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if r <= threshold and g <= threshold and b <= threshold:
                pixels[x, y] = (0, 0, 0, 0)
    return img


def remove_antialiasing(img: Image.Image, threshold: int = 128) -> Image.Image:
    """반투명 픽셀을 이진화."""
    img = img.copy()
    pixels = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if 0 < a < 255:
                pixels[x, y] = (r, g, b, 255) if a >= threshold else (0, 0, 0, 0)
    return img


def extract_frame(img: Image.Image, bbox: tuple, target_w: int, target_h: int) -> Image.Image:
    """바운딩 박스에서 프레임을 추출, 타이트 크롭 후 target 크기에 맞춤."""
    cropped = img.crop(bbox)
    content = cropped.getbbox()
    if content:
        cropped = cropped.crop(content)

    cw, ch = cropped.size
    if cw == 0 or ch == 0:
        return Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))

    # 90% 영역 내에 맞추기 (약간의 패딩)
    scale = min((target_w * 0.92) / cw, (target_h * 0.92) / ch)
    if scale > 1:
        scale = 1
    new_w = max(1, int(cw * scale))
    new_h = max(1, int(ch * scale))

    resized = cropped.resize((new_w, new_h), Image.NEAREST)

    frame = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    ox = (target_w - new_w) // 2
    oy = target_h - new_h  # 하단 정렬
    frame.paste(resized, (ox, oy), resized)
    return frame


def reduce_colors(img: Image.Image, max_colors: int) -> Image.Image:
    alpha = img.split()[3]
    rgb = img.convert("RGB")
    quantized = rgb.quantize(colors=max_colors, method=Image.Quantize.MEDIANCUT)
    result = quantized.convert("RGBA")
    result.putalpha(alpha)
    return result


def assemble_strip(frames: list, frame_w: int, frame_h: int) -> Image.Image:
    strip = Image.new("RGBA", (frame_w * len(frames), frame_h), (0, 0, 0, 0))
    for i, f in enumerate(frames):
        strip.paste(f, (i * frame_w, 0), f)
    return strip


def validate_strip(img: Image.Image, spec: dict) -> list[str]:
    warnings = []
    expected_w = spec["frame_w"] * spec["frames"]
    expected_h = spec["frame_h"]
    if img.size != (expected_w, expected_h):
        warnings.append(f"크기 불일치: {img.size} != ({expected_w}, {expected_h})")
    pixels = img.load()
    for i in range(spec["frames"]):
        has = any(
            pixels[x, y][3] > 10
            for y in range(spec["frame_h"])
            for x in range(i * spec["frame_w"], min((i + 1) * spec["frame_w"], img.size[0]))
        )
        if not has:
            warnings.append(f"프레임 {i}: 빈 프레임")
    colors = {(pixels[x, y][0], pixels[x, y][1], pixels[x, y][2])
              for y in range(img.size[1]) for x in range(img.size[0])
              if pixels[x, y][3] > 10}
    if len(colors) > spec["max_colors"]:
        warnings.append(f"색상 수 초과: {len(colors)} > {spec['max_colors']} (권장)")
    return warnings


def save_debug_preview(img: Image.Image, spec: dict, output_path: Path):
    scale = 4
    w, h = img.size
    preview = img.resize((w * scale, h * scale), Image.NEAREST)
    pixels = preview.load()
    for i in range(1, spec["frames"]):
        lx = i * spec["frame_w"] * scale
        for y in range(h * scale):
            if y % 4 < 2 and lx < preview.size[0]:
                pixels[lx, y] = (255, 0, 0, 180)
    dp = output_path.with_name(output_path.stem + "_debug.png")
    preview.save(dp)
    print(f"  디버그: {dp}")


# ── 투영 기반 레퍼런스 시트 분석 ──────────────────────────────

def _is_bright_pixel(r: int, g: int, b: int, a: int) -> bool:
    """스프라이트 콘텐츠 픽셀 여부 (그리드 라인/텍스트 제외).

    그리드 라인: 어두운 무채색 (max < 100, 색차 < 30) → False
    텍스트 라벨: 밝은 흰색 (max > 230, 무채색) → False
    실제 스프라이트: 밝고 유채색 → True
    """
    if a <= 10:
        return False
    mx = max(r, g, b)
    mn = min(r, g, b)
    diff = mx - mn
    # 어두운 무채색 (그리드 라인)
    if mx < 100 and diff < 30:
        return False
    # 밝은 무채색 (흰색 텍스트 라벨)
    if mx > 230 and diff < 20:
        return False
    return True


def _find_bands(projection: list[int], min_height: int = 15,
                gap: int = 5, threshold: int = 3
                ) -> list[tuple[int, int]]:
    """투영 프로파일에서 연속된 콘텐츠 구간(밴드) 찾기."""
    bands = []
    in_band = False
    start = 0
    gap_count = 0

    for i, val in enumerate(projection):
        if val >= threshold:
            if not in_band:
                start = i
                in_band = True
            gap_count = 0
        else:
            if in_band:
                gap_count += 1
                if gap_count > gap:
                    end = i - gap_count
                    if end - start >= min_height:
                        bands.append((start, end))
                    in_band = False
                    gap_count = 0

    if in_band:
        end = len(projection) - gap_count
        if end - start >= min_height:
            bands.append((start, end))

    return bands


def _find_sprites_in_band(
    pixels, x_start: int, x_end: int, y_start: int, y_end: int,
    min_width: int = 15
) -> list[tuple[int, int, int, int]]:
    """밴드 내에서 세로 투영(밝은 픽셀만)으로 개별 스프라이트 bbox를 찾는다."""
    band_w = x_end - x_start
    v_proj = [0] * band_w

    for x_offset in range(band_w):
        x = x_start + x_offset
        for y in range(y_start, y_end, 2):
            r, g, b, a = pixels[x, y]
            if _is_bright_pixel(r, g, b, a):
                v_proj[x_offset] += 1

    cols = _find_bands(v_proj, min_height=min_width, gap=3)
    return [(x_start + c0, y_start, x_start + c1, y_end) for c0, c1 in cols]


def _find_vertical_divider(pixels, w: int, h: int) -> int:
    """좌/우 섹션 사이의 수직 분할선 찾기.

    이미지 중앙 40% 영역에서 밝은 픽셀이 가장 적은 열을 탐색.
    """
    x_start = int(w * 0.3)
    x_end = int(w * 0.7)
    min_count = h + 1
    best_x = w // 2

    for x in range(x_start, x_end):
        count = 0
        for y in range(0, h, 4):
            r, g, b, a = pixels[x, y]
            if _is_bright_pixel(r, g, b, a):
                count += 1
        if count < min_count:
            min_count = count
            best_x = x

    return best_x


def _analyze_half(pixels, x0: int, x1: int, h: int, label: str
                  ) -> list[list[tuple[int, int, int, int]]]:
    """이미지의 한쪽 반을 분석하여 스프라이트 행/열을 반환."""
    half_w = x1 - x0

    # 가로 투영 (밝은 픽셀만, 이 반쪽 영역에서만)
    h_proj = [0] * h
    for y in range(h):
        for x in range(x0, x1, 2):
            r, g, b, a = pixels[x, y]
            if _is_bright_pixel(r, g, b, a):
                h_proj[y] += 1

    # 행 밴드 탐지
    # threshold를 반쪽 너비에 비례 (전체의 ~3/너비)
    min_threshold = max(3, half_w // 200)
    row_bands = _find_bands(h_proj, min_height=20, gap=5, threshold=min_threshold)

    sprite_rows = []
    for i, (y0, y1) in enumerate(row_bands):
        sprites = _find_sprites_in_band(pixels, x0, x1, y0, y1)
        if sprites:
            print(f"         {label} 행{i} (y={y0}-{y1}, h={y1-y0}): "
                  f"{len(sprites)}개 스프라이트")
            sprite_rows.append(sprites)

    return sprite_rows


def _analyze_reference_sheet(img: Image.Image
                             ) -> tuple[list[list[tuple]], list[list[tuple]]]:
    """레퍼런스 시트를 좌/우 독립 분석.

    Returns: (left_rows, right_rows) — 각각 [[bbox,...], ...] 형태
    """
    w, h = img.size
    pixels = img.load()

    # 수직 분할선 찾기
    div_x = _find_vertical_divider(pixels, w, h)
    print(f"       수직 분할: x={div_x} (전체 {w})")

    print(f"       [좌측 분석: x=0-{div_x}]")
    left_rows = _analyze_half(pixels, 0, div_x, h, "좌")

    print(f"       [우측 분석: x={div_x}-{w}]")
    right_rows = _analyze_half(pixels, div_x, w, h, "우")

    return left_rows, right_rows


def _select_frames(
    left_rows: list[list[tuple]], right_rows: list[list[tuple]],
    target_frames: int, asset_type: str
) -> list[tuple[int, int, int, int]]:
    """좌/우측 스프라이트 행에서 타입에 맞는 프레임 bbox 선택.

    좌측: IDLE/방향별 정지
    우측: WALK CYCLES
    """
    all_rows = left_rows + right_rows

    def _pick_bboxes(rows, count=4, skip_biggest=False):
        """행 리스트에서 bbox 선택. count개 이상 스프라이트가 있는 행 우선."""
        if not rows:
            return []
        # 스프라이트 수 충분한 행만 필터
        viable = [r for r in rows if len(r) >= count]
        if not viable:
            viable = [r for r in rows if len(r) >= 2]
        if not viable:
            viable = rows

        start = 0
        if skip_biggest and len(viable) >= 2:
            h0 = max(b[3] - b[1] for b in viable[0])
            h1 = max(b[3] - b[1] for b in viable[1])
            if h0 > h1 * 1.3:
                print(f"       큰 상단 행 건너뜀 (h={h0} > {h1})")
                start = 1
        bboxes = viable[start]
        by_area = sorted(bboxes, key=lambda b: -(b[2]-b[0])*(b[3]-b[1]))[:count]
        return sorted(by_area, key=lambda b: b[0])

    if asset_type == "player":
        idle_bboxes = _pick_bboxes(left_rows, 4, skip_biggest=True)
        walk_bboxes = _pick_bboxes(right_rows, 4)

        if not idle_bboxes and all_rows:
            idle_bboxes = _pick_bboxes(all_rows, 4)
        if not walk_bboxes:
            walk_bboxes = idle_bboxes

        print(f"       IDLE: {len(idle_bboxes)}개 (좌측), WALK: {len(walk_bboxes)}개 (우측)")
        return idle_bboxes + walk_bboxes

    elif asset_type == "enemy":
        bboxes = _pick_bboxes(right_rows, 4) or _pick_bboxes(left_rows, 4)
        if not bboxes and all_rows:
            bboxes = _pick_bboxes(all_rows, 4)
        return bboxes or []

    elif asset_type == "boss":
        idle = _pick_bboxes(left_rows, 2)
        attack = _pick_bboxes(right_rows, 2)
        if idle and attack:
            return idle + attack
        return _pick_bboxes(left_rows or right_rows, 4)

    else:
        if target_frames > 4:
            result = []
            for row in all_rows:
                by_area = sorted(row, key=lambda b: -(b[2]-b[0])*(b[3]-b[1]))[:4]
                result.extend(sorted(by_area, key=lambda b: b[0]))
                if len(result) >= target_frames:
                    break
            return result[:target_frames]

        bboxes = _pick_bboxes(left_rows or right_rows, 4)
        if not bboxes and all_rows:
            bboxes = _pick_bboxes(all_rows, 4)
        return bboxes or []


# ── 메인 처리 ──────────────────────────────────────────────────

def process_reference_sheet(
    img: Image.Image, spec: dict, asset_type: str, bg_threshold: int = 20
) -> Image.Image:
    """GPT 참조 시트 → 게임용 스트립 변환."""
    fw = spec["frame_w"]
    fh = spec["frame_h"]
    nf = spec["frames"]

    print("  [1/3] 배경 제거...")
    img = remove_background(img, bg_threshold)
    img = remove_antialiasing(img)
    w, h = img.size

    print(f"  [2/3] 스프라이트 탐지 ({asset_type})...")
    left_rows, right_rows = _analyze_reference_sheet(img)
    bboxes = _select_frames(left_rows, right_rows, nf, asset_type)
    print(f"       선택: {len(bboxes)}개 bbox")

    print("  [3/3] 추출 및 스트립 합성...")
    frames = []
    for bbox in bboxes[:nf]:
        frames.append(extract_frame(img, bbox, fw, fh))

    while len(frames) < nf:
        print(f"       프레임 {len(frames)} 부족 → 복제")
        frames.append(frames[-1].copy() if frames else
                      Image.new("RGBA", (fw, fh), (0, 0, 0, 0)))

    return assemble_strip(frames, fw, fh)


def process_clean_strip(
    img: Image.Image, spec: dict, bg_threshold: int = 20
) -> Image.Image:
    fw, fh, nf = spec["frame_w"], spec["frame_h"], spec["frames"]
    expected_w = fw * nf
    img = remove_background(img, bg_threshold)
    img = remove_antialiasing(img)
    if img.size == (expected_w, fh):
        return img
    src_fw = img.size[0] // nf
    src_fh = img.size[1]
    frames = []
    for i in range(nf):
        bbox = (i * src_fw, 0, (i + 1) * src_fw, src_fh)
        frames.append(extract_frame(img, bbox, fw, fh))
    return assemble_strip(frames, fw, fh)


def process_single(
    input_path: Path, output_path: Path, asset_type: str,
    bg_threshold: int = 20, debug: bool = False,
    force_reference: bool = False, reduce_col: bool = False,
) -> bool:
    spec = ASSET_SPECS[asset_type]
    expected_w = spec["frame_w"] * spec["frames"]
    expected_h = spec["frame_h"]

    print(f"\n{'=' * 60}")
    print(f"처리: {input_path.name}")
    print(f"타입: {asset_type} ({spec['frames']}프레임 x "
          f"{spec['frame_w']}x{spec['frame_h']})")
    print(f"목표: {expected_w}x{expected_h}")
    print(f"{'=' * 60}")

    img = Image.open(input_path).convert("RGBA")
    print(f"  원본: {img.size}")

    is_ref = force_reference
    if not is_ref:
        ratio = img.size[0] / max(img.size[1], 1)
        if ratio < 2 and img.size[1] > expected_h * 2:
            is_ref = True

    if is_ref:
        print("  모드: 레퍼런스 시트")
        result = process_reference_sheet(img, spec, asset_type, bg_threshold)
    else:
        print("  모드: 스트립")
        result = process_clean_strip(img, spec, bg_threshold)

    if reduce_col:
        result = reduce_colors(result, spec["max_colors"])

    warnings = validate_strip(result, spec)
    if warnings:
        print("\n  [경고]")
        for w in warnings:
            print(f"    - {w}")
    else:
        print("\n  [OK] 검증 통과")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    result.save(output_path, "PNG")
    print(f"  출력: {output_path} ({result.size[0]}x{result.size[1]})")

    if debug:
        save_debug_preview(result, spec, output_path)
    return len(warnings) == 0


def process_batch(input_dir, asset_type, output_dir=None, **kw):
    pngs = sorted(input_dir.glob("*.png"))
    if not pngs:
        print(f"PNG 없음: {input_dir}")
        return
    if output_dir is None:
        output_dir = input_dir / "output"
    ok = fail = 0
    for png in pngs:
        out = output_dir / png.name
        try:
            if process_single(png, out, asset_type, **kw):
                ok += 1
            else:
                fail += 1
        except Exception as e:
            print(f"  [실패] {png.name}: {e}")
            fail += 1
    print(f"\n결과: {ok}성공 / {fail}경고 / {len(pngs)}전체")


def main():
    p = argparse.ArgumentParser(description="GPT 스프라이트 → 게임 스트립")
    p.add_argument("input", type=Path)
    p.add_argument("-o", "--output", type=Path, default=None)
    p.add_argument("-t", "--type", required=True, choices=ASSET_SPECS.keys())
    p.add_argument("--bg-threshold", type=int, default=20)
    p.add_argument("--debug", action="store_true")
    p.add_argument("--reference", action="store_true")
    p.add_argument("--reduce-colors", action="store_true")
    p.add_argument("--batch", action="store_true")
    args = p.parse_args()

    if args.batch:
        process_batch(args.input, args.type, args.output,
                      bg_threshold=args.bg_threshold, debug=args.debug,
                      force_reference=args.reference, reduce_col=args.reduce_colors)
    else:
        out = args.output or args.input.with_name(args.input.stem + "_clean.png")
        process_single(args.input, out, args.type,
                       bg_threshold=args.bg_threshold, debug=args.debug,
                       force_reference=args.reference, reduce_col=args.reduce_colors)


if __name__ == "__main__":
    main()

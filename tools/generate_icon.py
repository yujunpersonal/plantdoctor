"""Generate the 1024x1024 Leafwise app icon.

Run: python3 tools/generate_icon.py

Produces plantdoctor/Assets.xcassets/AppIcon.appiconset/Icon-1024.png
and dark / tinted variants.
"""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
OUT_DIR = Path(__file__).resolve().parent.parent / "plantdoctor/Assets.xcassets/AppIcon.appiconset"

# Brand palette
LEAF_DEEP = (46, 125, 50)       # #2E7D32
LEAF_MID = (76, 175, 80)        # #4CAF50
LEAF_LIGHT = (200, 230, 201)    # #C8E6C9
CREAM = (251, 247, 238)         # #FBF7EE
SOIL = (93, 64, 55)              # #5D4037


def gradient_background(size: int, top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    img = Image.new("RGB", (size, size), top)
    for y in range(size):
        t = y / (size - 1)
        r = int(top[0] * (1 - t) + bottom[0] * t)
        g = int(top[1] * (1 - t) + bottom[1] * t)
        b = int(top[2] * (1 - t) + bottom[2] * t)
        for x in range(size):
            img.putpixel((x, y), (r, g, b))
    return img


def gradient_background_fast(size: int, top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    strip = Image.new("RGB", (1, size))
    for y in range(size):
        t = y / (size - 1)
        r = int(top[0] * (1 - t) + bottom[0] * t)
        g = int(top[1] * (1 - t) + bottom[1] * t)
        b = int(top[2] * (1 - t) + bottom[2] * t)
        strip.putpixel((0, y), (r, g, b))
    return strip.resize((size, size))


def draw_leaf(base: Image.Image, *, fill: tuple[int, int, int], vein_color: tuple[int, int, int]) -> Image.Image:
    w, h = base.size
    cx, cy = w / 2, h / 2

    # Leaf: two arcs meeting at top and bottom (classic leaf silhouette),
    # rotated slightly. Build on a supersample canvas for smoothness.
    ss = 2
    canvas = Image.new("RGBA", (w * ss, h * ss), (0, 0, 0, 0))
    cd = ImageDraw.Draw(canvas)

    W, H = w * ss, h * ss
    CX, CY = W / 2, H / 2

    # Leaf proportions
    leaf_w = W * 0.46
    leaf_h = H * 0.72

    # Bezier-like leaf shape via polygon samples
    points = []
    steps = 180
    for i in range(steps + 1):
        t = i / steps
        # Parametric leaf: x = a * sin(pi * t) * (1 - 0.05*t), y goes top->bottom
        angle = math.pi * t
        x = CX + math.sin(angle) * (leaf_w / 2) * (1 - 0.08 * (0.5 - abs(t - 0.5)) * 2)
        y = CY - leaf_h / 2 + t * leaf_h
        points.append((x, y))
    for i in range(steps + 1):
        t = i / steps
        angle = math.pi * t
        x = CX - math.sin(angle) * (leaf_w / 2) * (1 - 0.08 * (0.5 - abs(t - 0.5)) * 2)
        y = CY + leaf_h / 2 - t * leaf_h
        points.append((x, y))

    # Rotate leaf 16° via affine on the polygon
    theta = math.radians(-14)
    cos_t, sin_t = math.cos(theta), math.sin(theta)
    def rot(p):
        x, y = p
        dx, dy = x - CX, y - CY
        return (CX + dx * cos_t - dy * sin_t, CY + dx * sin_t + dy * cos_t)
    points = [rot(p) for p in points]

    cd.polygon(points, fill=(*fill, 255))

    # Central midrib
    rib_top = rot((CX, CY - leaf_h / 2 + leaf_h * 0.03))
    rib_bottom = rot((CX, CY + leaf_h / 2 - leaf_h * 0.03))
    cd.line([rib_top, rib_bottom], fill=(*vein_color, 210), width=int(W * 0.012))

    # Side veins
    for t in (0.22, 0.38, 0.55, 0.72):
        y = CY - leaf_h / 2 + t * leaf_h
        mid = rot((CX, y))
        left_end = rot((CX - leaf_w * 0.34 * (1 - abs(t - 0.5)), y - leaf_h * 0.06))
        right_end = rot((CX + leaf_w * 0.34 * (1 - abs(t - 0.5)), y - leaf_h * 0.06))
        cd.line([mid, left_end], fill=(*vein_color, 160), width=int(W * 0.006))
        cd.line([mid, right_end], fill=(*vein_color, 160), width=int(W * 0.006))

    # Medical plus cross near base, carved in light via overlay
    plus_cx, plus_cy = rot((CX + leaf_w * 0.12, CY + leaf_h * 0.30))
    arm_len = W * 0.06
    arm_thick = W * 0.022
    cd.rounded_rectangle(
        [plus_cx - arm_len, plus_cy - arm_thick, plus_cx + arm_len, plus_cy + arm_thick],
        radius=arm_thick * 0.5,
        fill=(*CREAM, 235),
    )
    cd.rounded_rectangle(
        [plus_cx - arm_thick, plus_cy - arm_len, plus_cx + arm_thick, plus_cy + arm_len],
        radius=arm_thick * 0.5,
        fill=(*CREAM, 235),
    )

    canvas = canvas.resize((w, h), Image.Resampling.LANCZOS)
    # Drop a soft inner glow
    glow = canvas.filter(ImageFilter.GaussianBlur(radius=6))
    result = base.convert("RGBA")
    result.alpha_composite(glow)
    result.alpha_composite(canvas)
    return result


def build_variant(mode: str) -> Image.Image:
    if mode == "light":
        bg = gradient_background_fast(SIZE, LEAF_LIGHT, LEAF_DEEP)
        return draw_leaf(bg, fill=LEAF_DEEP, vein_color=CREAM)
    if mode == "dark":
        bg = gradient_background_fast(SIZE, (22, 40, 24), (12, 24, 14))
        return draw_leaf(bg, fill=LEAF_MID, vein_color=LEAF_LIGHT)
    if mode == "tinted":
        bg = gradient_background_fast(SIZE, (70, 70, 70), (20, 20, 20))
        return draw_leaf(bg, fill=(210, 210, 210), vein_color=(245, 245, 245))
    raise ValueError(mode)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for mode, name in (("light", "Icon-1024.png"), ("dark", "Icon-1024-dark.png"), ("tinted", "Icon-1024-tinted.png")):
        img = build_variant(mode).convert("RGB")
        img.save(OUT_DIR / name, format="PNG", optimize=True)
        print(f"wrote {OUT_DIR / name}")


if __name__ == "__main__":
    main()

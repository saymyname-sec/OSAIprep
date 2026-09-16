#!/usr/bin/env python3
"""
stamp-timestamp.py -- overlay a UTC + local TIME/DATE stamp on a PNG.
Idempotent-ish: appends a footer bar; if you run it twice you get two bars.

Usage:
    stamp-timestamp.py IMAGE.png                    # write in place
    stamp-timestamp.py SRC.png OUT.png              # write to OUT
    stamp-timestamp.py --host HOSTNAME IMAGE.png    # include a host label
"""
import sys
from datetime import datetime, timezone
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

FONT_PATH = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"
FONT_PATH_FALLBACK = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
FONT_SIZE = 14
BAR_BG = (200, 20, 20)  # red, so it stands out on any screenshot
BAR_FG = (255, 255, 255)
PAD_X = 10
PAD_Y = 6

def load_font(size=FONT_SIZE):
    for p in (FONT_PATH, FONT_PATH_FALLBACK):
        try:
            return ImageFont.truetype(p, size)
        except OSError:
            continue
    return ImageFont.load_default()

def stamp(src_path: Path, out_path: Path, host: str | None = None) -> None:
    now_utc = datetime.now(timezone.utc)
    now_local = datetime.now().astimezone()
    stamp_utc   = now_utc.strftime("%Y-%m-%d %H:%M:%S UTC")
    stamp_local = now_local.strftime("%Y-%m-%d %H:%M:%S %Z%z")
    line = f"CAPTURED  {stamp_utc}  |  local {stamp_local}"
    if host:
        line += f"  |  {host}"

    img = Image.open(src_path).convert("RGB")
    font = load_font()
    tmp = ImageDraw.Draw(img)
    bbox = tmp.textbbox((0, 0), line, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    bar_h  = text_h + PAD_Y * 2

    new_h = img.height + bar_h
    out = Image.new("RGB", (img.width, new_h), (0, 0, 0))
    out.paste(img, (0, 0))

    d = ImageDraw.Draw(out)
    d.rectangle([0, img.height, img.width, new_h], fill=BAR_BG)
    # Center the text; anchor is the top-left, so position accordingly
    x = max(PAD_X, (img.width - text_w) // 2)
    y = img.height + PAD_Y
    d.text((x, y), line, fill=BAR_FG, font=font)

    out.save(out_path, "PNG", optimize=True)

def main() -> int:
    args = sys.argv[1:]
    host = None
    if len(args) >= 2 and args[0] == "--host":
        host = args[1]
        args = args[2:]
    if len(args) == 1:
        src = out = Path(args[0])
    elif len(args) == 2:
        src, out = Path(args[0]), Path(args[1])
    else:
        print("usage: stamp-timestamp.py [--host HOST] IMAGE.png [OUT.png]", file=sys.stderr)
        return 2
    stamp(src, out, host)
    print(str(out))
    return 0

if __name__ == "__main__":
    sys.exit(main())

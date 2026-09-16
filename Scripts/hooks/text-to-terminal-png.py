#!/usr/bin/env python3
"""
text-to-terminal-png.py -- render stdin (or a file) as a dark terminal-styled PNG.
Sidesteps ImageMagick's default path policy by using Pillow directly.

Usage:
    text-to-terminal-png.py OUT.png            # reads stdin
    text-to-terminal-png.py OUT.png FILE       # reads FILE
"""
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

BG = (13, 13, 23)
FG = (229, 229, 229)
DIM = (150, 150, 155)
FONT_PATH = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
FONT_SIZE = 14
PAD = 20
LINE_WRAP = 140  # chars per line before soft wrap

def wrap(text: str, width: int = LINE_WRAP) -> list[str]:
    out = []
    for raw in text.splitlines() or [""]:
        if not raw:
            out.append("")
            continue
        while len(raw) > width:
            out.append(raw[:width])
            raw = raw[width:]
        out.append(raw)
    return out

def main() -> int:
    if len(sys.argv) < 2:
        print("usage: text-to-terminal-png.py OUT.png [FILE]", file=sys.stderr)
        return 2
    out_path = Path(sys.argv[1])
    if len(sys.argv) >= 3:
        text = Path(sys.argv[2]).read_text(encoding="utf-8", errors="replace")
    else:
        text = sys.stdin.read()

    lines = wrap(text)
    if not lines:
        lines = ["(empty)"]

    try:
        font = ImageFont.truetype(FONT_PATH, FONT_SIZE)
    except OSError:
        font = ImageFont.load_default()

    # Measure
    tmp = Image.new("RGB", (10, 10), BG)
    draw = ImageDraw.Draw(tmp)
    # Use a canonical char to size line height / width
    bbox = draw.textbbox((0, 0), "M", font=font)
    ch_w = bbox[2] - bbox[0]
    line_h = int((bbox[3] - bbox[1]) * 1.5)
    max_line = max((len(l) for l in lines), default=0)
    width  = max(400, PAD * 2 + max_line * ch_w)
    height = PAD * 2 + line_h * len(lines) + 8

    img = Image.new("RGB", (width, height), BG)
    d = ImageDraw.Draw(img)
    # Faint terminal-title stripe at the top
    d.rectangle([0, 0, width, 22], fill=(24, 24, 34))
    d.text((PAD, 4), "osai — /home/kali", fill=DIM, font=font)

    y = 26 + PAD
    for line in lines:
        d.text((PAD, y), line, fill=FG, font=font)
        y += line_h

    img.save(out_path, "PNG", optimize=True)
    print(str(out_path))
    return 0

if __name__ == "__main__":
    sys.exit(main())

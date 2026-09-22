#!/usr/bin/env python3
"""Capture actual Ly PTY output as asciicast, text, PNG and optional GIF.

Optional image dependencies: pyte==0.8.2 and Pillow. No graphical mock UI.
"""
import argparse
import codecs
import fcntl
import json
import os
from pathlib import Path
import pty
import select
import signal
import struct
import subprocess
import termios
import time

import pyte
from PIL import Image, ImageDraw, ImageFont

from build import stage


def dimensions(value):
    w, h = map(int, value.lower().split("x"))
    if w < 1 or h < 1:
        raise argparse.ArgumentTypeError("Dimensions must be positive")
    return w, h


def render(screen, font):
    cw, ch = 10, 20
    image = Image.new("RGB", (screen.columns*cw, screen.lines*ch), "#e5e7e6")
    draw = ImageDraw.Draw(image)
    palette = {"default": "#1b2023", "black": "#000000", "white": "#ffffff",
               "red": "#b83f00", "green": "#168040", "blue": "#2056b0",
               "brown": "#b09020", "magenta": "#a050a0", "cyan": "#308080"}
    def color(value, default):
        if value == "default": return default
        return palette.get(value, "#" + value if len(value) == 6 else default)
    for y in range(screen.lines):
        for x in range(screen.columns):
            cell = screen.buffer[y][x]
            fg, bg = color(cell.fg, "#1b2023"), color(cell.bg, "#e5e7e6")
            if cell.reverse: fg, bg = bg, fg
            draw.rectangle((x*cw, y*ch, (x+1)*cw-1, (y+1)*ch-1), fill=bg)
            if cell.data == "█":
                draw.rectangle((x*cw, y*ch, (x+1)*cw-1, (y+1)*ch-1), fill=fg)
            elif cell.data == "─":
                draw.line((x*cw, y*ch+10, (x+1)*cw-1, y*ch+10), fill=fg)
            else:
                draw.text((x*cw, y*ch-1), cell.data, font=font, fill=fg,
                          stroke_width=0)
    return image


def capture(args):
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    config = stage(output / "config", output / "config", preview=True)
    subprocess.run(["ly-dm", "--validate-config", str(config / "config.lua")], check=True)
    w, h = args.size
    screen = pyte.Screen(w, h)
    stream = pyte.Stream(screen)
    decoder = codecs.getincrementaldecoder("utf-8")("replace")
    font_path = subprocess.check_output(["fc-match", "-f", "%{file}", "monospace"], text=True)
    font = ImageFont.truetype(font_path, 16)
    pid, fd = pty.fork()
    if pid == 0:
        fcntl.ioctl(0, termios.TIOCSWINSZ, struct.pack("HHHH", h, w, 0, 0))
        os.environ["TERM"] = "xterm-256color"
        os.environ["COLORTERM"] = "truecolor"
        os.execvp("ly-dm", ["ly-dm", "-c", str(config)])
    frames, events = [], []
    start = time.monotonic()
    next_frame, resized = 0, False
    try:
        while time.monotonic()-start < args.seconds:
            elapsed = time.monotonic()-start
            if args.resize and elapsed >= args.seconds/2 and not resized:
                w, h = args.resize
                fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", h, w, 0, 0))
                os.kill(pid, signal.SIGWINCH)
                screen.resize(h, w)
                events.append([round(elapsed, 6), "r", f"{w}x{h}"])
                resized = True
            if select.select([fd], [], [], 0.02)[0]:
                try: data = os.read(fd, 65536)
                except OSError: break
                if not data: break
                text = decoder.decode(data)
                stream.feed(text)
                events.append([round(elapsed, 6), "o", text])
                if b"\x1b[6n" in data:
                    os.write(fd, b"\x1b[1;1R")
            if args.gif and elapsed >= next_frame:
                frames.append(render(screen, font))
                next_frame += 0.1
        render(screen, font).save(output / "preview.png")
        (output / "screen.txt").write_text("\n".join(screen.display) + "\n")
        header = {"version": 2, "width": args.size[0], "height": args.size[1],
                  "title": "PRTS Analysis OS — actual Ly PTY", "env": {"TERM": "xterm-256color"}}
        (output / "preview.cast").write_text("\n".join(json.dumps(x) for x in [header, *events])+"\n")
        if frames:
            frames[0].save(output / "preview.gif", save_all=True, append_images=frames[1:],
                           duration=100, loop=0, disposal=2)
    finally:
        try: os.kill(pid, signal.SIGTERM)
        except ProcessLookupError: pass
        # Bounded cleanup even if a greeter ignores TERM.
        for _ in range(20):
            if os.waitpid(pid, os.WNOHANG)[0]: break
            time.sleep(0.05)
        else:
            os.kill(pid, signal.SIGKILL)
            os.waitpid(pid, 0)
        os.close(fd)
    text = "\n".join(screen.display)
    if "lua animation failed" in text or "cannot call draw" in text or "password" not in text:
        raise RuntimeError(f"Ly preview failed; inspect {output / 'screen.txt'}")
    print(output / "preview.png")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--size", type=dimensions, default=(100, 30))
    parser.add_argument("--resize", type=dimensions)
    parser.add_argument("--seconds", type=float, default=4)
    parser.add_argument("--gif", action="store_true")
    parser.add_argument("--output", type=Path, default=Path("build/capture"))
    args = parser.parse_args()
    if args.gif and args.resize: parser.error("Capture resize separately from fixed-size GIF")
    capture(args)

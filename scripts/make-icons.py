#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成 App 图标（纯 Python，无第三方依赖）"""
import os
import struct
import zlib

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "app", "res")
SIZES = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}

BG_TOP = (16, 20, 26)
BG_BOT = (27, 38, 52)
CYAN = (77, 208, 225)
WHITE = (236, 248, 255)
DARK = (14, 20, 27)


def lerp(a, b, t):
    return tuple(int(round(a[i] + (b[i] - a[i]) * t)) for i in range(3))


def rounded_rect(x, y, w, h, r):
    """返回 (x,y) 是否落在圆角矩形内"""
    cx = min(max(x, r), w - r)
    cy = min(max(y, r), h - r)
    dx = x - cx
    dy = y - cy
    return (dx * dx + dy * dy) <= r * r


def bubble(x, y, w, h):
    """聊天气泡：主体圆角矩形 + 左下角小尾巴"""
    bx0, bx1 = 0.24 * w, 0.76 * w
    by0, by1 = 0.26 * h, 0.62 * h
    rad = 0.10 * h
    if bx0 <= x <= bx1 and by0 <= y <= by1:
        cx = min(max(x, bx0 + rad), bx1 - rad)
        cy = min(max(y, by0 + rad), by1 - rad)
        if (x - cx) ** 2 + (y - cy) ** 2 <= rad * rad:
            return True
    # 尾巴
    if by1 <= y <= 0.74 * h:
        t = (y - by1) / (0.74 * h - by1)
        lx = bx0 + 0.06 * w
        rx = bx0 + 0.22 * w - t * 0.10 * w
        if lx <= x <= rx:
            return True
    return False


def dot(x, y, w, h, fx, fy, r):
    return (x - fx * w) ** 2 + (y - fy * h) ** 2 <= r * r


def pixel(x, y, w, h):
    """返回 (r,g,b,a)"""
    # 圆角方形底
    if not rounded_rect(x, y, w, h, 0.22 * w):
        return (0, 0, 0, 0)
    bg = lerp(BG_TOP, BG_BOT, y / float(h))
    # 气泡
    if bubble(x, y, w, h):
        col = CYAN
        # 三个小点（白色）
        for fx in (0.36, 0.50, 0.64):
            if dot(x, y, w, h, fx, 0.44, 0.032 * w):
                col = WHITE
        return (col[0], col[1], col[2], 255)
    return (bg[0], bg[1], bg[2], 255)


def write_png(path, size, ss=3):
    w = h = size
    rows = []
    for y in range(h):
        row = bytearray([0])  # filter 0
        for x in range(w):
            acc = [0, 0, 0, 0]
            for sy in range(ss):
                for sx in range(ss):
                    px = x + (sx + 0.5) / ss
                    py = y + (sy + 0.5) / ss
                    r, g, b, a = pixel(px, py, float(w), float(h))
                    acc[0] += r * a
                    acc[1] += g * a
                    acc[2] += b * a
                    acc[3] += a
            n = ss * ss
            if acc[3] == 0:
                row += bytes((0, 0, 0, 0))
            else:
                row += bytes((
                    int(acc[0] / acc[3]),
                    int(acc[1] / acc[3]),
                    int(acc[2] / acc[3]),
                    int(acc[3] / n),
                ))
        rows.append(bytes(row))
    raw = b"".join(rows)

    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data
                + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))

    png = (b"\x89PNG\r\n\x1a\n"
           + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
           + chunk(b"IDAT", zlib.compress(raw, 9))
           + chunk(b"IEND", b""))
    with open(path, "wb") as f:
        f.write(png)
    return len(png)


def main():
    total = 0
    for name, size in SIZES.items():
        d = os.path.join(OUT, "mipmap-" + name)
        os.makedirs(d, exist_ok=True)
        p = os.path.join(d, "ic_launcher.png")
        n = write_png(p, size)
        total += n
        print("  %-28s %4dpx  %6d B" % ("mipmap-" + name + "/ic_launcher.png", size, n))
    print("图标生成完成，共 %d 字节" % total)


if __name__ == "__main__":
    main()

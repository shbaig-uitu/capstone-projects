#!/usr/bin/env python3
"""Small dependency-free P6 PPM -> PNG converter for simulation evidence."""
import pathlib, struct, sys, zlib

def read_ppm(path):
    data = path.read_bytes()
    pos = 0
    tokens = []
    while len(tokens) < 4:
        while pos < len(data) and data[pos] in b' \t\r\n': pos += 1
        if pos < len(data) and data[pos] == ord('#'):
            while pos < len(data) and data[pos] not in b'\r\n': pos += 1
            continue
        start = pos
        while pos < len(data) and data[pos] not in b' \t\r\n': pos += 1
        tokens.append(data[start:pos])
    magic, ws, hs, maxv = tokens
    if magic != b'P6' or maxv != b'255':
        raise ValueError(f"Unsupported PPM format in {path}")
    while pos < len(data) and data[pos] in b' \t\r\n': pos += 1
    return int(ws), int(hs), data[pos:pos + int(ws) * int(hs) * 3]

def chunk(kind, payload):
    return struct.pack('>I', len(payload)) + kind + payload + struct.pack('>I', zlib.crc32(kind + payload) & 0xffffffff)

def write_png(path, w, h, rgb):
    raw = b''.join(b'\x00' + rgb[y*w*3:(y+1)*w*3] for y in range(h))
    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
    png += chunk(b'IDAT', zlib.compress(raw, 6))
    png += chunk(b'IEND', b'')
    path.write_bytes(png)

def main():
    if len(sys.argv) != 3:
        raise SystemExit("usage: ppm_to_png.py <ppm_dir> <png_dir>")
    src, dst = map(pathlib.Path, sys.argv[1:])
    dst.mkdir(parents=True, exist_ok=True)
    for ppm in sorted(src.glob('frame_*.ppm')):
        w, h, rgb = read_ppm(ppm)
        if len(rgb) != w*h*3:
            raise SystemExit(f"Incomplete image: {ppm}")
        out = dst / (ppm.stem + '.png')
        write_png(out, w, h, rgb)
        print(f"PNG: {out}")

if __name__ == '__main__':
    main()

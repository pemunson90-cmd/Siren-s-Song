"""Rebuild the seven original regional beds; Python standard library only.

Run from any directory. No downloaded/source recordings or runtime synthesis.
Integer Fourier bins make 12-second loops periodic without boundary transients.
Broad, slow textures deliberately avoid sonar chirps, warning pulses and impacts.
"""
from pathlib import Path
import hashlib
import math
import random
import struct
import wave

RATE = 22050
SECONDS = 12
FRAMES = RATE * SECONDS
DEST = Path(__file__).resolve().parents[1] / "game/assets/audio/regions"
# name, seed, low-frequency centre, spectral width, upper-air strength, swell
PROFILES = (
    ("shelf", 5301, 96, 70, .16, .08),
    ("divergence_deep", 5302, 43, 26, .025, .18),
    ("divergence_shelf", 5303, 137, 95, .20, .11),
    ("confluence", 5304, 76, 54, .10, .27),
    ("glass", 5305, 181, 132, .27, .12),
    ("iron", 5306, 62, 34, .055, .10),
    ("calder", 5307, 36, 24, .035, .23),
)


def build(name, seed, centre, width, air, swell):
    rng = random.Random(seed)
    bins = []
    for _ in range(48):
        frequency = max(24, min(700, rng.gauss(centre, width)))
        bins.append((round(frequency * SECONDS), rng.random() * math.tau, 1.0))
    for _ in range(16):
        bins.append((round(rng.uniform(430, 1100) * SECONDS), rng.random() * math.tau, air))
    # Oscillator recurrence avoids millions of trigonometric calls at generation time.
    values = [0.0] * FRAMES
    for bin_index, phase, gain in bins:
        step = math.tau * bin_index / FRAMES
        c, s = math.cos(step), math.sin(step)
        x, y = math.cos(phase), math.sin(phase)
        for i in range(FRAMES):
            values[i] += y * gain
            x, y = x*c-y*s, y*c+x*s
    for i in range(FRAMES):
        values[i] *= 1.0 + swell * math.sin(math.tau*i/FRAMES)
    dc = sum(values) / FRAMES
    peak = max(abs(value-dc) for value in values)
    pcm = b"".join(struct.pack("<h", round((value-dc)/peak*.42*32767)) for value in values)
    path = DEST / f"{name}.wav"
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(pcm)
    resource = f"res://assets/audio/regions/{name}.wav"
    imported = f"res://.godot/imported/{name}.wav-{hashlib.md5(resource.encode()).hexdigest()}.sample"
    Path(str(path)+".import").write_text(
        f'[remap]\n\nimporter="wav"\ntype="AudioStreamWAV"\npath="{imported}"\n\n'
        f'[deps]\n\nsource_file="{resource}"\ndest_files=["{imported}"]\n\n'
        '[params]\n\nforce/8_bit=false\nforce/mono=true\nforce/max_rate=false\n'
        'force/max_rate_hz=22050\nedit/trim=false\nedit/normalize=false\n'
        f'edit/loop_mode=2\nedit/loop_begin=0\nedit/loop_end={FRAMES-1}\ncompress/mode=0\n',
        encoding="utf-8")
    print(f"{name}: {FRAMES} frames, {len(pcm)} PCM bytes, sha256 {hashlib.sha256(path.read_bytes()).hexdigest()}")


if __name__ == "__main__":
    DEST.mkdir(parents=True, exist_ok=True)
    for profile in PROFILES:
        build(*profile)

"""Exercise the actual renderer with synthetic video; no API or user media."""
import json
import subprocess
import sys
from pathlib import Path

root = Path(__file__).resolve().parents[1]
out = root / 'smoke-output'
out.mkdir(exist_ok=True)
subprocess.run([
    'ffmpeg', '-y', '-v', 'error', '-f', 'lavfi', '-i',
    'testsrc2=size=640x360:rate=24', '-f', 'lavfi', '-i',
    'sine=frequency=440:sample_rate=48000', '-t', '4',
    '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-c:a', 'aac',
    str(out / 'source.mp4'),
], check=True)
(out / 'edl.json').write_text(json.dumps({
    'sources': {'demo': 'source.mp4'},
    'ranges': [
        {'source': 'demo', 'start': 0, 'end': 1},
        {'source': 'demo', 'start': 2, 'end': 3},
    ],
}))
subprocess.run([
    sys.executable, str(root / 'helpers/render.py'), str(out / 'edl.json'),
    '-o', str(out / 'final.mp4'), '--no-subtitles',
], check=True)
duration = float(subprocess.check_output([
    'ffprobe', '-v', 'error', '-show_entries', 'format=duration',
    '-of', 'default=noprint_wrappers=1:nokey=1', str(out / 'final.mp4'),
], text=True))
if not 1.8 <= duration <= 2.3:
    raise SystemExit(f'Duree inattendue : {duration}')
print(f'Rendu reel OK : {duration:.2f} secondes')

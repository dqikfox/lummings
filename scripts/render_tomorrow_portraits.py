"""Export all 80 Tomorrow Crew portraits to each website asset directory."""
from pathlib import Path
import sys
import re
import xml.etree.ElementTree as ET
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'src'))
from lummings.artwork import PROFILES, MOODS, render

def main():
 folders=[ROOT/'brand/portraits',ROOT/'docs/portraits',ROOT/'docs/assets/portraits']
 for folder in folders:
  folder.mkdir(parents=True,exist_ok=True)
  for name in PROFILES:
   for mood in MOODS:
    svg=render(name,mood); ET.fromstring(svg)
    (folder/f'{name}-{mood}.svg').write_text(svg,encoding='utf-8')
 # Keep the drawings embedded in both landing pages in sync as well.
 for file in ('docs/index.html', 'site/index.html'):
  page = ROOT / file
  text = page.read_text(encoding='utf-8')
  counter = [0]
  names = list(PROFILES)
  def update(match):
   old = match.group()
   if '0 0 240 240' not in old:
    return old
   i = counter[0]
   counter[0] += 1
   featured = 'featured-' in old
   name = 'lumo' if featured else names[i % 5]
   svg = render(name, 'curious')
   for ident in ('body', 'halo', 'checker'):
    unique = f'inline-{i}-{name}-{ident}'
    svg = svg.replace(f'id="{ident}"', f'id="{unique}"').replace(f'url(#{ident})', f'url(#{unique})')
   if featured or i == 10:
    svg = svg.replace('width="240" height="240"', 'style="background:#2a3142;border-radius:1rem;width:100%;max-width:400px"')
   return svg
  text = re.sub(r'<svg\b.*?</svg>', update, text, flags=re.S)
  page.write_text(text, encoding='utf-8')
 print(f'Updated {len(PROFILES)*len(MOODS)*len(folders)} SVG portraits across {len(folders)} directories.')
if __name__=='__main__': main()

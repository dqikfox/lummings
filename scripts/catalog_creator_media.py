"""Index explicitly selected creator media without changing any original file.

Run from any directory: python scripts/catalog_creator_media.py --root PROJECT
Requires Pillow and ffmpeg/ffprobe on PATH. The output is deterministic for the
same source bytes. Duplicate bytes produce one item with additional source paths.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import textwrap

from PIL import Image, ImageDraw, ImageFont, ImageOps


CHARACTERS = ('lumo', 'lila', 'pip', 'nori', 'moki')
PREVIEWS = Path('data/creator/media-previews')
# Descriptions refer only to the sampled poster, not a full playback/audio review.
VIDEO_POSTER_TITLES = {
    '020e5b5a': 'Nori with a lantern by the water',
    '0459c2ea': 'Lila in the glowing library',
    '07c56489': 'Illustrated crew in the moonlit forest',
    '117302ff': 'Pip with the glowing acorn',
    '39fac360': 'Moki in the lantern workshop',
    '560ce546': 'Lila with a glowing wand',
    '58ae86d6': 'Lumo with headphones and controller',
    '72fcb058': 'Illustrated crew brand presentation',
    '7c7c9d47': 'Moki with floating music notes',
    '9aff50d6': 'Alternate cast and earlier names',
    'b9b26340': 'Lumo holding the crystal controller',
    'd4451075': 'Pip in the glowing forest',
    'd6097689': 'Nori raising a lantern',
    'db6384f5': 'Lumo in the glowing workshop',
}


def digest(path):
    with path.open('rb') as handle:
        return hashlib.file_digest(handle, 'sha256').hexdigest()


def selected_sources(root):
    """Keep the scope explicit; never recursively ingest archive copies."""
    for name in CHARACTERS:
        yield (Path(f'marketing/demo-assets/{name}-portrait.png'),
               f'{name.title()} — current illustrated portrait', 'current-portrait', 'image')
    inventory = json.loads((root / 'docs/living-lummings/extracted-assets/image-inventory.json').read_text(encoding='utf-8-sig'))
    descriptions = {row['path'].replace('\\', '/'): row for row in inventory}
    for path in sorted((root / 'imagine_images/imagine_images').glob('*.jpg')):
        relative = path.relative_to(root)
        row = descriptions.get(relative.as_posix(), {})
        title = row.get('visual_description', path.stem)
        if row.get('number'):
            title = f"Concept {row['number']:02d} — {title}"
        yield relative, title, 'concept', 'image'
    for number, path in enumerate(sorted((root / 'imagine_videos/imagine_videos').glob('*.mp4')), 1):
        title = VIDEO_POSTER_TITLES.get(path.stem[:8], path.stem[:8])
        yield path.relative_to(root), f'Video {number:02d} — {title}', 'video', 'video'
    yield Path('lummings-heartlight-story.mp4'), 'Lummings Heartlight story', 'video', 'video'


def image_preview(source, destination):
    with Image.open(source) as original:
        width, height = original.size
        picture = ImageOps.exif_transpose(original).convert('RGBA')
        picture.thumbnail((640, 640), Image.Resampling.LANCZOS)
        background = Image.new('RGBA', picture.size, '#141a2c')
        background.alpha_composite(picture)
        background.convert('RGB').save(destination, 'JPEG', quality=85, optimize=True)
    return {'width': width, 'height': height}


def video_preview(source, destination, ffmpeg, ffprobe):
    response = subprocess.run([ffprobe, '-v', 'error', '-show_streams', '-show_format', '-of', 'json', str(source)],
                              check=True, capture_output=True, text=True)
    details = json.loads(response.stdout)
    video = next(stream for stream in details['streams'] if stream['codec_type'] == 'video')
    duration = float(details.get('format', {}).get('duration', video.get('duration', 0)))
    # One representative still, not a review of complete playback or audio.
    timestamp = min(1.0, duration / 4)
    subprocess.run([ffmpeg, '-v', 'error', '-y', '-ss', str(timestamp), '-i', str(source),
                    '-frames:v', '1', '-vf', "scale=640:640:force_original_aspect_ratio=decrease",
                    '-q:v', '3', str(destination)], check=True, capture_output=True)
    return {'width': int(video['width']), 'height': int(video['height']),
            'duration': round(duration, 3),
            'hasAudio': any(stream['codec_type'] == 'audio' for stream in details['streams'])}


def contact_sheet(root, items):
    videos = [item for item in items if item['kind'] == 'video']
    columns, cell_width, cell_height = 3, 420, 310
    rows = (len(videos) + columns - 1) // columns
    sheet = Image.new('RGB', (columns * cell_width, 82 + rows * cell_height), '#111827')
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default(size=16)
    small = ImageFont.load_default(size=13)
    draw.text((18, 14), 'Lummings extracted videos - poster inventory', font=font, fill='#ffffff')
    draw.text((18, 42), 'Single sampled frame per video. Audio presence is metadata; audio has not been reviewed.', font=small, fill='#cbd5e1')
    for index, item in enumerate(videos):
        x, y = (index % columns) * cell_width + 12, 82 + (index // columns) * cell_height
        with Image.open(root / item['preview']) as image:
            preview = ImageOps.contain(image, (396, 218))
            sheet.paste(preview, (x + (396 - preview.width) // 2, y))
        title = f"{index + 1:02d}. {item['title']}".replace('—', '-')
        draw.multiline_text((x, y + 222), '\n'.join(textwrap.wrap(title, width=45)), font=small, fill='#ffffff', spacing=3)
        info = f"{item['width']}x{item['height']} | {item['duration']:g}s | audio: {'present' if item['hasAudio'] else 'absent'}"
        draw.text((x, y + 270), info, font=small, fill='#b8c8dd')
    output = root / 'docs/living-lummings/extracted-assets/video-inventory.jpg'
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output, quality=90, optimize=True)


def build_catalog(root, ffmpeg='ffmpeg', ffprobe='ffprobe'):
    root = Path(root).resolve()
    destination = root / PREVIEWS
    destination.mkdir(parents=True, exist_ok=True)
    items, seen = [], {}
    for relative, title, category, kind in selected_sources(root):
        source = (root / relative).resolve(strict=True)
        source.relative_to(root)  # Reject any symlink escaping the project.
        sha256 = digest(source)
        if sha256 in seen:
            seen[sha256].setdefault('additionalSources', []).append(relative.as_posix())
            continue
        identifier = f'{kind}-{sha256}'
        preview = PREVIEWS / f'{identifier}.jpg'
        metadata = (image_preview(source, root / preview) if kind == 'image' else
                    video_preview(source, root / preview, ffmpeg, ffprobe))
        if digest(source) != sha256:
            raise RuntimeError(f'Source changed during indexing: {relative}')
        item = {'id': identifier, 'title': title, 'kind': kind, 'category': category,
                'source': relative.as_posix(), 'sha256': sha256, 'bytes': source.stat().st_size,
                **metadata, 'preview': preview.as_posix()}
        items.append(item)
        seen[sha256] = item
    result = {'version': 1, 'items': items}
    catalog_path = root / 'data/creator/media-catalog.json'
    temporary = catalog_path.with_suffix('.json.tmp')
    temporary.write_text(json.dumps(result, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    temporary.replace(catalog_path)
    contact_sheet(root, items)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--ffmpeg', default='ffmpeg')
    parser.add_argument('--ffprobe', default='ffprobe')
    options = parser.parse_args()
    result = build_catalog(options.root, options.ffmpeg, options.ffprobe)
    print(json.dumps({'items': len(result['items']),
                      'categories': {category: sum(item['category'] == category for item in result['items'])
                                     for category in ('current-portrait', 'concept', 'video')},
                      'videosWithAudio': sum(item.get('hasAudio', False) for item in result['items'])}))


if __name__ == '__main__':
    main()

# Extracted Lummings asset audit

Inspected 15 October 2026. Extraction timestamps do not establish design approval or original creation order.

## Findings

- `lumming/lumming/marketing/demo-assets/`: all five portrait files are byte-identical to the current project campaign portraits used by the corrected app.
- `imagine_images/imagine_images/`: 29 JPEG files, visually inventoried in the numbered contact sheet and manifest. These include illustrated crew designs, different round-bodied characters, earlier names, app concepts, branding and product mockups. They are not one consistent replacement character set.
- `imagine_videos/`: 14 MP4 files found. Video contents and audio have not been reviewed in this audit.
- `tmp/tmp/`: portrait copies, a grid, and five MP3 introductions with timestamp JSON files. Audio has not been reviewed.
- `lumming/lumming/brand/character-masters/`: the folder name alone does not establish these as the latest approved artwork. See exact comparisons below.
- The root also contains `lummings-heartlight-story.mp4` and the four source ZIP archives.

## Character-master comparisons with the current app originals

| Character | Extracted master filename | Comparison |
|---|---|---|
| Lumo | `lumo-master.png` | Exact match |
| Luna | `luna-lila-master.png` | Exact match |
| Sprout | `pip-sprout-related.png` | Different image - do not substitute automatically |
| Nori | `nori-master.png` | Exact match |
| Moki | `moki-master.png` | Exact match |

The differing Sprout master is a flat green fox-like drawing on a pale background. Current campaign Sprout is the detailed leaf-eared green character with a compass and boots. New concept images 21 and 25 show additional green leaf-eared character variants. No automatic character replacement was made from this mixed collection.

## Review files

- [Numbered image contact sheet](image-inventory.jpg)
- [Full-size image gallery](gallery.html)
- [Image inventory with source paths, dimensions and SHA-256](image-inventory.json)

Original extracted files and ZIP archives were preserved. The app artwork was not changed during this audit.

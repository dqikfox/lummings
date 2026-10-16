# Local source media library

Open the current creator app at `http://127.0.0.1:8511/` and choose **Library**. The collection separates current portraits, concepts and existing films. Search titles or filenames, open an asset, play clips, and add/remove shortlist selections. Shortlisting never changes character artwork or deletes files.

## Rebuild the index

From the project root with the existing Python/Pillow and FFmpeg tools:

```powershell
python scripts/catalog_creator_media.py --root C:\Users\KING\projects\lumming
```

Restart the Lummings server after rebuilding. The script scans only the five campaign portraits, `imagine_images/imagine_images/*.jpg`, `imagine_videos/imagine_videos/*.mp4` and the root `lummings-heartlight-story.mp4`. It preserves originals, hashes bytes, deduplicates identical content, reads dimensions/durations, and produces preview JPEGs. Concept descriptions come from the extracted image inventory; video titles describe sampled posters rather than a full audio/content review.

Generated catalog/previews and shortlist SQLite files live under the Git-ignored `data/creator/` directory. A missing source is shown as unavailable; restore the file to the displayed path or rebuild the catalog. New bytes get a new ID, so an old shortlist does not silently approve changed content. The service reads the catalog at startup. Source files should remain unchanged during a server session; rerun the index and restart after edits.

## Routes

- `GET /api/v1/media`: catalog metadata and shortlist states.
- `GET /api/v1/media/{id}/file`: original image or video; supports a single HTTP byte range.
- `GET /api/v1/media/{id}/preview`: lightweight preview.
- `POST /api/v1/media/{id}/shortlist`: `{ "selected": true }` or false with the creator mutation token.

Paths are resolved by the server from catalogued IDs and constrained to the selected directories. No arbitrary-path upload/read endpoint or public hosting is added. The library is for the current local creator workspace; future family accounts need their own authorization and ownership boundaries.

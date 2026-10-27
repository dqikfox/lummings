// Guards the promises the app makes to parents: nothing leaves the phone, the microphone stays off,
// voices are recordings only, and "add to home screen" has real first-party files behind it.
import assert from "node:assert/strict";
import { existsSync, readdirSync, readFileSync, statSync } from "node:fs";
import { dirname, join, extname } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");

function walk(dir, out = []) {
  for (const name of readdirSync(dir)) {
    const full = join(dir, name);
    if (statSync(full).isDirectory()) walk(full, out);
    else out.push(full);
  }
  return out;
}

const sourceFiles = walk(join(ROOT, "src")).filter((f) =>
  [".ts", ".tsx", ".css", ".json"].includes(extname(f)) && !f.endsWith("routeTree.gen.ts"),
);
const read = (f) => readFileSync(f, "utf8");

test("no third-party hosts or remote scripts in the app source", () => {
  // w3.org is only an XML namespace inside inline SVG, never fetched.
  const allowed = [/^https?:\/\/www\.w3\.org\//];
  for (const file of sourceFiles) {
    const text = read(file);
    for (const [url] of text.matchAll(/https?:\/\/[^\s"'`)<>]+/g)) {
      assert.ok(allowed.some((re) => re.test(url)), `${file} references ${url}`);
    }
    assert.doesNotMatch(text, /<script[^>]+src=/i, `${file} loads a remote script`);
    assert.doesNotMatch(text, /googleapis|gstatic|grok\.(com|me)|og\.grok/i, `${file} names a tracker or builder host`);
  }
  const manifest = read(join(ROOT, "public/manifest.webmanifest"));
  assert.doesNotMatch(manifest, /https?:\/\//);
});

test("the microphone is off by default, opt-in only, and voices are recordings only", () => {
  const appCode = sourceFiles.filter((f) => /\.(ts|tsx)$/.test(f) && !f.endsWith(".test.ts"));
  for (const file of appCode) {
    const text = read(file);
    assert.doesNotMatch(text, /getUserMedia/, `${file} opens the microphone directly`);
    assert.doesNotMatch(text, /speechSynthesis\.speak|new SpeechSynthesisUtterance/, `${file} uses browser speech`);
    // Speech recognition (parent opt-in "Talk") must live in voice.ts only.
    if (!file.endsWith("voice.ts")) {
      assert.doesNotMatch(text, /SpeechRecognition/, `${file} uses speech recognition outside voice.ts`);
    }
  }
  const store = read(join(ROOT, "src/lib/store.ts"));
  assert.match(store, /privacy:\s*true/, "microphone privacy must default to ON (microphone off)");
});

test("web manifest and icons are real first-party files", () => {
  const manifest = JSON.parse(read(join(ROOT, "public/manifest.webmanifest")));
  assert.equal(manifest.name, "Lummings");
  assert.equal(manifest.display, "standalone");
  assert.equal(manifest.start_url, "/");
  assert.ok(manifest.icons.length >= 2);
  for (const icon of manifest.icons) {
    const file = join(ROOT, "public", icon.src);
    assert.ok(existsSync(file), `missing ${icon.src}`);
    const png = readFileSync(file);
    assert.equal(png.subarray(1, 4).toString(), "PNG", `${icon.src} is not a PNG`);
    const [w, h] = [png.readUInt32BE(16), png.readUInt32BE(20)];
    assert.equal(`${w}x${h}`, icon.sizes, `${icon.src} is ${w}x${h}, manifest says ${icon.sizes}`);
  }
  assert.ok(existsSync(join(ROOT, "public/icons/apple-touch-icon.png")));
  const root = read(join(ROOT, "src/routes/__root.tsx"));
  assert.match(root, /href: "\/manifest\.webmanifest"/);
  assert.match(root, /href: "\/icons\/apple-touch-icon\.png"/);
});

test("every crew intro has a recording on disk", () => {
  for (const id of ["lumo", "luna", "sprout", "nori", "moki"]) {
    assert.ok(existsSync(join(ROOT, "public/voices", `${id}.mp3`)), `missing public/voices/${id}.mp3`);
  }
});

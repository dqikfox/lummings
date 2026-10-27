import { register } from "node:module";
import { pathToFileURL } from "node:url";

register(new URL("./alias-hook.mjs", import.meta.url), pathToFileURL("./"));

const mem = new Map();

const storage = {
  getItem: (key) => mem.get(key) ?? null,
  setItem: (key, value) => {
    mem.set(key, String(value));
  },
  removeItem: (key) => {
    mem.delete(key);
  },
  clear: () => mem.clear(),
  key: (index) => [...mem.keys()][index] ?? null,
  get length() {
    return mem.size;
  },
};

if (!globalThis.window) globalThis.window = globalThis;
globalThis.localStorage = storage;
globalThis.window.localStorage = storage;

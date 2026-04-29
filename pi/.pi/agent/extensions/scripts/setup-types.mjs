#!/usr/bin/env node
/**
 * Resolves the location of pi's type declarations and writes tsconfig.paths.json
 * with correct `paths` entries so the LSP works without installing the full packages.
 *
 * Run automatically via the `prepare` npm script (triggered by `npm install`).
 * Safe to re-run manually: `node scripts/setup-types.mjs`
 */

import { execSync } from "child_process";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { dirname, join, relative } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");

// ---------------------------------------------------------------------------
// Find pi's package directory
// ---------------------------------------------------------------------------

function findPiPackageDir() {
  // Strategy 1: npm root -g
  // Works for any npm-based global install (including mise-managed node)
  try {
    const globalRoot = execSync("npm root -g", {
      encoding: "utf8",
      stdio: ["pipe", "pipe", "ignore"],
    }).trim();
    const candidate = join(globalRoot, "@mariozechner", "pi-coding-agent");
    if (existsSync(join(candidate, "package.json"))) return candidate;
  } catch {
    // fall through
  }

  // Strategy 2: resolve the real path of the `pi` binary
  // Handles cases where npm root -g isn't reliable
  try {
    const piBin = execSync("which pi", {
      encoding: "utf8",
      stdio: ["pipe", "pipe", "ignore"],
    }).trim();

    // Follow symlinks to the actual file
    let realBin = piBin;
    try {
      realBin = execSync(`realpath "${piBin}"`, {
        encoding: "utf8",
        stdio: ["pipe", "pipe", "ignore"],
      }).trim();
    } catch {
      // realpath not available on all platforms, fall back to readlink
      try {
        realBin = execSync(`readlink -f "${piBin}"`, {
          encoding: "utf8",
          stdio: ["pipe", "pipe", "ignore"],
        }).trim();
      } catch {
        // keep piBin as-is
      }
    }

    // Real path looks like: .../node_modules/@mariozechner/pi-coding-agent/dist/cli.js
    // Walk up until we find the package.json
    let dir = dirname(realBin);
    for (let i = 0; i < 6; i++) {
      const pkg = join(dir, "package.json");
      if (existsSync(pkg)) {
        try {
          const name = JSON.parse(readFileSync(pkg, "utf8")).name;
          if (name === "@mariozechner/pi-coding-agent") return dir;
        } catch {
          // not the right package.json, keep walking up
        }
      }
      dir = dirname(dir);
    }
  } catch {
    // fall through
  }

  return null;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

const piDir = findPiPackageDir();
const outPath = join(root, "tsconfig.paths.json");

if (!piDir) {
  // Write an empty stub so tsconfig.json's `extends` still resolves on machines
  // where pi isn't installed yet. The TS LSP will complain about missing types
  // until pi is installed and `npm install` is re-run, but typecheck won't
  // explode with a missing-file error.
  if (!existsSync(outPath)) {
    writeFileSync(outPath, JSON.stringify({ compilerOptions: { paths: {} } }, null, 2) + "\n");
  }
  console.warn(
    "[setup-types] Could not locate @mariozechner/pi-coding-agent.\n" +
      "  Install pi first, then re-run: npm install",
  );
  process.exit(0); // non-fatal: don't block npm install
}

const piNm = join(piDir, "node_modules");

// Paths must be relative to the tsconfig file (root of the extensions dir)
const rel = (abs) => relative(root, abs).replace(/\\/g, "/");

const tsconfigPathsContent = {
  compilerOptions: {
    paths: {
      "@mariozechner/pi-coding-agent": [
        rel(join(piDir, "dist", "index.d.ts")),
      ],
      "@mariozechner/pi-tui": [
        rel(join(piNm, "@mariozechner", "pi-tui", "dist", "index.d.ts")),
      ],
      "@mariozechner/pi-ai": [
        rel(join(piNm, "@mariozechner", "pi-ai", "dist", "index.d.ts")),
      ],
      typebox: [rel(join(piNm, "typebox", "build", "index.d.mts"))],
    },
  },
};

writeFileSync(outPath, JSON.stringify(tsconfigPathsContent, null, 2) + "\n");

console.log(
  `[setup-types] Wrote tsconfig.paths.json using pi at:\n  ${piDir}`,
);

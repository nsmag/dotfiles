# pi extensions

Project-local copy of the `~/.pi/agent/extensions/` directory, tracked in this
dotfiles repo so the same set of extensions can be re-applied to any machine.

Extensions:

- `custom-footer.ts`
- `questionnaire.ts`
- `rosepine-tools.ts`
- `rounded-editor.ts`

## Setup on a new machine

These extensions need TypeScript types from the globally installed
`@mariozechner/pi-coding-agent` package so the editor / `tsc` can resolve
imports like `@mariozechner/pi-coding-agent`, `@mariozechner/pi-tui`,
`@mariozechner/pi-ai`, and `typebox`.

The path to those types is machine-specific (it depends on which Node version
manager you use, e.g. mise / nvm / Homebrew). To keep this directory portable,
the resolved `tsconfig.paths.json` is **not committed** — it is regenerated
locally by `scripts/setup-types.mjs`.

```bash
# 1. Install pi globally (any Node toolchain works)
npm install -g @mariozechner/pi-coding-agent

# 2. From this directory, install the small dev deps and regenerate paths
cd ~/.pi/agent/extensions   # or wherever this folder lives
npm install                 # runs scripts/setup-types.mjs via `prepare`
```

After this:

- `tsconfig.paths.json` exists locally with the correct paths for *this* machine
- `npm run typecheck` works
- The editor / LSP can resolve all imports

If you upgrade Node, switch toolchains, or move the pi install, just rerun:

```bash
npm install
# or
node scripts/setup-types.mjs
```

## What is committed vs. ignored

Committed (portable across machines):

- `*.ts` extension sources
- `package.json`
- `tsconfig.json`
- `scripts/setup-types.mjs`
- `README.md`

Ignored (machine-specific, regenerated locally — see top-level `.gitignore`):

- `node_modules/`
- `package-lock.json`
- `tsconfig.paths.json`

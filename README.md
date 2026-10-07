# Mojulo for Muse Code — prototype

Status: **prototype, built and verified 2026-10-06 in Muse's workspace.
Not published, and nothing in Franz's repos was touched.** It is one more
surface in the same pattern as the existing multi-surface adapter repo
(`mojulo-chatgpt` already carries work-plugin / Codex / dot surfaces):
the package teaches, a pinned bootstrap installs the tool locally, and
execution never touches a hosted server — so the route costs $0.

## Layout

```text
.
├── .agents/plugins/marketplace.json   # catalog Muse Code reads on `marketplace add`
├── .muse-plugin/plugin.json           # native Muse manifest (schemaVersion 1)
├── skills/mojulo/SKILL.md             # the skill the manifest points at
└── scripts/bootstrap.sh               # pinned install: mojulo@3.0.0 → ./.mojulo-runtime
```

The plugin lives at the repo root, so the catalog entry's source path is
`./` — the same root layout the Browserbase `browse` plugin uses, where
the native `.muse-plugin/plugin.json` points at the same skill file the
other clients share.

## Verified on Muse Code 1.4.3 (2026-10-06, this workspace's VM)

The current GA build (1.4.3) ships a working plugin loader behind the
flag — unlike build 1.3.0, measured elsewhere with no loader at all.
With `MUSE_EXPERIMENTAL_PLUGINS=1`:

- `muse plugins validate . --json` — clean: zero diagnostics, skill
  resolved, compatibility summary "full", classification "supported".
- `muse plugins install <clean-copy> --scope user --json` — installed:
  `manifest_family: "native"`, enabled, version 3.0.0.
- `muse plugins marketplace add mojulo <dir> --json` then
  `muse plugins install mojulo@mojulo --json` — the full marketplace
  flow works from a local-dir source: snapshot stored (1 plugin, none
  skipped), install succeeds.
- `muse plugins inspect mojulo --json` — `active: true`, effective
  capability `plugin:mojulo:mojulo`, no capability diagnostics.
- `muse skills list --source plugin --json` — `plugin:mojulo:mojulo`,
  activation "on".
- Bootstrap, live: in a fresh scratch workspace, `scripts/bootstrap.sh`
  installed mojulo@3.0.0 (130 packages), a re-run reported the pin
  already present (idempotent), and through the installed binary:
  `orient` returned the full orientation, `call mint_solid` minted a
  two-part pawn (ref `sk_xz3x8qlzf9`), and `call export_model` produced
  its GLB. The whole conversation → files loop runs off this package.

### Gotchas found during verification (both fixed / worked around)

1. **Validate freezes the package.** `muse plugins validate` snapshots
   the package; editing *any* package file afterwards makes
   `install` fail with `plugin-cache-invalid: frozen plugin package
   metadata changed before publication`. Re-run validate after edits,
   or install from a fresh copy of the tree (what the runs above did).
2. **`npm init` cannot create the runtime.** The bootstrap originally
   ran `npm init -y` inside `.mojulo-runtime`; npm rejects the name
   (a package name may not start with a dot) and the install silently
   died. The bootstrap now skips `npm init` — `npm install --prefix`
   creates `package.json` itself. It also guards Node >= 22.14 and
   verifies the installed version matches the 3.0.0 pin.

## Still Franz's to run

- **Publish the repo** (his GitHub — e.g. a `muse-code/` surface inside
  `mojulo-chatgpt`, or its own repo), then the same flow with a git
  source: `muse plugins marketplace add mojulo <repo-url> --json`.
  Only the local-dir source is verified so far.
- **One live session.** Install/validate/inspect need no sign-in, but a
  real Muse Code session does (Meta account). The end-to-end check is:
  start a session, ask "Use mojulo to mint a desk organizer and export
  an STL," and confirm the agent finds the skill, runs the bootstrap
  from the installed package, and drives the CLI.

## Known open questions

1. **Catalog precedence.** Independent reverse-engineering reports the
   marketplace probe order is root `marketplace.json` →
   `.agents/plugins/marketplace.json` → `.claude-plugin/marketplace.json`,
   first-found-wins. This prototype deliberately ships *only* the
   `.agents` catalog (the one Browse documents Muse accepting), so
   nothing shadows it. If a Claude/Codex catalog is added later for a
   multi-surface repo, re-check precedence before assuming both are read.
2. **Version field.** The manifest version is `3.0.0` to match the
   pinned mojulo release; the validator accepted it as-is. If the
   package gets its own release cadence, split the two numbers and keep
   the pin only in `bootstrap.sh` and the skill.
3. **Category.** The catalog uses `Productivity`, the value in the
   documented `.agents` examples. Swap if the validator or directory
   copy wants a developer-tools category.
4. **No MCP server is declared.** Intentional: mojulo's Muse Code
   surface is the local CLI, exactly like Browse's separately installed
   CLI. (Meta's own DAT manifest shows `mcpServers` entries are
   `{id, transport: "http", url}` — hosted-shaped; no stdio example
   exists to copy.) Declaring one would also make the capability inert
   until `muse plugins approve`.
5. **Discovery is still by URL.** There is no central Meta directory of
   marketplaces; "being on it" means this repo exists in the right
   format and users add it. Discovery runs through mojulo.ai / GitHub.
6. **No `muse-code` host profile in mojulo 3.0.0.** `orient` lists
   claude-code / codex / desktop / grok / hermes / grok-chat / chatgpt /
   muse. The skill works without `MOJULO_HOST` (generic wire); a future
   mojulo release could add a profile so exports name Muse Code's
   doors. Note `MOJULO_SURFACE=box` would be *wrong* here — Muse Code
   runs on the operator's own machine, not in a host sandbox.

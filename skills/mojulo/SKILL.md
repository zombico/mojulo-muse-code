---
name: mojulo
description: Create and edit deterministic 3D with mojulo — conversation in, editable geometry out. Use when the user asks to build, change, or export a 3D model, scene, floorplan, or printable object.
---

# Mojulo

Mojulo is a deterministic 3D compiler driven from the shell. The same
recipe always mints the same geometry, and an edit changes only what the
recipe change implies — geometry stays editable, never a black-box
generation you cannot revise.

## Setup (once per workspace)

Mojulo runs locally; there is no hosted endpoint and nothing to sign up
for.

```bash
# Run the bootstrap packaged with this plugin — scripts/bootstrap.sh at
# the plugin package root. It installs into the CURRENT workspace:
sh <plugin-root>/scripts/bootstrap.sh
# installs the pinned mojulo@3.0.0 into ./.mojulo-runtime
export MOJULO_BIN="$PWD/.mojulo-runtime/node_modules/.bin/mojulo"
"$MOJULO_BIN" orient
```

`orient` is the initialize step for a fresh context. Run it first, every
new session, before minting anything.

## Working loop

1. **Discover before calling.** The CLI is the discovery surface:
   `"$MOJULO_BIN" tools`, `"$MOJULO_BIN" packs`, and
   `"$MOJULO_BIN" help <tool>` describe the current surface. The three
   dispatchers are `mint_solid`, `create_view`, and `compose_world`.
2. **Call tools as JSON.**
   `"$MOJULO_BIN" call <tool> --json '{...}'`
3. **Keep the recipe.** Every mint is backed by a saved recipe. To change
   a model, edit the recipe and re-mint — do not rebuild from scratch
   when the user asked for a small change ("make the middle slot wider"
   should change only that slot).
4. **Export explicitly.** Ask for the format the user needs
   (`glb`, `stl`, `3mf`, `usda`, `usdz`, `scad`, `html`, `bundle`, `ifc`
   where supported) instead of assuming one.
5. **Verify the result.** Open or render the export when a viewer is
   available and report what you actually checked — a successful mint
   call is not proof the model looks right.

## Defaults

- Prefer angular, CAD-style construction; that is mojulo's strength.
- State dimensions in the units the tool expects and repeat them back
  when a size matters (a case that misses its ports is a sculpture,
  not a case).
- If a call fails, read the error, fix the recipe or arguments, and
  retry once with the correction visible in your summary.

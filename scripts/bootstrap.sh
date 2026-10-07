#!/bin/sh
# Install the pinned mojulo release into a workspace-local runtime.
# Nothing is installed globally and no hosted service is involved:
# execution stays on the user's own machine, which is the whole point
# of the package shape.
set -eu

RUNTIME_DIR="${MOJULO_RUNTIME_DIR:-.mojulo-runtime}"
MOJULO_VERSION="3.0.0"
BIN="$RUNTIME_DIR/node_modules/.bin/mojulo"

command -v node >/dev/null 2>&1 || { echo "Mojulo requires Node >=22.14; node was not found." >&2; exit 2; }
command -v npm >/dev/null 2>&1 || { echo "Mojulo bootstrap requires npm; npm was not found." >&2; exit 2; }

node -e "const [a,b]=process.versions.node.split('.').map(Number); if (a<22 || (a===22 && b<14)) process.exit(1)" || {
  echo "Mojulo requires Node >=22.14; found $(node -p 'process.versions.node')." >&2
  exit 2
}

installed_version() {
  [ -x "$BIN" ] || return 1
  out="$("$BIN" --version 2>/dev/null)" || return 1
  printf '%s\n' "${out#mojulo }"
}

CURRENT="$(installed_version || true)"
if [ "$CURRENT" = "$MOJULO_VERSION" ]; then
  echo "mojulo $MOJULO_VERSION already present in $RUNTIME_DIR"
  exit 0
fi
if [ -n "$CURRENT" ]; then
  echo "Replacing mojulo $CURRENT with pinned $MOJULO_VERSION in the workspace-local runtime." >&2
fi

mkdir -p "$RUNTIME_DIR"
# No `npm init` here on purpose: the runtime dir name starts with a dot,
# which npm rejects as a package name. `npm install --prefix` creates
# package.json itself.
npm install --prefix "$RUNTIME_DIR" --no-audit --no-fund --save-exact "mojulo@$MOJULO_VERSION"

INSTALLED="$(installed_version || true)"
if [ "$INSTALLED" != "$MOJULO_VERSION" ]; then
  echo "Expected mojulo $MOJULO_VERSION but installed ${INSTALLED:-unknown}." >&2
  exit 3
fi

echo "Installed mojulo@$MOJULO_VERSION into $RUNTIME_DIR"
echo "Try:  $BIN orient"

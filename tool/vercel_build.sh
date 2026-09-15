#!/usr/bin/env bash
# Vercel build command (see vercel.json). Installs the Flutter version pinned in .fvmrc,
# then analyzes, tests and builds the web app into build/web.
set -euo pipefail
cd "$(dirname "$0")/.."

FLUTTER_VERSION="$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .fvmrc)"
FLUTTER_DIR="${FLUTTER_DIR:-$HOME/flutter-sdk}"

installed_version() {
  git -C "$FLUTTER_DIR" describe --tags --exact-match 2>/dev/null || true
}

if [ "$(installed_version)" != "$FLUTTER_VERSION" ]; then
  rm -rf "$FLUTTER_DIR"
  echo "Installing Flutter $FLUTTER_VERSION into $FLUTTER_DIR"
  git clone --quiet --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi
export PATH="$FLUTTER_DIR/bin:$PATH"
flutter --disable-analytics >/dev/null
flutter --version

# Runtime configuration comes from Vercel environment variables (empty until they are set).
printf '{"SUPABASE_URL":"%s","SUPABASE_ANON_KEY":"%s"}\n' "${SUPABASE_URL:-}" "${SUPABASE_ANON_KEY:-}" > env/prod.json

flutter pub get
flutter analyze --fatal-infos
flutter test
flutter build web --release --no-web-resources-cdn --dart-define-from-file=env/prod.json

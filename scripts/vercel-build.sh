#!/usr/bin/env bash
# Builds the Flutter web app on Vercel (Amazon Linux 2023), which has no Flutter SDK.
# Keep FLUTTER_VERSION in step with the version used locally.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.50.1}"
FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"

# Tools the Flutter SDK needs that a minimal image may lack.
declare -A pkg=([git]=git [tar]=tar [xz]=xz [unzip]=unzip [which]=which [find]=findutils)
missing=()
for tool in "${!pkg[@]}"; do
  command -v "$tool" >/dev/null 2>&1 || missing+=("${pkg[$tool]}")
done
if [ ${#missing[@]} -gt 0 ]; then
  dnf install -y -q "${missing[@]}"
fi

if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  git clone -q --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$FLUTTER_HOME"
fi
export PATH="$FLUTTER_HOME/bin:$PATH"

flutter config --no-analytics --enable-web >/dev/null
flutter --version
flutter pub get
flutter build web --release

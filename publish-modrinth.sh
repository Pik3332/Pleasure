#!/usr/bin/env bash
# Publish TheWorld to Modrinth as a modpack version.
# Usage: ./publish-modrinth.sh [version]
# Reads the Modrinth token from ~/.gradle/gradle.properties (modrinth.token=...).
# The token is never printed.
set -euo pipefail

PROJECT_ID="D4iTMuLF"
MC_VERSION="1.21.1"
LOADER="neoforge"

VERSION="${1:-$(grep -m1 '^version' pack.toml | cut -d'"' -f2)}"
TOKEN="$(grep -m1 '^modrinth\.token=' "$HOME/.gradle/gradle.properties" | cut -d= -f2-)"
if [ -z "$TOKEN" ]; then echo "error: modrinth.token not found in ~/.gradle/gradle.properties" >&2; exit 1; fi

packwiz refresh
packwiz modrinth export

FILE="$(ls -t ./*.mrpack | head -1)"
DATA=$(printf '{"project_id":"%s","name":"TheWorld %s","version_number":"%s","game_versions":["%s"],"version_type":"release","loaders":["%s"],"featured":false,"dependencies":[],"file_parts":["file"],"primary_file":"file"}' \
  "$PROJECT_ID" "$VERSION" "$VERSION" "$MC_VERSION" "$LOADER")

curl -sS -X POST "https://api.modrinth.com/v2/version" \
  -H "Authorization: $TOKEN" \
  -F "data=$DATA;type=application/json" \
  -F "file=@${FILE};type=application/x-modrinth-modpack+zip" \
  -w "\nHTTP %{http_code}\n"

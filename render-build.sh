#!/bin/bash
# Fetch the pinned public core and copy this repository's config files into it.
set -euo pipefail
cd "$(dirname "$0")"

pin="$(tr -d '[:space:]' < core-pin)"
if [[ ! "$pin" =~ ^[0-9a-f]{40}$ ]]; then
  echo "core-pin must be 40 hex characters" >&2
  exit 1
fi

names=(
  locale.yml
  month_target.yml
  ops_schedule.yml
  protective_exit.yml
  strategies.yml
  strategy_results.yml
  venues.yml
)
for name in "${names[@]}"; do
  if [[ ! -s "config/$name" ]]; then
    echo "$name is missing" >&2
    exit 1
  fi
done

rm -rf .core
git init -q .core
git -C .core remote add origin https://github.com/SignalNexus/signal-nexus.git
git -C .core fetch --depth 1 origin "$pin"
git -C .core checkout --detach --quiet FETCH_HEAD
mkdir -p .core/config
for name in "${names[@]}"; do
  cp "config/$name" ".core/config/$name"
  sha="$(sha256sum ".core/config/$name" | awk '{print $1}')"
  echo "$name sha256 ${sha}"
done

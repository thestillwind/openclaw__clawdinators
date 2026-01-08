#!/usr/bin/env bash
set -euo pipefail

list_file="$1"
base_dir="$2"
auth_header=""

if [ -n "${GITHUB_TOKEN:-}" ]; then
  basic_auth="$(printf 'x-access-token:%s' "$GITHUB_TOKEN" | base64 | tr -d '\n')"
  auth_header="Authorization: Basic ${basic_auth}"
fi

if [ ! -f "$list_file" ]; then
  echo "seed-repos: missing repo list: $list_file" >&2
  exit 1
fi

mkdir -p "$base_dir"
export GIT_TERMINAL_PROMPT=0

failures=0
total=0

while IFS=$'\t' read -r name url branch; do
  [ -z "${name:-}" ] && continue
  [ -z "${url:-}" ] && continue

  dest="$base_dir/$name"
  total=$((total + 1))
  if [ ! -d "$dest/.git" ]; then
    if [ -n "${auth_header}" ] && [[ "$url" == https://github.com/* ]]; then
      if [ -n "${branch:-}" ]; then
        if ! git -c http.extraheader="$auth_header" clone --depth 1 --branch "$branch" "$url" "$dest"; then
          echo "seed-repos: failed to clone $name ($url)" >&2
          failures=$((failures + 1))
          continue
        fi
      else
        if ! git -c http.extraheader="$auth_header" clone --depth 1 "$url" "$dest"; then
          echo "seed-repos: failed to clone $name ($url)" >&2
          failures=$((failures + 1))
          continue
        fi
      fi
    else
      if [ -n "${branch:-}" ]; then
        if ! git clone --depth 1 --branch "$branch" "$url" "$dest"; then
          echo "seed-repos: failed to clone $name ($url)" >&2
          failures=$((failures + 1))
          continue
        fi
      else
        if ! git clone --depth 1 "$url" "$dest"; then
          echo "seed-repos: failed to clone $name ($url)" >&2
          failures=$((failures + 1))
          continue
        fi
      fi
    fi
    continue
  fi

  origin_url="$(git -C "$dest" -c safe.directory="$dest" config --get remote.origin.url || true)"
  if [ -z "$origin_url" ]; then
    rm -rf "$dest"
    if [ -n "${auth_header}" ] && [[ "$url" == https://github.com/* ]]; then
      if [ -n "${branch:-}" ]; then
        if ! git -c http.extraheader="$auth_header" clone --depth 1 --branch "$branch" "$url" "$dest"; then
          echo "seed-repos: failed to re-clone $name ($url)" >&2
          failures=$((failures + 1))
          continue
        fi
      else
        if ! git -c http.extraheader="$auth_header" clone --depth 1 "$url" "$dest"; then
          echo "seed-repos: failed to re-clone $name ($url)" >&2
          failures=$((failures + 1))
          continue
        fi
      fi
    else
      if [ -n "${branch:-}" ]; then
        if ! git clone --depth 1 --branch "$branch" "$url" "$dest"; then
          echo "seed-repos: failed to re-clone $name ($url)" >&2
          failures=$((failures + 1))
          continue
        fi
      else
        if ! git clone --depth 1 "$url" "$dest"; then
          echo "seed-repos: failed to re-clone $name ($url)" >&2
          failures=$((failures + 1))
          continue
        fi
      fi
    fi
    continue
  fi
  if [ "$origin_url" != "$url" ]; then
    if ! git -C "$dest" -c safe.directory="$dest" remote set-url origin "$url"; then
      echo "seed-repos: failed to set origin for $name ($url)" >&2
      failures=$((failures + 1))
      continue
    fi
    origin_url="$url"
  fi
  if [ -n "${auth_header}" ] && [[ "$origin_url" == https://github.com/* ]]; then
    if ! git -C "$dest" -c safe.directory="$dest" -c http.extraheader="$auth_header" fetch --all --prune; then
      echo "seed-repos: failed to fetch $name ($origin_url)" >&2
      failures=$((failures + 1))
      continue
    fi
  else
    if ! git -C "$dest" -c safe.directory="$dest" fetch --all --prune; then
      echo "seed-repos: failed to fetch $name ($origin_url)" >&2
      failures=$((failures + 1))
      continue
    fi
  fi
  if [ -n "${branch:-}" ]; then
    if ! git -C "$dest" -c safe.directory="$dest" checkout "$branch"; then
      echo "seed-repos: failed to checkout $name ($branch)" >&2
      failures=$((failures + 1))
      continue
    fi
    if ! git -C "$dest" -c safe.directory="$dest" reset --hard "origin/$branch"; then
      echo "seed-repos: failed to reset $name (origin/$branch)" >&2
      failures=$((failures + 1))
      continue
    fi
  else
    if ! git -C "$dest" -c safe.directory="$dest" reset --hard "origin/HEAD"; then
      echo "seed-repos: failed to reset $name (origin/HEAD)" >&2
      failures=$((failures + 1))
      continue
    fi
  fi
done < "$list_file"

if [ "$total" -gt 0 ] && [ "$failures" -ge "$total" ]; then
  echo "seed-repos: all repo operations failed ($failures/$total)" >&2
  exit 1
fi

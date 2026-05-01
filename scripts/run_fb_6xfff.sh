#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

case_name="FB_6XFFF"
max_histories="100000"
num_runs="500"

for run in $(seq 1 "$num_runs"); do
  echo "Starting run ${run}/${num_runs}: ${case_name}, ${max_histories} histories"
  docker run --rm \
    -e HOST_UID="$(id -u)" \
    -e HOST_GID="$(id -g)" \
    -v "$repo_root/cases:/cases" \
    primo-wine "$case_name" "$max_histories"
done

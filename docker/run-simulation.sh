#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage:
  primo-run CASE_NAME MAX_HISTORIES

Environment:
  CASES_DIR=/cases   Directory containing case folders.

Example:
  primo-run CL2100_6X 100000
USAGE
}

if [[ $# -ne 2 ]]; then
  usage
  exit 2
fi

case_name="$1"
max_histories="$2"
cases_dir="${CASES_DIR:-/cases}"
case_dir="$cases_dir/$case_name"
template_dir="$case_dir/Proc1.template"
lock_dir="$case_dir/.proc-create.lock"

if [[ ! "$max_histories" =~ ^[0-9]+$ || "$max_histories" -le 0 ]]; then
  echo "ERROR: MAX_HISTORIES must be a positive integer." >&2
  exit 2
fi

if [[ ! -d "$case_dir" ]]; then
  echo "ERROR: case directory not found: $case_dir" >&2
  exit 1
fi

if [[ ! -d "$template_dir" ]]; then
  echo "ERROR: template directory not found: $template_dir" >&2
  echo "Expected the template to be named Proc1.template." >&2
  exit 1
fi

cleanup_lock() {
  rmdir "$lock_dir" 2>/dev/null || true
}

while ! mkdir "$lock_dir" 2>/dev/null; do
  sleep 1
done
trap cleanup_lock EXIT

next_n=1
while [[ -e "$case_dir/Proc$next_n" || -e "$case_dir/Proc$next_n.template" ]]; do
  next_n=$((next_n + 1))
done

proc_dir="$case_dir/Proc$next_n"
mkdir "$proc_dir"
cp -a "$template_dir/." "$proc_dir/"

trap 'status=$?; cleanup_lock; if [[ $status -ne 0 ]]; then rm -rf "$proc_dir"; fi; exit $status' EXIT

find "$proc_dir" -maxdepth 1 -type f \( \
  -name 'Easy.Out' -o \
  -name 'dynLinac.OUT' -o \
  -name 'dynSQ.in' -o \
  -name 'PENdyn.geo' -o \
  -name 'fort.*' -o \
  -name 'init.out' -o \
  -name 'tally*.dat' -o \
  -name '*.IAEAheader' -o \
  -name '*.IAEAphsp' -o \
  -name '*.log' \
  \) -delete

easy_input="$proc_dir/EasyLinac.in"
if [[ ! -f "$easy_input" ]]; then
  echo "ERROR: EasyLinac.in not found in copied template." >&2
  exit 1
fi

seed1="$(od -An -N4 -tu4 /dev/urandom | awk '{print 1 + ($1 % 2147483646)}')"
seed2="$(od -An -N4 -tu4 /dev/urandom | awk '{print 1 + ($1 % 2147483646)}')"
if [[ "$seed1" == "$seed2" ]]; then
  seed2=$((seed2 % 2147483646 + 1))
fi

tmp_input="$(mktemp)"
awk -v histories="$max_histories" -v seed1="$seed1" -v seed2="$seed2" '
  /^\[SECTION CONFIG / { in_config=1; config_line=0; print; next }
  in_config && /^\[END OF CONFIG SECTION\]/ { in_config=0; print; next }
  in_config {
    config_line++
    if (config_line == 1) {
      printf "%12d\n", histories
      next
    }
    if (config_line == 4) {
      printf "%d %d\n", seed1, seed2
      next
    }
  }
  { print }
' "$easy_input" > "$tmp_input"
mv "$tmp_input" "$easy_input"

mkdir -p "$WINEPREFIX/drive_c/PRIMO/penEasyLinac"
ln -sfn /opt/primo/PenEasyLinac/dynLinac "$WINEPREFIX/drive_c/PRIMO/penEasyLinac/dynLinac"

cd "$proc_dir"

for required in dynLinac.exe penEasy_PRIMO_dyna.exe dynaSQ.dat EasyLinac.in; do
  if [[ ! -f "$required" ]]; then
    echo "ERROR: required file not found in $proc_dir: $required" >&2
    exit 1
  fi
done

echo "Created $proc_dir"
echo "Histories: $max_histories"
echo "Seeds: $seed1 $seed2"
echo "Step 1/2: generating dynamic geometry..."
xvfb-run -a wine dynLinac.exe < dynaSQ.dat > dynLinac.OUT

if [[ ! -s dynSQ.in || ! -s PENdyn.geo ]]; then
  echo "ERROR: dynLinac did not create dynSQ.in and PENdyn.geo. See $proc_dir/dynLinac.OUT." >&2
  exit 1
fi

echo "Step 2/2: running PenEasy..."
xvfb-run -a wine penEasy_PRIMO_dyna.exe < EasyLinac.in > Easy.Out

if [[ -n "${HOST_UID:-}" ]]; then
  chown -R "${HOST_UID}:${HOST_GID:-$HOST_UID}" "$proc_dir"
fi

echo "Simulation finished: $proc_dir"
echo "Main output: $proc_dir/Easy.Out"

trap cleanup_lock EXIT

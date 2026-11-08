#!/usr/bin/env bash
# Run a long pipeline job detached from the terminal, niced.
#
#   bin/run-detached.sh <name> <cmd> [args...]
#
# Writes, under ~/.cache/middle-of-somewhere/jobs/:
#   <name>.log   stdout and stderr
#   <name>.pid   the job's pid
#   <name>.done  the command's exit code, written only once it has exited
#
# A watcher waits on the .done file. It is written to a temporary name and
# renamed, so it never appears half-written. A TERM or INT sent to the pid is
# forwarded to the command, and the exit code is still recorded.
set -u

if [ "${1:-}" = "--inner" ]; then
  done_file=$2
  shift 2
  echo "started $(date '+%Y-%m-%d %H:%M:%S') in $(pwd): $*"
  "$@" &
  child=$!
  trap 'kill -TERM "$child" 2>/dev/null' TERM INT
  code=0
  wait "$child" || code=$?
  # A trapped signal interrupts wait before the child exits; wait for the child.
  if kill -0 "$child" 2>/dev/null; then
    code=0
    wait "$child" || code=$?
  fi
  echo "finished $(date '+%Y-%m-%d %H:%M:%S') exit=$code"
  printf '%s\n' "$code" > "$done_file.tmp"
  mv "$done_file.tmp" "$done_file"
  exit "$code"
fi

if [ $# -lt 2 ]; then
  echo "usage: $0 <name> <cmd> [args...]" >&2
  exit 64
fi

name=$1
shift
case $name in
  '' | *[!A-Za-z0-9._-]*)
    echo "job name must match [A-Za-z0-9._-]+: '$name'" >&2
    exit 64
    ;;
esac

jobs_dir=$HOME/.cache/middle-of-somewhere/jobs
mkdir -p "$jobs_dir"
log=$jobs_dir/$name.log
pid_file=$jobs_dir/$name.pid
done_file=$jobs_dir/$name.done

if [ -f "$pid_file" ] && [ ! -f "$done_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
  echo "job '$name' is already running (pid $(cat "$pid_file"))" >&2
  exit 1
fi
rm -f "$done_file" "$done_file.tmp"

self=$(cd "$(dirname "$0")" && pwd)/$(basename "$0")
nohup nice -n 10 "$self" --inner "$done_file" "$@" > "$log" 2>&1 < /dev/null &
echo $! > "$pid_file"

echo "job:  $name"
echo "pid:  $(cat "$pid_file")"
echo "log:  $log"
echo "done: $done_file"

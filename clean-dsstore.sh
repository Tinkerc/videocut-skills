#!/usr/bin/env bash
set -euo pipefail
usage() {
  echo "Usage: $0 [-n] [-v]"
  echo "-n  dry-run"
  echo "-v  verbose"
  echo "Cleans .DS_Store files in the script's directory and its subdirectories"
}
DRY_RUN=0
VERBOSE=0
while getopts ":nhv" opt; do
  case "$opt" in
    n) DRY_RUN=1 ;;
    v) VERBOSE=1 ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done
# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$SCRIPT_DIR"
if [ ! -d "$TARGET_DIR" ]; then
  echo "Directory not found: $TARGET_DIR" >&2
  exit 1
fi
COUNT=$(find "$TARGET_DIR" -type f -name ".DS_Store" | wc -l | tr -d ' ')
if [ "$COUNT" -eq 0 ]; then
  echo "No .DS_Store files in $TARGET_DIR"
  exit 0
fi
echo "Found $COUNT .DS_Store files in $TARGET_DIR"
echo "Directories containing .DS_Store in $TARGET_DIR:"
find "$TARGET_DIR" -type f -name ".DS_Store" -print0 \
  | xargs -0 -I {} dirname "{}" \
  | sort | uniq -c \
  | sed 's/^/  /'
if [ "$DRY_RUN" -eq 1 ]; then
  while IFS= read -r -d '' FILE; do
    DIRNAME=$(dirname "$FILE")
    echo "Would delete: $FILE (dir: $DIRNAME)"
  done < <(find "$TARGET_DIR" -type f -name ".DS_Store" -print0)
  echo "Total .DS_Store files: $COUNT"
else
  REMOVED=0
  while IFS= read -r -d '' FILE; do
    DIRNAME=$(dirname "$FILE")
    if [ "$VERBOSE" -eq 1 ]; then
      echo "Deleting: $FILE (dir: $DIRNAME)"
    fi
    if rm -f "$FILE"; then
      REMOVED=$((REMOVED + 1))
    else
      echo "Failed to delete: $FILE" >&2
    fi
  done < <(find "$TARGET_DIR" -type f -name ".DS_Store" -print0)
  echo "Removed $REMOVED .DS_Store files from $TARGET_DIR"
fi

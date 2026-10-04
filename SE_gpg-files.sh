#!/usr/bin/env bash
set -u

KEY='YOUR_KEY_ID'
mode=${1-}

case "$mode" in
  encrypt|decrypt) shift ;;
  *)
    printf 'Usage: %s encrypt|decrypt [file ...]\n' "$0" >&2
    printf 'Or pipe a NUL-delimited file list into it.\n' >&2
    exit 2
    ;;
esac

files=()

# Use command-line filenames if supplied; otherwise read NUL-delimited paths
# from stdin. NUL delimiters support filenames containing newlines.
if (($# > 0)); then
  files=("$@")
elif [[ ! -t 0 ]]; then
  while IFS= read -r -d '' file; do
    files+=("$file")
  done
fi

if ((${#files[@]} == 0)); then
  echo "No filenames supplied." >&2
  exit 2
fi

status=0
for file in "${files[@]}"; do
  if [[ ! -f "$file" ]]; then
    printf 'Skipping; not a regular file: %q\n' "$file" >&2
    status=1
    continue
  fi

  if [[ "$mode" == encrypt ]]; then
    output="${file}.gpg"
    if [[ -e "$output" ]]; then
      printf 'Skipping; output already exists: %q\n' "$output" >&2
      status=1
      continue
    fi

    gpg --local-user "$KEY" --recipient "$KEY" \
        --sign --encrypt --output "$output" -- "$file" || status=1
  else
    if [[ "$file" != *.gpg ]]; then
      printf 'Skipping; expected a .gpg file: %q\n' "$file" >&2
      status=1
      continue
    fi

    output="${file%.gpg}"
    if [[ -e "$output" ]]; then
      printf 'Skipping; output already exists: %q\n' "$output" >&2
      status=1
      continue
    fi

    gpg --output "$output" --decrypt -- "$file" || status=1
  fi
done

exit "$status"

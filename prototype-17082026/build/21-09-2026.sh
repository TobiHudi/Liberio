#!/bin/sh
printf '\033c\033]0;%s\a' liberio
base_path="$(dirname "$(realpath "$0")")"
"$base_path/21-09-2026.x86_64" "$@"

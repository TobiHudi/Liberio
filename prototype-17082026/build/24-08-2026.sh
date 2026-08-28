#!/bin/sh
printf '\033c\033]0;%s\a' prototype_17082026
base_path="$(dirname "$(realpath "$0")")"
"$base_path/24-08-2026.x86_64" "$@"

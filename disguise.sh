#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
RESET="\e[0m"

function task { printf "* $1.\n"; }
function fail {
    printf "${RED}$1${RESET}\n" >&2
    exit 1
}
function succ { printf "${GREEN}$1${RESET}\n"; }

if [[ $# -lt 1 ]]; then
    fail "Not enough arguments!"
fi

app_root="$1"
new_name="$2"
if [[ -z $new_name ]]; then
    new_name=$(openssl rand -hex 8)
fi

task "Copying application folder"
cp -a "$app_root" "$new_name"

info="$new_name/Contents/Info.plist"
macos="$new_name/Contents/MacOS"
binary="$(/usr/libexec/PlistBuddy "$info" -c "Print :CFBundleExecutable")"

task "Overwriting CFBundleName property"
plutil -replace CFBundleName -string "$new_name" "$info"
task "Renaming executable"
mv "$macos/$binary" "$macos/$new_name"
task "Creating symlink"
ln -s "$new_name" "$binary"

succ "Successfully disguised $app_root as $new_name."

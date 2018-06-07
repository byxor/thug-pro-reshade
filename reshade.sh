#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Please provide the arguments: <import/export> <windowsUsername>"
    echo "import: Copies reshade configurations from THUG Pro to git repo."
    echo "export: Copies reshade configurations from git repo to THUG Pro."
    exit 1
fi

username="$2"
thugPro="/mnt/c/Users/$username/AppData/Local/THUG Pro"

thugProScripts="$thugPro/scripts"
localScripts="THUG Pro/scripts"

if [ "$1" = "export" ]; then
    source="$localScripts"
    destination="$thugProScripts"
elif [ "$1" = "import" ]; then
    source="$thugProScripts"
    destination="$localScripts"
else
    echo "Invalid 2nd argument."
    exit 1
fi

backup="/tmp"
echo "Backing up configurations to $backup..."
cp -Rf "$destination" $backup

rm -Rf "$destination"
cp -Rf "$source" "$destination"


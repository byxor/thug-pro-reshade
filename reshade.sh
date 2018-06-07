#!/bin/bash


BACKUP="/tmp"


function _show_usage {
    echo "Please provide the arguments: <import/export> <windowsUsername>"
    echo "import: Copies reshade configurations from THUG Pro to git repo."
    echo "export: Copies reshade configurations from git repo to THUG Pro."
}


function _transfer {
    local source="$1"
    local destination="$2"

    echo "Backing up configurations to $BACKUP..."
    cp -Rf "$destination" "$BACKUP"

    rm -Rf "$destination"
    cp -Rf "$source" "$destination"    
}


function _run {
    if [ "$#" -ne 2 ]; then
        _show_usage
        exit 1
    fi

    local username="$2"
    local thugPro="/mnt/c/Users/$username/AppData/Local/THUG Pro"

    local thugProScripts="$thugPro/scripts"
    local localScripts="THUG Pro/scripts"

    if [ "$1" = "export" ]; then
        _transfer "$localScripts" "$thugProScripts"
    elif [ "$1" = "import" ]; then
        _transfer "$thugProScripts" "$localScripts"
    else
        _show_usage
        exit 1
    fi    
}


_run $@

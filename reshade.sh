#!/bin/bash


BACKUP="/tmp"


function _show_usage {
    echo "Please provide the arguments: <import/export/install> <windowsUsername>"
    echo "import: Copies reshade configurations from THUG Pro to git repo."
    echo "export: Copies reshade configurations from git repo to THUG Pro."
}


function _transfer {
    local source="$1"
    local destination="$2"

    echo "Backing up potentially overwritten configurations to $BACKUP..."
    cp -Rf "$destination" "$BACKUP"

    echo "Transferring configurations..."
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
    local repository="THUG Pro"

    local thugProScripts="$thugPro/scripts"
    local repositoryScripts="$repository/scripts"

    local repositoryDll="$repository/dinput8.dll"

    if [ "$1" = "install" ]; then
        echo "Installing custom DLL..."
        cp -f "$repositoryDll" "$thugPro"
        _transfer "$repositoryScripts" "$thugProScripts"
    elif [ "$1" = "export" ]; then
        _transfer "$repositoryScripts" "$thugProScripts"
    elif [ "$1" = "import" ]; then
        _transfer "$thugProScripts" "$repositoryScripts"
    else
        _show_usage
        exit 1
    fi    
}


_run $@

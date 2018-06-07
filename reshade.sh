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

    local shaders="scripts/ReShade/Presets/thugpro"

    local thugProShaders="$thugPro/$shaders"
    local repositoryShaders="$repository/$shaders"

    local repositoryDll="$repository/dinput8.dll"

    if [ "$1" = "install" ]; then
        echo "Installing custom DLL..."
        cp -f "$repositoryDll" "$thugPro"
        echo "Installing shaders and scripts..."
        cp -Rf "$repository/scripts" "$thugPro/scripts"
    elif [ "$1" = "export" ]; then
        _transfer "$repositoryShaders" "$thugProShaders"
    elif [ "$1" = "import" ]; then
        _transfer "$thugProShaders" "$repositoryShaders"
        echo "Triggering reshade to reload..."
        echo "" >> "$thugProShaders/Shaders_by_Alo81.cfg"
    else
        _show_usage
        exit 1
    fi    
}


_run $@

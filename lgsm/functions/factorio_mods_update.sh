#!/bin/bash
# LinuxGSM update_factorio.sh function
# Author: Daniel Gibbs
# Contributor: IIPoliII
# Website: https://linuxgsm.com
# Description: Handles updating mods Factorio servers.

local commandname="UPDATE-MODS"
local commandaction="Update-mods"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

#Variables

declare ver
declare installed_mods

fn_get_factorio_mods(){
        installed_mods=$(grep -Po '"name":.*?[^\\]",' ${serverfiles}/mods/mod-list.json | tr -d '"' | cut -c 7- | sed 's/.$//')
}
fn_download_factorio_mods(){
        echo $installed_mods
        while read -r installed_mods; do
                (
                while [[ ${get_mod_version} != "null" ]] ; do
                        ((ver++))
                        get_mod_version=$(curl -s --request GET https://mods.factorio.com/api/mods/bobpower | jq ".releases[${ver}] .info_json .factorio_version" | sed -e 's/^"//' -e 's/"$//')
                        echo "${get_mod_version}:${ver}"
                done
                ) | while read ver_check
                        do
                                currentbuild=$(grep "Loading mod base" "${serverfiles}/factorio-current.log" 2> /dev/null | awk '{print $5}' | tail -1 | cut -f1,2 -d'.')
                                ver=$(cut -d ":" -f 2 <<< "$ver_check")
                                mod_ver=$(echo "${ver_check}" | cut -f1 -d":")
                                echo current bld : $currentbuild
                                echo arraynb : $ver
                                echo mod_ver : $mod_ver
                                if [[ $mod_ver == $currentbuild ]]; then
                                        get_mod_download=$(curl -s --request GET https://mods.factorio.com/api/mods/bobpower | jq ".releases[${ver}] .download_url" | sed -e 's/^"//' -e 's/"$//')
                                        echo $get_mod_download
                                fi
                        done
        done <<< "$x"
}
fn_get_factorio_mods
fn_download_factorio_mods


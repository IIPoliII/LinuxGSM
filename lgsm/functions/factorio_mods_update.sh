#!/bin/bash
# LinuxGSM update_factorio.sh function
# Author: Daniel Gibbs
# Contributor: IIPoliII
# Website: https://linuxgsm.com
# Description: Handles updating mods Factorio servers.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

#Variables

username="IIPoliII"
token="**************"

declare ver
declare installed_mods

mkdir -p ${tmpdir}/factorio
rm -rf ${tmpdir}/factorio/mods-download
mkdir -p ${tmpdir}/factorio/mods-download

fn_check_download_factorio_mods(){
        installed_mods=$(grep -Po '"name":.*?[^\\]",' ${serverfiles}/mods/mod-list.json | tr -d '"' | cut -c 7- | sed 's/.$//')
        while read -r installed_mods; do
                (
                while [[ ${get_mod_version} != "null" ]] ; do
                        ver=$((ver+1))
                        get_mod_version=$(curl -s --request GET https://mods.factorio.com/api/mods/${installed_mods} | jq ".releases[${ver}] .info_json .factorio_version" | sed -e 's/^"//' -e 's/"$//')
                        download_url="${installed_mods}:"
                        echo "${get_mod_version}:${ver}"
                done
                ) | while read ver_check
                        do
                                currentbuild=$(grep "Loading mod base" "${serverfiles}/factorio-current.log" 2> /dev/null | awk '{print $5}' | tail -1 | cut -f1,2 -d'.')
                                ver=$(cut -d ":" -f 2 <<< "$ver_check")
                                mod_ver=$(echo "${ver_check}" | cut -f1 -d":")
                                echo $installed_mods
                                echo current bld : $currentbuild
                                echo arraynb : $ver
                                echo mod_ver : $mod_ver
                                if [[ ${mod_ver} == ${currentbuild} ]]; then
                                        get_mod_download=$(curl -s --request GET https://mods.factorio.com/api/mods/${installed_mods} | jq ".releases[${ver}] .download_url" | sed -e 's/^"//' -e 's/"$//')
                                        echo "https://mods.factorio.com${get_mod_download}" > ${tmpdir}/factorio/mods-download/$installed_mods
                                fi
                        done
        done <<< "${installed_mods}"
}
fn_download_factorio_mods(){
        mv ${serverfiles}/mods/mod-list.json ${tmpdir}/factorio/mod-list.json
        login_data="?username=${username}&token=${token}"
        for mod_dl in "${tmpdir}/factorio/mods-download"/*; do
                download=$(cat "$mod_dl")
				download_full=$(echo "${download}${login_data}")
                echo $download_full lin
                wget --content-disposition -qP ${serverfiles}/mods/ ${download_full}
        done
        find ${serverfiles}/mods -type f -name "*\?*" -exec sh -c 'mv $1 $(echo $1 | cut -d\? -f1)' mv {}  \;
        mv ${tmpdir}/factorio/mod-list.json ${serverfiles}/mods/mod-list.json
        rm -rf ${tmpdir}/factorio/mod-list.json
}
fn_check_download_factorio_mods
files=(${tmpdir}/factorio/mods-download/*)
if [ ${#files[@]} -gt 0 ]; then
fn_download_factorio_mods
else
:
#nothing for now
fi


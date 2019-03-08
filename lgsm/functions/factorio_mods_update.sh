#!/bin/bash
# LinuxGSM update_factorio.sh function
# Author: Daniel Gibbs
# Contributor: IIPoliII
# Website: https://linuxgsm.com
# Description: Handles updating mods Factorio servers.

local commandname="UPDATE-MODS"
local commandaction="Update-mods"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

fn_get_factorio_mods(){
        installed_mods=$(grep -Po '"name":.*?[^\\]",' ${serverfiles}/mods/mod-list.json | tr -d '"' | cut -c 7- | sed 's/.$//')
}
fn_download_factorio_mods(){

}
fn_get_factorio_mods


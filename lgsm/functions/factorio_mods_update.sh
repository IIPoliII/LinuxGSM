#!/bin/bash
# LinuxGSM update_factorio.sh function
# Author: Daniel Gibbs
# Contributor: IIPoliII
# Website: https://linuxgsm.com
# Description: Handles updating of Factorio servers Mods.

local commandname="UPDATE"
local commandaction="Update"
local function_selfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

#Variables

username="IIPoliII"
token="*********************"
modlist="${serverfiles}/mods/mod-list.json"

declare ver
declare installed_mods

mkdir -p ${tmpdir}/factorio
rm -rf ${tmpdir}/factorio/mods-download-link
mkdir -p ${tmpdir}/factorio/mods-download-link
rm -rf ${tmpdir}/factorio/mods
mkdir -p ${tmpdir}/factorio/mods
echo ""
fn_check_mod_version(){
	installed_mods=$(grep -Po '"name":.*?[^\\]",' ${serverfiles}/mods/mod-list.json | tr -d '"' | cut -c 7- | sed 's/.$//')
	mv ${serverfiles}/mods/*.zip ${tmpdir}/factorio/mods
	tmp_mods_read="${tmpdir}/factorio/mods/*"
	for tmp_mods_file in $tmp_mods_read; do
  		echo "Processing $tmp_mod_file file..."
		get_file_ver=$(zipgrep -h "version" "${tmp_mods_file}" | sed '2,$d' | tr -d '"' | sed 's/.$//')
		get_file_ver=$(cut -d ":" -f 2 <<< "$get_file_ver")
		get_file_ver=$(echo ${get_file_ver//[[:blank:]]/} | sed 's/\,//g')
		while read -r installed_mods; do
			while [[ ${get_mod_factorio_version} != "null" ]] ; do
                        ver=$((ver+1))
                        get_mod__version=$(curl -s --request GET https://mods.factorio.com/api/mods/${installed_mods} | jq ".releases[${ver}] .info_json .version" | sed -e 's/^"//' -e 's/")
			get_mod_fctr_version=$(curl -s --request GET https://mods.factorio.com/api/mods/${installed_mods} | jq ".releases[${ver}] .info_json .factorio_version" | sed -e 's/^"//' -e 's/")
                        echo "${get_mod_factorio_version}:${ver}"
                done

		done <<< "${installed_mods}"
	done
	mv ${tmpdir}/factorio/mods/*.zip ${serverfiles}/mods
}
fn_check_download_factorio_mods(){
	installed_mods=$(grep -Po '"name":.*?[^\\]",' ${serverfiles}/mods/mod-list.json | tr -d '"' | cut -c 7- | sed 's/.$//')
	while read -r installed_mods; do
		(
		while [[ ${get_mod_factorio_version} != "null" ]] ; do
			ver=$((ver+1))
			get_mod_factorio_version=$(curl -s --request GET https://mods.factorio.com/api/mods/${installed_mods} | jq ".releases[${ver}] .info_json .factorio_version" | sed -e 's/^"//' -e 's/"$//')
			#Use ?????
			#download_url="${installed_mods}:"
			echo "${get_mod_factorio_version}:${ver}"
		done
		) | while read ver_check
			do
				currentbuild=$(grep "Loading mod base" "${serverfiles}/factorio-current.log" 2> /dev/null | awk '{print $5}' | tail -1 | cut -f1,2 -d'.')
				ver=$(cut -d ":" -f 2 <<< "$ver_check")
				mod_ver=$(echo "${ver_check}" | cut -f1 -d":")
				echo -ne "[ INFO ] Updateing mods of fctrserver: Working on array $ver of ${installed_mods}"\\r
				if [[ ${mod_ver} == ${currentbuild} ]]; then
					get_mod_download=$(curl -s --request GET https://mods.factorio.com/api/mods/${installed_mods} | jq ".releases[${ver}] .download_url" | sed -e 's/^"//' -e 's/"$//')
					echo "https://mods.factorio.com${get_mod_download}" > ${tmpdir}/factorio/mods-download-link/${installed_mods}
				fi
			done
	done <<< "${installed_mods}"
}
fn_download_factorio_mods(){
	mv ${serverfiles}/mods/mod-list.json ${tmpdir}/factorio/mod-list.json
	login_data="?username=${username}&token=${token}"
	for mod_dl in "${tmpdir}/factorio/mods-download-link"/*; do
    		download=$(cat "$mod_dl")
		download_full=$(echo "${download}${login_data}")
		wget --content-disposition -qP ${serverfiles}/mods/ ${download_full}
	done
	find ${serverfiles}/mods -type f -name "*\?*" -exec sh -c 'mv $1 $(echo $1 | cut -d\? -f1)' mv {}  \;
	mv ${tmpdir}/factorio/mod-list.json ${serverfiles}/mods/mod-list.json
	rm -rf ${tmpdir}/factorio/mod-list.json
}
if [ -e "${modlist}" ]; then
	installed_mods_count=$(grep -Po '"name":.*?[^\\]",' ${serverfiles}/mods/mod-list.json | tr -d '"' | cut -c 7- | sed 's/.$//' | wc -l)
	if [[ ${installed_mods_count} == "0" || ${installed_mods_count} == "1" ]]; then
		echo 'No mods installed, or base mod not installed (impossible)'
	else
		fn_check_mod_version
		#fn_check_download_factorio_mods
		files=(${tmpdir}/factorio/mods-download/*)
		if [ ${#files[@]} -gt 0 ]; then
        		#fn_download_factorio_mods
			:
		fi

	fi
else
  	echo "Please launch fctrserver once with ./fctrserver start"
fi
echo ""

#!/bin/bash

# Fetch SABnzbd version
url_sabnzbd="https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest"
version=$(curl -fsSL "${url_sabnzbd}" | jq -re '.tag_name') || exit 1

# Fetch par2cmdline-turbo version
url_par2="https://api.github.com/repos/animetosho/par2cmdline-turbo/releases/latest"
par2turbo_version=$(curl -fsSL "${url_par2}" | jq -re '.tag_name') || exit 1

json=$(cat VERSION.json)
jq --sort-keys \
    --arg version "${version//v/}" \
    --arg par2turbo_version "${par2turbo_version//v/}" \
    '.version = $version | .par2turbo_version = $par2turbo_version' <<< "${json}" | tee VERSION.json

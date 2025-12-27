#!/bin/bash

. ./scripts/INCLUDE.sh

# openclash_core URL generation
if [[ "${ARCH_3}" == "x86_64" ]]; then
    meta_file="mihomo-linux-${ARCH_1}-compatible"
else
    meta_file="mihomo-linux-${ARCH_1}"
fi
openclash_core=$(curl -s "https://api.github.com/repos/MetaCubeX/mihomo/releases/latest" | grep "browser_download_url" | grep -oE "https.*${meta_file}-v[0-9]+\.[0-9]+\.[0-9]+\.gz" | head -n 1)

# Openclash IPK
openclash_file_ipk="luci-app-openclash"
openclash_file_ipk_down=$(curl -s "https://api.github.com/repos/de-quenx/OpenClash-x/releases" | grep "browser_download_url" | grep -oE "https.*${openclash_file_ipk}.*.ipk" | head -n 1)

# passwall_core URL generation
passwall_file_ipk="luci-24.10_luci-app-passwall"
passwall_core_file_zip="passwall_packages_ipk_${ARCH_3}"
passwall_file_ipk_down=$(curl -s "https://api.github.com/repos/xiaorouji/openwrt-passwall/releases" | grep "browser_download_url" | grep -oE "https.*${passwall_file_ipk}.*.ipk" | head -n 1)
passwall_core_file_zip_down=$(curl -s "https://api.github.com/repos/xiaorouji/openwrt-passwall/releases" | grep "browser_download_url" | grep -oE "https.*${passwall_core_file_zip}.*.zip" | head -n 1)

# Nikki URL generation
nikki_file_ipk="nikki_${ARCH_3}-openwrt-${VEROP}"
nikki_file_ipk_down=$(curl -s "https://api.github.com/repos/de-quenx/nikki-x/releases" | grep "browser_download_url" | grep -oE "https.*${nikki_file_ipk}.*.tar.gz" | head -n 1)

# Insomclash URL generation
insomclash_file_ipk="luci-app-insomclash"
insomclash_core_ipk="insomclash_1.0.3-r1_${ARCH_3}"
insomclash_file_ipk_down=$(curl -s "https://api.github.com/repos/bobbyunknown/Insomclash/releases" | grep "browser_download_url" | grep -oE "https.*${insomclash_file_ipk}.*.ipk" | head -n 1)
insomclash_core_ipk_down=$(curl -s "https://api.github.com/repos/bobbyunknown/Insomclash/releases" | grep "browser_download_url" | grep -oE "https.*${insomclash_core_ipk}.ipk" | head -n 1)

# Function to download and setup OpenClash
setup_openclash() {
    log "INFO" "Downloading OpenClash packages"
    ariadl "${openclash_file_ipk_down}" "packages/openclash.ipk"
    ariadl "${openclash_core}" "files/etc/openclash/core/clash_meta.gz"
    gzip -d "files/etc/openclash/core/clash_meta.gz" || error_msg "Error: Failed to extract OpenClash package."
}

# Function to download and setup PassWall
setup_passwall() {
    log "INFO" "Downloading PassWall packages"
    ariadl "${passwall_file_ipk_down}" "packages/passwall.ipk"
    ariadl "${passwall_core_file_zip_down}" "packages/passwall.zip"
    unzip -qq "packages/passwall.zip" -d packages && rm "packages/passwall.zip" || error_msg "Error: Failed to extract PassWall package."
}

# Function to download and setup Nikki
setup_nikki() {
    log "INFO" "Downloading Nikki packages"
    ariadl "${nikki_file_ipk_down}" "packages/nikki.tar.gz"
    tar -xzvf "packages/nikki.tar.gz" -C packages > /dev/null 2>&1 && rm "packages/nikki.tar.gz" || error_msg "Error: Failed to extract Nikki package."
}

# Function to download and setup Insomclash
setup_insomclash() {
    log "INFO" "Downloading Insomclash packages"
    ariadl "${insomclash_file_ipk_down}" "packages/luci-app-insomclash.ipk" || error_msg "Error: Failed to download luci-app-insomclash package."
    ariadl "${insomclash_core_ipk_down}" "packages/insomclash.ipk" || error_msg "Error: Failed to download Insomclash core package."
}

case "$1" in
    openclash)
        setup_openclash
        ;;
    nikki)
        setup_nikki
        ;;
    insomclash)
        setup_insomclash
        ;;
    passwall)
        setup_passwall
        ;;
    nikki-insomclash)
        setup_nikki
        setup_insomclash
        ;;
    nikki-passwall)
        setup_nikki
        setup_passwall
        ;;
    openclash-nikki)
        setup_openclash
        setup_nikki
        ;;
    openclash-insomclash)
        setup_openclash
        setup_insomclash
        ;;
    openclash-nikki-passwall)
        setup_openclash
        setup_nikki
        setup_passwall
        ;;
    no-tunnel)
        ;;
    *)
        log "INFO" "Invalid option. Usage: $0 {openclash|nikki|insomclash|passwall|nikki-passwall|nikki-insomclash|openclash-nikki|openclash-insomclash|openclash-nikki-passwall|no-tunnel}"
        exit 1
        ;;
esac

# Check final status
if [ "$?" -ne 0 ]; then
    error_msg "Download or extraction failed."
    exit 1
else
    log "INFO" "Download and installation completed successfully."
fi
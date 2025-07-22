#!/bin/bash

# === Styling Warna ===
BIBlue='\033[1;94m'
BGCOLOR='\e[1;97;101m'
NC='\e[0m'

# === Validasi Dasar ===
clear
cd /root
if [ "${EUID}" -ne 0 ]; then
    echo "Script harus dijalankan sebagai root!"
    exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo "OpenVZ tidak didukung"
    exit 1
fi

# === Input Nama User ===
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR}        MASUKKAN NAMA KAMU              ${NC}${BIBlue} │${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
until [[ $name =~ ^[a-zA-Z0-9_.-]+$ ]]; do
    read -rp "Nama kamu (tanpa spasi): " -e name
done
echo "$name" > /etc/profil
clear

# === Fungsi Setup Domain ===
function domain(){
    echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
    echo -e "${BIBlue}│ ${BGCOLOR}      MASUKKAN DOMAIN KAMU SENDIRI       ${NC}${BIBlue} │${NC}"
    echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
    until [[ $dnss =~ ^[a-zA-Z0-9_.-]+$ ]]; do
        read -rp "Domain (tanpa spasi): " -e dnss
    done

    rm -rf /etc/xray /etc/v2ray /etc/nsdomain
    mkdir -p /etc/xray /etc/v2ray /etc/nsdomain
    touch /etc/xray/domain /etc/v2ray/domain /etc/xray/slwdomain /etc/v2ray/scdomain

    echo "$dnss" > /root/domain
    echo "$dnss" > /root/scdomain
    echo "$dnss" > /etc/xray/scdomain
    echo "$dnss" > /etc/v2ray/scdomain
    echo "$dnss" > /etc/xray/domain
    echo "$dnss" > /etc/v2ray/domain
    echo "IP=$dnss" > /var/lib/ipvps.conf
    clear
}

# === Fungsi Instalasi Dasar ===
function Casper2(){
    sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1
    ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
    apt update -y && apt install git curl python -y >/dev/null 2>&1
    wget -q https://raw.githubusercontent.com/pikaproject/autosc/main/tools.sh
    chmod +x tools.sh && bash tools.sh
    clear
}

# === Fungsi Instalasi Layanan ===
function Casper3(){
    wget -q https://raw.githubusercontent.com/pikaproject/autosc/main/install/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh
    clear
    wget -q https://raw.githubusercontent.com/pikaproject/autosc/main/install/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh
    clear
    wget -q https://raw.githubusercontent.com/pikaproject/autosc/main/sshws/insshws.sh && chmod +x insshws.sh && ./insshws.sh
    clear
    wget -q https://raw.githubusercontent.com/pikaproject/autosc/main/install/set-br.sh && chmod +x set-br.sh && ./set-br.sh
    clear
    wget -q https://raw.githubusercontent.com/pikaproject/autosc/main/sshws/ohp.sh && chmod +x ohp.sh && ./ohp.sh
    clear
    wget -q https://raw.githubusercontent.com/pikaproject/autosc/main/update.sh && chmod +x update.sh && ./update.sh
    clear
    wget -q https://raw.githubusercontent.com/pikaproject/autosc/main/slowdns/installsl.sh && chmod +x installsl.sh && bash installsl.sh
    clear
    wget -q https://raw.githubusercontent.com/pikaproject/autosc/main/install/udp-custom.sh && chmod +x udp-custom.sh && bash udp-custom.sh
    clear
    wget -q https://raw.githubusercontent.com/pikaproject/autosc/main/noobz/noobzvpns.zip && unzip -qq noobzvpns.zip && chmod +x noobzvpns/* && cd noobzvpns && bash install.sh && cd .. && rm -rf noobzvpns
    systemctl restart noobzvpns
    clear
    wget -q https://raw.githubusercontent.com/pikaproject/autosc/main/bin/limit.sh && chmod +x limit.sh && ./limit.sh
    clear
    wget -q https://raw.githubusercontent.com/pikaproject/autosc/main/install/ins-trgo.sh && chmod +x ins-trgo.sh && ./ins-trgo.sh
    clear
}

# === Eksekusi ===
start=$(date +%s)
domain
Casper2
Casper3
runtime=$(( $(date +%s) - $start ))

# === Finalisasi ===
echo -e "${BIBlue}╭════════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR} INSTALL SCRIPT SELESAI (${runtime}s)         ${NC}${BIBlue} │${NC}"
echo -e "${BIBlue}╰════════════════════════════════════════════╯${NC}"
echo ""
read -p "Reboot sekarang? (y/n)? " answer
[[ "$answer" =~ ^[Yy]$ ]] && reboot
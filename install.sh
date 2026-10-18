#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================================
# Script Name: Automatic Ubuntu XFCE Setup for Termux (No Root)
# Version    : 1.2 (With Auto Device & Specs Detection)
# Author     : Zainal Abidin / LP Tech (lptech22)
# ==============================================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${CYAN}======================================================${NC}"
echo -e "${GREEN}  AUTOMATIC UBUNTU XFCE SETUP FOR TERMUX v1.2 (NO ROOT)${NC}"
echo -e "${CYAN}======================================================${NC}"
echo ""

# 1. Deteksi Otomatis Perangkat & Spesifikasi Hardware
echo -e "${YELLOW}[*] Mendeteksi spesifikasi perangkat Anda...${NC}"

# Cek Arsitektur CPU
ARCH=$(uname -m)

# Cek Total RAM (Perkiraan dari /proc/meminfo)
if [ -f /proc/meminfo ]; then
    TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
    TOTAL_RAM_GB=$(awk "BEGIN {printf \"%.1f\", $TOTAL_RAM_MB / 1024}")
else
    TOTAL_RAM_GB="Tidak diketahui"
fi

# Cek Penyimpanan Internal yang Tersedia (Termux home directory)
FREE_STORAGE=$(df -h /data/data/com.termux/files/home | awk 'NR==2 {print $4}')

sleep 1
echo -e "${BLUE}------------------------------------------------------${NC}"
echo -e " ${GREEN}✔ Arsitektur CPU :${NC} $ARCH"
echo -e " ${GREEN}✔ Kapasitas RAM  :${NC} ${TOTAL_RAM_GB} GB"
echo -e " ${GREEN}✔ Sisa Storage   :${NC} $FREE_STORAGE"
echo -e "${BLUE}------------------------------------------------------${NC}"

# Validasi Keamanan Arsitektur (Wajib aarch64 / ARM64)
if [ "$ARCH" != "aarch64" ]; then
    echo -e "${RED}[ERROR] Perangkat Anda berarsitektur $ARCH.${NC}"
    echo -e "${RED}Skrip ini membutuhkan perangkat Android 64-bit (aarch64).${NC}"
    exit 1
fi

# 2. Validasi Akses Penyimpanan
echo -e "\n${YELLOW}[1/6] Memeriksa izin penyimpanan Termux...${NC}"
termux-setup-storage

# 3. Update Paket Termux & Install Dependensi
echo -e "${YELLOW}[2/6] Memperbarui paket Termux & memasang dependensi dasar...${NC}"
pkg update -y && pkg upgrade -y
pkg install x11-repo wget curl proot proot-distro pulseaudio tar -y

# Cek & Install Termux-X11
if ! dpkg -l | grep -q termux-x11-nightly; then
    echo -e "${YELLOW}[*] Memasang Termux-X11...${NC}"
    pkg install termux-x11-nightly -y
fi

# 4. Unduh & Setup Ubuntu (Udroid)
echo -e "\n${YELLOW}[3/6] Mengunduh dan memasang Ubuntu Jammy XFCE...${NC}"
bash <(curl -s https://raw.githubusercontent.com/RandomCoderOrg/ubuntu-on-android/releases/download/v3/udroid-installer) -i jammy-xfce4

# 5. Wizard Interaktif Pemilihan Aplikasi Dasar
echo -e "\n${CYAN}======================================================${NC}"
echo -e "${GREEN}          PILIHAN APLIKASI DASAR (INTERAKTIF)         ${NC}"
echo -e "${CYAN}======================================================${NC}"

APPS_TO_INSTALL=""

read -p "1. Memasang Firefox Web Browser? (y/N): " choice_firefox
if [[ "$choice_firefox" =~ ^[Yy]$ ]]; then
    APPS_TO_INSTALL="$APPS_TO_INSTALL firefox"
fi

read -p "2. Memasang Code-OSS / VS Code ringan? (y/N): " choice_code
if [[ "$choice_code" =~ ^[Yy]$ ]]; then
    APPS_TO_INSTALL="$APPS_TO_INSTALL code-oss"
fi

read -p "3. Memasang LibreOffice (Writer & Calc)? (y/N): " choice_office
if [[ "$choice_office" =~ ^[Yy]$ ]]; then
    APPS_TO_INSTALL="$APPS_TO_INSTALL libreoffice-writer libreoffice-calc"
fi

read -p "4. Memasang GIMP (Editor Foto)? (y/N): " choice_gimp
if [[ "$choice_gimp" =~ ^[Yy]$ ]]; then
    APPS_TO_INSTALL="$APPS_TO_INSTALL gimp"
fi

# 6. Memasang Aplikasi Terpilih di Dalam Environment Ubuntu
if [ -n "$APPS_TO_INSTALL" ]; then
    echo -e "\n${YELLOW}[4/6] Memasang aplikasi terpilih (${BLUE}${APPS_TO_INSTALL# }${YELLOW})...${NC}"
    proot-distro login jammy-xfce4 -- env DEBIAN_FRONTEND=noninteractive bash -c "apt update && apt install -y $APPS_TO_INSTALL"
else
    echo -e "\n${YELLOW}[4/6] Tidak ada aplikasi tambahan yang dipilih.${NC}"
fi

# 7. Pembuatan Shortcut Command 'startlinux'
echo -e "\n${YELLOW}[5/6] Membuat shortcut perintah 'startlinux'...${NC}"
cat << 'EOF' > $PREFIX/bin/startlinux
#!/data/data/com.termux/files/usr/bin/bash

# Jalankan Audio Server di Latar Belakang
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 >/dev/null 2>&1

# Set Variabel Tampilan
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1

echo "================================================="
echo "   Membuka Ubuntu XFCE Desktop via Termux-X11... "
echo "================================================="
echo "Pastikan aplikasi Termux-X11 sudah dibuka terlebih dahulu!"
echo ""

udroid login jammy-xfce4 -- startxfce4
EOF

chmod +x $PREFIX/bin/startlinux

# 8. Selesai
echo -e "\n${GREEN}======================================================${NC}"
echo -e "${GREEN}          INSTALASI v1.2 BERHASIL SELESAI!            ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo -e "Untuk menjalankan Ubuntu Desktop:"
echo -e "1. Buka aplikasi ${CYAN}Termux-X11${NC}"
echo -e "2. Ketik perintah: ${YELLOW}startlinux${NC} di Termux"
echo -e "${GREEN}======================================================${NC}"

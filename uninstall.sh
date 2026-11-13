#!/data/data/com.termux/files/usr/bin/bash
#########################################################
#  tubuntu - Uninstaller
#  Menghapus semua komponen yang dipasang install.sh
#  Pembuat: LP Tech
#########################################################

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

confirm() {
    echo -e "${YELLOW}Ini akan menghapus:${NC}"
    echo "  - Server VNC dan desktop XFCE4"
    echo "  - Firefox dan VS Code (code-oss)"
    echo "  - Skrip, pintasan, dan perintah 'tubuntu'"
    echo ""
    echo -e "${RED}Tindakan ini tidak dapat dibatalkan.${NC}"
    echo ""
    local ans
    read -r -p "Ketik 'UNINSTALL' untuk melanjutkan: " ans < /dev/tty
    if [ "$ans" != "UNINSTALL" ]; then
        echo "Dibatalkan."
        exit 0
    fi
}

stop_desktop() {
    echo -e "${PURPLE}== Menghentikan desktop ==${NC}"
    vncserver -kill :1 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Desktop dihentikan"
}

remove_scripts() {
    echo -e "${PURPLE}== Menghapus skrip dan perintah ==${NC}"
    rm -f ~/start-tubuntu.sh ~/stop-tubuntu.sh ~/tubuntu
    rm -f "$PREFIX/bin/tubuntu"
    echo -e "  ${GREEN}✓${NC} Skrip dan perintah dihapus"
}

remove_shortcuts() {
    echo -e "${PURPLE}== Menghapus pintasan ==${NC}"
    rm -f ~/Desktop/Firefox.desktop ~/Desktop/VSCode.desktop ~/Desktop/Terminal.desktop
    rmdir ~/Desktop 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Pintasan dihapus"
}

remove_packages() {
    echo -e "${PURPLE}== Menghapus paket ==${NC}"
    pkg uninstall -y tigervnc xfce4 xfce4-terminal thunar mousepad firefox code-oss >/dev/null 2>&1
    pkg uninstall -y x11-repo tur-repo >/dev/null 2>&1
    echo -e "  ${GREEN}✓${NC} Paket dihapus"
}

# Membersihkan sisa instalasi versi lama (Termux-X11, PulseAudio, GPU Turnip/Zink)
remove_legacy() {
    echo -e "${PURPLE}== Membersihkan sisa versi lama ==${NC}"
    pkill -9 -f "termux.x11" 2>/dev/null
    pkill -9 -f "pulseaudio" 2>/dev/null
    pkg uninstall -y termux-x11-nightly xorg-xrandr pulseaudio mesa-zink \
        mesa-vulkan-icd-freedreno mesa-vulkan-icd-swrast vulkan-loader-android >/dev/null 2>&1
    rm -f ~/.config/tubuntu-gpu.sh
    if [ -f ~/.bashrc ]; then
        sed -i '/tubuntu-gpu.sh/d' ~/.bashrc
    fi
    echo -e "  ${GREEN}✓${NC} Sisa versi lama dibersihkan"
}

cleanup() {
    echo -e "${PURPLE}== Pembersihan akhir ==${NC}"
    rm -rf ~/.vnc ~/.config/xfce4 ~/.cache/xfce4 ~/.local/share/xfce4
    pkg clean >/dev/null 2>&1
    echo -e "  ${GREEN}✓${NC} Pembersihan selesai"
}

show_completion() {
    echo ""
    echo -e "${GREEN}✅ tubuntu berhasil dihapus.${NC}"
    echo -e "${WHITE}Termux dan paket umum (git, wget, curl) tetap terpasang.${NC}"
    echo ""
}

main() {
    clear
    confirm
    stop_desktop
    remove_scripts
    remove_shortcuts
    remove_packages
    remove_legacy
    cleanup
    show_completion
    rm -f ~/uninstall.sh
}

main

#!/data/data/com.termux/files/usr/bin/bash
#########################################################
# 🗑️ TUbuntu (Termux Ubuntu) - Uninstaller
# Menghapus semua komponen yang diinstal oleh skrip instalasi
#
# Pembuat: LP Tech (lptech22)
#########################################################

# ============== WARNA ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

# ============== BANNER ==============
show_banner() {
    clear
    echo -e "${RED}"
    cat << 'BANNER'
╔══════════════════════════════════════╗
║                                      ║
║ 🗑️ PENCOPOTAN TUbuntu (UNINSTALL) 🗑️ ║
║                                      ║
║      Hapus Semua Komponen            ║
║                                      ║
╚══════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    echo -e "${WHITE} Tindakan ini akan menghapus semua komponen TUbuntu.${NC}"
    echo ""
}

# ============== KONFIRMASI ==============
confirm_uninstall() {
    echo -e "${YELLOW}⚠️  PERINGATAN: Tindakan ini akan menghapus:${NC}"
    echo -e "  • Lingkungan desktop XFCE4 & aplikasi (Firefox, VS Code)"
    echo -e "  • Skrip kustom, pintasan, dan konfigurasi GPU"
    echo -e "  • Perintah global 'tubuntu'"
    echo ""
    echo -e "${RED}Tindakan ini tidak dapat dibatalkan!${NC}"
    echo ""
    read -p "$(echo -e "${WHITE}Ketik 'UNINSTALL' untuk mengonfirmasi: ${NC})" confirm
    
    if [ "$confirm" != "UNINSTALL" ]; then
        echo -e "${YELLOW}Pencopotan dibatalkan.${NC}"
        exit 0
    fi
}

# ============== HENTIKAN PROSES YANG BERJALAN ==============
stop_processes() {
    echo ""
    echo -e "${PURPLE}[*] Menghentikan proses yang berjalan...${NC}"
    
    pkill -9 -f "termux.x11" 2>/dev/null
    pkill -9 -f "xfce" 2>/dev/null
    pkill -9 -f "pulseaudio" 2>/dev/null
    pkill -9 -f "dbus" 2>/dev/null
    
    echo -e "  ${GREEN}✓${NC} Proses dihentikan"
}

# ============== HAPUS SKRIP & PERINTAH GLOBAL ==============
remove_scripts() {
    echo ""
    echo -e "${PURPLE}[*] Menghapus skrip dan perintah global...${NC}"
    
    rm -f ~/start-tubuntu.sh
    rm -f ~/stop-tubuntu.sh
    rm -f ~/.config/tubuntu-gpu.sh
    rm -f ~/tubuntu
    rm -f /data/data/com.termux/files/usr/bin/tubuntu
    
    if [ -f ~/.bashrc ]; then
        sed -i '/tubuntu-gpu.sh/d' ~/.bashrc
        sed -i '/TUbuntu/d' ~/.bashrc
    fi
    
    echo -e "  ${GREEN}✓${NC} Skrip dan perintah dihapus"
}

# ============== HAPUS PINTASAN DESKTOP ==============
remove_shortcuts() {
    echo ""
    echo -e "${PURPLE}[*] Menghapus pintasan desktop...${NC}"
    
    rm -rf ~/Desktop/*.desktop 2>/dev/null
    rmdir ~/Desktop 2>/dev/null
    
    echo -e "  ${GREEN}✓${NC} Pintasan dihapus"
}

# ============== HAPUS APLIKASI ==============
remove_apps() {
    echo ""
    echo -e "${PURPLE}[*] Menghapus aplikasi...${NC}"
    
    pkg uninstall firefox -y 2>/dev/null
    pkg uninstall code-oss -y 2>/dev/null
    pkg uninstall git -y 2>/dev/null
    pkg uninstall wget -y 2>/dev/null
    pkg uninstall curl -y 2>/dev/null
    
    echo -e "  ${GREEN}✓${NC} Aplikasi dihapus"
}

# ============== HAPUS AUDIO ==============
remove_audio() {
    echo ""
    echo -e "${PURPLE}[*] Menghapus dukungan audio...${NC}"
    
    pulseaudio --kill 2>/dev/null
    pkg uninstall pulseaudio -y 2>/dev/null
    
    echo -e "  ${GREEN}✓${NC} Audio dihapus"
}

# ============== HAPUS DRIVER GPU ==============
remove_gpu() {
    echo ""
    echo -e "${PURPLE}[*] Menghapus akselerasi GPU...${NC}"
    
    pkg uninstall mesa-zink -y 2>/dev/null
    pkg uninstall mesa-vulkan-icd-freedreno -y 2>/dev/null
    pkg uninstall mesa-vulkan-icd-swrast -y 2>/dev/null
    pkg uninstall vulkan-loader-android -y 2>/dev/null
    
    echo -e "  ${GREEN}✓${NC} Driver GPU dihapus"
}

# ============== HAPUS DESKTOP ==============
remove_desktop() {
    echo ""
    echo -e "${PURPLE}[*] Menghapus Desktop XFCE4...${NC}"
    
    pkg uninstall xfce4 -y 2>/dev/null
    pkg uninstall xfce4-terminal -y 2>/dev/null
    pkg uninstall thunar -y 2>/dev/null
    pkg uninstall mousepad -y 2>/dev/null
    
    rm -rf ~/.config/xfce4 2>/dev/null
    rm -rf ~/.cache/xfce4 2>/dev/null
    
    echo -e "  ${GREEN}✓${NC} Desktop dihapus"
}

# ============== HAPUS X11 ==============
remove_x11() {
    echo ""
    echo -e "${PURPLE}[*] Menghapus Termux-X11...${NC}"
    
    pkg uninstall termux-x11-nightly -y 2>/dev/null
    pkg uninstall xorg-xrandr -y 2>/dev/null
    
    echo -e "  ${GREEN}✓${NC} X11 dihapus"
}

# ============== HAPUS REPOSITORI ==============
remove_repos() {
    echo ""
    echo -e "${PURPLE}[*] Menghapus repositori paket...${NC}"
    
    pkg uninstall tur-repo -y 2>/dev/null
    pkg uninstall x11-repo -y 2>/dev/null
    
    echo -e "  ${GREEN}✓${NC} Repositori dihapus"
}

# ============== PEMBERSIHAN AKHIR ==============
cleanup() {
    echo ""
    echo -e "${PURPLE}[*] Melakukan pembersihan akhir...${NC}"
    
    rm -rf ~/.config/tubuntu* 2>/dev/null
    pkg clean 2>/dev/null
    
    rm -rf ~/.local/share/xfce4 2>/dev/null
    rm -rf ~/.xsessions 2>/dev/null
    rm -rf ~/.xsession-errors 2>/dev/null
    
    echo -e "  ${GREEN}✓${NC} Pembersihan selesai"
}

# ============== SELESAI ==============
show_completion() {
    echo ""
    echo -e "${GREEN}"
    cat << 'COMPLETE'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║          ✅ PENCOPOTAN TUbuntu BERHASIL! ✅                   ║
║                                                               ║
║          Semua komponen telah dihapus dari sistem.            ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
COMPLETE
    echo -e "${NC}"
    echo -e "${WHITE}📱 TUbuntu telah berhasil dihapus sepenuhnya.${NC}"
    echo ""
    echo -e "${YELLOW}Catatan: Termux Anda tetap terinstal seperti semula.${NC}"
    echo ""
}

# ============== UTAMA ==============
main() {
    show_banner
    confirm_uninstall
    
    stop_processes
    remove_scripts
    remove_shortcuts
    remove_apps
    remove_audio
    remove_gpu
    remove_desktop
    remove_x11
    remove_repos
    cleanup
    
    show_completion
}

main

#!/data/data/com.termux/files/usr/bin/bash
#########################################################
🗑️ UBUNTU TERMUX UNINSTALLER
Removes all components installed by Ubuntu Termux Installer
Author: LP Tech
#########################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

show_banner() {
    clear
    echo -e "${RED}"
    cat << 'BANNER'
╔══════════════════════════════════════╗
║                                      ║
║   🗑️ UBUNTU TERMUX UNINSTALLER 🗑️     ║
║                                      ║
║        Remove All Components         ║
║                                      ║
╚══════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    echo -e "${WHITE} This will remove all installed Ubuntu Termux components.${NC}"
    echo ""
}

confirm_uninstall() {
    echo -e "${YELLOW}⚠️ WARNING: This will remove:${NC}"
    echo -e " • XFCE4 desktop environment and Firefox browser"
    echo -e " • Custom launcher scripts and configurations"
    echo -e " • GPU acceleration configs"
    echo ""
    echo -e "${RED}This action cannot be undone!${NC}"
    echo ""
    read -p "$(echo -e "${WHITE}Type 'UNINSTALL' to confirm: ${NC})" confirm

    if [ "$confirm" != "UNINSTALL" ]; then
        echo -e "${YELLOW}Uninstall cancelled.${NC}"
        exit 0
    fi
}

main() {
    show_banner
    confirm_uninstall

    echo ""
    echo -e "${PURPLE}[*] Stopping running processes...${NC}"
    pkill -9 -f "termux.x11" 2>/dev/null
    pkill -9 -f "xfce" 2>/dev/null
    pkill -9 -f "pulseaudio" 2>/dev/null
    pkill -9 -f "dbus" 2>/dev/null
    echo -e " ${GREEN}✓${NC} Processes stopped"

    echo ""
    echo -e "${PURPLE}[*] Removing custom scripts...${NC}"
    rm -f ~/start-ubuntu.sh
    rm -f ~/stop-ubuntu.sh
    rm -f ~/.config/ubuntu-gpu.sh
    if [ -f ~/.bashrc ]; then
        sed -i '/ubuntu-gpu.sh/d' ~/.bashrc
        sed -i '/Ubuntu Termux/d' ~/.bashrc
    fi
    echo -e " ${GREEN}✓${NC} Scripts removed"

    echo ""
    echo -e "${PURPLE}[*] Removing desktop shortcuts...${NC}"
    rm -rf ~/Desktop/*.desktop 2>/dev/null
    rmdir ~/Desktop 2>/dev/null
    echo -e " ${GREEN}✓${NC} Shortcuts removed"

    echo ""
    echo -e "${PURPLE}[*] Removing applications and desktop...${NC}"
    pkg uninstall firefox -y 2>/dev/null
    pkg uninstall xfce4 -y 2>/dev/null
    pkg uninstall xfce4-terminal -y 2>/dev/null
    pkg uninstall thunar -y 2>/dev/null
    pkg uninstall mousepad -y 2>/dev/null
    pkg uninstall pulseaudio -y 2>/dev/null
    pkg uninstall termux-x11-nightly -y 2>/dev/null
    pkg uninstall xorg-xrandr -y 2>/dev/null
    pkg uninstall mesa-zink -y 2>/dev/null
    pkg uninstall mesa-vulkan-icd-freedreno -y 2>/dev/null
    pkg uninstall mesa-vulkan-icd-swrast -y 2>/dev/null
    pkg uninstall vulkan-loader-android -y 2>/dev/null
    pkg uninstall tur-repo -y 2>/dev/null
    pkg uninstall x11-repo -y 2>/dev/null
    echo -e " ${GREEN}✓${NC} Components removed"

    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║               ✅ UNINSTALLATION COMPLETE! ✅                  ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

main

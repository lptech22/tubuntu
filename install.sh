#!/data/data/com.termux/files/usr/bin/bash
#######################################################
📱 UBUNTU TERMUX INSTALLER - XFCE Desktop v2.0
Features:
- Overall progress percentage
- GPU acceleration auto-setup (Turnip/Zink)
- Firefox browser pre-installed
- One-click desktop launch
Author: LP Tech
#######################################################

============== CONFIGURATION ==============

TOTAL_STEPS=8
CURRENT_STEP=0

============== COLORS ==============

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

============== PROGRESS FUNCTIONS ==============

update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))

    FILLED=$((PERCENT / 5))
    EMPTY=$((20 - FILLED))
    BAR="${GREEN}"
    for ((i=0; i<FILLED; i++)); do BAR+="█"; done
    BAR+="${GRAY}"
    for ((i=0; i<EMPTY; i++)); do BAR+="░"; done
    BAR+="${NC}"

    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN} 📊 OVERALL PROGRESS: ${WHITE}Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC} ${BAR} ${WHITE}${PERCENT}%${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

spinner() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r ${YELLOW}⏳${NC} ${message} ${CYAN}${spin:$i:1}${NC} "
        sleep 0.1
    done
    wait $pid
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        printf "\r ${GREEN}✓${NC} ${message} \n"
    else
        printf "\r ${RED}✗${NC} ${message} ${RED}(failed)${NC} \n"
    fi
    return $exit_code
}

install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}
    (yes | pkg install $pkg -y > /dev/null 2>&1) & spinner $! "Installing ${name}..."
}

============== BANNER ==============

show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
╔══════════════════════════════════════╗
║                                      ║
║   🚀 UBUNTU TERMUX INSTALLER v2.0 🚀   ║
║                                      ║
║              By LP Tech              ║
║                                      ║
╚══════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    echo -e "${WHITE} By LP Tech${NC}"
    echo ""
}

============== DEVICE DETECTION ==============

detect_device() {
    echo -e "${PURPLE}[*] Detecting your device...${NC}"
    echo ""

    DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
    DEVICE_BRAND=$(getprop ro.product.brand 2>/dev/null || echo "Unknown")
    ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
    CPU_ABI=$(getprop ro.product.cpu.abi 2>/dev/null || echo "arm64-v8a")
    
    GPU_VENDOR=$(getprop ro.hardware.egl 2>/dev/null || echo "")

    echo -e " ${GREEN}📱${NC} Device: ${WHITE}${DEVICE_BRAND} ${DEVICE_MODEL}${NC}"
    echo -e " ${GREEN}🤖${NC} Android: ${WHITE}${ANDROID_VERSION}${NC}"
    echo -e " ${GREEN}⚙️${NC} CPU: ${WHITE}${CPU_ABI}${NC}"

    if [[ "$GPU_VENDOR" == *"adreno"* ]] || [[ "$DEVICE_BRAND" == *"samsung"* ]] || [[ "$DEVICE_BRAND" == *"Samsung"* ]] || [[ "$DEVICE_BRAND" == *"oneplus"* ]] || [[ "$DEVICE_BRAND" == *"xiaomi"* ]]; then
        GPU_DRIVER="freedreno"
        echo -e " ${GREEN}🎮${NC} GPU: ${WHITE}Adreno (Qualcomm) - Turnip driver${NC}"
    else
        GPU_DRIVER="swrast"
        echo -e " ${GREEN}🎮${NC} GPU: ${WHITE}Software rendering${NC}"
    fi
    echo ""
    sleep 1
}

============== STEP 1: UPDATE SYSTEM ==============

step_update() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Updating system packages...${NC}"
    echo ""
    (yes | pkg update -y > /dev/null 2>&1) & spinner $! "Updating package lists..."
    (yes | pkg upgrade -y > /dev/null 2>&1) & spinner $! "Upgrading installed packages..."
}

============== STEP 2: INSTALL REPOSITORIES ==============

step_repos() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Adding package repositories...${NC}"
    echo ""
    install_pkg "x11-repo" "X11 Repository"
    install_pkg "tur-repo" "TUR Repository (Firefox)"
}

============== STEP 3: INSTALL TERMUX-X11 ==============

step_x11() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Termux-X11...${NC}"
    echo ""
    install_pkg "termux-x11-nightly" "Termux-X11 Display Server"
    install_pkg "xorg-xrandr" "XRandR (Display Settings)"
}

============== STEP 4: INSTALL DESKTOP ==============

step_desktop() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing XFCE4 Desktop...${NC}"
    echo ""
    install_pkg "xfce4" "XFCE4 Desktop Environment"
    install_pkg "xfce4-terminal" "XFCE4 Terminal"
    install_pkg "thunar" "Thunar File Manager"
    install_pkg "mousepad" "Mousepad Text Editor"
}

============== STEP 5: INSTALL GPU DRIVERS ==============

step_gpu() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing GPU Acceleration (Turnip/Zink)...${NC}"
    echo ""
    install_pkg "mesa-zink" "Mesa Zink (OpenGL over Vulkan)"
    if [ "$GPU_DRIVER" == "freedreno" ]; then
        install_pkg "mesa-vulkan-icd-freedreno" "Turnip Adreno GPU Driver"
    else
        install_pkg "mesa-vulkan-icd-swrast" "Software Vulkan Renderer"
    fi
    install_pkg "vulkan-loader-android" "Vulkan Loader"
    echo -e " ${GREEN}✓${NC} GPU acceleration configured!"
}

============== STEP 6: INSTALL AUDIO ==============

step_audio() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Audio Support...${NC}"
    echo ""
    install_pkg "pulseaudio" "PulseAudio Sound Server"
}

============== STEP 7: INSTALL FIREFOX & UTILITIES ==============

step_apps() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Firefox & Utilities...${NC}"
    echo ""
    install_pkg "firefox" "Firefox Browser"
    install_pkg "git" "Git Version Control"
    install_pkg "wget" "Wget Downloader"
    install_pkg "curl" "cURL"
}

============== STEP 8: CREATE LAUNCHER SCRIPTS & SHORTCUTS ==============

step_launchers() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating Launcher Scripts & Shortcuts...${NC}"
    echo ""

    mkdir -p ~/.config
    cat > ~/.config/ubuntu-gpu.sh << 'GPUEOF'
# Ubuntu Termux - GPU Acceleration Config
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy
GPUEOF
    echo -e " ${GREEN}✓${NC} GPU config created"

    if ! grep -q "ubuntu-gpu.sh" ~/.bashrc 2>/dev/null; then
        echo 'source ~/.config/ubuntu-gpu.sh 2>/dev/null' >> ~/.bashrc
    fi

    cat > ~/start-ubuntu.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "🚀 Starting Ubuntu Termux Desktop..."
echo ""

source ~/.config/ubuntu-gpu.sh 2>/dev/null

echo "🔄 Cleaning up old sessions..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null

unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
echo "🔊 Starting audio server..."
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1

echo "📺 Starting X11 display server..."
termux-x11 :0 -ac &
sleep 3

export DISPLAY=:0

echo "🖥️ Launching XFCE4 Desktop..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " 📱 Open the Termux-X11 app to see desktop!"
echo " 🔊 Audio is enabled!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
exec startxfce4
LAUNCHEREOF
    chmod +x ~/start-ubuntu.sh
    echo -e " ${GREEN}✓${NC} Created ~/start-ubuntu.sh"

    cat > ~/stop-ubuntu.sh << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Stopping Ubuntu Termux Desktop..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null
echo "Desktop stopped."
STOPEOF
    chmod +x ~/stop-ubuntu.sh
    echo -e " ${GREEN}✓${NC} Created ~/stop-ubuntu.sh"

    mkdir -p ~/Desktop
    cat > ~/Desktop/Firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=firefox
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
EOF

    cat > ~/Desktop/Terminal.desktop << 'EOF'
[Desktop Entry]
Name=Terminal
Comment=XFCE Terminal
Exec=xfce4-terminal
Icon=utilities-terminal
Type=Application
Categories=System;TerminalEmulator;
EOF

    chmod +x ~/Desktop/*.desktop 2>/dev/null
    echo -e " ${GREEN}✓${NC} Desktop shortcuts created"
}

============== COMPLETION ==============

show_completion() {
    echo ""
    echo -e "${GREEN}"
    cat << 'COMPLETE'
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║               ✅ INSTALLATION COMPLETE! ✅                    ║
║                                                               ║
║               🎉 100% - All Done! 🎉                          ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
COMPLETE
    echo -e "${NC}"

    echo -e "${WHITE}📱 Your Ubuntu Termux Desktop is ready!${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}🚀 TO START THE DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/start-ubuntu.sh${NC}"
    echo ""
    echo -e "${WHITE}🛑 TO STOP THE DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/stop-ubuntu.sh${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}📦 INSTALLED APPLICATIONS:${NC}"
    echo -e " • Firefox Browser"
    echo -e " • XFCE4 Desktop + GPU Acceleration (Turnip/Zink)"
    echo -e " • Thunar File Manager & XFCE Terminal"
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}   By LP Tech${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}⚡ TIP: Open Termux-X11 app first, then run start-ubuntu.sh${NC}"
    echo ""
}

============== MAIN INSTALLATION ==============

main() {
    show_banner
    echo -e "${WHITE} This script will install a complete Linux XFCE desktop with${NC}"
    echo -e "${WHITE} Firefox browser and GPU acceleration on your Android phone.${NC}"
    echo ""
    echo -e "${GRAY} Estimated time: 5-10 minutes (depends on internet speed)${NC}"
    echo ""
    echo -e "${YELLOW} Press Enter to start installation, or Ctrl+C to cancel...${NC}"
    read

    detect_device
    step_update
    step_repos
    step_x11
    step_desktop
    step_gpu
    step_audio
    step_apps
    step_launchers

    show_completion
}

main

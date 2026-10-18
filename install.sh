#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  📱 TUbuntu (Termux Ubuntu) - Ultimate Installer
#  
#  Fitur:
#  - Persentase progres keseluruhan
#  - Pengaturan otomatis akselerasi GPU (Turnip/Zink)
#  - Lingkungan Desktop XFCE4 yang ringan
#  - Hanya menginstal Firefox dan VS Code
#  
#  Pembuat: LP Tech
#  YouTube: https://youtube.com/@LPTech
#######################################################

# ============== KONFIGURASI ==============
TOTAL_STEPS=11
CURRENT_STEP=0

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
BOLD='\033[1m'

# ============== FUNGSI PROGRES ==============
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
    echo -e "${CYAN}  📊 PROGRES KESELURUHAN: ${WHITE}Langkah ${CURRENT_STEP}/${TOTAL_STEPS}${NC} ${BAR} ${WHITE}${PERCENT}%${NC}"
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
        printf "\r  ${YELLOW}⏳${NC} ${message} ${CYAN}${spin:$i:1}${NC}  "
        sleep 0.1
    done
    
    wait $pid
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        printf "\r  ${GREEN}✓${NC} ${message}                    \n"
    else
        printf "\r  ${RED}✗${NC} ${message} ${RED}(gagal)${NC}     \n"
    fi
    
    return $exit_code
}

install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}
    
    (yes | pkg install $pkg -y > /dev/null 2>&1) &
    spinner $! "Menginstal ${name}..."
}

# ============== BANNER ASCII TUbuntu ==============
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
████████╗██╗   ██╗██████╗ ██╗   ██╗███╗   ██╗████████╗██╗   ██╗
╚══██╔══╝██║   ██║██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██║   ██║
   ██║   ██║   ██║██████╔╝██║   ██║██╔██╗ ██║   ██║   ██║   ██║
   ██║   ██║   ██║██╔══██╗██║   ██║██║╚██╗██║   ██║   ██║   ██║
   ██║   ╚██████╔╝██████╔╝╚██████╔╝██║ ╚████║   ██║   ╚██████╔╝
   ╚═╝    ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝    ╚═════╝ 
BANNER
    echo -e "${NC}"
    echo -e "${WHITE}       📱 TUbuntu (Termux Ubuntu) by LP Tech${NC}"
    echo ""
}

# ============== DETEKSI PERANGKAT ==============
detect_device() {
    echo -e "${PURPLE}[*] Mendeteksi perangkat Anda...${NC}"
    echo ""
    
    DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null || echo "Tidak Diketahui")
    DEVICE_BRAND=$(getprop ro.product.brand 2>/dev/null || echo "Tidak Diketahui")
    ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null || echo "Tidak Diketahui")
    CPU_ABI=$(getprop ro.product.cpu.abi 2>/dev/null || echo "arm64-v8a")
    GPU_VENDOR=$(getprop ro.hardware.egl 2>/dev/null || echo "")
    
    echo -e "  ${GREEN}📱${NC} Perangkat: ${WHITE}${DEVICE_BRAND} ${DEVICE_MODEL}${NC}"
    echo -e "  ${GREEN}🤖${NC} Android: ${WHITE}${ANDROID_VERSION}${NC}"
    echo -e "  ${GREEN}⚙️${NC}  CPU: ${WHITE}${CPU_ABI}${NC}"
    
    if [[ "$GPU_VENDOR" == *"adreno"* ]] || [[ "$DEVICE_BRAND" == *"samsung"* ]] || [[ "$DEVICE_BRAND" == *"Samsung"* ]] || [[ "$DEVICE_BRAND" == *"oneplus"* ]] || [[ "$DEVICE_BRAND" == *"xiaomi"* ]]; then
        GPU_DRIVER="freedreno"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Adreno (Qualcomm) - Driver Turnip${NC}"
    else
        GPU_DRIVER="swrast"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Rendering Perangkat Lunak${NC}"
    fi
    
    echo ""
    sleep 1
}

# ============== LANGKAH 1: PERBARUI SISTEM ==============
step_update() {
    update_progress
    echo -e "${PURPLE}[Langkah ${CURRENT_STEP}/${TOTAL_STEPS}] Memperbarui paket sistem...${NC}"
    echo ""
    
    (yes | pkg update -y > /dev/null 2>&1) &
    spinner $! "Memperbarui daftar paket..."
    
    (yes | pkg upgrade -y > /dev/null 2>&1) &
    spinner $! "Meningkatkan versi paket terinstal..."
}

# ============== LANGKAH 2: INSTAL REPOSITORI ==============
step_repos() {
    update_progress
    echo -e "${PURPLE}[Langkah ${CURRENT_STEP}/${TOTAL_STEPS}] Menambahkan repositori paket...${NC}"
    echo ""
    
    install_pkg "x11-repo" "Repositori X11"
    install_pkg "tur-repo" "Repositori TUR (Firefox, VS Code)"
}

# ============== LANGKAH 3: INSTAL TERMUX-X11 ==============
step_x11() {
    update_progress
    echo -e "${PURPLE}[Langkah ${CURRENT_STEP}/${TOTAL_STEPS}] Menginstal Termux-X11...${NC}"
    echo ""
    
    install_pkg "termux-x11-nightly" "Server Tampilan Termux-X11"
    install_pkg "xorg-xrandr" "XRandR (Pengaturan Layar)"
}

# ============== LANGKAH 4: INSTAL DESKTOP ==============
step_desktop() {
    update_progress
    echo -e "${PURPLE}[Langkah ${CURRENT_STEP}/${TOTAL_STEPS}] Menginstal Desktop XFCE4...${NC}"
    echo ""
    
    install_pkg "xfce4" "Lingkungan Desktop XFCE4"
    install_pkg "xfce4-terminal" "Terminal XFCE4"
    install_pkg "thunar" "Pengelola Berkas Thunar"
    install_pkg "mousepad" "Penyunting Teks Mousepad"
}

# ============== LANGKAH 5: INSTAL DRIVER GPU ==============
step_gpu() {
    update_progress
    echo -e "${PURPLE}[Langkah ${CURRENT_STEP}/${TOTAL_STEPS}] Menginstal Akselerasi GPU (Turnip/Zink)...${NC}"
    echo ""
    
    install_pkg "mesa-zink" "Mesa Zink (OpenGL lewat Vulkan)"
    
    if [ "$GPU_DRIVER" == "freedreno" ]; then
        install_pkg "mesa-vulkan-icd-freedreno" "Driver GPU Turnip Adreno"
    else
        install_pkg "mesa-vulkan-icd-swrast" "Renderer Vulkan Perangkat Lunak"
    fi
    
    install_pkg "vulkan-loader-android" "Pemuat Vulkan"
    
    echo -e "  ${GREEN}✓${NC} Akselerasi GPU dikonfigurasi!"
}

# ============== LANGKAH 6: INSTAL AUDIO ==============
step_audio() {
    update_progress
    echo -e "${PURPLE}[Langkah ${CURRENT_STEP}/${TOTAL_STEPS}] Menginstal Dukungan Audio...${NC}"
    echo ""
    
    install_pkg "pulseaudio" "Server Suara PulseAudio"
}

# ============== LANGKAH 7: INSTAL APLIKASI UTAMA ==============
step_apps() {
    update_progress
    echo -e "${PURPLE}[Langkah ${CURRENT_STEP}/${TOTAL_STEPS}] Menginstal Aplikasi (Firefox & VS Code)...${NC}"
    echo ""
    
    install_pkg "firefox" "Peramban Firefox"
    install_pkg "code-oss" "Penyunting VS Code"
    install_pkg "git" "Kontrol Versi Git"
    install_pkg "wget" "Pengunduh Wget"
    install_pkg "curl" "cURL"
}

# ============== LANGKAH 8: KONFIGURASI PELUNCUR ==============
step_launchers() {
    update_progress
    echo -e "${PURPLE}[Langkah ${CURRENT_STEP}/${TOTAL_STEPS}] Membuat Skrip Peluncur...${NC}"
    echo ""
    
    mkdir -p ~/.config
    cat > ~/.config/tubuntu-gpu.sh << 'GPUEOF'
# TUbuntu - Konfigurasi Akselerasi GPU
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy
GPUEOF
    echo -e "  ${GREEN}✓${NC} Konfigurasi GPU dibuat"
    
    if ! grep -q "tubuntu-gpu.sh" ~/.bashrc 2>/dev/null; then
        echo 'source ~/.config/tubuntu-gpu.sh 2>/dev/null' >> ~/.bashrc
    fi
    
    # Skrip Mulai Desktop
    cat > ~/start-tubuntu.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "🚀 Memulai Desktop TUbuntu..."
echo ""
source ~/.config/tubuntu-gpu.sh 2>/dev/null
echo "🔄 Membersihkan sesi lama..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null

unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
echo "🔊 Memulai server audio..."
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1

echo "📺 Memulai server tampilan X11..."
termux-x11 :0 -ac &
sleep 3
export DISPLAY=:0

echo "🖥️ Meluncurkan Desktop XFCE4..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📱 Buka aplikasi Termux-X11 untuk melihat desktop!"
echo "  🔊 Audio diaktifkan!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
exec startxfce4
LAUNCHEREOF
    chmod +x ~/start-tubuntu.sh
    echo -e "  ${GREEN}✓${NC} Skrip ~/start-tubuntu.sh dibuat"

    # Skrip Berhenti Desktop
    cat > ~/stop-tubuntu.sh << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "Menghentikan TUbuntu..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null
echo "Desktop dihentikan."
STOPEOF
    chmod +x ~/stop-tubuntu.sh
    echo -e "  ${GREEN}✓${NC} Skrip ~/stop-tubuntu.sh dibuat"
}

# ============== LANGKAH 9: JALUR PERINTAH TUBUNTU ==============
step_tubuntu_cli() {
    update_progress
    echo -e "${PURPLE}[Langkah ${CURRENT_STEP}/${TOTAL_STEPS}] Membuat Perintah Utama 'tubuntu'...${NC}"
    echo ""
    
    cat > ~/tubuntu << 'TUBUNTUEOF'
#!/data/data/com.termux/files/usr/bin/bash

show_banner() {
    clear
    echo -e "\033[0;36m"
    cat << 'BANNER'
████████╗██╗   ██╗██████╗ ██╗   ██╗███╗   ██╗████████╗██╗   ██╗
╚══██╔══╝██║   ██║██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██║   ██║
   ██║   ██║   ██║██████╔╝██║   ██║██╔██╗ ██║   ██║   ██║   ██║
   ██║   ██║   ██║██╔══██╗██║   ██║██║╚██╗██║   ██║   ██║   ██║
   ██║   ╚██████╔╝██████╔╝╚██████╔╝██║ ╚████║   ██║   ╚██████╔╝
   ╚═╝    ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝    ╚═════╝ 
BANNER
    echo -e "\033[0m"
    echo -e "\033[1;37m       📱 TUbuntu (Termux Ubuntu) by LP Tech\033[0m"
    echo ""
}

case "$1" in
    start)
        bash ~/start-tubuntu.sh
        ;;
    stop)
        bash ~/stop-tubuntu.sh
        ;;
    menu|*)
        while true; do
            show_banner
            echo -e "\033[1;33m─────────────────────────────────────────────\033[0m"
            echo -e "  \033[1;37mPilih Opsi TUbuntu:\033[0m"
            echo -e "  \033[0;36m1)\033[0m \033[1;32mstart\033[0m  - Jalankan Desktop Linux"
            echo -e "  \033[0;36m2)\033[0m \033[1;31mstop\033[0m   - Hentikan Desktop Linux"
            echo -e "  \033[0;36m3)\033[0m \033[1;37muninstall\033[0m - Hapus Instalasi TUbuntu"
            echo -e "  \033[0;36m0)\033[0m \033[1;37mkeluar\033[0m - Keluar dari Menu"
            echo -e "\033[1;33m─────────────────────────────────────────────\033[0m"
            echo ""
            read -p "  Masukkan pilihan [0-3]: " choice
            
            case $choice in
                1|start)
                    bash ~/start-tubuntu.sh
                    break
                    ;;
                2|stop)
                    bash ~/stop-tubuntu.sh
                    read -p "Tekan Enter untuk melanjutkan..."
                    ;;
                3|uninstall)
                    if [ -f ~/Uninstall.sh ]; then
                        bash ~/Uninstall.sh
                    else
                        echo "Skrip Uninstall.sh tidak ditemukan!"
                    fi
                    break
                    ;;
                0|keluar)
                    exit 0
                    ;;
                *)
                    echo -e "\033[0;31m  Pilihan tidak valid!\033[0m"
                    sleep 1
                    ;;
            esac
        done
        ;;
esac
TUBUNTUEOF

    chmod +x ~/tubuntu
    ln -sf ~/tubuntu /data/data/com.termux/files/usr/bin/tubuntu
    echo -e "  ${GREEN}✓${NC} Perintah global 'tubuntu' berhasil dibuat"
}

# ============== LANGKAH 10: PINTASAN DESKTOP ==============
step_shortcuts() {
    update_progress
    echo -e "${PURPLE}[Langkah ${CURRENT_STEP}/${TOTAL_STEPS}] Membuat Pintasan Desktop...${NC}"
    echo ""
    
    mkdir -p ~/Desktop
    
    cat > ~/Desktop/Firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox
Comment=Peramban Web
Exec=firefox
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
EOF
    
    cat > ~/Desktop/VSCode.desktop << 'EOF'
[Desktop Entry]
Name=VS Code
Comment=Penyunting Kode
Exec=code-oss --no-sandbox
Icon=code-oss
Type=Application
Categories=Development;
EOF
    
    cat > ~/Desktop/Terminal.desktop << 'EOF'
[Desktop Entry]
Name=Terminal
Comment=Terminal XFCE
Exec=xfce4-terminal
Icon=utilities-terminal
Type=Application
Categories=System;TerminalEmulator;
EOF

    chmod +x ~/Desktop/*.desktop 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Pintasan desktop dibuat"
}

# ============== SELESAI ==============
show_completion() {
    echo ""
    echo -e "${GREEN}"
    cat << 'COMPLETE'
    
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║         ✅  INSTALASI TUbuntu BERHASIL!  ✅                   ║
    ║                                                               ║
    ║              🎉 100% - Semuanya Selesai! 🎉                   ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
    
COMPLETE
    echo -e "${NC}"
    echo -e "${WHITE}📱 Lingkungan TUbuntu by LP Tech sudah siap!${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}🚀 CARA MENJALANKAN (Cukup ketik perintah singkat):${NC}"
    echo -e "   ${GREEN}tubuntu${NC}         (atau ${GREEN}tubuntu start${NC})"
    echo ""
    echo -e "${WHITE}🛑 CARA MENGHENTIKAN:${NC}"
    echo -e "   ${GREEN}tubuntu stop${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📦 APLIKASI TERPASANG:${NC}"
    echo -e "   • Firefox Browser & VS Code Editor"
    echo -e "   • XFCE4 Desktop + Akselerasi GPU (Turnip/Zink)"
    echo -e "   • Dukungan Suara (PulseAudio)"
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📺 YouTube: https://youtube.com/@LPTech${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}⚡ TIP: Buka aplikasi Termux-X11 terlebih dahulu, lalu jalankan 'tubuntu'${NC}"
    echo ""
}

# ============== FUNGSI UTAMA ==============
main() {
    show_banner
    
    echo -e "${WHITE}  Skrip ini akan menginstal desktop Linux lengkap dengan${NC}"
    echo -e "${WHITE}  Firefox, VS Code, dan akselerasi GPU di ponsel Android Anda.${NC}"
    echo ""
    echo -e "${GRAY}  Perkiraan waktu: 5-15 menit (tergantung kecepatan internet)${NC}"
    echo ""
    echo -e "${YELLOW}  Tekan Enter untuk memulai instalasi, atau Ctrl+C untuk membatalkan...${NC}"
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
    step_tubuntu_cli
    step_shortcuts
    
    show_completion
}

main

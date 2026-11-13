#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  tubuntu - Installer
#  Desktop XFCE4 di Termux, ditampilkan lewat VNC (AVNC)
#  Pembuat: LP Tech
#######################################################

REPO_RAW="https://raw.githubusercontent.com/lptech22/tubuntu/main"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

CURRENT_STEP=0

show_progress() {
    local total=$1
    local percent=$(( CURRENT_STEP * 100 / total ))
    local filled=$(( percent / 5 ))
    local empty=$(( 20 - filled ))
    local bar="" i
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    echo ""
    echo -e "${CYAN}  Progres: ${WHITE}${CURRENT_STEP}/${total}${NC} ${GREEN}${bar}${NC} ${WHITE}${percent}%${NC}"
    echo ""
}

spinner() {
    local pid=$1
    local msg=$2
    local spin='|/-\'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i + 1) % 4 ))
        printf "\r  ${YELLOW}⏳${NC} %s ${CYAN}%s${NC}  " "$msg" "${spin:$i:1}"
        sleep 0.1
    done
    wait "$pid"
    local code=$?
    if [ $code -eq 0 ]; then
        printf "\r  ${GREEN}✓${NC} %s                          \n" "$msg"
    else
        printf "\r  ${RED}✗${NC} %s ${RED}(gagal)${NC}                \n" "$msg"
    fi
    return $code
}

# run_pkg "label" paket1 paket2 ...
run_pkg() {
    local label=$1
    shift
    (yes | pkg install -y "$@" >/dev/null 2>&1) &
    spinner $! "$label"
}

# ============== LANGKAH 1: PERBARUI SISTEM ==============
step_update() {
    echo -e "${PURPLE}== Memperbarui sistem ==${NC}"
    (yes | pkg update -y >/dev/null 2>&1) &
    spinner $! "Memperbarui daftar paket..."
    (yes | pkg upgrade -y >/dev/null 2>&1) &
    spinner $! "Meningkatkan paket terpasang..."
}

# ============== LANGKAH 2: REPOSITORI ==============
step_repos() {
    echo -e "${PURPLE}== Menambahkan repositori ==${NC}"
    run_pkg "Repositori X11 (berisi TigerVNC)" x11-repo
    run_pkg "Repositori TUR (Firefox, VS Code)" tur-repo
    (yes | pkg update -y >/dev/null 2>&1) &
    spinner $! "Memperbarui daftar paket dari repositori baru..."
}

# ============== LANGKAH 3: SERVER VNC ==============
step_vnc() {
    echo -e "${PURPLE}== Menyiapkan server VNC ==${NC}"
    run_pkg "Server VNC (TigerVNC)" tigervnc

    mkdir -p ~/.vnc
    echo ""
    echo -e "  ${WHITE}Buat password untuk koneksi AVNC (minimal 6 karakter):${NC}"
    local pw1 pw2
    while true; do
        read -r -s -p "  Password: " pw1 < /dev/tty; echo ""
        read -r -s -p "  Ulangi password: " pw2 < /dev/tty; echo ""
        if [ "$pw1" = "$pw2" ] && [ ${#pw1} -ge 6 ]; then
            break
        fi
        echo -e "  ${RED}Password tidak cocok atau kurang dari 6 karakter, ulangi.${NC}"
    done
    printf '%s\n' "$pw1" | vncpasswd -f > ~/.vnc/passwd
    chmod 600 ~/.vnc/passwd
    echo -e "  ${GREEN}✓${NC} Password VNC disimpan"
}

# ============== LANGKAH 4: DESKTOP ==============
step_desktop() {
    echo -e "${PURPLE}== Menginstal desktop XFCE4 ==${NC}"
    run_pkg "Desktop XFCE4, terminal, Thunar, Mousepad" xfce4 xfce4-terminal thunar mousepad
}

# ============== LANGKAH 5: APLIKASI ==============
step_apps() {
    echo -e "${PURPLE}== Menginstal aplikasi ==${NC}"
    run_pkg "Firefox" firefox
    run_pkg "VS Code (code-oss)" code-oss
    run_pkg "git, wget, curl" git wget curl
}

# ============== LANGKAH 6: SKRIP START/STOP ==============
step_launchers() {
    echo -e "${PURPLE}== Membuat skrip start dan stop ==${NC}"

    cat > ~/.vnc/xstartup << 'XSTARTEOF'
#!/data/data/com.termux/files/usr/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
XSTARTEOF
    chmod +x ~/.vnc/xstartup
    echo -e "  ${GREEN}✓${NC} Konfigurasi sesi XFCE dibuat"

    cat > ~/start-tubuntu.sh << 'STARTEOF'
#!/data/data/com.termux/files/usr/bin/bash
vncserver -kill :1 >/dev/null 2>&1
vncserver :1 -localhost yes -geometry 1280x720 -depth 24
echo ""
echo "Desktop berjalan. Buka AVNC, sambungkan ke 127.0.0.1 port 5901."
STARTEOF
    chmod +x ~/start-tubuntu.sh
    echo -e "  ${GREEN}✓${NC} Skrip ~/start-tubuntu.sh dibuat"

    cat > ~/stop-tubuntu.sh << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
vncserver -kill :1 2>/dev/null
echo "Desktop dihentikan."
STOPEOF
    chmod +x ~/stop-tubuntu.sh
    echo -e "  ${GREEN}✓${NC} Skrip ~/stop-tubuntu.sh dibuat"
}

# ============== LANGKAH 7: PERINTAH tubuntu ==============
step_cli() {
    echo -e "${PURPLE}== Membuat perintah tubuntu ==${NC}"

    cat > ~/tubuntu << 'CLIEOF'
#!/data/data/com.termux/files/usr/bin/bash
case "$1" in
    start)     bash ~/start-tubuntu.sh ;;
    stop)      bash ~/stop-tubuntu.sh ;;
    uninstall) bash ~/uninstall.sh ;;
    *)
        echo "Pemakaian:"
        echo "  tubuntu start      jalankan desktop"
        echo "  tubuntu stop       hentikan desktop"
        echo "  tubuntu uninstall  hapus tubuntu"
        ;;
esac
CLIEOF
    chmod +x ~/tubuntu
    ln -sf ~/tubuntu "$PREFIX/bin/tubuntu"
    echo -e "  ${GREEN}✓${NC} Perintah 'tubuntu' siap"

    (curl -sL "$REPO_RAW/uninstall.sh" -o ~/uninstall.sh) &
    spinner $! "Mengunduh uninstaller..."
}

# ============== LANGKAH 8: PINTASAN ==============
step_shortcuts() {
    echo -e "${PURPLE}== Membuat pintasan ==${NC}"
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

    chmod +x ~/Desktop/*.desktop
    echo -e "  ${GREEN}✓${NC} Pintasan dibuat"
}

show_completion() {
    echo ""
    echo -e "${GREEN}✅ Instalasi tubuntu selesai!${NC}"
    echo ""
    echo -e "${WHITE}Cara pakai:${NC}"
    echo -e "  1. Ketik ${GREEN}tubuntu start${NC}"
    echo -e "  2. Buka AVNC, tambah koneksi ke ${GREEN}127.0.0.1${NC} port ${GREEN}5901${NC}"
    echo -e "  3. Masukkan password VNC yang tadi dibuat"
    echo ""
    echo -e "${GRAY}Hentikan dengan: tubuntu stop${NC}"
    echo ""
}

# ============== UTAMA ==============
main() {
    clear
    echo -e "${CYAN}📱 tubuntu - Desktop Linux di Android tanpa root${NC}"
    echo ""
    echo -e "${GRAY}Perkiraan waktu: 10-20 menit, tergantung internet.${NC}"
    echo -e "${YELLOW}Tekan Enter untuk mulai, Ctrl+C untuk batal...${NC}"
    read -r _ < /dev/tty

    local steps=(step_update step_repos step_vnc step_desktop step_apps step_launchers step_cli step_shortcuts)
    local total=${#steps[@]}
    local s
    for s in "${steps[@]}"; do
        CURRENT_STEP=$((CURRENT_STEP + 1))
        show_progress "$total"
        "$s"
    done

    show_completion
}

main

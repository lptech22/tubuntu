#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
# LP TECH - UBUNTU TERMUX AUTO v1.1
# XFCE Desktop for Termux + Termux:X11
# No Root Required
# ============================================================

set -o pipefail

VERSION="1.1"
PROJECT="LP Tech - ubuntu-termux-auto"
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
CONFIG_DIR="$HOME/.config/lp-tech"
BIN_DIR="$HOME/.local/bin"
LOG_FILE="$CONFIG_DIR/install.log"
MANIFEST="$CONFIG_DIR/installed-packages.txt"
BASHRC="$HOME/.bashrc"

mkdir -p "$CONFIG_DIR" "$BIN_DIR"
touch "$LOG_FILE" "$MANIFEST"

# ---------- COLORS ----------

RESET='\033[0m'
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'

# ---------- HELPERS ----------

log() {
    printf '[%s] %s\n' "$(date '+%F %T')" "$*" >> "$LOG_FILE"
}

info() {
    printf "${CYAN}[INFO]${RESET} %s\n' "$*"
    log "INFO: $*"
}

success() {
    printf "${GREEN}[ OK ]${RESET} %s\n" "$*"
    log "OK: $*"
}

warn() {
    printf "${YELLOW}[WARN]${RESET} %s\n" "$*"
    log "WARN: $*"
}

error() {
    printf "${RED}[ERROR]${RESET} %s\n" "$*"
    log "ERROR: $*"
}

pause() {
    printf '\nTekan Enter untuk melanjutkan...'
    read -r _
}

ask_yes_no() {
    local answer

    while true; do
        printf '%s [y/N]: ' "$1"
        read -r answer

        case "$answer" in
            y|Y|yes|YES|Yes) return 0 ;;
            n|N|no|NO|No|"") return 1 ;;
            *) printf 'Masukkan y atau n.\n' ;;
        esac
    done
}

banner() {
    clear 2>/dev/null || true

    printf "${CYAN}"
    cat <<'EOF'
 _      ____    _____          _
| |    |  _ \  |_   _|__   ___| |__
| |    | |_) |   | |/ _ \ / __| '_ \
| |___ |  __/    | | (_) | (__| | | |
|_____||_|       |_|\___/ \___|_| |_|

       LP TECH | VERSION 1.1
    TERMUX + XFCE + TERMUX:X11
EOF
    printf "${RESET}\n"
    printf '%s\n\n' 'Desktop installer for Android - no root required.'
}

# ---------- PACKAGE HELPERS ----------

package_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null |
        grep -q 'install ok installed'
}

install_package() {
    local package="$1"

    if package_installed "$package"; then
        success "$package sudah terpasang."
        return 0
    fi

    info "Memasang paket: $package"

    if pkg install -y "$package" >> "$LOG_FILE" 2>&1; then
        if ! grep -Fxq "$package" "$MANIFEST" 2>/dev/null; then
            printf '%s\n' "$package" >> "$MANIFEST"
        fi

        success "$package berhasil dipasang."
        return 0
    else
        warn "Paket $package gagal dipasang."
        warn "Periksa ketersediaan paket dan log instalasi."
        log "INSTALL FAILED: $package"
        return 1
    fi
}

# ---------- ENVIRONMENT CHECK ----------

check_environment() {
    if [ ! -x "$PREFIX/bin/pkg" ]; then
        error "Lingkungan Termux tidak terdeteksi."
        printf 'Jalankan skrip ini dari aplikasi Termux.\n'
        exit 1
    fi

    if [ "$(id -u)" -eq 0 ]; then
        warn "Skrip ini dirancang untuk lingkungan Termux tanpa root."
    fi

    if ! command -v dpkg-query >/dev/null 2>&1; then
        error "dpkg-query tidak tersedia."
        exit 1
    fi

    success "Lingkungan Termux terdeteksi."
}

# ---------- REPOSITORIES ----------

setup_repositories() {
    info "Memperbarui daftar paket..."

    if ! pkg update -y >> "$LOG_FILE" 2>&1; then
        warn "Pembaruan daftar paket gagal."
        warn "Periksa koneksi internet dan repositori Termux."
    fi

    if ! package_installed x11-repo; then
        if pkg install -y x11-repo >> "$LOG_FILE" 2>&1; then
            if ! grep -Fxq x11-repo "$MANIFEST" 2>/dev/null; then
                printf '%s\n' x11-repo >> "$MANIFEST"
            fi
            success "Repositori X11 siap."
        else
            error "Gagal memasang x11-repo."
            return 1
        fi
    else
        success "Repositori X11 sudah terpasang."
    fi

    if ! pkg update -y >> "$LOG_FILE" 2>&1; then
        warn "Pembaruan setelah menambahkan repositori gagal."
    fi

    return 0
}

# ---------- CORE INSTALLATION ----------

install_core() {
    local packages=(
        termux-x11-nightly
        xfce4
        xfce4-terminal
        thunar
        mousepad
        dbus
        pulseaudio
        procps
        coreutils
        findutils
        grep
        sed
    )

    local failed=0
    local total="${#packages[@]}"
    local current=0
    local package

    printf '\n=== INSTALASI DESKTOP XFCE ===\n\n'

    for package in "${packages[@]}"; do
        current=$((current + 1))

        printf '[%s/%s] %s\n' "$current" "$total" "$package"

        if ! install_package "$package"; then
            failed=1
        fi
    done

    if [ "$failed" -eq 0 ]; then
        success "Seluruh paket inti berhasil dipasang."
    else
        warn "Beberapa paket inti gagal dipasang."
        warn "Periksa log: $LOG_FILE"
    fi
}

# ---------- OPTIONAL APPLICATIONS ----------

offer_package() {
    local title="$1"
    local package="$2"
    local description="$3"

    printf '\n%s\n' "$title"
    printf '%s\n' "$description"

    if ask_yes_no "Pasang $title?"; then
        install_package "$package" || true
    else
        info "$title dilewati."
    fi
}

install_optional_apps() {
    printf '\n'
    printf '%s\n' '=== APLIKASI TAMBAHAN ==='
    printf '%s\n' 'Pilih y untuk memasang atau n untuk melewati.'

    offer_package "Git" "git" \
        "Pengelolaan repositori dan kode sumber."

    offer_package "Python" "python" \
        "Bahasa pemrograman Python."

    offer_package "Firefox" "firefox" \
        "Peramban web jika tersedia untuk repositori aktif."

    offer_package "Editor kode (Code OSS)" "code-oss" \
        "Paket ini mungkin tidak tersedia di semua repositori Termux."

    offer_package "VLC" "vlc" \
        "Pemutar media jika paket kompatibel tersedia."

    offer_package "Nmap" "nmap" \
        "Utilitas pemindaian jaringan untuk jaringan yang diizinkan."

    offer_package "DNS utilities" "dnsutils" \
        "Utilitas pemeriksaan DNS."

    offer_package "Whois" "whois" \
        "Pemeriksaan informasi registrasi domain."

    offer_package "Wget" "wget" \
        "Pengunduh berkas melalui jaringan."

    offer_package "Curl" "curl" \
        "Utilitas transfer data melalui jaringan."

    success "Pemilihan aplikasi tambahan selesai."
}

# ---------- DESKTOP SCRIPTS ----------

create_desktop_scripts() {
    mkdir -p "$BIN_DIR"

    cat > "$BIN_DIR/lp-start-xfce" <<'START_EOF'
#!/data/data/com.termux/files/usr/bin/bash

CONFIG_DIR="$HOME/.config/lp-tech"
mkdir -p "$CONFIG_DIR"

DISPLAY_NUMBER=":1"
X11_PID_FILE="$CONFIG_DIR/termux-x11.pid"
SESSION_PID_FILE="$CONFIG_DIR/xfce-session.pid"
LOG_FILE="$CONFIG_DIR/desktop.log"

if ! command -v termux-x11 >/dev/null 2>&1; then
    echo "termux-x11 belum terpasang."
    exit 1
fi

if ! command -v xfce4-session >/dev/null 2>&1; then
    echo "XFCE belum terpasang."
    exit 1
fi

if [ -f "$SESSION_PID_FILE" ]; then
    OLD_PID="$(cat "$SESSION_PID_FILE" 2>/dev/null)"

    if [[ "$OLD_PID" =~ ^[0-9]+$ ]] &&
        kill -0 "$OLD_PID" 2>/dev/null; then
        echo "Sesi XFCE mungkin sudah berjalan (PID $OLD_PID)."
        exit 0
    fi

    rm -f "$SESSION_PID_FILE"
fi

echo "Memulai Termux:X11..."

termux-x11 "$DISPLAY_NUMBER" >> "$LOG_FILE" 2>&1 &
X11_PID=$!
echo "$X11_PID" > "$X11_PID_FILE"

sleep 2

if ! kill -0 "$X11_PID" 2>/dev/null; then
    echo "Termux:X11 gagal berjalan. Periksa $LOG_FILE"
    rm -f "$X11_PID_FILE"
    exit 1
fi

echo "Memulai sesi XFCE..."

(
    export DISPLAY="$DISPLAY_NUMBER"
    export XDG_RUNTIME_DIR="${TMPDIR:-$PREFIX/tmp}"
    export PULSE_SERVER="127.0.0.1"

    if command -v pulseaudio >/dev/null 2>&1; then
        pulseaudio --start --exit-idle-time=-1 \
            >> "$LOG_FILE" 2>&1 || true
    fi

    if command -v dbus-launch >/dev/null 2>&1; then
        exec dbus-launch --exit-with-session xfce4-session
    else
        exec xfce4-session
    fi
) >> "$LOG_FILE" 2>&1 &

SESSION_PID=$!
echo "$SESSION_PID" > "$SESSION_PID_FILE"

sleep 2

if kill -0 "$SESSION_PID" 2>/dev/null; then
    echo "Permintaan mulai XFCE berhasil."
    echo "Buka aplikasi Android Termux:X11."
    echo "Display: $DISPLAY_NUMBER"
else
    echo "Sesi XFCE berhenti. Periksa $LOG_FILE"
    rm -f "$SESSION_PID_FILE"
    exit 1
fi
START_EOF

    cat > "$BIN_DIR/lp-stop-xfce" <<'STOP_EOF'
#!/data/data/com.termux/files/usr/bin/bash

CONFIG_DIR="$HOME/.config/lp-tech"
X11_PID_FILE="$CONFIG_DIR/termux-x11.pid"
SESSION_PID_FILE="$CONFIG_DIR/xfce-session.pid"

stop_recorded_pid() {
    local file="$1"
    local name="$2"
    local pid=""

    if [ ! -f "$file" ]; then
        echo "$name tidak memiliki PID tercatat."
        return
    fi

    pid="$(cat "$file" 2>/dev/null)"

    if [[ "$pid" =~ ^[0-9]+$ ]] &&
        kill -0 "$pid" 2>/dev/null; then
        echo "Mengirim sinyal berhenti ke $name (PID $pid)..."
        kill -TERM "$pid" 2>/dev/null || true
        sleep 1

        if kill -0 "$pid" 2>/dev/null; then
            echo "$name masih berjalan; tidak dipaksa berhenti."
        fi
    fi

    rm -f "$file"
}

stop_recorded_pid "$SESSION_PID_FILE" "Sesi XFCE"
stop_recorded_pid "$X11_PID_FILE" "Termux:X11"

echo "Permintaan berhenti selesai."
echo "Jika masih berjalan, tutup sesi melalui aplikasi Termux:X11."
STOP_EOF

    chmod 700 "$BIN_DIR/lp-start-xfce" "$BIN_DIR/lp-stop-xfce"

    success "Skrip mulai dan berhenti desktop dibuat."
}

# ---------- COMMAND MENU ----------

create_lp_command() {
    local lp_file="$PREFIX/bin/lp"

    if [ -e "$lp_file" ] &&
        ! grep -q 'LP_TECH_UBUNTU_TERMUX_AUTO' "$lp_file" 2>/dev/null; then
        warn "Perintah lp sudah digunakan oleh file lain."
        warn "File tersebut tidak akan ditimpa."
        return 0
    fi

    cat > "$lp_file" <<'LP_EOF'
#!/data/data/com.termux/files/usr/bin/bash
# LP_TECH_UBUNTU_TERMUX_AUTO

VERSION="1.1"
CONFIG_DIR="$HOME/.config/lp-tech"
BIN_DIR="$HOME/.local/bin"
LOG_FILE="$CONFIG_DIR/install.log"
MANIFEST="$CONFIG_DIR/installed-packages.txt"

mkdir -p "$CONFIG_DIR"
touch "$LOG_FILE" "$MANIFEST"

info() { printf '\033[0;36m[INFO]\033[0m %s\n' "$*"; }
ok() { printf '\033[0;32m[ OK ]\033[0m %s\n' "$*"; }
warn() { printf '\033[0;33m[WARN]\033[0m %s\n' "$*"; }

pause() {
    printf '\nTekan Enter untuk kembali...'
    read -r _
}

show_info() {
    echo
    echo "=== INFORMASI SISTEM ==="
    echo "Versi LP Tech : $VERSION"
    echo "Android       : $(getprop ro.build.version.release 2>/dev/null || echo tidak diketahui)"
    echo "Arsitektur    : $(dpkg --print-architecture 2>/dev/null || uname -m)"
    echo "Termux PREFIX : ${PREFIX:-tidak diketahui}"

    echo
    echo "Ruang penyimpanan:"
    df -h "$HOME" 2>/dev/null | tail -n 1

    echo
    echo "Paket inti:"

    for p in termux-x11-nightly xfce4 xfce4-terminal thunar mousepad dbus; do
        if dpkg-query -W -f='${Status}' "$p" 2>/dev/null |
            grep -q 'install ok installed'; then
            printf '  [OK] %s\n' "$p"
        else
            printf '  [--] %s belum terpasang\n' "$p"
        fi
    done
}

install_apps() {
    local package

    while true; do
        echo
        echo "=== INSTAL APLIKASI OPSIONAL ==="
        echo "[1] Git"
        echo "[2] Python"
        echo "[3] Firefox"
        echo "[4] Code OSS"
        echo "[5] VLC"
        echo "[6] Nmap"
        echo "[7] DNS utilities"
        echo "[8] Whois"
        echo "[9] Wget"
        echo "[10] Curl"
        echo "[0] Kembali"
        printf 'Pilih aplikasi: '
        read -r choice

        case "$choice" in
            1) package=git ;;
            2) package=python ;;
            3) package=firefox ;;
            4) package=code-oss ;;
            5) package=vlc ;;
            6) package=nmap ;;
            7) package=dnsutils ;;
            8) package=whois ;;
            9) package=wget ;;
            10) package=curl ;;
            0) return ;;
            *) warn "Pilihan tidak valid."; continue ;;
        esac

        printf 'Pasang %s? [y/N]: ' "$package"
        read -r answer

        case "$answer" in
            y|Y|yes|YES|Yes)
                if dpkg-query -W -f='${Status}' "$package" 2>/dev/null |
                    grep -q 'install ok installed'; then
                    ok "$package sudah terpasang."
                    continue
                fi

                if pkg install -y "$package" >> "$LOG_FILE" 2>&1; then
                    if ! grep -Fxq "$package" "$MANIFEST" 2>/dev/null; then
                        printf '%s\n' "$package" >> "$MANIFEST"
                    fi
                    ok "$package berhasil dipasang."
                else
                    warn "Gagal memasang $package. Periksa $LOG_FILE"
                fi
                ;;
            *)
                info "$package dilewati."
                ;;
        esac
    done
}

diagnostics() {
    echo
    echo "=== DIAGNOSTIK DASAR ==="

    for cmd in pkg termux-x11 xfce4-session dbus-launch; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "[OK] $cmd ditemukan"
        else
            echo "[--] $cmd tidak ditemukan"
        fi
    done

    echo
    echo "Log installer: $LOG_FILE"
    echo "Log desktop  : $CONFIG_DIR/desktop.log"
    echo
    echo "Pastikan aplikasi Android Termux:X11 terpasang."
}

backup_config() {
    local destination="$HOME/lp-tech-backup-$(date +%Y%m%d-%H%M%S).tar.gz"

    if tar -czf "$destination" \
        -C "$HOME" \
        .config/lp-tech \
        .local/bin/lp-start-xfce \
        .local/bin/lp-stop-xfce \
        2>> "$LOG_FILE"; then
        ok "Backup tersimpan:"
        echo "$destination"
    else
        warn "Backup gagal. Periksa log."
        rm -f "$destination"
    fi
}

restore_config() {
    local archive

    printf 'Path file backup .tar.gz: '
    read -r archive

    if [ ! -f "$archive" ]; then
        warn "File tidak ditemukan."
        return
    fi

    printf 'Pulihkan konfigurasi dari file ini? [y/N]: '
    read -r answer

    case "$answer" in
        y|Y|yes|YES|Yes)
            if tar -tzf "$archive" 2>/dev/null |
                grep -qE '(^/|(^|/)\.\.(/|$))'; then
                warn "Arsip berisi jalur tidak aman."
                return
            fi

            if tar -xzf "$archive" -C "$HOME" >> "$LOG_FILE" 2>&1; then
                ok "Pemulihan selesai."
            else
                warn "Pemulihan gagal. Periksa log."
            fi
            ;;
        *) info "Pemulihan dibatalkan." ;;
    esac
}

show_help() {
    cat <<'HELP_EOF'

LP Tech - ubuntu-termux-auto v1.1

1. Pastikan aplikasi Android Termux:X11 terpasang.
2. Jalankan lp.
3. Pilih Start XFCE Desktop.
4. Buka aplikasi Termux:X11.

Jika desktop gagal:
~/.config/lp-tech/install.log
~/.config/lp-tech/desktop.log

Proyek ini memasang XFCE langsung di Termux,
bukan Ubuntu melalui proot-distro.

HELP_EOF
}

while true; do
    clear 2>/dev/null || true

    printf '\033[0;36m'
    cat <<'BANNER_EOF'
 _      ____    _____          _
| |    |  _ \  |_   _|__   ___| |__
| |    | |_) |   | |/ _ \ / __| '_ \
| |___ |  __/    | | (_) | (__| | | |
|_____||_|       |_|\___/ \___|_| |_|

       LP TECH | VERSION 1.1
BANNER_EOF
    printf '\033[0m\n'

    echo "[1]  Start XFCE Desktop"
    echo "[2]  Stop XFCE Desktop"
    echo "[3]  Install Optional Apps"
    echo "[4]  Update Packages"
    echo "[5]  System Information"
    echo "[6]  Diagnose / Repair"
    echo "[7]  Backup Configuration"
    echo "[8]  Restore Configuration"
    echo "[9]  View Installation Log"
    echo "[10] Help & About"
    echo "[11] Uninstall LP Tech Components"
    echo "[0]  Exit"
    echo

    printf 'Pilih menu: '
    read -r choice

    case "$choice" in
        1)
            "$BIN_DIR/lp-start-xfce"
            pause
            ;;
        2)
            "$BIN_DIR/lp-stop-xfce"
            pause
            ;;
        3)
            install_apps
            ;;
        4)
            pkg update -y && pkg upgrade -y
            pause
            ;;
        5)
            show_info
            pause
            ;;
        6)
            diagnostics
            pause
            ;;
        7)
            backup_config
            pause
            ;;
        8)
            restore_config
            pause
            ;;
        9)
            if [ -f "$LOG_FILE" ]; then
                tail -n 80 "$LOG_FILE"
            else
                echo "Log belum tersedia."
            fi
            pause
            ;;
        10)
            show_help
            pause
            ;;
        11)
            if [ -x "$CONFIG_DIR/uninstall.sh" ]; then
                "$CONFIG_DIR/uninstall.sh"
            else
                echo "Uninstaller belum tersedia di konfigurasi LP Tech."
                echo "Jalankan bash uninstall.sh dari folder repositori."
            fi
            pause
            ;;
        0)
            exit 0
            ;;
        *)
            warn "Pilihan tidak valid."
            pause
            ;;
    esac
done
LP_EOF

    chmod 700 "$lp_file"
    success "Perintah lp berhasil dibuat."
}

# ---------- BASHRC PATH ----------

configure_path() {
    local marker="# LP_TECH_UBUNTU_TERMUX_AUTO_PATH"

    touch "$BASHRC"

    if ! grep -Fq "$marker" "$BASHRC"; then
        cat >> "$BASHRC" <<'PATH_EOF'

# LP_TECH_UBUNTU_TERMUX_AUTO_PATH
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
PATH_EOF
    fi

    success "PATH untuk skrip desktop dikonfigurasi."
}

# ---------- MAIN ----------

main() {
    banner
    check_environment

    printf '%s\n' \
        "Installer memasang XFCE langsung di Termux." \
        "Termux:X11 membutuhkan aplikasi Android pendamping." \
        "Instalasi membutuhkan koneksi internet dan ruang penyimpanan."

    if ! ask_yes_no "Lanjutkan instalasi LP Tech v$VERSION?"; then
        info "Instalasi dibatalkan."
        exit 0
    fi

    log "===== START INSTALL $VERSION ====="

    if setup_repositories; then
        install_core
    else
        error "Penyiapan repositori gagal."
        warn "Periksa koneksi dan repositori sebelum mencoba kembali."
    fi

    create_desktop_scripts
    configure_path
    create_lp_command

    # Simpan salinan uninstaller jika tersedia di repositori.
    if [ -f "$(dirname "$0")/uninstall.sh" ]; then
        cp "$(dirname "$0")/uninstall.sh" "$CONFIG_DIR/uninstall.sh"
        chmod 700 "$CONFIG_DIR/uninstall.sh"
    fi

    if ask_yes_no "Ingin memilih aplikasi tambahan sekarang?"; then
        install_optional_apps
    fi

    printf '\n'
    printf '%s\n' '=============================================='
    success "Proses installer selesai."
    printf '%s\n' '=============================================='
    printf 'Perintah menu : lp\n'
    printf 'Log installer : %s\n' "$LOG_FILE"
    printf 'Log desktop   : %s/desktop.log\n' "$CONFIG_DIR"
    printf '\n'
    printf '%s\n' \
        'Pastikan aplikasi Android Termux:X11 terpasang.' \
        'Jalankan: source ~/.bashrc' \
        'Kemudian: lp'

    log "===== END INSTALL $VERSION ====="
}

main "$@"

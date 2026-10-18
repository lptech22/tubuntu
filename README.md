# 🐧 Ubuntu XFCE Auto-Installer for Termux (No Root) - v1.1

Skrip otomatis untuk memasang **Ubuntu Desktop (XFCE)** di Android menggunakan Termux & Termux-X11 tanpa perlu akses Root. 

---

## ✨ Fitur Versi 1.1
- **One-Liner Command:** Instalasi serba otomatis cukup dengan 1 perintah.
- **Hardware Protection:** Pengecekan otomatis arsitektur CPU (ARM64) untuk mencegah kesalahan eksekusi binary.
- **Interactive App Wizard:** Pilih aplikasi desktop yang dibutuhkan secara interaktif (*Firefox, Code-OSS, LibreOffice, GIMP*).
- **Non-Interactive APT Guard:** Kebal terhadap *hang/freeze* saat proses instalasi paket Debian.
- **PulseAudio & Termux-X11 Integration:** Audio & Tampilan Desktop langsung aktif dan terhubung.
- **Shortcut Pintar:** Jalankan Linux kapan saja hanya dengan mengtik `startlinux`.

---

## 🚀 Cara Menggunakan

1. Buka aplikasi **Termux**.
2. Tempel dan jalankan satu baris perintah berikut:

```bash
bash <(curl -s [https://raw.githubusercontent.com/USERNAME-ANDA/ubuntu-termux-auto/main/install.sh](https://raw.githubusercontent.com/USERNAME-ANDA/ubuntu-termux-auto/main/install.sh))

# 🐧 Ubuntu XFCE Auto-Installer for Termux (No Root) - v1.2

Skrip otomatis pintar untuk memasang **Ubuntu Desktop (XFCE)** di Android menggunakan Termux & Termux-X11 tanpa perlu akses Root. 

---

## ✨ Fitur Versi 1.2
- **Smart Device Detection:** Otomatis mendeteksi arsitektur CPU, kapasitas RAM, dan sisa penyimpanan perangkat Anda sebelum instalasi dimulai.
- **One-Liner Command:** Instalasi serba otomatis cukup dengan 1 perintah.
- **Hardware Protection:** Validasi otomatis keamanan CPU (wajib ARM64/aarch64).
- **Interactive App Wizard:** Pilih aplikasi desktop tambahan sesuai kebutuhan (*Firefox, Code-OSS, LibreOffice, GIMP*).
- **Non-Interactive APT Guard:** Mencegah sistem *hang/freeze* saat menginstal paket Debian di latar belakang.
- **Shortcut Pintar:** Jalankan Linux kapan saja cukup dengan mengetik `startlinux`.

---

## 🚀 Cara Menggunakan

1. Buka aplikasi **Termux**.
2. Tempel dan jalankan satu baris perintah berikut:

```bash
bash <(curl -s [https://raw.githubusercontent.com/lptech22/ubuntu-termux-auto/main/install.sh](https://raw.githubusercontent.com/lptech22/ubuntu-termux-auto/main/install.sh))

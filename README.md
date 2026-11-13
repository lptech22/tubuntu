# tubuntu

Desktop Linux (XFCE4) di Android tanpa root, ditampilkan lewat AVNC.

## Instalasi

Buka Termux, lalu jalankan:

```bash
curl -sL https://raw.githubusercontent.com/lptech22/tubuntu/main/install.sh | bash
```

Di tengah instalasi, Anda akan diminta membuat password VNC.

## Pemakaian

1. Ketik `tubuntu start`.
2. Buka AVNC, tambahkan koneksi baru dengan alamat `127.0.0.1` dan port `5901`, lalu masukkan password VNC.
3. Hentikan dengan `tubuntu stop`.

## Aplikasi

XFCE4, Thunar, Mousepad, Firefox, VS Code (code-oss), git, wget, dan curl.

## Hapus

```bash
tubuntu uninstall
```

## Catatan

- Termux: pasang dari F-Droid atau GitHub, bukan Play Store.
- AVNC: bisa dari Play Store atau F-Droid.
- Resolusi desktop default 1280x720.

**LP Tech** · [GitHub lptech22](https://github.com/lptech22)

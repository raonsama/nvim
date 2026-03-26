# 🏛️ Artefak v0.1
Konfigurasi Neovim minimalis dan stabil untuk Termux/Android.

---

## ⌨️ Daftar Seluruh Keymaps (Complete Table)

| Shortcut | Mode | Fungsi | Deskripsi |
| :--- | :--- | :--- | :--- |
| `Ctrl + S` | N, I | **Smart Save** | Simpan file (Prompt nama jika buffer baru). |
| `Ctrl + W` | N | **Smart Close** | Tutup buffer dengan konfirmasi save & proteksi exit. |
| `Ctrl + N` | N | **New File** | Membuka buffer kosong baru. |
| `Ctrl + B` | N | **Explorer** | Buka/Tutup NvimTree (Sidebar File). |
| `Ctrl + P` | N | **Finder** | Cari file di seluruh proyek (Telescope). |
| `Ctrl + A` | N | **Select All** | Memilih seluruh teks dalam buffer. |
| `Ctrl + D` | N | **Duplicate** | Duplikasi baris aktif ke bawah. |
| `Alt + ↑` | N | **Move Up** | Geser baris aktif ke atas. |
| `Alt + ↓` | N | **Move Down** | Geser baris aktif ke bawah. |
| `Ctrl + /` | N, V | **Comment** | Toggle komentar pada baris atau blok teks. |
| `Ctrl + T` | N, T | **Terminal** | Buka/Tutup terminal bawah (Persistent). |
| `\ + n` | N | **Quiet Mode** | Toggle notifikasi sistem (On/Off). |
| `\ + h` | N | **Replace** | Buka Spectre untuk Search & Replace massal. |
| `Esc` | T | **Normal Mode** | Keluar dari mode Insert di Terminal. |
| `gd` | N | **Definition** | Lompat ke asal definisi fungsi/variabel (LSP). |
| `K` | N | **Hover** | Tampilkan dokumentasi fungsi di bawah kursor (LSP). |

*Keterangan Mode: N (Normal), I (Insert), V (Visual), T (Terminal)*

---

## 🛠️ Instalasi & Maintenance

### Requirements
- **Neovim 0.11+**
- **Nerd Font** (Wajib agar ikon statusline & git muncul).
- **Ripgrep** (`pkg install ripgrep`) untuk fitur pencarian teks.

### Instalasi
```bash
# required
mv ~/.config/nvim{,.bak}

# opsional
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}

git clone https://github.com/raonsama/nvim ~/.config/nvim
```

### Troubleshooting
Jika terjadi error saat membuka folder (`nvim .`), bersihkan session data dengan perintah:
```bash
rm -rf ~/.local/state/nvim/shada/*

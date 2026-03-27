# 🏛️ Artefak — Neovim Config
> Konfigurasi Neovim minimalis, cepat, dan stabil untuk **Termux / Android**.  
> Dioptimalkan khusus untuk perangkat ARM (Huawei MatePad, tablet Android, dll).

---

## ✨ Filosofi

- **Tidak ada yang jalan kalau tidak perlu** — semua plugin lazy-loaded
- **ARM-first** — setiap keputusan mempertimbangkan keterbatasan CPU ARM
- **Familiar** — shortcut bergaya Sublime Text agar tidak perlu belajar ulang
- **Stabil** — tidak ada dependensi eksperimental atau plugin yang sering breaking

---

## 📋 Daftar Keymaps

### File & Buffer
| Shortcut | Mode | Fungsi |
| :--- | :---: | :--- |
| `Ctrl + S` | N, I | **Smart Save** — simpan file, prompt nama jika buffer baru |
| `Ctrl + Q` | N | **Smart Close** — tutup buffer dengan konfirmasi jika belum disimpan |
| `Ctrl + N` | N | **New File** — buka buffer kosong baru |
| `Alt + Q` | N | **Quit All** — tutup semua buffer dan keluar Neovim |
| `Alt + [` | N | **Prev Buffer** — pindah ke buffer sebelumnya |
| `Alt + ]` | N | **Next Buffer** — pindah ke buffer berikutnya |

### Navigasi & Pencarian
| Shortcut | Mode | Fungsi |
| :--- | :---: | :--- |
| `Ctrl + B` | N | **Explorer** — buka/tutup NvimTree (sidebar file) |
| `Ctrl + P` | N | **Finder** — cari file di seluruh project (Telescope) |
| `Ctrl + F` | N | **Search** — cari teks di seluruh project (live grep) |

### Editing
| Shortcut | Mode | Fungsi |
| :--- | :---: | :--- |
| `Ctrl + A` | N | **Select All** — pilih seluruh teks dalam buffer |
| `Ctrl + D` | N, V | **Duplicate** — duplikasi baris atau blok seleksi |
| `Alt + ↑` | N, V | **Move Up** — geser baris/seleksi ke atas |
| `Alt + ↓` | N, V | **Move Down** — geser baris/seleksi ke bawah |
| `Ctrl + /` | N, V | **Comment** — toggle komentar baris atau blok |

### LSP & Tools
| Shortcut | Mode | Fungsi |
| :--- | :---: | :--- |
| `gd` | N | **Definition** — lompat ke definisi fungsi/variabel |
| `K` | N | **Hover** — tampilkan dokumentasi di bawah kursor |
| `Space + f` | N | **Format** — format file aktif (Prettier / Pint) |
| `Space + h` | N | **Replace** — buka Spectre untuk find & replace massal |
| `Space + gg` | N | **LazyGit** — buka UI git lengkap |

### Terminal
| Shortcut | Mode | Fungsi |
| :--- | :---: | :--- |
| `Alt + T` | N | **Toggle Terminal** — buka/fokus/tutup terminal bawah |
| `Alt + T` | T | **Toggle Terminal** — tutup terminal, kembali ke editor |
| `Esc` | T | **Normal Mode** — keluar dari insert mode di terminal |

### System
| Shortcut | Mode | Fungsi |
| :--- | :---: | :--- |
| `Space + n` | N | **Quiet Mode** — toggle semua notifikasi (on/off) |
| `Space + l` | N | **Lazy** — buka plugin manager (update/install plugin) |
| `Space + m` | N | **Mason** — buka installer LSP/linter/formatter |

*Mode: N = Normal, I = Insert, V = Visual, T = Terminal*

---

## 🔌 Plugin

| Plugin | Fungsi | Load |
| :--- | :--- | :---: |
| `tokyonight.nvim` | Colorscheme | Startup |
| `nvim-treesitter` | Syntax highlight & indent | BufRead |
| `nvim-lspconfig` | Language Server Protocol | BufRead |
| `mason.nvim` | Installer LSP/formatter | BufRead |
| `nvim-cmp` | Autocomplete | BufRead |
| `LuaSnip` | Snippet engine | BufRead |
| `gitsigns.nvim` | Git status di sign column | BufRead |
| `nvim-tree.lua` | File explorer | Keymap |
| `telescope.nvim` | Fuzzy finder | Keymap |
| `conform.nvim` | Formatter (Prettier, Pint) | Keymap |
| `nvim-spectre` | Find & replace massal | Keymap |
| `Comment.nvim` | Toggle komentar | BufRead |
| `nvim-autopairs` | Auto-tutup bracket/quote | InsertEnter |
| `lazygit.nvim` | UI git | Keymap |

---

## 🛠️ Instalasi

### Requirements

```bash
# Wajib
pkg install neovim git ripgrep fd

# Untuk formatter
npm install -g prettier                        # Prettier (JS/TS/CSS/HTML)
composer global require laravel/pint           # Laravel Pint (PHP)
```

> **Nerd Font** wajib dipasang di Termux agar ikon statusline dan git muncul dengan benar.  
> Download di [nerdfonts.com](https://www.nerdfonts.com) lalu taruh di `~/.termux/font.ttf`.

### Clone & Setup

```bash
# Backup config lama (opsional tapi disarankan)
mv ~/.config/nvim{,.bak}
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}

# Clone repo ini
git clone https://github.com/raonsama/nvim ~/.config/nvim

# Buka Neovim — plugin akan auto-install saat pertama kali
nvim
```

### Setup LSP & Formatter

Setelah Neovim terbuka, install language server via Mason:

```
:Mason
```

Cari dan install:
- `intelephense` — PHP
- `ts_ls` — TypeScript/JavaScript  
- `tailwindcss` — Tailwind CSS

---

## ⚡ Optimasi ARM

Beberapa keputusan teknis yang sengaja dibuat untuk performa di ARM:

| Keputusan | Alasan |
| :--- | :--- |
| Provider Python/Ruby/Perl dimatikan | Setiap provider = +40-80ms startup |
| `synmaxcol = 200` | Cegah freeze saat buka file minified |
| LSP dimatikan untuk file > 500KB | File vendor/minified tidak perlu analisis |
| `relativenumber` off saat insert mode | Recalculate nomor baris setiap ketikan = lag |
| `cursorline` off saat insert mode | Redraw highlight setiap ketikan = lag |
| Clipboard tidak auto-sync | `unnamedplus` di Termux = proses eksternal per yank |
| Gitsigns debounce 300ms | Default 100ms terlalu agresif di ARM |
| Telescope pakai `fd` bukan `find` | `fd` jauh lebih cepat di filesystem Android |
| Treesitter indent pakai cache | Tidak cek ulang parser/query setiap buka file |
| Format on save dimatikan | Prettier/Pint bisa lag beberapa detik di ARM |

---

## 🗂️ Struktur File

```
~/.config/nvim/
├── init.lua                  # Entry point — provider, lazy, autocmd direktori
└── lua/
    ├── core/
    │   ├── options.lua       # Semua vim.opt + autocmd dasar
    │   └── keymaps.lua       # Semua keymap global
    └── plugins/
        └── init.lua          # Daftar & konfigurasi semua plugin
```

---

## 🩺 Troubleshooting

**Error saat buka folder (`nvim .`)**
```bash
rm -rf ~/.local/state/nvim/shada/*
```

**Font size menyebabkan gap di bawah layar**  
Gap terjadi karena sisa piksel layar tidak habis dibagi tinggi karakter.  
Gunakan font size yang habis membagi tinggi layar kamu.  
Untuk MatePad 12X (1840px tinggi), ukuran bersih: **16px, 20px, 23px, 40px**.

Edit di `~/.termux/termux.properties`:
```properties
default-fontsize=20
```
Lalu jalankan `termux-reload-settings`.

**Indent tidak bekerja di suatu filetype**  
Berarti treesitter belum punya `indents` query untuk bahasa tersebut.  
Otomatis fallback ke `smartindent` bawaan Neovim.

**Formatter tidak bekerja**  
Pastikan formatter sudah terinstall dan bisa diakses dari Termux:
```bash
prettier --version
pint --version
```

---

## 📝 Lisensi

MIT — bebas dipakai, dimodifikasi, dan didistribusikan.

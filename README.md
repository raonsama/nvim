# 🏛️ Artefak — Neovim Config
> Konfigurasi Neovim minimalis, cepat, dan stabil untuk **Termux / Android**.  
> Dioptimalkan khusus untuk perangkat ARM (Huawei MatePad 12X 2026, tablet Android, dll).  
> Config ini dibuat menggunakan **[Claude AI](https://claude.ai/)** dengan **[Sublime Text](https://www.sublimetext.com/)** sebagai model dasar shortcut.

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

### AI (CodeCompanion + MCPHub)
| Shortcut | Mode | Fungsi |
| :--- | :---: | :--- |
| `Space + aa` | N, V | **Actions** — buka menu aksi AI (explain, refactor, test, dll) |
| `Space + ai` | N, V | **Chat** — buka/tutup jendela AI chat |
| `Space + al` | N | **Laravel Chat** — buka chat Laravel + auto accept semua aksi AI |
| `Space + am` | N | **Model** — pilih model AI yang digunakan |
| `Space + ah` | N | **MCPHub** — buka UI manajemen MCP server |
| `Space + at` | N | **Auto Mode** — toggle auto accept (on/off) tanpa perlu confirm |
| `ga` | V | **Add** — tambahkan seleksi ke chat yang sedang terbuka |

*Ketik `cc` di command line sebagai alias `CodeCompanion`.*

> **Catatan Auto Mode (`Space + at`):**  
> Saat ON → AI langsung jalankan semua perintah (buat file, edit, run artisan) tanpa tanya.  
> Saat OFF → setiap aksi AI akan meminta konfirmasi user terlebih dahulu.

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
| `render-markdown.nvim` | Render markdown cantik di buffer | FileType |
| `mcphub.nvim` | MCP client — manajemen MCP server | Startup |
| `codecompanion.nvim` | AI chat & inline assist (OpenRouter) | Keymap |

---

## 🛠️ Instalasi

### Requirements

```bash
# Wajib
pkg install neovim git ripgrep fd nodejs

# Untuk formatter
npm install -g prettier                        # Prettier (JS/TS/CSS/HTML)
composer global require laravel/pint           # Laravel Pint (PHP)

# Untuk AI (MCPHub binary — auto-install saat plugin pertama dibuka)
npm install -g mcp-hub@latest

# Untuk AI (CodeCompanion via OpenRouter)
export OPENROUTER_API_KEY="sk-or-..."         # Tambahkan ke ~/.bashrc atau ~/.zshrc

# Untuk Laravel Boost (opsional, per project)
composer require laravel/boost --dev
php artisan boost:install
```

> **Nerd Font** wajib dipasang di Termux agar ikon plugin muncul dengan benar.  
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

### Setup Laravel Boost (per project)

Untuk mengintegrasikan Laravel Boost dengan MCPHub di project Laravel:

```bash
# 1. Install Laravel Boost di project
composer require laravel/boost --dev
php artisan boost:install

# 2. Buat file MCP config di root project
mkdir -p .mcphub
```

Buat `.mcphub/servers.json`:
```json
{
  "mcpServers": {
    "laravel-boost": {
      "command": "php",
      "args": ["artisan", "boost:mcp"],
      "autoStart": true
    }
  }
}
```

Buka project di Neovim → tekan `Space + al` → AI siap dengan konteks Laravel penuh.

### Setup LSP & Formatter

**PHP LSP (phpantom_lsp)** — install manual via Cargo karena belum tersedia di Mason:

```bash
# Pastikan Rust sudah terinstall
pkg install rust

# Clone & build
git clone https://github.com/AJenbo/phpantom_lsp
cd phpantom_lsp
cargo build --release
cp target/release/phpantom_lsp $PREFIX/bin/

# Jalankan composer di root project PHP agar resolusi class bekerja
composer dump-autoload -o
```

**LSP lainnya** — install via Mason setelah Neovim terbuka:

```
:Mason
```

Cari dan install:
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
| render-markdown sign dimatikan | Hemat kolom sign, mengurangi redraw |

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
        ├── init.lua          # Plugin utama (LSP, UI, treesitter, git, dll)
        ├── ai.lua            # MCPHub + CodeCompanion (AI chat & agent)
        └── markdown.lua      # render-markdown.nvim (render markdown global)
```

---

## 🩺 Troubleshooting

**MCPHub error: `mcp-hub: Executable not found`**
```bash
npm install -g mcp-hub@latest
# Pastikan npm bin ada di PATH:
export PATH="$PATH:$(npm bin -g)"
```

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

**Laravel Boost tidak bisa start (`Parse error: Invalid JSON`)**  
Pastikan tidak ada output PHP warnings/Xdebug ke stdout:
```bash
# Cek di root project Laravel
php artisan mcp:start laravel-boost 2>error.log
cat error.log  # jika ada isi, berarti ada warning yang mengotori JSON stream
```

---

## 📝 Lisensi

MIT — bebas dipakai, dimodifikasi, dan didistribusikan.

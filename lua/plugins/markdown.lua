-- ╔══════════════════════════════════════════════════════════╗
-- ║                   RENDER-MARKDOWN.NVIM                   ║
-- ║  Render markdown secara visual langsung di buffer Neovim ║
-- ║  (heading bergaris, code block berwarna, list pakai ikon)║
-- ║  Aktif global untuk semua filetype yang didaftarkan.     ║
-- ╚══════════════════════════════════════════════════════════╝
return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		-- Wajib: digunakan untuk parsing syntax markdown
		"nvim-treesitter/nvim-treesitter",
	},

	-- ft: daftar filetype yang mengaktifkan plugin ini secara otomatis.
	-- BUG FIX: "txt" bukan filetype valid Neovim, nama yang benar adalah "text".
	-- Filetype bisa dicek dengan :set ft? di buffer yang bersangkutan.
	ft = {
		"markdown",      -- file .md biasa
		"codecompanion", -- chat buffer AI (CodeCompanion)
		"gitcommit",     -- pesan commit git
		"text",          -- file .txt (BUG FIX: bukan "txt")
	},

	opts = {
		-- Render di semua mode: normal, insert, visual.
		-- Tanpa ini, render hanya aktif di normal mode.
		render_modes = true,

		-- ── Heading (# ## ###) ──────────────────────────────────────
		heading = {
			sign  = false, -- matikan ikon di sign column (hemat ruang)
			-- Ikon per level heading (H1 - H6)
			icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
		},

		-- ── Code block (``` ```) ────────────────────────────────────
		code = {
			sign      = false,   -- matikan ikon di sign column
			width     = "block", -- lebar block mengikuti konten, bukan full-width
			right_pad = 1,       -- padding kanan 1 kolom agar tidak terlalu rapat
		},

		-- ── Bullet list (- * +) ─────────────────────────────────────
		bullet = {
			-- Ikon per level indent list
			icons = { "●", "○", "◆", "◇" },
		},

		-- ── Checkbox (- [ ] - [x]) ───────────────────────────────────
		checkbox = {
			enabled  = true,
			unchecked = { icon = "󰄱 " }, -- belum selesai
			checked   = { icon = "󰱒 " }, -- sudah selesai
		},

		-- ── Sign column ──────────────────────────────────────────────
		-- Matikan global agar tidak memakan kolom di kiri buffer.
		sign = {
			enabled = false,
		},

		-- ── Blockquote (> teks) ──────────────────────────────────────
		quote = {
			-- Ulangi karakter quote di setiap baris wrap
			-- agar blockquote panjang tetap terlihat jelas.
			repeat_linebreak = true,
		},

		-- ── Link ([teks](url)) ───────────────────────────────────────
		-- BUG FIX: struktur `footnote = { superscript = true }` tidak valid
		-- di render-markdown.nvim. Dihapus dan diganti struktur yang benar.
		link = {
			enabled   = true,
			image     = "󰥶 ", -- ikon untuk ![image](url)
			email     = "󰀓 ", -- ikon untuk mailto:
			hyperlink = "󰌹 ", -- ikon untuk link biasa
			highlight = "RenderMarkdownLink",
		},
	},
}

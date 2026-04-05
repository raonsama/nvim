return {
	-- ╔══════════════════════════════════════════════════════════╗
	-- ║                        MCPHUB                            ║
	-- ║  MCP client untuk Neovim. Harus di-load SEBELUM         ║
	-- ║  CodeCompanion karena CodeCompanion bergantung padanya.  ║
	-- ║  `build` menjalankan perintah install binary mcp-hub     ║
	-- ║  secara otomatis via npm saat plugin pertama di-install. ║
	-- ╚══════════════════════════════════════════════════════════╝
	{
		"ravitemer/mcphub.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		build = "npm install -g mcp-hub@latest",
		config = function()
			require("mcphub").setup({
				-- auto_approve dipanggil setiap kali AI ingin menjalankan MCP tool.
				-- Return true  → langsung jalankan tanpa tanya user.
				-- Return false → tampilkan dialog konfirmasi ke user.
				auto_approve = function(params)
					-- Jika mode "auto tool" aktif (via <leader>at),
					-- semua tool disetujui otomatis tanpa interupsi.
					if vim.g.codecompanion_auto_tool_mode == true then
						return true
					end
					-- Jika tool sudah ditandai autoApprove di servers.json project,
					-- ikuti konfigurasi tersebut.
					if params.is_auto_approved_in_server then
						return true
					end
					-- Default: tampilkan konfirmasi.
					return false
				end,
			})
		end,
	},

	-- ╔══════════════════════════════════════════════════════════╗
	-- ║                     CODECOMPANION                        ║
	-- ║  Plugin AI utama. Menghubungkan Neovim ke LLM via        ║
	-- ║  OpenRouter (gateway untuk berbagai model gratis).       ║
	-- ╚══════════════════════════════════════════════════════════╝
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"ravitemer/mcphub.nvim",                    -- MCP client
			"MeanderingProgrammer/render-markdown.nvim", -- render markdown di chat
		},
		config = function()
			-- ─── Model Management ─────────────────────────────────────
			-- BUG FIX: default_model harus ada di dalam available_models
			-- agar bisa terlihat dan dipilih via <leader>am.
			local default_model = "qwen/qwen3-235b-a22b:free"
			local available_models = {
				"qwen/qwen3-235b-a22b:free",          -- default, cukup cerdas & gratis
				"qwen/qwen3.6-plus:free",
				"stepfun/step-3.5-flash:free",
				"nvidia/nemotron-3-nano-30b-a3b:free",
				"nvidia/nemotron-3-super-120b-a12b:free",
				"arcee-ai/trinity-large-preview:free",
			}
			local current_model = default_model

			-- Fungsi pemilih model via popup — dipanggil oleh keymap <leader>am
			local function select_model()
				vim.ui.select(available_models, {
					prompt = "Select Model:",
				}, function(choice)
					if choice then
						current_model = choice
						vim.notify("Selected model: " .. current_model)
					end
				end)
			end

			-- ─── Setup ────────────────────────────────────────────────
			require("codecompanion").setup({

				-- ── Strategies: adapter per mode interaksi ──────────────
				strategies = {
					chat = {
						adapter = "openrouter",

						-- FIX: tabel kosong ini mencegah error di mcphub
						-- (variables.lua:20 pairs() on nil) saat mcphub
						-- mencoba mendaftarkan MCP resources sebagai #variables.
						variables = {},

						-- ── Tools: konfigurasi agent tools ──────────────
						tools = {
							opts = {
								-- @agent = grup tool agentic (pengganti @full_stack_dev
								-- yang sudah di-rename sejak codecompanion v19+).
								-- Aktif otomatis saat chat dibuka tanpa perlu ketik @agent.
								default_tools = { "agent" },
							},

							-- Matikan approval prompt untuk semua built-in tool.
							-- Tanpa ini, setiap aksi AI (buat file, edit, run cmd)
							-- akan selalu menampilkan dialog konfirmasi.
							-- vim.g.codecompanion_auto_tool_mode = true saja tidak cukup,
							-- masing-masing tool punya flag require_approval_before sendiri.
							["run_command"]           = { opts = { require_approval_before = false } },
							["create_file"]           = { opts = { require_approval_before = false } },
							["delete_file"]           = { opts = { require_approval_before = false } },
							["insert_edit_into_file"] = { opts = { require_approval_before = false } },
							["read_file"]             = { opts = { require_approval_before = false } },
							["file_search"]           = { opts = { require_approval_before = false } },
							["grep_search"]           = { opts = { require_approval_before = false } },
							["get_changed_files"]     = { opts = { require_approval_before = false } },
							["get_diagnostics"]       = { opts = { require_approval_before = false } },
						},

						-- ── System prompt adaptif ────────────────────────
						opts = {
							system_prompt = function(ctx)
								-- Suffix wajib: cegah model menambah newline berlebih.
								-- Beberapa model gratis OpenRouter cenderung verbose.
								local suffix = "\nIMPORTANT: Keep responses concise. Avoid excessive blank lines in your responses."

								-- Deteksi otomatis apakah ini project Laravel
								-- dengan mengecek keberadaan file `artisan`.
								local is_laravel = vim.fn.filereadable(ctx.cwd .. "/artisan") == 1
								if is_laravel then
									return string.format([[
You are an expert Laravel developer working inside Neovim.
The current working directory is: %s

When working on this Laravel project you MUST:
- Use @laravel-boost tools to inspect schema, routes, docs, and run Tinker
- Use run_command tool to execute artisan commands (make:controller, migrate, etc.)
- Use insert_edit_into_file tool to write code directly into files
- NEVER just write code in the chat buffer — always execute and write to files directly
- Always follow Laravel conventions and best practices
]], ctx.cwd) .. suffix
								end

								-- Fallback: pakai system prompt default CodeCompanion
								return ctx.default_system_prompt .. suffix
							end,
						},
					},
					inline = { adapter = "openrouter" },
				},

				-- ── Display: konfigurasi tampilan chat buffer ────────────
				display = {
					chat = {
						-- PENTING: harus false saat pakai render-markdown.nvim.
						-- Jika true, codecompanion menggambar separator sendiri
						-- yang akan bentrok dengan render dari plugin markdown.
						show_header_separator = false,
						separator             = "─",
						show_token_count      = true,  -- tampilkan jumlah token di chat
						show_tools_processing = true,  -- tampilkan status saat tool berjalan
						window = {
							layout    = "vertical",
							width     = 0.45,          -- 45% lebar layar
							opts = {
								-- Penting untuk keterbacaan teks panjang di layar tablet
								breakindent = true,
								linebreak   = true,
								wrap        = true,
							},
						},
					},
				},

				-- ── Adapters: koneksi ke LLM ─────────────────────────────
				adapters = {
					http = {
						-- Adapter OpenRouter: gateway ke ratusan model AI.
						-- Model gratis tersedia tapi rate-limited.
						openrouter = function()
							return require("codecompanion.adapters").extend("openai_compatible", {
								env = {
									url      = "https://openrouter.ai/api",
									-- Baca API key dari environment variable $OPENROUTER_API_KEY.
									-- Set di ~/.bashrc atau ~/.zshrc:
									-- export OPENROUTER_API_KEY="sk-or-..."
									api_key  = "OPENROUTER_API_KEY",
									chat_url = "/v1/chat/completions",
								},
								headers = {
									-- Wajib oleh OpenRouter untuk identifikasi app.
									["HTTP-Referer"] = "https://github.com/raonsama/nvim",
									["X-Title"]      = "Artefak",
								},
								schema = {
									model = {
										-- Fungsi agar model bisa diganti runtime via <leader>am
										-- tanpa perlu restart Neovim.
										default = function() return current_model end,
									},
								},
							})
						end,
					},
				},

				-- ── Prompt Library: shortcut chat siap pakai ─────────────
				prompt_library = {
					["Laravel Dev"] = {
						strategy    = "chat",
						description = "Laravel development dengan tools lengkap",
						opts = {
							index       = 1,
							is_default  = true,
							-- alias menggantikan short_name (deprecated sejak v19+)
							alias       = "lv",
							auto_submit = false,
						},
						prompts = {
							{
								role    = "user",
								-- Pre-inject @agent dan @laravel-boost agar user
								-- tidak perlu mengetiknya manual setiap sesi.
								content = "@agent @laravel-boost\n",
								opts    = { auto_submit = false },
							},
						},
					},
				},

				-- ── Extensions: integrasi plugin eksternal ───────────────
				extensions = {
					mcphub = {
						callback = "mcphub.extensions.codecompanion",
						opts = {
							make_tools          = true,  -- @server dan @server__tool tersedia di chat
							make_vars           = true,  -- MCP resources jadi #{mcp:...} variables
							make_slash_commands = true,  -- MCP prompts jadi /slash commands
							show_result_in_chat = true,  -- hasil tool tampil langsung di chat buffer
						},
					},
				},
			})

			-- ╔══════════════════════════════════════════════════════════╗
			-- ║             TRIM NEWLINE BERLEBIH (Tool Output)          ║
			-- ║  Beberapa MCP tool atau model mengembalikan output       ║
			-- ║  dengan banyak baris kosong berurutan. Callback ini      ║
			-- ║  membersihkannya sebelum ditampilkan di chat buffer.     ║
			-- ║  Dampak performa: hampir nol (Lua string.gsub sangat     ║
			-- ║  cepat, dijalankan sekali per tool call, bukan streaming)║
			-- ╚══════════════════════════════════════════════════════════╝
			vim.api.nvim_create_autocmd("User", {
				pattern  = "CodeCompanionChatCreated",
				callback = function(args)
					local chat = require("codecompanion").buf_get_chat(args.data.bufnr)
					chat:add_callback("on_tool_output", function(_, data)
						-- for_user: teks yang tampil di chat buffer
						-- for_llm:  teks yang dikirim ke model sebagai konteks
						if data.for_user then
							data.for_user = data.for_user:gsub("\n\n\n+", "\n\n") -- 3+ newline → 2
							data.for_user = data.for_user:gsub("\n+$", "\n")      -- trailing newline
						end
						if data.for_llm then
							data.for_llm = data.for_llm:gsub("\n\n\n+", "\n\n")
							data.for_llm = data.for_llm:gsub("\n+$", "\n")
						end
					end)
				end,
			})

			-- ╔══════════════════════════════════════════════════════════╗
			-- ║                       KEYMAPS AI                         ║
			-- ╚══════════════════════════════════════════════════════════╝

			-- Chat & aksi umum
			vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>",
				{ noremap = true, silent = true, desc = "AI: Action Palette" })
			vim.keymap.set({ "n", "v" }, "<leader>ai", "<cmd>CodeCompanionChat Toggle<cr>",
				{ noremap = true, silent = true, desc = "AI: Toggle Chat" })
			vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>",
				{ noremap = true, silent = true, desc = "AI: Add Selection to Chat" })

			-- Model & MCPHub
			vim.keymap.set("n", "<leader>am", select_model,
				{ desc = "AI: Select Model" })
			vim.keymap.set("n", "<leader>ah", "<cmd>MCPHub<cr>",
				{ desc = "AI: Open MCPHub" })

			-- Toggle auto tool mode.
			-- Saat ON: semua MCP tool call dan file edit disetujui otomatis.
			-- Saat OFF: setiap aksi AI akan menampilkan konfirmasi ke user.
			vim.keymap.set("n", "<leader>at", function()
				vim.g.codecompanion_auto_tool_mode = not vim.g.codecompanion_auto_tool_mode
				vim.notify(
					"Auto tool mode: " .. (vim.g.codecompanion_auto_tool_mode and "ON ✓" or "OFF"),
					vim.log.levels.INFO
				)
			end, { desc = "AI: Toggle Auto Tool Mode" })

			-- Laravel chat: buka chat + aktifkan auto accept + inject tools.
			-- vim.g.codecompanion_auto_tool_mode = true sudah cukup untuk:
			--   1. mcphub auto approve semua MCP tool call
			--   2. codecompanion auto accept semua file edit/create
			-- vim.defer_fn(300ms) memberi waktu chat buffer siap
			-- sebelum feedkeys menyuntikkan teks tool.
			vim.keymap.set("n", "<leader>al", function()
				vim.g.codecompanion_auto_tool_mode = true
				vim.notify("Laravel AI Chat: Auto accept ON ✓", vim.log.levels.INFO)
				vim.cmd("CodeCompanionChat")
				vim.defer_fn(function()
					vim.api.nvim_feedkeys(
						vim.api.nvim_replace_termcodes("i@agent @laravel-boost ", true, false, true),
						"n", false
					)
				end, 300)
			end, { desc = "AI: Laravel Chat (auto accept)" })

			-- Alias command line: ketik `cc` → `CodeCompanion`
			vim.cmd([[cab cc CodeCompanion]])
		end,
	},
}

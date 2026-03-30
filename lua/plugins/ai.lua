return {
	"olimorris/codecompanion.nvim",
	config = function()
		local default_model = "stepfun/step-3.5-flash:free"
		local available_models = {
			"qwen/qwen3-coder:free",
			"stepfun/step-3.5-flash:free",
			"arcee-ai/trinity-large-preview:free",
			"openrouter/free",
		}
		local current_model = default_model

		local function select_model()
			vim.ui.select(available_models, {
				prompt = "Select  Model:",
			}, function(choice)
				if choice then
					current_model = choice
					vim.notify("Selected model: " .. current_model)
				end
			end)
		end

		require("codecompanion").setup({
			strategies = {
				chat = {
					adapter = "openrouter",
				},
				inline = {
					adapter = "openrouter",
				},
			},
			adapters = {
        http = {
		    	openrouter = function()
		    		return require("codecompanion.adapters").extend("openai_compatible", {
		    			env = {
		    				url = "https://openrouter.ai/api",
		    				api_key = "OPENROUTER_API_KEY",
		    				chat_url = "/v1/chat/completions",
		    			},
              headers = {
                ["HTTP-Referer"] = "https://github.com/raonsama/nvim", -- Ganti dengan URL bebas
                ["X-Title"] = "Artefak", -- Nama yang akan muncul di OpenRouter Dashboard
              },
		    			schema = {
		    				model = {
		    					default = current_model,
		    				},
		    			},
		    		})
		    	end,
        }
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
		vim.keymap.set(
			{ "n", "v" },
			"<leader>ai",
			"<cmd>CodeCompanionChat Toggle<cr>",
			{ noremap = true, silent = true }
		)
		vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

		vim.keymap.set("n", "<leader>am", select_model, { desc = "Select Gemini Model" })
		-- Expand 'cc' into 'CodeCompanion' in the command line
		vim.cmd([[cab cc CodeCompanion]])
	end,

	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
}


return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		"selene.toml",
		"selene.yml",
		".git",
	},
	-- settings = {
	-- 	Lua = {
	-- 		workspace = {
	-- 			checkThirdParty = false,
	-- 			library = {
	-- 				vim.env.VIMRUNTIME,
	-- 				"${3rd}/love2d/library",
	-- 				"${3rd}/luv/library",
	-- 			},
	-- 		},
	-- 		runtime = {
	-- 			version = "LuaJIT",
	-- 		},
	-- 		-- diagnostics = {
	-- 		-- 	globals = { "vim" },
	-- 		-- },
	-- 	},
	-- },
}

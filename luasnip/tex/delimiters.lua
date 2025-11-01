local helpers = require("helpers.luasnip_helpers")
local visual = helpers.visual

local tex = {}
tex.in_math = function()
	return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end
tex.in_text = function()
	return not tex.in_math()
end

return {
	-- Left/Right parantheses
	s(
		{ trig = "([^%a])lr(", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>\\left(<>\\right)", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, visual),
		})
	),
	-- Left/Right square brackets
	s(
		{ trig = "([^%a])lr[", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>\\left[<>\\right]", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, visual),
		})
	),
	-- Left/Right curly braces
	s(
		{ trig = "([^%a])lr{", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>\\left{<>\\right}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, visual),
		})
	),
}

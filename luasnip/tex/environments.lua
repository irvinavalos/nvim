local helpers = require("helpers.luasnip_helpers")
local visual = helpers.visual

local tex = {}
tex.in_math = function()
	return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end
tex.in_text = function()
	return not tex.in_math()
end

local line_begin = require("luasnip.extras.expand_conditions").line_begin

return {
	-- New environment
	s(
		{ trig = "/b", snippetType = "autosnippet" },
		fmta(
			[[
        \begin{<>}
            <>
        \end{<>}
      ]],
			{
				i(1),
				d(2, visual),
				rep(1),
			}
		),
		{ condition = line_begin }
	),
	-- Equation
	s(
		{ trig = "eqn", snippetType = "autosnippet" },
		fmta(
			[[
        \begin{equation*}
            <>
        \end{equation*}
      ]],
			{
				i(1),
			}
		),
		{ condition = line_begin }
	),
	-- Align
	s(
		{ trig = "ain", snippetType = "autosnippet" },
		fmta(
			[[
        \begin{align*}
            <>
        \end{align*}
      ]],
			{
				i(1),
			}
		),
		{ condition = line_begin }
	),
	-- Inline math
	s(
		{ trig = "([^%l])mk", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>$<>$", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, visual),
		})
	),
}

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
	-- Superscript
	s(
		{ trig = "([%w%)%]%}])'", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>^{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, visual),
		}),
		{ condition = tex.in_math }
	),
	-- Subscript
	s(
		{ trig = "([%w%)%]%}]);", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>_{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, visual),
		}),
		{ condition = tex.in_math }
	),
	-- SUM with lower limit
	s(
		{ trig = "([^%a])sm", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\sum_{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
		}),
		{ condition = tex.in_math }
	),
	-- SUM with upper and lower limit
	s(
		{ trig = "([^%a])sM", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\sum_{<>}^{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
			i(2),
		}),
		{ condition = tex.in_math }
	),
	-- INTEGRAL with upper and lower limit
	s(
		{ trig = "([^%a])intt", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\int_{<>}^{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			i(1),
			i(2),
		}),
		{ condition = tex.in_mathzone }
	),
	-- Fraction
	s(
		{ trig = "([^%a])ff", wordTrig = false, regTrig = true, snippetType = "autosnippet" },
		fmta("<>\\frac{<>}{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, visual),
			i(2),
		}),
		{ condition = tex.in_math }
	),
	-- Less than or equal to, i.e. \leq
	s({ trig = "<=", snippetType = "autosnippet" }, {
		t("\\leq "),
	}),
	-- Greater than or equal to, i.e. \geq
	s({ trig = ">=", snippetType = "autosnippet" }, {
		t("\\geq "),
	}),
	-- Infinity, i.e. \infty
	s({ trig = "ooo", snippetType = "autosnippet" }, {
		t("\\infty "),
	}),
}

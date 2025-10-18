local visual = function(_, parent)
	if #parent.snippet.env.LS_SELECT_RAW > 0 then
		return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
	else
		return sn(nil, i(1))
	end
end

local tex = {}

tex.in_math = function()
	return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

tex.in_text = function()
	return not tex.in_math()
end

return {
	s({ trig = "pp", snippetType = "autosnippet" }, fmta("\\P (<>)", { i(1) }), { condition = tex.in_math }),
	s(
		{ trig = "pg", snippetType = "autosnippet" },
		fmta("\\P (<> \\mid <> )", { i(1), i(2) }),
		{ condition = tex.in_math }
	),
	s({ trig = "p_", snippetType = "autosnippet" }, fmta("\\P_{<>} (<>)", { i(1), i(2) }), { condition = tex.in_math }),
	s({ trig = "ee", snippetType = "autosnippet" }, fmta("\\E [<>]", { i(1) }), { condition = tex.in_math }),
	s(
		{ trig = "eg", snippetType = "autosnippet" },
		fmta("\\E [<> \\mid <> ]", { i(1), i(2) }),
		{ condition = tex.in_math }
	),
	s({ trig = "e_", snippetType = "autosnippet" }, fmta("\\E_{<>} [<>]", { i(1), i(2) }), { condition = tex.in_math }),
	s({ trig = "var", snippetType = "autosnippet" }, fmta("\\Var (<>)", { i(1) }), { condition = tex.in_math }),
	s({ trig = "cov", snippetType = "autosnippet" }, fmta("\\Cov (<>)", { i(1) }), { condition = tex.in_math }),
	s({ trig = "ber", snippetType = "autosnippet" }, fmta("\\Bernoulli (<>)", { i(1) }), { condition = tex.in_math }),
	s({ trig = "bin", snippetType = "autosnippet" }, fmta("\\Binomial (<>)", { i(1) }), { condition = tex.in_math }),
	s({ trig = "pois", snippetType = "autosnippet" }, fmta("\\Poisson (<>)", { i(1) }), { condition = tex.in_math }),
	s({ trig = "nor", snippetType = "autosnippet" }, fmta("\\Normal (<>)", { i(1) }), { condition = tex.in_math }),
	s({ trig = "exx", snippetType = "autosnippet" }, fmta("\\Exponential (<>)", { i(1) }), { condition = tex.in_math }),
	s({ trig = "geom", snippetType = "autosnippet" }, fmta("\\Geometric (<>)", { i(1) }), { condition = tex.in_math }),
	s({ trig = "~", snippetType = "autosnippet" }, { t("\\sim") }),
	s({ trig = "iid", snippetType = "autosnippet" }, { t("\\iid") }),
}

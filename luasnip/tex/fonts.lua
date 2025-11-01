local helpers = require("helpers.luasnip_helpers")
local visual = helpers.visual

function New_line_or_non_letter(cursor_line, matched_trigger)
	local new_line = cursor_line:sub(1, -(#matched_trigger + 1)):match("^$s*$")
	local non_letter = cursor_line:sub(-(#matched_trigger + 1), -(#matched_trigger + 1)):match("[^%a]")
	return new_line or non_letter
end

local tex = {}
tex.in_math = function()
	return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end
tex.in_text = function()
	return not tex.in_math()
end

return {
	-- Italic
	s(
		{ trig = "([^$a])tii", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>\\textit{<>}", { f(function(_, snip)
			return snip.captures[1]
		end), d(1, visual) })
	),
	-- Bold
	s(
		{ trig = "tbb", snippetType = "autosnippet" },
		fmta("\\textbf{<>}", {
			d(1, visual),
		})
	),
	-- Math roman
	s(
		{ trig = "([^%a])mrm", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>\\mathrm{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, visual),
		})
	),
	-- Math caligraphy
	s(
		{ trig = "([^%a])mcl", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>\\mathcal{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, visual),
		})
	),
	-- Math bold
	s(
		{ trig = "([^%a])mbf", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>\\mathbf{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, visual),
		})
	),
	-- Math blackboard
	s(
		{ trig = "([^%a])mbb", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>\\mathbb{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, visual),
		})
	),
	-- Text in math mode
	s(
		{ trig = "([^%a])txt", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
		fmta("<>\\text{<>}", {
			f(function(_, snip)
				return snip.captures[1]
			end),
			d(1, visual),
		}),
		{ condition = tex.in_math }
	),
}

local visual = function(_, parent)
	if #parent.snippet.env.LS_SELECT_RAW > 0 then
		return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
	else
		return sn(nil, i(1))
	end
end

return {
	-- Paired parentheses
	s({ trig = "(", wordTrig = false, snippetType = "autosnippet" }, {
		t("("),
		d(1, visual),
		t(")"),
	}),
	-- Paired curly braces
	s({ trig = "{", wordTrig = false, snippetType = "autosnippet" }, {
		t("{"),
		d(1, visual),
		t("}"),
	}),
	-- Paired square brackets
	s({ trig = "[", wordTrig = false, snippetType = "autosnippet" }, {
		t("["),
		d(1, visual),
		t("]"),
	}),
}

-- Custom minimal status bar: filename  size | (a)dd (e)dit (r)ename

-- Remove all default elements (ids 1-6)
Status:children_remove(1, Status.LEFT)   -- mode
Status:children_remove(2, Status.LEFT)   -- size
Status:children_remove(3, Status.LEFT)   -- name
Status:children_remove(4, Status.RIGHT)  -- perm
Status:children_remove(5, Status.RIGHT)  -- percent
Status:children_remove(6, Status.RIGHT)  -- position

-- Left: filename + size
Status:children_add(function(self)
	local h = self._current.hovered
	if not h then return "" end

	local size = h and (h:size() or h.cha.len) or 0

	return ui.Line {
		ui.Span(" " .. tostring(h.name)):fg("white"),
		ui.Span("  " .. ya.readable_size(size)):fg("gray"),
	}
end, 1000, Status.LEFT)

-- Right: keybinding hints with nerd icons
Status:children_add(function()
	return ui.Line {
		ui.Span(" a"):fg("cyan"),
		ui.Span("  "):fg("gray"),
		ui.Span(" e"):fg("cyan"),
		ui.Span("  "):fg("gray"),
		ui.Span(" r"):fg("cyan"),
		ui.Span("  "):fg("gray"),
		ui.Span("  d"):fg("cyan"),
		ui.Span(" "):fg("gray"),
	}
end, 1000, Status.RIGHT)

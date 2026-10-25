local workspacerule = {}

local named_workspaces = { "󰖟 ", " ", "󰭹 ", "󰎇 ", " " }

function workspacerule.setup(primary_monitor)
	for i, workspace_name in ipairs(named_workspaces) do
		local rule = {
			workspace = tostring(i),
			persistent = true,
			default_name = workspace_name,
		}
		if primary_monitor then
			rule.monitor = primary_monitor
		end
		hl.workspace_rule(rule)
	end

	hl.workspace_rule({
		workspace = "name:tablet",
		monitor = "HEADLESS-1",
		default = true,
		default_name = "󰍹 ",
	})
end

return workspacerule

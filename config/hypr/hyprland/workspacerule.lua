local named_workspaces = { "󰖟 ", " ", "󰭹 ", "󰎇 ", " " }

for i, workspace_name in ipairs(named_workspaces) do
	hl.workspace_rule({
		workspace = tostring(i),
		persistent = true,
		default_name = workspace_name,
	})
end

local isOpen = false
local busyRepos = {}

local function trim(text)
	if not text then
		return ""
	end
	return (string.gsub(text, "^%s*(.-)%s*$", "%1"))
end

local function firstLine(text)
	local cleaned = trim(text)
	if cleaned == "" then
		return ""
	end
	return string.match(cleaned, "^([^\r\n]+)") or cleaned
end

local function triggerRefresh()
	local nonce = tonumber(noctalia.state.get("refresh_nonce")) or 0
	noctalia.state.set("refresh_nonce", nonce + 1)
end

local function renderPanel()
	if not isOpen then
		return
	end

	local outOfSync = noctalia.state.get("out_of_sync") or {}
	local checking = noctalia.state.get("checking") == true
	local updateCommands = noctalia.getConfig("update_commands") or {}
	local remote = noctalia.getConfig("remote") or "origin"
	local branch = noctalia.getConfig("branch") or "main"

	local children = {
		ui.row({ align = "center", justify = "space_between", gap = 8 }, {
			ui.label({
				text = "Out of Sync",
				fontSize = 15,
				fontWeight = "bold",
				color = "primary",
				flexGrow = 1,
			}),
			ui.button({
				glyph = "refresh",
				variant = "ghost",
				controlSize = "sm",
				enabled = not checking,
				tooltip = "Re-check all repositories",
				onClick = "onRefreshClicked",
			}),
		}),
		ui.separator({}),
	}

	if #outOfSync == 0 then
		table.insert(
			children,
			ui.label({
				text = checking and "Checking repositories..." or "All repositories are up to date.",
				fontSize = 13,
				color = "on_surface_variant",
			})
		)
	else
		for _, repo in ipairs(outOfSync) do
			local isBusy = busyRepos[repo.name] == true
			local customAction = type(updateCommands) == "table" and updateCommands[repo.name] or nil

			local function finishUpdate(result)
				busyRepos[repo.name] = nil
				if result.exitCode == 0 then
					noctalia.notify("Git Sync", "Updated " .. repo.name .. " (" .. repo.remoteHash .. ")")
				else
					local detail = firstLine(result.stderr)
					if detail == "" then
						detail = firstLine(result.stdout)
					end
					if detail ~= "" then
						noctalia.notify("Git Sync", "Failed to update " .. repo.name .. ": " .. detail)
					else
						noctalia.notify("Git Sync", "Failed to update " .. repo.name)
					end
				end
				triggerRefresh()
				renderPanel()
			end

			local function handleUpdate()
				if busyRepos[repo.name] then
					return
				end
				if customAction and customAction ~= "" then
					noctalia.runAsync(customAction)
					panel.close()
					return
				end

				busyRepos[repo.name] = true
				renderPanel()

				noctalia.runAsync({ "git", "-C", repo.path, "rev-parse", "--abbrev-ref", "HEAD" }, function(headResult)
					if headResult.exitCode ~= 0 then
						finishUpdate(headResult)
						return
					end

					local currentBranch = trim(headResult.stdout)
					local gitArgs
					if currentBranch == branch then
						gitArgs = {
							"git",
							"-C",
							repo.path,
							"-c",
							"core.hooksPath=/dev/null",
							"-c",
							"core.fsmonitor=false",
							"pull",
							"--ff-only",
							remote,
							branch,
						}
					else
						gitArgs = {
							"git",
							"-C",
							repo.path,
							"-c",
							"core.hooksPath=/dev/null",
							"-c",
							"core.fsmonitor=false",
							"fetch",
							remote,
							branch .. ":" .. branch,
						}
					end

					noctalia.runAsync(gitArgs, finishUpdate)
				end)
			end

			table.insert(
				children,
				ui.row({
					key = "repo-" .. repo.name,
					align = "center",
					justify = "space_between",
					gap = 8,
					paddingH = 8,
					paddingV = 6,
					radius = 8,
					fill = "surface_container_high",
				}, {
					ui.column({ gap = 2, flexGrow = 1 }, {
						ui.label({
							text = repo.name,
							fontSize = 13,
							fontWeight = "semibold",
						}),
						ui.label({
							text = repo.localHash .. " -> " .. repo.remoteHash,
							fontSize = 11,
							color = "on_surface_variant",
						}),
					}),
					ui.button({
						text = isBusy and "Updating..." or "Update",
						variant = "primary",
						controlSize = "sm",
						enabled = not isBusy,
						onClick = handleUpdate,
					}),
				})
			)
		end
	end

	panel.render(ui.column({ gap = 10, padding = 12 }, children))
end

noctalia.state.watch("out_of_sync", function()
	renderPanel()
end)

noctalia.state.watch("checking", function()
	renderPanel()
end)

function onOpen()
	isOpen = true
	renderPanel()
end

function onClose()
	isOpen = false
end

function onRefreshClicked()
	triggerRefresh()
end

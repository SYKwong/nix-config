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

local function statusText(repo)
	if not repo.outOfSync then
		return "Up to date"
	end
	if repo.behindCount == 1 then
		return "1 commit behind"
	end
	if repo.behindCount > 1 then
		return tostring(repo.behindCount) .. " commits behind"
	end
	return "Update available (" .. repo.remoteHash .. ")"
end

local renderPanel

local function runRepoUpdate(repo, updateCommands, remote, branch, closeOnCustom)
	if busyRepos[repo.name] then
		return
	end

	local customAction = type(updateCommands) == "table" and updateCommands[repo.name] or nil
	if customAction and customAction ~= "" then
		noctalia.runAsync(customAction)
		if closeOnCustom then
			panel.close()
		end
		return
	end

	busyRepos[repo.name] = true
	renderPanel()

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

renderPanel = function()
	if not isOpen then
		return
	end

	local allRepos = noctalia.state.get("repos") or {}
	local checking = noctalia.state.get("checking") == true
	local updateCommands = noctalia.getConfig("update_commands") or {}
	local remote = noctalia.getConfig("remote") or "origin"
	local branch = noctalia.getConfig("branch") or "main"

	local outOfSyncRepos = {}
	for _, repo in ipairs(allRepos) do
		if repo.outOfSync then
			table.insert(outOfSyncRepos, repo)
		end
	end

	local headerChildren = {
		ui.label({
			text = "Git Sync",
			fontSize = 16,
			fontWeight = "bold",
			color = "primary",
			textAlign = "start",
			flexGrow = 1,
		}),
	}

	if #outOfSyncRepos > 0 then
		table.insert(
			headerChildren,
			ui.button({
				text = "Update All",
				variant = "primary",
				controlSize = "sm",
				onClick = function()
					local launchedCustom = false
					for _, repo in ipairs(outOfSyncRepos) do
						local hasCustom = type(updateCommands) == "table"
							and updateCommands[repo.name] ~= nil
							and updateCommands[repo.name] ~= ""
						if hasCustom then
							launchedCustom = true
						end
						runRepoUpdate(repo, updateCommands, remote, branch, false)
					end
					if launchedCustom then
						panel.close()
					end
				end,
			})
		)
	end

	local children = {
		ui.row({ align = "center", justify = "space_between", gap = 12 }, headerChildren),
		ui.separator({}),
	}

	if #allRepos == 0 then
		table.insert(
			children,
			ui.label({
				text = checking and "Checking repositories..." or "No repositories configured.",
				fontSize = 14,
				color = "on_surface_variant",
				textAlign = "start",
			})
		)
	else
		local repoRows = {}
		for _, repo in ipairs(allRepos) do
			local isBusy = busyRepos[repo.name] == true
			local rightControl
			if repo.outOfSync then
				rightControl = ui.button({
					text = isBusy and "Updating..." or "Update",
					variant = "primary",
					controlSize = "sm",
					enabled = not isBusy,
					onClick = function()
						runRepoUpdate(repo, updateCommands, remote, branch, true)
					end,
				})
			else
				rightControl = ui.glyph({
					name = "check",
					size = 16,
					color = "primary",
				})
			end

			local cardChildren = {
				ui.row({ align = "center", justify = "space_between", gap = 12 }, {
					ui.column({ gap = 2, flexGrow = 1, align = "start" }, {
						ui.row({ align = "center", gap = 8 }, {
							ui.label({
								text = repo.name,
								fontSize = 14,
								fontWeight = "semibold",
								textAlign = "start",
							}),
							ui.label({
								text = statusText(repo),
								fontSize = 13,
								color = repo.outOfSync and "primary" or "on_surface_variant",
								textAlign = "start",
							}),
						}),
						ui.label({
							text = repo.displayPath .. " • " .. remote .. "/" .. branch,
							fontSize = 12,
							color = "on_surface_variant",
							textAlign = "start",
						}),
					}),
					rightControl,
				}),
			}

			if repo.outOfSync and type(repo.commits) == "table" and #repo.commits > 0 then
				local commitNodes = {}
				for _, subject in ipairs(repo.commits) do
					table.insert(
						commitNodes,
						ui.label({
							text = "• " .. subject,
							fontSize = 13,
							maxLines = 1,
							color = "on_surface_variant",
							textAlign = "start",
						})
					)
				end
				if repo.behindCount > #repo.commits then
					table.insert(
						commitNodes,
						ui.label({
							text = "+ " .. tostring(repo.behindCount - #repo.commits) .. " more",
							fontSize = 12,
							color = "on_surface_variant",
							textAlign = "start",
						})
					)
				end
				table.insert(cardChildren, ui.column({ gap = 2, align = "start" }, commitNodes))
			end

			table.insert(
				repoRows,
				ui.column({
					key = "repo-" .. repo.name,
					gap = 8,
					paddingH = 12,
					paddingV = 10,
					radius = 10,
					fill = "surface_container_high",
				}, cardChildren)
			)
		end

		table.insert(children, ui.scroll({ flexGrow = 1, gap = 10 }, repoRows))
	end

	panel.render(ui.column({ gap = 12, flexGrow = 1 }, children))
end

noctalia.state.watch("repos", function()
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

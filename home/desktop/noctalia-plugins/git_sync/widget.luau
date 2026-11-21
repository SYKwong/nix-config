local isChecking = false
local checkGeneration = 0

local function trim(text)
	if not text then
		return ""
	end
	return (string.gsub(text, "^%s*(.-)%s*$", "%1"))
end

local function readSettings()
	local rawRepos = noctalia.getConfig("repos")
	local repos = {}
	if type(rawRepos) == "table" then
		for name, rawPath in pairs(rawRepos) do
			if type(name) == "string" and type(rawPath) == "string" and rawPath ~= "" then
				table.insert(repos, {
					name = name,
					path = noctalia.expandPath(rawPath),
				})
			end
		end
	end
	table.sort(repos, function(a, b)
		return a.name < b.name
	end)

	local intervalSeconds = tonumber(noctalia.getConfig("interval_seconds")) or 3600
	return {
		repos = repos,
		remote = noctalia.getConfig("remote") or "origin",
		branch = noctalia.getConfig("branch") or "main",
		intervalMs = math.max(intervalSeconds, 60) * 1000,
	}
end

local function applyPollInterval()
	local settings = readSettings()
	noctalia.setUpdateInterval(settings.intervalMs)
end

local function applyResults(outOfSync)
	table.sort(outOfSync, function(a, b)
		return a.name < b.name
	end)

	noctalia.state.set("out_of_sync", outOfSync)
	noctalia.state.set("checking", false)

	if #outOfSync > 0 then
		local names = {}
		for _, repo in ipairs(outOfSync) do
			table.insert(names, repo.name)
		end
		barWidget.setText(tostring(#outOfSync))
		barWidget.setTooltip("Out of sync: " .. table.concat(names, ", "))
		barWidget.setVisible(true)
	else
		barWidget.setText("")
		barWidget.clearTooltip()
		barWidget.setVisible(false)
	end
end

local function checkAllRepos()
	if isChecking then
		return
	end

	local settings = readSettings()
	if #settings.repos == 0 then
		applyResults({})
		return
	end

	isChecking = true
	checkGeneration = checkGeneration + 1
	local currentGen = checkGeneration
	noctalia.state.set("checking", true)

	local remaining = #settings.repos
	local outOfSync = {}

	local function finishOne()
		if currentGen ~= checkGeneration then
			return
		end
		remaining = remaining - 1
		if remaining <= 0 then
			isChecking = false
			applyResults(outOfSync)
		end
	end

	for _, repo in ipairs(settings.repos) do
		noctalia.runAsync({ "git", "-C", repo.path, "rev-parse", settings.branch }, function(localResult)
			if currentGen ~= checkGeneration then
				return
			end
			if localResult.exitCode ~= 0 then
				finishOne()
				return
			end

			local localHash = trim(localResult.stdout)
			if localHash == "" then
				finishOne()
				return
			end

			noctalia.runAsync(
				{ "git", "-C", repo.path, "ls-remote", settings.remote, "-h", "refs/heads/" .. settings.branch },
				function(remoteResult)
					if currentGen ~= checkGeneration then
						return
					end
					if remoteResult.exitCode == 0 then
						local remoteHash = string.match(remoteResult.stdout or "", "^(%x+)")
						if remoteHash and remoteHash ~= "" and remoteHash ~= localHash then
							table.insert(outOfSync, {
								name = repo.name,
								path = repo.path,
								localHash = string.sub(localHash, 1, 7),
								remoteHash = string.sub(remoteHash, 1, 7),
							})
						end
					end
					finishOne()
				end
			)
		end)
	end
end

noctalia.state.watch("refresh_nonce", function()
	checkAllRepos()
end)

applyPollInterval()
barWidget.setGlyph("refresh")
barWidget.setText("")
barWidget.setVisible(false)
checkAllRepos()

function update()
	checkAllRepos()
end

function onConfigChanged()
	applyPollInterval()
	checkAllRepos()
end

function onClick()
	noctalia.togglePanel("local/git_sync:panel")
end

function onRightClick()
	checkAllRepos()
end

function onIpc(event)
	if event == "refresh" then
		checkAllRepos()
	end
end

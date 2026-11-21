local MAX_PREVIEW_COMMITS = 3

local isChecking = false
local checkGeneration = 0

local function trim(text)
	if not text then
		return ""
	end
	return (string.gsub(text, "^%s*(.-)%s*$", "%1"))
end

local function parseCommitSubjects(stdout)
	local subjects = {}
	for line in string.gmatch(stdout or "", "([^\r\n]+)") do
		local cleaned = trim(line)
		if cleaned ~= "" then
			table.insert(subjects, cleaned)
		end
	end
	return subjects
end

local function readSettings()
	local rawRepos = noctalia.getConfig("repos")
	local rawRemotes = noctalia.getConfig("remotes")
	local rawBranches = noctalia.getConfig("branches")
	local defaultRemote = noctalia.getConfig("remote") or "origin"
	local defaultBranch = noctalia.getConfig("branch") or "main"

	local repos = {}
	if type(rawRepos) == "table" then
		for name, rawPath in pairs(rawRepos) do
			if type(name) == "string" and type(rawPath) == "string" and rawPath ~= "" then
				local repoRemote = type(rawRemotes) == "table" and rawRemotes[name] or ""
				local repoBranch = type(rawBranches) == "table" and rawBranches[name] or ""
				table.insert(repos, {
					name = name,
					displayPath = rawPath,
					path = noctalia.expandPath(rawPath),
					remote = repoRemote ~= "" and repoRemote or defaultRemote,
					branch = repoBranch ~= "" and repoBranch or defaultBranch,
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
		intervalMs = math.max(intervalSeconds, 60) * 1000,
	}
end

local function applyPollInterval()
	local settings = readSettings()
	noctalia.setUpdateInterval(settings.intervalMs)
end

local function applyResults(allRepos)
	table.sort(allRepos, function(a, b)
		if a.outOfSync ~= b.outOfSync then
			return a.outOfSync
		end
		return a.name < b.name
	end)

	local outOfSyncNames = {}
	for _, repo in ipairs(allRepos) do
		if repo.outOfSync then
			table.insert(outOfSyncNames, repo.name)
		end
	end

	noctalia.state.set("repos", allRepos)
	noctalia.state.set("checking", false)

	if #outOfSyncNames > 0 then
		barWidget.setText(tostring(#outOfSyncNames))
		barWidget.setTooltip("Out of sync: " .. table.concat(outOfSyncNames, ", "))
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
	local results = {}

	local function finishRepo(entry)
		if currentGen ~= checkGeneration then
			return
		end
		table.insert(results, entry)
		remaining = remaining - 1
		if remaining <= 0 then
			isChecking = false
			applyResults(results)
		end
	end

	for _, repo in ipairs(settings.repos) do
		noctalia.runAsync({ "git", "-C", repo.path, "rev-parse", repo.branch }, function(localResult)
			if currentGen ~= checkGeneration then
				return
			end
			if localResult.exitCode ~= 0 then
				finishRepo({
					name = repo.name,
					displayPath = repo.displayPath,
					path = repo.path,
					remote = repo.remote,
					branch = repo.branch,
					outOfSync = false,
					behindCount = 0,
					commits = {},
					localHash = "",
					remoteHash = "",
				})
				return
			end

			local localHash = trim(localResult.stdout)
			if localHash == "" then
				finishRepo({
					name = repo.name,
					displayPath = repo.displayPath,
					path = repo.path,
					remote = repo.remote,
					branch = repo.branch,
					outOfSync = false,
					behindCount = 0,
					commits = {},
					localHash = "",
					remoteHash = "",
				})
				return
			end

			noctalia.runAsync(
				{ "git", "-C", repo.path, "ls-remote", repo.remote, "-h", "refs/heads/" .. repo.branch },
				function(remoteResult)
					if currentGen ~= checkGeneration then
						return
					end

					local remoteHash = remoteResult.exitCode == 0
							and string.match(remoteResult.stdout or "", "^(%x+)")
						or nil

					if not remoteHash or remoteHash == "" or remoteHash == localHash then
						finishRepo({
							name = repo.name,
							displayPath = repo.displayPath,
							path = repo.path,
							remote = repo.remote,
							branch = repo.branch,
							outOfSync = false,
							behindCount = 0,
							commits = {},
							localHash = string.sub(localHash, 1, 7),
							remoteHash = string.sub(remoteHash or localHash, 1, 7),
						})
						return
					end

					noctalia.runAsync({
						"git",
						"-C",
						repo.path,
						"-c",
						"core.hooksPath=/dev/null",
						"-c",
						"core.fsmonitor=false",
						"fetch",
						"--no-tags",
						repo.remote,
						repo.branch,
					}, function(fetchResult)
						if currentGen ~= checkGeneration then
							return
						end
						if fetchResult.exitCode ~= 0 then
							finishRepo({
								name = repo.name,
								displayPath = repo.displayPath,
								path = repo.path,
								remote = repo.remote,
								branch = repo.branch,
								outOfSync = true,
								behindCount = 0,
								commits = {},
								localHash = string.sub(localHash, 1, 7),
								remoteHash = string.sub(remoteHash, 1, 7),
							})
							return
						end

						noctalia.runAsync(
							{ "git", "-C", repo.path, "log", "--format=%s", repo.branch .. "..FETCH_HEAD" },
							function(logResult)
								if currentGen ~= checkGeneration then
									return
								end
								local allSubjects = logResult.exitCode == 0 and parseCommitSubjects(logResult.stdout)
									or {}
								local preview = {}
								for i = 1, math.min(#allSubjects, MAX_PREVIEW_COMMITS) do
									table.insert(preview, allSubjects[i])
								end

								finishRepo({
									name = repo.name,
									displayPath = repo.displayPath,
									path = repo.path,
									remote = repo.remote,
									branch = repo.branch,
									outOfSync = true,
									behindCount = #allSubjects,
									commits = preview,
									localHash = string.sub(localHash, 1, 7),
									remoteHash = string.sub(remoteHash, 1, 7),
								})
							end
						)
					end)
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

function onIpc(event)
	if event == "refresh" then
		checkAllRepos()
	end
end

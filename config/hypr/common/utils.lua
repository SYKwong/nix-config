local M = {}

M.get_hostname = function()
	local handle = io.popen("hostname -s")
	local host = handle and handle:read("*a"):gsub("%s+", "") or "fallback-host"
	if handle then
		handle:close()
	end
	return host
end

M.file_exists = function(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	else
		return false
	end
end

return M

local rootDirectory = "inv"

local function AddFile(file, dir)
	local prefix = string.lower(string.Left(file, 3))

	if (SERVER and prefix == "sv_") then
		include(dir .. file)
	elseif (prefix == "sh_") then
		if (SERVER) then
			AddCSLuaFile(dir .. file)
		end
		include(dir .. file)
	elseif (prefix == "cl_") then
		if (SERVER) then
			AddCSLuaFile(dir .. file)
		elseif (CLIENT) then
			include(dir .. file)
		end
	end
end

local function IncludeDir(dir)
	dir = dir .. "/"

	local files, dirs = file.Find(dir .. "*", "LUA")

	for _, v in ipairs(files) do
		if (string.EndsWith(v, ".lua")) then
			AddFile(v, dir)
		end
	end

	for _, v in ipairs(dirs) do
		IncludeDir(dir .. v)
	end
end

IncludeDir(rootDirectory)
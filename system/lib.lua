local _, NeP = ...

NeP.Library = {}

NeP.Globals.Library = NeP.Library

local libs = {}

function NeP.Library:Add(name, lib)
	if not libs[name] then
		libs[name] = lib
	end
end

function NeP.Library:Fetch(name)
	return libs[name]
end

function NeP.Library:Parse(Strg)
	if evaluation:sub(-1) == ')' then
		return loadstring('return NeP.library.libs.'..evaluation)()
	else
		local a, b = strsplit(".", evaluation, 2)
		return NeP.library.libs[a][b]()
	end
end
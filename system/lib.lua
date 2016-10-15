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

function NeP.Library:Parse(strg, args)
	args = NeP.Core:string_split(args, ',')
	local a, b = strsplit(".", strg, 2)
	if type(args) == 'table' then
		return libs[a][b](unpack(args))
	end
	return libs[a][b](args)
end
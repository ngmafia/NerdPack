local _, NeP = ...
local strsplit = strsplit
local unpack = unpack

NeP.Library = {}
NeP.Globals.Library = NeP.Library

local libs = {}

function NeP.Library.Add(_, name, lib)
	if not libs[name] then
		libs[name] = lib
	end
end

function NeP.Library.Fetch(_, name)
	return libs[name]
end

function NeP.Library.Parse(_, strg, args)
	if args then
		args = NeP.Core:string_split(args, ',')
	end
	local a, b = strsplit(".", strg, 2)
	if type(args) == 'table' then
		return libs[a] and libs[a][b](unpack(args))
	end
	return libs[a] and libs[a][b](args)
end

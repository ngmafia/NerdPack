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
	local a, b = strsplit(".", Strg, 2)
	if not libs[a] then return end
	local args = b:match('%((.+)%)')
	if args then 
		b = b:gsub('%((.+)%)', '')
	end
	return libs[a][b](args)
end
local _, NeP = ...

NeP.FakeUnits = {}
NeP.Globals.FakeUnits = NeP.FakeUnits
local Units = {}

local function _add(name, func)
	if not Units[name] then
		Units[name] = func
	end
end

function NeP.FakeUnits.Add(_, name, func)
	if type(name) == 'table' then
		for i=1, #name do
			_add(name[i], func)
		end
	elseif type(name) == 'string' then
		_add(name, func)
	else
		NeP.Core:Print("ERROR! tried to add an invalid fake unit")
	end
end

local function process(unit)
	-- Find and remove num and arg
	local arg = unit:match('%((.+)%)')
	local num = unit:match("%d+") or 1
	local funit = unit:gsub(arg or '', ''):gsub(num or '', '')
	return Units[funit] and Units[funit](tonumber(num), arg) or unit
end

local function not_in_tbl(unit, tbl)
	for i=1, #tbl do
		if tbl[i] == unit then return false end
	end
	return true
end

-- If the fake unit returns a table then we need
-- to merge it, EX: {tank, enemies}
-- tank is a single unit while enemie is a table
local function add_tbl(unit, tbl)
	local unit_type = type(unit)
	--table
	if unit_type =='table' then
		NeP.FakeUnits:Filter(unit, tbl)
	--function
	elseif unit_type == 'function' then
		NeP.FakeUnits:Filter(unit(), tbl)
	--add
	else
		unit = process(unit)
		if type(unit) ~= 'string' then
			NeP.FakeUnits.Filter(_,unit, tbl)
		elseif not_in_tbl(unit, tbl) then
			tbl[#tbl+1] = unit
		end
	end
end
 
function NeP.FakeUnits.Filter(_,unit, tbl)
	tbl = tbl or {}
	-- Table (recursive)
	if type(unit) == 'table' then
		for i=1, #unit do
			add_tbl(unit[i], tbl)
		end
	else
		add_tbl(unit, tbl)
	end
	return tbl
end

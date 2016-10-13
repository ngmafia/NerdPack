local _, NeP = ...

NeP.Queuer = {}
local Queue = {}

function NeP.Queuer:Add(_spell, _target)
	print(_spell)
	if not _spell then return end
	Queue[_spell] = {
		spell = _spell,
		nil,
		target = _target or 'target'
	}
end

function NeP.Queuer:Execute()
	for spell, table in pairs(Queue) do
		local r = NeP.Parser:Parse(Queue[spell])
		if r then return true end
	end
end

NeP.Globals.Queue = NeP.Queuer.Add
local _, NeP = ...

NeP.Compiler = {}

local spellTokens = {
	{'actions', '^%%'},
	{'lib', '^@'},
	{'item', '^#'}
}

-- Takes a string a produces a table in its place
function NeP.Compiler.Spell(eval, name)
	local ref = {
		spell = eval[1]
	}
	local skip = false
	if ref.spell:find('^!') then
		ref.interrupts = true
		ref.bypass = true
		ref.spell = ref.spell:sub(2)
	end
	if ref.spell:find('^&') then
		ref.bypass = true
		ref.spell = ref.spell:sub(2)
	end
	if ref.spell:find('^/') then
		ref.token = ref.spell:sub(1,1)
		skip = true
	end
	for i=1, #spellTokens do
		local _, patern = unpack(spellTokens[i])
		if ref.spell:find(patern) then
			ref.token = ref.spell:sub(1,1)
			ref.spell = ref.spell:sub(2)
			skip = true
		end
	end
	-- Some APIs only work after we'r in-game, so we delay.
	if not skip then
		NeP.Core:WhenInGame(function()
			ref.spell = NeP.Spells:Convert(ref.spell, name)
			ref.icon = select(3,GetSpellInfo(ref.spell))
		end)
	end
	local arg1, args = ref.spell:match('(.+)%((.+)%)')
	if args then ref.spell = arg1 end
	ref.args = args
	eval[1] = ref
end

local fake_unit = {
	target = 'fake',
	func = function()
		return UnitExists('target') and 'target' or 'player'
	end
}

function NeP.Compiler.Target(eval)
	local ref = {}
	if type(eval[3]) == 'string' then
		ref.target = eval[3]
	else
		ref = fake_unit
	end
	if ref.target:find('.ground') then
		ref.target = ref.target:sub(0,-8)
		ref.ground = true
	end
	eval[3] = ref
end

function NeP.Compiler.Compile(eval, name)
	local spell = eval[1]
	-- Take care of spell
	if type(spell) == 'table' then
		for k=1, #spell do
			NeP.Compiler.Compile(spell[k], name)
		end
	else
		if type(spell) == 'string' then
			NeP.Compiler.Spell(eval, name)
		elseif type(spell) == 'function' then
			local ref = {
				spell = 'fake',
				token = 'func'
			}
			eval.func = spell
			eval[1] = ref
		else
			NeP.Core:Print('Found a issue compiling:', name, 'Spell cant be a', type(spell))
		end
		NeP.Compiler.Target(eval)
	end
end

function NeP.Compiler:Iterate(eval, name)
	for i=1, #eval do
		NeP.Compiler.Compile(eval[i], name)
	end
end
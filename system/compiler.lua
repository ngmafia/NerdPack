local _, NeP = ...

NeP.Compiler = {}

local spellTokens = {
	{'actions', '^%%'},
	{'lib', '^@'},
	{'macro', '^/'}
}

-- Takes a string a produces a table in its place
function NeP.Compiler:Spell(eval)
	local ref = {
		spell = eval[1]
	}
	if ref.spell:find('^!') then
		ref.interrupts = true
		ref.bypass = true
		ref.spell = ref.spell:sub(2)
	end
	if ref.spell:find('^&') then
		ref.bypass = true
		ref.spell = ref.spell:sub(2)
	end
	for i=1, #spellTokens do
		local kind, patern = unpack(spellTokens[i])
		if ref.spell:find(patern) then
			ref.token = ref.spell:sub(1,1)
			ref.spell = ref.spell:sub(2)
		end
	end
	ref.spell = NeP.Spells:Convert(ref.spell)
	local arg1, args = ref.spell:match('(.+)%((.+)%)')
	if args then ref.spell = arg1 end
	ref.args = args
	eval[1] = ref
end

function NeP.Compiler:Target(eval)
	local ref = {
		target = eval[3]
	}
	if ref.target:find('.ground') then
		ref.target = ref.target:sub(0,-8)
		ref.ground = true
	end
	eval[3] = ref
end

function NeP.Compiler.Compile(eval)
	local spell, cond, target = eval[1], eval[2], eval[3]
	print(spell)
	-- Take care of target
	if type(target) == 'string' then
		NeP.Compiler:Target(eval)
	end
	-- Take care of spell
	if type(spell) == 'table' then
		for k=1, #spell do
			NeP.Compiler.Compile(spell[k])
		end
	elseif type(spell) == 'string' then
		NeP.Compiler:Spell(eval)
	elseif type(spell) == 'function' then
		spell = {
			spell = spell,
			token = 'func'
		}
	end
end

function NeP.Compiler:Iterate(eval)
	print('-------------------', #eval)
	for i=1, #eval do
		NeP.Compiler.Compile(eval[i])
	end
end
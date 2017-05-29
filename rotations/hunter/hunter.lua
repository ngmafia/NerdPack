local incombat = {
	{'Mend Pet', 'pet.health < 100'},
	{'Kill Command', 'target.petrange < 25'},
	{'Cobra Shot'}
}

local outcombat = {

}

NeP.CR:Add(3, {
  name = '[NeP] Hunter - Basic',
  ic = incombat,
  ooc = outcombat
})

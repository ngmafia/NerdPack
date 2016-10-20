### Unit Power:  
```
* UNIT.energy  
  > Returns: Number  
* UNIT.energydiff  
  > Returns: Number  
* UNIT.mana  
  > Returns: Number  
* UNIT.insanity  
  > Returns: Number   
* UNIT.focus  
  > Returns: Number  
* UNIT.runicpower  
  > Returns: Number  
* UNIT.runes  
  > Returns: Number  
* UNIT.maelstrom  
  > Returns: Number  
* UNIT.demonicfury  
  > Returns: Number  
* UNIT.embers  
  > Returns: Number  
* UNIT.soulshards  
  > Returns: Number  
* UNIT.chi  
  > Returns: Number  
* UNIT.chidiff  
  > Returns: Number  
* UNIT.combopoints  
  > Returns: Number  
* UNIT.holypower  
  > Returns: Number  
* UNIT.rage  
  > Returns: Number  
* UNIT.fury  
  > Returns: Number  
* UNIT.furydiff  
  > Returns: Number  
* UNIT.pain  
  > Returns: Number  
* UNIT.arcanecharges  
  > Returns: Number  
* UNIT.timetomax  
  > Returns: Number  
```

***
### Keybinds:  

Keybind(KEY)
```
  > KEYS:
shift
lshift
rshift
control
lcontrol
rcontrol
alt
lalt
ralt
```

***
### UNIT:  
```
* UNIT.petrange  
  > Returns: Number  
* UNIT.exists  
* IsNear(UNIT_ID, DISTANCE)  
```

***
### Spell: 
``` 
* spell(SPELL_NAME/ID).cooldown  
  > Returns: Number  
* spell(SPELL_NAME/ID).recharge  
  > Returns: Number  
* spell(SPELL_NAME/ID).recharge  
  > Returns: Number    
* spell(SPELL_NAME/ID).charges  
  > Returns: Number    
* spell(SPELL_NAME/ID).count  
  > Returns: Number    
* spell(SPELL_NAME/ID).usable  
* spell(SPELL_NAME/ID).exists  
* UNIT.spell(SPELL_NAME/ID).range 
``` 

***
### Casting:  
```
* UNIT.casting(SPELL_NAME/ID)  
* UNIT.casting(SPELL_NAME/ID).percent  
  > Returns: Number  
* UNIT.casting(SPELL_NAME/ID).delta  
  > Returns: Number  
* UNIT.channeling(SPELL_NAME/ID)  
* UNIT.interruptAt(%)  
```

***
### Random:
```
* toggle(TOGGLE_NAME)  
* totem(TOTEM_NAME)  
* totem(TOTEM_NAME).duration  
  > Returns: Number  
* form  
  > Returns: Number  
* stance  
  > Returns: Number  
* mushrooms  
  > Returns: Number  
* UNIT.combat.time  
  > Returns: Number  
* timeout(NAME, TIME)  
* waitfor(NAME, TIME)  
* lastcast(SPELL_NAME/ID) 
```
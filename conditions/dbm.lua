local _, NeP = ...
local DBM = DBM

if not DBM then return end

local C_Timer = C_Timer
local Timers = { ["Pull in"] = {timer = 999} }
local fake_timer = 999

C_Timer.NewTicker(0.1, function()
  for bar in pairs(DBM.Bars.bars) do
      local number = string.match(bar.id ,"%d+")
      Timers[bar.id] = Timers[bar.id] or {}
      Timers[bar.id].timer = bar.timer
      Timers[bar.id].spellid = number
  end
end)

NeP.DSL:Register('dbm', function(_, event)
  local T = Timers[event]
  if not T then return fake_timer end
  T.timer = (T.timer > 0) and T.timer or fake_timer
  return T.timer
end)

NeP.DSL:Register('pull_timer', function()
  local T = Timers["Pull in"]
  T.timer = (T.timer > 0) and T.timer or fake_timer
  return T.timer
end)

--Export to globals
NeP.Globals.DBM = NeP.DBM

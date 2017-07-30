if not DBM then return end
print("test")
local _, NeP = ...
local C_Timer = C_Timer
local DBM = DBM
local Timers = { ["Pull in"] = {timer = 999} }

C_Timer.NewTicker(0.1, function()
  for bar in pairs(DBM.Bars.bars) do
      local number = string.match(bar.id ,"%d+")
      Timers[bar.id] = Timers[bar.id] or {}
      Timers[bar.id].timer = bar.timer
      Timers[bar.id].spellid = number
  end
end)

--[[
RegisterAddonMessagePrefix('D4')
NeP.Listener:Add('DBM_LISTNER', 'CHAT_MSG_ADDON', function (prefix, arg)
  if prefix ~= 'D4' then return end
  local kind, seconds = strsplit('\t', arg or '')
  if kind == 'PT' then
    NeP.DBM.pullTimer = GetTime() + tonumber(seconds)
  end
end)]]

NeP.DSL:Register('pull_timer', function()
  local T = Timers["Pull in"]
  T.timer = (T.timer > 0) and T.timer or 999
  return T.timer
end)

--Export to globals
NeP.Globals.DBM = NeP.DBM

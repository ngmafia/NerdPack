local _, NeP = ...

local match = string.match
local tonumber = tonumber
local GetTime = GetTime
local RegisterAddonMessagePrefix = RegisterAddonMessagePrefix

RegisterAddonMessagePrefix('D4')

local pullTimer = nil

NeP.Listener:Add('PullTimer', 'CHAT_MSG_ADDON', function (prefix, arg)
	if prefix ~= 'D4' then
		return
 	end

	local _, seconds = match(arg or '', '^PT\t(%d+)')
	if seconds then
		pullTimer = GetTime() + tonumber(seconds)
	end
end)

NeP.DSL:Register('pull_timer', function ()
	if not pullTimer then
		return 0
	end

	local seconds = pullTimer - GetTime()
	if seconds < 0 then
		pullTimer = nil
		return 0
	end

	return seconds
end)

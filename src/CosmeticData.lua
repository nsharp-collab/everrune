--[[
	This module is a placeholder for the actual China API that Roblox will ship later on in the year.
	Please use it like so to check whether you need to adjust your content:
	
		local ChinaPolicyService = require(path.to.module)
		
		if ChinaPolicyService:IsActive() then
			-- this server/client runs in China and should be made compliant
		else
			-- this server/client does not run in China and does not need to be made compliant
		end
		
	Later on, when the actual API is released, we will give you an updated version of this module
	that uses the actual engine API. This way, you don't need to change anything except updating
	this module to make your game work.
	
	You should also have been provided with a ChinaPolicyPlugin script that you can use to easily change
	the settings of this module.
--]]

local TESTER_GROUPID = 5018342 -- The group of testers Roblox will use to test China Initiative games

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local active -- policy value
local ready = false -- whether policy value is final
local changed = Instance.new("BindableEvent") -- for firing changes on `active`
local readySignal = Instance.new("BindableEvent") -- for firing when the final policy value is set

local isForced = false -- whether policy is forced
local doGroupCheck = true -- whether policy is determined by group membership to tester group

-- Find setting values:
for _, child in pairs(script:GetChildren()) do
	if child:IsA("BoolValue") then
		if child.Name == "Forced" then
			isForced = child.Value
		elseif child.Name == "DisableGroupCheck" then
			doGroupCheck = not child.Value
		end
	end
end

-- Only do group check in VIP servers or Studio:
if not RunService:IsStudio() and game.PrivateServerOwnerId == 0 then
	doGroupCheck = false
end

-- Whether policy is active:
local function getPolicyActive(player)
	if isForced then
		-- always on when forced
		return true
	end
	
	if doGroupCheck and player.UserId > 0 then
		-- if group check active, then base it off of that
		return player:IsInGroup(TESTER_GROUPID)
	end

	-- group check disabled, not forced, so not active
	return false
end

if RunService:IsServer() then

	-- On the server, assume default until a player joins:
	active = isForced
	
	if not active and doGroupCheck then
		-- Listen for first player added:
		local connection
		connection = Players.PlayerAdded:Connect(
			function(player)
				if not connection then
					-- Safeguard in case multiple players join in exact same frame
					return
				end
				
				-- Stop listening for new players
				connection:Disconnect()
				connection = nil
				
				-- Set policy based on player:
				active = getPolicyActive(player)
				ready = true
				if active then
					changed:Fire(active)
				end
				
				-- Inform WaitForReady yielders:
				readySignal:Fire(active)
			end
		)
	else
		ready = true
	end

else

	-- On the client, just check if the local player is in the tester group:
	active = getPolicyActive(Players.LocalPlayer)
	ready = true
	
end

-- Whether the policy is currently active:
function ChinaPolicyService:IsActive()
	return active
end

-- Whether this is the final value:
function ChinaPolicyService:IsReady()
	return ready
end

-- Wait for the final value: (when first player is joined)
function ChinaPolicyService:WaitForReady()
	if ready then
		-- already final
		return active
	end
	-- wait for final active value
	return readySignal.Event:Wait()
end

-- For listening to policy changes (only does something on the server):
ChinaPolicyService.Changed = changed.Event

return ChinaPolicyService
]]></ProtectedString>
					<string name="ScriptGuid">{94FCB13E-F66A-4104-ADC3-9E42A84088EF}
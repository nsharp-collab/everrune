local Run = game:GetService("RunService")
local DS = game:GetService("DataStoreService")
local MS = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")
local Physics = game:GetService("PhysicsService")
local CS = game:GetService("CollectionService")
local HTTP = game:GetService("HttpService")
local SS = game:GetService("ServerStorage")
local SSS = game:GetService("ServerScriptService")

-- modules
local ItemData = require(Rep.Modules.ItemData)
local ColorData = require(Rep .Modules.ColorData)
local DataRepair1 = require(Rep.Modules.DataRepair1)

-- the module
local GU = {}

-- LIGHTING AND TIME, DAY / NIGHT FUNCTIONS

GU.GetDayPhase = function(specificMinutes)
	local dayPhases = ColorData["dayPhases"]
	local minutes = specificMinutes or Rep.Constants.MinutesAfterMidnight.Value
	
	for dayPhase,phaseData in next,dayPhases do
		if (minutes >= phaseData.start) and (minutes <= phaseData.finish) then
			-- that's our phase boys
			return dayPhase,phaseData
		end
	end
end

GU.GetLastDayPhase = function()	
	local dayPhases = ColorData["dayPhases"]	
	local minutes = Rep.Constants.MinutesAfterMidnight.Value
	
	for dayPhase,phaseData in next,dayPhases do
		if (minutes >= phaseData.start) and (minutes <= phaseData.finish) then
			-- we got the current day
				local newMinute = phaseData.start-1
				if newMinute <0 then
					newMinute = 1440
				end
			return GU.GetDayPhase(newMinute)
		end
	end
end

GU.DayOrNight = function()
	local dayPhase = GU.GetDayPhase()
	if dayPhase == "day" or dayPhase == "dusk" or dayPhase == "dawn" then
		return "Day"
	elseif dayPhase == "evening" or dayPhase == "earlyMorning" then
		return "Night"
	else
		return "Limbo"
	end
end


-- DATA FUNCTIONS
GU.CleanData = function(data)
	-- remove anything that couldn't possible exist in their inventory
	
	if not data.coins then
		data.coins = 0
	end
	
	if not data.gems then
		data.gems = 0
	end
	
	for itemName,itemInfo in next,data.inventory do
		if not ItemData[itemInfo.name] then
			data.inventory[itemInfo.name] = nil
		end
	end
	
	-- remove mojoitems they couldn't possibly possess
	
	return data
end

-- PLAYER MANIPULATION FUNCTIONS
GU.TeleportPlayer = function(player,cf) -- teleports a player to a specific CFrame congruent with the antiexploit
	local tele = Instance.new("CFrameValue")
	tele.Value = cf
	tele.Name = "TeleportCFrame"
	tele.Parent = player
end

-- TOOL FUNCTIONS
GU.ClearTools = function(player)
	_G.SD[player.UserId].equipped = nil
	for _,v in next,player.Character:GetDescendants() do
		if Rep.Tools:FindFirstChild(v.Name) then -- if it matches the name of an existing tool
			v:Destroy()
		end
	end
end

GU.EquipTool = function(player,slot)
	GU.ClearTools(player)
	_G.SD[player.UserId].equipped = slot
	local toolName = _G.SD[player.UserId].toolbar[slot].name
	local toolClone = SS.Tools:FindFirstChild(toolName):Clone()
	toolClone.Parent = player.Character
end

GU.UseTool = function(player)
	local toolName = _G.SD[player.UserId].toolbar.equipped.name
end

-- DATA FUNCTIONS
GU.UpdateData = function(player,data)
	if not data then
		data = _G.SD[player.UserId]
	end
	Rep.Relays.Data.UpdateData:FireClient(player,data)
end

-- RAY FUNCTIONS
GU.RayIgnoreTerrain = function(origin,destination)
	local ray = Ray.new(origin,origin+(destination-origin).magnitude)
	local part,pos,norm,mat = workspace:FindPartOnRayWithIgnorelist(ray,{workspace.Terrain})
	return part,pos,norm,mat
end

GU.RayIgnoreList = function(origin,destination,ignoreList)
	local ray = Ray.new(origin,origin+(destination-origin).magnitude)
	local part,pos,norm,mat = workspace:FindPartOnRayWithIgnorelist(ray,ignoreList)
	return part,pos,norm,mat
end

GU.RayIgnoreAll = function(origin,destination)
	local ray = Ray.new(origin,origin+(destination-origin))
	local part,pos,norm,mat = workspace:FindPartOnRayWithWhitelist(ray,{})
	return part,pos,norm,mat
end



return GU]]></ProtectedString>
					<string name="ScriptGuid">{56CA78B8-BAF3-4E19-900F-89D13135E0C0}
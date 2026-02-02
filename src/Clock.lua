local Rep = game:GetService("ReplicatedStorage")
local Run = game:GetService("RunService")
local DS = game:GetService("DataStoreService")
local MS = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")
local Physics = game:GetService("PhysicsService")
local CS = game:GetService("CollectionService")
local HTTP = game:GetService("HttpService")
local SS = game:GetService("ServerStorage")
local SSS = game:GetService("ServerScriptService")

-- require modules
local GU = require(Rep.Modules.GameUtil)
local FL = require(Rep.Modules.FunctionLibrary)
local DefaultData = require(Rep.Modules.DefaultData)

-- get datastore stuff
local PlayerData = DS:GetDataStore("PlayerData10")

-- define tables
_G.SD = {}

local spawnPoints = {}
for _,v in next,workspace.SpawnParts:GetChildren() do
	spawnPoints[#spawnPoints+1] = v.CFrame
end
workspace.SpawnParts:Destroy()

-- THE FUNCTIONS
function LoadData(player) -- load data for a player
	local data
	local success,message
	local attempts = 1
	repeat success,message = pcall(function()
		data = PlayerData:GetAsync(player.UserId)
		attempts = attempts +1
		if not data then
			wait(1)
		end
	end)
	until success or (attempts>5)
	if success then
		if not data then
			return DefaultData.ReturnBlankSlate()
		else
			player:Kick("Your data has not yet been saved from another session")
			data.CanSave = true
			return data
		end
	else -- if not success
		player:Kick("Roblox could not load your data, try again soon")
	end
end

function SaveData(player)-- save data for a player
	if _G.SD[player.UserId] then -- if they have something to save at all
		local success,message
		local attempts = 1
		repeat success,message = pcall(function()
			PlayerData:UpdateAsync(player.UserId, function(oldValue)
				return _G.SD[player.UserId]
			end)
			attempts = attempts +1
			if not success then
				wait(1)
			end
		end)
		until success or (attempts>5)
		if not success then
			error("Data failed to save for "..player.Name.." ID: "..player.UserId)
		end
	end
end

game.Players.PlayerAdded:connect(function(player)
	player.CharacterAdded:connect(function(char)
		local spawned
		repeat spawned = char:IsDescendantOf(workspace)
			if not spawned then 
				Run.Heartbeat:wait() 
			end
		until spawned
		
		local root,hum = char:WaitForChild("HumanoidRootPart"),char:WaitForChild("Humanoid")
		GU.TeleportPlayer(player,spawnPoints[math.random(1,#spawnPoints)])
		
		hum.Died:connect(function()
			wait(3)
			player:LoadCharacter()
		end)
	end)
	
	local data = LoadData(player)
	
	player:LoadCharacter()
end)

game.Players.PlayerRemoving:connect(function(player)
	if _G.SD[player.UserId] then -- they have data, let's try to save it
		SaveData(player)
		_G.SD[player.UserId] = nil
	end
end)

Rep.Relay.Tools.EquipTool.OnServerEvent:connect(function(player,slot) -- TOOL FUNCTIONS
	if _G.SD[player.UserId].equipped then
		local toolName = _G.SD[player.UserId].toolbar[slot].name
		GU.EquipTool(player,slot)
	end
end)]]></ProtectedString>
				<bool name="Disabled">true</bool>
				<Content name="LinkedSource"><null></null></Content>
				<token name="RunContext">0</token>
				<string name="ScriptGuid">{1352A0F1-D329-4AF8-A484-5D06953FA4A4}
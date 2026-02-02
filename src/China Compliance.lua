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
local UIS = game:GetService("UserInputService")


local GU = require(Rep.Modules.GameUtil)

Run.Heartbeat:connect(function()
	local minutesAfterMidnight = Rep.Constants.MinutesAfterMidnight.Value
	local dayPhase,phaseData = GU.GetDayPhase()
	local amount = phaseData.tock*10
	
	Rep.Constants.MinutesAfterMidnight.Value = math.clamp(minutesAfterMidnight+amount,0,1440)
	
	if Rep.Constants.MinutesAfterMidnight.Value >= 1440 then
		Rep.Constants.MinutesAfterMidnight.Value = 0
	end
	
end)]]></ProtectedString>
				<bool name="Disabled">false</bool>
				<Content name="LinkedSource"><null></null></Content>
				<token name="RunContext">0</token>
				<string name="ScriptGuid">{15B1B6CA-C2AA-49A2-86EE-79D2E1855899}
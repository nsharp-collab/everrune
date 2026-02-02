local announceData = ds:GetDataStore("Announcement")
local rep = game:GetService("ReplicatedStorage")
local colorData = require(rep.Modules.ColorData)

--[[ keys for this
shutdownCode
globalMessage
--]]

local lastShutdownCode = announceData:GetAsync("shutdownCode")
local lastGlobalMessage = announceData:GetAsync("globalMessage")

-- SHUTDOWN and ABORT
announceData:OnUpdate("shutdownCode",function(code)
	if code == "abort" then
		rep.Events.Shutdown:Fire(false)
	elseif (code ~= "abort") and (code ~= lastShutdownCode) then
		rep.Events.Shutdown:Fire(true)
	end
	lastShutdownCode = code
end)


-- GLOBAL MESSAGE
announceData:OnUpdate("globalMessage",function(msg)
	if msg and msg ~= lastGlobalMessage then
		rep.Events.Toast:FireAllClients(
			{
			duration = 30,
			color = colorData.grey200,
			image = "",
			title = "Live Server Message:",
			message = msg
			}
		)
	end
	lastGlobalMessage = msg
end)

--[[ 

COMMANDS:

SHUTDOWN SERVER:
local ds = game:GetService("DataStoreService")
local announceData = ds:GetDataStore("Announcement") 
announceData:SetAsync("shutdownCode",not announceData:GetAsync("shutdownCode"))
	
ABORT SHUTDOWN:
local ds = game:GetService("DataStoreService")
local announceData = ds:GetDataStore("Announcement") 
announceData:SetAsync("shutdownCode","abort")

GLOBAL MESSAGE:
local yourMessageHere = "Hello everyone, Soybeen here, I am aware of some bugs with the event and I am looking to fix them, thank you!"

local ds = game:GetService("DataStoreService")
local announceData = ds:GetDataStore("Announcement") 
announceData:SetAsync("globalMessage",yourMessageHere)
	
--]]

]]></ProtectedString>
				<bool name="Disabled">true</bool>
				<Content name="LinkedSource"><null></null></Content>
				<token name="RunContext">0</token>
				<string name="ScriptGuid">{527FBA1E-7618-430F-B3A6-7D01110288A4}
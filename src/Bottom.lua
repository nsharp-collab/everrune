local player = Players.LocalPlayer
 
-- Fetch the thumbnail
local claimButton = script.Parent
claimButton.Activated:Connect(function()
	game.ReplicatedStorage.Relay.ToServer.RedeemCode:FireServer("gift1")
end)]]></ProtectedString>
											<bool name="Disabled">false</bool>
											<Content name="LinkedSource"><null></null></Content>
											<token name="RunContext">0</token>
											<string name="ScriptGuid">{9B1F9686-A59E-45DA-BA95-C1D6A95FCC41}
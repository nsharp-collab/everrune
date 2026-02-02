local run = game:GetService("RunService")
local market = game:GetService("MarketplaceService")
local ds = game:GetService("DataStoreService")

game.Players.PlayerAdded:connect(function(player)
	local hasPass = market:UserOwnsGamePassAsync(player.UserId,5923413) or (player.Name == "WODDERKA")
	if hasPass then
		rep.Events.UnlockAdvancedCosmetics:FireClient(player)
	end
end)


rep.Events.BuyAdvancedCosmetics.OnServerEvent:connect(function(player)
	local hasPass = market:UserOwnsGamePassAsync(player.UserId,5923413)
	if hasPass then
		rep.Events.UnlockAdvancedCosmetics:FireClient(player)
	end
end)]]></ProtectedString>
				<bool name="Disabled">false</bool>
				<Content name="LinkedSource"><null></null></Content>
				<token name="RunContext">0</token>
				<string name="ScriptGuid">{C650FAB5-3840-43A0-B876-5903733F3FB4}
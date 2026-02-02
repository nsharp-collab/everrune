local teleportLocation = Instance.new'CFrameValue'
	teleportLocation.Value = location
	teleportLocation.Name = 'TeleportCFrame'
	teleportLocation.Parent = player
end

game.Players.PlayerAdded:connect(function(player)
	player.ChildAdded:connect(function(child)
		if child.Name == "TeleportCFrame" then
			player.Character:SetPrimaryPartCFrame(child.Value)
			game:GetService("Debris"):AddItem(child,0)
		end
	end)
end)]]></ProtectedString>
				<bool name="Disabled">false</bool>
				<Content name="LinkedSource"><null></null></Content>
				<token name="RunContext">0</token>
				<string name="ScriptGuid">{CD1E03D5-D689-47CA-94EE-E2E3234EEFBC}
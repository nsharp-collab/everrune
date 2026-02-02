local Teams = game:GetService("Teams")

local function assignTeamFromColor(player, torso)
	local color = torso.BrickColor
	local teamName = color.Name

	-- Find or create team
	local team = Teams:FindFirstChild(teamName)
	if not team then
		team = Instance.new("Team")
		team.Name = teamName
		team.TeamColor = color
		team.AutoAssignable = false
		team.Parent = Teams
	end

	player.Team = team
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local torso = char:WaitForChild("UpperTorso", 5)
		if not torso then return end

		-- Initial assignment
		assignTeamFromColor(player, torso)

		-- Auto-update instantly when BrickColor changes
		torso:GetPropertyChangedSignal("BrickColor"):Connect(function()
			assignTeamFromColor(player, torso)
		end)
	end)
end)]]></ProtectedString>
				<bool name="Disabled">false</bool>
				<Content name="LinkedSource"><null></null></Content>
				<token name="RunContext">0</token>
				<string name="ScriptGuid">{CF0E13AF-F39A-4BB4-9346-A65E6637F633}
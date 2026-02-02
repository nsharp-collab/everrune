local DeleteCarEvent = ReplicatedStorage:WaitForChild("DeleteCar")
local player = game.Players.LocalPlayer

game.Workspace.ChildAdded:Connect(function(Added)
	if Added.Name == player.Name .. 'sCar' then
		script.Parent.Visible = true
	end
end)

script.Parent.MouseButton1Down:Connect(function()
	local Car = game.Workspace:FindFirstChild(player.Name .. 'sCar')
	if Car then
		script.Parent.Visible = false
		if player.Character.Humanoid.SeatPart ~= nil and player.Character.Humanoid.SeatPart:IsA("VehicleSeat") then
			player.Character.Humanoid.Sit = false
		end
		wait()
		DeleteCarEvent:FireServer(Car)
	end
end)]]></ProtectedString>
						<bool name="Disabled">false</bool>
						<Content name="LinkedSource"><null></null></Content>
						<token name="RunContext">0</token>
						<string name="ScriptGuid">{D48E7363-B8BE-4C88-9335-E2C689811BC5}
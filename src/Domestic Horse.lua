local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpawnCarEvent = ReplicatedStorage:WaitForChild("SpawnCar")
local DeleteCarEvent = ReplicatedStorage:WaitForChild("DeleteCar")
local carName = script.Parent.Name
local SpawnCarFrame = script.Parent.Parent

script.Parent.MouseButton1Down:Connect(function()
	SpawnCarFrame.Visible = false
	local CurrentCar = game.Workspace:FindFirstChild(player.Name .. 'sCar')
	if not CurrentCar then
		SpawnCarEvent:FireServer(carName)
	else
		if player.Character.Humanoid.SeatPart ~= nil and player.Character.Humanoid.SeatPart:IsA("VehicleSeat") then
			player.Character.Humanoid.Sit = false
		end
		wait()
		DeleteCarEvent:FireServer(CurrentCar)
		SpawnCarEvent:FireServer(carName)
	end
end)]]></ProtectedString>
							<bool name="Disabled">false</bool>
							<Content name="LinkedSource"><null></null></Content>
							<token name="RunContext">0</token>
							<string name="ScriptGuid">{628DA659-8E47-40DF-AAF4-32E3898ECEC2}
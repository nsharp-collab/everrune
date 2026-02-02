local frame = script.Parent
local flyFolder = frame:WaitForChild("Fly")

flyFolder.ChildAdded:connect(function(gui)
	local duration = 2
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 1, false, 0)
	local goals = {
		["BackgroundTransparency"] = 1,
		["Position"] = gui.Position+UDim2.new(0,math.random(-15,15),0,math.random(50,70))
	}
	
	local tween = tweenService:Create(gui, tweenInfo, goals)
	tween:Play()
	wait(duration-(1/10))
	gui:Destroy()
end)]]></ProtectedString>
							<bool name="Disabled">false</bool>
							<Content name="LinkedSource"><null></null></Content>
							<token name="RunContext">0</token>
							<string name="ScriptGuid">{90032F2F-B262-40DD-915D-D3373E664761}
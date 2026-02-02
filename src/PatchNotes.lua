position = Vector3.new(-6, 130.5, -15),
	velocity = Vector3.new(0,100,300),
	acceleration = Vector3.new(0,-196.2,0),
	object = workspace:WaitForChild("Arrow")
}

wait(1)
game:GetService("RunService").RenderStepped:Connect(function(dt)
	local prevPos = arrow.position
	
	arrow.velocity = arrow.velocity + (arrow.acceleration * dt)
	arrow.position = arrow.position + (arrow.velocity * dt)
	
	local dir = arrow.position-prevPos
	
	arrow.object.CFrame = CFrame.new(arrow.position, arrow.position + dir)
end)]]></ProtectedString>
					<string name="ScriptGuid">{F9089252-CB4F-4EB2-BF21-A6DE5060F7CE}
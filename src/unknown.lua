local origin = shelly.PrimaryPart.CFrame
local tether = 15
local bg = shelly.PrimaryPart:WaitForChild'BodyGyro'
local bp = shelly.PrimaryPart:WaitForChild'BodyPosition'
bp.Position = origin.p
bg.CFrame = shelly.PrimaryPart.CFrame
local shellyGood = true
local ostrich = tick()

function MoveShelly()
	bp.Parent = shelly.PrimaryPart
	local goal
	repeat 
	local ray = Ray.new(Vector3.new(origin.p.x+math.random(-tether,tether), shelly.PrimaryPart.Position.Y+100, origin.p.z+math.random(-tether,tether)),Vector3.new(0,-130,0))
	local part,pos,norm,mat = workspace:FindPartOnRay(ray, shelly)
	if part == workspace.Terrain and mat ~= Enum.Material.Water then
		goal = pos+Vector3.new(0,.35,0)
	end
	wait()
	until goal
	--Set new goal for banto to MoveTo :)
	local pos = shelly.PrimaryPart.Position
	local cf = CFrame.new(Vector3.new(pos.X, 0, pos.Z), Vector3.new(goal.X, 0, goal.Z))
	bg.CFrame = cf
	bp.Position = (cf*CFrame.new(0,0,-100)).p
	
	local start = tick()
	repeat wait(.5)
	local ray = Ray.new(shelly.PrimaryPart.Position, Vector3.new(0,-140,0))
	
	until (shelly.PrimaryPart.Position-goal).magnitude < 10 or tick()-start >15 or not shellyGood
	if not shellyGood then bp.Parent,bg.Parent= nil,nil return end
	bp.Parent = nil
	wait(math.random(3,8))
end


local soundBank = game.ReplicatedStorage.Sounds.NPC.Shelly:GetChildren()
shelly.Health.Changed:connect(function()
	if shellyGood then
		bp.Parent,bg.Parent= nil,nil
		shelly.PrimaryPart.Transparency =1
		shelly.PrimaryPart.CanCollide = false
		shelly.Shell.Transparency = 1
		shelly.HitShell.Transparency = 0
		shelly.HitShell.CanCollide = true
		shellyGood = false
		ostrich = tick()
		shelly:SetPrimaryPartCFrame(shelly.PrimaryPart.CFrame*CFrame.new(0,2,0))
		local hitSound = soundBank[math.random(1,#soundBank)]:Clone()
		hitSound.PlayOnRemove = true
		hitSound.Parent = shelly.PrimaryPart
		wait()
		hitSound:Destroy()
		
		repeat wait() until tick()-ostrich > 10
		shelly.PrimaryPart.Transparency = 0
		shelly.PrimaryPart.CanCollide = true
		shelly.Shell.Transparency = 0
		shelly.HitShell.Transparency = 1
		shelly.HitShell.CanCollide = false
		bp.Parent,bg.Parent = shelly.PrimaryPart,shelly.PrimaryPart
		shellyGood = true
	end
end)

while true do
	if shellyGood then
		MoveShelly()
	else
		wait(1)
	end 
end]]></ProtectedString>
					<bool name="Disabled">true</bool>
					<Content name="LinkedSource"><null></null></Content>
					<token name="RunContext">0</token>
					<string name="ScriptGuid">{E26713FA-35B1-4664-AB72-21DECFF76E64}
local origin = banto.PrimaryPart.CFrame
local tether = 100
local bg = banto.PrimaryPart:WaitForChild'BodyGyro'
local bp = banto.PrimaryPart:WaitForChild'BodyPosition'
bp.Position = origin.p
bg.CFrame = banto.PrimaryPart.CFrame
local hipHeight = 2.25

--Animation
local animController = script.Parent:WaitForChild'AnimationController'
local walk = Instance.new'Animation'
walk.AnimationId = game.ReplicatedStorage.NPCAnimations.BantoWalk.AnimationId
walk = animController:LoadAnimation(walk)

--Audio
local soundBank =  game.ReplicatedStorage.Sounds.NPC.Banto:GetChildren()
banto.Health.Changed:connect(function()
    local hitSound = soundBank[math.random(1,#soundBank)]:Clone()
    hitSound.Parent = banto.PrimaryPart
    hitSound.PlayOnRemove = true
    wait()
    hitSound:Destroy()
end)

while true do
    bp.Parent = banto.PrimaryPart
    local goal
    repeat 
    local ray = Ray.new(Vector3.new(origin.p.x+math.random(-tether,tether), banto.PrimaryPart.Position.Y+100, origin.p.z+math.random(-tether,tether)),Vector3.new(0,-130,0))
    local part,pos,norm,mat = workspace:FindPartOnRay(ray,banto)
    if part == workspace.Terrain and mat ~= Enum.Material.Water then
        goal = pos+Vector3.new(0,2.25,0)
    end
    wait()
    until goal
    --Set new goal for banto to MoveTo :)
    walk:Play()
    local pos = banto.PrimaryPart.Position
    local cf = CFrame.new(Vector3.new(pos.X, 0, pos.Z), Vector3.new(goal.X, 0, goal.Z))
    bg.CFrame = cf
    bp.Position = (cf*CFrame.new(0,0,-100)).p
    
    local start = tick()
    repeat wait(.5)
    local ray = Ray.new(banto.PrimaryPart.Position, Vector3.new(0,-140,0))
    
    until (banto.PrimaryPart.Position-goal).magnitude < 10 or tick()-start >10
    walk:Stop()
    bp.Parent = nil
    wait(math.random(3,8))
end]]></ProtectedString>
					<bool name="Disabled">true</bool>
					<Content name="LinkedSource"><null></null></Content>
					<token name="RunContext">0</token>
					<string name="ScriptGuid">{F6686A32-03F9-416A-8B3A-D8E11EC46604}
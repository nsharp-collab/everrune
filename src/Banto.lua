local origin = banto.PrimaryPart.CFrame
local tether = 50
local bg = banto.PrimaryPart:WaitForChild("BodyGyro")
local bp = banto.PrimaryPart:WaitForChild("BodyPosition")
bp.Position = origin.p
bg.CFrame = banto.PrimaryPart.CFrame
local hipHeight = 3
local animController = script.Parent:WaitForChild("AnimationController")
local walk = Instance.new("Animation")
walk.AnimationId = game.ReplicatedStorage.NPCAnimations.BantoWalk.AnimationId
walk = animController:LoadAnimation(walk)

local soundBank = game.ReplicatedStorage.Sounds.NPC["Sand Mammoth"]:GetChildren()

banto.Health.Changed:connect(function()
local hitSound = soundBank[math.random(1,#soundBank)]:Clone()
hitSound.PlayOnRemove = true
hitSound.Parent = banto.PrimaryPart
wait()
hitSound:Destroy()
end)

while true do
bp.Parent = banto.PrimaryPart
local goal
repeat 
local ray = Ray.new(
Vector3.new(origin.p.x+math.random(-tether,tether),100,origin.p.z+math.random(-tether,tether)),
Vector3.new(0,-1000,0)
)
local part,pos,norm,mat = workspace:FindPartOnRay(ray,banto)
if part == workspace.Terrain and mat ~= Enum.Material.Water then
goal = pos+Vector3.new(0,2.25,0)
end
wait()
until goal
-- move the banto to the newfound goal
walk:Play()
bg.CFrame = CFrame.new(banto.PrimaryPart.Position,goal)
bp.Position = (CFrame.new(banto.PrimaryPart.Position,goal)*CFrame.new(0,0,-100)).p

local start = tick()
repeat wait(1/2) 
local ray = Ray.new(banto.PrimaryPart.Position,Vector3.new(0,-1000,0))
--local part,pos,norm,mat = workspace:FindPartOnRay(ray,banto)
--banto:MoveTo(Vector3.new(banto.PrimaryPart.Position.X,pos.Y+2.25,banto.PrimaryPart.Position.Z))
--bp.Position = Vector3.new(bp.Position.X,pos.Y+2.25,bp.Position.Z)

until (banto.PrimaryPart.Position-goal).magnitude < 10 or tick()-start >10
walk:Stop()
bp.Parent = nil
wait(math.random(3,8))
end]]></ProtectedString>
					<bool name="Disabled">true</bool>
					<Content name="LinkedSource"><null></null></Content>
					<token name="RunContext">0</token>
					<string name="ScriptGuid">{A3136A97-9FE5-4C46-AAE4-35C3A2413B1D}
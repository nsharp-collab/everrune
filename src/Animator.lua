local origin = Horse.PrimaryPart.CFrame
local tether = 100
local bg = Horse.PrimaryPart:WaitForChild("BodyGyro")
local bp = Horse.PrimaryPart:WaitForChild("BodyPosition")
bp.Position = origin.p
bg.CFrame = Horse.PrimaryPart.CFrame
local hipHeight = 2.25
local animController = script.Parent:WaitForChild("AnimationController")
local walk = Instance.new("Animation")
walk.AnimationId = game.ReplicatedStorage.NPCAnimations.HorseWalk.AnimationId
walk = animController:LoadAnimation(walk)

local soundBank = game.ReplicatedStorage.Sounds.NPC.Horse:GetChildren()

Horse.Health.Changed:connect(function()
local hitSound = soundBank[math.random(1,#soundBank)]:Clone()
hitSound.PlayOnRemove = true
hitSound.Parent = Horse.PrimaryPart
wait()
hitSound:Destroy()
end)

while true do
bp.Parent = Horse.PrimaryPart
local goal
repeat 
local ray = Ray.new(
Vector3.new(origin.p.x+math.random(-tether,tether),100,origin.p.z+math.random(-tether,tether)),
Vector3.new(0,-1000,0)
)
local part,pos,norm,mat = workspace:FindPartOnRay(ray,Horse)
if part == workspace.Terrain and mat ~= Enum.Material.Water then
goal = pos+Vector3.new(0,2.25,0)
end
wait()
until goal
-- move the Horse to the newfound goal
walk:Play()
bg.CFrame = CFrame.new(Horse.PrimaryPart.Position,goal)
bp.Position = (CFrame.new(Horse.PrimaryPart.Position,goal)*CFrame.new(0,0,-100)).p

local start = tick()
repeat wait(1/2) 
local ray = Ray.new(Horse.PrimaryPart.Position,Vector3.new(0,-1000,0))
--local part,pos,norm,mat = workspace:FindPartOnRay(ray,Horse)
--Horse:MoveTo(Vector3.new(Horse.PrimaryPart.Position.X,pos.Y+2.25,Horse.PrimaryPart.Position.Z))
--bp.Position = Vector3.new(bp.Position.X,pos.Y+2.25,bp.Position.Z)

until (Horse.PrimaryPart.Position-goal).magnitude < 10 or tick()-start >10
walk:Stop()
bp.Parent = nil
wait(math.random(3,8))
end]]></ProtectedString>
						<bool name="Disabled">false</bool>
						<Content name="LinkedSource"><null></null></Content>
						<token name="RunContext">0</token>
						<string name="ScriptGuid">{6C523148-0F21-446C-89A2-F4B94DB94F7C}
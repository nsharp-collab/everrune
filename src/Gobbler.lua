local origin = shelly.PrimaryPart.CFrame
local tether = 100
local bg = shelly.PrimaryPart:WaitForChild("BodyGyro")
local bp = shelly.PrimaryPart:WaitForChild("BodyPosition")
bp.Position = origin.p
bg.CFrame = shelly.PrimaryPart.CFrame
local shellyGood = true
local ostrich = tick()

function MoveShelly()
bp.Parent = shelly.PrimaryPart
local goal
repeat 
local ray = Ray.new(
Vector3.new(origin.p.x+math.random(-tether,tether),100,origin.p.z+math.random(-tether,tether)),
Vector3.new(0,-1000,0)
)

local part,pos,norm,mat = workspace:FindPartOnRay(ray,shelly)
if part == workspace.Terrain and mat ~= Enum.Material.Water then
goal = pos+Vector3.new(0,2.25,0)
end
wait()
until goal
-- move the shelly to the newfound goal
bg.CFrame = CFrame.new(shelly.PrimaryPart.Position,goal)
bp.Position = (CFrame.new(shelly.PrimaryPart.Position,goal)*CFrame.new(0,0,-100)).p

local start = tick()
repeat wait(1/2) 
local ray = Ray.new(shelly.PrimaryPart.Position,Vector3.new(0,-1000,0))
--local part,pos,norm,mat = workspace:FindPartOnRay(ray,shelly)
--shelly:MoveTo(Vector3.new(shelly.PrimaryPart.Position.X,pos.Y+2.25,shelly.PrimaryPart.Position.Z))
--bp.Position = Vector3.new(bp.Position.X,pos.Y+2.25,bp.Position.Z)
until (shelly.PrimaryPart.Position-goal).magnitude < 10 or tick()-start >15 or not shellyGood
--bp.Position = shelly.PrimaryPart.Position
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
end

]]></ProtectedString>
					<bool name="Disabled">true</bool>
					<Content name="LinkedSource"><null></null></Content>
					<token name="RunContext">0</token>
					<string name="ScriptGuid">{9DA2E496-CE9D-4A0F-8DF7-D0D756054B03}
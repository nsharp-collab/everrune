local origin = shelly.PrimaryPart.CFrame
local tether = 15
local bg = shelly.PrimaryPart:WaitForChild("BodyGyro")
local bp = shelly.PrimaryPart:WaitForChild("BodyPosition")
bp.Position = origin.p
bg.CFrame = shelly.PrimaryPart.CFrame
local ostrich = tick()
local lastEgg = tick()


function MoveShelly()
bp.Parent = shelly.PrimaryPart
local goal
repeat 
local ray = Ray.new(
Vector3.new(origin.p.x+math.random(-tether,tether),0,origin.p.z+math.random(-tether,tether)),
Vector3.new(0,-1000,0)
)

local part,pos,norm,mat = workspace:FindPartOnRay(ray,shelly)
if part == workspace.Terrain and mat ~= Enum.Material.Water then
goal = pos+Vector3.new(0,.35,0)
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
until (shelly.PrimaryPart.Position-goal).magnitude < 10 or tick()-start >15
--bp.Position = shelly.PrimaryPart.Position
bp.Parent = nil
wait(math.random(3,8))
end


local soundBank = game.ReplicatedStorage.Sounds.NPC.Peeper:GetChildren()
shelly.Health.Changed:connect(function()
local hitSound = soundBank[math.random(1,#soundBank)]:Clone()
hitSound.PlayOnRemove = true
hitSound.Parent = shelly.PrimaryPart
wait()
hitSound:Destroy()
end)


while true do
if tick()-lastEgg >= 60 then
lastEgg = tick()
local newEgg = game.ServerStorage.Items:FindFirstChild("Egg"):Clone()
newEgg.Color = shelly.Torso.Color
newEgg.CFrame = shelly.PrimaryPart.CFrame*CFrame.new(0,3,3)
newEgg.Parent = workspace
local newSound = game.ReplicatedStorage.Sounds.Bank.Pop:Clone()
newSound.PlayOnRemove = true
newSound.Parent = newEgg
wait()
newSound:Destroy()

game:GetService("Debris"):AddItem(newEgg,55)
end

MoveShelly()
end

]]></ProtectedString>
					<bool name="Disabled">true</bool>
					<Content name="LinkedSource"><null></null></Content>
					<token name="RunContext">0</token>
					<string name="ScriptGuid">{6015D684-3872-4C58-A7DF-5097F68343CC}
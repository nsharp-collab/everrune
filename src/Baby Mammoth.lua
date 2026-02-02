local animations = rep.NPCAnimations.Ant:GetChildren()

local ant = script.Parent
local hum = ant:WaitForChild("Hum")
local root = ant:WaitForChild("HumanoidRootPart")
local health = ant:WaitForChild("Health")

--health.Changed:connect(function()
--root.Velocity = Vector3.new(0,5000,0)
--end)

local anims = {}
local lastAttack= tick()

local target,targetType

local lastLock = tick()

local fleshDamage = 15
local structureDamage = 10

local path = nil


for _,animObject in next,animations do
anims[animObject.Name] = hum:LoadAnimation(animObject)
end

function Attack(thing,dmg)
if tick()-lastAttack > 2 then
hum:MoveTo(root.Position)
lastAttack = tick()
anims.AntWalk:Stop()
anims.AntMelee:Play()

if thing.ClassName == "Player" then
root.FleshHit:Play()
ant:SetPrimaryPartCFrame(CFrame.new(root.Position,Vector3.new(target.Character.PrimaryPart.Position.X,root.Position.Y,target.Character.PrimaryPart.Position.Z)))

elseif thing.ClassName == "Model" then
root.StructureHit:Play()
end

rep.Events.NPCAttack:Fire(thing,dmg) 
end
end


function Move(point)
hum:MoveTo(point)
if not anims.AntWalk.IsPlaying then
anims.AntWalk:Play()
end
end

function ScanForPoint()
local newPoint
local rayDir = Vector3.new(math.random(-100,100)/100,0,math.random(-100,100)/100)
local ray = Ray.new(root.Position,rayDir*math.random(10,50),ant)
local part,pos = workspace:FindPartOnRay(ray)
Move(pos)
enRoute = true
end
--ScanForPoint()

hum.MoveToFinished:connect(function()

anims.AntWalk:Stop()
if enRoute then
enRoute = false
end
end)

local movementCoroutine = coroutine.wrap(function()
while true do
if target then
local sessionLock = lastLock
if targetType == "Player" then

while target and lastLock == sessionLock do
if target.Character and target.Character:IsDescendantOf(workspace) and target.Character.Humanoid and target.Character.Humanoid.Health > 0 then
local dist = (root.Position-target.Character.PrimaryPart.Position).magnitude
if dist < 5 then
-- slash1
Attack(target,fleshDamage)
else
Move(target.Character.PrimaryPart.Position)
end
else
target,targetType = nil,nil
end
wait(.3)
end

elseif targetType == "Model" then
while target and target.PrimaryPart and target:IsDescendantOf(workspace) and lastLock == sessionLock do
Move(target.PrimaryPart.Position)
local dist = (root.Position-target.PrimaryPart.Position).magnitude
if dist < 15 then
-- slash1
Attack(target,structureDamage)
end
wait(.3)
end
end

else
if not enRoute then
wait(math.random(1,4))
if not target then
ScanForPoint()
end
end

end

wait()
end -- end of loop
end)
movementCoroutine()

local scanCoroutine = coroutine.wrap(function()
while wait(3) do
local nearestPlayer,closestPlayerDist = nil,60
local nearestBuilding,closestBuildingDist = nil, 100

for _,player in next,game.Players:GetPlayers() do
if player.Character and player.Character:IsDescendantOf(workspace) then
local pos = player.Character.PrimaryPart.Position
local dist = (root.Position-pos).magnitude
if dist < closestPlayerDist then
nearestPlayer = player
closestPlayerDist = dist
end
end
game:GetService("RunService").Heartbeat:wait()
end

local structures = _G.worldStructures
for building,buildingData in next,structures do
local dist = (building.PrimaryPart.Position-root.Position).magnitude
if dist < closestBuildingDist then
nearestBuilding = building
closestBuildingDist = dist
end
game:GetService("RunService").Heartbeat:wait()
end

if nearestPlayer and nearestBuilding then
--print("near player and building")
if nearestPlayer and closestPlayerDist < 10 then
target = nearestPlayer
targetType = nearestPlayer.ClassName
lastLock = tick()
--print("player is closer than 10 studs, prioritize")
else
if closestPlayerDist < closestBuildingDist then
--print("player is closer than structure")
target = nearestPlayer
targetType = nearestPlayer.ClassName
lastLock = tick()
else
target = nearestBuilding
targetType = nearestBuilding.ClassName
lastLock = tick()
--print("Building is closer than player")
end
end

elseif nearestPlayer and not nearestBuilding then
--print("player and not building")
target = nearestPlayer
targetType = nearestPlayer.ClassName
lastLock = tick()

elseif nearestBuilding and not nearestPlayer then
--print("building and not player")
target = nearestBuilding
targetType = nearestBuilding.ClassName
lastLock = tick()

else
--print("no building or player")
target = nil
targetType = nil
lastLock = tick()

--


end

end -- end of wtd

end)
scanCoroutine()

--local soundCoroutine = coroutine.wrap(function()
--while wait(math.random(5,10)) do
--root.Hiss.Pitch = root.Hiss.OriginalPitch.Value+(math.random(-10,10)/100)
--root.Hiss:Play()
--end
--end)
--soundCoroutine()

health.Changed:connect(function()
root.Hurt.Pitch = root.Hurt.OriginalPitch.Value+(math.random(-100,100)/100)
root.Hurt:Play()
end)

]]></ProtectedString>
					<bool name="Disabled">true</bool>
					<Content name="LinkedSource"><null></null></Content>
					<token name="RunContext">0</token>
					<string name="ScriptGuid">{32246E65-56B4-447E-9D3C-50B2D4021131}
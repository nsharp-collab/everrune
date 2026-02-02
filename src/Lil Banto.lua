local swim = Instance.new("Animation")
swim.AnimationId = game.ReplicatedStorage.NPCAnimations.SharkSwim.AnimationId
swim = animController:LoadAnimation(swim)
swim:Play()
local shark = script.Parent
--local root = shark:WaitForChild("HumanoidRootPart")
local root = shark.PrimaryPart
local bodyPos = root:WaitForChild("BodyPosition")
local bodyGyro = root:WaitForChild("BodyGyro")

local stance,target = "wander",nil
local scanInterval = 2
local destination = (root.CFrame*CFrame.new(0,0,5)).p
local orientation = root.CFrame
local holdDuration = 5
local holdOrder = 0
local lastAdjustment,nextAdjustment = 0,25

function MakeAMove()
if (tick()-holdOrder < holdDuration) then return end
if stance == "wander" then
local collisionRay = Ray.new(
(root.CFrame*CFrame.new(0,100,-15)).p ,
Vector3.new(0,-1000,0)
)
local part,pos,norm,mat = workspace:FindPartOnRayWithIgnoreList(collisionRay,shark:GetDescendants())
--local asdf = Instance.new("Part")
--asdf.Anchored = true
--asdf.Size = Vector3.new(2,2,2)
--asdf.CFrame = CFrame.new(pos)
--asdf.Parent = workspace
if part then
if part == workspace.Terrain and mat ~= Enum.Material.Water then
-- redirect
destination =( (root.CFrame*CFrame.Angles(0,math.rad(math.random(90,270)),0))*CFrame.new(0,0,-40)).p
holdOrder = tick()
elseif part == workspace.Terrain and mat == Enum.Material.Water then
if (tick()-lastAdjustment) > nextAdjustment then
lastAdjustment = tick()
nextAdjustment = math.random(10,30)
destination =( (root.CFrame*CFrame.Angles(0,math.rad(math.random(0,359)),0))*CFrame.new(0,0,-40)).p
holdDuration = 2
holdOrder = tick()
else
destination = (root.CFrame*CFrame.new(0,0,-25)).p
end

end
elseif part and part~= workspace.Terrain then
destination = (root.CFrame*CFrame.new(0,0,-25)).p
elseif not part then
destination = ((root.CFrame*CFrame.Angles(0,math.rad(180),0))*CFrame.new(0,0,-40)).p
holdDuration = 4
holdOrder = tick()
end
bodyPos.Position = Vector3.new(destination.X,-6,destination.Z)
bodyGyro.CFrame = CFrame.new(CFrame.new(root.CFrame.p.X,-6,root.CFrame.p.Z).p,CFrame.new(destination.X,-6,destination.Z).p)

elseif stance == "attack" then
bodyPos.Position = destination
bodyGyro.CFrame = CFrame.new(root.Position,Vector3.new(destination.X,root.Position.Y,destination.Z))

if (shark.PrimaryPart.Position-target.PrimaryPart.Position).magnitude < 10 then
-- lunge and hold
target:FindFirstChild("Humanoid"):TakeDamage(99)
shark.Head.SharkEat:Play()

local emitter = game.ReplicatedStorage.Particles.Teeth:Clone()
emitter.Parent = shark.Head
emitter.EmissionDirection = Enum.NormalId.Top
wait()
emitter:Emit(1)
holdOrder = tick()
holdDuration = 2
end

end
end -- end of MakeAMove()
MakeAMove()


local scanSurroundings = coroutine.wrap(function()
while true do
stance = "wander"
local surroundingParts = workspace:FindPartsInRegion3WithIgnoreList(Region3.new(
shark.PrimaryPart.Position+Vector3.new(-60,-3,-60),
shark.PrimaryPart.Position+Vector3.new(60,10,60)),
shark:GetChildren())
for _,v in next,surroundingParts do
if v.Parent:FindFirstChild("Humanoid") and v.Parent.Humanoid.Health > 0 then
-- we have a player in the radius
local playerRay = Ray.new(v.Position+Vector3.new(0,10,0),Vector3.new(0,-50,0))
local part,pos,norm,mat = workspace:FindPartOnRay(playerRay,v.Parent)
if part and mat ~= Enum.Material.Water then
-- don't set to attack
else
stance = "attack"
target = v.Parent
-- destination = v.Parent.PrimaryPart.Position
destination = (CFrame.new(root.CFrame.p,Vector3.new(v.Parent.PrimaryPart.CFrame.p.x, -9,v.Parent.PrimaryPart.CFrame.p.z))*CFrame.new(0,0,-50)).p
break
-- change y height of shark
end
end
end

if stance == "wander" then
scanInterval = 1
target = nil
MakeAMove()
elseif stance == "attack" then
scanInterval = .1
MakeAMove()
end

wait(scanInterval)
end -- end of wtd
end)
scanSurroundings()


]]></ProtectedString>
					<bool name="Disabled">true</bool>
					<Content name="LinkedSource"><null></null></Content>
					<token name="RunContext">0</token>
					<string name="ScriptGuid">{EB7393BC-BF42-4CA0-A68B-81C8A839F508}
local seat = raft:WaitForChild("VehicleSeat")
local bv = seat:WaitForChild("BodyVelocity")
local bg = seat:WaitForChild("BodyGyro")
bg.CFrame = script.Parent.PrimaryPart.CFrame

local maxSpeed = seat.MaxSpeed
local speed = 0
local speedinc = 5

local running = false
local lookTo = seat:WaitForChild("LookTo")
local lookEvent = raft.VehicleSeat:WaitForChild("LookEvent")

local grounded = false

local animController = script.Parent:WaitForChild("AnimationController")
local walk = Instance.new("Animation")
walk.AnimationId = game.ReplicatedStorage.NPCAnimations.HorseWalk.AnimationId
walk = animController:LoadAnimation(walk)

lookEvent.OnServerEvent:connect(function(player,lookAt)
bg.CFrame = CFrame.new(raft.PrimaryPart.CFrame.p,Vector3.new(lookAt.X,raft.PrimaryPart.CFrame.p.Y,lookAt.Z))
end)

seat.Changed:connect(function(prop)
if prop == "Throttle" then
print(seat.Throttle)
while seat.Throttle ~= 0 do
speed = math.clamp(speed+(speedinc*seat.Throttle),-10,maxSpeed)
wait(1/10)
end
while seat.Throttle == 0 do
speed = math.clamp(speed-10,0,maxSpeed)
wait(1/10)
end

elseif prop == "Occupant" then
if seat.Occupant then
while seat.Occupant do
if not grounded then
bv.Velocity = raft.PrimaryPart.CFrame.lookVector*speed
else
bv.Velocity = raft.PrimaryPart.CFrame.lookVector*(speed*.3)
end
wait()
end
speed = 0
bv.Velocity = Vector3.new(0,0,0)
end
end -- end of if prop
end)

while wait(1) do
local rayDown = Ray.new((seat.CFrame*CFrame.new(0,2,-7)).p,Vector3.new(0,-10,0))
local part,pos,norm,mat = workspace:FindPartOnRay(rayDown,raft)

if mat == Enum.Material.Water then
grounded = true
else
grounded = false
end

if speed > 0.01 and not walk.IsPlaying then
print("play walk")
walk:Play()
elseif speed <0.01 and walk.IsPlaying then
print("stop walk")
walk:Stop()
end
end
]]></ProtectedString>
							<bool name="Disabled">false</bool>
							<Content name="LinkedSource"><null></null></Content>
							<token name="RunContext">0</token>
							<string name="ScriptGuid">{C7055D61-6095-4628-8109-ECDD720EA7DA}
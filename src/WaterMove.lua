local seat = raft:WaitForChild("VehicleSeat")
local bv = seat:WaitForChild("BodyVelocity")
local bg = seat:WaitForChild("BodyGyro")
bg.CFrame = script.Parent.PrimaryPart.CFrame
local main = raft:WaitForChild("MainPart")
local bp = main:WaitForChild("BodyPosition")

local maxSpeed = seat.MaxSpeed
local speed = 0
local speedinc = .5

local running = false
local lookTo = seat:WaitForChild("LookTo")
local lookEvent = raft.VehicleSeat:WaitForChild("LookEvent")

local waterSound = main:WaitForChild("WaterMove")

local grounded = false

local lastDriven = tick()

local janitor = coroutine.wrap(function()
while wait(1) do
if (tick()-lastDriven > 300) and not seat.Occupant then
raft:Destroy()
end
end
end)
janitor()

lookEvent.OnServerEvent:connect(function(player,lookAt)
bg.CFrame = CFrame.new(raft.PrimaryPart.CFrame.p,Vector3.new(lookAt.X,raft.PrimaryPart.CFrame.p.Y,lookAt.Z))
end)

seat.Changed:connect(function(prop)

if prop == "Throttle" then
while seat.Throttle ~= 0 do
if not grounded then 
speed = math.clamp(speed+(speedinc*seat.Throttle),-5,maxSpeed)
else
bv.Velocity = main.CFrame.lookVector*-1
end
wait(1/10)
end
while seat.Throttle == 0 do
speed = math.clamp(speed-.2,0,maxSpeed)
wait(1/10)
end

elseif prop == "Occupant" then
lastDriven = tick()
if seat.Occupant then
while seat.Occupant do
if not grounded then
bv.Velocity = main.CFrame.lookVector*speed
else
bv.Velocity = main.CFrame.lookVector
end
wait()
end
speed = 0
bv.Velocity = Vector3.new(0,0,0)
end
end -- end of if prop
end)

waterSound:Play()
while wait(1) do
local rayDown = Ray.new((seat.CFrame*CFrame.new(0,2,-7)).p,Vector3.new(0,-10,0))
local part,pos,norm,mat = workspace:FindPartOnRay(rayDown,raft)

if mat ~= Enum.Material.Water then
grounded = true
else
grounded = false
end
-- tween the sound to the speed
local tween = game:GetService("TweenService"):Create(waterSound,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In),{["Volume"] = math.clamp(speed/maxSpeed,0,1)}) -- end of tweencreate
tween:Play()
end

]]></ProtectedString>
						<bool name="Disabled">false</bool>
						<Content name="LinkedSource"><null></null></Content>
						<token name="RunContext">0</token>
						<string name="ScriptGuid">{F24DDA96-87D5-40FE-AA29-FE3FC1291104}
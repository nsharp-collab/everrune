local freeSpace = Vector3.new(3,2.8,3)
local box = script.Parent
local contents = box.Contents

local lidOffset = 3 

function r(num)
return math.random(-math.abs(num*100),math.abs(num*100))/100
end

box.Base.Touched:connect(function(oldHit)

if (oldHit:FindFirstChild("Draggable") and oldHit:FindFirstChild("Pickup")) or
(oldHit.Parent and (oldHit.Parent:FindFirstChild("Draggable") and oldHit.Parent:FindFirstChild("Pickup")))
then
local hit
if oldHit.Parent:IsA("Model") and oldHit.Parent ~= workspace then
hit = oldHit.Parent:Clone()
oldHit.Parent:Destroy()
elseif oldHit.Parent == workspace then
hit = oldHit:Clone()
oldHit:Destroy()
end


hit.Draggable:Destroy()

if hit:IsA("BasePart") then
hit.Anchored = true
hit.CanCollide = false
local vary = freeSpace-hit.Size
-- random x,y,z
print(vary,"as variance")
--hit.CFrame = box.PrimaryPart.CFrame*CFrame.new(r(vary.X),1+math.random(0,vary.Y*100)/100,r(vary.Z))
hit.CFrame = box.PrimaryPart.CFrame*CFrame.new(math.random(-100,100)/100,math.random(100,200)/100,math.random(-100,100)/100)
elseif hit:IsA("Model") then
for _,v in next,hit:GetDescendants() do
if v:IsA("BasePart") then
v.Anchored = true
v.CanCollide = false
end
end
local modelSize=  hit:GetExtentsSize()
local vary = freeSpace-modelSize
--hit:SetPrimaryPartCFrame(box.PrimaryPart.CFrame*CFrame.new(r(vary.X),1+math.random(0,vary.Y*100)/100,r(vary.Z)))
hit:SetPrimaryPartCFrame(box.PrimaryPart.CFrame*CFrame.new(math.random(-100,100)/100,math.random(100,200)/100,math.random(-100,100)/100))
end -- end of if hit is a basepart or model
hit.Parent = contents
end
end)]]></ProtectedString>
						<bool name="Disabled">false</bool>
						<Content name="LinkedSource"><null></null></Content>
						<token name="RunContext">0</token>
						<string name="ScriptGuid">{AFF6AA11-42E7-4575-B714-BE885A988A7E}
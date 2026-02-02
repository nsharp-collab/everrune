local root = pet.PrimaryPart
local bg = root:WaitForChild("BodyGyro")
local bp = root:WaitForChild("BodyPosition")

local char = pet.Parent
local charRoot = char.PrimaryPart

local oreBank = {
"Pumpkin",
}

local targetLocation,targetLook
local mode = "charLock"

local AttitudeCoroutine = coroutine.wrap(function()
while true do
mode = "charLock"
wait(240)
local rayDown = Ray.new(Vector3.new(root.Position.X+math.random(-15,15),root.Position.Y,root.Position.Z+math.random(-15,15)),Vector3.new(0,-1000,0))
local part,pos,mat,norm = workspace:FindPartOnRayWithWhitelist(rayDown,{workspace.Terrain})
mode = "locationLock"
targetLocation = pos
targetLook = CFrame.new(pos)
-- dig it up
wait(1)
pet.Head.Squeak:Play()
-- spawn a random ore
local oreName = oreBank[math.random(1,#oreBank)]
local newOre = game.ServerStorage.Items:FindFirstChild(oreName):Clone()
newOre.CFrame = root.CFrame*CFrame.new(0,1,0)
newOre.Parent = workspace
game.Debris:AddItem(newOre, 85)
end
end)
AttitudeCoroutine()


while true do
if mode == "charLock" then
targetLocation = (charRoot.CFrame*CFrame.new(-1,-2,5)).p
targetLook = charRoot.CFrame*CFrame.new(charRoot.CFrame.lookVector*1000)
end
bg.CFrame = targetLook
bp.Position = targetLocation
wait()
end




]]></ProtectedString>
						<bool name="Disabled">true</bool>
						<Content name="LinkedSource"><null></null></Content>
						<token name="RunContext">0</token>
						<string name="ScriptGuid">{92726111-E87C-4492-BE01-A6FA24054E4D}
local run = game:GetService("RunService")


-- char tags
local char = script.Parent
local root = char.PrimaryPart

local bg = root:WaitForChild("BodyGyro")
bg.CFrame = CFrame.new(root.CFrame.X,root.CFrame.Y,root.CFrame.Z)
local bv = root:WaitForChild("BodyVelocity")
local target = root:WaitForChild("Target")
-- the toggleables
local walkSpeed = 16
local aggroRange = 60
local stateData = {
["state"] = "Idle",
["targ"] = nil,
["lastOrder"] = 0,
}

local animController = char:WaitForChild("AnimationController")

local preAnims = {
--["Walk"] = "rbxassetid://1136173829",
["Walk"] = "http://www.roblox.com/asset/?id=507767714",
["Idle"] = "http://www.roblox.com/asset/?id=507766666",
["SwingTool"] = "rbxassetid://1262318281"
}
local anims = {}
for animName,animId in next,preAnims do
local anim = Instance.new("Animation")
anim.AnimationId = animId
game:GetService("ContentProvider"):PreloadAsync({anim})
anims[animName] = animController:LoadAnimation(anim)
end


local fallConstant = -2
run.Heartbeat:connect(function()
	local part,pos,norm,mat = workspace:FindPartOnRay(Ray.new(root.Position,Vector3.new(0,-2.8,0)),char)
	if target.Value then
	local facingCFrame = CFrame.new(Vector3.new(root.CFrame.X,pos.Y+3,root.CFrame.Z),CFrame.new(target.Value.CFrame.X,pos.Y+3,target.Value.CFrame.Z).p)
	bg.CFrame = facingCFrame
	else
	--bg.CFrame = CFrame.new(root.CFrame.X,pos.Y+3,root.CFrame.Z)
	end
	if target.Value then
		bv.P = 100000
		bv.Velocity = root.CFrame.lookVector*10
		if not part then
			bv.Velocity = bv.Velocity+Vector3.new(0,fallConstant,0)
			fallConstant = fallConstant-1
		else
			fallConstant = -2
		end
		if not anims["Walk"].IsPlaying then
		anims["Walk"]:Play()
		end
	else
		bv.P = 0
		bv.Velocity = Vector3.new(0,0,0)
		anims["Walk"]:Stop()
anims["Idle"]:Play()
	end
end)

while true do
	local thresh,nearest = 60,nil
	for _,player in next,game.Players:GetPlayers() do
		if player.Character and player.Character.PrimaryPart then
			local dist = (player.Character.PrimaryPart.Position-root.Position).magnitude
			if dist < thresh then
				thresh = dist
				nearest = player.Character.PrimaryPart
			end
		end		
	end
	if nearest then
if thresh < 5 then
anims["SwingTool"]:Play()
nearest.Parent.Humanoid:TakeDamage(8)
target.Value = nil
wait(1)
end
		target.Value = nearest
	else
		target.Value = nil
	end
wait(1)
end

]]></ProtectedString>
					<bool name="Disabled">false</bool>
					<Content name="LinkedSource"><null></null></Content>
					<token name="RunContext">0</token>
					<string name="ScriptGuid">{2D62F1D1-9240-4AE0-8A44-EDF80B2774E7}
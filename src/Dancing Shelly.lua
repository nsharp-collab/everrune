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

local fleshDamage = 20
local structureDamage = 10

local path = nil

for _,animObject in next,animations do
	anims[animObject.Name] = hum:LoadAnimation(animObject)
end

hum.ChillmanIdle:Play()

--health.Changed:connect(function()
--root.Hurt.Pitch = root.Hurt.OriginalPitch.Value+(math.random(-100,100)/100)
--root.Hurt:Play()
--end)
--
]]></ProtectedString>
					<bool name="Disabled">true</bool>
					<Content name="LinkedSource"><null></null></Content>
					<token name="RunContext">0</token>
					<string name="ScriptGuid">{CBD687AC-E1B9-405E-8372-5329A2E5CAEE}
local Rep = game:GetService("ReplicatedStorage")

local ItemData = require(Rep.Modules.ItemData)
local FL = require(Rep.Modules.FunctionLibrary)

function RegenRecurse(itemect)
	if itemect:FindFirstChild("NoRegen") then
		return
	end
	
	local oldParent = itemect.Parent
	local clone = itemect:Clone()
	itemect.AncestryChanged:connect(function()
		wait(ItemData[itemect.Name].regenDuration)
		if itemect then
			itemect:Destroy()
		end
		clone.Parent = oldParent
		RegenRecurse(clone)
	end)
end

local regenThings = FL.CombineArrays({
	workspace.Resources:GetChildren(),
	workspace.Critters:GetChildren()
})

for _,item in next,regenThings do
	local itemInfo = ItemData[item.Name]
	
	if itemInfo then -- if it has info
		
		if itemInfo.health then
			if not item:FindFirstChild("Health") then
				local health = Instance.new("IntValue")
				health.Name = "Health"
				health.Parent = item
			end
			item.Health.Value = itemInfo.health
		end
	
		if itemInfo.regenDuration then -- if it can be regenereated
			RegenRecurse(item)
		end
	end
end
]]></ProtectedString>
				<bool name="Disabled">false</bool>
				<Content name="LinkedSource"><null></null></Content>
				<token name="RunContext">0</token>
				<string name="ScriptGuid">{35A94913-F229-4D1B-BD66-69DECFAED5D0}
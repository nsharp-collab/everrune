local Rep = game:GetService("ReplicatedStorage")
local Run = game:GetService("RunService")
local DS = game:GetService("DataStoreService")
local MS = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")
local Physics = game:GetService("PhysicsService")
local CS = game:GetService("CollectionService")
local HTTP = game:GetService("HttpService")
local SS = game:GetService("ServerStorage")
local SSS = game:GetService("ServerScriptService")
local UIS = game:GetService("UserInputService")

-- modules
local GU = require(Rep.Modules.GameUtil)
local FL = require(Rep.Modules.FunctionLibrary)
local ItemData = require(Rep.Modules.ItemData)
local DefaultData = require(Rep.Modules.DefaultData)
local ColorData = require(Rep.Modules.ColorData)
-- tables and static vars
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera

_G.char,_G.hum,_G.root = nil,nil,nil
_G.alive = false
_G.SD = {} -- session data
_G.TD = DefaultData.ReturnTempData()
_G.anims = {}

local LMBDown,timeDepressed = false,0

-- cursor icons
local targetIcon = "rbxassetid://117431027"
local interactIcon = "http://www.roblox.com/asset/?id=455570287"
local defaultIcon = ""
local shiftLockIcon = "rbxasset://textures/MouseLockedCursor.png"

_G.mouseTarget = nil
_G.mouseIgnores = {}
_G.selectionBox = Rep.Misc.SelectionBox:Clone()
_G.selectionBox.Parent = workspace

local targetDetection = coroutine.wrap(function()
	while true do
	--	pcall(function()
		if _G.alive and _G.root then
			local length = 1000
			local origin = cam.CFrame.p
			local direction = (mouse.Hit.p-origin)
			local part,pos,norm,mat = GU.RayIgnoreList(
				cam.CFrame.p,
				direction*length,
				FL.CombineArrays({_G.char:GetChildren(),_G.mouseIgnores})
				)
			
			local distance = (_G.root.Position-pos).magnitude
			
			if part then
				if part:IsDescendantOf(workspace.ItemDrops) then
					_G.mouseTarget = part
					_G.selectionBox.Adornee = _G.mouseTarget
					
				else
					_G.mouseTarget = GU.GetFirstOrder(part)
					_G.selectionBox.Adornee = nil

				end
				
			else
				_G.selectionBox.Adornee = nil
				_G.mouseTarget = nil
			end
			
			mouse.Icon = ""
			
			if _G.mouseTarget then
				if _G.mouseTarget:FindFirstChild("Health") and _G.SD.equipped and (distance <= Rep.Constants.PickupRange.Value) then
					mouse.Icon = targetIcon
				end
				
				if _G.mouseTarget:IsDescendantOf(workspace.ItemDrops) and (distance <= Rep.Constants.PickupRange.Value) then
					mouse.Icon = interactIcon
					-- enable the information gui
				end
			end
		--	end)
		end
		Run.RenderStepped:wait()
	end
end)

targetDetection()

--Run.RenderStepped:connect(function(step)
--	if _G.mouseTarget then
--		mainGui.Panels
--	end
--end)

-- UIS functions
UIS.InputBegan:connect(function(input,gp)
	
--	InputObject.Delta
--	InputObject.KeyCode
--	InputObject.Position
--	InputObject.UserInputState

	if gp then return end -- if this input is outside of the game window, return nothing
	
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local num = input.KeyCode.Value - 48
		if (num >= 1) and (num <= 6) then -- they are trying to get a tool
			Rep.Relay.Tools.EquipTool:FireServer(num)
			if (_G.SD.equipped == num) or (not _G.SD.toolbar[num].name) then
				_G.SD.equipped = nil
			else
				_G.SD.equipped = num
			end
		end
		
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		local targetIsItem = (_G.mouseTarget and _G.mouseTarget:IsDescendantOf(workspace) and _G.mouseTarget:FindFirstChild("Pickup"))
		
		if targetIsItem and (GU.GetBagSpace() > 0) and (FL.DistanceBetween(_G.root.Position,_G.mouseTarget.Position) <= Rep.Constants.PickupRange.Value) then
			print("can totally pick up, bag space is",GU.GetBagSpace())
			local itemClone = _G.mouseTarget:Clone()
			itemClone.Anchored = true
			itemClone.CanCollide = false
			_G.mouseIgnores[#_G.mouseIgnores+1] = itemClone
			itemClone.Parent = workspace
			
			Rep.Relay.Interaction.Pickup:FireServer(_G.mouseTarget)
			Rep.Sounds.Bank:FindFirstChild(ItemData[_G.mouseTarget.Name].pickupSound or "Pickup")
			_G.mouseTarget:Destroy()
			
			GU.FlyItem(itemClone,itemClone.CFrame,_G.root)
			itemClone:Destroy()
			
		elseif _G.SD.equipped and (not targetIsItem) then
			-- if they have a melee tool equipped
			local currentTime = tick()
			LMBDown,timeDepressed = true,currentTime
			
			while LMBDown and (timeDepressed == currentTime) do
--				SwingTool()
				wait(ItemData[_G.SD.toolbar[_G.SD.equipped].name].weaponSuite.fireRate)
			end
			
		else

		end
		
	elseif input.UserInputType == Enum.UserInputType.Touch then
	--	print("A touchscreen input has started at",input.Position)
		
	elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
		
	end
end)

UIS.InputEnded:connect(function(input,gp)
	if gp then return end
	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		LMBDown = false
	end
end)

--UIS.TouchTapInWorld:connect(function(position, processedByUI)
--	if _G.alive and _G.root then
--		local direction = CFrame.new(_G.root.Position,position).lookVector
--		local hitTowards = _G.root.Position+direction
--	end
--end)


-- Event Connections
--local lastTargetHit = 0
--Rep.Relay.Interaction.HealthFeedback.OnClientEvent:connect(function(targetInfo,armorInfo)
--	mainGui.Panels.TargetHealth.Visible = true
--	
--	if targetInfo and (targetInfo.health > 0) then
--		lastTargetHit = tick()
--		
--		mainGui.Panels.TargetHealth.HealthBar.Size = UDim2.new(math.clamp(targetInfo.health/targetInfo.maxHealth,0,1),0,1,0)
--		mainGui.Panels.TargetHealth.HealthLabel.Text = math.floor(targetInfo.health+0.5)
--		mainGui.Panels.TargetHealth.NameLabel.Text = targetInfo.name
--	else
--		lastTargetHit = 0
--	end
--	if armorInfo and (armorInfo.remaining > 0) then
--		mainGui.Panels.TargetHealth.ArmorBar.Size = UDim2.new(math.clamp(armorInfo.remaining/armorInfo.total,0,1),0,1,0)
--		mainGui.Panels.TargetHealth.HealthLabel.Text = math.floor(armorInfo.remaining+0.5)
--		mainGui.Panels.TargetHealth.ArmorBar.Visible = true
--	else
--		mainGui.Panels.TargetHealth.ArmorBar.Visible = false
--	end
--		
--	spawn(function()
--		wait(3+(1/30))
--		if (tick()-lastTargetHit) > 3 then
--			mainGui.Panels.TargetHealth.Visible = false
--		end
--	end)
--	
--end)
]]></ProtectedString>
						<bool name="Disabled">true</bool>
						<Content name="LinkedSource"><null></null></Content>
						<token name="RunContext">0</token>
						<string name="ScriptGuid">{561E873B-B1AE-406B-8ADC-BC27424D8544}
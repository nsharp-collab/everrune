local hill = script.Parent
local itemData = require(game.ReplicatedStorage.Modules.ItemData)
local activeAnts = {}

function GetDictionaryLength(tab)
	local total = 0
	for _,v in next, tab do
		total = total + 1
	end
	return total
end


addAnt = coroutine.wrap(function()
	while wait(5) do
		if GetDictionaryLength(activeAnts) < 3 then
			local newAnt = game.ServerStorage.Creatures['Scavenger Ant']:Clone()
			newAnt:SetPrimaryPartCFrame(hill.PrimaryPart.CFrame*CFrame.new(0,5,0))
			newAnt.Parent = hill
			
			activeAnts[newAnt] = {
				["carrying"] = nil,
				["target"] = nil,
				["destination"] = newAnt.PrimaryPart.Position,
				["lastOrder"] = tick(),
				["lastScan"] = tick(),
				["anims"] = {},
			}
			
			for _,anim in next,game.ReplicatedStorage.NPCAnimations.Ant:GetChildren() do
				activeAnts[newAnt].anims[anim.Name] = newAnt:WaitForChild("Hum"):LoadAnimation(anim)
			end
			
			newAnt:WaitForChild'Health'.Changed:connect(function()
				newAnt.PrimaryPart.Hurt.Pitch = newAnt.PrimaryPart.Hurt.OriginalPitch.Value+(math.random(-100,100)/100)
				newAnt.PrimaryPart.Hurt:Play()
			end)
		
			newAnt.AncestryChanged:connect(function()
			activeAnts[newAnt] = nil
			end)
		end
		wait(55)
	end
end)

addAnt()

function Seeking(array, target)--Queen ant keeps track of her workers. ;)
	for i,v in pairs(array) do
		if v == target then
			return true
		end
	end
	return false
end

manageAnts = coroutine.wrap(function()
	while wait(1) do
		local seeking = {}
		for ant, antData in next,activeAnts do
			spawn(function()
				if ant and ant.PrimaryPart and ant:FindFirstChild'Hum' and ant.Hum.Health > 0 and ant:IsDescendantOf(workspace) then
					activeAnts[ant].lastScan = tick()
					-- scan for nearest Shelly
					if not activeAnts[ant].carrying then
						local nearestShelly,closestDist = nil,math.huge
						
						for _,creature in next, workspace.Critters:GetChildren() do
							if not Seeking(seeking, creature) and creature:FindFirstChild'HitShell' and itemData[creature.Name].abductable then
								
								local a, c = ant.PrimaryPart, creature.PrimaryPart
								
								if not c then
									c = creature:FindFirstChildOfClass'BasePart'
								end
									
								local dist = (c.Position-a.Position).magnitude
								
								if dist < closestDist then
									nearestShelly = creature
									closestDist = dist
								end
							end
						end
						
						if ant and nearestShelly then
							activeAnts[ant].destination = nearestShelly.PrimaryPart.Position
							activeAnts[ant].target = nearestShelly
							table.insert(seeking, nearestShelly)
							
							activeAnts[ant].target.AncestryChanged:connect(function()
								activeAnts[ant].target = nil
							end)
						end
						
					else	
						activeAnts[ant].destination  = hill.PrimaryPart.Position+Vector3.new(0,3,0)
					end
					
					if activeAnts[ant].destination then
						ant.Hum:MoveTo(activeAnts[ant].destination)
						if not activeAnts[ant].anims.AntWalk.IsPlaying then
							activeAnts[ant].anims.AntWalk:Play()
						end
					
						if antData.target and not antData.carrying then
							local dist = (ant.PrimaryPart.Position-activeAnts[ant].target.PrimaryPart.Position).magnitude
							if dist < 5 then
								-- let's get a new shelly
								local abductedShelly = game.ServerStorage.Misc["Abducted Shelly"]:Clone()
								antData.carrying = abductedShelly
								abductedShelly.Shell.Material = antData.target.Shell.Material
								abductedShelly.Shell.Color = antData.target.Shell.Color
								abductedShelly.ActualName.Value = antData.target.Name
								--game.ReplicatedStorage.Events.NPCAttack:Fire(antData.target,math.huge)
								antData.target:Destroy()
								abductedShelly.Parent = ant
								activeAnts[ant].anims.AntWalk:Stop()
								activeAnts[ant].anims.AntHold:Play()
								ant.PrimaryPart.Chatter:Play()
								ant.PrimaryPart.ShellyAbduct:Play()
								-- weld the shelly to the torso
								local weld = Instance.new("ManualWeld")
								weld.Parent = ant.PrimaryPart
								weld.Part0 = ant.PrimaryPart
								weld.Part1 = abductedShelly.PrimaryPart
								weld.C0 = CFrame.new(-.4,.4,-1.6)*CFrame.Angles(0,math.rad(90),0)
							end
						
						elseif antData.carrying then
							local dist = (ant.PrimaryPart.Position-activeAnts[ant].destination).magnitude
							if dist < 7 then
								ant.Hum:MoveTo(ant.PrimaryPart.Position)
								ant.PrimaryPart.Chatter:Play()
								activeAnts[ant].anims.AntHold:Stop()
								activeAnts[ant].anims.AntWalk:Stop()
								activeAnts[ant].carrying:Destroy()
								activeAnts[ant].carrying = nil
								activeAnts[ant].destination = nil
								activeAnts[ant].target = nil
							end
						end
					end
				end
			end)--Help prevent breaking and faster responding times for ants.
		end--Shouldn't error now though.
	end
end)

manageAnts()]]></ProtectedString>
						<bool name="Disabled">false</bool>
						<Content name="LinkedSource"><null></null></Content>
						<token name="RunContext">0</token>
						<string name="ScriptGuid">{B7571CE1-560B-4C22-ACF5-768B4076BBB9}
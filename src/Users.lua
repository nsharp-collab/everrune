-- SERVICES
local rep = game:GetService("ReplicatedStorage")
local HTTP = game:GetService("HttpService")
local ss = game:GetService("ServerStorage")
local debris = game:GetService("Debris")
local MS = game:GetService("MessagingService")
local TS = game:GetService("TeleportService")
local debris = game:GetService("Debris")
-- DATA STORES
local ds = game:GetService("DataStoreService")
local suspendList = ds:GetDataStore("suspendList")
-- MODULES
local ItemData = require(rep.Modules.ItemData)
local colorData = require(rep.Modules.ColorData)
local levelData = require(rep.Modules.LevelData)
local cmdList = require(script.Parent.List)
local users = require(script.Parent.Users)
local defaultData = require(script.Parent.DefaultData)

-- Config
local Webhook = script.Parent.Configuration.Webhook.Value
local safeTeleport = script.Parent.Configuration.SafeTeleport.Value
local yourGroup = script.Parent.Configuration.GroupID.Value -- default is Soybeen

local HasAuthority = function(player)
	return player:GetRankInGroup(yourGroup) >= 99 -- 99 is the rank level
	
end

-- template function
ADMIN_GU.TestFunction = function()
	print("TEST FUNCTION")
end



ADMIN_GU.PlaySound = function(soundName, inPlayer)
	if script.Parent:FindFirstChild("SFX") and script.Parent.SFX:FindFirstChild(soundName) then
		local newSound = script.Parent.SFX:FindFirstChild(soundName):Clone()
		if inPlayer ~= nil then
			newSound.Parent = inPlayer
		else
			newSound.Parent = workspace
		end

		newSound:Play()
		debris:AddItem(newSound, newSound.TimeLength)
	else
		warn("sound folder is gone!")
	end
end

ADMIN_GU.AddPart = function(partName, duration, inPlayer)
	if script.Parent:FindFirstChild("Parts") and script.Parent.Parts:FindFirstChild(partName) then
		local newPart = script.Parent.Parts:FindFirstChild(partName):Clone()
		if inPlayer ~= nil then
			newPart.Parent = inPlayer.Character
			newPart.Position = inPlayer.Character.PrimaryPart.Position
		else
			newPart.Parent = workspace
		end

		debris:AddItem(newPart, duration)
	else
		warn("Parts folder is gone!")
	end
end

ADMIN_GU.RemovePart = function(partName, model)
	if model:FindFirstChild(partName) then
		model:FindFirstChild(partName):Destroy()
	else
		warn("Could not find "..partName)
	end
end

ADMIN_GU.FindItem = function(itemName)
	local foundItem = false
	if ItemData[itemName] then
		foundItem = true
	else
		-- check if the string is lower
		for this_itemName, itemInfo in next, ItemData do
			if string.lower(this_itemName) == string.lower(itemName) then
				print("found lowercase item")
				foundItem = true
				itemName = this_itemName
				break
			end
			-- upper case???
			if string.upper(this_itemName) == string.upper(itemName) then
				print("found uppercase item")
				foundItem = true
				itemName = this_itemName
			end
		end
	end
	return foundItem,itemName
end

ADMIN_GU.HasItem = function(player,itemName)
	for key,v in next,_G.sessionData[player.UserId].inventory do
		if v.name == itemName then
			return key
		end
	end
	return false
end

ADMIN_GU.HasItemInToolBar = function(player,itemName)
	for key,v in next,_G.sessionData[player.UserId].toolbar do
		if v.name == itemName then
			return key
		end
	end
	return false
end


ADMIN_GU.HasItemInEquipment = function(player,itemName)
	for key,v in next,_G.sessionData[player.UserId].armor do
		if v == itemName then
			--print(key.." and "..v)
			return v
		end
	end
	return false
end

ADMIN_GU.CleanInventory = function(player)
	local tab = _G.sessionData[player.UserId].inventory
	local newTab = {}
	for key, itemInfo in next, tab do
		if itemInfo.name and itemInfo.name ~= "none" and ItemData[itemInfo.name] then
			if itemInfo.quantity then
				if itemInfo.quantity > 0 then
					newTab[#newTab + 1] = itemInfo
				end
			else
				newTab[#newTab + 1] = itemInfo
			end
		else
			warn("this thing didn't have a name for some reason")
		end
	end -- end of loop
	_G.sessionData[player.UserId].inventory = newTab
	return
end

ADMIN_GU.ReportCMD = function(player,response,hide)
	if hide == nil then
		hide = false
	end
	if not hide then
		-- notify the player's cmd
		rep.Events.Notify:FireClient(player,response, colorData.grey200, 6)
	end

	if Webhook ~= "" then -- server report
		local Key = Webhook
		local HookData = HTTP:JSONEncode({content = "```" ..player.Name.." ".. response.."```", username = "Activity [" .. tostring(math.random(10000, 99999)) .. "]"})
		HTTP:postAsync(Key, HookData)
		--else
		--	warn("ERR: Webhook does not have a value")
	end
end

ADMIN_GU.KickPlayer = function(player,reason)
	if game.Players:FindFirstChild(player.Name) then
		player:kick(reason or "Unknown Reason...")
	end
end

ADMIN_GU.KillPlayer = function(player)
	if game.Players:FindFirstChild(player) then
		game.Players:FindFirstChild(player).Character.Humanoid.Health = 0
	end
end
ADMIN_GU.FreezeCMD = function(plr)
	if not plr.Character.HumanoidRootPart.Anchored then
		plr.Character.HumanoidRootPart.Anchored = true
		ADMIN_GU.AddPart("PartFreeze", math.huge, plr)
		ADMIN_GU.ReportCMD(plr,"Freezed")
	else
		plr.Character.HumanoidRootPart.Anchored = false
		ADMIN_GU.RemovePart("PartFreeze", plr.Character)
		ADMIN_GU.ReportCMD(plr,"Unfreezed")
	end
end


ADMIN_GU.GiveItemToPlayer = function(itemName,player,amount)
	-- check if the object is from itemdata
	--	if string.lower(itemName) 
	local keyFound, newItemName = ADMIN_GU.FindItem(itemName)
	if  keyFound then
		local hasKey = ADMIN_GU.HasItem(player,newItemName)

		if hasKey then

			if not ItemData[_G.sessionData[player.UserId].inventory[hasKey].name].toolType then
				_G.sessionData[player.UserId].inventory[hasKey].quantity = _G.sessionData[player.UserId].inventory[hasKey].quantity +(amount or 1)				
			else -- is tool
				-- add how much they wanted
				for newAmount = 1, amount, 1 do
					_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory+1] = {name = newItemName, quantity = 1}
				end

			end

		else
			if not ItemData[newItemName].toolType then
				_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory+1] = {name = newItemName,quantity = (amount or 1)}
			else
				-- add how much they wanted
				for newAmount = 1, amount, 1 do
					_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory+1] = {name = newItemName, quantity = 1}
				end
			end
		end 
	end

	rep.Events.UpdateData:FireClient(player,_G.sessionData[player.UserId],{{"DrawInventory"},{"UpdateStats"}})
	return keyFound
end

ADMIN_GU.ForceUnequip = function(player)
	for _, v in next, player.Character:GetChildren() do
		if ItemData[v.Name] and ItemData[v.Name].itemType == "tool" then
			v:Destroy()
			_G.sessionData[player.UserId].equipped = nil
			rep.Events.UpdateData:FireClient(player,_G.sessionData[player.UserId],{{"SortToolbar"}})
		end
	end
end


ADMIN_GU.RemoveItemFromPlayer = function(itemName,player,amount)
	local keyFound, newItemName = ADMIN_GU.FindItem(itemName)
	local hasKey = nil
	if keyFound then
		hasKey = ADMIN_GU.HasItem(player,newItemName)
	end

	-- check system

	if hasKey then
		if not ItemData[newItemName].toolType then
			_G.sessionData[player.UserId].inventory[hasKey].quantity -= (amount or 1)
		else
			-- if its a tool
			_G.sessionData[player.UserId].inventory[hasKey] = nil
		end
	else
		-- check in toolbar
		hasKey = ADMIN_GU.HasItemInToolBar(player,newItemName)
		if hasKey then
			_G.sessionData[player.UserId].toolbar[hasKey] = {}
			ADMIN_GU.ForceUnequip(player)
			-- do loop for extra
			if _G.sessionData[player.UserId].inventory[hasKey] then
				_G.sessionData[player.UserId].inventory[hasKey].quantity -= (amount or 1)
			end
		end
	end 
	ADMIN_GU.CleanInventory(player)
	rep.Events.UpdateData:FireClient(player,_G.sessionData[player.UserId],{{"DrawInventory"},{"UpdateStats"}})
	return hasKey
end

ADMIN_GU.GetDictionaryLength = function(tab)
	local count = 0
	for _,v in next,tab do
		count = count+1 
	end
	return count
end

ADMIN_GU.ResetStats = function(player)
	rep.Events.Notify:FireClient(player,"RESETING YOUR DATA!!!", colorData.badRed, 3)
	print("RESETING "..player.Name.."'s Data")
	_G.sessionData[player.UserId] = defaultData.ReturnBlankSlate()
	for _,v in next,_G.sessionData[player.UserId].toolbar do
		if ADMIN_GU.GetDictionaryLength(v) >0 then
			v.lastSwing = 0
		end
	end
	wait(1)
	player.Character.Humanoid.Health = 0
	print("succesfully reset data")
	rep.Events.Notify:FireClient(player,"Data has been wiped!", colorData.badRed, 6)
	--ADMIN_GU.KickPlayer(player, "data reset!")
end


ADMIN_GU.ClearInventory = function(player)
	_G.sessionData[player.UserId].inventory = {}
	rep.Events.UpdateData:FireClient(player,_G.sessionData[player.UserId],{{"DrawInventory"},{"UpdateStats"}})
	return
end

ADMIN_GU.GiveEssence = function(player, amount)
	_G.sessionData[player.UserId].essence = _G.sessionData[player.UserId].essence + tonumber(amount)

	if _G.sessionData[player.UserId].essence >= (levelData[_G.sessionData[player.UserId].level] or math.huge) then

		local leftover = _G.sessionData[player.UserId].essence - levelData[_G.sessionData[player.UserId].level]
		_G.sessionData[player.UserId].essence = leftover
		_G.sessionData[player.UserId].level = _G.sessionData[player.UserId].level + 1
		
		
		
		

		rep.Events.Notify:FireClient(player, "You leveled up!", colorData.essenceYellow, 5)
		ADMIN_GU.GiveEssence(player, 0)

		local newItemList = {}
		for itemName, itemInfo in next, ItemData do
			if itemInfo.craftLevel and itemInfo.craftLevel == _G.sessionData[player.UserId].level then
				newItemList[#newItemList + 1] = itemName
			end
		end
		if #newItemList > 0 then
			local messagio = ""
			for i, v in next, newItemList do
				if i ~= #newItemList then
					messagio = messagio..v..", "
				else
					messagio = messagio..v 
				end
			end

			rep.Events.Toast:FireClient(player,
				{
					title = "NEW RECIPES!",
					message = messagio,
					color = colorData.essenceYellow,
					image = "rbxassetid://1390834073",
					duration = 8
				})
			rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {{"UpdateStats"},{"DrawCraftMenu"}})
		end
	end
	rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {{"UpdateStats"}})

end
-- adds mojo pet or thing
ADMIN_GU.AddMojoPart = function(player, thingName)
	if thingName == "Sparkles" then
		local sparkle = rep.Particles.GodSparkle:Clone()
		sparkle.Parent = player.Character.PrimaryPart
	else -- is a pet
		local newPet = ss.Pets:FindFirstChild(thingName):Clone()
		newPet.Parent = player.Character
		newPet.PetMover.Disabled = false
	end
end

ADMIN_GU.UpdateData = function(player, update, amount)
	if player then		-- im so sorry for these if statments
		if update == "addcoins" then
			_G.sessionData[player.UserId].coins += tonumber(amount)
		elseif update == "setcoins" then
			_G.sessionData[player.UserId].coins = tonumber(amount)
		elseif update == "addmelons" then
				_G.sessionData[player.UserId].melons += tonumber(amount)
			elseif update == "setmelons" then
				_G.sessionData[player.UserId].melons = tonumber(amount)
		elseif update == "addgems" then
			_G.sessionData[player.UserId].gems += tonumber(amount)
		elseif update == "setgems" then
			_G.sessionData[player.UserId].gems = tonumber(amount)
		elseif update == "setmojo" then
			_G.sessionData[player.UserId].mojo = tonumber(amount)
		elseif update == "addmojo" then
			_G.sessionData[player.UserId].mojo += tonumber(amount)
		elseif update == "addexp" then
			ADMIN_GU.GiveEssence(player, amount)
		elseif update == "setexp" then
			_G.sessionData[player.UserId].essence = tonumber(amount)
			ADMIN_GU.GiveEssence(player, 0)
		elseif update == "setlvl" then
			_G.sessionData[player.UserId].level = tonumber(amount)
			_G.sessionData[player.UserId].essence = 0
			ADMIN_GU.GiveEssence(player, 0)
		elseif update == "customrecipe" then -- meatmaker, magnetite stick, etc
			_G.sessionData[player.UserId].customRecipes[amount] = true
		elseif update == "cosmetic" then
			if ADMIN_GU.FindItem(amount) then
				_G.sessionData[player.UserId].ownedCosmetics[amount] = true
				rep.Events.UpdateData:FireClient(player,_G.sessionData[player.UserId],{{"UpdateCosmetics"}})
			end
		elseif update == "delete" then
			_G.sessionData[player.UserId].ownedCosmetics[amount] = nil
			rep.Events.UpdateData:FireClient(player,_G.sessionData[player.UserId],{{"UpdateCosmetics"}})
		elseif update == "removerecipe" then
			_G.sessionData[player.UserId].customRecipes[amount] = nil
		elseif update == "setspell" then
			if ADMIN_GU.FindItem(amount) then
				_G.sessionData[player.UserId].spell = amount
			end
		elseif update == "mojo" then
			if ADMIN_GU.FindItem(amount) then
				_G.sessionData[player.UserId].mojoItems[amount] = true
				ADMIN_GU.AddMojoPart(player, amount)
				rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {{"UpdateMojoMenu"}})
			end
		elseif update == "setvoodoo" then
			_G.sessionData[player.UserId].voodoo = amount
		end
		rep.Events.UpdateData:FireClient(player,_G.sessionData[player.UserId],{{"UpdateStats"}})
	end
end

ADMIN_GU.TeleportSafe = function(player, location)
	local teleportLocation = Instance.new("CFrameValue")
	teleportLocation.Value = location
	teleportLocation.Name = "TeleportCFrame"
	teleportLocation.Parent = player

	if not safeTeleport then
		warn("safe teleport is off")
		player.Character:SetPrimaryPartCFrame(location)
	end

end

-- Needs Organising in V2
ADMIN_GU.FindInCMDLIST = function (search)
	for name, data in next, cmdList do
		if data.cmdType == search then
			search = name
		end
	end
	return search
end
ADMIN_GU.createList = function(plr, list, listType)
	if listType == "itemsOnly" then
		for itemName, data in next, ItemData do 
			local daTemp = {
				name = itemName,
				image = data.image or 
					"http://www.roblox.com/Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=420&ht=420&aid=4823036",
				itemType = data.itemType
			}
			-- Search ig, its kinda broken, Needs fix in V2
			if daTemp.itemType == "tool" or 
				daTemp.itemType == "object" or
				daTemp.itemType == "armor" or 
				daTemp.itemType == "dropChest"
			then
				list[#list+1] = daTemp
			end

		end
	elseif listType == "plrinv" then
		for itemName, data in next, _G.sessionData[plr.UserId].inventory do
			local daTemp = {
				name = data.name,
				image = ItemData[data.name].image or 
					"http://www.roblox.com/Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=420&ht=420&aid=4823036",
				itemType = data.itemType
			}
			list[#list+1] = daTemp
		end
		-- get tools
		for key, data in next, _G.sessionData[plr.UserId].toolbar do
			if data.name == nil then
				continue
			end
			local daTemp = {
				name = data.name,
				image = ItemData[data.name].image or 
					"http://www.roblox.com/Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=420&ht=420&aid=4823036",
			}
			list[#list+1] = daTemp
		end

	elseif listType == "players" then
		for i,v in next, game.Players:GetChildren() do
			local userId = v.UserId
			local thumbType = Enum.ThumbnailType.HeadShot
			local thumbSize = Enum.ThumbnailSize.Size420x420
			local content, isReady = 
				game.Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
			local plrTemp = {
				name = v.Name,
				image = (content or isReady) or 
					"http://www.roblox.com/Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=420&ht=420&aid=4823036"
			}
			list[#list + 1] = plrTemp
		end
	elseif listType == "cosmeticlist" then
		for itemName, data in next, ItemData do 
			local daTemp = {
				name = itemName,
				image = data.image or 
					"http://www.roblox.com/Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=420&ht=420&aid=4823036",
				cosmetic = data.cosmetic or  data.melonscosmetic or nil
			}
			-- search for not owned hats
			if daTemp.cosmetic and 
				not _G.sessionData[plr.UserId].ownedCosmetics[itemName] then
				list[#list+1] = daTemp
			end
		end
	elseif listType == "voodoospells" then
		for itemName, data in next, ItemData do 
			local daTemp = {
				name = itemName,
				image = data.image or 
					"http://www.roblox.com/Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=420&ht=420&aid=4823036",
				voodooSpell = data.voodooSpell or nil
			}
			-- search for voodoo spells
			if daTemp.voodooSpell then
				list[#list+1] = daTemp
			end
		end
	elseif listType == "mojolist" then
		for itemName, data in next, ItemData do 
			local daTemp = {
				name = itemName,
				image = data.image or 
					"http://www.roblox.com/Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=420&ht=420&aid=4823036",
				mojoCost = data.mojoCost or nil
			}
			-- search for mojo that you do not have
			if daTemp.mojoCost and 
				not _G.sessionData[plr.UserId].mojoItems[itemName] then
				list[#list+1] = daTemp
			end
		end
	end
	return list
end

ADMIN_GU.showInfo = function(plr, name, data, argument)
	local warrant = HasAuthority(plr) or users.CheckID(plr) or ADMIN_GU.GetOwner(plr)

	local itemGui = plr.PlayerGui.CMDGui.ItemFrame
	local itemInfo = plr.PlayerGui.CMDGui.ItemFrame.ItemInfo
	itemInfo.ImageButton.Image = data.image or
		"http://www.roblox.com/Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=420&ht=420&aid=4823036"
	itemInfo.Title.Text = name
	itemInfo.Visible = true

	itemInfo.CloseButton.MouseButton1Down:Connect(function()
		local daPlr = game.Players:FindFirstChild(itemGui.Title.Text)
		if argument == "give" then
			ADMIN_GU.GiveItemToPlayer(name, daPlr, tonumber(itemInfo.Change.Value))
			ADMIN_GU.ReportCMD(plr, "Gave out "..tonumber(itemInfo.Change.Value).." "..name.." to "..daPlr.Name)
		elseif argument == "remove" then
			ADMIN_GU.RemoveItemFromPlayer(name, daPlr, tonumber(itemInfo.Change.Value))
			ADMIN_GU.ReportCMD(plr, "Removed "..tonumber(itemInfo.Change.Value).." "..name.." from "..daPlr.Name)
		elseif argument == "kick" then
			ADMIN_GU.KickPlayer(daPlr, itemInfo.Change.Value)
			ADMIN_GU.ReportCMD(plr, daPlr.Name.." is kicked for "..itemInfo.Change.Value)
		elseif argument == "suspend" then
			if daPlr.Name == plr.Name then
				rep.Events.Notify:FireClient(plr, "cannot suspend yourself", colorData.badRed, 4)
				print("cannot suspend yourself")
				plr.PlayerGui.CMDGui:FindFirstChild("ItemFrame"):Destroy()
				return
			end
			if warrant and ((not HasAuthority(daPlr) or users.CheckID(daPlr) or ADMIN_GU.GetOwner(daPlr))) then
				suspendList:SetAsync(daPlr.UserId,os.time())
				daPlr:Kick("You are suspended by a admin. Your suspend ends on "..
					tostring(os.date("%c"))..".")
				ADMIN_GU.ReportCMD(plr, daPlr.Name.." is suspended for "..itemInfo.Change.Value)
			else
				ADMIN_GU.ReportCMD(plr, "CANNOT SUSPEND "..daPlr.Name)
			end
		else
			ADMIN_GU.UpdateData(daPlr, argument, itemInfo.Change.Value)
			ADMIN_GU.ReportCMD(plr, daPlr.Name.." "..argument.." "..itemInfo.Change.Value)
		end
		plr.PlayerGui.CMDGui:FindFirstChild("ItemFrame"):Destroy()
	end)

end

ADMIN_GU.sendGui = function(plr, list, action, argument)
	if plr.PlayerGui.CMDGui:FindFirstChild("ItemFrame") then
		plr.PlayerGui.CMDGui:FindFirstChild("ItemFrame"):Destroy()
	end
	local itemGui = script.Parent.ItemFrame:Clone()
	itemGui.Parent = plr.PlayerGui.CMDGui
	if argument then
		itemGui.Title.Text = argument
	end
	-- EVENT CODE
	itemGui.SendChange.OnServerEvent:Connect(function(p,n,c)
		if n == "change" then
			itemGui.ItemInfo.Change.Value = c
		end
	end)
	-- setup image buttons
	for name,data in next, list do 
		local daName = data.name or name

		local newFrame = itemGui.Templates.ItemFrame:Clone()
		newFrame.Parent = itemGui.List
		newFrame.Title.Text = daName
		newFrame.Name = daName
		newFrame.ImageButton.Image = data.image or
			"http://www.roblox.com/Game/Tools/ThumbnailAsset.ashx?fmt=png&wd=420&ht=420&aid=4823036"

		newFrame.ImageButton.MouseButton1Down:Connect(function()
			daName = newFrame.Name -- forgot to give proper value

			if action == "chooseplr" then
				local justItems = {}
				local cmdName = ADMIN_GU.FindInCMDLIST(argument)

				if cmdList[cmdName].quick then
					itemGui.Title.Text = daName
					ADMIN_GU.showInfo(plr, daName, data, argument)
					return
				elseif cmdList[cmdName].createlist then
					ADMIN_GU.createList(plr, justItems,cmdList[cmdName].createlist)
				end
				-- instant
				if argument == "kill" then
					ADMIN_GU.KillPlayer(daName)
					local t = game.Players:FindFirstChild(daName)
					ADMIN_GU.ReportCMD(t, "ded")
					plr.PlayerGui.CMDGui:Destroy()
					return
				elseif argument == "freeze" then
					local t = game.Players:FindFirstChild(daName)
					ADMIN_GU.FreezeCMD(t)
					plr.PlayerGui.CMDGui:Destroy()
					return
				elseif argument == "reset" then
					local t = game.Players:FindFirstChild(daName)
					ADMIN_GU.ResetStats(t)
					ADMIN_GU.ReportCMD(plr, "Did reset on "..t.Name)
					return
				elseif argument == "clear" then
					local t = game.Players:FindFirstChild(daName)
					ADMIN_GU.ClearInventory(t)
					ADMIN_GU.ReportCMD(plr, "Cleared "..t.Name)
					return
				end

				ADMIN_GU.sendGui(plr, justItems, argument, daName)
			elseif action == "tp" then
				local firstGuy = game.Players:FindFirstChild(argument)
				local otherGuy = game.Players:FindFirstChild(daName)
				ADMIN_GU.TeleportSafe(firstGuy, otherGuy.Character.HumanoidRootPart.CFrame)
				ADMIN_GU.ReportCMD(plr,"Made "..firstGuy.Name.." TP to "..otherGuy.Name)
				plr.PlayerGui.CMDGui:Destroy()
			elseif action == "cosmetic" then
				local firstGuy = game.Players:FindFirstChild(argument)
				ADMIN_GU.UpdateData(firstGuy, "cosmetic", daName)
				ADMIN_GU.ReportCMD(plr,firstGuy.Name.." Received "..daName)
				plr.PlayerGui.CMDGui:Destroy()
			elseif action == "setspell" then
				local firstGuy = game.Players:FindFirstChild(argument)
				ADMIN_GU.UpdateData(firstGuy, "setspell", daName)
				ADMIN_GU.ReportCMD(plr,firstGuy.Name.."'s spell changed to "..daName)
				plr.PlayerGui.CMDGui:Destroy()
			elseif action == "mojo" then
				local firstGuy = game.Players:FindFirstChild(argument)
				ADMIN_GU.UpdateData(firstGuy, "mojo", daName)
				ADMIN_GU.ReportCMD(plr,firstGuy.Name.." Received mojo: "..daName)
				plr.PlayerGui.CMDGui:Destroy()
			else -- give, remove
				ADMIN_GU.showInfo(plr, daName, data, action)

			end
		end)

		newFrame.Visible = true
	end
	itemGui.Visible = true
end

ADMIN_GU.createGui = function(plr)
	local cmdgui = script.Parent.CMDGui:Clone()
	local cmdFrame = cmdgui.Cmds
	local list = cmdFrame.List
	local annouceFrame = cmdFrame.Annoucement

	cmdFrame.CloseButton.MouseButton1Down:Connect(function()
		cmdgui:Destroy()
	end)

	cmdFrame.Parent.UpdateText.OnServerEvent:Connect(function(p,c)
		cmdFrame.Parent.Annouce.Value = c
	end)

	annouceFrame.ConfirmButton.MouseButton1Down:Connect(function()
		MS:PublishAsync("announceAdmin", cmdFrame.Parent.Annouce.Value)
		ADMIN_GU.ReportCMD(plr, "ANNOUCEMENT: "..cmdFrame.Parent.Annouce.Value, true)
		ADMIN_GU.PlaySound("TribeSound")
		cmdgui:Destroy()
	end)
	for name,data in next, cmdList do 
		local newFrame = cmdFrame.Templates.Frame:Clone()
		newFrame.Name = data.cmdType
		newFrame.Parent = list
		newFrame.Header.Text = name
		newFrame.Note.Text = data.desc
		newFrame.LayoutOrder = data.order

		if data.noBtn then
			newFrame.ConfirmButton.Visible = false
		end

		if data.plrGui then
			newFrame.ConfirmButton.MouseButton1Down:Connect(function()
				local players = {}
				ADMIN_GU.createList(plr, players, "players")
				ADMIN_GU.sendGui(plr, players, "chooseplr", data.cmdType)
			end)
		end

		if data.startup then
			newFrame.ConfirmButton.MouseButton1Down:Connect(function()
				if data.cmdType == "shutdownall" then
					MS:PublishAsync("shutdownAdmin")
					ADMIN_GU.ReportCMD(plr, "Shutdown ALL!", true)
					ADMIN_GU.PlaySound("WarHorn")
				else
					for _, player in next, game.Players:GetPlayers() do
						player:Kick("This server has shutdown!")
					end
					ADMIN_GU.ReportCMD(plr, "Shutdown one server!")

				end
				cmdgui:Destroy()
			end)
		end
		newFrame.Visible = true

	end
	cmdgui.Parent = plr.PlayerGui
end


return ADMIN_GU
-- Im tired after making this]]></ProtectedString>
					<string name="ScriptGuid">{1f0ac175-2204-402f-9400-f51ce8767ab4}
local Rep = game:GetService("ReplicatedStorage")
local ss = game:GetService("ServerStorage")
local debris = game:GetService("Debris")
local tweenService = game:GetService("TweenService")
local market = game:GetService("MarketplaceService")
local http = game:GetService("HttpService")

local GU = require(Rep.Modules.GameUtil)
local FL = require(Rep.Modules.FunctionLibrary)

local ds = game:GetService'DataStoreService'
local PlayerData = ds:GetDataStore'PlayerData10'

if game.PlaceId == 2626094174 then
	PlayerData = ds:GetDataStore'BugTestData1'
end

local banData = ds:GetDataStore("BanData")

local physics = game:GetService("PhysicsService")
physics:CreateCollisionGroup("Draggers")

physics:CreateCollisionGroup("Terrain")
physics:SetPartCollisionGroup(workspace.Terrain, "Terrain")

physics:CollisionGroupSetCollidable("Draggers", "Terrain", true)
physics:CollisionGroupSetCollidable("Default", "Terrain", true)

physics:CollisionGroupSetCollidable("Default", "Draggers", false)

physics:CreateCollisionGroup("Players")
physics:CollisionGroupSetCollidable("Players", "Players", false)
physics:CollisionGroupSetCollidable("Players", "Draggers", false)

local previousCollisionGroups = {}

local function setCollisionGroup(object)
	if object:IsA("BasePart") then
		previousCollisionGroups[object] = object.CollisionGroupId
		physics:SetPartCollisionGroup(object, "Players")
	end
end
 
local function setCollisionGroupRecursive(object)
	setCollisionGroup(object)
	for _, child in ipairs(object:GetChildren()) do
		setCollisionGroupRecursive(child)
	end
end

local function resetCollisionGroup(object)
	local previousCollisionGroupId = previousCollisionGroups[object]
	if not previousCollisionGroupId then
		return
	end	
 
	local previousCollisionGroupName = physics:GetCollisionGroupName(previousCollisionGroupId)
	if not previousCollisionGroupName then
		return
	end
 
	physics:SetPartCollisionGroup(object, previousCollisionGroupName)
	previousCollisionGroups[object] = nil
end

function lerp()
	return function(a, b, t)
		return a + (b - a) * t
	end
end

local defaultData = require(Rep.Modules.DefaultData)
if game.PlaceId == 2626094174 then
	defaultData = require(Rep.Modules.BugTesterDefaultData)
end

local ItemData = require(Rep.Modules.ItemData)
local ColorData = require(Rep.Modules.ColorData)
local levelData = require(Rep.Modules.LevelData)
local cosmeticData  = require(Rep.Modules.CosmeticData)
local patchNotes = require(Rep.Modules.PatchNotes)
local SoundModule = require(Rep.Modules.SoundModule)
local DataRepair1 = require(Rep.Modules.DataRepair1)

local gameClosing = false

local salesData = {
	chests = {
		["153549063"] = "Pleb Chest",
		["153549248"] = "Good Chest",
		["153549363"] = "Great Chest",
		["153549511"] = "OMG Chest",
		["153549712"] = "Essence Chest",
	},

	coins = {
		["155936601"] = 200,
		["155936804"] = 500,
		["155936991"] = 1000,
		["155937159"] = 3000,
		["155937326"] = 10000,
		["155937456"] = 50000,
	}
}

local lastTotemTimers = {
	Yellow = 0,
	Green = 0,
	Red = 0,
	Violet = 0,
	Blue = 0,
	Grey = 0,
	Teal = 0,
}

local tradeSerializer = 1
_G.trades = {
--{trader = playerName,
--giveName = "Log",
--giveQuantity = 5,
--getCoins = 5, -- in coins
--tradeId = 1,
--},
}

local teleImmunity = {}
local tempImmunity = {}

function GetXDifference(p1, p2)
	return (Vector3.new(p1.x, 0, p1.z) - Vector3.new(p2.x, 0, p2.z)).magnitude
end

function TeleportPlayer(player, location)
	local teleportLocation = Instance.new("CFrameValue")
	teleportLocation.Value = location
	teleportLocation.Name = "TeleportCFrame"
	teleportLocation.Parent = player
--player.Character:SetPrimaryPartCFrame(location)
end


--[[ for testing damage in studio, run this command to bring 2 players together
	function TeleportPlayer(player, location)
	local teleportLocation = Instance.new("CFrameValue")
	teleportLocation.Value = location
	teleportLocation.Name = "TeleportCFrame"
	teleportLocation.Parent = player
	--player.Character:SetPrimaryPartCFrame(location)
	end TeleportPlayer(game.Players.Player1,workspace.Player2.PrimaryPart.CFrame)
	
--]]
function IsDescendantOfPlayer(part)
	for _, player in next, game.Players:GetPlayers() do
		if player.Character then
			if part:IsDescendantOf(player.Character) then
				return true
			end
		end
	end
	return false
end

local function typeValid(data)
	return type(data) ~= 'userdata', typeof(data)
end

local function weldBetween(a, b)
    --Make a new Weld and Parent it to a.
	local weld = Instance.new("ManualWeld", a)
	weld.Part0 = a
	weld.Part1 = b
    --Get the CFrame of b relative to a.
	weld.C0 = a.CFrame:inverse() * b.CFrame
    --Return the reference to the weld so that you can change it later.
	return weld
end

local function scanValidity(tbl, passed, path)
	if type(tbl) ~= 'table' then
		return scanValidity({
			input = tbl
		}, {}, {})
	end
	passed, path = passed or {}, path or {
		'input'
	}
	passed[tbl] = true
	local tblType
	do
		local key, value = next(tbl)
		if type(key) == 'number' then
			tblType = 'Array'
		else
			tblType = 'Dictionary'
		end
	end
	local last = 0
	for key, value in next, tbl do
		path[#path + 1] = tostring(key)
		if type(key) == 'number' then
			if tblType == 'Dictionary' then
				return false, path, 'Mixed Array/Dictionary'
			elseif key % 1 ~= 0 then  -- if not an integer
				return false, path, 'Non-integer index'
			elseif key == math.huge or key == -math.huge then
				return false, path, '(-)Infinity index'
			end
		elseif type(key) ~= 'string' then
			return false, path, 'Non-string key', typeof(key)
		elseif tblType == 'Array' then
			return false, path, 'Mixed Array/Dictionary'
		end
		if tblType == 'Array' then
			if last ~= key - 1 then
				return false, path, 'Array with non-sequential indexes'
			end
			last = key
		end
		local isTypeValid, valueType = typeValid(value)
		if not isTypeValid then
			return false, path, 'Invalid type', valueType
		end
		if type(value) == 'table' then
			if passed[value] then
				return false, path, 'Cyclic'
			end
			local isValid, keyPath, reason, extra = scanValidity(value, passed, path)
			if not isValid then
				return isValid, keyPath, reason, extra
			end
		end
		path[#path] = nil
	end
	passed[tbl] = nil
	return true
end

local function getStringPath(path)
	return table.concat(path, '.')
end

local function warnIfInvalid(input)
	local isValid, keyPath, reason, extra = scanValidity(input)
	if not isValid then
		if extra then
			warn('Invalid at '..getStringPath(keyPath)..' because: '..reason..' ('..tostring(extra)..')')
		else
			warn('Invalid at '..getStringPath(keyPath)..' because: '..reason)
		end
	else
	end
end


local cyclicTest = {
	a = {
		{
			b = {}
		}
	}
}

cyclicTest.a[1].b[1] = cyclicTest

local testCases = {
	true,
	'hello',
	5,
	5.7,  -- all valid
	CFrame.new(),  -- invalid: type
	{
		true,
		'hello',
		5,
		5.7
	},  -- valid array
	{
		a = true,
		b = 'hello',
		c = 5,
		d = 5.7
	},  -- valid dictionary
	{
		a = true,
		'hello',
		5,
		5.7
	},  -- invalid: array/dictionary mix
	{
		CFrame.new()
	},  -- invalid: type in array
	{
		in1 = {
			{
				in2 = {
					a = true,
					'hello'
				}
			},
			5
		},
		in3 = {}
	},  -- invalid: array/dictionary mix deep in path
	{
		[5.7] = 'hello'
	},  -- invalid: decimal index
	{
		[{}] = 'hello'
	},  -- invalid: non-string key
	{
		[1] = 'hello',
		[3] = 'WRONG',
	},  -- invalid: non-sequential array
	cyclicTest,  -- invalid: cyclic
	{
		[math.huge] = 'hello'
	},  -- invalid: infinity index
}

-- breathe life into the animals
--for _, animal in next, workspace.Critters:GetChildren() do
--	local soul = game.ServerStorage.AnimalCode:FindFirstChild(ItemData[animal.Name].codeBase):Clone()
--	for i, v in pairs(animal:GetDescendants()) do
--		if v:IsA'BodyPosition' then
--			v.Position = v.Parent.Position
--			local yForce = (animal.Name == 'Lurky Boi' or animal.Name == 'Goldy Boi') and math.huge or 0
--			v.MaxForce = Vector3.new(math.huge, yForce, math.huge)
--			break
--		end
--	end
--	soul.Parent = animal
--	soul.Disabled = false
--end

market.ProcessReceipt = function(receiptInfo)
-- PlayerId
-- PlaceIdWherePurchased
-- PurchaseId
-- ProductId
-- CurrencySpent

	local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then -- Seems like we can't find the player= already left?
		return Enum.ProductPurchaseDecision.NotProcessedYet -- Can't Process
	end

	local purchaseType
	local purchaseName

	if salesData.chests[tostring(receiptInfo.ProductId)] then
		GiveItemToPlayer(salesData.chests[tostring(receiptInfo.ProductId)] , player, 3)

	elseif salesData.coins[tostring(receiptInfo.ProductId)] then -- if purchase type == something else
		_G.sessionData[player.UserId].coins = _G.sessionData[player.UserId].coins + salesData.coins[tostring(receiptInfo.ProductId)]
		_G.sessionData[player.UserId].totalRobuxSpent = _G.sessionData[player.UserId].totalRobuxSpent + receiptInfo.CurrencySpent
		Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
			{
				"UpdateStats"
			}
		})

	elseif tostring(receiptInfo.ProductId) == "253832340" then
		_G.sessionData[player.UserId].newBan = false
-- unban
		Rep.Events.UnbanNotify:FireClient(player, false)
		SpawnCharacter(player)

	elseif tostring(receiptInfo.ProductId) == "5923413" then
--	print("they bought the advanced cosmetics")
--	_G.sessionData[player.UserId].advancedCosmetics = true
--	Rep.Events.UnlockAdvancedCosmetics:FireClient(player)
end -- end of purchaseType == "chest"

	Rep.Events.PlaySoundOnClient(player,"Coin Purchase")
	
	spawn(function()
		SaveData(player.UserId, _G.sessionData[player.UserId])
	end)


	return Enum.ProductPurchaseDecision.PurchaseGranted	
end

Rep.Events.BuyAdvancedCosmetics.OnServerEvent:connect(function(player)
	market:PromptGamePassPurchase(player, 5923413)
end)

Rep.Events.BuyBoulderGamepass.OnServerEvent:connect(function(player)
	market:PromptGamePassPurchase(player, 6268626)
end)


market.PromptGamePassPurchaseFinished:connect(function(player, purchaseId, purchased)
	if purchased then

		if purchaseId == 5923413 then
			_G.sessionData[player.UserId].advancedCosmetics = true
			Rep.Events.UnlockAdvancedCosmetics:FireClient(player)
		end

		if purchaseId == 6268626 then
			Rep.Events.BuyBoulderGamepass:FireClient(player)
			if not HasToolAtAll(player, "Boulder Tool") then
				_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory + 1] = {
					name = "Boulder Tool",
					lastSwing = 0
				}
			end
		end
		Rep.Events.PlaySoundOnClient(player,"Coin Purchase")
	end
end)

local spawnLocations = {}
for _, v in next, workspace.SpawnParts:GetChildren() do
	table.insert(spawnLocations, CFrame.new(v.CFrame.p))
--v.CFrame = v.CFrame*CFrame.new(0,-10,0)
	v:Destroy()
end

local meteorLocations = {}
for _, v in next, workspace.MeteorParts:GetChildren() do
	table.insert(meteorLocations, CFrame.new(v.CFrame.p + Vector3.new(0, -2.4, 0)))
--v.CFrame = v.CFrame*CFrame.new(0,-10,0)
	v:Destroy()
end

local antMoundLocations = {}
for _, v in next, workspace.AnthillParts:GetChildren() do
	table.insert(antMoundLocations, CFrame.new(v.CFrame.p + Vector3.new(0, -2.4, 0)))
--v.CFrame = v.CFrame*CFrame.new(0,-10,0)
	v:Destroy()
end

local shipwreckLocations = {}
for _, v in next, workspace.ShipwreckParts:GetChildren() do
	table.insert(shipwreckLocations, v.CFrame)
--v.CFrame = v.CFrame*CFrame.new(0,-10,0)
	v:Destroy()
end


_G.sessionData = {}
_G.worldStructures = {}
_G.tribeData = {}

-- setup tribes
for tribeName,tribeColor in next,ColorData.TribeColors do
	_G.tribeData[tribeName] = {
			name = tribeName,
			color = tribeColor,
			lastTotemTimer = 0,
			
			benefits = {
--				woodYield = 1,
--				stoneYield = 1,
--				speed = 2,
--				health = 10,
--				starvationMultiplier = 0.8,
--				healthRegenMultiplier = 1.2,
			},
			
			faith = nil,
			
			chief = nil,
			
			members = {
				-- [memberName] = jobString,
			},
			
			allies = {
				-- tribeKey (i.e Yellow, Green)
			},
			
			enemies = {
				-- tribeKey (i.e. Yellow, Green)
			},
		
		dynastyGUID = http:GenerateGUID(),
	}
end

--tribeFunctions = {
--	ContainsPlayer = function(player)
--		if self[player] then
--			return true
--		end
--	end
--}
--
--
--
--tribea = {
--color = BrickColor.new("Bright red")
--}
--
--
--
--if tribea:ContainsPlayer(player) then
--
--
--tribe:ContainsPlayer(player)

--_G.tribeData = {
--
----{
----color = "Yellow",
----chief = nil,
----members = {},
----message = "",
----diplomacy = {},
----way = {},
----},
--}


utilityWhiteList = {}

local InGame = ds:GetDataStore'InGame'

function SD(p)
	if not game:GetService'RunService':IsStudio() then
		InGame:RemoveAsync(p.UserId)
	end
end

function LoadData(userId) -- their user id
	local IsInGame, p = InGame:GetAsync(userId), game.Players:GetPlayerByUserId(userId)
	
	if p and not game:GetService'RunService':IsStudio() then
		if IsInGame then
			p:Kick()
		else
			InGame:SetAsync(userId, true)
		end
	end
	
	local attempts, data, success, err = 0
	
	repeat
		success, err = pcall(function()
			data = PlayerData:GetAsync(userId, err)
		end)
		attempts = attempts + 1
		if not success then 
			wait(1)
		end
	until success or attempts >= 5
	
	if success then
		if data then
			data = GU.CleanData(data)
			if data.CanSave then
				data.CanSave = true
			else
				data['CanSave'] = true
			end
		end
		return data and data or defaultData.ReturnBlankSlate()
	end
	
	if p then
		p:Kick()
	end
end

SaveAllData = function()
	-- go all over sessionData
	for id,data in next,_G.sessionData do
		SaveData(id,data)
	end
end

function SaveData(userId, dataToSave)
	if game.PlaceId == 2626094174 then -- bug test place ID
		return
	end
	
	local p, attempts, success, err = game.Players:GetPlayerByUserId(userId), 0
	
	if p then
		CleanInventory(p)
	end
	
	repeat
		success, err = pcall(function()
			dataToSave.CanSave = false
			PlayerData:SetAsync(userId, dataToSave)
		end)
		attempts = attempts + 1
		if not success then 
			wait(1)
		end
	until success or attempts >= 5
	
	if success then
		warnIfInvalid(dataToSave)
	else
		warnIfInvalid(dataToSave)
		warn('Data failed to save for:', userId, ' ~ Error:', err)
	end
end

game.Players.PlayerRemoving:connect(function(p)
	if gameClosing then
		return
	end
	SD(p)
end)
	
-- autosave coroutine
local autosave = coroutine.wrap(function()
	while wait(10) do
		local success,message =	pcall(function()
			for _, v in next, game.Players:GetPlayers() do
				local data = _G.sessionData[v.UserId]
				if data and data.CanSave then
					SaveData(v.UserId, _G.sessionData[v.UserId])
				end
			end
		end)
		if not success then
			warn(message)
		end
	end
end)
autosave()


if not game:GetService'RunService':IsStudio() then
	game:BindToClose(function()
		gameClosing = true

		for id, data in next, _G.sessionData do
			data.lastAttacker =  nil
			data.lastCombat  = 0 
			SaveData(id, data)
			_G.sessionData[id] = nil
		end
		
		for _, p in pairs(game.Players:GetPlayers()) do
			SD(p)
		end
	end)
end


function GetDictionaryLength(tab)
	local count = 0
	for _, v in next, tab do
		count = count + 1 
	end
	return count
end

function Chance(num)
-- out of 100
	return math.random(0, 100) <= num
end

function HasMojoRecipe(player, itemName)
	return _G.sessionData[player.UserId].mojoItems[itemName]
end

function CalculateToolDamageToPlayers(toolName, player)
-- name of the tool,  and the  player receiving damage
	local totalDamage = 0
	
	local itemInfo = ItemData[toolName]
	if itemInfo.damages then
		totalDamage =  ItemData[toolName].damages.lifeforms
		local totalAbsorb = CalculateArmor(player)
		--local totalPierce = ItemData[toolName].armorPierce or 1
		--armorMultiplier = armorMultiplier*totalPierce
		--totalArmorResist  = math.clamp(totalArmorResist,0,9/10) -- 90% absorbs  possible always
	
		totalDamage = math.clamp(totalDamage - totalAbsorb,10,100)
		return totalDamage
	end
end

function CalculateArmor(player)
	local armorRating = 0
	
	for armorLocus, armorName in next, _G.sessionData[player.UserId].armor do
		if armorName and armorName ~= "none" then
			if ItemData[armorName] and ItemData[armorName].absorbs then
				armorRating = armorRating + ItemData[armorName].absorbs
			end 
		end
	end
	print("calculated armorRating",armorRating)
	return armorRating
end

function GiveItemToPlayer(itemName, player, amount)
	amount = amount or 1
	
	local hasKey = HasItem(player, itemName)
	if hasKey then
		_G.sessionData[player.UserId].inventory[hasKey].quantity = _G.sessionData[player.UserId].inventory[hasKey].quantity + amount
	
	else
		_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory + 1] = {
			name = itemName,
			quantity = amount
		}
	end

	Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
		{
			"DrawInventory"
		},
		{
			"UpdateStats"
		}
	})
end -- giveitemtoplayer


function ForceUnequip(player)
	for _, v in next, player.Character:GetChildren() do
		if ItemData[v.Name] and ItemData[v.Name].itemType == "tool" then
			v:Destroy()
			_G.sessionData[player.UserId].equipped = nil
--Rep.Events.UpdateData:FireClient(player,_G.sessionData[player.UserId],{{"SortToolbar"}})
		end
	end
end

function GiveCoin(player, amount)
	_G.sessionData[player.UserId].coins = _G.sessionData[player.UserId].coins + amount
	Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
		{
			"UpdateStats"
		}
	})
end

function GiveEssence(player, amount)
	_G.sessionData[player.UserId].essence = _G.sessionData[player.UserId].essence + amount
--print("level is",_G.sessionData[player.UserId].level)
--print("essence is",_G.sessionData[player.UserId].essence)
	if _G.sessionData[player.UserId].essence >= (levelData[_G.sessionData[player.UserId].level] or math.huge) then
-- we gotta level them up!
-- if there is a level above what they are
		local leftover = _G.sessionData[player.UserId].essence - levelData[_G.sessionData[player.UserId].level]
		_G.sessionData[player.UserId].essence = leftover
		_G.sessionData[player.UserId].level = _G.sessionData[player.UserId].level + 1
--spawn(function()
--SaveData(player.UserId,_G.sessionData[player.UserId])
--end)
-- tell them they leveled up level up
		Rep.Events.Notify:FireClient(player, "You leveled up!", ColorData.essenceYellow, 5)
--		GiveItemToPlayer("Pleb Chest", player)
		UpdateAllPlayerLists()

		local newItemList = {}
		for itemName, itemInfo in next, ItemData do
			if itemInfo.craftLevel and itemInfo.craftLevel == _G.sessionData[player.UserId].level then --and not _G.sessionData[player.UserId].ownedRecipes[itemName] then
--_G.sessionData[player.UserId].ownedRecipes[itemName] = true
				newItemList[#newItemList + 1] = itemName
			end
		end
		if #newItemList > 0 then
-- tell them they unlocked new items
--local messagio = "YOU LEARNED: "
			local messagio = ""
			for i, v in next, newItemList do
				if i ~= #newItemList then
					messagio = messagio..v..", "
				else
					messagio = messagio..v 
				end
			end

			Rep.Events.MakeToast:FireClient(player,
{
				title = "NEW RECIPES!",
				message = messagio,
				color = ColorData.essenceYellow,
				image = "rbxassetid://1390834073",
				duration = 8
			})
			Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
				{
					"UpdateStats"
				},
				{
					"DrawCraftMenu"
				}
			})
		end
	end
	Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
		{
			"UpdateStats"
		}
	})

end

function AppendTables(tables)
	local mainTable = {}
	for tabKey, tabData in next, tables do
		for key, val in next, tabData do
			mainTable[#mainTable + 1] = val
		end
	end
	return mainTable
end

function CheckIfLockedCosmetic(player, cosmeticName) 
	local found = cosmeticData.hair[cosmeticName] or cosmeticData.skin[cosmeticName] or cosmeticData.face[cosmeticName]
	if found.locked and _G.sessionData[player.UserId].advancedCosmetics then
		return true
	else
		return false
	end
end

function SetupAppearance(player)
	if not player.Character then
		return
	end
	local char = player.Character
-- set up their core appearance

	for limbName, val in next, skinColorList do
		local skinColor = cosmeticData.skin[_G.sessionData[player.UserId].appearance.skin].color
		char["Body Colors"].HeadColor3 = skinColor
		char["Body Colors"].LeftArmColor3 = skinColor
		char["Body Colors"].RightArmColor3 = skinColor
	end

	ColorCharacter(player)

-- face
	char.Head.Face.Texture = cosmeticData.face[_G.sessionData[player.UserId].appearance.face].image
-- torso
--char.UpperTorso.MeshId = cosmeticData.bodyTypes[_G.sessionData[player.UserId].gender]
-- hair


---- clear old armor
--for itemName,itemInfo in next,ItemData do
--if itemInfo.itemType == "armor" then
--for _,pieceName in next,itemInfo.pieces do
--if player.Character:FindFirstChild(pieceName) then
--player.Character:FindFirstChild(pieceName):Destroy()
--end
--end
--end
--end

-- clear all accoutrements
	for _, v in next, player.Character:GetChildren() do
		if v:IsA("Accoutrement") then
			v:Destroy()
		end
	end

	local newHair
	local newHelmetName
	local newHat

-- add the hair
	if _G.sessionData[player.UserId].appearance.hair and 
	_G.sessionData[player.UserId].appearance.hair ~= "none" and 
	_G.sessionData[player.UserId].appearance.hair ~= "Bald"
	then
		newHair = ss.Cosmetics.Hair:FindFirstChild(_G.sessionData[player.UserId].appearance.hair):Clone()
		newHair.Parent = player.Character
	end


-- set up armor and masks
	for keyLocus, armorName in next, _G.sessionData[player.UserId].armor do
		if armorName and armorName ~= "none" then
			if keyLocus == "head" then
				newHelmetName = armorName
			end
			local itemInfo = ItemData[armorName]
			if itemInfo then
				for _, pieceName in next, itemInfo.pieces do
					local found = ss.Armor:FindFirstChild(pieceName)
					if not player.Character:FindFirstChild(pieceName) then
						found:Clone().Parent = player.Character
					end
				end
			end

		end
	end

	if _G.sessionData[player.UserId].appearance.hat and _G.sessionData[player.UserId].appearance.hat ~= "none" then
		newHat = ss.Cosmetics.hat:FindFirstChild(_G.sessionData[player.UserId].appearance.hat):Clone()
		newHat.Parent = player.Character
	end

	if ((newHelmetName or newHat) and newHair) and (newHelmetName ~= "God Halo") then
		newHair:Destroy()
	end
	if newHat and newHelmetName then
		player.Character:FindFirstChild(newHelmetName):Destroy()
	end

	Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
		{
			"UpdateCosmetics"
		}
	})
end -- end of setup player


GetPlayerInfo = function(player)
	local data = _G.sessionData[player.UserId]
	local info
	
	if data then
		info = {
		name = player.Name,
		level = _G.sessionData[player.UserId].stats.level,
		tribe = HasTribe(player),
		}
	else
		info = {
		name = player.Name,
		level = 1,
		tribe = nil,
		}
	end
	return info		
end

UpdateAllPlayerLists = function()
	local data = {}
	for _,otherPlayer in next,game.Players:GetPlayers() do
		local info = GetPlayerInfo(otherPlayer)
		data[#data+1] = info
	end
	
	Rep.Events.DrawPlayerList:FireAllClients(data)
end

function SpawnCharacter(player)
	_G.sessionData[player.UserId].lastSpawn = Rep.Constants.RelativeTime.Value
	player:LoadCharacter()
	repeat
		if not (player.Character and (player.Character:IsDescendantOf(workspace))) then
			wait()
		else
			break
		end
	until nil

	if _G.sessionData[player.UserId].newBan then 
		wait(1)
		player.Character:Destroy()
		Rep.Events.UnbanNotify:FireClient(player, true)
		return 
	end

	local char = player.Character

	SetupAppearance(player)

	if _G.sessionData[player.UserId].mojoItems["Shelly Friend"] and not _G.sessionData[player.UserId].disabledMojo["Shelly Friend"] then
		local newPet = ss.Pets:FindFirstChild("Shelly Friend"):Clone()
		newPet:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
		newPet.Parent = char
		newPet.PetMover.Disabled = false
	end

	if _G.sessionData[player.UserId].mojoItems["Lurky Bro"] and not _G.sessionData[player.UserId].disabledMojo["Lurky Bro"] then
		local newPet = ss.Pets:FindFirstChild("Lurky Bro"):Clone()
		newPet:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
		newPet.Parent = char
		newPet.PetMover.Disabled = false
	end

	if _G.sessionData[player.UserId].mojoItems["Peeper Pet"] and not _G.sessionData[player.UserId].disabledMojo["Peeper Pet"] then
		local newPet = ss.Pets:FindFirstChild("Peeper Pet"):Clone()
		newPet:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
		newPet.Parent = player.Character
		newPet.PetMover.Disabled = false
	end
	
	if _G.sessionData[player.UserId].mojoItems["Gobbler Buddy"] and not _G.sessionData[player.UserId].disabledMojo["Gobbler Buddy"] then
		local newPet = ss.Pets:FindFirstChild("Gobbler Buddy"):Clone()
		newPet:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
		newPet.Parent = player.Character
		newPet.PetMover.Disabled = false
	end

	if _G.sessionData[player.UserId].mojoItems["Sparkles"] and not _G.sessionData[player.UserId].disabledMojo["Sparkles"] then
		local sparkle = Rep.Particles.GodSparkle:Clone()
		sparkle.Parent = char.PrimaryPart
	end

-- make sure they at least have a rock
	local hasRock = HasToolAtAll(player, "Rock Tool")
	if not hasRock then
		_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory + 1] = {
			name = "Rock Tool",
		}
	end
	
	local hasBoulder = HasToolAtAll(player, "Boulder Tool")
	if not hasBoulder and _G.sessionData[player.UserId].boulderGamepass then
		_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory + 1] = {
			name = "Boulder Tool",
			lastSwing = 0
		}
	end
	
	print("attempting to index _G.sessionData:",_G.sessionData,"at",player.UserId)
	for key,val in next,_G.sessionData[player.UserId] do
		print(key,val)
	end
	Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
		{
			"DrawInventory"
		},
		{
			"UpdateArmor"
		},
		{
			"SortToolbar"
		}
	})
end-- end of spawncharacter

function AddValueObject(target, valName, valType, val)
	local newVal = Instance.new(valType, target)
	newVal.Value = val
	newVal.Name = valName
end

function CreateParticles(instance, origin, facing, count, duration, particleProperties)

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(0, 0, 0)
	part.CFrame = CFrame.new(origin, facing)
	local emitter = instance:Clone()
	emitter.Parent = part
	emitter.EmissionDirection = Enum.NormalId.Front
	if particleProperties then
		for property, val in next, particleProperties do
			emitter[property] = val
		end
	end

	part.Parent = workspace
	wait()

	if count then
		emitter.Rate = 0
		emitter:Emit(count)
		debris:AddItem(part, duration)
	else
		debris:AddItem(part, duration)
	end

end -- end of createparticles

function WithinDistance(object1, object2, range)
	local pos1, pos2

	if object1:IsA("BasePart") then
		pos1 = object1.Position
	elseif object1:IsA("Model") then
		pos1 = object1.PrimaryPart.Position
	end

	if object2:IsA("BasePart") then
		pos2 = object2.Position
	elseif object2:IsA("Model") then
		pos2 = object2.PrimaryPart.Position
	end

	local dist = (pos1 - pos2).magnitude
	if dist <= range then
		return true
	else
		return false
	end
end

function CanCraftItem(player, itemName)
	local itemInfo = ItemData[itemName]
	if itemInfo.mojoRecipe then
		local function notify()
			Rep.Events.Notify:FireClient(player, 'You can only have one '..itemName..'.', Color3.fromRGB(222, 147, 223), 4)
		end
		
		if not HasMojoRecipe(player, itemName) then
			player:Kick()
			return false
		end
		
		--Check inventory
		if HasItem(player, itemName) then
			notify()
			return false
		end
		
		--Scan their equipped armor
		for _, v in next, _G.sessionData[player.UserId].armor do
			if v == itemName then
				notify()
				return false
			end
		end
		
	 	--Scan their toolbar
		for _, toolData in next, _G.sessionData[player.UserId].toolbar do
			if toolData.name == itemName then
				notify()
				return false
			end
		end
		
		--Check if they have all the items to craft it.
		if itemInfo.recipe then
			for ingredientName, ingredientQuantity in next, itemInfo.recipe do
				local hasKey = HasItem(player, ingredientName)
				if not (hasKey and _G.sessionData[player.UserId].inventory[hasKey].quantity >= ingredientQuantity) then
					Rep.Events.Notify:FireClient(player, 'Not enough materials.', Color3.fromRGB(222, 147, 223), 4)
					return false
				end
			end
		end
		
		return true
	end
	
	--Not a mojo item.
	if _G.sessionData[player.UserId].level >= itemInfo.craftLevel then
		for ingredientName, ingredientQuantity in next, itemInfo.recipe do
			local hasKey = HasItem(player, ingredientName)
			if not (hasKey and _G.sessionData[player.UserId].inventory[hasKey].quantity >= ingredientQuantity) then
				return false
			end
		end
	else
		player:Kick()
		return false
	end
	
	return true
end

local conversionNames = {
	["Crystal Chunk"] = "Crystal",
	["Stick"] = "Wood",
	["Gold Bar"] = "Gold",
	["Rock"] = "Rock Tool",
	["Boulder"] = "Boulder Tool",
}

function CleanNils(t)
  local ans = {}
  for _,v in pairs(t) do
    ans[ #ans+1 ] = v
  end
  return ans
end

function CleanInventory(player,data)
	if not data then 
		data = _G.sessionData[player.UserId].toolbar
	end
		
	local tab = data or _G.sessionData[player.UserId].inventory

		local contraband = false
		
		-- inventory
		
	_G.sessionData[player.UserId].inventory = CleanNils(_G.sessionData[player.UserId].inventory)
		
		for itemKey, itemInfo in next, _G.sessionData[player.UserId].inventory do

			-- clear anything that doesn't have a name
			if (not itemInfo) or (not itemInfo.name) or (not ItemData[itemInfo.name]) then
				table.remove(_G.sessionData[player.UserId].inventory,itemKey)
			end
			
			if itemInfo.quantity and (itemInfo.quantity <=0) then
				table.remove(_G.sessionData[player.UserId].inventory,itemKey)
			end
			
			if conversionNames[itemInfo.name] then -- check for conversions
				_G.sessionData[player.UserId].inventory[itemKey].name = conversionNames[itemInfo.name]
			end
						
		end

		-- armor
		for locus, armorName in next, _G.sessionData[player.UserId].armor do
			if conversionNames[armorName] then -- check for conversions
				_G.sessionData[player.UserId].armor[locus].armorName = conversionNames[armorName]
			end
			
			if armorName ~= "none" and (not ItemData[armorName]) then
				print("no ItemData for",armorName)
				_G.sessionData[player.UserId].armor[locus] = "none"
			end
		end

		-- toolbar
		for toolKey, toolInfo in next, _G.sessionData[player.UserId].toolbar do
			if toolInfo.name then
				if conversionNames[toolInfo.name] then -- check for conversions
					_G.sessionData[player.UserId].toolbar[toolKey].armorName = conversionNames[toolInfo.name]
				end	
				if (not ItemData[toolInfo.name]) or (ItemData[toolInfo.name] == "none") then
					_G.sessionData[player.UserId].toolbar[toolKey] = {}
				end
			end
		end

	return
end

function HasToolInBar(player, toolName, data)
	if not data then 
		data = _G.sessionData[player.UserId].toolbar
	end
	
	for key, v in next, data.toolbar or _G.sessionData[player.UserId].toolbar do
		if v.name == toolName then
			return true
		end
	end
	return false
end

function HasToolAtAll(player, toolName, data)
	if not data then 
		data = _G.sessionData[player.UserId].toolbar
	end
	
	for key,v in next, data.toolbar or _G.sessionData[player.UserId].toolbar do
		if v.name == toolName then
			return true
		end
	end
	
	if HasItem(player, toolName,data) then
		return true
	end

end

function HasItem(player, itemName,data )
	if not data then 
		data = _G.sessionData[player.UserId].toolbar
	end
	
	for key, v in next, data.toolbar or _G.sessionData[player.UserId].inventory do
		if v.name == itemName then
			return key
		end
	end
	return false
end

function ClearTools(char)
	for _, v in next, char:GetChildren() do
		if ItemData[v.Name] and ItemData[v.Name].itemType == "tool" then
			v:Destroy()
		end
	end
end

function ScanArray(tab, element)
	for _, v in next, tab do
		if v == element then
			return false
		end
	end
	return true
end

function PieceIsAnchored(thing)
	if thing:IsA("BasePart") then
		return thing.Anchored

	elseif thing:IsA("Model") then
		for _, v in next, thing:GetChildren() do
			if v:IsA("BasePart") and v.Anchored then
				return true
			end
		end
		return false
	end

end

local setToAnchor = {}
-- {when = Rep.Constants.RelativeTime.Value, item = newItem, ownedBy = dropInfo.player, collectIn = dropInfo.gc or (math.random(40,60)/10)}
local anchorGcCoroutine = coroutine.wrap(function()
	while Run.Heartbeat:wait() do
		for key, dropInfo in next, setToAnchor do
			if (Rep.Constants.RelativeTime.Value - (dropInfo.when + (dropInfo.gc or 4))) > 0 and not PieceIsAnchored(dropInfo.item) then
				local part, pos, norm, mat

				if dropInfo.item:IsA("BasePart") and dropInfo.item.CanCollide then
					part, pos, norm, mat = RayUntil(dropInfo.item.Position, Vector3.new(0, -1000, 0), {
						dropInfo.item
					})
					dropInfo.item.Anchored = true
					dropInfo.item.CanCollide = false
					dropInfo.item.CFrame = dropInfo.item.CFrame * CFrame.new(0, -(dropInfo.item.CFrame.Y - pos.Y) + (dropInfo.item.Size.Y / 2), 0)

				elseif dropInfo.item:IsA("Model") and dropInfo.item.PrimaryPart.CanCollide then
					part, pos, norm, mat = RayUntil(dropInfo.item.PrimaryPart.Position, Vector3.new(0, -1000, 0), {
						dropInfo.item:GetChildren()
					})
					for _, v in next, dropInfo.item:GetDescendants() do
						if v:IsA("BasePart") then
							v.Anchored = true
							v.CanCollide = false
						end
					end
					dropInfo.item:SetPrimaryPartCFrame(dropInfo.item.PrimaryPart.CFrame * CFrame.new(0, -(dropInfo.item.PrimaryPart.CFrame.Y - pos.Y) + (dropInfo.item.PrimaryPart.Size.Y / 2), 0))

				else
				end

				table.remove(setToAnchor, key)
				Run.Heartbeat:wait()
			end

		end
	end
end)
anchorGcCoroutine()

-- coroutine to loop through set to anchor and turn them into little dummy bois
function DropItem(dropInfo)
--print("DROP INFO  TRIGGERED")
--for k,v in next,dropInfo do
--print(k,v)
--end

--local player,itemName,cf,setOwner,variation = dropInfo["player"], dropInfo.itemName, dropInfo["cf"], dropInfo["setOwner"],dropInfo["variation"]
--player, itemName,cf,setowner,variation,gc
-- print("attempting to drop",dropInfo.itemName)
	local newItem = ss.Items:FindFirstChild(dropInfo.itemName):Clone()
	local offsetCF = CFrame.new(0, 0, 0)

	if dropInfo.variation then
		offsetCF = CFrame.new(math.random(-50, 50) / 10, math.random(40, 80) / 10, math.random(-50, 50) / 10)
	end
	
	local newParent = workspace
	if ItemData[dropInfo.itemName].itemType == "creature" then
		newParent = workspace.Critters
	end

	if newItem:IsA("BasePart") then
		newItem.CFrame = dropInfo.cf * offsetCF
	elseif newItem:IsA("Model") then
		newItem:SetPrimaryPartCFrame(dropInfo.cf * offsetCF)
	end

	debris:AddItem(newItem, (dropInfo.gc or 360))
	if dropInfo.autoAnchor then
		if newItem:IsA("BasePart") then
			newItem.Anchored = true
			newItem.CanCollide = false
		elseif dropInfo.item:IsA("Model") then
			for _, v in next, newItem:GetDescendants() do
				if v:IsA("BasePart") then
					v.Anchored = true
					v.CanCollide = false
				end
			end 
		end
		newItem.Parent = newParent
		return
	else
		newItem.Parent = newParent
	end
	setToAnchor[#setToAnchor + 1] = {
		when = Rep.Constants.RelativeTime.Value,
		item = newItem,
		ownedBy = dropInfo.player,
		collectIn = dropInfo.gc or (math.random(40, 60) / 10)
	}
end

function DeathDrop(player, pos)

	for keyLocus, armorName in next, _G.sessionData[player.UserId].armor do
		if armorName and armorName ~= "none" and keyLocus ~= "bag" and (not ItemData[armorName].noDrop) then
--drop the ingredients for that armor

			if ItemData[armorName].recipe and not ItemData[armorName].mojoRecipe then
				for ingredientName, ingredientQuantity in next, ItemData[armorName].recipe do
					for i = 1, math.random(1, ingredientQuantity) do
						DropItem({
							["player"] = player,
							["itemName"] = ingredientName,
							["cf"] = CFrame.new(pos),
							["gc"] = Rep.Constants.RelativeTime.Value + 600,
							["variation"] = true,
						})
					end
				end
			end
			_G.sessionData[player.UserId].armor[keyLocus] = "none"
		end
	end -- end of armor loop

-- check for tools or armor in the bag
	for itemKey, itemInfo in next, _G.sessionData[player.UserId].inventory do
		if (ItemData[itemInfo.name].itemType  == "tool" or (ItemData[itemInfo.name].itemType == "armor" and ItemData[itemInfo.name].locus ~= "bag")) and not ItemData[itemInfo.name].noDrop then
-- it's a tool so let's break it up
			if ItemData[itemInfo.name].recipe and not ItemData[itemInfo.name].mojoRecipe then
				for ingredientName, ingredientQuantity in next, ItemData[itemInfo.name].recipe do
					for i = 1, math.random(1, ingredientQuantity) do
						DropItem({
							["player"] = player,
							["itemName"] = ingredientName,
							["cf"] = CFrame.new(pos),
							["gc"] = Rep.Constants.RelativeTime.Value + 600,
							["variation"] = true,
						})
					end
				end
			end
			table.remove(_G.sessionData[player.UserId].inventory,itemKey)
		end
	end

-- check for tools in the toolbar
	for toolKey, toolInfo in next, _G.sessionData[player.UserId].toolbar do
		if GetDictionaryLength(toolInfo) > 0 and (toolInfo.name ~= "none") then
			if ItemData[toolInfo.name].recipe then
				for ingredientName, ingredientQuantity in next, ItemData[toolInfo.name].recipe do
					for i = 1, ingredientQuantity do
						DropItem({
							["player"] = player,
							["itemName"] = ingredientName,
							["cf"] = CFrame.new(pos),
							["gc"] = Rep.Constants.RelativeTime.Value + 600,
							["variation"] = true,
						})

					end
				end

				_G.sessionData[player.UserId].toolbar[toolKey] = {}
			end
		end
	end

	for i = 1, 2 do
		DropItem({
			["player"] = player,
			["itemName"] = "Raw Meat",
			["cf"] = CFrame.new(pos),
			["gc"] = Rep.Constants.RelativeTime.Value + 600,
			["variation"] = true,
		})
	end

--for i = 1,1 do
--local essenceDrop = ss.Items:FindFirstChild("Raw Meat"):Clone()
--essenceDrop.CFrame = CFrame.new(pos+Vector3.new(0,3,0))
--essenceDrop.Parent = workspace
--debris:AddItem(essenceDrop,60*10)
--end
end -- end of death drop

function DamagePlayer(player, damage) -- , obeyArmor)
	if player and player.Character and player.Character.Humanoid and player.Character:IsDescendantOf(workspace) then

		if player.Character:FindFirstChild("Shield") then
			player.Character.Shield.Health.Value = player.Character.Shield.Health.Value - 1
			if player.Character.Shield.Health.Value <= 0 then
				player.Character.Shield:Destroy()
			end
			return
		end

		local canDamage = true
		
		local distanceFromSpawn = (player.Character.PrimaryPart.Position - Rep.SpawnCF.Value.p).magnitude
		if distanceFromSpawn < 20 then
			canDamage = false
		end

		if canDamage then
			local totalAbsorb = CalculateArmor(player)
			print("totalAbsorb:",totalAbsorb,"dealing",math.clamp(damage-totalAbsorb,10,math.huge))
			player.Character.Humanoid:TakeDamage(math.clamp(damage-totalAbsorb,10,math.huge))
		end
	end
end

function PlaySoundInObject(soundReference, object, waver, extension)
	local sound
	if object:FindFirstChild(soundReference.Name) then
		sound = object:FindFirstChild(soundReference.Name)
	else
		sound = soundReference:Clone()
		sound.Parent = object
	end

	if waver then
		sound.Pitch = soundReference.Pitch + (math.random(-waver * 100, waver * 100) / 100)
	end
	sound:Play()
end

function ResetStats(player)
-- soft or hard
	_G.sessionData[player.UserId].equipped = nil
	_G.sessionData[player.UserId].stats.food = 100
	_G.sessionData[player.UserId].stats.water = 100
	_G.sessionData[player.UserId].lastTribeLeave = 0
	_G.sessionData[player.UserId].lastSpamRequest = 0
	_G.sessionData[player.UserId].lastCombat = 0
	for _, v in next, _G.sessionData[player.UserId].toolbar do
		if GetDictionaryLength(v) > 0 then
			v.lastSwing = 0
		end
	end

end


local adminPrefix = "/"
adminFunctions = {

	give = function(speaker, ...) --target, itemName, quantity
		local args = {
			...
		}
		local targetName = args[1]
		local amount = args[2]
		table.remove(args, 1)
		table.remove(args, 2)
		local itemNamePartial = table.concat(args)

		local closestMatch, targetPlayer = "", nil
		local target = game.Players:FindFirstChild(targetName)
		if target then
			targetPlayer = target
		else
			for _, v in next, game.Players:GetPlayers() do
				local match = string.match(v.Name:lower(), targetName:lower())
				if match then
					if #match >= #closestMatch then
						closestMatch = match
						targetPlayer = v
					end
				end
			end

		end
		if not targetPlayer then
			Rep.Events.Notify:FireClient(speaker, "Can't find that player!", ColorData.badRed, 3)
			return
		end

		closestMatch = ""
		local closestItem = nil
		for _, v in next, game.ServerStorage.Items:GetChildren() do
			local match = string.match(v.Name:lower(), itemNamePartial:lower())
			if match and #match >= #closestMatch then
				closestMatch = match
				closestItem = v
			end
		end
		if not closestItem then
			Rep.Events.Notify:FireClient(speaker, "Can't find that item...", ColorData.goodGreen, 3)
			return
		end
		local itemName = closestItem.Name

		if type(amount) ~= "number" then
			Rep.Events.Notify:FireClient(speaker, "Incorrect format.. say  /give plrName amount itemName", ColorData.badRed, 6)
			return
		end

		GiveItemToPlayer(itemName, targetPlayer)
-- should be SoftUpdate
		if targetPlayer ~= speaker then
			Rep.Events.Notify:FireClient(targetPlayer, speaker.Name.." gave you "..amount.." "..itemName, ColorData.goodGreen, 3)
		end
		Rep.Events.Notify:FireClient(speaker, "You gave "..targetPlayer.Name.." "..amount.." ".. itemName, ColorData.goodGreen, 3)
	end,

	msg = function(speaker, ...)
		local args = {
			...
		}
		local message = Instance.new("Message")
		message.Text = speaker.Name..[[: "]]..table.concat(args)..[["]]
		message.Parent = workspace
		debris:AddItem(message, (#args[1] * .1) + 4)
	end,
}


game.Players.PlayerAdded:connect(function(player)

	if banData:GetAsync(player.UserId) then
	--	player:Kick()
	end
	
	player.Chatted:connect(function(msg)
		if msg == "2626094174" then
			game:GetService("TeleportService"):Teleport(2626094174,player)
		end
	end)

	player.CharacterAdded:connect(function(char)
		teleImmunity[player.UserId]  = Rep.Constants.RelativeTime.Value
--spawn(function()
--wait(1)
--char.Parent = workspace.Critters
--end)

		setCollisionGroupRecursive(char)
		char.DescendantAdded:Connect(setCollisionGroup)
		char.DescendantRemoving:Connect(resetCollisionGroup)


		local hum = char:WaitForChild("Humanoid")
		hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
		hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
		hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
--hum:WaitForChild("BodyTypeScale").Value = 1.0

		local root = char:WaitForChild("HumanoidRootPart")

--char.DescendantAdded:connect(function(thing)
--if thing:IsA("BodyMover") and (not thing:IsA("BodyGyro") and thing.Parent ~= root) then
--player:Kick()
--end
--end)

-- GIVE THEM ARMOR IF THEY HAVE SOME
--local leafyboi = Rep.Armors.LeafShirt:Clone()
--leafyboi.Parent = char 

		local healthGui, nameGui = Rep.Guis.HealthGui:Clone(), Rep.Guis.NameGui:Clone()
		healthGui.Parent, nameGui.Parent = root, root
		healthGui.PlayerToHideFrom, nameGui.PlayerToHideFrom = player, player
		healthGui.Adornee, nameGui.Adornee = root, root
		if player.Name == "LollyLeeloo" then
			nameGui.TextLabel.Text = "Dr_Cyanidee"
		else
			nameGui.TextLabel.Text = player.Name
		end

		hum.HealthChanged:connect(function()
	--local healthy = Color3.fromRGB(211, 255, 114)
			local healthy = ColorData.goodGreen
			local dead = Color3.fromRGB(214, 39, 36)
			local slider = healthGui:FindFirstChild'Slider'
			if slider then
				slider.BackgroundColor3 = healthy:lerp(dead, 1 - (hum.Health / hum.MaxHealth))
				slider.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
			end
		end)

		hum.Died:connect(function()
			_G.sessionData[player.UserId].hasSpawned = false
			_G.sessionData[player.UserId].appearance.hat = "none"
-- respawn sequence
--remove all their armor
			DeathDrop(player, root.Position)

			CleanInventory(player)
			ResetStats(player)
			Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
				{
					"SortToolbar"
				},
				{
					"UpdateStats"
				},
			})

			wait(2)
			local succ, err = pcall(function()
				ResetStats(player)
			end)
--wait(1)
			SpawnCharacter(player)
			print("spawn that character")

		end)-- end of hum died

		local isReady = false
		repeat
			isReady = (char:FindFirstChild("HumanoidRootPart") and char:IsDescendantOf(workspace))
			if not isReady then
				wait()
			else
				break
			end
		until isReady

		if _G.sessionData[player.UserId].hasSpawned then
			local destination = spawnLocations[math.random(1, #spawnLocations)]
			teleImmunity[player.UserId] = Rep.Constants.RelativeTime.Value
			TeleportPlayer(player, destination)

		else
			TeleportPlayer(player, Rep.SpawnCF.Value)
			char.PrimaryPart.Anchored = true
--char.Humanoid.MaxHealth,char.Humanoid.Health = math.huge,math.huge
			char.Humanoid.WalkSpeed = 0
			char.Humanoid.JumpPower = 0
		end

	end) -- end of characteraddded

	local data = LoadData(player.UserId)
	UpdateAllPlayerLists()
--	Rep.Events.Weather:FireClient(player, currentWeather, true)

	if not data.advancedCosmetics then
		data.advancedCosmetics = market:UserOwnsGamePassAsync(player.UserId, 5923413)-- or (player.Name == "Soybeen")
		if data.advancedCosmetics then
			Rep.Events.UnlockAdvancedCosmetics:FireClient(player)
		end
	end

	if not data.boulderGamepass then
		data.boulderGamepass = market:UserOwnsGamePassAsync(player.UserId, 6268626)-- or (player.Name == "Soybeen")
		if data.boulderGamepass then
		-- give them a boulder if they don't have one
			if not HasToolAtAll(player,"Boulder Tool",data) then
			data.inventory[#data.inventory+1] = {
				name = "Boulder Tool",
				}
			end
		end
	end

	-- reset lastSwings
	for _, v in next, data.toolbar do
		if GetDictionaryLength(v) > 0 then
			v.lastSwing = 0
		end
	end
	
	data.equipped = nil

	if data.lastAttacker then
		Rep.Events.Notify:FireClient(player, "You combat logged against "..data.lastAttacker, ColorData.badRed, 15)
	end
	
	data.lastAttacker = nil
	data.lastCombat = 0
	 
	if not data.coins then
		data.coins = 0
	end
	
	if not data.quests then
		data.quests = {}
	end
	
	if not data.version then
		data.version = 0
	end

	if not data.newBan then
		data.newBan = false
	end
	
	if not data.stats.overHeal then
		data.stats.overHeal = 0
	end
		-- accredit them for things such as DataRepair1
	if table.find(DataRepair1,player.UserId) and not data.redeemed["dataRepair1"] then
		data.redeemed["dataRepair1"] = true
		data.coins = data.coins+20000
	end
	
	local necessaryTables = {
		redeemed = {}, -- redeemed codes
		mojoItems = {},
		appearance = {
			gender = "Male",
			skin = "White",
			face = "Smile",
			hat = "none",
			hair = "Bald",
			back = "none",
			effect = "none",
			},
			stats = {
			food = 100,
			water = 100
		},
		inventory = {
			{name = "Wood",
			quantity = 4},
			{name = "Cooked Meat",
			quantity = 1},
		},
		armor = {
			head = "none",
			arms = "none",
			legs = "none",
			torso = "none",
			bag = "none",
		--face = "none",
		},
		toolbar = {
		{name = "Rock Tool",
		lastSwing = 0,}, -- 1
		{}, -- 2
		{}, -- 3
		{}, -- 4
		{}, -- 5
		{}, -- 6
		}, -- end of toolbar
		customRecipes = {},
		ownedCosmetics = {},
		
		userSettings = {
			muteTribeInvitations = false,
			hideGrass = false
		}
	}
	
	for tab,val in next,necessaryTables do
		if not data[tab] then
			data[tab] = FL.DeepCopy(val)
		end
	end

	if not data.disabledMojo then
		data.disabledMojo = {}
	end
	
	if not data.lastRequest then
		data.lastRequest = 0
	end

-- finalizing data
	_G.sessionData[player.UserId] = data
	_G.sessionData[player.UserId].hasSpawned = false
	CleanInventory(player)

	ResetStats(player)
	print("spawning character")
	SpawnCharacter(player)

	local deviceType = "pc"
	spawn(function()
		print("asking for client device type")
		deviceType = Rep.Events.AskForDeviceType:InvokeClient(player)
		local deviceTypeVal = Instance.new("StringValue", player)
		deviceTypeVal.Value = deviceType
		deviceTypeVal.Name =  "DeviceType" 
	end)

end) -- end of playeradded

game.Players.PlayerRemoving:connect(function(player)
	
	for tradeKey, tradeData in next, _G.trades do--ADD TRADE DATA TO PLAYER's DATA?
		if tradeData.trader == player.Name then
		--table.remove(_G.trades,tradeKey)
			_G.trades.tradeKey = nil
		end
	end

	if _G.sessionData[player.UserId] then
		if _G.sessionData[player.UserId].lastCombat then
			if (Rep.Constants.RelativeTime.Value - _G.sessionData[player.UserId].lastCombat) < 10 and not gameClosing then
				if _G.sessionData[player.UserId].lastAttacker then
					local targetPlayer = game.Players:FindFirstChild(_G.sessionData[player.UserId].lastAttacker)
					if targetPlayer and targetPlayer.Character and targetPlayer.Character.PrimaryPart then
						DeathDrop(player, (targetPlayer.Character.PrimaryPart.CFrame * CFrame.new(0, 3, -5)).p)
-- drop all the loot like normal for the attacker
					end
				end
			else
				_G.sessionData[player.UserId].lastAttacker = nil
			end
		end
--_G.sessionData[player.UserId].lastCombat = 0
--_G.sessionData[player.UserId].lastAttacker = nil


		SaveData(player.UserId, _G.sessionData[player.UserId])
		_G.sessionData[player.UserId] = nil
	end

	LeaveTribe(player)

-- turn all their buildings to rubble
	for structure, structureData in next, _G.worldStructures do
		if structureData.owner and structureData.owner == player then
			if ItemData[structure.Name].itemType ~= "creature" and ItemData[structure.Name].rubble then
				local rubbleOG = ss.Rubble:FindFirstChild(ItemData[structure.Name].rubble)
				if rubbleOG then
					local rubble = rubbleOG:Clone()
					rubble.Health.Value = ItemData[rubble.Name].health
					rubble:SetPrimaryPartCFrame(structure.PrimaryPart.CFrame)
					_G.worldStructures[structure] = nil
					structure:Destroy()
					rubble.Parent = workspace
					debris:AddItem(rubble, 60 * 10)
					CreateParticles(Rep.Particles.SmokeRubble, rubble.PrimaryPart.CFrame.p, (rubble.PrimaryPart.CFrame * CFrame.new(0, 1, 0)).p, 3, 10, {
						SpreadAngle = Vector2.new(math.random(1, 90), math.random(1, 90))
					})
				end
			end
		end
	end

end) -- end of player removing

function AreAllies(player1, player2)
	if player1 == player2  then
		return true
	end
	local tribeKey1, tribeInfo1 = HasTribe(player1)
	local  tribeKey2, tribeInfo2 =  HasTribe(player2)
	if tribeKey1 and tribeKey2 and tribeKey1 == tribeKey2 then
		return true
	else
		return false 
	end
end

function BanPlayer(player)
--_G.sessionData[player.UserId].banned = true
--_G.sessionData[player.UserId].hasHacked = true
--player:Kick()
end

function Exists(thing)
	if thing then
		return true
	else
		return false
	end
end

rayIgnore = {}
function RayUntil(origin, destination, ignoreArray)
	if ignoreArray then
		rayIgnore = AppendTables(rayIgnore, ignoreArray)
	end
	local ray = Ray.new(origin, destination)
	local part, pos, norm, mat = workspace:FindPartOnRayWithIgnoreList(ray, rayIgnore)
	if part and part ~= workspace.Terrain then
		table.insert(rayIgnore, part)
		return RayUntil(origin, destination)
	end
	rayIgnore = {}
	return part, pos, norm, mat
end

local affectingModels = {}

function ShakeModel(model)
	affectingModels[model] = true
	if (not model) or (not model.PrimaryPart) then
		return
	end
	local origin = model.PrimaryPart.CFrame
	if (not model) or (not model.PrimaryPart) then
		return
	end
	model:SetPrimaryPartCFrame(origin * CFrame.new(-.1, 0, 0))
	wait(.1)
	if (not model) or (not model.PrimaryPart) then
		return
	end
	model:SetPrimaryPartCFrame(origin * CFrame.new(.1, 0, 0))
	wait(.1)
	if (not model) or (not model.PrimaryPart) then
		return
	end
	model:SetPrimaryPartCFrame(origin)
	affectingModels[model] = nil
end


function DamageResource(model, damage, player, noDrop)
	local health = model:FindFirstChild("Health")
	if health.Value == ItemData[model.Name].health then
		if model.Name ~= "Plant Box" then
			for _, v in next, model:GetDescendants() do
				if (ItemData[v.Name] and ItemData[v.Name].itemType == "food" and not v.Parent:IsA("Folder")) then
					v.Anchored = false
					v.Parent = workspace.Homeless
					debris:AddItem(v, 120)
					AddValueObject(v, "Pickup", "BoolValue", true)
					AddValueObject(v, "Draggable", "BoolValue", true)
				end
			end
		end
	end

	health.Value = math.clamp(health.Value - damage, 0, math.huge)
	if player then
		if ItemData[model.Name] then
--			Rep.Events.TargetAcquire:FireClient(player, model.Name, model.Health.Value, model.Health.Value / ItemData[model.Name].health)
			Rep.Events.RemoteDamageNotify:FireClient(player,
				{name = model.Name,
				health = model.Health.Value,
				maxHealth = ItemData[model.Name].health
				}
			)
		end
	end

	if health.Value > 0 then
-- shake object, give fractional?
		if not affectingModels[model] then

			if ItemData[model.Name].itemType ~= "creature" and ItemData[model.Name].itemType ~= "boat" and not ItemData[model.Name].noShake then
				spawn(function()
					ShakeModel(model)
				end) -- end of spawn
			end

		else
		end -- end of if not affectingmodels

	elseif health.Value <= 0 then
		local oldOrigin
		if model.PrimaryPart then
			oldOrigin = model.PrimaryPart.CFrame 
		else
			oldOrigin = player.Character.PrimaryPart.CFrame * CFrame.new(0, 3, -7)
		end

		local oldName = model.Name
-- enable this if the structures aren't removed from the table upon being destroyed
--worldStructres[model] = nil
		_G.worldStructures[model] = nil
		local contents
		if model:FindFirstChild("Contents") then
			contents = model.Contents
			contents.Parent = nil
		end

		if model:FindFirstChild("Breakaway") then
			for _, v in next, model.Breakaway:GetChildren() do
				v.Parent = workspace
			end
		end

		if model.Name == "Domestic Bantae" or model.Name == "Domestic Banto" then
-- check for distance between all void gate 
			for structure, structureData in next, _G.worldStructures do
				if structure.Name == "Void Gate" then
					local distance = (model.PrimaryPart.Position - structure.PrimaryPart.Position).magnitude
					if distance < 20 then
-- open the portal to the voiiiiiid!
						for _, v in next, structure:GetChildren() do
							if v.Name == "VoidFire" then
								v:Destroy()
							end
						end

						structure.Portal.Transparency = 1
						structure.Portal.DecalFront.Transparency = 0
						structure.Portal.DecalBack.Transparency = 0
						structure.Portal.ParticleEmitter.Enabled = false
						structure.Portal.PortalAmbience:Play()

-- when they touch the portal... what do?
						structure.Portal.Touched:connect(function(hit)
							local char = hit.Parent
							local player = game.Players:GetPlayerFromCharacter(char)
							if player then
--								local tribeKey, tribeInfo = HasTribe(player)
--								if tribeKey then
--									if tribeInfo.chief == player.Name then
---- teleport their whole tribe
--										local teleportList = {
--											game.Players:FindFirstChild(player.Name)
--										}
--										for _, memberName in next, tribeInfo.members do
--											teleportList[#teleportList + 1] = game.Players:FindFirstChild(memberName)
--										end
---- teleport everyone in that tribe
--										game:GetService("TeleportService"):TeleportPartyAsync(2021740958, teleportList)
--										structure:Destroy()
--									end
--
--								else -- if not tribekey
--									game:GetService("TeleportService"):Teleport(2021740958, player)
--									structure:Destroy()
--
--								end
								Rep.Events.PromptVoodooSpell:FireClient(player)
								structure:Destroy()
							end
						end)

					end
				end
				end
		
		elseif model.Name == "Crag" then
			-- randomize ore
			
		
		elseif model.Name == "Chillman" then
			_G.sessionData[player.UserId].quests.ruined_chillmen = (_G.sessionData[player.UserId].quests.ruined_chillmen or 0) + 1
			
			local amt = _G.sessionData[player.UserId].quests.ruined_chillmen
			
			if (amt < 1000) then
				Rep.Events.Notify:FireClient(player, "Chillman ruined ("..amt.." / 1000)", Color3.fromRGB(255, 200, 142), 1.5)
			end
			
			if amt >= 250 and not _G.sessionData[player.UserId].ownedCosmetics["Frozen Pumpkin Head"] then
				_G.sessionData[player.UserId].ownedCosmetics["Frozen Pumpkin Head"] = true
				
				Rep.Events.Notify:FireClient(player, "You've ruined 250 Chillmen!", Color3.fromRGB(170,255,0), 5)
				Rep.Events.Notify:FireClient(player, "Frozen Pumpkin hat unlocked!", Color3.fromRGB(255, 200, 142), 10)
			end
			
			if amt >= 1000 and not _G.sessionData[player.UserId].ownedCosmetics["Am Chillman"] then
				_G.sessionData[player.UserId].ownedCosmetics["Am Chillman"] = true
				
				Rep.Events.Notify:FireClient(player, "You've ruined 250 Chillmen!", Color3.fromRGB(170,255,0), 5)
				Rep.Events.Notify:FireClient(player, "Am Chillman hat unlocked!", Color3.fromRGB(255, 200, 142), 10)
			end
		end

		model:Destroy()

		if _G.sessionData[player.UserId].toolbar[_G.sessionData[player.UserId].equipped].name == "The Moneymaker" then
			for i = 1, math.random(10, 16) do
				DropItem({
					["player"] = player,
					["itemName"] = "Coin",
					["cf"] = oldOrigin,
					["gc"] = Rep.Constants.RelativeTime.Value + 600,
					["autoAnchor"] = false,
					["variation"] = true,
				})
			end
	
		elseif _G.sessionData[player.UserId].toolbar[_G.sessionData[player.UserId].equipped].name == "Peeper Pop Hammer" then
			DropItem({
				["player"] = player,
				["itemName"] = "Egg",
				["cf"] = oldOrigin,
				["gc"] = Rep.Constants.RelativeTime.Value + 600,
				["autoAnchor"] = false,
				["variation"] = true,
			})
		end

		if contents then
			spawn(function()
				for _, v in next, contents:GetChildren() do
					DropItem({
						["player"] = player,
						["itemName"] = v.Name,
						["cf"] = oldOrigin,
						["gc"] = Rep.Constants.RelativeTime.Value + 60*5,
						["autoAnchor"] = false,
						["variation"] = true,
					})
				end
				contents:Destroy()
			end)
		end -- end of if contents

		if ItemData[oldName] then
			if ItemData[oldName].deathSoundBank then
				local soundPart = Instance.new("Part")
				soundPart.Size = Vector3.new(0, 0, 0)
				soundPart.CFrame = oldOrigin * CFrame.new(0, -2, 0)
				local soundClone = Rep.Sounds.Bank:FindFirstChild(ItemData[oldName].deathSoundBank):Clone()
				soundClone.PlayOnRemove = true
				soundClone.Parent = soundPart

				soundPart.Parent = workspace
				soundPart:Destroy()
--repeat if not soundClone.TimeLength >0 then wait() end until soundClone.Timelength >0
			end
			if ItemData[oldName] and ItemData[oldName].drops then
				for _, v in next, ItemData[oldName].drops do
					local precipitationRay = Ray.new(oldOrigin.p + Vector3.new(math.random(-30, 30) / 10, 5, math.random(-30, 30) / 10), Vector3.new(0, -15, 0))
					local part, pos = workspace:FindPartOnRay(precipitationRay)
					DropItem({
						["player"] = player,
						["itemName"] = v,
						["cf"] = CFrame.new(pos + Vector3.new(0, .6, 0)),
						["gc"] = Rep.Constants.RelativeTime.Value + 600,
--["autoAnchor"] = false
--["variation"] = true,
					})
				end -- end of for drops loop
			end

			if ItemData[oldName] and ItemData[oldName].possibleDrops then
				for _, dropData in next, ItemData[oldName].possibleDrops do
					local existingItem = ss.Items:FindFirstChild(dropData.name)
					if existingItem then
						local quantity = math.random(dropData.min, dropData.max)
						for i = 1, quantity do
							local precipitationRay = Ray.new(oldOrigin.p + Vector3.new(math.random(-30, 30) / 10, 5, math.random(-30, 30) / 10), Vector3.new(0, -15, 0))
							local part, pos = workspace:FindPartOnRay(precipitationRay)
							DropItem({
								["player"] = player,
								["itemName"] = dropData.name,
								["cf"] = CFrame.new(pos),
								["gc"] = Rep.Constants.RelativeTime.Value + 600,
							})

						end -- end of if end of quantity loop
					end -- end of if existingItem
				end -- end of for possibleDrops loop
			end -- end of if possibleDrops


			if ItemData[oldName].rubble then
				local rubble = ss.Rubble:FindFirstChild(ItemData[oldName].rubble):Clone()
				rubble:SetPrimaryPartCFrame(oldOrigin)
				rubble.Health.Value = ItemData[rubble.Name].health
				rubble.Parent = workspace
				CreateParticles(Rep.Particles.SmokeRubble, rubble.PrimaryPart.CFrame.p, (rubble.PrimaryPart.CFrame * CFrame.new(0, 1, 0)).p, 3, 10, {
					SpreadAngle = Vector2.new(math.random(1, 90), math.random(1, 90))
				})
			end
--if ItemData[oldName].essence and Chance(ItemData[oldName].essence[1]) then
--for i = 1,ItemData[oldName].essence[2] do
--local sundrop = ss.Items.Essence:Clone()
--sundrop.CFrame = oldOrigin*CFrame.new(math.random(0,2),math.random(2,4),math.random(0,2))
--sundrop.Parent = workspace
--sundrop.Velocity = Vector3.new(0,20,0)
---- play the ding sound
--end
--end

			if ItemData[oldName].essence and player then
				GiveEssence(player, ItemData[oldName].essence)
			end
		end -- end of if ItemData[model.Name]
	end -- end of if health.value >0
end -- end of DamageResource()


Rep.Events.NPCAttack.Event:connect(function(thing, damage)
	if thing.ClassName == "Player" then
		DamagePlayer(thing, damage)
	elseif thing.ClassName == "Model" then
		DamageResource(thing, damage)
	end
end)


function Rep.Events.RemoteTextCheck.OnServerInvoke(text)
	local filtered = TextCheck(text) 
	return filtered
end

Rep.Events.PromptSpellChoice.OnServerEvent:Connect(function(p, input)
	--print('Attempt to set spell: '..input)
	local spell = _G.sessionData[p.UserId].spell
	if not spell and input then
		_G.sessionData[p.UserId].spell = input
	elseif spell then
		p:Kick()
	end
end)

--[[
game.Players.PlayerAdded:connect(function(player)
wait(1)
local requestTime = Rep.Constants.RelativeTime.Value
local resultFromPlayer = Rep.Events.PromptClient:InvokeClient(player,
{promptType = "YesNo"}
) -- end of args

if resultFromPlayer and Rep.Constants.RelativeTime.Value-requestTime < 15 then
print("server got a result:",resultFromPlayer) -- this will always be a table
end
end)
]]--


function Rep.Events.RequestData.OnServerInvoke(player)
	local sendData
	repeat
		sendData = _G.sessionData[player.UserId]
		if not sendData then
			wait()
		end
	until sendData
	return _G.sessionData[player.UserId]
end

function Rep.Events.RequestTribeData.OnServerInvoke(player)
	return _G.tribeData
end


function Rep.Events.Pinger.OnServerInvoke(player)
	return true
end


--function UpdateArmor(player)
--local char = player.Character
--if char then
---- clear old armor
--
--_G.sessionData[player.UserId].armor
--
--
--end
--end)


function EquipTool(player, wantNum)
	if _G.sessionData[player.UserId] and not _G.sessionData[player.UserId].hasSpawned then
		return
	end
	
	local char
	if player.Character then
		char = player.Character
	else 
		return
	end
	if (wantNum == _G.sessionData[player.UserId].equipped) or (GetDictionaryLength(_G.sessionData[player.UserId].toolbar[wantNum]) == 0) then
		_G.sessionData[player.UserId].equipped = nil
		ClearTools(char)
	elseif (wantNum ~= _G.sessionData[player.UserId].equipped) and (GetDictionaryLength(_G.sessionData[player.UserId].toolbar[wantNum]) > 0) then
		_G.sessionData[player.UserId].equipped = wantNum
		ClearTools(char)
		local toolClone = ss.Tools:FindFirstChild(_G.sessionData[player.UserId].toolbar[wantNum].name):Clone()
--toolClone:SetPrimaryPartCFrame(char.RightHand.CFrame)
		local weld = Instance.new("Weld", toolClone.Handle)
		weld.Part0 = char.RightHand
		weld.Part1 = toolClone.Handle
		weld.Name = "ToolWeld"
--weld.C0 = CFrame.new(0,0,-(1/2))*CFrame.Angles(math.rad(-90),math.rad(0),math.rad(0))
		weld.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), 0, 0)

		toolClone.Parent = char

	end
	Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
		{
			"SortToolbar",
		}
	})
end
Rep.Events.EquipTool.OnServerEvent:connect(EquipTool)

Rep.Events.MusicTool.OnServerEvent:connect(function(player, timeSwung)
	local char
	if player.Character and player.Character.Humanoid and player.Character.Humanoid.Health > 0 then
		char = player.Character
	else
		return
	end

	local equippedToolName = _G.sessionData[player.UserId].toolbar[_G.sessionData[player.UserId].equipped].name
	local equippedToolData = ItemData[equippedToolName]

	local previous = _G.sessionData[player.UserId].toolbar[_G.sessionData[player.UserId].equipped].lastSwing
	if timeSwung - previous >= equippedToolData.speed then
		_G.sessionData[player.UserId].toolbar[_G.sessionData[player.UserId].equipped].lastSwing = timeSwung
		wait(equippedToolData.noteDelay)
		PlaySoundInObject(Rep.Sounds.Bank:FindFirstChild(equippedToolData.noteName), char.Head, equippedToolData.noteWaver, 6)
	end
end)

Rep.Events.TargetTool.OnServerEvent:connect(function(player, timeSwung, targetPart)
-- determine their tool
	local hasEquipped = _G.sessionData[player.UserId].equipped
	if not hasEquipped then
		return
	end

	local equippedTool = _G.sessionData[player.UserId].toolbar[hasEquipped]
	if ItemData[equippedTool.name] and ItemData[equippedTool.name].saddleLevel then
-- determine if part is a child of a critter that can be saddled
		local saddleTarget
		if targetPart.Parent:IsA("Model") and targetPart.Parent ~= workspace then
			if ItemData[targetPart.Parent.Name] and 
ItemData[targetPart.Parent.Name].saddleable and 
ItemData[targetPart.Parent.Name].saddleLevel <= ItemData[equippedTool.name].saddleLevel and
(targetPart.Position - player.Character.PrimaryPart.Position).magnitude <= 15 and
not (_G.worldStructures[targetPart.Parent] and _G.worldStructures[targetPart.Parent].owner ~= player) then

--remove their saddle tool
				_G.sessionData[player.UserId].toolbar[hasEquipped] = {}
				Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
					{
						"SortToolbar"
					}
				})
				ForceUnequip(player)
-- remove the animal to Replace with a domestic variant
				local oldCF = targetPart.Parent.PrimaryPart.CFrame
				local oldName = targetPart.Parent.Name
				targetPart.Parent:Destroy()
-- find domestic variant
				local newAnimal = ss.Items:FindFirstChild(ItemData[oldName].domesticVariant):clone()
				_G.worldStructures[newAnimal] = {
					owner = player
				}

				if ItemData[newAnimal.Name].dangerZoneDamage then
					_G.worldStructures[newAnimal].lastAttack = Rep.Constants.RelativeTime.Value
					newAnimal:WaitForChild("DangerZone").Touched:connect(function(hit)
						if (Rep.Constants.RelativeTime.Value - _G.worldStructures[newAnimal].lastAttack) >= ItemData[newAnimal.Name].dangerZoneSpeed then
							local munched

							if hit.Parent:FindFirstChild("Health") and (not hit:IsDescendantOf(newAnimal.DangerZone.Parent)) and ItemData[hit.Parent.Name] and ItemData[hit.Parent.Name].health then
--hit.Parent.Health.Value = hit.Parent.Health.Value - ItemData[newAnimal.Name].dangerZoneDamage
								munched = true

								local canDamage = false
								for  damageType, damageAmount  in next, ItemData[newAnimal.Name].damages  do
									if ItemData[hit.Parent.Name].susceptions[damageType] then
										canDamage = damageAmount
									end
								end 

								if canDamage then 
									DamageResource(hit.Parent, canDamage, player) 
								end

							elseif hit.Parent:FindFirstChild("Humanoid") then
								local otherPlayer = game.Players:GetPlayerFromCharacter(hit.Parent)
								if otherPlayer and not AreAllies(_G.worldStructures[newAnimal].owner, otherPlayer) then
-- do damage to the player
									munched = true
									DamagePlayer(otherPlayer, CalculateToolDamageToPlayers(newAnimal.Name, otherPlayer))

								end
							end

-- if an attack went through
							if munched then
								_G.worldStructures[newAnimal].lastAttack = Rep.Constants.RelativeTime.Value
								PlaySoundInObject(Rep.Sounds.Bank:FindFirstChild(ItemData[newAnimal.name].damageSound), newAnimal.Head)
								local emitter = game.ReplicatedStorage.Particles.Teeth:Clone()
								emitter.Parent = newAnimal.Head
								emitter.EmissionDirection = Enum.NormalId.Top
								wait()
								emitter:Emit(1)
							end

						end

					end)
				end

				newAnimal:SetPrimaryPartCFrame(oldCF)
				newAnimal.Parent = workspace.Deployables

			end
		end

	elseif ItemData[equippedTool.name] and ItemData[equippedTool.name].netLevel then
		if targetPart.Parent:IsA("Model") and targetPart.Parent ~= workspace then
			if ItemData[targetPart.Parent.Name] and ItemData[targetPart.Parent.Name].netLevel <= ItemData[equippedTool.name].netLevel and
(targetPart.Position - player.Character.PrimaryPart.Position).magnitude <= 15 then
				GiveItemToPlayer(targetPart.Parent.Name, player)
				targetPart.Parent:Destroy()
			end
		end
	elseif equippedTool.Name == "" then -- insert here
	else -- if equippedTool doesn't match anything
	end
end)


local lastPlayerToolActions = {}
local lastCombatNotices = {}

function CombatTag(player, otherPlayer)
	_G.sessionData[player.UserId].lastCombat = Rep.Constants.RelativeTime.Value
	_G.sessionData[player.UserId].lastAttacker = otherPlayer.Name 

	if player.Character.Head:FindFirstChild("LogNotice") then
		player.Character.Head.LogNotice:Destroy()
	end

	local logNotice = Rep.Guis.LogNotice:Clone()
	logNotice.Parent = player.Character.Head
	debris:AddItem(logNotice, 10)
end



Run.Heartbeat:connect(function(dt)
	Rep.Constants.RelativeTime.Value = Rep.Constants.RelativeTime.Value+dt
end)

Rep.Events.SwingTool.OnServerEvent:connect(function(player, touchedParts)
	local plrData = _G.sessionData[player.UserId]

	local equippedData = plrData.toolbar[plrData.equipped]
	local toolName = equippedData.name
	local toolInfo = ItemData[toolName]
	

	if (Rep.Constants.RelativeTime.Value - equippedData.lastSwing) >= toolInfo.speed then
		local char
		if player.Character and player.Character.Humanoid and player.Character.Humanoid.Health > 0 then
			char = player.Character
		else
			return
		end

		if not plrData.equipped then
			return
		end
		
		
		local previous = plrData.toolbar[plrData.equipped].lastSwing
		if Rep.Constants.RelativeTime.Value - previous >= toolInfo.speed then
			plrData.toolbar[plrData.equipped].lastSwing = Rep.Constants.RelativeTime.Value
-- take their region into account
--[[
if (regionData[1].p-player.Character.PrimaryPart.Position).magnitude < 10 then
print("region is acceptably close")
local region = Region3.new(regionData[2],regionData[3].p) -- left front top, right back bottom
]]--


			local impactedModels = {}
			local lastDamageTypeDone = nil
			for _,v in next, touchedParts do
-- if they hit a resource with "Health" in it
				if v.Parent and v:IsDescendantOf(workspace) and v.Parent:FindFirstChild("Health") and not v.Parent:FindFirstChild("Humanoid") and (v.Position - player.Character.PrimaryPart.Position).magnitude < 15 then
-- if it's a resource
					if ItemData[v.Parent.Name] then
						for damageType, damageAmount in next, toolInfo.damages do
							if ItemData[v.Parent.Name].susceptions[damageType] and not impactedModels[v.Parent] then

								if ItemData[v.Parent.Name].level then
									if toolInfo.level and toolInfo.level >= ItemData[v.Parent.Name].level then
										impactedModels[v.Parent] = damageAmount
									else
										impactedModels[v.Parent] = 0
									end
								else
									impactedModels[v.Parent] = damageAmount
								end

								if v.Parent:FindFirstChild("VehicleSeat") and v.Parent.VehicleSeat.Occupant == player.Character.Humanoid then
									impactedModels[v.Parent] = nil
								else
									lastDamageTypeDone = damageType
								end

								break
							end
						end
					end -- end of if it's ItemData

-- if they hit a real player
				elseif v and v.Parent and v.Parent:FindFirstChild("Humanoid") then
					local otherPlayer = game.Players:GetPlayerFromCharacter(v.Parent)
					if toolInfo.damages.lifeforms and (player.Character.PrimaryPart.Position - v.Parent.PrimaryPart.Position).magnitude < 10 then
						
						if AreAllies(player, otherPlayer) then
-- don't do damage!
						else
							
							DamagePlayer(otherPlayer, toolInfo.damages.lifeforms)
							
							local playerOldCombat, otherPlayerOldCombat = _G.sessionData[player.UserId].lastCombat, _G.sessionData[otherPlayer.UserId].lastCombat
							_G.sessionData[player.UserId].lastCombat = Rep.Constants.RelativeTime.Value
							_G.sessionData[player.UserId].lastAttacker = otherPlayer.Name 
							_G.sessionData[otherPlayer.UserId].lastCombat = Rep.Constants.RelativeTime.Value
							_G.sessionData[otherPlayer.UserId].lastAttacker = player.Name 


							CombatTag(player, otherPlayer)
							CombatTag(otherPlayer, player)

						end
						local sound = FL.GetRandomChild(Rep.Sounds.ToolSounds[toolInfo.toolType]["lifeforms"])
						
						SoundModule.PlaySoundAtLocation(sound.Name,otherPlayer.Character.PrimaryPart.Position)
--						Rep.Events.TargetAcquire:FireClient(player, v.Parent.Name, v.Parent.Humanoid.Health, v.Parent.Humanoid.Health / v.Parent.Humanoid.MaxHealth)
						Rep.Events.RemoteDamageNotify:FireClient(player,
							{name = otherPlayer.Name,
							health = otherPlayer.Character.Humanoid.Health,
							maxHealth = otherPlayer.Character.Humanoid.MaxHealth
							}
						)
						return
					end

				elseif v and v.Parent and v.Parent:FindFirstChild("PseudoHumanoid") then
					if toolInfo.damages.lifeforms then
						v.Parent.PseudoHumanoid.Health.Value = v.Parent.PseudoHumanoid.Health.Value - ItemData[_G.sessionData[player.UserId].toolbar[_G.sessionData[player.UserId].equipped].name].damages.lifeforms
						return
					end

				end -- end of "if find health"
			end

			local lastModelPos = char.PrimaryPart.Position
			
			for model, damageToReceive in next, impactedModels do
				lastModelPos = model.PrimaryPart.Position
				DamageResource(model, damageToReceive, player)
			end
			
			if lastDamageTypeDone then
				local toolType = ItemData[_G.sessionData[player.UserId].toolbar[_G.sessionData[player.UserId].equipped].name].toolType
				local sound = FL.GetRandomChild(Rep.Sounds.ToolSounds[toolType][lastDamageTypeDone])
								SoundModule.PlaySoundAtLocation(sound.Name, lastModelPos)
			end


--end -- end of if region is within 15 studs of the player

		end -- end of attack speed hack check
		Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId])
--lastPlayerToolActions[player] = Rep.Constants.RelativeTime.Value
	end
end) -- end of equipped tool

Rep.Events.CharacterGyroRotation.OnServerEvent:connect(function(player, destination)
	local char
	if player.Character then
		char = player.Character
	end
	char.PrimaryPart.BodyGyro.CFrame = destination
end)


function CanBearLoad(p, itemName)--Limit on farming items too.
	local playerLoad, data = 0, _G.sessionData[p.UserId]
	local maxLoad = 100
	
		local baseLoad = 1
		if itemName == "Essence" or ItemData[itemName].maxLoad then
			baseLoad = 0
		end
	
	if data.armor.bag and data.armor.bag ~= 'none' then
		maxLoad = ItemData[data.armor.bag].maxLoad
	end
	
	for _,slot in next, data.inventory do
		if slot.quantity and ItemData[slot.name] then
			local load = ItemData[slot.name].load or baseLoad
			playerLoad = playerLoad + (slot.quantity * load)
		end
	end
	
	local anticipatedLoad = 0
	if ItemData[itemName].multiPickup then
		for _,dropName in next, ItemData[itemName].multiPickup do
			local load = ItemData[dropName].load or baseLoad
			anticipatedLoad =  anticipatedLoad+load
		end
	else
		anticipatedLoad = ItemData[itemName].load or baseLoad
	end
	return ((playerLoad+anticipatedLoad) <= maxLoad)
end

Rep.Events.Pickup.OnServerEvent:connect(function(player, item)
	if not player.Character then
		return
	end
	
	if (player.Character:FindFirstChild'Humanoid') and not (player.Character.Humanoid.Health > 0) then
		return
	end
	
	if item and (item:IsDescendantOf(workspace)) and ItemData[item.Name].itemType and item:FindFirstChild("Pickup") and WithinDistance(player.Character.PrimaryPart, item, 25) and CanBearLoad(player, item.Name) then

		if ItemData[item.Name].mojoRecipe and not HasMojoRecipe(player, item.Name) then
			Rep.Events.Notify:FireClient(player, "Can't pick up Mojo items", Color3.fromRGB(222, 147, 223), 4)
			return
		end

		if item.Name == "Essence" then
			item:Destroy()
			GiveEssence(player, 10)
			return
		end

		if ItemData[item.Name].coinPickup then
			local value = ItemData[item.Name].coinPickup
			item:Destroy()
			GiveCoin(player, value)
			return
		end

		if ItemData[item.Name].itemType ~= "tool" then

			if ItemData[item.Name].multiPickup then
				for _, v in next, ItemData[item.Name].multiPickup do
					GiveItemToPlayer(v, player)
				end
			else
				GiveItemToPlayer(item.Name, player)
			end

		else -- if it's a tool
			local freeSlotKey
			for key, v in next, _G.sessionData[player.UserId].toolbar do
				if GetDictionaryLength(v) == 0 then
					freeSlotKey = key
					break
				end
			end
			if freeSlotKey then
				_G.sessionData[player.UserId].toolbar[freeSlotKey] = {
					name = item.Name,
					lastSwing = 0
				}
			else 
				_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory + 1] = {
					name = item.Name
				}
			end -- end of if freeSlotKey
		end


		item:Destroy()
		Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
			{
				"DrawInventory"
			},
			{
				"UpdateCraftMenu"
			},
			{
				"SortToolbar"
			}
		})
-- should be softupdate
	end


end)

local lastInteract = {}
Rep.Events.ForceInteract.OnServerEvent:connect(function(player, part)

	local canDrag = true
	if part then
		local dist 
		if part:IsA("Model") then
			dist = (part.PrimaryPart.Position - player.Character.PrimaryPart.Position).magnitude
		elseif part:IsA("BasePart") then
			dist  = (part.Position - player.Character.PrimaryPart.Position).magnitude
		end
		if dist  > 15 then
			return
		end
	end



	if not part then
		if lastInteract[player] then
			if lastInteract[player]:IsDescendantOf(workspace) then
				local setArray = AppendTables({
					{
						lastInteract[player]
					},
					lastInteract[player]:GetChildren()
				})

				for _, v in next, setArray do
					if v:IsA("BasePart") then
						physics:SetPartCollisionGroup(v, "Default")
						v:SetNetworkOwnershipAuto()
					end
				end
			end


			lastInteract[player] = nil
		end
	else
		if part:FindFirstChild("Draggable") then
			local setArray = AppendTables({
				{
					part
				},
				part:GetChildren()
			})
			for _, v in next, setArray do
				if v:IsA("BasePart") then
					v.Anchored = false
					v.CanCollide =  true
					
					for _,obj in next,v:GetDescendants() do
						if obj:IsA("Weld") or obj:IsA("ManualWeld") then
							obj:Destroy()
						end
					end
					
					physics:SetPartCollisionGroup(v, "Draggers")
					if not v.Anchored then
						v:SetNetworkOwner(player)
					end
				end
			end

			if lastInteract[player] then
				if lastInteract[player]:IsDescendantOf(workspace) then
					local setArray = AppendTables({
						{
							lastInteract[player]
						},
						lastInteract[player]:GetChildren()
					})

					for _, v in next, setArray do
						if v:IsA("BasePart") then
							physics:SetPartCollisionGroup(v, "Default")
							v:SetNetworkOwnershipAuto()
						end
					end
				end
			end
			lastInteract[player] = part
		end
	end
end)


--local recentDrops = {}
--
--local dropRoutine = coroutine.wrap(function()
--	while wait(1/5) do
--		for player,amt in next,recentDrops do
--			recentDrops[player] = math.clamp((amt or 0)-1,math.huge,0)
--		end
--	end
--end)
--dropRoutine()

Rep.Events.DropBagItem.OnServerEvent:connect(function(player, itemName)
	if ItemData[itemName].mojoRecipe or ItemData[itemName].noDrop then
		Rep.Events.Notify:FireClient(player, "Can't drop Unique items", Color3.fromRGB(222, 147, 223), 4)
		return
	end

	local hasKey = HasItem(player, itemName)
	if hasKey then

		if ItemData[itemName].itemType ~= "tool" then
			_G.sessionData[player.UserId].inventory[hasKey].quantity = math.clamp(_G.sessionData[player.UserId].inventory[hasKey].quantity - 1, 0, math.huge)
			
			if _G.sessionData[player.UserId].inventory[hasKey].quantity <= 0 then
				table.remove(_G.sessionData[player.UserId].inventory,hasKey)
			end

		else
			table.remove(_G.sessionData[player.UserId].inventory,hasKey)
			CleanInventory(player)
		end
	else
-- they don't have enough to drop this!
		return
	end
	CleanInventory(player)
	local itemInfo = ItemData[itemName]
	local itemClone
	if ItemData[itemName].itemType == "food" or ItemData[itemName].itemType == "armor" or ItemData[itemName].itemType == "object" then
		DropItem({
			["player"] = player,
			["itemName"] = itemName,
			["cf"] = player.Character.PrimaryPart.CFrame * CFrame.new(0, 2, -6),
			["gc"] = Rep.Constants.RelativeTime.Value + 600,
		})
	elseif ItemData[itemName].itemType == "tool" then
		itemClone = ss.Tools:FindFirstChild(itemName):Clone()
		AddValueObject(itemClone, "Pickup", "BoolValue", true)
		AddValueObject(itemClone, "Drag", "BoolValue", true)
		itemClone:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame * CFrame.new(0, 2, -6))

		for _, v in next, itemClone:GetChildren() do
			if v:IsA("BasePart") then
				v.CanCollide = true
			end
		end
		itemClone.Parent = workspace
	end

--if itemClone.Name == "Lurky Boi" then
--local part,pos,norm,mat = RayUntil(player.Character.PrimaryPart.Position,Vector3.new(0,-100,0))
--if mat == Enum.Material.Water then
--itemClone = ss.Items:FindFirstChild("Beached Boi"):Clone()
--itemClone.CFrame = pos
--end
--else -- if there is  no exception to the parent
--itemClone.Parent = workspace
--end

	debris:AddItem(itemClone, 360)

	Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
		{
			"DrawInventory"
		},
		{
			"UpdateStats"
		},
		{
			"UpdateCraftMenu"
		}
	})
--softupdate
end)

Rep.Events.ToolSwap.OnServerEvent:connect(function(player, key1, key2)
	_G.sessionData[player.UserId].toolbar[key1], _G.sessionData[player.UserId].toolbar[key2] =
	_G.sessionData[player.UserId].toolbar[key2], _G.sessionData[player.UserId].toolbar[key1]
	if _G.sessionData[player.UserId].equipped == key1 then
		EquipTool(player, key2)
	elseif _G.sessionData[player.UserId].equipped == key2 then
		EquipTool(player, key1)
	end

	Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
		{
			"SortToolbar"
		}
	})
end)


Rep.Events.Retool.OnServerEvent:connect(function(player, key)
	if GetDictionaryLength(_G.sessionData[player.UserId].toolbar[key]) > 0 then
		local toolInfo = _G.sessionData[player.UserId].toolbar[key]
		if _G.sessionData[player.UserId].equipped == key then
			ForceUnequip(player)
		end
		_G.sessionData[player.UserId].toolbar[key] = {}
		_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory + 1] = {
			["name"] = toolInfo.name
		}
	end
	Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
		{
			"DrawInventory"
		},
		{
			"SortToolbar"
		}
	})
end)

Rep.Events.Consume.OnServerEvent:connect(function(player, item)
	if item and ((ItemData[item.Name] and ItemData[item.Name].nourishment and item:FindFirstChild("Pickup") and  item:IsDescendantOf(workspace)) or item.Material == Enum.Material.Water) and (item.Position - player.Character.PrimaryPart.Position).magnitude <= 25 then
		
		local itemFood = ItemData[item.Name].nourishment.food or 0
		local itemHealth = ItemData[item.Name].nourishment.health or 0
		local itemOverheal = ItemData[item.Name].nourishment.overHeal or 0
		local itemVoodoo = ItemData[item.Name].nourishment.voodoo or 0
		
		if item ~= workspace.Terrain then
			item:Destroy()
		end
		
		_G.sessionData[player.UserId].stats.food = math.clamp((_G.sessionData[player.UserId].stats.food or 0) + itemFood, 0, 100)
		_G.sessionData[player.UserId].stats.overHeal = math.clamp((_G.sessionData[player.UserId].stats.overHeal or 0) + itemOverheal, 0, 1000)
		_G.sessionData[player.UserId].stats.voodoo = math.clamp((_G.sessionData[player.UserId].stats.voodoo or 0) + itemVoodoo, 0, 100)
	
		if player.Character.Humanoid and player.Character.Humanoid.Health >= 0 then 
			player.Character.Humanoid.Health = math.clamp(player.Character.Humanoid.Health + itemHealth, 0, player.Character.Humanoid.MaxHealth)
		end
		Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
			{
				"UpdateStats"
			}
		})
	end
end)

Rep.Events.UseBagItem.OnServerEvent:connect(function(player, itemName)
	local hasKey = HasItem(player, itemName)
	if hasKey then
		local itemInfo = ItemData[itemName]

		if itemInfo.itemType == "tool" then
			local emptySlot
			for openKey, v in next, _G.sessionData[player.UserId].toolbar do
				if GetDictionaryLength(v) == 0 then
					emptySlot = openKey
					break
				end
			end
			if not emptySlot then
-- tell player they have no empty slot
				return
			else
				table.remove(_G.sessionData[player.UserId].inventory,hasKey)
				_G.sessionData[player.UserId].toolbar[emptySlot] = {
					["name"] = itemName,
					lastSwing = 0
				}
				CleanInventory(player)
			end

		elseif itemInfo.itemType == "building" then

		elseif itemInfo.itemType == "armor" then
--clear their char of any current armor

			if _G.sessionData[player.UserId].inventory[hasKey].quantity >= 1 then
				_G.sessionData[player.UserId].inventory[hasKey].quantity = _G.sessionData[player.UserId].inventory[hasKey].quantity - 1
				CleanInventory(player)
			else
				return
			end

-- if there was armor in the slot, return it to their inventory
			if _G.sessionData[player.UserId].armor[itemInfo.locus] and _G.sessionData[player.UserId].armor[itemInfo.locus]  ~= "none" then
				local otherArmorKey = HasItem(player, _G.sessionData[player.UserId].armor[itemInfo.locus])
				if otherArmorKey then
					_G.sessionData[player.UserId].inventory[otherArmorKey].quantity = _G.sessionData[player.UserId].inventory[otherArmorKey].quantity + 1
				else
					_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory + 1] = {
						name = _G.sessionData[player.UserId].armor[itemInfo.locus],
						quantity = 1
					}
				end
			end

			_G.sessionData[player.UserId].armor[itemInfo.locus] = itemName


			SetupAppearance(player)
			Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
				{
					"DrawInventory"
				},
				{
					"UpdateArmor"
				}
			})

		elseif itemInfo.nourishment then
			if player.Character.Humanoid and player.Character.Humanoid.Health > 0 then
				_G.sessionData[player.UserId].inventory[hasKey].quantity = _G.sessionData[player.UserId].inventory[hasKey].quantity - 1
				CleanInventory(player)
				
				_G.sessionData[player.UserId].stats.food = math.clamp(_G.sessionData[player.UserId].stats.food + (itemInfo.nourishment.food or 0), 0, 100)
				_G.sessionData[player.UserId].stats.overHeal = math.clamp(_G.sessionData[player.UserId].stats.overHeal + (itemInfo.nourishment.overHeal or 0), 0, 100)
				player.Character.Humanoid.Health = math.clamp(player.Character.Humanoid.Health + (itemInfo.nourishment.health or 0), 0, player.Character.Humanoid.MaxHealth)
			end
		end -- end of If item type

		Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
			{
				"UpdateStats"
			},
			{
				"DrawInventory"
			},
			{
				"SortToolbar"
			}
		} )

-- they don't have this item.. how did they request it??
	end
end)

Rep.Events.CraftItem.OnServerEvent:connect(function(player, itemName)
	if CanCraftItem(player, itemName) then
		for ingredientName, ingredientQuantity in next, ItemData[itemName].recipe do
			local hasIngredientKey = HasItem(player, ingredientName)
			_G.sessionData[player.UserId].inventory[hasIngredientKey].quantity = _G.sessionData[player.UserId].inventory[hasIngredientKey].quantity - ingredientQuantity
		end
		CleanInventory(player)
		
		local itemInfo = ItemData[itemName]
		
		if itemInfo.itemType == "tool" then
			-- check first if they have open space in their hotbar
			
			local openSlot
			for key, val in next, _G.sessionData[player.UserId].toolbar do
				if GetDictionaryLength(val) == 0 then
					openSlot = key
					break
				end
			end
			if openSlot then
				_G.sessionData[player.UserId].toolbar[openSlot] = {
					name = itemName,
					lastSwing = 0
				}
			else
				_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory + 1] = {
					name = itemName,
				quantity = 1
				}
			end

		elseif ((itemInfo.ItemType == "armor") or (itemInfo.itemType == "bag")) and (not (not _G.sessionData[player.UserId].armor[itemInfo.locus]) or (_G.sessionData[player.UserId].armor[itemInfo.locus] and _G.sessionData[player.UserId].armor[itemInfo.locus] ~= nil))  then
			_G.sessionData[player.UserId].inventory.armor[itemInfo.locus] = itemName
			SetupAppearance(player)
		
		else -- elseif not itemType == "tool"
			local hasItemKey = HasItem(player, itemName)
			if hasItemKey then
				_G.sessionData[player.UserId].inventory[hasItemKey].quantity = _G.sessionData[player.UserId].inventory[hasItemKey].quantity + ItemData[itemName].craftQuantity
			else
				_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory + 1] = {
					name = itemName,
					quantity = ItemData[itemName].craftQuantity
				}
			end
		end -- end of item type

		Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
			{
				"DrawInventory"
			},
			{
				"UpdateCraftMenu"
			},
			{
				"SortToolbar"
			},
			{
				"UpdateArmor"
			}
		})
-- softupdate
	end -- end of if cancraft
end)


Rep.Events.DropTool.OnServerEvent:connect(function(player, toolKey)
	local toolSlotInfo = _G.sessionData[player.UserId].toolbar[toolKey]

	if toolSlotInfo.name and (ItemData[toolSlotInfo.name].noDrop or ItemData[toolSlotInfo.name].mojoRecipe) then 
		Rep.Events.Notify:FireClient(player, "Can't drop Unique items", Color3.fromRGB(222, 147, 223), 4)
		return 
	end

	if GetDictionaryLength(toolSlotInfo) > 0 then
		_G.sessionData[player.UserId].toolbar[toolKey] = {}
		local toolData = ItemData[toolSlotInfo.name]
		local toolClone = ss.Tools:FindFirstChild(toolSlotInfo.name):Clone()
		toolClone:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame * CFrame.new(0, 2, -4))
		AddValueObject(toolClone, "Pickup", "BoolValue", true)
		AddValueObject(toolClone, "Draggable", "BoolValue", true)
		for _, v in next, toolClone:GetDescendants() do
			if v:IsA("BasePart") then
				v.CanCollide = true
			end
		end
		toolClone.Parent = workspace
		debris:AddItem(toolClone, 360)
		if _G.sessionData[player.UserId].equipped == toolKey then
			ForceUnequip(player)
		end
		Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
			{
				"SortToolbar"
			}
		} )
	end
end)

Cooldown_Placement = {}

Rep.Events.PlaceStructure.OnServerEvent:connect(function(player, buildingName, origin, rotY)
	local found
	for i, v in pairs(Cooldown_Placement) do
		if i == player then
			found = true
			local elapsed = os.time() - v
			if elapsed < .4 then
				return
			else
				i = nil
			end
		elseif os.time() - v < .4 then
			i = nil
		end
	end
	if not found then
		Cooldown_Placement[player] = os.time()
	end
	
--local xRot,yRot,zRot = origin:toEulerAnglesXYZ()
	if buildingName == "Tribe Totem" or (ItemData[buildingName].recipe and CanCraftItem(player, buildingName)) then
	else
		return
	end
	local canPlace = true


	local function ReturnIgnoreList()
		local IgnoreList = {}
	
		for i, v in pairs(workspace.Critters:GetChildren()) do
			table.insert(IgnoreList, v)
		end
	
		for i, v in pairs(workspace.Deployables:GetChildren()) do
			table.insert(IgnoreList, v)
		end
	
		for _, p in pairs(game.Players:GetChildren()) do
			if p.Character then
				table.insert(IgnoreList, p.Character)
			--[[
			for i,v in pairs(p.Character:GetDescendants()) do
				if v:IsA'BasePart' then
					table.insert(IgnoreList, v)
				end
			end
			--]]
			end
		end
	
		return IgnoreList
	end


	local IgnoreList = ReturnIgnoreList()

	local ray = Ray.new(origin.p + Vector3.new(0, 2, 0), -Vector3.new(0, 5, 0))
	local part, pos, norm, mat = workspace:FindPartOnRayWithIgnoreList(ray, IgnoreList)

	if part and origin.p.Y - pos.Y > 1 then
		canPlace = false
		return
	elseif not part then
		canPlace = false
		return
	end

	for i, v in pairs(workspace.Deployables:GetChildren()) do
		local part = v:FindFirstChild'Reference' or v:FindFirstChild'MainPart'
		if part then
			local dist = (part.Position - origin.p).magnitude
			if buildingName == 'Chest' then
				if dist <= 2 then
					Rep.Events.Notify:FireClient(player, 'Too close to another structure.', ColorData.badRed, 2)
					canPlace = false
					return
				end
			else
				if dist <= (part.Name == 'MainPart' and 15 or 6) then
					Rep.Events.Notify:FireClient(player, 'Too close to another structure.', ColorData.badRed, 2)
					canPlace = false
					return
				end
			end
		end
	end

	local part, pos, norm, mat = RayUntil(origin.p + Vector3.new(0, 10, 0), Vector3.new(0, -1000, 0))
-- rules for a generic building

--	for _, v in next, game.Players:GetPlayers() do
--		if (v.Character) and (v ~= player) then
--			local dist = (origin.p - v.Character.PrimaryPart.Position).magnitude
--			if buildingName == 'Iron Turret' then
--				if dist < 25 then
--					Rep.Events.Notify:FireClient(player, "Don't build on "..v.Name.."'s head!", ColorData.badRed, 2)
--					canPlace = false
--				end
--				
--			elseif buildingName == "Dock" then
--				if dist < 20 then
--					Rep.Events.Notify:FireClient(player, "Don't build on "..v.Name.."'s head!", ColorData.badRed, 2)
--					canPlace = false
--				end
--			end
--			
--			if buildingName == 'Chest' or buildingName == "Iron Strongbox" then
--				if player.Character.Head:FindFirstChild("LogNotice") then
--					Rep.Events.Notify:FireClient(player, "Chest trapping noooooob", ColorData.badRed, 4)
--					origin = player.Character.PrimaryPart.CFrame * CFrame.new(0, -2, 0)
--				else
--					Rep.Events.Notify:FireClient(player, "Don't build on "..v.Name.."'s head!", ColorData.badRed, 2)
--					canPlace = false
--				end
--			end
--		end
--	end


	if (origin.p - player.Character.PrimaryPart.Position).magnitude > 50 then
		canPlace = false
	end
--if (part~= workspace.Terrain) and ItemData[buildingName].itemType == "allBuilding" then canPlace = false end
	if (part ~= workspace.Terrain) and ItemData[buildingName].placement ~= "all" then
		canPlace = false
	end
	if mat and mat == Enum.Material.Water and (ItemData[buildingName].placement ~= "sea" and ItemData[buildingName].placement ~= "all") then
		canPlace = false
	end
	if mat and mat ~= Enum.Material.Water and ItemData[buildingName].placement == "sea" then
		canPlace = false
	end
	for _, v in next, spawnLocations do
		if ItemData[buildingName].placement ~= "sea" and (origin.p - v.p).magnitude < 25 then
			canPlace = false
			Rep.Events.Notify:FireClient(player, "Can't build less than 25 studs from a spawn", ColorData.badRed, 2)
			break
		end
	end
	local closestTotem, distance = NearestTotemAndDistance(player, pos)
	if distance < 500 then
		Rep.Events.Notify:FireClient(player, "This land is claimed by the "..closestTotem.Name, ColorData.badRed, 4)
		canPlace = false
	end

	if canPlace then
-- remove the ingredients
		if ItemData[buildingName].recipe then
			for ingredientName, ingredientQuantity in next, ItemData[buildingName].recipe do
				local hasKey = HasItem(player, ingredientName)
				if hasKey and _G.sessionData[player.UserId].inventory[hasKey].quantity >= ingredientQuantity then
					_G.sessionData[player.UserId].inventory[hasKey].quantity = _G.sessionData[player.UserId].inventory[hasKey].quantity - ingredientQuantity
				end
			end
			CleanInventory(player)
		end -- end of if recipe name
	else
-- tell them they don't have the required structure
		return
	end
	local newStructure = Rep.Deployables:FindFirstChild(buildingName):Clone()
	newStructure:SetPrimaryPartCFrame(origin)
--_G.sessionData[player.UserId].structures[#_G.sessionData[player.UserId].structures+1] = {name = buildingName,location = CFrame.new(origin)*CFrame.Angles(0,math.rad(rotY),0)}

-- assemble the structure data
	local structureData = {}
	if buildingName == "Campfire" then
		structureData.fuel = 100

	elseif buildingName == "Plant Box" then
		structureData.growing = nil
		structureData.progress = 0

	elseif buildingName == "Grinder" then
		structureData.grinding = nil

	elseif buildingName == "Chest" then
		structureData.contans = {}

	elseif buildingName == "Nest" then
		structureData.progress = 0
		structureData.hasBaby = true
		structureData.hasHen = false
		structureData.hasEgg = false

	elseif buildingName == "Fish Trap" then
		structureData.progress = 0
		structureData.hasFish = false


--	elseif buildingName == "Market" then
--		structureData.coinProgress = 0
--		newStructure.InputTouch.Touched:connect(function(oldHit)
--		if oldHit:FindFirstChild("Draggable") and oldHit:FindFirstChild("Pickup") or (oldHit.Parent and (oldHit.Parent:FindFirstChild("Draggable") and oldHit.Parent:FindFirstChild("Pickup"))) then
--			local hitName
--			
--			if oldHit.Parent:IsA("Model") and oldHit.Parent ~= workspace then
--				hitName = oldHit.Parent.Name
--			elseif oldHit.Parent == workspace then
--				hitName = oldHit.Name
--			end
--			
--			if ItemData[hitName] and ItemData[hitName].coinValue then
--				if oldHit.Parent:IsA("Model") and oldHit.Parent ~= workspace then
--					oldHit.Parent:Destroy()
--					elseif oldHit.Parent == workspace then
--					oldHit:Destroy()
--				end
--		-- pump coins into the coin slot
--		--local extra = 0
--		--if structureData.coinProgress+ItemData[hitName].coinValue > 1 then
--		--extra = 1- (structureData.coinProgress+ItemData[hitName].coinValue)
--		--end
--				structureData.coinProgress = structureData.coinProgress+ItemData[hitName].coinValue
--				
--				if structureData.coinProgress >= 1 then
--					local leftOver = structureData.coinProgress-1
--					structureData.coinProgress = 0+leftOver
--					DropItem({
--					["player"] = player,
--					["itemName"] = "Gold Coin",
--					["cf"] = newStructure.OutputPart.CFrame,
--					["gc"] = Rep.Constants.RelativeTime.Value+300,
--					})
--				end
--				newStructure.Board.SurfaceGui.Frame.Slider.Size = UDim2.new(math.clamp(structureData.coinProgress,0,1),0,1,0)
--			end
--		
--			end
--		
--		end)



	elseif buildingName == "Tribe Totem" then
-- if they are in a tribe
		local tribeKey, tribeInfo = HasTribe(player)
		local canPlaceTotem = true

		if not tribeInfo then
			canPlaceTotem = false
		end
		
		if tribeInfo and (tribeInfo.chief ~= player.Name) then 
			canPlaceTotem = false 
		end

		local totem
		for _, v in next, workspace.Totems:GetChildren() do
			if v.TribeColor.Value == tribeKey then
				totem = v
			end
		end

		if totem then
-- totem already exists
			canPlaceTotem = false
		end

		if tribeInfo and  Rep.Constants.RelativeTime.Value - _G.tribeData[tribeKey].lastTotemTimer < 300 then
			canPlaceTotem = false
			Rep.Events.Notify:FireClient(player, "You must wait "..math.floor(300 - (Rep.Constants.RelativeTime.Value - _G.tribeData[tribeKey].lastTotemTimer)).." seconds before placing another Totem!", ColorData.badRed, 5)
		end

		if canPlaceTotem then
			newStructure.TribeColor.Value = tribeKey
			newStructure.Parent = workspace.Totems
			newStructure.AncestryChanged:connect(function()
				_G.tribeData[tribeKey].lastTotemTimer = Rep.Constants.RelativeTime.Value
			end)

-- color it to tribe color
			for _, v in next, newStructure:GetChildren() do
				if v.Name == "Coloration" then
					v.Color = ColorData.TribeColors[tribeKey]
				end
			end
		end -- end of if canplacetotem
		return -- return if totel
--elseif buildingName == ""  something else
	end

-- determine how this should be logged in the structure table
	_G.worldStructures[newStructure] = {
		lastCheck = Rep.Constants.RelativeTime.Value,
		name = buildingName,
		owner = player,
		specificData = structureData,
	}

	newStructure.AncestryChanged:connect(function(child, parent)
		if not parent then
			_G.worldStructures[newStructure] = nil
		end
	end)

--AddValueObject(newStructure,"Owner","ObjectValue",player)
	newStructure.Health.Value = ItemData[buildingName].health
	newStructure.Parent = workspace.Deployables
	Rep.Events.PlaySoundOnClient:FireClient(player,"Construction",origin.p)
-- play a placement sound in the structure
	Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
		{
			"DrawInventory"
		},
		{
			"UpdateCraftMenu"
		}
	})
-- softupdate
--Rep.Events.Notify:FireClient(player,"Placed "..buildingName.."!",ColorData.goodGreen)
end)

function TextCheck(text)
--local filtered = game:GetService("Chat"):FilterStringForBroadcast(text)
	local filtered = "for testing"
	if filtered then
		return filtered
	else
		return nil
	end
end


skinColorList = {
	LeftUpperArm = true,
	LeftLowerArm = true,
	LeftHand = true,
	RightUpperArm = true,
	RightLowerArm = true,
	RightHand = true,
	Head = true,
}

bodyColorList = {
	["LeftUpperLeg"] = true,
	["LeftLowerLeg"] = true,
	["LeftFoot"] = true,
	["RightUpperLeg"] = true,
	["RightLowerLeg"] = true,
	["RightFoot"] = true,
	["UpperTorso"] = true,
	["LowerTorso"] = true, 
}


ColorCharacter = function(player)
	if player then -- they might have left
		local char = player.Character
		if char then
			local bodyColors = char:WaitForChild("Body Colors")
			local hasTribe = HasTribe(player)
			local coloration
			if hasTribe then
				coloration = ColorData.TribeColors[hasTribe]
			else
				coloration = ColorData.basicBrown
			end
			
			bodyColors.LeftLegColor3 = coloration
			bodyColors.RightLegColor3 = coloration
			bodyColors.TorsoColor3 = coloration
		end
	end
end

--Rep.Events.CreateTribe.OnServerEvent:connect(function(player, chosenColor, chosenWay)
--	for tribeKey, tribeInfo in next, _G.tribeData do
--		if (tribeData.color == chosenColor)  or (tribeData.members[player.Name]) or (tribeData.chief == player.Name) then
---- tell them that the clan color already exists
--			Rep.Events.Notify:FireClient(player, "This tribe already exists")
--			return
--		end
--	end 
--
--	_G.tribeData[#_G.tribeData + 1] = {
--		color = chosenColor,
--		chief = player.Name,
--		members = {},
--		message = "",
--		diplomacy = {},
--		way = chosenWay,
--	}
--
--	ColorCharacter(player, ColorData.TribeColors[chosenColor])
--	Rep.Events.Notify:FireAllClients("Chief "..player.Name.." has founded the "..chosenColor.." tribe", ColorData.TribeColors[chosenColor], 6)
--	Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
--		{
--			"OpenGui"
--		}
--	})
--	UpdateAllPlayerLists()
--end)
--
--function IsMemberOfTribe(player, tribeInfo)
--	local  ismember
--	for memberKey, memberInfo in next, tribeInfo.members do
--		if player.Name == memberInfo then
--			ismember = memberKey, memberInfo
--		end
--	end
--	return ismember
--end
--
--function HasTribe(player)
--	for tribeKey, tribeInfo  in next, _G.tribeData do
--		if IsMemberOfTribe(player, tribeInfo) or tribeInfo.chief  == player.Name then
--			return tribeKey, tribeInfo
--		end 
--	end
--	return false
--end 



--[[
Rep.Events.TribeInvite.OnServerEvent:connect(function(player,str)
local originTribe = HasTribe(player)
if not originTribe then return end

local otherPlayer

for _,v in next,game.Players:GetPlayers() do
if v.Name == str then
otherPlayer = v
break
end
if string.match(str,v.Name) then
otherPlayer = v
end
end

if  not otherPlayer then
Rep.Events.Notify:FireClient(player,"This player could not be found")
return
end
if HasTribe(player) then
Rep.Events.Notify:FireClient(player,"This player is already in a tribe")
return
end

local request = 15
local  result = game.ReplicataedStorage.PromptClient("YesNo","Join the"..HasTribe(otherPlayer).color.." Tribe?")
if result then
originTribe.members[otherPlayer] = true
end

end)
]]--

--Rep.Events.TribeInvite.OnServerEvent:connect(function(player, otherPlayer)
--	if (Rep.Constants.RelativeTime.Value - _G.sessionData[player.UserId].lastSpamRequest) < 1 then
--		Rep.Events.Notify:FireClient(player, "Slow your requests")
--		return
--	end
--	
--	_G.sessionData[player.UserId].lastSpamRequest = Rep.Constants.RelativeTime.Value
--
--
--	local tribeKey, tribeInfo = HasTribe(player)
--
--	if not tribeKey then
--		Rep.Events.Notify:FireClient(player, "You are not in a tribe!", ColorData.badRed)
--	end
--
--	if not otherPlayer then
--		Rep.Events.Notify:FireClient(player, "That player is not in the game", ColorData.badRed)
--		return
--	end
--
--	local otherTribe = HasTribe(otherPlayer)
--	if otherTribe then
--		Rep.Events.Notify:FireClient(player, otherPlayer.Name.." is already in a tribe", ColorData.badRed)
--		return
--	end
--
--	if tribeKey and tribeInfo.chief ~= player.Name then
--		local request = Rep.Constants.RelativeTime.Value
--		local received = Rep.Events.PromptClient:InvokeClient(game.Players:FindFirstChild(tribeData.chief), {
--			promptType = "YesNo",
--			message = player.Name.." wants to invite "..otherPlayer.Name.." to the tribe. Accept?"
--		})
--
--		if received and received.result and received.result == "yes" and Rep.Constants.RelativeTime.Value - request < 15 then
--			received, request = nil, Rep.Constants.RelativeTime.Value
--		else
--			return
--		end
--		local request = Rep.Constants.RelativeTime.Value
--		
--		if not _G.sessionData[otherPlayer.UserId].userSettings.muteTribeInvitations then
--			local received = Rep.Events.PromptClient:InvokeClient(otherPlayer, {
--				promptType = "YesNo",
--				message = player.Name.." invited you to the "..tribeData.color.." tribe"
--			})
--	
--			if received and received.result and received.result == "yes" and Rep.Constants.RelativeTime.Value - request < 15  and not HasTribe(otherPlayer.Name) then
--	-- otherPlayer successfully wants to join the origin tribe!
--	-- notify the other members
--				table.insert(_G.tribeData[tribeKey].members, otherPlayer.Name)
--				ColorCharacter(otherPlayer, ColorData.TribeColors[tribeData.color])
--	
--				local chiefPlayer = game.Players:FindFirstChild(_G.tribeData[tribeKey].chief)
--				if chiefPlayer then
--					Rep.Events.Notify:FireClient(chiefPlayer, otherPlayer.Name.." has joined the tribe!", ColorData.TribeColors[tribeData.color])
--				end
--	
--				for _, memberName in next, _G.tribeData[tribeKey].members do
--					local memberPlayer = game.Players:FindFirstChild(memberName) 
--					if memberPlayer then
--						Rep.Events.Notify:FireClient(memberPlayer, otherPlayer.Name.." has joined the tribe!", ColorData.TribeColors[tribeData.color])
--					end
--				end
--				UpdateAllPlayerLists()
--	--Rep.Events.Notify:FireClient(v,otherPlayer.Name.." has joined the tribe!",ColorData.TribeColors[tribeData.color])
--			else
--				return
--			end
--		end
--
--	elseif tribeKey and tribeInfo.chief == player.Name then
--		local request = Rep.Constants.RelativeTime.Value
--		if not _G.sessionData[otherPlayer.UserId].userSettings.muteTribeInvitations then
--			local received = Rep.Events.PromptClient:InvokeClient(otherPlayer, {
--				["promptType"] = "YesNo",
--				["message"] = player.Name.." invited you to the "..tribeData.color.." tribe"
--			})
--			if received and received.result and received.result == "yes" and Rep.Constants.RelativeTime.Value - request < 15 and not HasTribe(otherPlayer) then
--	-- otherPlayer successfully wants to join the origin tribe!
--	-- notify the other members
--				table.insert(_G.tribeData[tribeKey].members, otherPlayer.Name)
--				ColorCharacter(otherPlayer, ColorData.TribeColors[tribeData.color])
--	
--				for _, v in next, game.Players:GetPlayers() do
--					local tribeKey1, tribeInfo1 = HasTribe(v)
--					if tribeKey1 and (IsMemberOfTribe(v, tribeInfo) or tribeInfo.chief == v.Name) then
--						Rep.Events.UpdateData:FireClient(v, _G.sessionData[v.UserId], {
--							{
--								"DrawTribeGui"
--							}
--						})
--						Rep.Events.Notify:FireClient(v, otherPlayer.Name.." has joined the tribe!", ColorData.TribeColors[tribeData.color])
--					end
--				end
--				UpdateAllPlayerLists()
--	--Rep.Events.Notify:FireClient(v,otherPlayer.Name.." has joined the tribe!",ColorData.TribeColors[tribeData.color])
--			else
--				return
--			end -- end of if result and request
--		end
--	end -- end of if tribekey and chief == 
--end)
--
--function PromoteToChief()
--end

function NearestTotemAndDistance(player, pos)
	local ignoreTotemColor
	local tribeKey, tribeInfo = HasTribe(player)
	if tribeInfo then
		ignoreTotemColor = tribeInfo.color
	end

	local closestTotem, closestDistance = nil, math.huge
	for _, totem in next, workspace.Totems:GetChildren() do
		if totem.TribeColor.Value ~= ignoreTotemColor then
			local distance = (totem.PrimaryPart.Position - pos).magnitude
			if distance < closestDistance then
				closestTotem, closestDistance = totem, distance
			end
		end
	end

	return closestTotem, closestDistance

end

--function RemovePlayerFromTribe(player)
---- determine which tribe the player is in
--	local tribeKey, tribeInfo = HasTribe(player)
--	if not tribeKey then
--		return
--	end
--	ColorCharacter(player, ColorData.basicBrown)
---- regardless, they're leaving
--	local position
--	if _G.tribeData.chief == player.Name then
--		position = "chief"
--	elseif IsMemberOfTribe(player, tribeInfo) then
--		position = "member"
--	end
--
--	if position == "chief" then
----[[
--if GetDictionaryLength(tribeData.members) >0 then
--local m = {}
--for _,v in next,tribeData.members do
--m[#m+1] = v
--end
--local chosen = m[math.random(1,#m)]
--_G.tribeData[tribeKey].chief = chosen
--_G.tribeData[tribeKey].members[chosen] = nil
--else
--table.remove(_G.tribeData,tribeKey)
--end
--]]--
--		Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
--			{
--				"OpenGui"
--			},
--			{
--				"DrawTribeGui"
--			}
--		})
---- remove the 
--		local totemName = tribeInfo.color.." Totem"
--		local totem
--		for _, v in next, workspace.Totems:GetChildren() do
--			if v.TribeColor.Value == tribeInfo.color then
--				totem = v
--			end
--		end
--
--		if totem then 
--			totem:Destroy()
--			lastTotemTimers[tribeData.color] = Rep.Constants.RelativeTime.Value
--		end
--		ColorCharacter(player, ColorData.basicBrown)
--		for _, memberName in next, tribeInfo.members do -- kick all the remaining members
--			local memberPlayer = game.Players:FindFirstChild(memberName)
--			if memberPlayer then
--				ColorCharacter(memberPlayer, ColorData.basicBrown)
--				Rep.Events.UpdateData:FireClient(memberPlayer, _G.sessionData[memberPlayer.UserId], {
--					{
--						"OpenGui"
--					},
--					{
--						"DrawTribeGui"
--					}
--				})
--				Rep.Events.Notify:FireClient(memberPlayer, "Your tribe has disbanded", ColorData.badRed, 4)
--			end
--		end
---- destroy the tribe, the chief left
--		table.remove(_G.tribeData, tribeKey)

--	elseif position == "member" then
--		for key, memberName in next, _G.tribeData[tribeKey].members do
--			if memberName == player.Name then
--				local memberPlayer = game.Players:FindFirstChild(memberName)
--				if memberPlayer then
--					Rep.Events.UpdateData:FireClient(memberPlayer, _G.sessionData[memberPlayer.UserId], {
--						{
--							"OpenGui"
--						},
--						{
--							"DrawTribeGui"
--						}
--					})
--				end -- end of if memberplayer
--				table.remove(_G.tribeData[tribeKey].members, key)
--				break
--			end
--		end
--
--	end
--	UpdateAllPlayerLists()
--end

--function Rep.Events.RelayChestContents(player,chest)
--if _G.worldStructures[chest] then
--return _G.worldStructures[chest].contents
--end
--end


Cooldown_Stru = {}

Rep.Events.InteractStructure.OnServerEvent:connect(function(player, structure, itemName)
	if structure.Name == "Plant Box" then
		local found
		for i, v in pairs(Cooldown_Stru) do
			if i == player then
				found = true
				local elapsed = os.time() - v
				if elapsed < .5 then
					return
				else
					i = nil
				end
			elseif os.time() - v < .5 then
				i = nil
			end
		end
		if not found then
			Cooldown_Stru[player] = os.time()
		end
	end
	
	if structure.Name == "Campfire" then
		local hasKey = HasItem(player, itemName)
		if hasKey then
			_G.sessionData[player.UserId].inventory[hasKey].quantity = _G.sessionData[player.UserId].inventory[hasKey].quantity - 1
			CleanInventory(player)
			if ItemData[itemName].fuels then
				_G.worldStructures[structure].specificData.fuel = math.clamp(_G.worldStructures[structure].specificData.fuel + ItemData[itemName].fuels, 0, ItemData[_G.worldStructures[structure].name].capacity)
				structure.Board.Billboard.Backdrop.TextLabel.Text = math.floor(_G.worldStructures[structure].specificData.fuel + .5)
				structure.Board.Billboard.Backdrop.Slider.Size = UDim2.new(_G.worldStructures[structure].specificData.fuel / ItemData[structure.Name].capacity, 0, 1, 0)
				structure.Board.Billboard.Backdrop.Slider.BackgroundColor3 = Color3.fromRGB(255, 0, 0):lerp(Color3.fromRGB(170, 255, 0), _G.worldStructures[structure].specificData.fuel / 100)

			end -- end of if the item is fuels
		end -- end of haskey

	elseif structure.Name == "Plant Box" then
		if _G.worldStructures[structure].specificData.growing then
			return
		end
		local hasKey = HasItem(player, itemName)
		if hasKey then
			_G.sessionData[player.UserId].inventory[hasKey].quantity = _G.sessionData[player.UserId].inventory[hasKey].quantity - 1
			CleanInventory(player)
			if ItemData[itemName].grows then
				_G.worldStructures[structure].lastCheck = Rep.Constants.RelativeTime.Value
				local seed = ss.Items:FindFirstChild(itemName)
				local seedClone
				if seed:IsA("BasePart") then
					seedClone = seed:Clone()
				elseif seed:IsA("Model") then
					seedClone = Instance.new("Part")
					seedClone.Size = Vector3.new(1.8, 1.8, 1.8)
					seedClone.Material = seed.PrimaryPart.Material
					seedClone.Color = seed.PrimaryPart.Color
					seedClone.Name = seed.Name
				end
				seedClone.Anchored = true
				seedClone.CanCollide = false
				seedClone:ClearAllChildren()
				seedClone.CFrame = structure.Compost.CFrame * CFrame.new(0, structure.Compost.Size.Y / 2, 0)
				seedClone.Parent = structure
				PlaySoundInObject(Rep.Sounds.Bank.Plant, seedClone)
				_G.worldStructures[structure].specificData.growing = seedClone

				Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
					{
						"DrawInventory"
					},
					{
						"UpdateCraftMenu"
					},
					{
						"UpdateBillboards",
						{
							"clear"
						}
					}
				})
--softupdate craftmenu
				return 
			end
		end

	elseif structure.Name == "Grinder" then
		local hasKey = HasItem(player, itemName)
		if hasKey then
			if ItemData[itemName].grindsTo then
				_G.sessionData[player.UserId].inventory[hasKey].quantity = _G.sessionData[player.UserId].inventory[hasKey].quantity - 1
				CleanInventory(player)

				DropItem({
					["player"] = player,
					["itemName"] = ItemData[itemName].grindsTo,
					["cf"] = structure.PrimaryPart.CFrame * CFrame.new(0, 4, 0),
					["gc"] = Rep.Constants.RelativeTime.Value + 600,
				})

				PlaySoundInObject(Rep.Sounds.Bank.StoneImpact, structure.PrimaryPart)
			end
		end

	elseif structure.Name == "Coin Press" then
		if (itemName == "Gold") or (itemName == "Silver") or (itemName == "Copper") then
			local hasKey = HasItem(player, itemName)
			if hasKey then
				-- has the gold bar
				_G.sessionData[player.UserId].inventory[hasKey].quantity = _G.sessionData[player.UserId].inventory[hasKey].quantity - 1
				CleanInventory(player)
				
				for i = 1, 3 do
					DropItem({
						["player"] = player,
						["itemName"] = itemName.." Coin",
						["cf"] = structure:FindFirstChild("CoinPart").CFrame,
						["gc"] = Rep.Constants.RelativeTime.Value + 600,
					})
				end
			end -- end of for loop
		end




--elseif structure.Name == "Chest" then
--local chestHas
--for k,v in next,_G.worldStructures[structure].contents do
--if v.name == itemName then
--_G.worldStructures[structure].contents[k].quantity = 
--local newItem = game.ReplicatedStorage.Items:FindFirstChild(itemName):Clone()
--newItem.CFrame = structure.PrimaryPart.CFrame*CFrame.new(5,3,4)
--newItem.Parent = workspace
--end
--end

--elseif structure.Name == "Nest" then
--local hasKey = HasItem(player,itemName)
--if hasKey then
--if itemName == "Egg" then
--if not _G.worldStructures[structure].specificData.hasBaby then
--_G.sessionData[player.UserId].inventory[hasKey].quantity =_G.sessionData[player.UserId].inventory[hasKey].quantity-1
--_G.worldStructures[structure].specificData.hasBaby = true
--structure.GrowEgg.Transparency = 0
--CleanInventory(player)
--end
--end
--end


	end -- end of if campfire
	Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
		{
			"DrawInventory"
		},
		{
			"UpdateCraftMenu"
		}
	})
--softupdate
end)



-- SOME COROUTINES

lastHungerNotify = {}

local degradeStats = coroutine.wrap(function()
	while wait(1) do
		local success,message  = pcall(function()
				for _, player in next, game.Players:GetPlayers() do
					local data = _G.sessionData[player.UserId]
	
					if data then
		
						local healthGain = 0
						local foodDegradation = 1/10
						
						if HasMojoRecipe(player, "Survivalist") then
							healthGain = 1 / 3
							foodDegradation = 1 / 15
						end
	
						_G.sessionData[player.UserId].stats.food = math.clamp(_G.sessionData[player.UserId].stats.food - foodDegradation, 0, 100)
						
						local last  = lastHungerNotify[player.UserId] or 0
	
						if data.stats.food <= 25 and (Rep.Constants.RelativeTime.Value - last) >= 60  then
							lastHungerNotify[player.UserId] = Rep.Constants.RelativeTime.Value
							Rep.Events.Notify:FireClient(player, "You are starving!", ColorData.badRed, 3)
						end
	
	--if data.stats.food >= 50 then
	--player.Character.Humanoid.Health = math.clamp(player.Character.Humanoid.Health+(1/4),0,player.Character.Humanoid.MaxHealth)
	--end
	
	-- restore void energy
						local totalVoodooRestored = 0
						
						for locus, armorName in next, _G.sessionData[player.UserId].armor do
							if armorName and armorName ~= "none" then
								local voodooRegen = ItemData[armorName].voodooRegen or 0
								totalVoodooRestored = totalVoodooRestored + voodooRegen
							end
						end
						
						local worldVoodooMultiplier = 1/10
						if game.PlaceId == 2021740958 then
							local worldVoodooMultiplier = 1
						end
						
						totalVoodooRestored = totalVoodooRestored * worldVoodooMultiplier
						
						if data.voodoo then
							data.voodoo = math.clamp(data.voodoo + totalVoodooRestored, 0, 100)
						end
	
--						if data.stats.food >= 50 then
--							if player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:IsDescendantOf(workspace) then
--								player.Character.Humanoid.Health = math.clamp(player.Character.Humanoid.Health + (1 / 3) + survivalistHealthGain, 0, player.Character.Humanoid.MaxHealth)
--							end
--						end
						
						local hum = player.Character:FindFirstChild("Humanoid")
						
						if hum then
							data.stats.overHeal = math.clamp(data.stats.overHeal or 0, 0, hum.MaxHealth+10-hum.Health)
							
							if data.stats.overHeal > 0 then
								data.stats.overHeal = (data.stats.overHeal or 0) -3
								hum.Health = math.clamp(hum.Health+3,0,hum.MaxHealth)
							end
		
							if data.stats.food <= 0 then
								if player.Character then
									hum:TakeDamage(1)
								end
							end
						end
	
						Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
							{
								"UpdateStats"
							}
						})
					end
				end
		end) -- end of pcall
	end -- end of loop
end)

degradeStats()


-- STRUCTURE MANIPULATION
local structureAffection = coroutine.wrap(function()
	local timeScale = 1 / 15
	while true do
		Run.Heartbeat:wait()
		for structure, structureData in next, _G.worldStructures do

			if structureData.name == "Campfire" then
				local fueled
				fueled = structureData.specificData.fuel > 0

				_G.worldStructures[structure].specificData.fuel = math.clamp(structureData.specificData.fuel - ((Rep.Constants.RelativeTime.Value - structureData.lastCheck) / 2), 0, ItemData[structure.Name].capacity)-- decrease in increments of .5
-- make sure the effects are
				local r = 10
				local scanRegion = Region3.new(
structure.PrimaryPart.Position + Vector3.new(-r, -4, -r),
structure.PrimaryPart.Position + Vector3.new(r, r, r)
)


				local partsInRegion = workspace:FindPartsInRegion3(scanRegion, structure, 150)
--print("region is",scanRegion.Size,"at",scanRegion.CFrame,"... origin of flame is",structure.PrimaryPart.Position)

				for _, v in next, partsInRegion do
--[[
if ItemData[v.Name] and ItemData[v.Name].fuels then
_G.worldStructures[structure].specificData.fuel = math.clamp(_G.worldStructures[structure].specificData.fuel+ItemData[v.Name].fuels,0,ItemData[structure.Name].capacity)
v:Destroy()
end
]]--
					if fueled then
						if ItemData[v.Name] and ItemData[v.Name].cooksTo then
							if v:FindFirstChild("CookingSuite") then
								v.CookingSuite.Progress.Value = v.CookingSuite.Progress.Value + (Rep.Constants.RelativeTime.Value - _G.worldStructures[structure].lastCheck)
								v.CookingSuite.ProgressGui.Frame.Slider.Size = UDim2.new(v.CookingSuite.Progress.Value / ItemData[v.Name].cooksTo.steps, 0, 1, 0)
								if v.CookingSuite.Progress.Value >= ItemData[v.Name].cooksTo.steps then
									local oldCF = v.CFrame

									DropItem({
										["player"] = structureData.owner,
										["itemName"] = ItemData[v.Name].cooksTo.name,
										["cf"] = CFrame.new(oldCF.p + Vector3.new(0, 2, 0)),
										["gc"] = Rep.Constants.RelativeTime.Value + 600,
									})
									v:Destroy()
								end

							else -- if no cookProportion
--AddValueObject(v,"CookProportion","NumberValue",timeScale)
								local suite = Rep.Guis.CookingSuite:Clone()
								suite.ProgressGui.Adornee = v
								suite.Parent = v
								suite.ProgressGui.Frame.BackgroundColor3 = v.BrickColor.Color or v.PrimaryPart.BrickColor.Color
--suite.Progress.Value = v.Progress.Value+timeScale
							end
						end
					end
				end

				if fueled then
					for _, v in next, structure:GetDescendants() do
						if v.Name == "Effect" then
							for _, effect in next, v:GetChildren() do
								effect.Enabled = true
							end
						end
					end
					if not structure.Reference.Campfire.IsPlaying then
						structure.Reference.Campfire:Play()
					end

				else
					for _, v in next, structure:GetDescendants() do
						if v.Name == "Effect" then
							for _, effect in next, v:GetChildren() do
								effect.Enabled = false
							end
						end
					end
					structure.Reference.Campfire:Stop()
				end
				_G.worldStructures[structure].lastCheck = Rep.Constants.RelativeTime.Value
				structure.Board.Billboard.Backdrop.TextLabel.Text = math.floor(_G.worldStructures[structure].specificData.fuel + .5)
				structure.Board.Billboard.Backdrop.Slider.Size = UDim2.new(_G.worldStructures[structure].specificData.fuel / ItemData[structure.Name].capacity, 0, 1, 0)
				structure.Board.Billboard.Backdrop.Slider.BackgroundColor3 = Color3.fromRGB(255, 0, 0):lerp(Color3.fromRGB(170, 255, 0), _G.worldStructures[structure].specificData.fuel / 100)
--print(_G.worldStructures[structure].specificData.fuel/100)
-- campfire Process
				Run.Heartbeat:wait()

			elseif structureData.name == "Plant Box" then
-- farm Process
				if structureData.specificData.growing then
					_G.worldStructures[structure].specificData.progress = structureData.specificData.progress + (Rep.Constants.RelativeTime.Value - structureData.lastCheck)
					_G.worldStructures[structure].lastCheck = Rep.Constants.RelativeTime.Value
					if _G.worldStructures[structure].specificData.progress >= ItemData[structureData.specificData.growing.Name].growthTime then
						local plant = ss.Growths:FindFirstChild(ItemData[structureData.specificData.growing.Name].grows):Clone()
						local seed = structure:FindFirstChild(structureData.specificData.growing.Name)
						plant:SetPrimaryPartCFrame(seed.CFrame)
						seed:Destroy()
						if plant:FindFirstChild("Health") then
							plant.Health:Destroy()
						end
--[[
for _,v in next,plant:GetChildren() do
if not v:FindFirstChild("Pickup") then
AddValueObject(v,"Pickup","BoolValue",true)
end
end
]]--l

						plant.Parent = workspace
						_G.worldStructures[structure].specificData.growing = nil
						_G.worldStructures[structure].specificData.progress = 0
					end
				end

			elseif structureData.name == "Nest" then
				if structureData.specificData.hasBaby or structureData.specificData.hasHen then
					_G.worldStructures[structure].specificData.progress = structureData.specificData.progress + (Rep.Constants.RelativeTime.Value - structureData.lastCheck)
					_G.worldStructures[structure].lastCheck = Rep.Constants.RelativeTime.Value
					if _G.worldStructures[structure].specificData.progress >= ItemData[structureData.name].growthTime then
						if structureData.specificData.hasBaby and not structureData.specificData.hasHen then
							_G.worldStructures[structure].specificData.hasHen = true
							for _, v in next, structure.Peeper:GetChildren() do
								v.Transparency = 0
							end
							structure.GrowEgg.Transparency = 1

						elseif structureData.specificData.hasHen and not structureData.specificData.hasEgg then
							_G.worldStructures[structure].specificData.hasEgg = true
							local newEgg = ss.Items.Egg:Clone()
							newEgg.CFrame = structure.EggSlot.CFrame
							newEgg.Anchored = true
							newEgg.CanCollide = false
							newEgg.Draggable:Destroy()
							newEgg.Parent = structure.Contents
							newEgg.AncestryChanged:connect(function()
								if structure and _G.worldStructures[structure] then
									_G.worldStructures[structure].specificData.hasEgg = false
								end
							end)
						end
						_G.worldStructures[structure].specificData.progress = 0
					end
				end

			elseif structureData.name == "Fish Trap" then
				if not structureData.specificData.hasFish then
					_G.worldStructures[structure].specificData.progress = structureData.specificData.progress + (Rep.Constants.RelativeTime.Value - structureData.lastCheck)
					_G.worldStructures[structure].lastCheck = Rep.Constants.RelativeTime.Value
					if (_G.worldStructures[structure].specificData.progress >= ItemData[structureData.name].growthTime) then
						_G.worldStructures[structure].specificData.hasFish = true
						local newFish = ss.Items["Raw Fish"]:Clone()
						newFish.CFrame = structure.FishSlot.CFrame
						newFish.Anchored = true
						newFish.CanCollide = false
						newFish.Draggable:Destroy()
						newFish.Parent = structure.Contents

						newFish.AncestryChanged:connect(function()
							if structure and _G.worldStructures[structure] then
								_G.worldStructures[structure].specificData.hasFish = false
								_G.worldStructures[structure].specificData.progress = 0
								_G.worldStructures[structure].lastCheck = Rep.Constants.RelativeTime.Value
							end
						end)
					end

				end


			elseif structureData.name == "Quarry" then
-- default quarry Process
			elseif structureData.custom then
-- if this is a custom structure
				if structureData.custom.CampfireMechanic then
-- do campfire thing
				end
				if structureData.custom.QuarryMechanic then
-- do quarry thing
				end
				if structureData.custom.FishingMechanic then
-- do fishing thing
				end
				if structureData.custom.SmeltMechanic then
-- do smeltery thing
				end

			end -- end of elseifs

		end -- end of iteration through structures
	end -- end of wtd
end)
structureAffection()

Rep.Events.SpawnFirst.OnServerEvent:connect(function(player)
	if not _G.sessionData[player.UserId].hasSpawned then
		_G.sessionData[player.UserId].hasSpawned = true

		Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId])
		player.Character:Destroy()
		wait(1 / 10)
		SpawnCharacter(player)
	end
end)

--Rep.Events.AppearanceChange.OnServerEvent:connect(function(player,locus,value)
--if not player.Character then return end
--local itemKey,itemInfo = ItemData[value]
--if itemInfo then
--
---- if it's a free thing, we don't care if they own it
--if (not cosmeticData.price) or _G.sessionData[player.UserId].ownedCosmetics[value] then
---- wear it
--_G.sessionData[player.UserId].appearance[locus] = value
--SetupAppearance(player)
--else
---- tell them no
--end
--
--end -- end of if iteminfo
--
--end)

Rep.Events.UnequipArmor.OnServerEvent:connect(function(player, armorName)
	if _G.sessionData[player.UserId].armor[ItemData[armorName].locus] then

		local otherArmorKey = HasItem(player, _G.sessionData[player.UserId].armor[ItemData[armorName].locus])
		if otherArmorKey then
			_G.sessionData[player.UserId].inventory[otherArmorKey].quantity = _G.sessionData[player.UserId].inventory[otherArmorKey].quantity + 1
		else
			_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory + 1] = {
				name = _G.sessionData[player.UserId].armor[ItemData[armorName].locus],
				quantity = 1
			}
		end

		_G.sessionData[player.UserId].armor[ItemData[armorName].locus] = "none"
		Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
			{
				"DrawInventory"
			},
			{
				"UpdateArmor"
			}
		})
		SetupAppearance(player)
	end
end)

local shutdownCoroutine = coroutine.wrap(function()
	
	Rep.Events.Notify:FireAllClients("MAINTENANCE BREAK WARNING", ColorData.badRed, Rep.Constants.ShutdownTime.Value)
	Rep.Events.MakeToast:FireAllClients(
		{
		color = ColorData.badRed,
		image = "",
		title = "SERVER MAINTENANCE",
		message = "ALL SERVERS will shut down for maintenance in "..Rep.Constants.ShutdownTime.Value.." seconds",
		duration = 10,
		})
			
		for _,player in next,game.Players:GetPlayers() do
			Rep.Events.PlaySoundOnClient:FireClient(player,"Quest Affirm")
		end
			
		SaveAllData()

	for seconds = Rep.Constants.ShutdownTime.Value, 0, -1 do
		wait(1)
			local hours = string.format("%02.f", math.floor(seconds / 3600))
			local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
			local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))
			local timeString = mins.."m "..secs.."s"
			
		if ((seconds % 30 == 0) or (seconds <= 60 and seconds % 10 == 0)) and seconds > 0 then
			local message = "Server shutdown for maintenance in "..timeString
			Rep.Events.Notify:FireAllClients("Server Maintenance shutdown in "..timeString,Color3.fromRGB(220,220,220),10)
			for _,player in next,game.Players:GetPlayers() do
				Rep.Events.PlaySoundOnClient:FireClient(player,"Cork Pop")
			end
		end
	end
	
	for _, player in next, game.Players:GetPlayers() do
		player:Kick("This server has shutdown")
	end
end)

game:GetService("MessagingService"):SubscribeAsync("shutdown",shutdownCoroutine)
game:GetService("MessagingService"):SubscribeAsync("announce",function(message)
	
	Rep.Events.Notify:FireAllClients("ANNOUNCEMENT!", ColorData.goodGreen, 10)
		for _,player in next,game.Players:GetPlayers() do
			Rep.Events.PlaySoundOnClient:FireClient(player,"Cork Pop")
		end
	
	Rep.Events.MakeToast:FireAllClients(
	{
	color = ColorData.goodGreen,
	image = "",
	title = "ANNOUNCEMENT",
	message = message.Data,
	duration = 30
	})
	
	wait(3)
	for _,player in next,game.Players:GetPlayers() do
		Rep.Events.PlaySoundOnClient:FireClient(player,"Enchant A")
	end
end)
--[[
messagingService codes

local message = "Hello everyone! This is Soybeen the creator of the game, testing the new announcement system"
game:GetService("MessagingService"):PublishAsync("announce",message) -- makes an announcement

local message = "shutting down"
game:GetService("MessagingService"):PublishAsync("shutdown",message) -- shuts down all servers


]]--

--function Rep.Events.RequestPlayerList.OnServerInvoke(player)
--	return playerListInfo, _G.tribeData
--end


Rep.Events.ToggleDoor.OnServerEvent:connect(function(player, gate)
	local gateInfo = _G.worldStructures[gate]
	if gateInfo then
-- is the player allowed to open the gate?
		local canOpen = false

		if gateInfo.owner == player then
			canOpen = true
		else
			local tribeKey, tribeInfo = HasTribe(player)
			local gateTribeKey, gateTribeData = HasTribe(gateInfo.owner)
			if (tribeKey and gateTribeKey) and tribeKey == gateTribeKey then
				canOpen = true
			end
		end

		if canOpen then
			local status
			if gate.Door.CanCollide then
				status = "closed"
			else
				status = "open"
			end

			if status == "open" then
				gate.Door.CanCollide = true
				gate.Door.Transparency = 0
				gate.Button.Color = ColorData.fadedGoodGreen
			elseif status == "closed" then
				gate.Door.CanCollide = false
				gate.Door.Transparency = 1
				gate.Button.Color = ColorData.fadedBadRed
			end
			if gate.Door:FindFirstChild("Offset") then
				gate.Door.CFrame = gate.Door.CFrame * CFrame.new(gate.Door.Offset.Value)
				gate.Door.Offset.Value = -gate.Door.Offset.Value
			end

		else -- if not canopen
			Rep.Events.Notify:FireClient(player, "NO ACCESS", ColorData.grey200)
		end

	end
end)


Rep.Events.RedoAvatar.OnServerEvent:connect(function(player)
	local request = Rep.Constants.RelativeTime.Value
	local received = Rep.Events.PromptClient:InvokeClient(player, {
		promptType = "YesNo",
		message = "Respawn to edit character? This will OOF you!"
	})
	if received.result == "yes" and Rep.Constants.RelativeTime.Value - request < 15 then
		_G.sessionData[player.UserId].hasSpawned = false

		_G.sessionData[player.UserId].appearance.hat = "none"
		Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId])
		player.Character.Humanoid.Health = 0
--SpawnCharacter(player)
	end
end)

function SpawnChest(chestName, locationCF, extraContents)
-- determine what will be in the new chest
	local newChest = ss.Chests:FindFirstChild(chestName):Clone()
	if extraContents then
		for _, itemName in next, extraContents do
			local newItem = ss.Items:FindFirstChild(itemName):Clone()
			for _, v in next, newItem:GetChildren() do
				if v.Name == "Pickup" or v.Name == "Draggable" then
					v:Destroy()
				end
			end

			if newItem:IsA("BasePart") then
				newItem.Anchored = true
				newItem.CanCollide = false
				newItem.CFrame = newChest.PrimaryPart.CFrame * CFrame.new(0, 2.5, 0)
			elseif newItem:IsA("Model") then
				for _, v in next, newItem:GetChildren() do
					v.Anchored = true
					v.CanCollide = false
				end
				newItem:SetPrimaryPartCFrame(newChest.PrimaryPart.CFrame * CFrame.new(0, 2.5, 0))
			end

			newItem.Parent = newChest.Contents
		end
	end

	local possibleDrops = ItemData[chestName]["possibleDrops"]
	newChest:SetPrimaryPartCFrame(locationCF * CFrame.new(0, 200, 0))
	newChest.Parent = workspace
-- tween the chest to its proper location after parenting it
	local newTweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0)

	local CFrameValue = Instance.new("CFrameValue")
	CFrameValue.Value = newChest:GetPrimaryPartCFrame()

	CFrameValue:GetPropertyChangedSignal("Value"):connect(function()
		newChest:SetPrimaryPartCFrame(CFrameValue.Value)
	end)
	
	local tween = tweenService:Create(CFrameValue, newTweenInfo, {
		Value = newChest.PrimaryPart.CFrame * CFrame.new(0, -200, 0)
	})
-- play the falling sound in the object
	PlaySoundInObject(Rep.Sounds.Bank.Falling, newChest.PrimaryPart)
	tween:Play()
	
	tween.Completed:connect(function()
		CFrameValue:Destroy()
		PlaySoundInObject(Rep.Sounds.Bank.ChestImpact, newChest.PrimaryPart)
		if newChest.PrimaryPart:FindFirstChild("Falling") then
			newChest.PrimaryPart.Falling:Destroy()
		end
-- play the impact sound in the object
	end)
end -- end of spawncrate


Rep.Events.ChestDrop.OnServerEvent:connect(function(p, chestName)
	if p and p.Character and p.Character.PrimaryPart then
	else
		return
	end
	local item = HasItem(p, chestName)
	
	if item then
		if ItemData[chestName].mojoRecipe then--Kick the exploiter. :o
			if not HasMojoRecipe(p, chestName) then
				p:Kick()
				return
			end
		end
		_G.sessionData[p.UserId].inventory[item].quantity = _G.sessionData[p.UserId].inventory[item].quantity - 1
		CleanInventory(p)
		Rep.Events.UpdateData:FireClient(p, _G.sessionData[p.UserId], {
			{
				"DrawInventory"
			}
		})
		
		local part, pos, norm, mat = RayUntil((p.Character.PrimaryPart.CFrame * CFrame.new(0, 0, -3)).p, Vector3.new(0, -10, 0))
		local toFace = CFrame.new(pos, Vector3.new(p.Character.PrimaryPart.CFrame.X, pos.Y, p.Character.PrimaryPart.CFrame.Z))
		SpawnChest(chestName, toFace)
	--else
		--Prompt them to buy more chests of that type
		--Rep.Events.Notify:FireClient(p, "You're out of "..chestName.." buy more.",ColorData.fadedBadRed, 2)
	end
end)


Rep.Events.CosmeticChange.OnServerEvent:connect(function(player, change, val)
	
	local good = false
	print("change", change, "val", val)
	if not cosmeticData[change][val].locked then
		good = true
	end

	if cosmeticData[change][val].locked and _G.sessionData[player.UserId].advancedCosmetics then
		good = true
	end

	if good then
		if change == "skin" then
			_G.sessionData[player.UserId].appearance.skin = val
		elseif change == "gender" then
			_G.sessionData[player.UserId].appearance.gender = val
		elseif change == "face" then
			_G.sessionData[player.UserId].appearance.face = val
		elseif change == "hair" then
			_G.sessionData[player.UserId].appearance.hair = val
		end
		SetupAppearance(player)
	end
end)

Rep.Events.EquipCosmetic.OnServerEvent:connect(function(player, itemName) 
	if _G.sessionData[player.UserId].ownedCosmetics[itemName] then
		local oldVal = _G.sessionData[player.UserId].appearance.hat
		if oldVal == itemName then
			_G.sessionData[player.UserId].appearance.hat = "none"
		else
			_G.sessionData[player.UserId].appearance.hat = itemName
		end
		SetupAppearance(player)
	end
end)

--Rep.Events.PurchaseCosmetic.OnServerEvent:connect(function(player, itemName)
--	local price = ItemData[itemName].cost
--	if price then
--		local hasCoins = _G.sessionData[player.UserId].coins
--		if hasCoins >= price and not _G.sessionData[player.UserId].ownedCosmetics[itemName] then
--			_G.sessionData[player.UserId].coins = _G.sessionData[player.UserId].coins - price
---- let's give them the item
--			_G.sessionData[player.UserId].ownedCosmetics[itemName] = true
--			Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
--				{
--					"UpdateCosmetics"
--				},
--				{
--					"UpdateStats"
--				}
--			})
--			Rep.Events.Notify:FireClient(player, "Unlocked "..itemName.."!", ColorData.essenceYellow, 4)
--		else
--			Rep.Events.Notify:FireClient(player, "Not enough coins", ColorData.badRed, 2)
---- tell them they can't afford that item
--		end
--	else
--		Rep.Events.Notify:FireClient(player, "This item is not for sale", ColorData.badRed, 2)
--	end
--end)

Rep.Events.PurchaseChest.OnServerEvent:connect(function(player, itemName)
	local price = ItemData[itemName].cost
	local hasCoins = _G.sessionData[player.UserId].coins
	if hasCoins >= price then
		_G.sessionData[player.UserId].coins = _G.sessionData[player.UserId].coins - price
		GiveItemToPlayer(itemName, player, 1)
		Rep.Events.Notify:FireClient(player, "Received a "..itemName.."!", ColorData.essenceYellow, 4)
	end
end)



-------------- MARKET STUFF

Rep.Events.SubmitTrade.OnServerEvent:connect(function(player, giveNameSent, giveQuantitySentRaw, getCoinsSentRaw)
	if not giveNameSent then
		return
	end
	
	if ItemData[giveNameSent].mojoRecipe then
		Rep.Events.Notify:FireClient(player, "Can't trade Mojo items!")
		return
	end
	
	local giveQuantitySent, getCoinsSent = math.floor(giveQuantitySentRaw), math.floor(getCoinsSentRaw)
	
	local maxCostPerItem = 10000
	if getCoinsSent > giveQuantitySent * maxCostPerItem then
		Rep.Events.Notify:FireClient(player, 'Price too high, 10,000 coins max per item.', ColorData.badRed, 3)
		return
	end
	
	-- see how many trades they have pending
	local totalPending = 0
	for _, tradeData in next, _G.trades do
		if tradeData.trader == player.Name then
			totalPending = totalPending + 1
		end
	end
	
	if totalPending >= 5 then
		Rep.Events.Notify:FireClient(player, "Max 5 outbound trades!", ColorData.badRed, 3)
		return
	end

	local hasKey = HasItem(player, giveNameSent)
	
	if hasKey then
		local hasQuantity = _G.sessionData[player.UserId].inventory[hasKey].quantity
		if hasQuantity >= giveQuantitySent and giveQuantitySent >= 1 and getCoinsSent >= 1 then
			
			_G.sessionData[player.UserId].inventory[hasKey].quantity = hasQuantity - giveQuantitySent
			
			local tradeInfo = {
				trader = player.Name,
				giveName =  giveNameSent,
				giveQuantity = giveQuantitySent,
				getCoins = getCoinsSent,
				bought = false,
			}
			
			_G.trades[player.UserId..'_'..os.time()] = tradeInfo
			
			Rep.Events.UpdateTradeData:FireAllClients(_G.trades)
		else
			Rep.Events.Notify:FireClient(player, 'Not enough items.', ColorData.badRed, 3)
			return
		end
	end
	
	CleanInventory(player)
	Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
		{
			"DrawInventory"
		}
	})
end)


function CanBearLoadArray(p, items)
	for _,item in next,items do
		if not CanBearLoad(p,item) then
			return
		end
	end
	return true
end


Rep.Events.AcceptTrade.OnServerEvent:connect(function(player, tradeKey)
	local tradeData = _G.trades[tradeKey]
	
	if not tradeData or not tradeData.trader then 
		Rep.Events.Notify:FireClient(player, 'Invalid trade.', ColorData.badRed, 3)
		return 
	end
	
	if tradeData.bought then
		Rep.Events.Notify:FireClient(player, 'Item already sold.', ColorData.badRed, 3)
		return
	end
	
	if tradeData.trader ~= player.Name then
		local hasCoins = _G.sessionData[player.UserId].coins
		
		if hasCoins >= tradeData.getCoins then
			if CanBearLoadArray(player, {
				{
					tradeData.giveName,
					tradeData.giveQuantity
				}
			}) then
				_G.trades[tradeKey].bought = true--Prevent coin loss / duped items.
				
				_G.sessionData[player.UserId].coins = hasCoins - tradeData.getCoins
				
				
				-- give the gold to the seller tradedata.player
				local traderPlayer = game.Players:FindFirstChild(tradeData.trader)
				if traderPlayer then
					_G.sessionData[traderPlayer.UserId].coins = _G.sessionData[traderPlayer.UserId].coins + tradeData.getCoins
					Rep.Events.UpdateData:FireClient(traderPlayer, _G.sessionData[traderPlayer.UserId], {
						{
							"UpdateStats"
						}
					})
				end
				
				--[[
				local contents = {}
				for i = 1,tradeData.giveQuantity do
				contents[#contents+1] = tradeData.giveName
				end
				
				
				-- determine the market they're trading from
				local marketSent = false
				for structure,structureData in next,_G.worldStructures do
				if structureData.owner == player and structure.Name == "Market" then
				--drop the chest at the target spot
				SpawnChest("Trade Chest",structure.CratePart.CFrame*CFrame.new(0,0,-7),contents)
				marketSent = true
				break
				end
				end
				
				if not marketSent then
					if traderPlayer.Character then
						GiveItemToPlayer(tradeData.giveName, player, tradeData.giveQuantity)
						local text = 'You bought '..tradeData.giveName..' x'..tradeData.giveQuantity..' for '..tradeData.getCoins..' Coins.'
						Rep.Events.Notify:FireClient(player, text, ColorData.essenceYellow, 4)
						--SpawnChest("Trade Chest",player.Character.PrimaryPart.CFrame*CFrame.new(0,-2,0),contents)
					end
				end
				--]]
				GiveItemToPlayer(tradeData.giveName, player, tradeData.giveQuantity)
				--Remove data.
				_G.trades.tradeKey = nil--table.remove(_G.trades, tradeKey)
				
				
				local text = 'You bought '..tradeData.giveName..' x'..tradeData.giveQuantity..' for '..tradeData.getCoins..' Coins.'
				Rep.Events.Notify:FireClient(player, text, ColorData.essenceYellow, 4)
				Rep.Events.Notify:FireClient(traderPlayer, player.Name..' bought your Market offer.', ColorData.essenceYellow, 4)
				Rep.Events.UpdateTradeData:FireAllClients(_G.trades)
			else
				Rep.Events.Notify:FireClient(player, 'Your bag is full.', ColorData.essenceYellow, 4)
			end
		end
		
	else-- refund the player, they're canceling their trade.
		if not tradeData.bought then
			_G.trades[tradeKey].bought = true--Prevent coin loss / duped items.
			_G.trades.tradeKey = nil--table.remove(_G.trades, tradeKey)
			GiveItemToPlayer(tradeData.giveName, player, tradeData.giveQuantity)
			Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
				{
					"DrawInventory"
				}
			})
			
			Rep.Events.UpdateTradeData:FireAllClients(_G.trades)
		else
			print'Error removing data from array.'
		end
	end
end)



local tradeDataUpdater = coroutine.wrap(function()
	while wait(30) do
		Rep.Events.UpdateTradeData:FireAllClients(_G.trades)
	end
end)
tradeDataUpdater()

-------------- MARKET STUFF END


local projectileBank = {}
Rep.Events.CreateProjectile.OnServerEvent:connect(function(player, projectileData)

	local sound = Rep.Sounds.ToolSounds[projectileData.toolName]:FindFirstChild(ItemData[projectileData.toolName].fireSound)
	
	for _, otherPlayer in next, game.Players:GetPlayers() do
		if otherPlayer ~= player then
			if player.Character and player.Character.PrimaryPart then
				Rep.Events.PlaySoundAtPosition:FireClient(otherPlayer, sound, player.Character.PrimaryPart.Position)
			end
		end
	end

	local originCF, drawStrength, toolName = projectileData.originCF, projectileData.drawStrength, projectileData.toolName
	local lastAction = lastPlayerToolActions[player.UserId] or 0
	if (Rep.Constants.RelativeTime.Value - lastAction) > math.clamp(ItemData[toolName].speed, .3, 10) then
		lastPlayerToolActions[player.UserId] = Rep.Constants.RelativeTime.Value
		_G.sessionData[player.UserId].toolbar[_G.sessionData[player.UserId].equipped].lastSwing = Rep.Constants.RelativeTime.Value


		local hasKey = HasItem(player, ItemData[projectileData.toolName].ammoItem)
		
		if HasToolInBar(player, toolName) and hasKey then
-- good to go
			lastPlayerToolActions[player.UserId] = Rep.Constants.RelativeTime.Value
			_G.sessionData[player.UserId].inventory[hasKey].quantity = _G.sessionData[player.UserId].inventory[hasKey].quantity - 1
			
			CleanInventory(player)
			Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
				{
					"DrawInventory"
				}
			})
			if not projectileBank[player.UserId] then
				projectileBank[player.UserId] = {}
			end
			table.insert(projectileBank[player.UserId], Rep.Constants.RelativeTime.Value)

			for _, otherPlayer in next, game.Players:GetPlayers() do
				if otherPlayer ~= player then
					Rep.Events.CreateProjectile:FireClient(otherPlayer, {
						["fromPlayer"] = player,
						["toolName"] = toolName,
						["originCF"] = originCF,
						["drawStrength"] = drawStrength,
						["owner"] = false
					})
				end
			end

		end

	end 
end)

Rep.Events.ProjectileImpact.OnServerEvent:connect(function(player)
	_G.sessionData[player.UserId].banned = true
	_G.sessionData[player.UserId].hasHacked = true
--player:Kick()
end)

Rep.Events.DequipCosmetic.OnServerEvent:connect(function(player, part, pos, projectileData, projDistance)
	local toolName = projectileData.toolFrom
	if not (#projectileBank[player.UserId] >= 1) then
--_G.sessionData[player.UserId].banned = true
--_G.sessionData[player.UserId].hasHacked = true
--player:Kick()
		return
	end

	local validProjectile = false
	for k, v in next, projectileBank[player.UserId] do
		if Rep.Constants.RelativeTime.Value - v > 10 then
			table.remove(projectileBank[player.UserId], k)
		else
			validProjectile = projectileBank[player.UserId][k]
			table.remove(projectileBank[player.UserId], k)
			break
		end
	end

	if not validProjectile then
--_G.sessionData[player.UserId].banned = true
--_G.sessionData[player.UserId].hasHacked = true
--player:Kick()
		return
	else
	end

	local lastProjectileOut = projectileBank[player.UserId][1] or Rep.Constants.RelativeTime.Value
	if Rep.Constants.RelativeTime.Value - lastProjectileOut < 4 and (projectileData.origin - player.Character.PrimaryPart.Position).magnitude < 10 then
		if player.Character and player.Character.PrimaryPart then
			if math.abs((player.Character.PrimaryPart.Position - pos).magnitude - projDistance) < 10 + (projDistance / 10) then-- accing for ping
-- let's damage the resource
				if part then
					if  (part:FindFirstChild("Health") or part.Parent:FindFirstChild("Health")) and not game.Players:GetPlayerFromCharacter(part.Parent) then
						local targetEntity
						if part:FindFirstChild("Health") then 
							targetEntity = part
						elseif part.Parent:FindFirstChild("Health") then
							targetEntity = part.Parent
						end
-- if it's a resource
						local canDamage = false
						for damageType, damageAmount  in next, ItemData[toolName].damages do
							if ItemData[targetEntity.Name].susceptions[damageType] then
								canDamage = damageAmount
							end
						end

						if canDamage then 
							DamageResource(targetEntity, canDamage, player) 
						end

					elseif IsDescendantOfPlayer(part) then 

						local otherPlayer = game.Players:GetPlayerFromCharacter(part.Parent)
						if otherPlayer then
							local dist = (player.Character.PrimaryPart.Position - otherPlayer.Character.PrimaryPart.Position).magnitude
							if not AreAllies(player, otherPlayer) then
								DamagePlayer(otherPlayer, CalculateToolDamageToPlayers(toolName, otherPlayer))
								CombatTag(player, otherPlayer)
								CombatTag(otherPlayer, player)

							else
-- they're allies, don't do it!
							end

						end
					end
				end
			end
		end
	end
end)


local offloadCritters = coroutine.wrap(function()
	while wait() do
		local critters = AppendTables({
			workspace.Critters:GetChildren(),
			workspace.Deployables:GetChildren()
		})
		local toOffload, toOnload = {}, {}
		local nearestPlayer, nearestDist
		for _, critter in next, critters do
			if critter and critter.PrimaryPart and (ItemData[critter.Name].itemType  == "boat" or ItemData[critter.Name].itemType  == "creature")  then
				local critterTether = ItemData[critter.Name].physicsTether or 200
				local instruction =  "offload"

				for _, player in next, game.Players:GetPlayers() do
					if player and player.Character and player.Character.PrimaryPart then
						local dist = (player.Character.PrimaryPart.Position - critter.PrimaryPart.Position).magnitude
						if dist < critterTether then
							instruction = "onload"
							break
						end 
					end
				end
				if  critter  and critter.PrimaryPart then
					if instruction == "onload" then

						for _, v in next, critter:GetChildren() do
							if v:IsA("BasePart") then
								v.Anchored = false
							end
						end

					else
						if critter.Name == "Raft" then
						end
						for _, v in next, critter:GetChildren() do
							if v:IsA("BasePart") then
								v.Anchored = true
							end
						end
					end
--if critter:FindFirstChild("AnimationController") then
--for _,anim in next,critter.AnimationController:GetPlayingAnimationTracks() do 
--anim:Stop()
--end 
--end

					Run.Heartbeat:wait()
				end
			end
		end

	end
-- compare every  critter with every human

end)
--offloadCritters()

--[[
local portals ={
workspace:WaitForChild("LavaPortal"),
workspace:WaitForChild("HavenPortal"),
--workspace:WaitForChild("QueenPortal")
}
for _,portal in next, portals do
portal.Touched:connect(function(hit)
local char = hit.Parent
local player = game.Players:GetPlayerFromCharacter(char)
if player then
-- give them immunity
-- you can also accomplish this by adding a value to their player called TeleportObject 
-- or something, then remove it with the anti hack
--player.Character:SetPrimaryPartCFrame(CFrame.new(portal.Destination.Value))
TeleportPlayer(player,CFrame.new(portal.Destination.Value))
end
end)
end
--]]

for i, v in pairs(workspace:GetDescendants()) do
	if v:IsA'BasePart' and v:FindFirstChild'Destination' then
		v.Touched:connect(function(hit)
			local char = hit.Parent
			local player = game.Players:GetPlayerFromCharacter(char)
			if player then
				TeleportPlayer(player, CFrame.new(v.Destination.Value))
			end
		end)
	end
end


Run.Stepped:connect(function(overall, dt)
	Rep.Constants.RelativeTime.Value = overall
end)

local violations = {}
local lastPositions  = {}

function CrystalMeteor()
	for _, player in next, game.Players:GetPlayers() do
		Rep.Events.Notify:FireClient(player, "A Crystal meteor is falling from the sky!", Color3.fromRGB(176, 241, 244), 8)
	end
	wait(4)
	for _, player in next, game.Players:GetPlayers() do
		Rep.Events.Notify:FireClient(player, "Track it down!", Color3.fromRGB(176, 241, 244), 4)
	end
	local destination = meteorLocations[math.random(1, #meteorLocations)]

	local meteor = game.ServerStorage.Misc:FindFirstChild("Crystal Meteor"):Clone()
	local origin = destination * CFrame.new(math.random(-2000, 2000), math.random(1000), math.random(-2000, 2000))
	meteor.Parent = workspace
	meteor.Rumble:Play()

	local distance = (meteor.Position - destination.p).magnitude
	for i = 0, 1, 1 / 1000 do
		meteor.CFrame = CFrame.new(origin.p):lerp(destination, i) * CFrame.Angles(i * 10, i * 5, i * 20)
		game:GetService("RunService").Heartbeat:wait()
	end
	meteor:Destroy()
	local meteorSuite = ss.Misc:FindFirstChild("Crystal Meteor Suite"):Clone()
	meteorSuite:SetPrimaryPartCFrame(destination)
	meteorSuite.Parent = workspace

	meteorSuite["Crystal Meteor Core"].PrimaryPart.Sound:Play()
	meteorSuite["Crystal Meteor Core"].PrimaryPart.Boom.TimePosition = .9
	meteorSuite["Crystal Meteor Core"].PrimaryPart.Boom:Play()

	for _,v in next,meteorSuite:GetChildren() do
		if ItemData[v.Name] and ItemData[v.Name].itemType and ItemData[v.Name].itemType == "creature" then
			ItemData.Parent = workspace.Critters
		else
			v.Parent = workspace
		end
	end
	meteorSuite:Destroy()
end

function Shipwreck()
	for _, player in next, game.Players:GetPlayers() do
		Rep.Events.Notify:FireClient(player, "An old treasure has washed ashore!", ColorData.essenceYellow, 8)
	end
	local destination = shipwreckLocations[math.random(1, #shipwreckLocations)]
	local shipwreck = ss.Misc:FindFirstChild("ShipwreckSuite"):Clone()
	shipwreck:SetPrimaryPartCFrame(destination)
	for _, v in next, shipwreck:GetChildren() do
		if v:IsA("Model") then
			v.Parent = workspace
		else
			v:Destroy()
		end
	end
	shipwreck:Destroy()
end


function AduriteMeteor()
	for _, player in next, game.Players:GetPlayers() do
		Rep.Events.Notify:FireClient(player, "An Adurite Meteor is falling from the sky!", Color3.fromRGB(189, 0, 0), 8)
	end
	wait(4)
	for _, player in next, game.Players:GetPlayers() do
		Rep.Events.Notify:FireClient(player, "Track it down!", Color3.fromRGB(221, 196, 255), 4)
	end

	local destination = meteorLocations[math.random(1, #meteorLocations)]

	local meteor = game.ServerStorage.Misc:FindFirstChild("Adurite Meteor"):Clone()
	local origin = destination * CFrame.new(math.random(-2000, 2000), math.random(1000), math.random(-2000, 2000))
	meteor.Parent = workspace
	meteor.Rumble:Play()

	local distance = (meteor.Position - destination.p).magnitude
	for i = 0, 1, 1 / 1000 do
		meteor.CFrame = CFrame.new(origin.p):lerp(destination, i) * CFrame.Angles(i * 10, i * 5, i * 20)
		game:GetService("RunService").Heartbeat:wait()
	end
	meteor:Destroy()
	local meteorSuite = ss.Misc:FindFirstChild("Adurite Meteor Suite"):Clone()
	meteorSuite:SetPrimaryPartCFrame(destination)
	meteorSuite.Parent = workspace
	meteorSuite["Adurite Meteor Core"].PrimaryPart.Sound:Play()
	meteorSuite["Adurite Meteor Core"].PrimaryPart.Boom.TimePosition = .9
	meteorSuite["Adurite Meteor Core"].PrimaryPart.Boom:Play()

	for _,v in next,meteorSuite:GetChildren() do
		if ItemData[v.Name] and ItemData[v.Name].itemType and ItemData[v.Name].itemType == "creature" then
			ItemData.Parent = workspace.Critters
		else
			v.Parent = workspace
		end
	end
	
	meteorSuite:Destroy()
end


local AduriteMeteorLoop = coroutine.wrap(function()
	while wait(math.random(30*60)) do
		AduriteMeteor()
		repeat
			wait(10)
		until not workspace:FindFirstChild("Adurite Meteor Core")
	end
end)
AduriteMeteorLoop()

--local CrystalMeteorLoop = coroutine.wrap(function()
--	while wait(math.random((30 * 60), (60 * 60))) do
--		CrystalMeteor()
--		repeat
--			wait(10)
--		until not workspace:FindFirstChild("Crystal Meteor Core")
--	end
--end)
--CrystalMeteorLoop()

--local ShipwreckLoop = coroutine.wrap(function()
--	while wait(math.random((45 * 60), (60 * 60))) do
--		Shipwreck()
--		repeat
--			wait(10)
--		until not workspace:FindFirstChild("Treasure Chest")
--	end
--end)
--ShipwreckLoop()

workspace.DescendantRemoving:connect(function(child)
	if child.Name == "Totem of the Moon" then
		AduriteMeteor()
	elseif child.Name == "Lonely God" then
		for i = 1,5 do
			AduriteMeteor()
			wait(8)
		end
	elseif child.Name == "Queen Ant" then
		workspace.QueenWall.Parent = Rep
		wait(60*5)
		workspace.QueenWall.Parent = workspace
	end
end)


local lastFishings = {}
Rep.Events.RodSwing.OnServerEvent:connect(function(player, when, ray)
	local lastFish = lastFishings[player.UserId] or 0
	if not lastFish then
		lastFishings[player.UserId] = Rep.Constants.RelativeTime.Value
	end

	local equippedName = _G.sessionData[player.UserId].toolbar[_G.sessionData[player.UserId].equipped].name
	if not ItemData[equippedName].useType == "Rod" then
		return
	end

	local startEquip = _G.sessionData[player.UserId].equipped
	local toolInfo = ItemData[equippedName]
	local part, pos, norm, mat = workspace:FindPartOnRay(ray, player.Character)

	local realTool = player.Character:FindFirstChild(equippedName)
	local rodAttach = realTool.RodAttach
	local dist = (rodAttach.CFrame.p - pos).magnitude

	if part and mat == Enum.Material.Water and Rep.Constants.RelativeTime.Value - lastFish >= toolInfo.speed and dist < 100 then
		lastFishings[player.UserId] = Rep.Constants.RelativeTime.Value
		local line = ss.Misc.FishingLine:Clone()
		line.Size = Vector3.new(.2, .2, dist)
		line.CFrame = CFrame.new(rodAttach.CFrame.p, rodAttach.Position) * CFrame.new(0, 0, -dist / 2)
		line.Parent = player.Character:FindFirstChild(equippedName)

		local bobber = ss.Misc.Bobber:Clone()
		bobber.CFrame = CFrame.new(pos)
		bobber.Parent = player.Character:FindFirstChild(equippedName)

		local start = Rep.Constants.RelativeTime.Value
		repeat
			if _G.sessionData[player.UserId].equipped ~= startEquip  then
				return
			end 
			line.Size = Vector3.new(.2, .2, (rodAttach.CFrame.p - pos).magnitude)
			line.CFrame = CFrame.new(rodAttach.CFrame.p, bobber.Position) * CFrame.new(0, 0, -(rodAttach.CFrame.p - pos).magnitude / 2)
			wait()
		until ((Rep.Constants.RelativeTime.Value - start) >= ItemData[equippedName].speed)

		local magicNum = math.random(1, 4)

		if magicNum == 1 then
			Rep.Events.Notify:FireClient(player, "Caught a fish!", ColorData.goodGreen, 3)
			GiveItemToPlayer("Raw Fish", player, 1)
		else
			Rep.Events.Notify:FireClient(player, "No bite", Color3.fromRGB(255, 255, 255), 2)
		end
		line:Destroy()
		bobber:Destroy()
	end
end)


local currentWeather = "Shine"
local weatherTypes = {
"Rain",
"Snow",
"Shine",
--"Doom",	
}
local weatherCoroutine = coroutine.wrap(function()
	while true do

		local nextWeather = weatherTypes[math.random(1, #weatherTypes)]

		wait(math.random(240, 300))

		if nextWeather ~= currentWeather then
			Rep.Events.Weather:FireAllClients(currentWeather, false)
		end
		Rep.Events.Weather:FireAllClients(nextWeather, true)

		currentWeather = nextWeather
		
--		if currentWeather == "Doom" then
--			wait(60)
--		else -- if the weather is not specified a length
			wait(math.random(4*60, 6*60))
		--end

	end
end)
weatherCoroutine()


--for _,critter in next,workspace.Critters:GetChildren() do
---- determine if they are near a player
--local nearestTarget,closest = nil,math.huge
--local characters = {}
--for _,v in next,game.Players:GetPlayers() do
--if v.Character then
--characters[#characters+1] = v.Character
--end
--end
--
--for _,v in next,AppendTables
--
--
--wait(1)
--end
--
--local creatureCoroutine = coroutine.wrap(function()
--
--end)
--creatureCoroutine()

local activeMounds = 0
local antMoundCoroutine = coroutine.wrap(function()
	while true do 

		if (#antMoundLocations >0) and activeMounds < 5 then
-- let's make a new mound
			local newMound = ss.Misc:FindFirstChild("Scavenger Ant Mound"):Clone()
			local destinationKey = math.random(1, #antMoundLocations)
			local destination = antMoundLocations[destinationKey]
			table.remove(antMoundLocations, destinationKey)

			newMound:SetPrimaryPartCFrame(destination)
			newMound.Parent = workspace
			activeMounds = activeMounds + 1
			newMound.AncestryChanged:connect(function()
				activeMounds = activeMounds - 1
				antMoundLocations[#antMoundLocations + 1] = destination
			end)

		end

		wait(180)
	end
end)
antMoundCoroutine()

local potentialInfinityDrops = {
	"Pleb Chest",
	"Pleb Chest",
	"Good Chest",
	"Good Chest",
	"Good Chest",
	"Great Chest",
	"Great Chest",
	"Great Chest",
	"Great Chest",
	"OMG Chest",
	"OMG Chest",
	"OMG Chest",
	"Adurite Chest",
	"Adurite Chest",
	"Adurite Chest",
	"Crystal Chest",
	"Magnetite Chest",
	"Emerald Chest",
}

workspace.Deployables.ChildAdded:connect(function(child)
	if child.Name == "Infinity Chest" then
		local location = child.PrimaryPart.Position

		child.AncestryChanged:connect(function(c, newParent)
			if not newParent then
				for i = 1, 20 do
					local randoChestName = potentialInfinityDrops[math.random(1, #potentialInfinityDrops)]
					local newLocation = Vector3.new(location.X + math.random(-20, 20), location.Y, location.Z + math.random(-20, 20))
					local downRay = Ray.new(newLocation + Vector3.new(0, 1000, 0), Vector3.new(0, -10000, 0))
					local part, pos, mat, norm = workspace:FindPartOnRayWithWhitelist(downRay, {
						workspace.Terrain
					})
					SpawnChest(randoChestName, CFrame.new(pos, location))
					wait(math.random(2, 4) / (math.random(1, 2)))
				end
			end
		end)


	end
end)

for _,obj in next,workspace:GetChildren() do
	if obj.Name == "Crag" then
		-- differentiate the crag
		local rarities
	end
end

Rebirth = function(player)
	if _G.sessionData[player.UserId].level >= 100 then
		_G.sessionData[player.UserId].rebirths = _G.sessionData[player.UserId].rebirths + 1

		local itemsToPreserve = {}
		for itemKey, itemInfo in next, _G.sessionData[player.UserId].inventory do
			if ItemData[itemInfo.name].rebirthPersist then
				itemsToPreserve[#itemsToPreserve + 1] = itemInfo.name
			end
		end

		for locus, armorName in next, _G.sessionData[player.UserId].armor do
			if ItemData[armorName] and ItemData[armorName] ~= "none" and ItemData[armorName].rebirthPersist then
				itemsToPreserve[#itemsToPreserve + 1] = armorName
			end
		end

		for toolKey, toolInfo in next, _G.sessionData[player.UserId].toolbar do
			if GetDictionaryLength(_G.sessionData[player.UserId].toolbar[toolKey]) > 0 then
				if ItemData[toolInfo.name].rebirthPersist then
					itemsToPreserve[#itemsToPreserve + 1] = toolInfo.name
				end
			end
		end

	_G.sessionData[player.UserId].inventory = {
		{name = "Wood",
		quantity = 4},
		{name = "Cooked Meat",
		quantity = 1},
	}
	
	_G.sessionData[player.UserId].armor = {
		head = "none",
		arms = "none",
		legs = "none",
		torso = "none",
		bag = "none",
--face = "none",
	}

	_G.sessionData[player.UserId].toolbar = {
		{name = "Rock Tool",
		lastSwing = 0,}, -- 1
		{}, -- 2
		{}, -- 3
		{}, -- 4
		{}, -- 5
		{}, -- 6
	} -- end of toolbar

	_G.sessionData[player.UserId].appearance = {
		gender = "Male",
		skin = "White",
		face = "Smile",
		hat = "none",
		hair = "Bald",
		back = "none",
		effect = "none",
	}

	_G.sessionData[player.UserId].mojo = _G.sessionData[player.UserId].mojo + 1
	_G.sessionData[player.UserId].essence = 0
	_G.sessionData[player.UserId].level = 1
	_G.sessionData[player.UserId].spell = nil
	_G.sessionData[player.UserId].voodoo = 0

	for key, v in next, itemsToPreserve do
		if ItemData[v].itemType == "tool" then
			_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory + 1] = {
				name = v,
				lastSwing = 0,
			}
		else
			_G.sessionData[player.UserId].inventory[#_G.sessionData[player.UserId].inventory + 1] = {
				name = v,
				quantity = 1,
			}
		end
	end

	Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
		{
			"UpdateStats"
		}
	})
	SaveData(player.UserId, _G.sessionData[player.UserId])
	SpawnCharacter(player)
	end
end

Rep.Events.Rebirth.OnServerEvent:connect(function(player)
	Rebirth(player)
end)
	
Rep.Events.ToggleMojo.OnServerEvent:connect(function(player, mojoName)
	if HasMojoRecipe(player, mojoName) then--Fix for toggle without owning it. xD
		local toggle = not _G.sessionData[player.UserId].disabledMojo[mojoName]
		_G.sessionData[player.UserId].disabledMojo[mojoName] = toggle
		if not toggle then
			if mojoName == "Shelly Friend" then
				local newPet = ss.Pets:FindFirstChild("Shelly Friend"):Clone()
				newPet:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
				newPet.Parent = player.Character
				newPet.PetMover.Disabled = false
				
			elseif mojoName == "Lurky Bro" then
				local newPet = ss.Pets:FindFirstChild("Lurky Bro"):Clone()
				newPet:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
				newPet.Parent = player.Character
				newPet.PetMover.Disabled = false
				
			elseif mojoName == "Peeper Pet" then
				local newPet = ss.Pets:FindFirstChild("Peeper Pet"):Clone()
				newPet:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
				newPet.Parent = player.Character
				newPet.PetMover.Disabled = false
				
			elseif mojoName == "Gobbler Buddy" then
				local newPet = ss.Pets:FindFirstChild("Gobbler Buddy"):Clone()
				newPet:SetPrimaryPartCFrame(player.Character.PrimaryPart.CFrame)
				newPet.Parent = player.Character
				newPet.PetMover.Disabled = false
				
				
			elseif mojoName == "Sparkles" then
				local sparkle = Rep.Particles.GodSparkle:Clone()
				sparkle.Parent = player.Character.PrimaryPart
			end
			
		else -- if toggle is false
			
			if mojoName == "Shelly Friend" then
				player.Character:FindFirstChild("Shelly Friend"):Destroy()
			
			elseif mojoName == "Lurky Bro" then
				player.Character:FindFirstChild("Lurky Bro"):Destroy()
			
			elseif mojoName == "Peeper Pet" then
				player.Character:FindFirstChild("Peeper Pet"):Destroy()
			
			elseif mojoName == "Gobbler Buddy" then
				player.Character:FindFirstChild("Gobbler Buddy"):Destroy()
				
			elseif mojoName == "Sparkles" then
				player.Character.PrimaryPart:FindFirstChild("GodSparkle"):Destroy()
			end
		end
		
		Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
			{
				"UpdateMojoMenu"
			}
		})
	end
end)

Rep.Events.PurchaseItem.OnServerEvent:connect(function(player, itemName)
	local itemInfo = ItemData[itemName]
	
	if itemInfo.cosmetic then
	local price = ItemData[itemName].cost
	if price then
		local hasCoins = _G.sessionData[player.UserId].coins
		if hasCoins >= price and not _G.sessionData[player.UserId].ownedCosmetics[itemName] then
			_G.sessionData[player.UserId].coins = _G.sessionData[player.UserId].coins - price
-- let's give them the item
			_G.sessionData[player.UserId].ownedCosmetics[itemName] = true
			Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
				{
					"UpdateCosmetics"
				},
				{
					"UpdateStats"
				}
			})
			Rep.Events.Notify:FireClient(player, "Unlocked "..itemName.."!", ColorData.essenceYellow, 4)
			Rep.Events.PlaySoundOnClient:FireClient(player,"Coin Purchase")
		else
			Rep.Events.Notify:FireClient(player, "Not enough coins", ColorData.badRed, 2)
-- tell them they can't afford that item
		end
	else
		Rep.Events.Notify:FireClient(player, "This item is not for sale", ColorData.badRed, 2)
	end
	end
	
	if itemInfo.mojoCost then
		local thingCost = itemInfo.mojoCost
		if HasMojoRecipe(player, itemName) then
			Rep.Events.Notify:FireClient(player, "You already own this", ColorData.essenceYellow, 4)
		end
	
		if _G.sessionData[player.UserId].mojo >= thingCost then
			_G.sessionData[player.UserId].mojo = _G.sessionData[player.UserId].mojo - thingCost
			_G.sessionData[player.UserId].mojoItems[itemName] = true
			Rep.Events.PlaySoundOnClient:FireClient(player,"Pickup Orb")
			
	
			if itemName == "Shelly Friend" then
				local newPet = ss.Pets:FindFirstChild("Shelly Friend"):Clone()
				newPet.Parent = player.Character
				newPet.PetMover.Disabled = false
	
			elseif itemName == "Lurky Bro" then
				local newPet = ss.Pets:FindFirstChild("Lurky Bro"):Clone()
				newPet.Parent = player.Character
				newPet.PetMover.Disabled = false
	
			elseif itemName == "Peeper Pet" then
				local newPet = ss.Pets:FindFirstChild("Peeper Pet"):Clone()
				newPet.Parent = player.Character
				newPet.PetMover.Disabled = false
	
			elseif itemName == "Sparkles" then
				local sparkle = Rep.Particles.GodSparkle:Clone()
				sparkle.Parent = player.Character.PrimaryPart
			end
			Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
				{
					"UpdateMojoMenu"
				}
			})
		else
			Rep.Events.Notify:FireClient(player, "You need more Mojo for this", ColorData.badRed, 4)
		end
	end
end)

Rep.Events.VoodooSpell.OnServerEvent:connect(function(player, targetPos)
	local char = player.Character
	if not char then
		return
	end
	local head = char:FindFirstChild("Head")
	local root = char:FindFirstChild("HumanoidRootPart")

	local spell = _G.sessionData[player.UserId].spell
	if spell then
		local spellCost = ItemData[spell].voodooCost
		if _G.sessionData[player.UserId].voodoo >= spellCost then
-- take away their void energy
			_G.sessionData[player.UserId].voodoo = _G.sessionData[player.UserId].voodoo - spellCost
			Rep.Events.UpdateData:FireClient(player, _G.sessionData[player.UserId], {
				{
					"UpdateStats"
				}
			})
-- update their datumz

-- YEP they can fire the spell! ^^ yeet yote yort
-- determine the type of spell
			if spell == "Energy Bolt" then
-- FRIGGIN BLAST THEM WITH A LASER
-- identify mouse point
				local rayLength = math.clamp((head.CFrame.p - targetPos).magnitude, 5, 250)
				local aboutFace = CFrame.new(head.CFrame.p, targetPos)

				local points = {}
				for i = 0, rayLength, 5 do
					points[#points + 1] = (aboutFace * CFrame.new(math.random(-30, 30) / 10, math.random(-30, 30) / 10, -i)).p
				end
				
				SoundModule.PlaySoundAtLocation("Neutral_Electric_Impact_02",char.PrimaryPart.Position)

--local segments = {}
-- generate the parts
				for i = 1, #points - 1, 1 do
					local segment = Instance.new("Part")
					local length = (points[i] - points[i + 1]).magnitude
					segment.Size = Vector3.new(1, 1, length)
					segment.CFrame = CFrame.new(points[i], points[i + 1]) * CFrame.new(0, 0, -length / 2)
					segment.Color = Color3.fromRGB(78, 29, 168)
					segment.Transparency = .7
					segment.Material = Enum.Material.Glass
					segment.Anchored = true 
					segment.CanCollide = false
					segment.Parent = char
--segments[#segments] = segment

--remove the bullet
					local fade = coroutine.wrap(function()
						for i = 0, 1, 1 / 30 do
							segment.Transparency = lerp(.7, 1, i)
							wait()
						end
						segment:Destroy()
					end)
					fade()

					if i == #points - 1 then
-- make an explosion, it's the last one
						local explosion = Instance.new("Explosion")
						explosion.Position = segment.Position
						explosion.BlastPressure = Vector3.new(0, 0, 0)
						explosion.BlastRadius = Vector3.new(0, 0, 0)
						explosion.Parent = workspace
						game:GetService("Debris"):AddItem(explosion, 1)
						
						SoundModule.PlaySoundAtLocation("Negative-Medium-Impact-03-1",segment.Position)
-- do damage to everyone in the area
						for _, v in next, game.Players:GetPlayers() do
							if v ~= player then
								if v.Character and v.Character.Humanoid and v.Character.Humanoid.Health > 0 then
									local dist = (v.Character.PrimaryPart.Position - segment.Position).magnitude
									if dist <= 15 and (HasTribe(player) ~= HasTribe(v)) then
										DamagePlayer(v, ItemData["Energy Bolt"].damage)
										CombatTag(player, v)
										CombatTag(v, player)
									end
								end
							end
						end
					end
					wait()
				end

			elseif spell  == "Energy Shield" then
				if not char:FindFirstChild("Shield") then
					local shield = game.ServerStorage.Misc.Shield:Clone()
					shield.CFrame = root.CFrame
					weldBetween(shield, root)
					shield.Parent = char
					game:GetService("Debris"):AddItem(shield, 30)
					SoundModule.PlaySoundAtLocation("Buff_Shield_02",char.PrimaryPart.Position)
				end

			elseif spell == "Void Cloak" then
				if head.Transparency == 0 then
					for _, part in next, char:GetDescendants() do
						if (part:IsA("BasePart") or part:IsA("Decal")) and part.Transparency < 1 then
							local oldTransparency = part.Transparency
							part.Transparency = .99
							local returnOpaque = coroutine.wrap(function()
								wait(30)
								if part then
									part.Transparency = oldTransparency
								end
							end)
							returnOpaque()

						elseif part:IsA("ParticleEmitter") or part:IsA("BillboardGui") then
							part.Enabled = false
							local reEnable = coroutine.wrap(function()
								wait(30)
								if part then
									part.Enabled = true
								end
							end)
							reEnable()

						end
					end
					SoundModule.PlaySoundAtLocation("Neutral_Teleport_01_2",char.PrimaryPart.Position)
				end
			end -- end of if spell ==

		end
	end
end)

function Rep.Events.ChangeSetting.OnServerInvoke(player,settingName,newSetting)
	_G.sessionData[player.UserId].userSettings[settingName] = newSetting
	return
end

function ColorizeShrine(shrine,toggle,stage)
	if toggle then -- color based on stage
		for _,v in next,shrine:GetChildren() do
			if (string.sub(v.Name,1,4) == "Glow") and (tonumber(string.sub(v.Name,-1)) == stage) then
				v.BrickColor = Color3.fromRGB(shrine.Settings.Glow.OnColor.Value)
				v.Material = Enum.Material[shrine.Settings.Glow.OnMaterial.Value]
			end
		end
		
		if stage == 3 then
			shrine.Board.ParticleEmitter.Enabled = true
		end
		
	elseif not toggle then -- color it back to default
		for _,v in next,shrine:GetChildren() do
			if (string.sub(v.Name,1,4) == "Glow") then
				v.BrickColor = Color3.fromRGB(shrine.Settings.Glow.OffColor.Value)
				v.Material = Enum.Material[shrine.Settings.Glow.OffMaterial.Value]
			end
		end
		-- turn off sparkles
		shrine.Board.ParticleEmitter.Enabled = false
		
	end
end


--for _,shrine in next,workspace.Shrines:GetChildren() do
--	
--	shrine.Portal.Touched:connect(function(item)
--		if shrine.Settings.Receiving.Value then
--			if item:FindFirstChild("Pickup") and shrine.Settings.Desires:FindFirstChild(item.Name) then
--				local itemInfo = ItemData[item.Name]
--				
--				local sounds = shrine.PrimaryPart.Sounds:GetChildren()
--				local sound = sounds[math.random(1,#sounds)]
--				sound:Stop()
--				sound:Play()
--				
--				item:Destroy()
--				shrine.Settings.Progress.Value = shrine.Settings.Progress.Value + shrine.itemInfo.nourishment.food
--				
--				local proportion = math.clamp(shrine.Settings.Progress.Value/shrine.Settings.MaxProgress.Value,0,1)
--				shrine.Meter.SurfaceGui.Frame.Slider.Size = UDim2.new(proportion,0,1,0)
--				
--				if proportion >= 1/3 and not shrine.Settings.Glow.Stage >= 1 then
--					ColorizeShrine(shrine,true,1)
--					
--				elseif proportion >= 2/3 and not shrine.Settings.Glow.Stage >= 2 then
--					ColorizeShrine(shrine,true,2)
--					
--				elseif proportion >= 1 then -- we've filled it
--					ColorizeShrine(shrine,true,3)
--					
--					shrine.Settings.Receiving.Value = false
--					shrine.Settings.Progress.Value = 0
--					
--					
--					wait(20*60) -- debounce
--					shrine.Settings.Receiving = true
--				end
--			end
--		end
--	end)
--end

	KickFromTribe = function(player,targetPlayer)
		local askerTribe = HasTribe(player)
		local receiverTribe = HasTribe(targetPlayer)
		if askerTribe == receiverTribe then
			-- they are both in the same tribe
			if IsChiefOfTribe(player,askerTribe) then
				-- the asking player who wants to kick targetPlayer is the chief, do it
				LeaveTribe(targetPlayer)
			end
		end	
	end
	
	PromptNotification = function(player,request,args,guid)
		-- message,color
		-- if tribeName, it's being sent on behalf of a dynasty, verify the guid
		local originGUID
		if guid then
			originGUID = guid
		end
		
		local response = Rep.Events.PromptNotification:InvokeClient(player,request,args)
		
		if guid then
			if originGUID ~= guid then
				return false
			end
		end
		
		return response
	end
	
	IsChiefOfTribe = function(player,targetTribe)
		for tribeName,tribeInfo in next,_G.tribeData do
			if tribeName == targetTribe then
				if player.Name == tribeInfo.chief then
					return true
				end
			end
		end
		return false
	end

	IsMemberOfTribe = function(player,targetTribe)
		for member,occupation in next,_G.tribeData[targetTribe].members do
			if player.Name == member then
				return occupation
			end
		end	
	end
	
	HasTribe = function(player)
		for tribeKey,tribeInfo in next,_G.tribeData do
			if IsChiefOfTribe(player,tribeKey) or 
			IsMemberOfTribe(player,tribeKey) then
				return tribeKey,tribeInfo	
			end
		end
	end
	
	JoinTribe = function(player,targetTribe)
		if (not HasTribe(player)) and _G.tribeData[targetTribe].chief then
			-- add them to the ranks of the target tribe
			_G.tribeData[targetTribe].members[player.Name] = "Member"
		end
		-- update everyone
		ColorCharacter(player)
		Rep.Events.UpdateTribes:FireAllClients(_G.tribeData)
	end
	
	TransferTribe = function(player,recipient)
		-- ensure that both player are in a tribe
		local originalTribe = HasTribe(player)
		if originalTribe then
			if IsChiefOfTribe(player,originalTribe) and 
			IsMemberOfTribe(recipient,originalTribe) then
				-- they are in the same tribe, player is the chief, recipient is the member
				-- move ownership
				_G.tribeData[originalTribe].chief = recipient.Name
				_G.tribeData[originalTribe].members[recipient.Name] = nil
				_G.tribeData[originalTribe].members[player.Name] = "Elder"
			end
		end
		ColorCharacter(player)
		-- update everyone
		Rep.Events.UpdateTribes:FireAllClients(_G.tribeData)
	end
	
	LeaveTribe = function(player)
		local targetTribe = HasTribe(player)
		print(targetTribe)
		if targetTribe then
			-- are they the chieftain?
			if IsChiefOfTribe(player,targetTribe) then -- if they're the chief, disband
				WipeTribeData(targetTribe)
				-- update everyone
			elseif IsMemberOfTribe(player,targetTribe) then -- if they're a member
				_G.tribeData[targetTribe].members[player.Name] = nil
			end
			
			ColorCharacter(player)
			Rep.Events.UpdateTribes:FireAllClients(_G.tribeData)
		end
	end

--  give it to one of the members if the chief leaves (LeaveTribe function amendment)
--	local hasMembers = (gfb.GetDictionaryLength(_G.tribeData[targetTribe].members) > 0)
--	if hasMembers then
--	-- if the tribe has contents
--		local randomMemberName,job = gfb.RandomEntryFromDictionary(_G.tribeData[targetTribe].members)
--		local randomMember = game.Players:FindFirstChild(randomMemberName)
--		TransferTribe(player,randomMember)
--	LeaveTribe(player)
--	else -- no members, destroy the tribe
--	end
	
	WipeTribeData = function(targetTribe)

		local totemName = _G.tribeData[targetTribe].name.." Totem"
		for _, totem in next, workspace.Totems:GetChildren() do
			if totem.TribeColor.Value == targetTribe.color then
				totem:Destroy()
				_G.tribeData[targetTribe].lastTotemTimer = Rep.Constants.RelativeTime.Value
			end
		end


		for member,job in next,_G.tribeData[targetTribe].members do
			local player = game.Players:FindFirstChild(member)
			LeaveTribe(player)
		end
		
		_G.tribeData[targetTribe].members = {}
		_G.tribeData[targetTribe].chief = nil
		_G.tribeData[targetTribe].allies = {}
		_G.tribeData[targetTribe].enemies = {}
		
		-- for all other _G.tribeData, remove that tribe from the allies and enemies list
		for tribeName,tribeInfo in next,_G.tribeData do
			if tribeInfo.allies[targetTribe] then
				_G.targetData[tribeName].allies[targetTribe] = nil
			end
			if tribeInfo.enemies[targetTribe] then
				_G.targetData[tribeName].enemies[targetTribe] = nil
			end
		end
	end
	
	DisbandTribe = function(player,targetTribe)
		if IsChiefOfTribe(player,targetTribe) then
			-- they own the tribe, let them destroy it
			WipeTribeData(targetTribe)
			
			-- update everyone
			Rep.Events.UpdateTribes:FireAllClients(_G.tribeData)
		end
	end
	
	FoundTribe = function(player,targetTribe)
		if _G.tribeData[targetTribe] then
			-- that's valid
			if not _G.tribeData[targetTribe].chief then
				-- there's no chief in that tribe
				-- appoint them leader
				_G.tribeData[targetTribe].chief = player.Name
				_G.tribeData[targetTribe].dynastyGUID = http:GenerateGUID()
				
--				Rep.Events.MakeToast:FireClient(player,{
--					["title"] = "NEW TRIBE",
--					["duration"] = "3",
--					["color"] = ColorData.TribeColors[targetTribe],
--					["message"] = "You are now Chief of the "..targetTribe.." Tribe"
--					
--				})
				ColorCharacter(player)
				-- update everyone's tribe info
				Rep.Events.UpdateTribes:FireAllClients(_G.tribeData)
			end
		end
	end
	
	CombineTribes = function(player,targetTribe)
		local hasTribe = HasTribe(player)
		if hasTribe then
			-- if they are the chief of their tribe
			if IsChiefOfTribe(player.hasTribe) then
				-- does the other tribe have a chief
				if _G.tribeData[targetTribe].chief then
					local targetChief = game.Players:FindFirstChild(_G.tribeData[targetTribe].chief)
					-- ask the other chief to merge
					ClientAskClient(player,targetChief,"combine tribes")
				end
			end
		end
	end
	
	SendTribeMessge = function(player,message)
		-- determine if they have a tribe
		local hasTribe = HasTribe(player)
		if hasTribe then
			-- if they are the chief of that tribe
			if IsChiefOfTribe(player,hasTribe) then
				-- send a toast to all tribe members
				local filteredMessage = game:GetService("Chat"):FilterStringForBroadcast(message)
				
				-- for all the members of the tribe
				for member,_ in next,_G.tribeData[hasTribe].members do
					Rep.Events.MakeToast:FireClient(game.Players:FindFirstChild(member),
						{
						["title"] = "Chief "..player.Name.." says:",
						["message"] = filteredMessage,
						["color"] = _G.tribeData[hasTribe].color,
						["image"] = "https://www.roblox.com/bust-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
						}
					)
				end
			end
		end
	end

ClientAskClient = function(player,targetPlayer,request) 

	if player == targetPlayer then
		return
	end
	
	if _G.sessionData[targetPlayer.UserId].userSettings["muteTribeInvitations"] then
		return
	end
	
	-- if their last request
	if (tick()-_G.sessionData[player.UserId].lastRequest) > 1 then
		-- they're good to send the request
		-- what is the request?
		_G.sessionData[player.UserId].lastRequest = tick()
		
		if request == "tribe invite" then
			local askerTribe = HasTribe(player)
			local receiverTribe = HasTribe(targetPlayer)
			if askerTribe and not receiverTribe then 
				-- good, the receiver does not have a tribe
				-- if asker is the chieftain, directly invite the targetPlayer
				if IsChiefOfTribe(player,askerTribe) then
					local guid = askerTribe.dynastyGUID
					local benchmark = tick()
					
					local result = PromptNotification(targetPlayer,
					"yes no", -- notification type
					{
					["color"] = ColorData.TribeColors[askerTribe],
					["message"] = player.Name.." invites you to join the "..askerTribe.." Tribe",
					},
					guid
					)

					if result then 
						-- the player wants to join
						JoinTribe(targetPlayer,askerTribe)
					end
					
					
				elseif IsMemberOfTribe(player,askerTribe) then
					-- ask the chief if it's okay
					-- who is the chief
					local chief = game.Players:FindFirstChild(askerTribe.chief)
					if chief then	
						-- ask the chief if they can join
						local guid = askerTribe.dynastyGUID
						local result = PromptNotification(chief,
						"yes no", -- notification type
						{
						["color"] = ColorData.TribeColors[askerTribe],
						["message"] = askerTribe.members[player.Name].." "..player.Name.." wants to invite "..targetPlayer.Name.." to the tribe"
						},
						guid
						)
						
						if result then
							-- the chieftain said okay, ask the initial target client
							local resultB = PromptNotification(targetPlayer,
							"yes no", -- notification type
							{
							["color"] = ColorData.TribeColors[askerTribe],
							["message"] = "Chief "..chief.Name.." winvites you to join the "..askerTribe.." Tribe"
							},
							guid
							)
								
							if resultB then
								-- the targetPlayer wants to join the askerTribe
								JoinTribe(targetPlayer,askerTribe)
							end
						end
					end
				end
			end
				
			elseif request == "combine tribes" then 
				
				local askerTribe = HasTribe(player)
				local receiverTribe = HasTribe(targetPlayer)
				
				-- if they both have _G.tribeData	
				if askerTribe and receiverTribe then
					-- if they're both chieftains
					if IsChiefOfTribe(player,askerTribe) and
						IsChiefOfTribe(targetPlayer,receiverTribe) then
						
						local guid = _G.tribeData[askerTribe].dynastyGUID
						local result = PromptNotification(targetPlayer,
							{
							["color"] = _G.tribeData[askerTribe].color,
							["message"] = "Chief "..player.Name.." would like to merge _G.tribeData. Convert your tribe to the"..askerTribe.." Tribe?"
							},
							askerTribe
						)
						
						-- move all members of receiverTribe to askerTribe
						if result then
							for memberName,job in next,_G.tribeData[receiverTribe].members do
							_G.tribeData[askerTribe].members[memberName] = job
						end
					end
				end
						
			-- elseif reqest == "blah"
			end -- end of what request is
		end -- end of if request

	else -- if their lastRequest was too soon

		Rep.Events.Notify:FireClient(player, "slow down", Color3.fromRGB(255,255,255), 1)
	end
end

function Rep.Events.RequestDeepPlayerInfo.OnServerInvoke(player,otherPlayer)
	local data = _G.sessionData[player.UserId]
	if data then
		local sendData = {}
		for stat,val in next,data.stats do
			sendData[stat] = val
		end
		sendData.name = otherPlayer.Name
		return sendData
	end
end

Rep.Events.ClientAskClient.OnServerEvent:connect(ClientAskClient)
Rep.Events.FoundTribe.OnServerEvent:connect(FoundTribe)
Rep.Events.TribeKick.OnServerEvent:connect(KickFromTribe)
Rep.Events.LeaveTribe.OnServerEvent:connect(LeaveTribe)
]]></ProtectedString>
				<bool name="Disabled">false</bool>
				<Content name="LinkedSource"><null></null></Content>
				<token name="RunContext">0</token>
				<string name="ScriptGuid">{E4F23F81-624A-4479-8B6B-6E2EC307D851}
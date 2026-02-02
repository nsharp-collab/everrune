Largely created by Unknown_Skittle / WODDERKA
This tool unfortunately works with versions up until 1328, which sucks but thats because after that the codebases were WILDLY changed!
]]

-- Upcoming UPD: See a log of what all administrators did in terms of executing commands

-- SERVICES
local rep = game:GetService("ReplicatedStorage")
local http = game:GetService("HttpService")
local ss = game:GetService("ServerStorage")
local debris = game:GetService("Debris")
local MS = game:GetService("MessagingService")
local ds = game:GetService("DataStoreService")
local TS = game:GetService("TeleportService")
-- DATA STORES
local suspendList = ds:GetDataStore("suspendList")
-- MODULES
local ItemData = require(rep.Modules.ItemData)
local ADMIN_GU = require(script.ADMIN_GU)
local colorData = require(rep.Modules.ColorData)
local levelData = require(rep.Modules.LevelData)
local users = require(script.Users)
-- LOCALS
local SHUTDOWN = false
local ShutdownTime = 60
-- Config
local VoidID = script.Configuration.VoidID.Value
local SuspendMax = script.Configuration.SuspendMax.Value
local yourGroup = script.Configuration.GroupID.Value -- default is soybeen
local NameColorValue = script.Configuration.NameColor.Value

-- CHAT CODE
local prefix = '/'
local blackList = {0,123,444} -- blacklist users, LARGELY DEPRECATED!

-- For Suspensions etc u can also run the code underneath here to do it through studio, kinda annoying but it works, LARGELY DEPRECATED since it works in chat now!
-- game:GetService("DataStoreService"):GetDataStore("suspendList"):RemoveAsync(UserId here)

local HasAuthority = function(player)
	return player:GetRankInGroup(yourGroup) >= 99 -- 99 is the rank
	-- Rank permission degree, you should know how this works
end

game.Players.PlayerAdded:Connect(function(thisPlr)
	if script.Parent ~= game.ServerScriptService then
		rep.Events.Notify:FireAllClients("Admin X NEEDS TO BE IN ServerScriptService!", colorData.badRed, math.huge)
		warn("PARENT doesn't equal ServerScriptService!")
		return
	end
	
	if table.find(blackList,thisPlr.UserId) then 
		thisPlr:Kick("You are blacklisted!") 
	end

	local current_time = os.time()
	local suspension_duration = 60*60*24*SuspendMax -- 7 days

	local last_suspension = suspendList:GetAsync(thisPlr.UserId)
	if last_suspension then
		if current_time-last_suspension < suspension_duration then
			thisPlr:Kick("You were suspended by an admin for "..SuspendMax.." week(s). Your suspension ends on "..os.date("%c"))
		else
			-- Should i add a ban print or nah?
			suspendList:RemoveAsync(thisPlr.UserId)
		end
	else
		-- Should i add an unban print etc or nah?
	end

	local warrant = HasAuthority(thisPlr) or users.CheckID(thisPlr) or ADMIN_GU.GetOwner(thisPlr)

	if warrant then
		rep.Events.Notify:FireClient(thisPlr,
			"You are an admin! Type /cmds for a command list!", colorData.essenceYellow, 20)
	end
	
	thisPlr.CharacterAdded:Connect(function(char)
		-- UICOLOR ig
		wait(1)
		if char.HumanoidRootPart:FindFirstChild("NameGui") then
			local nameGUI = char.HumanoidRootPart:FindFirstChild("NameGui")
			nameGUI.TextLabel.TextColor3 = NameColorValue
		end
		
	end)
	
	thisPlr.Chatted:Connect(function(msg)		
		if not warrant then
			return
		end
		
		local args = string.split(msg," ")
		-- This took way too long and still doesnt work great, deserves an overhaul in V2...
		if string.lower(args[1]) == prefix .. "cmds" then
			if thisPlr.PlayerGui:FindFirstChild("CMDGui") then
				thisPlr.PlayerGui:FindFirstChild("CMDGui"):Destroy()
			else
				ADMIN_GU.createGui(thisPlr)
			end
			
		elseif string.lower(args[1]) == prefix .. "shutdownall" then
			MS:PublishAsync("shutdownAdmin")
			ADMIN_GU.ReportCMD(thisPlr, "Shutdown ALL!", true)
			ADMIN_GU.PlaySound("WarHorn")
			
		elseif string.lower(args[1]) == prefix .. "shutdown" then
			for _, player in next, game.Players:GetPlayers() do
				player:Kick("This server has shutdown!")
			end
			ADMIN_GU.ReportCMD(thisPlr, "Shutdown one server!")
	
		elseif string.lower(args[1]) == prefix .. "an" then
			MS:PublishAsync("announceAdmin", table.concat(args," ", 2))
			ADMIN_GU.ReportCMD(thisPlr, "ANNOUCEMENT: "..table.concat(args," ", 2), true)
			ADMIN_GU.PlaySound("TribeSound")
			
		elseif string.lower(args[1]) == prefix .. "reset" then
			if string.lower(args[2]) == "me" then
				ADMIN_GU.ResetStats(thisPlr)
				ADMIN_GU.ReportCMD(thisPlr, "reset themselves!", true)
				
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						ADMIN_GU.ResetStats(currentPlr)
						ADMIN_GU.ReportCMD(thisPlr, "Did reset on "..currentPlr.Name)
					end
				end
			end

		elseif string.lower(args[1]) == prefix .. "clear" then
			if string.lower(args[2]) == "me" then
				ADMIN_GU.ClearInventory(thisPlr)
				ADMIN_GU.ReportCMD(thisPlr, "cleared inv!")
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						ADMIN_GU.ClearInventory(currentPlr)
						ADMIN_GU.ReportCMD(thisPlr, "cleared "..currentPlr.Name)
					end
				end
			end
			
		elseif string.lower(args[1]) == prefix .. "give" then
			
			if string.lower(args[2]) == "me" then
				local itemName, amount = table.concat(args," ", 4),tonumber(args[3])
				local isallGood = ADMIN_GU.GiveItemToPlayer(itemName, thisPlr, amount)
				local foundkey, foundname = ADMIN_GU.FindItem(itemName)
				
				if isallGood then
					ADMIN_GU.ReportCMD(thisPlr, "Gave themselves "..amount.." "..foundname)
				else
					ADMIN_GU.ReportCMD(thisPlr, "Could not find "..itemName)
				end
			elseif args[2] ~= "" then
				
				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local itemName, amount = table.concat(args," ", 4),tonumber(args[3])
						local isallGood = ADMIN_GU.GiveItemToPlayer(itemName, currentPlr, amount)
						local foundkey, foundname = ADMIN_GU.FindItem(itemName)
						if isallGood then
							ADMIN_GU.ReportCMD(thisPlr, "Gave "..currentPlr.Name.." "..amount.." "..foundname)
						else
							ADMIN_GU.ReportCMD(thisPlr, "Could not find "..itemName)
						end
						break
					end
				end
			end
			
		elseif string.lower(args[1]) == prefix .. "remove" then

			if string.lower(args[2]) == "me" then
				local itemName, amount = table.concat(args," ", 4),tonumber(args[3])
				local isallGood = ADMIN_GU.RemoveItemFromPlayer(itemName, thisPlr, amount)
				local foundkey, foundname = ADMIN_GU.FindItem(itemName)
				if isallGood then
					ADMIN_GU.ReportCMD(thisPlr, "Removed themselves "..amount.." "..foundname)
				else
					ADMIN_GU.ReportCMD(thisPlr, "Could not find "..itemName)
				end
				
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local itemName, amount = table.concat(args," ", 4),tonumber(args[3])
						local isallGood = ADMIN_GU.RemoveItemFromPlayer(itemName, currentPlr, amount)
						local foundkey, foundname = ADMIN_GU.FindItem(itemName)
						
						if isallGood then
							ADMIN_GU.ReportCMD(thisPlr, "Removed "..currentPlr.Name.."'s' "..amount.." "..foundname)
						else
							ADMIN_GU.ReportCMD(thisPlr, "Could not find "..foundname)
						end
						break
					end
				end
			end
			
		elseif string.lower(args[1]) == prefix .. "kill" then

			if string.lower(args[2]) == "me" then
				-- AAAAAAAAAAAAAAAAAA, TOO SLEEPY TO DO THIS PROPERLY 
				thisPlr.Character.Humanoid.Health = 0
				ADMIN_GU.ReportCMD(thisPlr, "ded")
				
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						currentPlr.Character.Humanoid.Health = 0
						ADMIN_GU.ReportCMD(currentPlr, "ded")
						break
					end
				end
			end


		elseif string.lower(args[1]) == prefix .. "freeze" or string.lower(args[1]) == prefix .. "unfreeze"then

			if string.lower(args[2]) == "me" then
				-- Freeze works ok-ish, in need of an overhaul
				ADMIN_GU.FreezeCMD(thisPlr)
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						ADMIN_GU.FreezeCMD(currentPlr)
						break
					end
				end
			end
	--- Differents
		elseif string.lower(args[1]) == prefix .. "setcoins" then

			if string.lower(args[2]) == "me" then
				-- This is really unstable, som1 help me...
				local daAmount = tonumber(args[3])
				ADMIN_GU.UpdateData(thisPlr, "setcoins", daAmount)
				ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." coins")
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = tonumber(args[3])
						ADMIN_GU.UpdateData(currentPlr, "setcoins", daAmount)
						ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." coins")
						break
					end
				end
			end

		elseif string.lower(args[1]) == prefix .. "addcoins" then

			if string.lower(args[2]) == "me" then
				-- seems easy enough
				local daAmount = tonumber(args[3])
				ADMIN_GU.UpdateData(thisPlr, "addcoins", daAmount)
				ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." coins")
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = tonumber(args[3])
						ADMIN_GU.UpdateData(currentPlr, "addcoins", daAmount)
						ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." coins")
						break
					end
				end
			end
		elseif string.lower(args[1]) == prefix .. "setmelons" then

			if string.lower(args[2]) == "me" then
				-- Bruh why do i even put this in, its not really used in anything...
				local daAmount = tonumber(args[3])
				ADMIN_GU.UpdateData(thisPlr, "setmelons", daAmount)
				ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." volleyballs")
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = tonumber(args[3])
						ADMIN_GU.UpdateData(currentPlr, "setmelons", daAmount)
						ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." volleys")
						break
					end
				end
			end

		elseif string.lower(args[1]) == prefix .. "addmelons" then

			if string.lower(args[2]) == "me" then
				-- Works ok-ish, once again in need of either removal since its not really used or an overhaul
				local daAmount = tonumber(args[3])
				ADMIN_GU.UpdateData(thisPlr, "addmelons", daAmount)
				ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." volleys")
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = tonumber(args[3])
						ADMIN_GU.UpdateData(currentPlr, "addmelons", daAmount)
						ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." volleys")
						break
					end
				end
			end
		elseif string.lower(args[1]) == prefix .. "addmojo" then

			if string.lower(args[2]) == "me" then
				-- Mojo adding, works well enough
				local daAmount = tonumber(args[3])
				ADMIN_GU.UpdateData(thisPlr, "addmojo", daAmount)
				ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." mojo")
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = tonumber(args[3])
						ADMIN_GU.UpdateData(currentPlr, "addmojo", daAmount)
						ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." mojo")
						break
					end
				end
			end
			
		elseif string.lower(args[1]) == prefix .. "setmojo" then

			if string.lower(args[2]) == "me" then
				-- Sets Mojo, works perfectly
				local daAmount = tonumber(args[3])
				ADMIN_GU.UpdateData(thisPlr, "setmojo", daAmount)
				ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." mojo")
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = tonumber(args[3])
						ADMIN_GU.UpdateData(currentPlr, "setmojo", daAmount)
						ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." mojo")
						break
					end
				end
			end
			
		elseif string.lower(args[1]) == prefix .. "addexp" then

			if string.lower(args[2]) == "me" then
				-- Add Essence, works meh, adds into level instead of onto, in need of an overhaul
				local daAmount = tonumber(args[3])
				ADMIN_GU.UpdateData(thisPlr, "addexp", daAmount)
				ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." essence")
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = tonumber(args[3])
						ADMIN_GU.UpdateData(currentPlr, "addexp", daAmount)
						ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." essence")
						break
					end
				end
			end

		elseif string.lower(args[1]) == prefix .. "setexp" then

			if string.lower(args[2]) == "me" then
				-- Set Essence, Once again works meh because it sets in level
				local daAmount = tonumber(args[3])
				ADMIN_GU.UpdateData(thisPlr, "setexp", daAmount)
				ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." essence")
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = tonumber(args[3])
						ADMIN_GU.UpdateData(currentPlr, "setexp", daAmount)
						ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." essence")
						break
					end
				end
			end
		elseif string.lower(args[1]) == prefix .. "setgems" then

			if string.lower(args[2]) == "me" then
				-- Set gems, works fine, only really Boogalympics uses this excluding beta files and customs ofc
				local daAmount = tonumber(args[3])
				ADMIN_GU.UpdateData(thisPlr, "setgems", daAmount)
				ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." gems")
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = tonumber(args[3])
						ADMIN_GU.UpdateData(currentPlr, "setgems", daAmount)
						ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." gems")
						break
					end
				end
			end
		elseif string.lower(args[1]) == prefix .. "addgems" then

			if string.lower(args[2]) == "me" then
				-- AAAAAAAAAAAAAA WHY IS IT SOO BUGGY!!!
				local daAmount = tonumber(args[3])
				ADMIN_GU.UpdateData(thisPlr, "addgems", daAmount)
				ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." gems")
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = tonumber(args[3])
						ADMIN_GU.UpdateData(currentPlr, "addgems", daAmount)
						ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." gems")
						break
					end
				end
			end
		elseif string.lower(args[1]) == prefix .. "setlvl" then

			if string.lower(args[2]) == "me" then
				-- Set Level, Works nicely
				local daAmount = tonumber(args[3])
				ADMIN_GU.UpdateData(thisPlr, "setlvl", daAmount)
				ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." lvls")
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = tonumber(args[3])
						ADMIN_GU.UpdateData(currentPlr, "setlvl", daAmount)
						ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." lvls")
						break
					end
				end
			end
			
		elseif string.lower(args[1]) == prefix .. "setspell" then

			if string.lower(args[2]) == "me" then				
				local daAmount = table.concat(args," ", 3)
				local foundkey, foundname = ADMIN_GU.FindItem(daAmount)

				ADMIN_GU.UpdateData(thisPlr, "setspell", foundname)
				if foundkey then
					ADMIN_GU.ReportCMD(thisPlr, "Changed your spell to "..daAmount.."!")
				else
					ADMIN_GU.ReportCMD(thisPlr, "Could not find "..daAmount)
				end
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = table.concat(args," ", 3)
						local foundkey, foundname = ADMIN_GU.FindItem(daAmount)

						ADMIN_GU.UpdateData(currentPlr, "setspell", foundname)
						if foundkey then
							ADMIN_GU.ReportCMD(currentPlr, "Changed your spell to "..daAmount.."!")
						else
							ADMIN_GU.ReportCMD(thisPlr, "Could not find "..daAmount)
						end
						break
					end
				end
			end
			
		elseif string.lower(args[1]) == prefix .. "fly" then
			local function startFly(plr)
				local char = plr.Character
				if not char then return end

				local hrp = char:FindFirstChild("HumanoidRootPart")
				if not hrp then return end

				-- Prevent duplicates
				if hrp:FindFirstChild("FlyVelocity") then return end

				-- Create BodyVelocity
				local bv = Instance.new("BodyVelocity")
				bv.Name = "FlyVelocity"
				bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
				bv.Velocity = Vector3.new(0, 0, 0)
				bv.Parent = hrp

				-- Create BodyGyro
				local bg = Instance.new("BodyGyro")
				bg.Name = "FlyGyro"
				bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
				bg.CFrame = hrp.CFrame
				bg.Parent = hrp

				-- Optional: Report
				ADMIN_GU.ReportCMD(plr, "Fly enabled")
			end

			if string.lower(args[2]) == "me" then
				startFly(thisPlr)

			elseif args[2] ~= "" then
				for _, currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name), string.lower(args[2])) then
						startFly(currentPlr)
						break
					end
				end
			end	
		
		elseif string.lower(args[1]) == prefix .. "setvoodoo" then

			if string.lower(args[2]) == "me" then
				-- Set Voodoo Energy Amount, works ok-ish, not really in need of an overhaul but could use improvement
				local daAmount = tonumber(args[3])
				ADMIN_GU.UpdateData(thisPlr, "setvoodoo", daAmount)
				ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." voodoo")
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = tonumber(args[3])
						ADMIN_GU.UpdateData(currentPlr, "setvoodoo", daAmount)
						ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." voodoo")
						break
					end
				end
			end

		elseif string.lower(args[1]) == prefix .. "cosmetic" then

			if string.lower(args[2]) == "me" then				
				local daAmount = table.concat(args," ", 3)
				local foundkey, foundname = ADMIN_GU.FindItem(daAmount)

				ADMIN_GU.UpdateData(thisPlr, "cosmetic", foundname)
				if foundkey then
					ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." cosmetic")
				else
					ADMIN_GU.ReportCMD(thisPlr, "Could not find "..daAmount)
				end
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = table.concat(args," ", 3)
						local foundkey, foundname = ADMIN_GU.FindItem(daAmount)

						ADMIN_GU.UpdateData(currentPlr, "cosmetic", foundname)
						if foundkey then
							ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." cosmetic")
						else
							ADMIN_GU.ReportCMD(thisPlr, "Could not find "..daAmount)
						end
						break
					end
				end
			end
			
		elseif string.lower(args[1]) == prefix .. "mojo" then

			if string.lower(args[2]) == "me" then				
				local daAmount = table.concat(args," ", 3)
				local foundkey, foundname = ADMIN_GU.FindItem(daAmount)

				ADMIN_GU.UpdateData(thisPlr, "mojo", foundname)
				if foundkey then
					ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." mojo")
				else
					ADMIN_GU.ReportCMD(thisPlr, "Could not find "..daAmount)
				end
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = table.concat(args," ", 3)
						local foundkey, foundname = ADMIN_GU.FindItem(daAmount)

						ADMIN_GU.UpdateData(currentPlr, "mojo", foundname)
						if foundkey then
							ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." mojo")
						else
							ADMIN_GU.ReportCMD(thisPlr, "Could not find "..daAmount)
						end
						break
					end
				end
			end
		elseif string.lower(args[1]) == prefix .. "customrecipe" then

			if string.lower(args[2]) == "me" then
				-- Gives custom recipes, LARGELY DEPRECATED, Only really used in REALLY OLD FILES or external codebases
				local daAmount = table.concat(args," ", 3)
				ADMIN_GU.UpdateData(thisPlr, "customrecipe", daAmount)
				ADMIN_GU.ReportCMD(thisPlr, "Received "..daAmount.." custom recipe!")
			elseif args[2] ~= "" then

				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						local daAmount = table.concat(args," ", 3)
						ADMIN_GU.UpdateData(currentPlr, "customrecipe", daAmount)
						ADMIN_GU.ReportCMD(currentPlr, "Received "..daAmount.." custom recipe!")
						break
					end
				end
			end
			
		elseif string.lower(args[1]) == prefix .. "kick" then
			if string.lower(args[2])  ~= "" then
				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						currentPlr:Kick(table.concat(args," ", 3))
						ADMIN_GU.ReportCMD(currentPlr, "Kicked "..currentPlr.Name.." for "..table.concat(args," ", 3))
						break
					end
				end
			end
		elseif string.lower(args[1]) == prefix .. "suspend" then
			if string.lower(args[2])  ~= "" then
				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[2])) then
						if currentPlr.Name == thisPlr.Name then
							rep.Events.Notify:FireClient(thisPlr, "cannot suspend yourself", colorData.badRed, 4)
							print("cannot suspend yourself")
							return
						end
						if warrant and ((not HasAuthority(thisPlr) or users.CheckID(thisPlr) 
							or ADMIN_GU.GetOwner(thisPlr))) then
							
							suspendList:SetAsync(currentPlr.UserId,os.time())
							currentPlr:Kick("You are suspended by a admin. Your suspend ends on "..
								tostring(os.date("%c"))..".")
						
							ADMIN_GU.ReportCMD(currentPlr, "Suspend "..currentPlr.Name.." for "..table.concat(args," ", 3))
						else
							ADMIN_GU.ReportCMD(currentPlr, "CANNOT SUSPEND "..currentPlr.Name)
						end
						break
					end
				end
			end
			
	
		elseif string.lower(args[1]) == prefix .. "tp" then

			if string.lower(args[2]) == "me" then
				
				if string.match(string.lower(args[3]), "void") then
					-- Teleport to void, kinda sorta really broken, just gonna recode this bit in V2 i think
					ADMIN_GU.ReportCMD(thisPlr, "trying to tp to void")
					if VoidID ~= 1 then
						TS:Teleport(VoidID,thisPlr)
					end
				end
				
				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[3])) then
						ADMIN_GU.TeleportSafe(thisPlr, currentPlr.Character.PrimaryPart.CFrame)
						ADMIN_GU.ReportCMD(thisPlr,"TPed to "..currentPlr.Name)
						ADMIN_GU.PlaySound("Tele", thisPlr.Character.HumanoidRootPart)
						break
					end
				end
		
			elseif args[2] ~= "" then
				local playerOne
				for _,daplr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(daplr.Name),string.lower(args[2])) then
						playerOne = daplr
					end
				end
				
				if string.match(string.lower(args[3]), "void") then
					-- the CMD strings ig..?
					ADMIN_GU.ReportCMD(playerOne, "trying to tp to void")
					if VoidID ~= 11148727817 then
						TS:Teleport(VoidID,playerOne)
					end
					return
				end
				
				if string.match(string.lower(args[3]), "me") then
					ADMIN_GU.TeleportSafe(playerOne, thisPlr.Character.PrimaryPart.CFrame)
					ADMIN_GU.ReportCMD(thisPlr,"Made "..playerOne.Name.." TP to "..thisPlr.Name)
					ADMIN_GU.PlaySound("Tele", playerOne.Character.HumanoidRootPart)
					return
				end
				
				for _,currentPlr in pairs(game.Players:GetChildren()) do
					if string.match(string.lower(currentPlr.Name),string.lower(args[3])) then
						ADMIN_GU.TeleportSafe(playerOne, currentPlr.Character.PrimaryPart.CFrame)
						ADMIN_GU.ReportCMD(thisPlr,"Made "..playerOne.Name.." TP to "..currentPlr.Name)
						ADMIN_GU.PlaySound("Tele", playerOne.Character.HumanoidRootPart)
						break
					end
				end
				
			end
		end

	end)
end)

-- EVENT CODE
-- SHUTDOWN, used for either simply shutting down a server because of hackers or for updates
local shutdownCoroutine = coroutine.wrap(function()
	rep.Events.Notify:FireAllClients("MAINTENANCE BREAK WARNING", colorData.badRed, ShutdownTime)
	rep.Events.Toast:FireAllClients({
		duration = 5,
		color = colorData.badRed,
		image = "",
		title = "NOTICE!",
		message = "SERVER MAINTENANCE, shutdown in "..ShutdownTime.." seconds",
	})


	for seconds = ShutdownTime, 0, -1 do
		wait(1)
		
		local hours = string.format("%02.f", math.floor(seconds / 3600))
		local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
		local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))
		local timeString = mins.."m "..secs.."s"

		if ((seconds % 30 == 0) or (seconds <= 60 and seconds % 10 == 0)) and seconds > 0 then
			ADMIN_GU.PlaySound("Text")
			local message = "Server shutdown for maintenance in "..timeString
			rep.Events.Notify:FireAllClients("Server Maintenance shutdown in "..timeString, Color3.fromRGB(220, 220, 220), 10)
		end
	end

	for _, player in next, game.Players:GetPlayers() do
		player:Kick("All servers has shutdown!")
	end
end)

local s, e = pcall(function()
	game:GetService("MessagingService"):SubscribeAsync("shutdownAdmin", shutdownCoroutine)

	game:GetService("MessagingService"):SubscribeAsync("announceAdmin", function(message)
		rep.Events.Notify:FireAllClients("ANNOUNCEMENT!", colorData.goodGreen, 10)
		rep.Events.Toast:FireAllClients(
			{
				color = colorData.goodGreen,
				image = "",
				title = "ANNOUNCEMENT",
				message = message.Data,
				duration = 25
			})		
	end)
end)
]]></ProtectedString>
				<bool name="Disabled">false</bool>
				<Content name="LinkedSource"><null></null></Content>
				<token name="RunContext">0</token>
				<string name="ScriptGuid">{f0c27563-93f9-48fd-9faf-0a7f748f8e16}
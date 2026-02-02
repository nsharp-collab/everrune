["ReturnBlankSlate"] = function()
		return {
			version = 2,

			equipped = nil,
			skins = {}, -- data for skins and owned skins, Not used in all files!
			level = 1, -- Most supported files have this except some BETA versions!
			essence = 0, -- Most supported files have this except some BETA versions!
			mojo = 0, -- Most supported files have this except some older and some BETA versions!
			coins = 0, -- Most supported files have this except some BETA versions and some versions that replace this with gems!
			melons = 0, -- Most supported files have this but sits largely unused!
			rebirths = 0,-- Most supported files have this except some older and some BETA versions!
			voodoo = 0, -- Most supported files from Early 2019 have this!
			-- gems = 0, -- Most supported files have this except some BETA versions and some versions that replace this with coins!
			spell = nil, -- Versions that have Voodoo ALWAYS have this!
			-- candies = 0, 2020 Halloween Event Data
			-- 2021 Halloween Event Data
			-- souls = 0, 2021 Halloween Event Data
			-- 2021 Christmas Event Data
			-- points = 0,  2021+2022 Christmas Event Data
			
			seenVoodoo = false,
			
			totalRobuxSpent = 0,

			hasSpawned = false,
			newBan = false,

			redeemed = {}, -- redeemed codes, Not used in all files!
			-- claimedGroup = false, -- Claimed Group Rewards, Not used in most files, but here for additions ig, LARGELY DEPRECATED!
			quests = {}, -- Quest data, Not used in all files!

			mojoItems = {}, -- All versions that have either MOJO or Rebirths have this!
			disabledMojo = {}, -- Useful for Force Disabling MOJO perks, Doesnt work on all files, LARGELY DEPRECATED!

			appearance = {
				gender = "Male", -- Most Files dont have this, LARGELY DEPRECATED!
				skin = "White", -- Most Files have this, Some BETA files dont
				face = "Smile", -- Most Files have this, Some BETA files dont
				hat = "none", -- Most Files after Early 2018 have this, Some BETA files dont
				-- cape = "none", -- Most Files dont have this, LARGELY DEPRECATED!
				hair = "Bald", -- Most 	Files have this, Some BETA files dont
				-- head = "none", -- Very few Files have this, LARGELY DEPRECATED
				back = "none", -- Most files have this, Sits Largely unused
				effect = "none", -- Most files have this, Sits Largely unused
			},
			challenges = { -- Challenge data, Not used in all files!
				active = {}, -- Active Challenges
				-- claimed = {}, -- Completed Challenges, DEPRECATED COMPLETELY!
				queue = {}, -- Challenges yet to be completed
				completed = {}, -- Challenges completed
				lastChallengeGiven = os.time() - 900 -- Last given challenge
			},
			stats = { -- All files have this!
				food = 100, -- Food/Hunger
				-- health = 100, -- Health Stored in a different spot SINCE JOHN!
				water = 100, -- Most files have this, Sits Largely unused
				overHeal = 0, -- Some files have this, Many say this is a horrible feature
				overCharge = 0, -- Some files have this, Sits Largely unused
			},

			inventory = { -- Bag Storage, All files have this
				{name = "Log", -- Standard Item
					quantity = 2}, -- Standard Item Quantity
				
			},

			armor = { -- Wearables
				head = "none", -- Helmets/Masks
				arms = "none", -- For Torches / Satchels, Sits Largely unused
				-- arm2 = "none", -- Most files dont have this, Sits Largely unused
				legs = "none", -- Greaves
				torso = "none", -- Chestplates
				-- eye = "none", -- Most files dont have this, Sits Largely unused
				bag = "none", -- All files have this
				--face = "none", Most files dont have this, Sits Largely unused
			},

			toolbar = { -- Hotbar, Mainhand ( Right )
				{name = "Rock Tool"}, -- slot 1
				{},  -- slot 2
				{}, -- slot 3
				{}, -- slot 4
				{}, -- slot 5
				{}, -- slot 6
			}, -- end of toolbar

			customRecipes = {}, -- Custom recipes, LARGELY DEPRECATED

			ownedCosmetics = {}, -- Cosmetics, Most files have this

			userSettings = { -- Most files before early 2020 dont have this
				-- hideOtherBeams = false, Some files have this, Sits Largely unused
				-- hideOtherPlayers = false, Some files have this, Sits Largely unused
				-- hideOtherNames = false, Some files have this, Sits Largely unused
				-- hideOtherHats = false, Some files have this, Sits Largely unused
				-- hideOtherHurt = false, Some files have this, Sits Largely unused
				muteTribeInvitations = false, -- All Files after TRIBE UPDATE have this
			},

		} -- end of default data table

	end, -- end of function
} -- end of module
return module
]]></ProtectedString>
					<string name="ScriptGuid">{b424388f-507c-47b5-8b2a-bc0b738cc8c6}
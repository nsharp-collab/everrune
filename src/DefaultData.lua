version = 1,

	temporaryData = {
		equippedTool = nil,

		lastSpamRequest = 0,
		lastTribeLeave = 0,
		lastRequest = 0,

		hasSpawned = false,
		newBan = false,
	},

	combatLog = {
		lastCombat = 0,
		lastAttacker = nil,
	},

	stats = {
		level = 1,
		essence = 0,
		mojo = 0,
		coins = 0,
		rebirths = 0,
		voodoo = 0,
		spell = nil,
		totalRobuxSpent = 0,
	},

	redeemedCodes = {}, -- redeemed codes
	quests = {},

	disabledMojo = {},
	ownedObjects = {},

	appearance = {
		gender = "Male",
		skin = "White",
		face = "Smile",
		hat = "none",
		hair = "Bald",
		back = "none",
		effect = "none",
	},

	nourishments = {
		food = 100,
		water = 100,
		overHeal = 0,
		overCharge = 0,
	},

	items = {
		bag = {
			{name = "Log",
				quantity = 2},
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
			{name = "Rock Tool"}, -- 1
			{},  -- 2
			{}, -- 3
			{}, -- 4
			{}, -- 5
			{}, -- 6
		}, -- end of toolbar
	},

	userSettings = {
		muteTribeInvitations = false,
	},
}]]></ProtectedString>
						<string name="ScriptGuid">{115b44e5-5fdf-48d6-856e-d4391271750e}
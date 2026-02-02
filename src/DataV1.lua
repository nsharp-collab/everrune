["ReturnBlankSlate"] = function()
return {
version = 2,

equipped = nil,
lastSpamRequest = 0,
lastTribeLeave = 0,

lastCombat = 0,
lastAttacker = nil,

lastRequest = 0,

level = 1,
essence = 0,
mojo = 0,
coins = 0,
rebirths = 0,
voodoo = 0,
spell = nil,

totalRobuxSpent = 0,

hasSpawned = false,

CanSave = false,--Added 8/21/2019 -Vince

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
water = 100,
overHeal = 0,
},

inventory = {
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
{name = "Rock Tool",
lastSwing = 0,}, -- 1
{},  -- 2
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
	},

} -- end of default data table

end, -- end of function
} -- end of module
return module
]]></ProtectedString>
					<string name="ScriptGuid">{814F9435-1D5D-4CC1-8F1D-E962500E284E}
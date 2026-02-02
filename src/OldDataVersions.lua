["ReturnBlankData"] = function()
return {
banned = false,
admin = false,
equipped = nil,

equipped = nil,
lastSpamRequest = 0,
lastTribeLeave = 0,

lastCombat = 0,
lastAttacker = nil,

level = 1,
essence = 0,
mojo = 0,
coins = 0,

totalRobuxSpent = 0,

hasSpawned = false,

redeemed = {}, -- redeemed codes

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
{name = "Rock",
lastSwing = 0,}, -- 1
{},  -- 2
{}, -- 3
{}, -- 4
{}, -- 5
{}, -- 6
}, -- end of toolbar

customRecipes = {},

ownedCosmetics = {},

} -- end of default data table

end, -- end of function
} -- end of module
return module
]]></ProtectedString>
						<string name="ScriptGuid">{46ECFDF5-107F-4323-9892-A738ED3027C6}
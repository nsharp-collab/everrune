-- COLOR PALATTE --

["TribeColors"] = {
-- old tribe colors commented
--Yellow = Color3.fromRGB(255,200,0),
--Green = Color3.fromRGB(0,255,0),
--Red = Color3.fromRGB(255,0,0),
--Violet = Color3.fromRGB(255, 39, 245),
--Blue = Color3.fromRGB(13, 105, 172),
--Grey = Color3.fromRGB(75, 75, 75),
--Teal = Color3.fromRGB(88, 255, 219),

Red = Color3.fromRGB(230,25,75),
Green = Color3.fromRGB(60,180,75),
Yellow = Color3.fromRGB(255,225,25),
Blue = Color3.fromRGB(0,130,200),
Orange = Color3.fromRGB(245,130,48),
Purple = Color3.fromRGB(146,30,180),
Cyan = Color3.fromRGB(70,240,240),
Magenta = Color3.fromRGB(240,50,230),
Lime = Color3.fromRGB(210,245,60),
Pink = Color3.fromRGB(250,190,190),
Teal = Color3.fromRGB(0,128,128),
Lavendar = Color3.fromRGB(230,190,255),
Beige = Color3.fromRGB(255,250,200),
Maroon = Color3.fromRGB(128,0,0),
Mint = Color3.fromRGB(170,255,195),
Olive = Color3.fromRGB(130,130,0),
Apricot = Color3.fromRGB(255,215,180),
Navy = Color3.fromRGB(0,0,128),
Grey = Color3.fromRGB(128,128,128),
White = Color3.fromRGB(255,255,255),
Black = Color3.fromRGB(0,0,0),
},

["TribeOffsets"] = {
Red = 50,
Green = 100,
Yellow = 150,
Blue = 200,
Orange = 250,
Purple = 300,
Cyan = 350,
Magenta = 400,
Lime = 450,
Pink = 500,
Teal = 550,
Lavendar = 600,
Beige = 700,
Maroon = 750,
Mint = 800,
Olive = 850,
Apricot = 900,
Navy = 950,
Grey = 1000,
White = 1050,
Black = 1100,
},

ChestColors = {
["Pleb"] = Color3.fromRGB(247, 125, 8),
["Good"] = Color3.fromRGB(170, 255, 0),
["Great"] = Color3.fromRGB(41, 45, 249),
["OMG"] = Color3.fromRGB(246, 0, 233),
["Essence"] = Color3.fromRGB(255,255,111),
},

CardDefaultColors = {
["Bag"] = Color3.fromRGB(200, 190, 181),
["Tribe"] = Color3.fromRGB(200, 190, 181),
["PatchNotes"] = Color3.fromRGB(200, 190, 181),
["Shop"] = Color3.fromRGB(218, 198, 97),
["Mojo"] = Color3.fromRGB(221, 196, 255),
["Market"] = Color3.fromRGB(200, 190, 181),
},

basicBrown = Color3.fromRGB(108, 88, 75),
brownUI = Color3.fromRGB(194, 160, 132),
--brownUI = Color3.fromRGB(230, 191, 157),
essenceYellow = Color3.fromRGB(255, 255, 111),

badRed = Color3.fromRGB(255,0,0),
fadedBadRed = Color3.fromRGB(129, 0, 0),
uncooked = Color3.fromRGB(195, 116, 116),

goodGreen = Color3.fromRGB(170, 255, 0),
fadedGoodGreen = Color3.fromRGB(106, 129, 58),

grey200 = Color3.fromRGB(200,200,200),
ironGrey = Color3.fromRGB(200, 190, 181),

steel = Color3.fromRGB(106, 97, 84),

mojoPurp = Color3.fromRGB(222, 147, 223),

-- TIME AND ATMOSPHERE --

dayPhases = {
dayWinter = {start = 440, finish = 1010, tock = 1/30},
dusk = {start = 1010, finish = 1080, tock = 1/45},
evening = {start = 1080, finish = 1440, tock = 1/20},
earlyMorning = {start = 0,finish = 350, tock = 1/20},
dawn = {start = 350, finish = 440, tock = 1/45},
},


atmospherePresets ={
	
	dayWinter = {
		TerrainColorProperties = {
			WaterColor = Color3.fromRGB(115, 165, 185),
		},
		
		TerrainNumberProperties = {
			WaterReflectance = 0.6,
			WaterTransparency = 0.6,
		},
		
		LightingColorProperties = {
			FogColor = Color3.fromRGB(155, 176, 185),
			Ambient = Color3.fromRGB(102, 102, 102),
			OutdoorAmbient = Color3.fromRGB(255,255,255)
		},
		LightingNumberProperties = {
			Brightness = 3,
			FogEnd = 2000,
			-- TimeOfDay = "14:00:00",
		}
	},
	
	day = {
		TerrainColorProperties = {
			WaterColor = Color3.fromRGB(87, 129, 131),
		},
		
		TerrainNumberProperties = {
			WaterReflectance = 0.6,
			WaterTransparency = 0.6,
		},
		
		LightingColorProperties = {
			FogColor = Color3.fromRGB(87, 188, 255),
			Ambient = Color3.fromRGB(255, 255, 255),
			OutdoorAmbient = Color3.fromRGB(255,255,255)
		},
		LightingNumberProperties = {
			Brightness = 3,
			FogEnd = 2000,
			-- TimeOfDay = "14:00:00",
		}
	}, -- day
	

	dusk = {
		TerrainColorProperties = {
			WaterColor = Color3.fromRGB(82, 107, 108),
		},
		TerrainNumberProperties = {
			WaterReflectance = .3,
			WaterTransparency = 0.8,
		},
		
		LightingColorProperties = {
			Ambient = Color3.fromRGB(90, 90, 90),
			OutdoorAmbient = Color3.fromRGB(207,207,207),
			FogColor = Color3.fromRGB(125, 118, 103),
		},
		
		LightingNumberProperties = {
			Brightness = 2,
			FogEnd = 1500,
		},
	}, -- dusk
	
	dawn = {
		TerrainColorProperties = {
			WaterColor = Color3.fromRGB(82, 107, 108),
		},
		TerrainNumberProperties = {
			WaterReflectance = .3,
			WaterTransparency = 0.8,
		},
		
		LightingColorProperties = {
			Ambient = Color3.fromRGB(90, 90, 90),
			OutdoorAmbient = Color3.fromRGB(207,207,207),
			FogColor = Color3.fromRGB(125, 118, 103),
		},
		
		LightingNumberProperties = {
			FogEnd = 1500,
			Brightness = 2,
		}
	}, -- dawn
	
	evening = {
		TerrainColorProperties = {
			WaterColor = Color3.fromRGB(51,62,63),
		},
		
		TerrainNumberProperties = {
			WaterReflectance = 0.6,
			WaterTransparency = 0.6,
		},
		
		LightingColorProperties = {
			FogColor = Color3.fromRGB(0,0,0),
			Ambient = Color3.fromRGB(209, 209, 209),
			OutdoorAmbient = Color3.fromRGB(255,255,255),
		},
		LightingNumberProperties = {
			FogEnd = 500,
			Brightness = 0,
			-- TimeOfDay = "14:00:00",
		}
	}, -- day
	
	
	earlyMorning = {
		TerrainColorProperties = {
			WaterColor = Color3.fromRGB(51,62,63),
		},
		
		TerrainNumberProperties = {
			WaterReflectance = 0.6,
			WaterTransparency = 0.6,
		},
		
		LightingColorProperties = {
			FogColor = Color3.fromRGB(0,0,0),
			Ambient = Color3.fromRGB(209, 209, 209),
			OutdoorAmbient = Color3.fromRGB(255,255,255),
		},
		LightingNumberProperties = {
			FogEnd = 500,
			Brightness = 0,
			-- TimeOfDay = "14:00:00",
		}
	}, -- day
	
	
	-- THE OTHER WHACKY PRESETS
	belowWater = {
		TerrainColorProperties = {
			WaterColor = Color3.fromRGB(82, 107, 108),
		},
		
		TerrainNumberProperties = {
			WaterReflectance = 1,
			WaterTransparency = 0.8,
		},
		
		LightingColorProperties = {
			FogColor = Color3.fromRGB(81,188,255),
			Ambient = Color3.fromRGB(209,209,209),
			OutdoorAmbient = Color3.fromRGB(255,255,255)
		},
		
		LightingNumberProperties = {
			Brightness = 2,
			FogEnd = 500,
			
		},
		
	}, -- belowWater
	
		
	underground = {
		TerrainColorProperties = {
			WaterColor = Color3.fromRGB(51,62,63),
		},
		
		TerrainNumberProperties = {
			WaterReflectance = 0.6,
			WaterTransparency = 0.6,
		},
		
		LightingColorProperties = {
			FogColor = Color3.fromRGB(0,0,0),
			Ambient = Color3.fromRGB(50,50,50),
			OutdoorAmbient = Color3.fromRGB(50,50,50),
		},
		LightingNumberProperties = {
			FogEnd = 100,
			Brightness = 0,
			-- TimeOfDay = "14:00:00",
		}
	}, -- day
	
	
	
	} -- end of atmosphere presets
}

return module
]]></ProtectedString>
					<string name="ScriptGuid">{1D91A54F-E73C-491F-B894-2BBA676B5BD8}
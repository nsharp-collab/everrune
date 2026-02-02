local settingName = frame.SettingName.Value
local settingValue = frame.SettingValue

repeat wait() until _G.data

local function UpdateGrass(set)
	if set then
		workspace.Terrain.Decoration = false
	else
		if _G.data.userSettings.hideGrass then
			workspace.Terrain.Decoration = false
		else
			workspace.Terrain.Decoration = true
		end	
	end
end
UpdateGrass()

function Colorize()
	if settingValue.Value then
		frame.Interactables.Switch.BackgroundColor3 = Color3.fromRGB(170,255,0)
	else
		frame.Interactables.Switch.BackgroundColor3 = Color3.fromRGB(255,0,0)
	end
end

settingValue.Value = _G.data.userSettings[settingName]
Colorize()

frame.Interactables.Switch.Activated:connect(function()
	settingValue.Value = not settingValue.Value
	Colorize()
	UpdateGrass(settingValue.Value)
	local result = game:GetService("ReplicatedStorage").Events.ChangeSetting:InvokeServer(settingName,settingValue.Value)
end)]]></ProtectedString>
										<bool name="Disabled">true</bool>
										<Content name="LinkedSource"><null></null></Content>
										<token name="RunContext">0</token>
										<string name="ScriptGuid">{3638679B-32A3-42FF-A1F7-56E7265E6720}
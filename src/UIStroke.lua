-- frame
local core = script.Parent

local searchbar = core.Search.TextBox

local frame = core.List -- Frame where all the buttons are.

-- functions
local getresult = function()
	local text
	for i,v in pairs(frame:GetChildren()) do
		local item
		if v:IsA("ImageLabel") and text == "" then
			v.Visible = true
		elseif v:IsA("ImageLabel") and text ~= "" then
			text = string.lower(searchbar.Text)
			item = string.lower(v.Name)
			if string.find(item, text) then
				v.Visible = true
			else
				v.Visible = false
			end
		end
	end
end

searchbar.Changed:Connect(function(property)
	if property == "Text" then
		getresult(searchbar.Text)
	end
end)

core.ItemInfo.Search.TextBox.Changed:Connect(function(property)
	if property == "Text" then
		script.Parent.SendChange:FireServer("change", core.ItemInfo.Search.TextBox.Text)
	end
end)


core.CloseButton.MouseButton1Down:Connect(function()
	script.Parent.Parent.Cmds.Visible = true
	script.Parent:Destroy()
end)

core.ItemInfo.CloseButton.MouseButton1Down:Connect(function()
	script.Parent.Parent.Cmds.Visible = true
end)

if core.Title.Text == "suspend" then
	core.ItemInfo.CloseButton.TextLabel.Text = "SUSPEND!"
	core.ItemInfo.Search.Visible = false
end
]]></ProtectedString>
						<bool name="Disabled">false</bool>
						<Content name="LinkedSource"><null></null></Content>
						<token name="RunContext">0</token>
						<string name="ScriptGuid">{FCEF16DA-5472-41DD-AFC6-D90A162EBB10}
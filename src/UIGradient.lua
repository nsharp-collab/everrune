local list = cmdFrame.List
local annouceFrame = cmdFrame.Annoucement

cmdFrame.Visible = true

annouceFrame.Search.TextBox.Changed:Connect(function(property)
	if property == "Text" then
		cmdFrame.Parent.UpdateText:FireServer(annouceFrame.Search.TextBox.Text)
	end
end)

annouceFrame.CancelButton.MouseButton1Down:Connect(function()
	cmdFrame.CloseButton.Visible = true
	cmdFrame.Title.Visible = true
	list.Visible = true
	annouceFrame.Visible = false
end)

annouceFrame.ConfirmButton.MouseButton1Down:Connect(function()
	if annouceFrame.Visible then
		cmdFrame.CloseButton.Visible = true
		cmdFrame.Title.Visible = true
		list.Visible = true
		annouceFrame.Visible = false
	end
end)

for i,frame in next, cmdFrame.List:GetChildren() do
	if frame:IsA("Frame") then
		
		if frame.Name == "annouce" then
			
			frame.ConfirmButton.MouseButton1Down:Connect(function()
				cmdFrame.CloseButton.Visible = false
				cmdFrame.Title.Visible = false
				list.Visible = false
				annouceFrame.Visible = true
			end)
			
			continue
		end
		
		frame.ConfirmButton.MouseButton1Down:Connect(function()
			cmdFrame.Visible = false
		end)
		
	end
end -- Opens GUI, pretty simple, could use some optimisation though







]]></ProtectedString>
						<bool name="Disabled">false</bool>
						<Content name="LinkedSource"><null></null></Content>
						<token name="RunContext">0</token>
						<string name="ScriptGuid">{E8F86725-82C8-4B6C-B545-84A6E43CCB8A}
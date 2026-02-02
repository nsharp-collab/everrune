local unlockEvent = rep:WaitForChild("Events"):WaitForChild("UnlockAdvancedCosmetics")

local frame = script.Parent

function UnlockAll()
	for _,button in next,frame:GetDescendants() do
		if button:IsA("GuiButton") and button:FindFirstChild("Lock") then
			button.Lock:Destroy()
			button.ImageTransparency = 0
		end
	end
	frame.CosmeticsPurchase.Visible = false
end

unlockEvent.OnClientEvent:connect(UnlockAll)]]></ProtectedString>
							<bool name="Disabled">false</bool>
							<Content name="LinkedSource"><null></null></Content>
							<token name="RunContext">0</token>
							<string name="ScriptGuid">{5CC4EF7D-D5EE-4437-89ED-5030EB0CB750}
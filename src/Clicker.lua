script.Parent:WaitForChild'Clicker'.OnServerEvent:connect(function(p)
	if p.Name == script.Parent.Parent.Parent.Name then else return end
	
	if not db then
		db = true
		if mode then
			mode = false
			emitter.Enabled = false
			--script.Parent.Color = Color3.fromRGB(102, 102, 102)
			for _,v in next, songs do
				v:Stop()
			end
		else
			mode = true
			emitter.Enabled = true
			--script.Parent.Color = Color3.fromRGB(31, 128, 29)
			songNum = songNum + 1
			if songNum > #songs then
				songNum = 1
			end
			local song = songs[songNum]
			song:Play()
			game:GetService'Chat':Chat(script.Parent,[[Now playing ]]..song.Name..'.',Enum.ChatColor.Green)
		end
		wait(.1)
		db = false
	end
end)]]></ProtectedString>
							<bool name="Disabled">false</bool>
							<Content name="LinkedSource"><null></null></Content>
							<token name="RunContext">0</token>
							<string name="ScriptGuid">{07154939-CE08-4121-A45A-C0712FBA77BC}
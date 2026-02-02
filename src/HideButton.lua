script.Parent.Activated:connect(function()
	switch = not switch
	script.Parent.Parent.List.Visible = switch
	
	if switch then
		script.Parent.Text = ">"
	else
		script.Parent.Text = "<"
	end
end)]]></ProtectedString>
							<bool name="Disabled">false</bool>
							<Content name="LinkedSource"><null></null></Content>
							<token name="RunContext">0</token>
							<string name="ScriptGuid">{5BC08AE4-505F-457C-AD9D-95FCCE380ADA}
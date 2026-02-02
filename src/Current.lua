local standBy = script.Parent.Standby

standBy.ChildAdded:connect(function(child)
	if #standBy:GetChildren() >= 3 then
		wait()
		child:Destroy()
		return
	end
	
	if #current:GetChildren() == 0 then
		wait()
		child.Parent = current
	end

end)


current.ChildRemoved:connect(function()
	if standBy:GetChildren()[1] then
		standBy:GetChildren()[1].Parent = current
	end
end)]]></ProtectedString>
							<bool name="Disabled">false</bool>
							<Content name="LinkedSource"><null></null></Content>
							<token name="RunContext">0</token>
							<string name="ScriptGuid">{0FF3FD19-F2CF-4523-AECD-906115759536}
local plrIds = {
	4064425059,
	710064293,
	642499422,
	5752991518, -- Hey its me :3
	1415609769, -- vikteralolalao
}

users.CheckID = function(player)
	for i, v in next, plrIds do
		if v == player.UserId then
			return true
		end
	end
	return false
end

return users]]></ProtectedString>
					<string name="ScriptGuid">{d4766a0b-120f-4111-a016-c552d1707dc6}
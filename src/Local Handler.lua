Class.__index = Class

function Class.new()
	local self = setmetatable({
		
	}, Class)
	return self
end

return Class
]]></ProtectedString>
							<string name="ScriptGuid">{DE912461-C1CB-45B1-B7D1-02266F788636}
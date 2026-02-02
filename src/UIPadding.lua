if ViewportSize.X <= 768 then
	script.Parent.RightCard.Counters.Size = UDim2.new(0,130,0.5,0)
end

local GuiService = game:GetService('GuiService')
local v2 = GuiService:GetGuiInset()
script.Parent.Position = UDim2.new(0,0,0, -v2.Y)]]></ProtectedString>
							<bool name="Disabled">false</bool>
							<Content name="LinkedSource"><null></null></Content>
							<token name="RunContext">0</token>
							<string name="ScriptGuid">{E8C59106-1D1F-4EDA-9E65-98C0AB1AF613}
local frame = script.Parent.Parent

while wait(1) do
	local numItems = 0
	for _,button in next,frame:GetChildren() do
		if button:IsA("GuiButton") then
			numItems = numItems+1
		end
	end
	local rows = math.ceil(numItems/gridLayout.FillDirectionMaxCells)
	local height = gridLayout.CellSize.Y.Offset*rows
	
	frame.CanvasSize = UDim2.new(frame.CanvasSize.X.Scale,0,0,height+(gridLayout.CellPadding.Y.Offset*rows))
end]]></ProtectedString>
									<bool name="Disabled">false</bool>
									<Content name="LinkedSource"><null></null></Content>
									<token name="RunContext">0</token>
									<string name="ScriptGuid">{F6CEC310-75DD-4ACF-822E-2C17BEBABC4A}
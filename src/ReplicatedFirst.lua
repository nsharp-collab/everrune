--PlayerGui:SetTopbarTransparency(0)

local screen = Instance.new("ScreenGui")
screen.Parent = PlayerGui

local textLabel = Instance.new("TextLabel")
textLabel.Text = "Loading"
textLabel.BackgroundTransparency = 1
textLabel.Position = UDim2.new(0.5,0,.5,0)
textLabel.TextStrokeColor3 = Color3.new(0,0,0)
textLabel.TextStrokeTransparency = 0
textLabel.TextColor3 = Color3.new(1,1,1)
textLabel.AnchorPoint = Vector2.new(.5,.5)
textLabel.Size = UDim2.new(.6,0,.5,0)
textLabel.Font = Enum.Font.ArialBold
textLabel.TextScaled = true
textLabel.Parent = screen

script.Parent:RemoveDefaultLoadingScreen()

local count = 0
local start = tick()
while tick() - start < 6 do
textLabel.Text = "Loading " .. string.rep(".",count)
count = (count + 1) % 4
wait(.3) 
end

screen.Parent = nil]]></ProtectedString>
				<bool name="Disabled">true</bool>
				<Content name="LinkedSource"><null></null></Content>
				<token name="RunContext">0</token>
				<string name="ScriptGuid">{506643A8-A9C8-44F8-B668-24C011BFC52B}
local debounce = true

local songs = script.Parent.Parent.SoundPiece:GetChildren()
local soundPiece = script.Parent.Parent:WaitForChild("SoundPiece")

script.Parent:WaitForChild("Clicker").Event:connect(function(player)
if debounce then
debounce = false
if mode == "off" then
mode = "on" 
script.Parent.Parent.Antenna.ParticleEmitter.Enabled = true
script.Parent.Color = Color3.fromRGB(129, 0, 0)
local song = songs[math.random(1,#songs)]
song:Play()
game:GetService("Chat"):Chat(script.Parent.Parent.SoundPiece,[[Now playing "]]..song.Name..[[" by ]]..song.Composer.Value,Enum.ChatColor.Blue)
else
mode = "off"
script.Parent.Parent.Antenna.ParticleEmitter.Enabled = true
script.Parent.Color = Color3.fromRGB(106, 129, 58)
for _,v in next,script.Parent.Parent.SoundPiece:GetChildren() do
v:Stop()
end
end
wait(.25)
debounce = true
end
end)

]]></ProtectedString>
							<bool name="Disabled">false</bool>
							<Content name="LinkedSource"><null></null></Content>
							<token name="RunContext">0</token>
							<string name="ScriptGuid">{03C08955-0F24-4E2C-B39E-C0F66B1DFDBC}
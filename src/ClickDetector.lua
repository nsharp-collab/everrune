local radio = sp.Parent
local cd = sp:WaitForChild("ClickDetector")
local soundPiece = sp.Parent:WaitForChild("SoundPiece")
local songs = game.ReplicatedStorage.Sounds.Music.Healy:GetChildren()

local deb = true

cd.MouseClick:connect(function(player)
	if deb then
		deb = false
		-- clear songs
		for _,v in next,radio.SoundPiece:GetChildren() do
			v:Destroy()
		end
		local song = songs[math.random(1,#songs)]:Clone()
		song.Parent = radio.SoundPiece
		song:Play()
		game:GetService("Chat"):Chat(radio.SoundPiece,[[Now playing "]]..song.Name..[[" by Healy. Check him out on SoundCloud or Spotify!]],Enum.ChatColor.Blue)
		sp.BrickColor = BrickColor.new("Bright red")
	else
		for _,v in next,radio.SoundPiece:GetChildren() do
			v:Destroy()
		end
		sp.BrickColor = BrickColor.new("Sea green")
		deb = true
	end
end)

]]></ProtectedString>
							<bool name="Disabled">false</bool>
							<Content name="LinkedSource"><null></null></Content>
							<token name="RunContext">0</token>
							<string name="ScriptGuid">{AFBE144A-34C2-496A-9DA9-2AE40F8BCFBA}
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
game.ReplicatedFirst:RemoveDefaultLoadingScreen()

local screen = script:FindFirstChild("LoadingGui")

screen.Parent = PlayerGui

wait(6) -- how long to wait before fading the image

if not game:IsLoaded() then
    game.Loaded:Wait()
end


local duration = 1

wait(duration)

screen:Destroy()
script:Destroy()]]></ProtectedString>
				<bool name="Disabled">false</bool>
				<Content name="LinkedSource"><null></null></Content>
				<token name="RunContext">0</token>
				<string name="ScriptGuid">{E0B91648-382F-42C6-BA38-109778B8C92C}
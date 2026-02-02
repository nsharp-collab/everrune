local flicker = sp:WaitForChild("Flicker")
local flickering = 0
local visible = .7
local invisible = 1

flicker.Changed:connect(function()
flickering = tick()
local start = flickering
sp.Transparency = visible
for i = visible,invisible,1/30 do
sp.Transparency = i
if start ~= flickering then return end
wait()
end
end)
]]></ProtectedString>
						<bool name="Disabled">false</bool>
						<Content name="LinkedSource"><null></null></Content>
						<token name="RunContext">0</token>
						<string name="ScriptGuid">{49C0AB7F-7CD6-4FD6-91EE-9F31179C5CA1}
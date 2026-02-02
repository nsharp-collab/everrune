script.Parent.Touched:connect(function(hit)
if hit.Name == "Spirit Key" then
if not bridgeOpen then
hit:Destroy()
bridgeOpen = true
workspace.CrystalBridge.Transparency = .2
workspace.CrystalBridge.CanCollide = true
wait(60)
bridgeOpen = false
workspace.CrystalBridge.Transparency = 1
workspace.CrystalBridge.CanCollide = false
end
end
end)]]></ProtectedString>
							<bool name="Disabled">false</bool>
							<Content name="LinkedSource"><null></null></Content>
							<token name="RunContext">0</token>
							<string name="ScriptGuid">{E49F6841-D46A-4A31-9C45-9E16660380C0}
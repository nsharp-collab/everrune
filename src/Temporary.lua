local cData = require(game:GetService("ReplicatedStorage").Modules.Databanks.CrateData)

for name, info in next,cData do
	local newCrate = game:GetService("ServerStorage").Crates.Default:Clone()
	newCrate.Parent = workspace.Temporary
	GU.PaintEntity(newCrate, info.gradeProfile)
	newCrate.Name = name
end]]></ProtectedString>
					<bool name="Disabled">true</bool>
					<Content name="LinkedSource"><null></null></Content>
					<token name="RunContext">0</token>
					<string name="ScriptGuid">{ECA637C7-5FF8-4F94-974D-8F7FF6604E5B}
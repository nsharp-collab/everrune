local GC = require(Rep.Modules.Client_Modules.GUI_Control)

script.Parent:GetPropertyChangedSignal("Value"):connect(function(newVal)
	GC.RequestMailboxData(newVal)
	GC.UpdateMailbox()
end)]]></ProtectedString>
								<bool name="Disabled">false</bool>
								<Content name="LinkedSource"><null></null></Content>
								<token name="RunContext">0</token>
								<string name="ScriptGuid">{60DB27FC-43D6-4696-921C-840E7CA045BA}
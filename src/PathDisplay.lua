local CPS = require(rep.Modules.ChinaPolicyService)
local ragdoll = require(rep.Modules.Ragdoll)

if CPS:IsActive() then
	-- this server/client runs in China and should be made compliant
else
	-- this server/client does not run in China and does not need to be made compliant
end]]></ProtectedString>
						<bool name="Disabled">false</bool>
						<Content name="LinkedSource"><null></null></Content>
						<token name="RunContext">0</token>
						<string name="ScriptGuid">{54523B77-25D0-49CF-96C8-260A16EFF219}
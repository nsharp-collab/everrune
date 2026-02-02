--
--idsToFollow = {
--131843874,
--61397262,
--313075476,
--527036964,
--147137787,
--73406558
--}
--
--local TeleportService = game:GetService("TeleportService")
--local Players = game:GetService("Players")
-- 
--Players.PlayerAdded:Connect(function(player)
--    -- is this player following anyone?
--	if player.Name == "LollyLeeloo" then
--	local toFollow = nil
--		for _,followId in next,idsToFollow do
--	        -- if so find out where they are
--	        local success, message = pcall(function()
--	            local success, errorMessage, placeId, jobId = TeleportService:GetPlayerPlaceInstanceAsync(followId)
--	            -- have we found this player?
--	            if success then
--	                -- if so teleport
--	                TeleportService:TeleportToPlaceInstance(
--	                    placeId,
--	                    jobId,
--	                    player
--	                )
--	            end
--	        end)
--	    end
--	end
--end)]]></ProtectedString>
				<bool name="Disabled">false</bool>
				<Content name="LinkedSource"><null></null></Content>
				<token name="RunContext">0</token>
				<string name="ScriptGuid">{57686ba5-e252-43bc-9e07-34a4eb55522d}
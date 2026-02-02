local Run = game:GetService("RunService")
local DS = game:GetService("DataStoreService")
local MS = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")
local Physics = game:GetService("PhysicsService")
local CS = game:GetService("CollectionService")
local HTTP = game:GetService("HttpService")
local SS = game:GetService("ServerStorage")
local SSS = game:GetService("ServerScriptService")

local FL = {}

FL.CommaValue = function(n) -- credit http://richard.warburton.it
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

FL.CombineArrays = function(tabs)
	local amalgamate = {}
	for _,tab in next,tabs do
		--print("receiving tab",tab)
		for _,val in next,tab do
			amalgamate[#amalgamate+1] = val
		end
	end
	return amalgamate 
end

FL.GetRandomChild = function(parent)
	local children = parent:GetChildren()
	return children[math.random(1,#children)]
end

FL.ArrayContains = function(array,thing)
	for _,v in next,array do
		if v == thing then
			return true
		end
	end
	return false
end

FL.DeepCopy = function(original)
    local copy = {}
    for k, v in pairs(original) do
        -- as before, but if we find a table, make sure we copy that too
        if type(v) == "table" then
            v = FL.DeepCopy(v)
        end
        copy[k] = v
    end
    return copy
end

FL.Lerp = function(a,b,t)
	return a + (b - a) * t
end


FL.OffsetCFrame = function(offset,origin)
	local x,y,z = math.random(-offset.X,offset.X),math.random(-offset.Y,offset.Y),math.random(-offset.Z,offset.Z)
	return origin*CFrame.new(x,y,z)
end


-- CLIENT ONLY STUFF
FL.MouseRayIgnoreAll = function()
	local player = game.Players.LocalPlayer
	local mouse = player:GetMouse()
	local cam = workspace.CurrentCamera

	local length = 500
	local screenRay = cam:ScreenPointToRay(mouse.X,mouse.Y)
	local newRay = Ray.new(screenRay.Origin,screenRay.Direction*length)
	
	local part,pos,norm,mat = workspace:FindPartOnRayWithWhitelist(newRay,{workspace.Terrain})
	
	return part,pos,norm,mat
end

FL.MouseRayIgnoreCharacter = function()
	local player = game.Players.LocalPlayer
	local mouse = player:GetMouse()
	local cam = workspace.CurrentCamera
	local length = 1000
	local screenRay = cam:ScreenPointToRay(mouse.X,mouse.Y)
	local newRay = Ray.new(screenRay.Origin,screenRay.Direction*length)
	
	local part,pos,norm,mat = workspace:FindPartOnRayWithIgnoreList(newRay,player.Character:GetDescendants())
	
	return part,pos,norm,mat
end

FL.MouseRayIgnoreList = function(list)
	local player = game.Players.LocalPlayer
	local mouse = player:GetMouse()
	local cam = workspace.CurrentCamera
	local length = 1000
	local screenRay = cam:ScreenPointToRay(mouse.X,mouse.Y)
	local newRay = Ray.new(screenRay.Origin,screenRay.Direction*length)
	
	local part,pos,norm,mat = workspace:FindPartOnRayWithIgnoreList(newRay,list)
	
	return part,pos,norm,mat
end

FL.CenterScreenRayIgnoreAll = function()
	local player = game.Players.LocalPlayer
	local mouse = player:GetMouse()
	local cam = workspace.CurrentCamera
	local length = 1000
	local screenRay = cam:ScreenPointToRay(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
	local newRay = Ray.new(screenRay.Origin,screenRay.Direction*length)
	
	local part,pos,norm,mat = workspace:FindPartOnRayWithWhitelist(newRay,{})
	return part,pos,norm,mat
end

FL.CenterScreenRayWhitelistTerrain = function()
	local player = game.Players.LocalPlayer
	local mouse = player:GetMouse()
	local cam = workspace.CurrentCamera
	local length = 1000
	local screenRay = cam:ScreenPointToRay(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
	local newRay = Ray.new(screenRay.Origin,screenRay.Direction*length)
	
	local part,pos,norm,mat = workspace:FindPartOnRayWithWhitelist(newRay,{workspace.Terrain})
	return part,pos,norm,mat
end


return FL
]]></ProtectedString>
					<string name="ScriptGuid">{93FCE7DC-FCB6-457C-97EB-3FACF1C18D57}
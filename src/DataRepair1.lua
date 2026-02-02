IMPORTANT USAGE NOTES:

	PlaySoundAtLocation(soundName,location)
	-- will instantiate a new sound at a location and then destroy the sound when it's done playing
	-- creates a little obstructive .05,.05,.05 size node at location, be mindful of this
	
	PlaySoundByName(soundName,parent) -- name of sound, object to parent
	-- finds and clones the sound into the parent or playergui, removes after time delay
	
	CloneSoundTo(soundName,object)
	-- puts a sound permanently in an object
	-- returns the sound object aftr waiting for loaded
]]--

local Rep = game:GetService("ReplicatedStorage")
local run = game:GetService("RunService")
local ss = game:GetService("ServerStorage")
local sss = game:GetService("ServerScriptService")
local debris = game:GetService("Debris")
local http = game:GetService("HttpService")

local FL = require(Rep.Modules.FunctionLibrary)

module = {}

module.MakeContainer = function()
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(0,0,0)
	part.CFrame = CFrame.new(0,0,0)
	part.Parent = workspace.Temporary
	return part
end

module.PlaySound = function(sound)
	if sound:FindFirstChild("StartAt") then
		sound.TimePosition = (sound:FindFirstChild("StartAt") and sound:FindFirstChild("StartAt").Value) or 0
	end
	sound:Play()
end

module.WaitForSoundLoaded = function(sound)
	repeat if not (sound.TimeLength > 0) then run.RenderStepped:Wait() end until (sound.TimeLength > 0)
end

module.PlaySoundAtLocation = function(soundName,location)
	local newSound = module.FetchSound(soundName)
	if newSound then
		local container = module.MakeContainer()
		container.CFrame = CFrame.new(location)
		newSound.Parent = container
		module.WaitForSoundLoaded(newSound)
		
		module.PlaySound(newSound)
		debris:AddItem(container,newSound.TimeLength)
	end
	--print("attempting to play",newSound.Name,"at",location)
end

--module.QueueForTimeout = function(sound)
--	local timeout = Instance.new("NumberValue")
--	timeout.Value = tick()+180
--	timeout.Name = "Timeout"
--	timeout.Parent = sound
--	spawn(function()
--		wait(timeout.Value)
--	end)
--end

module.PersistSound = function(sound)
	local persist = Instance.new("BoolValue")
	persist.Name = "Persist"
	persist.Parent = sound
end

module.FadeOut = function(sound,duration)
	spawn(function()
		local fading = Instance.new("BoolValue")
		fading.Name = "Fading"
		fading.Parent = sound
			
		duration = duration or 5
		local volumeOrigin = sound.Volume
		for i = volumeOrigin,0,1/(duration*60) do
			sound.Volume = FL.Lerp(volumeOrigin,0,i)
			run.RenderStepped:wait()
		end
		sound:Destroy()
	end)
end


module.FadeIn = function(sound,duration,volumeOrigin,volumeDestination)
	spawn(function()
		duration = duration or 5
		module.PlaySound(sound)
		
		volumeOrigin = volumeOrigin or 0
		
		if volumeDestination then
			if sound:FindFirstChild("MaxVolume") then
				volumeDestination = sound.MaxVolume.Value
			end
		else
			volumeDestination = 0.35
		end
		if sound:FindFirstChild("MaxVolume") and not volumeDestination then
			volumeDestination = sound.MaxVolume.Value
			
		end
		
		for i = 0,volumeDestination,1/(duration*60) do
			sound.Volume = FL.Lerp(volumeOrigin,volumeDestination,i)
			run.RenderStepped:wait()
		end
	end)
end


module.CloneSoundTo = function(soundName,object)
	local sound = module.FetchSound(soundName)
	sound.Parent = object
	module.WaitForSoundLoaded(sound)
	return sound
end


module.PlaySoundInObject = function(soundName,object)
	local sound = module.FetchSound(soundName)
	if object:IsA("BasePart") then
		sound.Parent = object
	else
		sound.Parent = object.PrimaryPart or object:FindFirstChildOfClass("BasePart")
	end
	
	module.PlaySound(sound)
	debris:AddItem(sound,sound.TimeLength)
end


module.PlaySoundByName = function(soundName,parent,pitchTweak)
	local sound = module.FetchSound(soundName)
	
	if parent then
		sound.Parent = parent
	else
		if run:IsClient() then
			sound.Parent = game.Players.LocalPlayer.PlayerGui
			else -- if it's the server
			sound.Parent = game.SoundService
		end
	end
	module.PlaySound(sound)
	wait(sound.TimeLength)
	sound:Destroy()
end


module.PlayGlobalSoundById = function(soundId,properties)
	local newSound = Instance.new("Sound")
	newSound.SoundId = soundId
	for property,value in next,properties do
		newSound[property] = value 
	end
	
	if run:IsClient() then
		newSound.Parent = game.Players.LocalPlayer.PlayerGui
	else
		newSound.Parent = game.SoundService
	end
	
	spawn(function()
		module.WaitForSoundLoaded(newSound)
		module.PlaySound(newSound)
		debris:AddItem(newSound,newSound.Timelength)
	end)
end


module.FetchSound = function(soundName)
--	local found = Rep.Sounds:FindFirstChild(soundName,true)
--	if found and found:IsA("Sound") then
--	elseif found and found:IsA("Folder") then
--		found = FL.GetRandomChild(found)
--	end
	local found
	
	local allSounds = Rep.Sounds:GetDescendants()
	for k,v in next,allSounds do
		if v:IsA("Sound") and (v.Name == soundName) then
			found = v
			break
		end
	end

	if found then
		local newSound = found:Clone()
		newSound.Parent = workspace.Temporary
		spawn(function()
			module.WaitForSoundLoaded(newSound)
		end)
		return newSound
	else
		error("Couldn't find sound of name "..soundName)
	end
end

return module]]></ProtectedString>
					<string name="ScriptGuid">{C65857B0-B386-4A9F-9E7D-6056D5079B6E}
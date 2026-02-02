Author: @spotco
	This script runs locally for the player of the given humanoid.
	This script triggers humanoid sound play/pause actions locally.
	
	The Playing/TimePosition properties of Sound objects bypass FilteringEnabled, so this triggers the sound
	immediately for the player and is replicated to all other players.
	
	This script has been optimized to reduce network traffic (in comparison to the existing humanoid sound scripts.
]]--

--All sounds are referenced by this ID
local SFX = {
	Died = 0;
	Running = 1;
	Swimming = 2;
	Climbing = 3,
	Jumping = 4;
	GettingUp = 5;
	FreeFalling = 6;
	FallingDown = 7;
	Landing = 8;
	Splash = 9;
}

local Humanoid = nil
local Head = nil

--SFX ID to Sound object
local Sounds = {}

do
	local Figure = script.Parent.Parent
	Head = Figure:WaitForChild("Head")
	Humanoid = Figure:WaitForChild("Humanoid")
	
	Sounds[SFX.Died] = 			Head:WaitForChild("Died")
	Sounds[SFX.Running] = 		Head:WaitForChild("Running")
	Sounds[SFX.Swimming] = 		Head:WaitForChild("Swimming")
	Sounds[SFX.Climbing] = 		Head:WaitForChild("Climbing")
	Sounds[SFX.Jumping] = 		Head:WaitForChild("Jumping")
	Sounds[SFX.GettingUp] = 	Head:WaitForChild("GettingUp")
	Sounds[SFX.FreeFalling] = 	Head:WaitForChild("FreeFalling")
	Sounds[SFX.Landing] = 		Head:WaitForChild("Landing")
	Sounds[SFX.Splash] = 		Head:WaitForChild("Splash")
end

local Util
Util = {
	
	--Define linear relationship between (pt1x,pt2x) and (pt2x,pt2y). Evaluate this like at x.
	YForLineGivenXAndTwoPts = function(x,pt1x,pt1y,pt2x,pt2y)
		--(y - y1)/(x - x1) = m
		local m = (pt1y - pt2y) / (pt1x - pt2x)
		--float b = pt1.y - m * pt1.x;
		local b = (pt1y - m * pt1x)
		return m * x + b
	end;
	
	--Clamps the value of "val" between the "min" and "max"
	Clamp = function(val,min,max)
		return math.min(max,math.max(min,val))	
	end;
	
	--Gets the horizontal (x,z) velocity magnitude of the given part
	HorizontalVelocityMagnitude = function(Head)
		local hVel = Head.Velocity + Vector3.new(0,-Head.Velocity.Y,0)
		return hVel.magnitude	
	end;
	
	--Gets the vertical (y) velocity magnitude of the given part
	VerticalVelocityMagnitude = function(Head)
		return math.abs(Head.Velocity.Y)
	end;
	
	--Checks if Sound.Playing is usable
	SoundIsV2 = function(sound)
		return sound.IsLoaded
	end;
	
	--Setting Playing/TimePosition values directly result in less network traffic than Play/Pause/Resume/Stop
	--If these properties are enabled, use them.
	Play = function(sound)		
		if Util.SoundIsV2(sound) then
			if sound.TimePosition ~= 0 then
				sound.TimePosition = 0
			end
			if not sound.IsPlaying then
				sound.Playing = true
			end
		else
			sound:Play()
		end
		
	end;
	Pause = function(sound)
		if Util.SoundIsV2(sound) then
			if sound.IsPlaying then
				sound.Playing = false
			end
		else
			sound:Pause()
		end
	end;
	Resume = function(sound)
		if Util.SoundIsV2(sound) then
			if not sound.IsPlaying then
				sound.Playing = true
			end
		else
			sound:Resume()
		end
	end;
	Stop = function(sound)
		if Util.SoundIsV2(sound) then
			if sound.IsPlaying then
				sound.Playing = false
			end
			if sound.TimePosition ~= 0 then
				sound.TimePosition = 0
			end
		else
			sound:Stop()
		end
	end;
}

do
	-- List of all active Looped sounds
	local activeLoopedSounds = {}
	
	-- Last seen Enum.HumanoidStateType
	local activeState = nil
	
	-- Verify and set that the sound's .Looped property is the value of "looped"
	function verifyAndSetLoopedForSound(sound, looped)
		if sound.Looped ~= looped then
			sound.Looped = looped
		end
	end
	
	-- Verify and set that "sound" is in "activeLoopedSounds".
	function setSoundInActiveLooped(sound)
		for i=1, #activeLoopedSounds do
			if activeLoopedSounds[i] == sound then
				return
			end
		end	
		table.insert(activeLoopedSounds,sound)
	end
	
	-- Stop all active looped sounds except parameter "except". If "except" is not passed, all looped sounds will be stopped.
	function stopActiveLoopedSoundsExcept(except)
		for i=#activeLoopedSounds,1,-1 do
			if activeLoopedSounds[i] ~= except then
				Util.Pause(activeLoopedSounds[i])			
				table.remove(activeLoopedSounds,i)	
			end
		end
	end
	
	-- Table of Enum.HumanoidStateType to handling function
	local stateUpdateHandler = {
		[Enum.HumanoidStateType.Dead] = function()
			stopActiveLoopedSoundsExcept()
			local sound = Sounds[SFX.Died]
			verifyAndSetLoopedForSound(sound,false)
			Util.Play(sound)
		end;
		
		[Enum.HumanoidStateType.RunningNoPhysics] = function()
			stateUpdated(Enum.HumanoidStateType.Running)
		end;
		
		[Enum.HumanoidStateType.Running] = function()	
			local sound 
			local ray = Ray.new(Head.Position,Vector3.new(0,-15,0))
			local part1,pos1,norm1,mat1 = workspace:FindPartOnRay(ray,Head.Parent)
			if mat1 == Enum.Material.Water then
			sound = Sounds[SFX.Swimming]
			if activeState ~= Enum.HumanoidStateType.Swimming then
			activeState = Enum.HumanoidStateType.Swimming
				local splashSound = Sounds[SFX.Splash]
				splashSound.Volume = .1
				Util.Play(splashSound)
			end
			else
			if activeState == Enum.HumanoidStateType.Swimming then
				local splashSound = Sounds[SFX.Splash]
				splashSound.Volume = .1
				Util.Play(splashSound)
			end
			sound = Sounds[SFX.Running]
			activeState = Enum.HumanoidStateType.Running
			end
			verifyAndSetLoopedForSound(sound,true)
			stopActiveLoopedSoundsExcept(sound)
			
			if Util.HorizontalVelocityMagnitude(Head) > 0.5 then
				if not sound.IsPlaying then
					Util.Resume(sound)
				end
				setSoundInActiveLooped(sound)
			else
				stopActiveLoopedSoundsExcept()
			end
		end;
		
		[Enum.HumanoidStateType.Swimming] = function()
			if activeState ~= Enum.HumanoidStateType.Swimming and Util.VerticalVelocityMagnitude(Head) > 0.1 then
				local splashSound = Sounds[SFX.Splash]
				splashSound.Volume = Util.Clamp(
					Util.YForLineGivenXAndTwoPts(
						Util.VerticalVelocityMagnitude(Head), 
						100, 0.28, 
						350, 1),
					0,1)
				Util.Play(splashSound)
			end
			
			do
				local sound = Sounds[SFX.Swimming]
				verifyAndSetLoopedForSound(sound,true)
				stopActiveLoopedSoundsExcept(sound)
				if not sound.IsPlaying then
					Util.Resume(sound)
				end
				setSoundInActiveLooped(sound)
			end
		end;
		
		[Enum.HumanoidStateType.Climbing] = function()
			local sound = Sounds[SFX.Climbing]
			verifyAndSetLoopedForSound(sound,true)
			if Util.VerticalVelocityMagnitude(Head) > 0.1 then
				if not sound.IsPlaying then
					Util.Resume(sound)
				end				
				stopActiveLoopedSoundsExcept(sound)
			else
				stopActiveLoopedSoundsExcept()
			end		
			setSoundInActiveLooped(sound)
		end;
		
		[Enum.HumanoidStateType.Jumping] = function()
			if activeState == Enum.HumanoidStateType.Jumping then
				return
			end		

	local ray = Ray.new(Head.Position,Vector3.new(0,-15,0))
			local part1,pos1,norm1,mat1 = workspace:FindPartOnRay(ray,Head.Parent)
		local splashSound = Sounds[SFX.Splash]
			if mat1 and mat1 == Enum.Material.Water then
				splashSound.Volume = .1
				Util.Play(splashSound)
end
			stopActiveLoopedSoundsExcept()
			local sound = Sounds[SFX.Jumping]
			verifyAndSetLoopedForSound(sound,false)
			Util.Play(sound)
		end;
		
		[Enum.HumanoidStateType.GettingUp] = function()
			stopActiveLoopedSoundsExcept()
			local sound = Sounds[SFX.GettingUp]
			verifyAndSetLoopedForSound(sound,false)
			Util.Play(sound)
		end;
		
		[Enum.HumanoidStateType.Freefall] = function()
			if activeState == Enum.HumanoidStateType.Freefall then
				return
			end
			local sound = Sounds[SFX.FreeFalling]
			if sound.Volume ~= 0 then
				sound.Volume = 0
			end
			stopActiveLoopedSoundsExcept()
		end;
		
		[Enum.HumanoidStateType.FallingDown] = function()
			stopActiveLoopedSoundsExcept()
		end;
		
		[Enum.HumanoidStateType.Landed] = function()
			stopActiveLoopedSoundsExcept()
			if Util.VerticalVelocityMagnitude(Head) > 75 then
				local landingSound = Sounds[SFX.Landing]
				landingSound.Volume = Util.Clamp(
					Util.YForLineGivenXAndTwoPts(
						Util.VerticalVelocityMagnitude(Head), 
						50, 0, 
						100, 1),
					0,1)
				Util.Play(landingSound)			
			end
		end
	}
	
	-- Handle state event fired or OnChange fired
	function stateUpdated(state)
		if stateUpdateHandler[state] ~= nil then
			stateUpdateHandler[state]()
		end

		local ray = Ray.new(Head.Position,Vector3.new(0,-15,0))
			local part1,pos1,norm1,mat1 = workspace:FindPartOnRay(ray,Head.Parent)
			if mat1 and mat1 == Enum.Material.Water then
				return
			else
					activeState = state
			end
	end
	
	-- Runs on heartbeat
	function onHeartbeat(step)
		local stepScale = step / (1/60.0)
		
		do
			local sound = Sounds[SFX.FreeFalling]
			if activeState == Enum.HumanoidStateType.Freefall then
				if Head.Velocity.Y < 0 and Util.VerticalVelocityMagnitude(Head) > 75 then
					if not sound.IsPlaying then
						Util.Resume(sound)
					end
					if sound.Volume < 1 then
						sound.Volume = Util.Clamp(sound.Volume + 0.01 * stepScale,0,1)
					end
				else
					if sound.Volume ~= 0 then
						sound.Volume = 0
					end
				end			
			else
				if sound.IsPlaying then
					Util.Pause(sound)
				end
			end
		end
		
		do
			local sound = Sounds[SFX.Running]
			if activeState == Enum.HumanoidStateType.Running then
				if sound.IsPlaying and Util.HorizontalVelocityMagnitude(Head) < 0.5 then
					Util.Pause(sound)
				end
			end
		end		
		
	end
	
	Humanoid.Died:connect(			function() stateUpdated(Enum.HumanoidStateType.Dead) 			end)
	Humanoid.Running:connect(		function() stateUpdated(Enum.HumanoidStateType.Running) 		end)
	Humanoid.Swimming:connect(		function() stateUpdated(Enum.HumanoidStateType.Swimming) 		end)
	Humanoid.Climbing:connect(		function() stateUpdated(Enum.HumanoidStateType.Climbing) 		end)
	Humanoid.Jumping:connect(		function() stateUpdated(Enum.HumanoidStateType.Jumping) 		end)
	Humanoid.GettingUp:connect(	function() stateUpdated(Enum.HumanoidStateType.GettingUp) 	end)
	Humanoid.FreeFalling:connect(	function() stateUpdated(Enum.HumanoidStateType.Freefall) 		end)
	Humanoid.FallingDown:connect(	function() stateUpdated(Enum.HumanoidStateType.FallingDown) 	end)
	
	-- required for proper handling of Landed event
	Humanoid.StateChanged:connect(function(old, new)
		stateUpdated(new)
	end)
	game:GetService('RunService').Heartbeat:connect(onHeartbeat)
end
]]></ProtectedString>
						<bool name="Disabled">false</bool>
						<Content name="LinkedSource"><null></null></Content>
						<token name="RunContext">0</token>
						<string name="ScriptGuid">{CFCF6FE7-D358-4879-96F9-E407EF6A160E}
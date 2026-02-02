---██████╗ ██████╗  ██████╗ ███╗   ███╗██████╗ ████████╗███████╗██████╗          
---██╔══██╗██╔══██╗██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██╔════╝██╔══██╗         
---██████╔╝██████╔╝██║   ██║██╔████╔██║██████╔╝   ██║   █████╗  ██║  ██║         
---██╔═══╝ ██╔══██╗██║   ██║██║╚██╔╝██║██╔═══╝    ██║   ██╔══╝  ██║  ██║         
---██║     ██║  ██║╚██████╔╝██║ ╚═╝ ██║██║        ██║   ███████╗██████╔╝         
---╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝        ╚═╝   ╚══════╝╚═════╝          
---
---██╗    ██╗██╗████████╗██╗  ██╗     ██████╗ ███████╗███╗   ███╗██╗███╗   ██╗██╗
---██║    ██║██║╚══██╔══╝██║  ██║    ██╔════╝ ██╔════╝████╗ ████║██║████╗  ██║██║
---██║ █╗ ██║██║   ██║   ███████║    ██║  ███╗█████╗  ██╔████╔██║██║██╔██╗ ██║██║
---██║███╗██║██║   ██║   ██╔══██║    ██║   ██║██╔══╝  ██║╚██╔╝██║██║██║╚██╗██║██║
---╚███╔███╔╝██║   ██║   ██║  ██║    ╚██████╔╝███████╗██║ ╚═╝ ██║██║██║ ╚████║██║
---╚══╝╚══╝ ╚═╝   ╚═╝   ╚═╝  ╚═╝     ╚═════╝ ╚══════╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝
---
---███████╗██████╗  ██████╗ ███╗   ███╗                                          
---██╔════╝██╔══██╗██╔═══██╗████╗ ████║                                          
---█████╗  ██████╔╝██║   ██║██╔████╔██║                                          
---██╔══╝  ██╔══██╗██║   ██║██║╚██╔╝██║                                          
---██║     ██║  ██║╚██████╔╝██║ ╚═╝ ██║                                          
---╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝                                          
---
---███████╗███╗   ███╗███████╗ █████╗ ██████╗  ██████╗ ██╗     ███████╗          
---██╔════╝████╗ ████║██╔════╝██╔══██╗██╔══██╗██╔════╝ ██║     ██╔════╝          
---███████╗██╔████╔██║█████╗  ███████║██████╔╝██║  ███╗██║     █████╗            
---╚════██║██║╚██╔╝██║██╔══╝  ██╔══██║██╔══██╗██║   ██║██║     ██╔══╝            
---███████║██║ ╚═╝ ██║███████╗██║  ██║██║  ██║╚██████╔╝███████╗███████╗          
---╚══════╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝          

------------------------------------------------------------------------------------------------------
--                                    Scriptable Camera Controller                                  --
--                                 Prompted and Paid for By: SMEARGLE                               --
------------------------------------------------------------------------------------------------------

-- Script Location: StarterPlayer > StarterCharacterScripts > LocalScript
--      This script should be placed inside a LocalScript within StarterCharacterScripts.
--      This ensures the script runs on the client (the player's computer) and controls
--      the camera for that specific player.  Each player will have their own instance
--      of this script running.

--[[
    OVERVIEW:
    This LocalScript provides a custom camera controller for a Roblox game.  It replaces the
    default Roblox camera behavior with a more flexible, script-controlled system.  Key features:

    * Customizable Camera Modes:  Includes a "normal" (hip-fire) mode and an "aiming down sights" (ADS) mode.
    * Smooth Transitions:  Uses linear interpolation (Lerp) to smoothly transition between camera positions,
        field of view (FOV), and player rotation.
    * Camera Collision Detection:  Prevents the camera from going through walls and other objects.
    * Shoulder Swapping:  Allows the player to switch the camera's position from the right shoulder
        to the left shoulder (and back).
    * Mouse Sensitivity Adjustment:  Separate mouse sensitivity settings for normal and ADS modes.
    * Modular Design:  The code is organized into functions to improve readability and maintainability.
    * Frame-Rate Independent Smoothing: Uses deltaTime to ensure smooth camera movement regardless of
        the player's frame rate.

    HOW IT WORKS:
    1.  Initialization:
        * Gets references to important Roblox services (UserInputService, RunService, Players).
        * Gets references to the player's character and camera.
        * Sets up initial camera settings (scriptable control, locks the mouse).
        * Defines configuration variables (camera offsets, sensitivities, FOVs).
        * Initializes state variables (camera angles, aiming status, shoulder side).
        * Creates a RaycastParams object for camera collision detection.
        * Disables the humanoid's default autorotate.

    2.  Input Handling:
        * `handleAimInput()`:  Detects when the player presses and releases the right mouse button
            to toggle aiming mode.
        * `handleShoulderSwapInput()`: Detects when the player presses the 'Q' key to switch the
            camera's shoulder side.

    3.  Camera Update (updateCamera()):
        * This function is called every frame by `RunService.RenderStepped`.
        * Calculates the target camera position and orientation based on the current state
            (aiming or not, shoulder side).
        * Uses Lerp to smoothly transition the camera's position, FOV, and player rotation
            towards the target values.
        * Performs a raycast to detect potential camera collisions.  If a collision is detected,
            the camera's position is adjusted to prevent it from going through the obstacle.
        * Sets the camera's CFrame (position and orientation) and FOV.
        * Rotates the player's character to face the direction the camera is pointing.

    4.  Cleanup:
        * When the character is destroyed (e.g., when the player respawns), the script disconnects
            the `RenderStepped` connection and resets the mouse behavior to the default.

    IMPORTANT NOTES:
    * This script is a LocalScript, meaning it runs on the client (the player's computer).
        This is necessary for controlling the camera, as camera control is a client-side
        operation.
    * The script assumes that it is placed inside a LocalScript within
        `StarterCharacterScripts`.  This is the standard location for scripts that control
        player behavior.
    * The `RunService.RenderStepped` event fires every frame, allowing for smooth and responsive
        camera updates.
    * The `Lerp` function is used extensively to create smooth transitions between camera
        states.  Lerp stands for "linear interpolation" and is a common technique in
        game development for smoothing animations and movements.
    * Raycasting is used to prevent the camera from going through walls.  A raycast is a
        virtual line that is cast from a starting point in a given direction.  The raycast
        returns information about the first object that it hits.
    * The `shoulderSide` variable is used to keep track of which shoulder the camera is
        currently positioned over (1 for right, -1 for left).
    * The `effectiveOffset` variable is crucial for the shoulder swapping.  It holds the
        *actual* offset that is applied to the camera, and it's smoothly adjusted when the
        shoulder is swapped.
    * The script prints a message to the console when it is initialized.  This can be
        useful for debugging.
    * The configuration variables at the top of the script (e.g., `NORMAL_MOUSE_SENSITIVITY`,
        `NORMAL_CAMERA_OFFSET`, `AIM_FOV`) can be adjusted to customize the camera behavior.
        Experiment with different values to find what feels best for your game.
--]]

--[[
    ROBLOX SERVICES:
    Roblox provides several built-in services that provide access to various parts of the
    game engine.  This script uses the following services:

    * game:GetService("UserInputService"):  Provides access to user input, such as mouse
        and keyboard input.
    * game:GetService("RunService"):  Provides access to the game's update loop and
        other runtime information.
    * game:GetService("Players"): Provides access to all the players in the game.
--]]
-- Services
local UserInputService = game:GetService("UserInputService") -- Gets the UserInputService
local RunService = game:GetService("RunService")             -- Gets the RunService
local Players = game:GetService("Players")                   -- Gets the Players service

--[[
    PLAYER AND CHARACTER VARIABLES:
    These variables store references to the player and their character.  These references
    are used to access the player's input and control the camera's position relative to
    the character.
--]]
-- Player and Character variables
local player = Players.LocalPlayer                        -- Gets the LocalPlayer (the player running this script)
local character = script.Parent                          -- Gets the character model.  `script.Parent` refers to the object
-- that the script is parented to.  In this case, it's assumed
-- that the script is parented to the character model.
local humanoid = character:WaitForChild("Humanoid")       -- Gets the Humanoid object from the character.  The Humanoid
-- is responsible for the character's movement and animation.
-- WaitForChild() waits until the Humanoid is loaded.
local rootPart = character:WaitForChild("HumanoidRootPart") -- Gets the HumanoidRootPart. This is the primary part
-- of the character, used for positioning.

--[[
    CAMERA VARIABLES:
    This variable stores a reference to the game's camera.  The camera is what the player
    sees the game world through.
--]]
-- Camera variables
local camera = workspace.CurrentCamera                 -- Gets the CurrentCamera.  This is the camera that is currently
-- being used to render the game world.  In a single-player
-- game, this is usually the player's camera.

--[[
    CONFIGURATION VARIABLES:
    These variables define the behavior of the camera.  They can be adjusted to customize
    the camera's position, sensitivity, and field of view.  These are the primary values
    you'll want to tweak to get the camera feeling just right.  Documented extensively
    so you know what each value does.
--]]
-- Configuration Variables (TUNE THESE FOR FEEL!)
---------------------------------------------------------------------
-- Normal (Hip-Fire) State
local NORMAL_MOUSE_SENSITIVITY = 0.3          -- The mouse sensitivity when the player is not aiming down sights.
-- Higher values make the camera rotate faster.
local NORMAL_CAMERA_OFFSET = Vector3.new(2.5, 2.0, 8.0) -- The camera's position relative to the character's HumanoidRootPart
-- when the player is not aiming.  X is side-to-side (positive is right),
-- Y is up-and-down, and Z is distance behind the character.
-- Default X is for the right shoulder.
local NORMAL_FOV = 70                       -- The field of view (in degrees) when the player is not aiming.
-- Higher values make the view wider.
local NORMAL_ROTATION_SMOOTHNESS = 0.15      -- Controls how smoothly the camera rotates when the player is not aiming.
-- Lower values make the rotation smoother (more damping/lag).

-- Aiming Down Sights (ADS) State
local AIM_MOUSE_SENSITIVITY = 0.2             -- Mouse sensitivity when aiming down sights.  Usually lower than normal
-- for more precise aiming.
local AIM_CAMERA_OFFSET = Vector3.new(1.5, 1.8, 6.0)  -- Camera offset when aiming down sights.  Typically closer to the
-- character and more centered. X is side-to-side, Y is up-and-down, Z is distance.
-- Default X is for the right shoulder.
local AIM_FOV = 50                          -- Field of view when aiming down sights.  Lower FOV zooms in.
local AIM_ROTATION_SMOOTHNESS = 0.8         -- Rotation smoothness when aiming.  Higher values make it smoother (more lag).
--  A higher value here means *less* smoothing, counterintuitively, because
--  it's used in a Lerp as the *amount* of rotation applied.

-- General Settings
local MIN_PITCH = -80                       -- The minimum vertical angle (in degrees) of the camera.  Prevents
-- the player from looking too far up.
local MAX_PITCH = 80                        -- The maximum vertical angle of the camera.  Prevents looking too far down.
local CAMERA_COLLISION_BUFFER = 0.2         -- A small distance (in studs) that the camera will maintain from walls
-- and other objects.  This prevents the camera from clipping through surfaces.
local SMOOTH_TRANSITION_SPEED = 10           -- Controls the speed of transitions between camera states (e.g., normal to ADS).
-- Higher values make transitions faster.  This isn't directly a Lerp *amount*,
-- but rather a factor used in the `getLerpAlpha` function to calculate it.
---------------------------------------------------------------------

--[[
    STATE VARIABLES:
    These variables store the current state of the camera and player.  They are used to
    control the camera's behavior and update it correctly each frame.
--]]
-- State variables
local currentYaw = 0                            -- The current horizontal angle (in degrees) of the camera.  Also known as "yaw".
local currentPitch = 0                          -- The current vertical angle (in degrees) of the camera.  Also known as "pitch".
local isAiming = false                          -- A boolean that indicates whether the player is currently aiming down sights.
local shoulderSide = 1                          --  1 = Default (Right Shoulder), -1 = Swapped (Left Shoulder).  This controls
--  which side of the character the camera is positioned on.
local isCameraActive = true                    -- A boolean that indicates if this script should be controlling the camera.
--  If false, the script will not update the camera.

-- Variables for smoothing
-- Initialize effectiveOffset considering the starting shoulderSide
local effectiveOffset = Vector3.new(NORMAL_CAMERA_OFFSET.X * shoulderSide, NORMAL_CAMERA_OFFSET.Y, NORMAL_CAMERA_OFFSET.Z)
local effectiveFov = NORMAL_FOV

--[[
    INITIALIZATION:
    This code is executed when the script is first loaded.  It sets up the initial
    state of the camera and player.
--]]
-- Initialization
humanoid.AutoRotate = false                      -- Disables the humanoid's default auto-rotation behavior.  This prevents
-- the character from automatically turning to face the direction of movement,
-- which would interfere with the custom camera control.
camera.CameraType = Enum.CameraType.Scriptable    -- Sets the camera's control mode to "Scriptable".  This means that the
-- camera's position and orientation will be controlled by a script,
-- rather than by the player's default camera controls.
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter  -- Locks the mouse cursor to the center of the screen.  This is
-- a common technique used in third-person camera systems to provide
-- smooth and consistent camera control.
UserInputService.MouseIconEnabled = false        -- Hides the default mouse cursor.  This is often done when the mouse
-- is locked to the center of the screen, as the cursor is no longer needed.

-- Create RaycastParams for camera collision
local raycastParams = RaycastParams.new()       -- Creates a new RaycastParams object.  This object is used to configure
-- how raycasts are performed.  Raycasts are used to detect collisions
-- between the camera and other objects in the game world.
raycastParams.FilterType = Enum.RaycastFilterType.Exclude  -- Sets the filter type to "Exclude".  This means that the raycast
-- will ignore any objects that are included in the filter list.
raycastParams.FilterDescendantsInstances = {character}    -- Sets the filter list to include the player's character.  This
-- prevents the camera from colliding with the character itself.
raycastParams.IgnoreWater = true                -- Makes the raycast ignore water.

--[[
    HELPER FUNCTIONS:
    These functions provide reusable logic for the camera control system.
--]]

-- Helper function for linear interpolation (Lerp) for numbers
local function lerp(a, b, t)
	return a + (b - a) * t
end

-- Frame-rate independent Lerp alpha calculation
local function getLerpAlpha(speed, deltaTime)
	deltaTime = math.min(deltaTime, 0.1) -- Prevent large jumps in interpolation if deltaTime is very big
	return 1 - math.exp(-speed * deltaTime) -- Exponential approach to target value
end

--[[
    CAMERA UPDATE FUNCTION:
    This function is called every frame to update the camera's position and orientation.
    It is the core of the camera control system.
--]]
-- Main update function connected to RenderStepped
local function updateCamera(deltaTime)
	if not isCameraActive or not rootPart then return end  -- If the camera is not active or the root part doesn't exist, exit.

	-- === Determine TARGET State Parameters ===
	-- Decide what the base offset/fov/etc SHOULD be based on current state (BEFORE shoulder side)
	local targetBaseOffset, targetFov
	local sensitivity, rotSmoothness -- Use target values directly for responsiveness
	if isAiming then
		targetBaseOffset = AIM_CAMERA_OFFSET
		targetFov = AIM_FOV
		sensitivity = AIM_MOUSE_SENSITIVITY
		rotSmoothness = AIM_ROTATION_SMOOTHNESS
	else
		targetBaseOffset = NORMAL_CAMERA_OFFSET
		targetFov = NORMAL_FOV
		sensitivity = NORMAL_MOUSE_SENSITIVITY
		rotSmoothness = NORMAL_ROTATION_SMOOTHNESS
	end

	-- === Calculate FULL Target Offset (including shoulder side) === -- NEW STEP
	-- This is the actual position offset the camera should smoothly move towards
	local fullTargetOffset = Vector3.new(targetBaseOffset.X * shoulderSide, targetBaseOffset.Y, targetBaseOffset.Z)

	-- === Smoothly update EFFECTIVE values towards TARGET values ===
	local alpha = getLerpAlpha(SMOOTH_TRANSITION_SPEED, deltaTime)

	-- Interpolate the full offset (which now includes shoulder side) towards the target
	effectiveOffset = effectiveOffset:Lerp(fullTargetOffset, alpha)
	-- Interpolate the Field of View
	effectiveFov = lerp(effectiveFov, targetFov, alpha)

	-- === Camera Rotation ===
	local mouseDelta = UserInputService:GetMouseDelta() -- Gets the change in mouse position since the last frame.
	currentYaw = currentYaw - mouseDelta.X * sensitivity    -- Updates the horizontal camera angle (yaw) based on mouse movement
	currentPitch = math.clamp(currentPitch - mouseDelta.Y * sensitivity, MIN_PITCH, MAX_PITCH) -- Updates the vertical camera
	-- angle (pitch) and clamps it to the defined limits.

	local yawRad = math.rad(currentYaw)     -- Converts the yaw angle from degrees to radians.  Roblox uses radians
	-- for trigonometric functions.
	local pitchRad = math.rad(currentPitch)  -- Converts the pitch angle from degrees to radians.

	-- === Camera Positioning and CFrame Calculation ===
	local cameraRotation = CFrame.Angles(0, yawRad, 0) * CFrame.Angles(pitchRad, 0, 0)  -- Creates a CFrame (Coordinate Frame)
	-- that represents the camera's rotation.  CFrames are used to store
	-- position and orientation information.  This combines the yaw and
	-- pitch rotations.
	local anchorPosition = rootPart.Position  -- Gets the position of the character's HumanoidRootPart.  This is the
	-- point around which the camera will rotate.

	-- Calculate the IDEAL CFrame and Position WITHOUT collision first
	-- Use the FULLY SMOOTHED effective offset (already includes shoulder side effects)
	local idealShoulderOffsetCFrame = CFrame.new(effectiveOffset.X, effectiveOffset.Y, effectiveOffset.Z)
	local idealCameraCFrame = CFrame.new(anchorPosition) * cameraRotation * idealShoulderOffsetCFrame
	local idealPosition = idealCameraCFrame.Position

	-- === Collision Detection ===
	local finalOffsetVector = effectiveOffset -- Start collision scaling from the current SMOOTHED offset
	local rayOrigin = anchorPosition
	local rayDirection = idealPosition - rayOrigin
	local idealDistance = rayDirection.Magnitude

	if idealDistance > 0.01 then -- added a check to prevent a bug where the camera would go inside the player.
		local raycastResult = workspace:Raycast(rayOrigin, rayDirection.Unit * idealDistance, raycastParams) -- Performs the raycast.
		if raycastResult then  -- If the raycast hit something...
			local hitDistance = raycastResult.Distance  -- Gets the distance from the origin to the hit point.
			if hitDistance < idealDistance then
				-- Scale the current effectiveOffset based on collision distance
				local scaleFactor = math.clamp((hitDistance - CAMERA_COLLISION_BUFFER) / idealDistance, 0, 1)
				finalOffsetVector = effectiveOffset * scaleFactor
			end
		end
	end

	-- === Calculate Final CFrame using potentially adjusted offset ===
	-- The finalOffsetVector now already includes smoothing and shoulder side effects
	local finalAppliedOffsetCFrame = CFrame.new(finalOffsetVector.X, finalOffsetVector.Y, finalOffsetVector.Z)
	local finalCameraCFrame = CFrame.new(anchorPosition) * cameraRotation * finalAppliedOffsetCFrame

	-- === Set Camera CFrame and FOV ===
	camera.CFrame = finalCameraCFrame       -- Sets the camera's position and orientation.
	camera.Focus = CFrame.new(anchorPosition)  -- Sets the point that the camera is focused on.  In this case, it's the
	-- character's root part.  This can help with some camera behaviors.
	camera.FieldOfView = effectiveFov      -- Sets the camera's field of view.

	-- === Character Rotation ===
	local targetRootCFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, yawRad, 0)  -- Creates a CFrame that represents
	-- the target orientation for the character's root part.  This rotates
	-- the character horizontally to face the direction the camera is pointing.
	rootPart.CFrame = rootPart.CFrame:Lerp(targetRootCFrame, rotSmoothness)  -- Smoothly rotates the character's root part
	-- towards the target orientation.  The `rotSmoothness` value controls
	-- how quickly the rotation occurs.
end

--[[
    INPUT HANDLER FUNCTIONS:
    These functions handle player input, such as mouse and keyboard input.  They determine
    how the camera should respond to the player's actions.
--]]

-- Handle Aim Input
local function handleAimInput(input, gameProcessed)
	if gameProcessed or not isCameraActive then return end  -- If the input was already handled by the game or the camera is inactive, exit.
	if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- If the input is from the right mouse button...
		if input.UserInputState == Enum.UserInputState.Begin then  -- ...and the button was just pressed down...
			isAiming = true                                     -- ...set the aiming flag to true.
		elseif input.UserInputState == Enum.UserInputState.End then  -- ...or the button was just released...
			isAiming = false                                    -- ...set the aiming flag to false.
		end
	end
end

-- Handle Shoulder Swap Input
local function handleShoulderSwapInput(input, gameProcessed)
	if gameProcessed or not isCameraActive then return end
	if input.KeyCode == Enum.KeyCode.Q and input.UserInputState == Enum.UserInputState.Begin then
		shoulderSide = shoulderSide * -1
	end
end

--[[
    CONNECT INPUT HANDLERS:
    These lines of code connect the input handler functions to the appropriate input events.
    This ensures that the functions are called when the corresponding input occurs.
--]]
-- Connect Input Handlers
UserInputService.InputBegan:Connect(handleAimInput)    -- Connects the handleAimInput function to the InputBegan event,
-- which is fired when an input begins (e.g., a key is pressed down).
UserInputService.InputEnded:Connect(handleAimInput)     -- Connects handleAimInput to the InputEnded event, which fires
-- when an input ends (e.g., a key is released).
UserInputService.InputBegan:Connect(handleShoulderSwapInput)

--[[
    CONNECT CAMERA UPDATE FUNCTION:
    This line of code connects the updateCamera function to the RunService.RenderStepped
    event.  This ensures that the updateCamera function is called every frame, allowing
    for smooth and continuous camera updates.
--]]
-- Connect the update function to RunService.RenderStepped
local renderConnection = RunService.RenderStepped:Connect(updateCamera)  -- Connects updateCamera to RenderStepped.
--  Returns a connection object which is stored
--  in renderConnection.

--[[
    CLEANUP FUNCTION:
    This code is executed when the character is destroyed (e.g., when the player respawns).
    It disconnects the RenderStepped connection to prevent the camera from continuing to
    update after the character is gone, and it resets the mouse behavior to the default.
--]]
-- Clean up when character is removed
character.Destroying:Connect(function()  -- Connects a function to the character's Destroying event.
	if renderConnection then           -- If the renderConnection exists...
		renderConnection:Disconnect()    -- ...disconnect it.  This stops the updateCamera function from being called.
	end
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default  -- Resets the mouse behavior to the default.
	UserInputService.MouseIconEnabled = true                    -- Re-enables the mouse icon.
end)

print("ScriptableCameraController Initialized (v_SmoothShoulderFix)") -- Prints a message to the console to indicate that the script has been initialized.
-- Version 2.0 (v2.0): Added smooth shoulder offset option]]></ProtectedString>
						<bool name="Disabled">true</bool>
						<Content name="LinkedSource"><null></null></Content>
						<token name="RunContext">0</token>
						<string name="ScriptGuid">{24EBEA65-36D3-4E60-AB4D-4BE325004D54}
--[[
	find(model) {"HumanoidRootPart", "RootAttachment"} {"Torso", "BodyFrontAttachment"}
	--> {HumanoidRootPart.RootAttachment, Torso.BodyFrontAttachment} or nil
--]]
local function find(model)
	return function(first)
		return function(second)
			local part0 = model:FindFirstChild(first[1])
			local part1 = model:FindFirstChild(second[1])
			if part0 and part1 then
				local attach0 = part0:FindFirstChild(first[2])
				local attach1 = part1:FindFirstChild(second[2])
				if attach0 and attach1 and attach0:IsA("Attachment") and attach1:IsA("Attachment") then
					return {attach0, attach1}
				end
			end
		end
	end
end

-- Get list of attachments to make ballsocketconstraints between:
function RigTypes:GetAttachments(model, humanoid)
	local query = find(model)
	
	if humanoid.RigType == Enum.HumanoidRigType.R6 then

		local rightLegAttachment = Instance.new("Attachment")
		rightLegAttachment.Name = "RagdollRightLegAttachment"
		rightLegAttachment.Position = Vector3.new(0, 1, 0)
		rightLegAttachment.Parent = model:FindFirstChild("Right Leg")
		
		local leftLegAttachment = Instance.new("Attachment")
		leftLegAttachment.Name = "RagdollLeftLegAttachment"
		leftLegAttachment.Position = Vector3.new(0, 1, 0)
		leftLegAttachment.Parent = model:FindFirstChild("Left Leg")
		
		local torsoLeftAttachment = Instance.new("Attachment")
		torsoLeftAttachment.Name = "RagdollTorsoLeftAttachment"
		torsoLeftAttachment.Position = Vector3.new(-0.5, -1, 0)
		torsoLeftAttachment.Parent = model:FindFirstChild("Torso")
		
		local torsoRightAttachment = Instance.new("Attachment")
		torsoRightAttachment.Name = "RagdollTorsoRightAttachment"
		torsoRightAttachment.Position = Vector3.new(0.5, -1, 0)
		torsoRightAttachment.Parent = model:FindFirstChild("Torso")
		
		return {
			HumanoidRootPart = query
				{"HumanoidRootPart", "RootAttachment"}
				{"Torso", "BodyFrontAttachment"},
			Head = query
				{"Torso", "NeckAttachment"}
				{"Head", "FaceCenterAttachment"},
			["Left Arm"] = query
				{"Torso", "LeftCollarAttachment"}
				{"Left Arm", "LeftShoulderAttachment"},
			["Right Arm"] = query
				{"Torso", "RightCollarAttachment"}
				{"Right Arm", "RightShoulderAttachment"},
			["Left Leg"] = {
				torsoLeftAttachment,
				leftLegAttachment
			},
			["Right Leg"] = {
				torsoRightAttachment,
				rightLegAttachment
			},
		}
		
	elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
		
		return {
			Head = query
				{"UpperTorso", "NeckRigAttachment"}
				{"Head", "NeckRigAttachment"},
			
			LowerTorso = query
				{"UpperTorso", "WaistRigAttachment"}
				{"LowerTorso", "RootRigAttachment"},
			
			LeftUpperArm = query
				{"UpperTorso", "LeftShoulderRigAttachment"}
				{"LeftUpperArm", "LeftShoulderRigAttachment"},
			LeftLowerArm = query
				{"LeftUpperArm", "LeftElbowRigAttachment"}
				{"LeftLowerArm", "LeftElbowRigAttachment"},
			LeftHand = query
				{"LeftLowerArm", "LeftWristRigAttachment"}
				{"LeftHand", "LeftWristRigAttachment"},
			
			RightUpperArm = query
				{"UpperTorso", "RightShoulderRigAttachment"}
				{"RightUpperArm", "RightShoulderRigAttachment"},
			RightLowerArm = query
				{"RightUpperArm", "RightElbowRigAttachment"}
				{"RightLowerArm", "RightElbowRigAttachment"},
			RightHand = query
				{"RightLowerArm", "RightWristRigAttachment"}
				{"RightHand", "RightWristRigAttachment"},
			
			LeftUpperLeg = query
				{"LowerTorso", "LeftHipRigAttachment"}
				{"LeftUpperLeg", "LeftHipRigAttachment"},
			LeftLowerLeg = query
				{"LeftUpperLeg", "LeftKneeRigAttachment"}
				{"LeftLowerLeg", "LeftKneeRigAttachment"},
			LeftFoot = query
				{"LeftLowerLeg", "LeftAnkleRigAttachment"}
				{"LeftFoot", "LeftAnkleRigAttachment"},
			
			RightUpperLeg = query
				{"LowerTorso", "RightHipRigAttachment"}
				{"RightUpperLeg", "RightHipRigAttachment"},
			RightLowerLeg = query
				{"RightUpperLeg", "RightKneeRigAttachment"}
				{"RightLowerLeg", "RightKneeRigAttachment"},
			RightFoot = query
				{"RightLowerLeg", "RightAnkleRigAttachment"}
				{"RightFoot", "RightAnkleRigAttachment"},
		}

	end
	
	return {} -- unknown rig type
end

return RigTypes
]]></ProtectedString>
						<string name="ScriptGuid">{A29F3891-5A3F-482B-8BF1-10C30962D7CC}
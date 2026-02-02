print("--- [STARTING REMODEL] ---")

local success, result = pcall(function()
    print("Loading file: assets/Everrune.rbxlx...")
    local game = remodel.readPlaceFile("assets/Everrune.rbxlx")
    
    print("File loaded successfully!")
    local services = game:GetChildren()
    print("Found " .. #services .. " services.")

    for _, service in ipairs(services) do
        print("Checking service: " .. service.Name)
        -- Only look in services likely to have code to save memory
        if service.Name == "ServerScriptService" or service.Name == "ReplicatedStorage" or service.Name == "StarterPlayer" then
            for _, child in ipairs(service:GetDescendants()) do
                if child.ClassName == "Script" or child.ClassName == "LocalScript" or child.ClassName == "ModuleScript" then
                    remodel.writeFile("src/" .. child.Name .. ".lua", child.Source)
                    print("  Extracted: " .. child.Name)
                end
            end
        end
    end
end)

if not success then
    print("--- [CRASH ERROR] ---")
    print(result)
else
    print("--- [FINISHED SUCCESSFULLY] ---")
end
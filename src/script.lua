-- Services
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local helpers = loadstring(game:HttpGet(
'https://github.com/Zzza38/Dead-Rails-Script/raw/refs/heads/main/src/helperFunctions.lua'))()
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer

-- 🧠 States FIRST before UI
local nightVisionOn = false
local espOn = false
local addedESPModels = {}
local frameCounter = 0
local espEveryNFrames = 3
local onlyWhenAlive = true
local highlightEnabled = true
local defaultNPCModes = {
    ["Model_Unicorn"] = "highlight",
    ["Model_Werewolf"] = "warn",
    ["Model_Runner"] = "ignore",
    ["Model_Walker"] = "ignore",
    ["Model_Horse"] = "ignore",
    ["Model_RifleSolider"] = "none",
    ["Model_TurretSolider"] = "none",
    ["Shopkeeper"] = "none"
}
local playerChosenModes = table.clone(defaultNPCModes)
local importantNPCs = table.clone(playerChosenModes)
local NPCNames = {
    ["Model_Unicorn"] = "Unicorn",
    ["Model_Werewolf"] = "Werewolf",
    ["Model_Runner"] = "Zombie (Fast)",
    ["Model_Walker"] = "Zombie (Slow)",
    ["Model_Horse"] = "Horse",
    ["Model_RifleSolider"] = "Ground Solider",
    ["Model_TurretSolider"] = "Turret Solider",
}
local readableHighlightModes = {}
for internalName, mode in pairs(defaultNPCModes) do
    local readableName = NPCNames[internalName] or internalName
    readableHighlightModes[readableName] = mode
end
local readableToInternal = {}
for internalName, mode in pairs(playerChosenModes) do
    local readableName = NPCNames[internalName] or internalName
    readableToInternal[readableName] = internalName
end


-- Create the main window
local Window = Rayfield:CreateWindow({
    Name = "Dead Rails Script",
    Icon = 0,
    LoadingTitle = "Dead Rails Script",
    LoadingSubtitle = "by Zzza38",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "dead-rails"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Untitled",
        Subtitle = "Key System",
        Note = "No method of obtaining the key is provided",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = { "Hello" }
    }
})


-- Lighting control
local function enableLighting()
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.Brightness = 5
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.ClockTime = 12
end

local function resetLighting()
    Lighting.Ambient = Color3.new(0, 0, 0)
    Lighting.Brightness = 2
    Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
end

-- ESP functions
local function addESP(model)
    if model:FindFirstChild("Humanoid") and not model:FindFirstChild("ESP_Added") then
        if Players:GetPlayerFromCharacter(model) then return end
        local mode = importantNPCs[model.Name]
        local name = NPCNames[model.Name] or model.Name
        local color = Color3.new(1, 0, 0) -- default red

        if mode == "none" then return end
        if mode == "highlight" then
            color = Color3.fromRGB(0, 255, 0)   -- green
        elseif mode == "warn" then
            color = Color3.fromRGB(255, 255, 0) -- yellow
        end

        for _, part in pairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                local box = Instance.new("BoxHandleAdornment")
                box.Size = part.Size
                box.Adornee = part
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Transparency = 0.5
                box.Color3 = color
                box.Name = "ESPBox"
                box.Parent = part
            end
        end

        local head = model:FindFirstChild("Head")
        if head and mode ~= "ignore" then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "NameESP"
            billboard.Size = UDim2.new(0, 150, 0, 40)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true
            billboard.Adornee = head
            billboard.Parent = head

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            nameLabel.TextStrokeTransparency = 0.5
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.SourceSansBold

            nameLabel.Text = name
            if (mode == "warn") then
                local frameCounter = 0
                RunService.RenderStepped:Connect(function()
                    if not model:IsDescendantOf(workspace) or not head:IsDescendantOf(workspace) then
                        return
                    end

                    frameCounter += 1
                    if frameCounter % espEveryNFrames == 0 then
                        local distance = 0
                        if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("HumanoidRootPart") then
                            distance = math.floor((localPlayer.Character.HumanoidRootPart.Position - model.HumanoidRootPart.Position)
                                .Magnitude)
                        end

                        nameLabel.Text = (mode == "warn" and "⚠️ " or "") .. name .. " - " .. distance .. " studs"
                    end
                end)
            end

            nameLabel.Parent = billboard
        end

        local tag = Instance.new("BoolValue")
        tag.Name = "ESP_Added"
        tag.Parent = model

        table.insert(addedESPModels, model)
    end
end

local function clearESP()
    for _, model in pairs(addedESPModels) do
        if model and model:IsDescendantOf(workspace) then
            for _, part in pairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    local box = part:FindFirstChild("ESPBox")
                    if box then box:Destroy() end
                end
                if part:IsA("BillboardGui") and part.Name == "NameESP" then
                    part:Destroy()
                end
            end
            local tag = model:FindFirstChild("ESP_Added")
            if tag then tag:Destroy() end
        end
    end
    addedESPModels = {}
end

-- ESP frame update
RunService.RenderStepped:Connect(function()
    if espOn then
        frameCounter += 1
        if frameCounter % espEveryNFrames == 0 then
            for _, model in pairs(workspace:GetDescendants()) do
                if model:IsA("Model") and model:FindFirstChild("Humanoid") then
                    local humanoid = model.Humanoid
                    local tagged = model:FindFirstChild("ESP_Added")

                    if not tagged and humanoid.Health > 0 then
                        addESP(model)
                    elseif onlyWhenAlive and tagged and humanoid.Health <= 0 then
                        for _, part in pairs(model:GetDescendants()) do
                            if part:IsA("BasePart") then
                                local box = part:FindFirstChild("ESPBox")
                                if box then box:Destroy() end
                            end
                            if part:IsA("BillboardGui") and part.Name == "NameESP" then
                                part:Destroy()
                            end
                        end
                    end
                end
            end
        end
    end
end)


-- UI Tabs
local generalTab = Window:CreateTab("General Settings", 0)
local espTab = Window:CreateTab("ESP", 0)

-- ⚙️ Toggles and Sliders
generalTab:CreateToggle({
    Name = "ESP",
    CurrentValue = espOn,
    Flag = "espToggle",
    Callback = function(Value)
        espOn = Value
        if not Value then
            clearESP()
        end
    end,
})
generalTab:CreateToggle({
    Name = "Night Vision",
    CurrentValue = nightVisionOn,
    Flag = "nightVisionToggle",
    Callback = function(Value)
        nightVisionOn = Value
        if Value then
            enableLighting()
        else
            resetLighting()
        end
    end,
})
espTab:CreateToggle({
    Name = "Only Show Alive Entities",
    CurrentValue = onlyWhenAlive,
    Flag = "onlyWhenAlive",
    Callback = function(Value)
        onlyWhenAlive = Value
    end,
})
espTab:CreateToggle({
    Name = "Highlight Entities",
    CurrentValue = highlightEnabled,
    Flag = "entityHighlight",
    Callback = function(Value)
        highlightEnabled = Value
        if Value then
            importantNPCs = table.clone(playerChosenModes)
        else
            importantNPCs = {}
        end
    end,
})
espTab:CreateSlider({
    Name = "ESP Update Speed",
    Range = { 1, 100 },
    Increment = 1,
    Suffix = "frames",
    CurrentValue = espEveryNFrames,
    Flag = "espSpeed",
    Callback = function(Value)
        espEveryNFrames = Value
    end,
})
espTab:CreateParagraph({ Title = "", Content =
"To change the highlight mode for any defined entity, pick it from the dropdown, click the button, and pick its mode in the second dropdown." })
local currentEntity
local highlightMode
espTab:CreateDropdown({
    Name = "Entity Picker",
    Options = keys(readableHighlightModes),
    CurrentOption = currentEntity,
    MultipleOptions = false,
    Flag = "entityHighlight", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Options)
        currentEntity = Options[1]
        highlightMode = readableHighlightModes[currentEntity]
    end,
})
espTab:CreateParagraph({ Title = "", Content =
"The ignore mode removes the label but keeps the ESP, and None completely removes the ESP." })
espTab:CreateDropdown({
    Name = "Entity Highlight Mode",
    Options = { "Highlight", "Warn", "Ignore", "None" },
    CurrentOption = highlightMode,
    MultipleOptions = false,
    Flag = "entityHighlight", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Options)
        highlightMode = Options
        playerChosenModes[readableToInternal[currentEntity]] = highlightMode
        importantNPCs = table.clone(playerChosenModes)
    end,
})

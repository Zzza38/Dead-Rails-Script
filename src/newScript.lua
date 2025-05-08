local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer
local circle = Drawing.new("Circle")

-- Configuration Settings
local settings = {
    aimbot = {
        targetPart = "Head",
        fallbackPart = "HumanoidRootPart",
        enabled = false,
        fov = {
            show = true,
            color = Color3.fromRGB(255, 0, 0),
            thickness = 2,
            transparency = 1,
            degrees = 90
        },
        priorityRadius = 90
    },
    esp = {
        enabled = false,
        updateSpeed = 20,
        aliveOnly = true,
        customHighlights = true
    },
    nightVision = false,
    noclip = false
}

-- Entity/Item Definitions
local definitions = {
    entities = {
        Model_Unicorn = {
            name = "Unicorn",
            highlight = "highlight",
            tags = {}
        },
        Model_Banker = {
            name = "Banker",
            highlight = "highlight",
            tags = { "aimbot", "enemy" }
        },
        Model_Werewolf = {
            name = "Werewolf",
            highlight = "warn",
            tags = { "aimbot", "enemy" }
        }
    },
    items = {
        -- Add your item definitions here
        -- Example:
        -- Item_HealthPack = {
        --     name = "Health Pack",
        --     highlight = "highlight",
        --     tags = {"heal"}
        -- }
    }
}

-- Runtime State
local state = {
    connections = {},
    esp = {
        models = {},
        labels = {},
        userHighlights = {}
    },
    aimbot = {
        targets = {}
    }
}

-- Core Functions
local function updateLighting()
    if settings.nightVision then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 5
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    end
end

local function createESP(model, definitionType)
    if model:FindFirstChild("ESP_Added") then return end
    
    local def = definitions[definitionType][model.Name]
    if not def then return end
    
    local highlight = state.esp.userHighlights[model.Name] or def.highlight
    if highlight == "none" then return end

    local color = Color3.new(1, 0, 0)
    if highlight == "highlight" then
        color = Color3.fromRGB(0, 255, 0)
    elseif highlight == "warn" then
        color = Color3.fromRGB(255, 255, 0)
    end

    for _, part in model:GetDescendants() do
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
    if head and highlight ~= "ignore" then
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
        nameLabel.Text = def.name
        nameLabel.Parent = billboard

        if highlight == "warn" then
            state.esp.labels[model] = nameLabel
        end
    end

    Instance.new("BoolValue", model).Name = "ESP_Added"
    table.insert(state.esp.models, model)
end

local function clearESP()
    for _, model in pairs(state.esp.models) do
        if model.Parent then
            for _, part in model:GetDescendants() do
                if part:IsA("BoxHandleAdornment") or part:IsA("BillboardGui") then
                    part:Destroy()
                end
            end
        end
    end
    state.esp.models = {}
    state.esp.labels = {}
end

-- UI Setup
local Window = Rayfield:CreateWindow({
    Name = "Dead Rails Script",
    LoadingTitle = "Dead Rails Script",
    LoadingSubtitle = "by Zzza38",
    ConfigurationSaving = { Enabled = true, FileName = "dead-rails" }
})

local generalTab = Window:CreateTab("General", 140020355535548)
local espTab = Window:CreateTab("ESP", 122410053148023)
local aimbotTab = Window:CreateTab("Aimbot", 90837964489774)

-- General Tab
generalTab:CreateToggle({
    Name = "Night Vision",
    CurrentValue = settings.nightVision,
    Callback = function(value)
        settings.nightVision = value
        updateLighting()
    end
})

generalTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = settings.noclip,
    Callback = function(value)
        settings.noclip = value
    end
})

-- ESP Tab
espTab:CreateToggle({
    Name = "ESP",
    CurrentValue = settings.esp.enabled,
    Callback = function(value)
        settings.esp.enabled = value
        if not value then clearESP() end
    end
})

local entityOptions = {}
for _, def in pairs(definitions.entities) do
    table.insert(entityOptions, def.name)
end

espTab:CreateDropdown({
    Name = "Entity Highlight Modes",
    Options = entityOptions,
    Callback = function(selected)
        local internalName
        for name, def in pairs(definitions.entities) do
            if def.name == selected then
                internalName = name
                break
            end
        end
        
        espTab:CreateDropdown({
            Name = "Highlight Mode",
            Options = {"Highlight", "Warn", "Ignore", "None"},
            Callback = function(mode)
                state.esp.userHighlights[internalName] = mode:lower()
                clearESP()
            end
        })
    end
})

-- Aimbot Tab
aimbotTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = settings.aimbot.enabled,
    Callback = function(value)
        settings.aimbot.enabled = value
        circle.Visible = value and settings.aimbot.fov.show
    end
})

aimbotTab:CreateColorPicker({
    Name = "FOV Color",
    Color = settings.aimbot.fov.color,
    Callback = function(value)
        settings.aimbot.fov.color = value
        circle.Color = value
    end
})

-- Main Loop
table.insert(state.connections, RunService.RenderStepped:Connect(function()
    -- ESP Update
    if settings.esp.enabled then
        for _, model in workspace:GetChildren() do
            if model:IsA("Model") and model:FindFirstChild("Humanoid") then
                if model:FindFirstChild("ESP_Added") then continue end
                if Players:GetPlayerFromCharacter(model) then continue end
                
                if definitions.entities[model.Name] then
                    createESP(model, "entities")
                elseif definitions.items[model.Name] then
                    createESP(model, "items")
                end
            end
        end
    end

    -- Aimbot Logic
    circle.Visible = settings.aimbot.enabled and settings.aimbot.fov.show
    circle.Radius = math.tan(math.rad(settings.aimbot.fov.degrees/2)) * workspace.CurrentCamera.ViewportSize.X
    circle.Position = Vector2.new(
        workspace.CurrentCamera.ViewportSize.X/2,
        workspace.CurrentCamera.ViewportSize.Y/2
    )

    -- Noclip Logic
    if settings.noclip and localPlayer.Character then
        for _, part in localPlayer.Character:GetDescendants() do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end))

-- Cleanup
Rayfield:LoadConfiguration()
game:GetService("Unloaded"):Connect(function()
    clearESP()
    for _, conn in pairs(state.connections) do
        conn:Disconnect()
    end
    circle:Remove()
end)
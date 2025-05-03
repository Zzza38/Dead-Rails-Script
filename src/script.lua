-- Load Rayfield library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main window
local Window = Rayfield:CreateWindow({
    Name = "Dead Rails",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Please wait",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "dead-rails-script",
        FileName = "config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Access Key",
        Subtitle = "Enter the key to continue",
        Note = "This is a custom key system",
        FileName = "KeyConfig",
        SaveKey = true
    }
})

-- Create tabs
local generalTab = Window:CreateTab("General Settings", 4483362458)
local espTab = Window:CreateTab("ESP", 4483362458)

-- UI: ESP Update Frequency (Slider)
espTab:CreateSlider({
	Name = "ESP Refresh Rate (Lower = Faster)",
	Range = {1, 60},
	Increment = 1,
	Suffix = "frames",
	CurrentValue = espEveryNFrames,
	Callback = function(Value)
		espEveryNFrames = Value
	end
})

-- UI: Show Only Alive Targets (Toggle)
espTab:CreateToggle({
	Name = "Show Only Living NPCs",
	CurrentValue = onlyWhenAlive,
	Callback = function(Value)
		onlyWhenAlive = Value
	end
})
-- Fullbright (Night Vision) Toggle
generalTab:CreateToggle({
	Name = "Night Vision (Fullbright)",
	CurrentValue = nightVisionOn,
	Callback = function(Value)
		nightVisionOn = Value
		if nightVisionOn then
			enableLighting()
		else
			resetLighting()
		end
	end
})

-- ESP Toggle (Same as PGUP)
generalTab:CreateToggle({
	Name = "ESP Enabled",
	CurrentValue = espOn,
	Callback = function(Value)
		espOn = Value
		if not espOn then
			clearESP()
		end
	end
})

-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer

-- States
local nightVisionOn = false
local espOn = false
local addedESPModels = {}
local frameCounter = 0
local espEveryNFrames = 3
local onlyWhenAlive = true

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

-- ESP logic
local function addESP(model)
	if model:FindFirstChild("Humanoid") and not model:FindFirstChild("ESP_Added") then
		if Players:GetPlayerFromCharacter(model) then return end

		for _, part in pairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				local box = Instance.new("BoxHandleAdornment")
				box.Size = part.Size
				box.Adornee = part
				box.AlwaysOnTop = true
				box.ZIndex = 10
				box.Transparency = 0.5
				box.Color3 = Color3.new(1, 0, 0)
				box.Name = "ESPBox"
				box.Parent = part
			end
		end

		local head = model:FindFirstChild("Head")
		if head then
			local billboard = Instance.new("BillboardGui")
			billboard.Name = "NameESP"
			billboard.Size = UDim2.new(0, 100, 0, 40)
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
			nameLabel.Text = model.Name
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
					local humanoid = model:FindFirstChild("Humanoid")
					local alreadyTagged = model:FindFirstChild("ESP_Added")

					if not alreadyTagged and humanoid.Health > 0 then
						addESP(model)
					elseif onlyWhenAlive and alreadyTagged and humanoid.Health <= 0 then
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

-- UI Toggles
generalTab:CreateToggle({
	Name = "Night Vision",
	CurrentValue = false,
	Callback = function(Value)
		nightVisionOn = Value
		if nightVisionOn then
			enableLighting()
		else
			resetLighting()
		end
	end
})

espTab:CreateToggle({
	Name = "ESP",
	CurrentValue = false,
	Callback = function(Value)
		espOn = Value
		if not espOn then
			clearESP()
		end
	end
})

Rayfield:LoadConfiguration()

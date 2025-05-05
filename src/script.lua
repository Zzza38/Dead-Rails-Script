local Rayfield = (loadstring(game:HttpGet("https://sirius.menu/rayfield")))();
local helpers = (loadstring(game:HttpGet("https://github.com/Zzza38/Dead-Rails-Script/raw/refs/heads/main/src/helperFunctions.lua")))();
local UserInputService = game:GetService("UserInputService");
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local Lighting = game:GetService("Lighting");
local workspace = game:GetService("Workspace");
local localPlayer = Players.LocalPlayer;
local highlightMode;
local currentEntity;
local renderConnection;
local aimbotTargetBodyPart = "Head";
local aimbotFallbackPart = "HumanoidRootPart";
local nightVisionOn = false;
local espOn = false;
local Clipon = false;
local aimbotEnabled = false;
local addedESPModels = {};
local onlyWhenAlive = true;
local highlightEnabled = true;
local warnNPCLabels = {};
local frameCounter = 0;
local frameCount = 20;
local priorityRadius = 90;
local showAimbotCircle = true;
local fovAngleDegrees = 90;
local circleColor = Color3.fromRGB(255, 0, 0);
local circleThickness = 2;
local circleTransparency = 1;
local circle = Drawing.new("Circle");
circle.Color = circleColor;
circle.Thickness = circleThickness;
circle.Transparency = circleTransparency;
circle.Visible = showAimbotCircle;
circle.Filled = false;
local defaultNPCModes = {
	Model_Unicorn = "highlight",
	Model_Banker = "highlight",
	Model_Werewolf = "warn",
	Model_RevolverOutlaw = "warn",
	Model_RifleOutlaw = "warn",
	Model_ShotgunOutlaw = "warn",
	Model_ZombieMiner = "warn",
	Model_ZombieSheriff = "warn",
	Model_Vampire = "warn",
	Model_Runner = "ignore",
	Model_Walker = "ignore",
	Model_Horse = "ignore",
	Model_Wolf = "ignore",
	Model_RifleSoldier = "none",
	Model_TurretSoldier = "none",
	Shopkeeper = "none",
	Model_ZombieRevolverSoldier = "",
	Model_ZombieRifleSoldier = "",
	Model_ZombieShotgunSoldier = "",
	Model_ArmoredZombie = ""
};
local NPCNames = {
	Model_Unicorn = "Unicorn",
	Model_Werewolf = "Werewolf",
	Model_Runner = "Zombie (Fast)",
	Model_Walker = "Zombie (Slow)",
	Model_Horse = "Horse",
	Model_RifleSoldier = "Ground Soldier",
	Model_TurretSoldier = "Turret Soldier",
	Shopkeeper = "Shopkeeper",
	Model_Wolf = "Wolf",
	Model_RevolverOutlaw = "Outlaw (Revolver)",
	Model_RifleOutlaw = "Outlaw (Rifle)",
	Model_ShotgunOutlaw = "Outlaw (Shotgun)",
	Model_Banker = "Banker",
	Model_ZombieMiner = "Bomber Zombie",
	Model_ZombieSheriff = "Sheriff Zombie",
	Model_ArmoredZombie = "Zombie (Armor)",
	Model_Vampire = "Vampire",
	Model_ZombieRevolverSoldier = "Zombie (Revolver)",
	Model_ZombieRifleSoldier = "Zombie (Rifle)",
	Model_ZombieShotgunSoldier = "Zombie (Shotgun)"
};
local entityTags = {
	Model_Unicorn = {},
	Model_Werewolf = {
		"aimbot",
		"enemy"
	},
	Model_Runner = {
		"aimbot",
		"enemy"
	},
	Model_Walker = {
		"aimbot",
		"enemy"
	},
	Model_Horse = {},
	Model_RifleSoldier = {},
	Model_TurretSoldier = {},
	Shopkeeper = {},
	Model_Wolf = {},
	Model_RevolverOutlaw = {
		"aimbot",
		"enemy"
	},
	Model_RifleOutlaw = {
		"aimbot",
		"enemy"
	},
	Model_ShotgunOutlaw = {
		"aimbot",
		"enemy"
	},
	Model_Banker = {
		"aimbot",
		"enemy"
	},
	Model_ZombieMiner = {
		"aimbot",
		"enemy",
		"kill-first"
	},
	Model_ZombieSheriff = {
		"aimbot",
		"enemy",
		"kill-first"
	},
	Model_ArmoredZombie = {
		"aimbot",
		"enemy"
	},
	Model_Vampire = {
		"aimbot",
		"enemy"
	},
	Model_ZombieRevolverSoldier = {
		"aimbot",
		"enemy"
	},
	Model_ZombieRifleSoldier = {
		"aimbot",
		"enemy"
	},
	Model_ZombieShotgunSoldier = {
		"aimbot",
		"enemy"
	}
};
local playerChosenModes = table.clone(defaultNPCModes);
local importantNPCs = table.clone(playerChosenModes);
local readableHighlightModes = {};
for internalName, mode in pairs(defaultNPCModes) do
	local readableName = NPCNames[internalName] or internalName;
	readableHighlightModes[readableName] = mode;
end;
local readableToInternal = {};
for internalName, mode in pairs(playerChosenModes) do
	local readableName = NPCNames[internalName] or internalName;
	readableToInternal[readableName] = internalName;
end;
local rayfieldConfig = {
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
		Key = {
			"Hello"
		}
	}
};
local Window = Rayfield:CreateWindow(rayfieldConfig);
local function enableLighting()
	Lighting.Ambient = Color3.new(1, 1, 1);
	Lighting.Brightness = 5;
	Lighting.OutdoorAmbient = Color3.new(1, 1, 1);
	Lighting.ClockTime = 12;
end;
local function resetLighting()
	Lighting.Ambient = Color3.new(0, 0, 0);
	Lighting.Brightness = 2;
	Lighting.OutdoorAmbient = Color3.new(0, 0, 0);
end;
local function addESP(model)
	if model:FindFirstChild("Humanoid") and (not model:FindFirstChild("ESP_Added")) then
		if Players:GetPlayerFromCharacter(model) then
			return;
		end;
		local mode = importantNPCs[model.Name];
		local name = NPCNames[model.Name] or model.Name;
		local color = Color3.new(1, 0, 0);
		if mode == "none" then
			return;
		end;
		if mode == "highlight" then
			color = Color3.fromRGB(0, 255, 0);
		elseif mode == "warn" then
			color = Color3.fromRGB(255, 255, 0);
		end;
		for _, part in pairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				local box = Instance.new("BoxHandleAdornment");
				box.Size = part.Size;
				box.Adornee = part;
				box.AlwaysOnTop = true;
				box.ZIndex = 10;
				box.Transparency = 0.5;
				box.Color3 = color;
				box.Name = "ESPBox";
				box.Parent = part;
			end;
		end;
		local head = model:FindFirstChild("Head");
		if head and mode ~= "ignore" then
			local billboard = Instance.new("BillboardGui");
			billboard.Name = "NameESP";
			billboard.Size = UDim2.new(0, 150, 0, 40);
			billboard.StudsOffset = Vector3.new(0, 2, 0);
			billboard.AlwaysOnTop = true;
			billboard.Adornee = head;
			billboard.Parent = head;
			local nameLabel = Instance.new("TextLabel");
			nameLabel.Size = UDim2.new(1, 0, 1, 0);
			nameLabel.BackgroundTransparency = 1;
			nameLabel.TextColor3 = Color3.new(1, 1, 1);
			nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0);
			nameLabel.TextStrokeTransparency = 0.5;
			nameLabel.TextScaled = true;
			nameLabel.Font = Enum.Font.SourceSansBold;
			nameLabel.Text = name;
			if mode == "warn" then
				warnNPCLabels[model] = nameLabel;
			end;
			nameLabel.Parent = billboard;
		end;
		local tag = Instance.new("BoolValue");
		tag.Name = "ESP_Added";
		tag.Parent = model;
		table.insert(addedESPModels, model);
	end;
end;
local function clearESP()
	for _, model in pairs(addedESPModels) do
		if model and model:IsDescendantOf(workspace) then
			for _, part in pairs(model:GetDescendants()) do
				if part:IsA("BasePart") then
					local box = part:FindFirstChild("ESPBox");
					if box then
						box:Destroy();
					end;
				end;
				if part:IsA("BillboardGui") and part.Name == "NameESP" then
					part:Destroy();
				end;
			end;
			local tag = model:FindFirstChild("ESP_Added");
			if tag then
				tag:Destroy();
			end;
		end;
	end;
	for model, nameLabel in pairs(warnNPCLabels) do
		if nameLabel and nameLabel.Parent then
			nameLabel:Destroy();
		end;
	end;
	warnNPCLabels = {};
	addedESPModels = {};
end;
renderConnection = RunService.RenderStepped:Connect(function()
	if espOn then
		frameCounter = frameCounter + 1;
		if frameCounter % frameCount == 0 then
			for _, model in pairs(workspace:GetDescendants()) do
				if model:IsA("Model") and model:FindFirstChild("Humanoid") then
					local humanoid = model.Humanoid;
					local tagged = model:FindFirstChild("ESP_Added");
					if not tagged and humanoid.Health > 0 then
						addESP(model);
					elseif onlyWhenAlive and tagged and humanoid.Health <= 0 then
						for _, part in pairs(model:GetDescendants()) do
							if part:IsA("BasePart") then
								local box = part:FindFirstChild("ESPBox");
								if box then
									box:Destroy();
								end;
							end;
							if part:IsA("BillboardGui") and part.Name == "NameESP" then
								part:Destroy();
							end;
						end;
					end;
				end;
			end;
			for model, label in pairs(warnNPCLabels) do
				if model:IsDescendantOf(workspace) and localPlayer and localPlayer.Character then
					local distance = 0;
					local name = NPCNames[model.Name] or model.Name;
					if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("HumanoidRootPart") then
						distance = math.floor((localPlayer.Character.HumanoidRootPart.Position - model.HumanoidRootPart.Position).Magnitude);
					end;
					label.Text = ("⚠️ " or "") .. name .. " - " .. distance .. " meters";
				end;
			end;
		end;
	end;
	if aimbotEnabled then
		local camera = workspace.CurrentCamera;
		local character = localPlayer.Character;
		if character and character:FindFirstChild("HumanoidRootPart") then
			local rootPos = character.HumanoidRootPart.Position;
			local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2);
			local fovRadius = math.tan(math.rad(fovAngleDegrees / 2)) * camera.ViewportSize.X;
			local closestNormal, closestPriority = nil, nil;
			local closestNormalDist, closestPriorityDist = math.huge, math.huge;
			for _, model in pairs(workspace:GetDescendants()) do
				if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model:FindFirstChild("Humanoid") then
					if not Players:GetPlayerFromCharacter(model) then
						local targetPartName = aimbotTargetBodyPart or aimbotFallbackPart;
						local targetPart = model:FindFirstChild(targetPartName) or model:FindFirstChild(aimbotFallbackPart);
						local tags = entityTags[model.Name];
						if targetPart and tags and table.find(tags, "aimbot") and model.Humanoid.Health > 0 then
							local dist = (targetPart.Position - rootPos).Magnitude;
							local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position);
							if not onScreen then
								continue;
							end;
							local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude;
							if screenDist > fovRadius then
								continue;
							end;
							if table.find(tags, "kill-first") and dist <= priorityRadius then
								if dist < closestPriorityDist then
									closestPriority = targetPart;
									closestPriorityDist = dist;
								end;
							elseif dist < closestNormalDist then
								closestNormal = targetPart;
								closestNormalDist = dist;
							end;
						end;
					end;
				end;
			end;
			local target = closestPriority or closestNormal;
			if target then
				local camPos = camera.CFrame.Position;
				local targetDir = (target.Position - camPos).Unit;
				local newLook = camPos + targetDir;
				local smoothedLook = camPos:Lerp(newLook, 0.2);
				camera.CFrame = CFrame.new(camPos, smoothedLook);
			end;
			circle.Visible = showAimbotCircle;
			if showAimbotCircle then
				circle.Position = screenCenter;
				circle.Radius = fovRadius;
			end;
		end;
	end;
	if Clipon then
		local char = game.Players.LocalPlayer.Character;
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false;
				end;
			end;
		end;
	end;
end);
local generalTab = Window:CreateTab("General Settings", 92518365223638);
local espTab = Window:CreateTab("ESP", 77626488648237);
local aimbotTab = Window:CreateTab("Aimbot", 133705719422297);
generalTab:CreateToggle({
	Name = "ESP",
	CurrentValue = espOn,
	Flag = "espToggle",
	Callback = function(Value)
		espOn = Value;
		if not Value then
			clearESP();
		end;
	end
});
generalTab:CreateToggle({
	Name = "Night Vision",
	CurrentValue = nightVisionOn,
	Flag = "nightVisionToggle",
	Callback = function(Value)
		nightVisionOn = Value;
		if Value then
			enableLighting();
		else
			resetLighting();
		end;
	end
});
generalTab:CreateToggle({
	Name = "Noclip",
	CurrentValue = Clipon,
	Flag = "noclip",
	Callback = function(Value)
		Clipon = Value;
	end
});
generalTab:CreateToggle({
	Name = "Aimbot",
	CurrentValue = aimbotEnabled,
	Flag = "aimbotToggle",
	Callback = function(Value)
		aimbotEnabled = Value;
	end
});
generalTab:CreateButton({
	Name = "Unload Script",
	Callback = function()
		if renderConnection then
			renderConnection:Disconnect();
			renderConnection = nil;
		end;
		clearESP();
		circle.Visible = false;
		Rayfield:Destroy();
	end
});
generalTab:CreateButton({
	Name = "Reload Script",
	Callback = function()
		if renderConnection then
			renderConnection:Disconnect();
			renderConnection = nil;
		end;
		clearESP();
		circle.Visible = false;
		(loadstring(game:HttpGet("https://github.com/Zzza38/Dead-Rails-Script/raw/refs/heads/main/src/script.lua")))();
		Rayfield:Destroy();
	end
});
espTab:CreateToggle({
	Name = "Only Show Alive Entities",
	CurrentValue = onlyWhenAlive,
	Flag = "onlyWhenAlive",
	Callback = function(Value)
		onlyWhenAlive = Value;
	end
});
espTab:CreateToggle({
	Name = "Custom Highlight Entities",
	CurrentValue = highlightEnabled,
	Flag = "entityHighlight",
	Callback = function(Value)
		highlightEnabled = Value;
		if Value then
			importantNPCs = table.clone(playerChosenModes);
		else
			importantNPCs = {};
		end;
	end
});
espTab:CreateSlider({
	Name = "ESP Update Speed",
	Range = {
		1,
		100
	},
	Increment = 1,
	Suffix = "frames",
	CurrentValue = frameCount,
	Flag = "espSpeed",
	Callback = function(Value)
		frameCount = Value;
	end
});
espTab:CreateParagraph({
	Title = "Change Highlight Mode",
	Content = "To change the highlight mode for any defined entity, pick it from the dropdown, click the button, and pick its mode in the second dropdown.\n\n The ignore mode removes the label but keeps the ESP, and None completely removes the ESP."
});
espTab:CreateDropdown({
	Name = "Entity Picker",
	Options = keys(readableHighlightModes),
	CurrentOption = currentEntity,
	MultipleOptions = false,
	Flag = "entityPicker",
	Callback = function(Options)
		currentEntity = Options[1];
		highlightMode = capitalizeFirst(readableHighlightModes[currentEntity]);
	end
});
espTab:CreateDropdown({
	Name = "Entity Highlight Mode",
	Options = {
		"Highlight",
		"Warn",
		"Ignore",
		"None"
	},
	CurrentOption = highlightMode,
	MultipleOptions = false,
	Flag = "entityModePicker",
	Callback = function(Options)
		highlightMode = Options[1];
		playerChosenModes[readableToInternal[currentEntity]] = string.lower(highlightMode);
		importantNPCs = table.clone(playerChosenModes);
		clearESP();
	end
});
aimbotTab:CreateDropdown({
	Name = "Target Bodypart",
	Options = {
		"Head",
		"HumanoidRootPart",
		"Torso",
		"UpperTorso",
		"LowerTorso"
	},
	CurrentOption = aimbotTargetBodyPart,
	MultipleOptions = false,
	Flag = "aimbotTargetBodypart",
	Callback = function(Options)
		aimbotTargetBodyPart = Options[1];
	end
});
aimbotTab:CreateParagraph({
	Title = "Priority Radius",
	Content = "When the aimbot is enabled, a dangerous entity within the priority radius will be auto snapped on for shooting. The FOV circle is ignored."
});
aimbotTab:CreateSlider({
	Name = "Enemy Priority Radius",
	Range = {
		0,
		250
	},
	Increment = 1,
	Suffix = "meters",
	CurrentValue = priorityRadius,
	Flag = "enemyPriorityRadius",
	Callback = function(Value)
		priorityRadius = Value;
	end
});
aimbotTab:CreateSlider({
	Name = "Aimbot FOV",
	Range = {
		5,
		90
	},
	Increment = 1,
	Suffix = "degrees",
	CurrentValue = fovAngleDegrees,
	Flag = "aimbotFOV",
	Callback = function(Value)
		fovAngleDegrees = Value;
	end
});
aimbotTab:CreateToggle({
	Name = "Show Aimbot FOV Circle",
	CurrentValue = showAimbotCircle,
	Flag = "showAimbotCircle",
	Callback = function(Value)
		showAimbotCircle = Value;
		circle.Visible = showAimbotCircle;
	end
});
aimbotTab:CreateColorPicker({
	Name = "Circle Color",
	Color = circleColor,
	Flag = "aimbotCircleColor",
	Callback = function(Value)
		circleColor = Value;
		circle.Color = circleColor;
	end
});
aimbotTab:CreateSlider({
	Name = "Circle Thickness",
	Range = {
		0.1,
		5
	},
	Increment = 0.1,
	Suffix = "",
	CurrentValue = circleThickness,
	Flag = "aimbotCircleThickness",
	Callback = function(Value)
		circleThickness = Value;
		circle.Thickness = circleThickness;
	end
});
aimbotTab:CreateSlider({
	Name = "Circle Transparency",
	Range = {
		0,
		100
	},
	Increment = 1,
	Suffix = "",
	CurrentValue = circleTransparency * 100,
	Flag = "aimbotCircleTransparency",
	Callback = function(Value)
		circleTransparency = Value / 100;
		circle.Transparency = circleTransparency;
	end
});

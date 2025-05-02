local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/Zzza38/Dead-Rails-Script/main/src/OrionLib.lua')))()
local Window = OrionLib:MakeWindow(
	{
		Name = "Dead Rails",
		HidePremium = false,
		SaveConfig = true,
		ConfigFolder =
		"dead-rails-script"
	})
local tabs = {}
tabs.general = Window:MakeTab({
	Name = "General Settings",
	Icon = "rbxassetid://6774409980",
	PremiumOnly = false
})
tabs.esp = Window:MakeTab({
	Name = "ESP",
	Icon = "rbxassetid://77626488648237",
	PremiumOnly = false
})

tabs.general:AddButton({
	Name = "Button!",
	Callback = function()
		print("button pressed")
	end
})

tabs.general:AddToggle({
	Name = "This is a toggle!",
	Default = false,
	Callback = function(Value)
		print(Value)
	end
})
tabs.general:AddColorpicker({
	Name = "Colorpicker",
	Default = Color3.fromRGB(255, 0, 0),
	Callback = function(Value)
		print(Value)
	end
})
local Slider = tabs.general:AddSlider({
	Name = "Slider",
	Min = 16,
	Max = 100,
	Default = 16,
	Color = Color3.fromRGB(255, 255, 255),
	Increment = 1,
	ValueName = "bananas",
	Callback = function(Value)
		print(Value)
	end
})
Slider:Set(18)
local CoolLabel = tabs.general:AddLabel("Label")
CoolLabel:Set("Label New!")
local CoolParagraph = tabs.general:AddParagraph("Paragraph", "Paragraph Content")
CoolParagraph:Set("Paragraph New!", "New Paragraph Content!")
tabs.general:AddTextbox({
	Name = "Textbox",
	Default = "default box input",
	TextDisappear = true,
	Callback = function(Value)
		print(Value)
	end
})
tabs.general:AddBind({
	Name = "Bind",
	Default = Enum.KeyCode.E,
	Hold = false,
	Callback = function()
		print("press")
	end
})
tabs.general:AddDropdown({
	Name = "Dropdown",
	Default = "1",
	Options = { "1", "2" },
	Callback = function(Value)
		print(Value)
	end
})
OrionLib:Init()

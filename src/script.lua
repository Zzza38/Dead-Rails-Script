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

-- Add general settings section
local generalSection = generalTab:CreateSection("Main Settings", true)
local espSection = espTab:CreateSection("ESP Options", true)

-- Button example
generalTab:CreateButton({
    Name = "Button!",
    Callback = function()
        print("Button pressed")
    end
})

-- Toggle examplea
generalTab:CreateToggle({
    Name = "This is a toggle!",
    Default = false,
    Callback = function(Value)
        print(Value)
    end
})

-- Colorpicker example
generalTab:CreateColorPicker({
    Name = "Color Picker",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        print(Value)
    end
})

-- Slider example
local Slider = generalTab:CreateSlider({
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

-- Label example
local CoolLabel = generalTab:CreateLabel("Label")
CoolLabel:Set("Label New!")

-- Paragraph example
local CoolParagraph = generalTab:CreateParagraph("Paragraph", "Paragraph Content")
CoolParagraph:Set("Paragraph New!", "New Paragraph Content!")

-- Textbox example
generalTab:CreateTextbox({
    Name = "Textbox",
    Default = "default box input",
    TextDisappear = true,
    Callback = function(Value)
        print(Value)
    end
})

-- Bind example
generalTab:CreateBind({
    Name = "Bind",
    Default = Enum.KeyCode.E,
    Hold = false,
    Callback = function()
        print("Key pressed")
    end
})

-- Dropdown example
generalTab:CreateDropdown({
    Name = "Dropdown",
    Default = "1",
    Options = { "1", "2" },
    Callback = function(Value)
        print(Value)
    end
})

-- Final Rayfield Initialization
Rayfield:LoadConfiguration()

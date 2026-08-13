local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "",
	Footer = "",
	NotifySide = "Right",
	ShowCustomCursor = false,
    MobileButtonsSide = "Left",
    SidebarCompacted = true,
    CornerRadius = 5,
})

Window:SetAnimations({ ToggleWindow = true, TabSwitch = true, Groupbox = true, Dropdown = true, KeyPicker = true }, 0.22, 26, "bottom")

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
if not Player then
    Player = Players.PlayerAdded:Wait()
end

local char, humanoid, hrp

function OnCharacterAdded(newChar)
    char = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    hrp = newChar:WaitForChild("HumanoidRootPart")

    if setfpscap then
        setfpscap(240)
    end

    humanoid.Died:Connect(function()
        hrp = nil
        humanoid = nil
    end)
end

if Player.Character then OnCharacterAdded(Player.Character) end
Player.CharacterAdded:Connect(OnCharacterAdded)

game:service("Players").LocalPlayer.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- https://lucide.dev/icons/

local Tabs = {
	Main = Window:AddTab("", "house"),
	["UI Settings"] = Window:AddTab("", "settings"),
}

-- local LeftMain = Tabs.Main:AddLeftGroupbox("name", "", nil, nil, true)
-- local RightMain = Tabs.Main:AddRightGroupbox("name", "", nil, nil, true)



-- local Toggle = Groupbox:AddToggle("Toggle", {
--     Text = "",
--     Default = false,
-- })

-- Toggle:OnChanged(function(state)
-- end)



-- local Slider = Groupbox:AddSlider("Slider", {
--     Text = "Slider",
--     Default = 50,
--     Min = 0,
--     Max = 100,
--     Rounding = 0,
--     Suffix = "%",
-- })

-- Slider:OnChanged(function(value)
-- end)



-- local Dropdown = Groupbox:AddDropdown("Dropdown", {
--     Text = "A dropdown",
--     Values = { "This" },
--     Default = "This",
--     Multi = true,
--     AllowNull = true,
--     Searchable = true,
-- })

-- Dropdown:OnChanged(function(Value)
-- end)



-- Groupbox:AddDivider("----")

local buyevent = game:GetService("ReplicatedStorage").Remotes.BuyItem
local collectevent = game:GetService("ReplicatedStorage").Remotes.CollectionMachine


local ShopLeftMain = Tabs.Main:AddLeftGroupbox("Shop", "", nil, nil, true)

local Eggs = { "Capybara Egg", "Alpha Capybara Egg", "Archer Capybara Egg", "Magic Capybara Egg", "Ghost Capybara Egg", "Golem Capybara Egg", "Robot Capybara Egg", "Disco Capybara Egg", "Angel Capybara Egg" }
local Gears = { "Hatch Hammer", "Nametag", "Mutation Sponge", "Boombox", "Bizarre Stopwatch" }

--Egg Section
local SelectEggsDropdown = ShopLeftMain:AddDropdown("SelectEggsDropdown", {
    Text = '<font color="#FF0000">*</font> Select Eggs',
    Values = Eggs,
    Default = "",
    Multi = true,
    AllowNull = true,
    Searchable = true,
})

local SelectEggs = {}
SelectEggsDropdown:OnChanged(function(Value)
    SelectEggs = {}
    for Egg, i in pairs(Value) do
        if i then
            table.insert(SelectEggs, Egg)
        end
    end
end)

local AutoBuyToggle = ShopLeftMain:AddToggle("AutoBuyToggle", {
    Text = "Auto Buy Eggs",
    Default = false,
})

AutoBuyToggle:OnChanged(function(Value)
    if AutoBuyToggle.Value then
        task.spawn(function()
            while AutoBuyToggle.Value do
                if #SelectEggs > 0 then
                    for _, egg in ipairs(SelectEggs) do
                        if not AutoBuyToggle.Value then return end
                        buyevent:FireServer(egg)
                        task.wait(0.1)
                    end
                else
                    task.wait(0.5)
                end
            end
        end)
    end
end)

ShopLeftMain:AddDivider()

-- Gear Section
local SelectGearsDropdown = ShopLeftMain:AddDropdown("SelectGearsDropdown", {
    Text = '<font color="#FF0000">*</font> Select Gears',
    Values = Gears,
    Default = "",
    Multi = true,
    AllowNull = true,
    Searchable = true,
})

local SelectGears = {}
SelectGearsDropdown:OnChanged(function(Value)
    SelectGears = {}
    for gearName, selected in pairs(Value) do
        if selected then
            table.insert(SelectGears, gearName)
        end
    end
end)

local AutoBuyGearsToggle = ShopLeftMain:AddToggle("AutoBuyGearsToggle", {
    Text = "Auto Buy Gears",
    Default = false,
})

AutoBuyGearsToggle:OnChanged(function(Value)
    if AutoBuyGearsToggle.Value then
        task.spawn(function()
            while AutoBuyGearsToggle.Value do
                if #SelectGears > 0 then
                    for _, gear in ipairs(SelectGears) do
                        if not AutoBuyGearsToggle.Value then break end
                        buyevent:FireServer(gear)
                        task.wait(0.1)
                    end
                else
                    task.wait(0.5)
                end
            end
        end)
    end
end)

local MoneyLeftMain = Tabs.Main:AddLeftGroupbox("Money", "", nil, nil, true)

local AutoCollectMoney = MoneyLeftMain:AddToggle("AutoCollectMoney", {
    Text = "Auto Collect Money",
    Default = false,
})

AutoCollectMoney:OnChanged(function(Value)
    if AutoCollectMoney.Value then
        task.spawn(function()
            while AutoCollectMoney.Value do
                if not AutoCollectMoney.Value then return end
                collectevent:FireServer()
                task.wait(1)
            end
        end)
    end
end)




local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})

MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",

	Text = "Notification Side",

	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})

MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
ThemeManager:ApplyTheme("Mint")

SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("fzlmm_xz")
SaveManager:SetFolder("fzlmm_xz/config")
SaveManager:SetSubFolder("gamename")

SaveManager:BuildConfigSection(Tabs["UI Settings"])

ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
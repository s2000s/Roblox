local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "BYTE X",
	Footer = "Plant vs Brainrots | 1.0.0",
    Size = UDim2.fromOffset(700, 600), -- กว้าง,ยาว
	NotifySide = "Right",
	ShowCustomCursor = false,
    DisableSearch = false,
    Center = true,
    MobileButtonSide = "Left",
})

local Tabs = {
	Main = Window:AddTab("Main", "user"),
    --Exploits = Window:AddTab("Exploits", "bug"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}


-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
if not Player then
    Player = Players.PlayerAdded:Wait()
end

local Char = Player.Character
local hrp = Char.HumanoidRootPart
local humanoid = Char.Humanoid

local SelectedSeed = {}
local SelectedGear = {}

local AutoBuySeeds = false
local AutoBuyGears = false

Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- function AutoBuySeedsFunc()
function AutoBuySeedsFunc()
    local BuyItem = ReplicatedStorage.Remotes.BuyItem

    task.spawn(function()
        while AutoBuySeeds do
            for _, Seed in ipairs(SelectedSeed) do
                BuyItem:FireServer(Seed, true)
                task.wait(0.001)
            end
            task.wait(0.01)
        end
    end)
end

-- function AutoBuyGearsFunc()
function AutoBuyGearsFunc()
    local BuyGear = ReplicatedStorage.Remotes.BuyGear

    task.spawn(function()
        while AutoBuyGears do
            for _, Gear in ipairs(SelectedGear) do
                BuyGear:FireServer(Gear, true)
                task.wait(0.001)
            end
            task.wait(0.01)
        end
    end)
end

local LeftGroupBoxMainSeed = Tabs.Main:AddLeftGroupbox("Seeds", "sprout")

local SelectSeedDropdown = LeftGroupBoxMainSeed:AddDropdown("SelectSeedDropdown", {
    Text = "<font color='#FF0000'>*</font> Select Seeds",
    Values = {
    "Cactus Seed",
    "Strawberry Seed",
    "Pumpkin Seed",
    "Sunflower Seed",
    "Dragon Fruit Seed",
    "Eggplant Seed", 
    "Watermelon Seed",
    "Grape Seed",
    "Cocotank Seed",
    "Carnivorous Plant Seed",
    "Mr Carrot Seed",
    "Tomatrio Seed",
    "Shroombino Seed",
    "Mango Seed",
    "King Limone Seed",
    "StarFruit Seed"},
    Multi = true,
    Default = {}
})

local SelectAllSeed = LeftGroupBoxMainSeed:AddButton("Select All", function()
    local all = {}
    for _, v in ipairs(SelectSeedDropdown.Values) do
        all[v] = true
    end
    Options.SelectSeedDropdown:SetValue(all)
end)

SelectAllSeed:AddButton("Unselect All", function()
    Options.SelectSeedDropdown:SetValue({})
end)

SelectSeedDropdown:OnChanged(function(Value)
    SelectedSeed = {}

    for i in pairs(Options.SelectSeedDropdown.Value) do
        table.insert(SelectedSeed, i)
    end
end)

LeftGroupBoxMainSeed:AddDivider()

local AutoBuySeedToggle = LeftGroupBoxMainSeed:AddToggle("AutoBuySeedToggle", {
    Text = "Auto Purchase",
    Default = false
})

AutoBuySeedToggle:OnChanged(function(Value)
    AutoBuySeeds = Value

    if AutoBuySeeds then
        task.spawn(AutoBuySeedsFunc)
    end
end)

local LeftGroupBoxMainGear = Tabs.Main:AddLeftGroupbox("Gears", "pickaxe")

local SelectGearDropdown = LeftGroupBoxMainGear:AddDropdown("SelectGearDropdown", {
    Text = "<font color='#FF0000'>*</font> Select Gears",
    Values = {"Water Bucket", "Frost Grenade", "Banana Gun", "Frost Blower", "Carrot Launcher"},
    Multi = true,
    Default = {}
})

local SelectAllGear = LeftGroupBoxMainGear:AddButton("Select All", function()
    local all = {}
    for _, v in ipairs(SelectGearDropdown.Values) do
        all[v] = true
    end
    Options.SelectGearDropdown:SetValue(all)
end)

SelectAllGear:AddButton("Unselect All", function()
    Options.SelectGearDropdown:SetValue({})
end)

SelectGearDropdown:OnChanged(function(Value)
    SelectedGear = {}
    for i in pairs(Options.SelectGearDropdown.Value) do
        table.insert(SelectedGear, i)
    end
end)

LeftGroupBoxMainGear:AddDivider()

local AutoBuyGearToggle = LeftGroupBoxMainGear:AddToggle("AutoBuyGearToggle", {
    Text = "Auto Purchase",
    Default = false
})

AutoBuyGearToggle:OnChanged(function(Value)
    AutoBuyGears = Value
    
    if AutoBuyGears then
        task.spawn(AutoBuyGearsFunc)
    end
end)

local RightGroupBoxMainInvasion = Tabs.Main:AddRightGroupbox("Invation", "star")

local AutoStartInvasion = RightGroupBoxMainInvasion:AddToggle("AutoStartInvasion", {
    Text = "Auto Start",
    Default = false
})

AutoStartInvasion:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoStartInvasion.Value do
                local RequestStartInvasion = ReplicatedStorage.Remotes.MissionServicesRemotes.RequestStartInvasion
                
                if RequestStartInvasion then
                    RequestStartInvasion:FireServer()
                    task.wait(10)
                end
            end
        end)
    end
end)

local AutoContinueInvasion = RightGroupBoxMainInvasion:AddToggle("AutoContinueInvasion", {
    Text = "Auto Continue",
    Default = false
})

local AutoRestartInvasion = RightGroupBoxMainInvasion:AddToggle("AutoRestartInvasion", {
    Text = "Auto Restart",
    Default = false
})

-- local CurrentTargetText = RightGroupBoxMainEvents:AddLabel("[<font color='#FF0000'>TARGET</font>] Not Found", true)

-- local FoundBrainrot = false

-- task.spawn(function()
-- 	while task.wait(5) do
--         local Plot = Player:GetAttribute("Plot")
--         local EventFindReturn = workspace.Plots[Plot].EventPlatforms:GetChildren()

--         if #EventFindReturn > 0 then
--             local textList = {}

--             for _, Brainrot in ipairs(EventFindReturn) do
--                 local Blackout = Brainrot:GetAttribute("Blackout")
--                 local BrainrotPlatform = Brainrot:GetAttribute("VisualBrainrot")

--                 if Blackout then
--                     table.insert(textList, string.format("<font color='#FF0000'>%s</font>", tostring(BrainrotPlatform)))
--                 else
--                     table.insert(textList, string.format("<font color='#00FF00'>%s</font>", tostring(BrainrotPlatform)))
--                 end
--             end

--             -- รวมทั้งหมดเป็นข้อความเดียว
--             local combinedText = table.concat(textList, ", \n")
--             CurrentTargetText:SetText(string.format("[<font color='#FF0000'>TARGET</font>] %s", combinedText))
--         else
--             CurrentTargetText:SetText("[<font color='#FF0000'>TARGET</font>] <font color='#808080'>Not Found</font>")
--         end
-- 	end
-- end)


-- task.spawn(function()
-- 	while task.wait(5) do
-- 		local CurrentTarget = workspace.ScriptedMap.Event.HitListVisualizer.VisualFolder:GetChildren()
		
-- 		if #CurrentTarget > 0 then
-- 			local targetName = CurrentTarget[1].Name
-- 			CurrentTargetText:SetText(string.format("[<font color='#FF0000'>TARGET</font>] %s", targetName))
--             FoundBrainrot = true
-- 		else
-- 			CurrentTargetText:SetText("[<font color='#FF0000'>TARGET</font>] <font color='#808080'>Not Found</font>")
--             FoundBrainrot = false
-- 		end
-- 	end
-- end)


-- RightGroupBoxMainEvents:AddDivider()

-- local AutoClaimToggle = RightGroupBoxMainEvents:AddToggle("AutoClaim", {
--     Text = "Auto Claim",
--     Default = false
-- })

-- AutoClaimToggle:OnChanged(function(Value)
--     if Value then
--         task.spawn(function()
--             while AutoClaimToggle.Value do
--                 local PathClaim = workspace.ScriptedMap.Event.TomadeFloor.GuiAttachment.Billboard.Display
--                 local FloorTomade = workspace.ScriptedMap.Event.TomadeFloor

--                 local promptPath = workspace.ScriptedMap.Event.EventRewards.TalkPart:FindFirstChildOfClass("ProximityPrompt")

--                 if PathClaim.Text == "Claim" then
--                     if promptPath then
--                         local hrp = Char.HumanoidRootPart

--                         hrp.CFrame = FloorTomade.CFrame + Vector3.new(0, 5, 0)
--                         fireproximityprompt(promptPath)
--                     end
--                 else
--                     -- print("Text is not Claim,", PathClaim.Text)
--                 end

--                 task.wait(2)
--             end
--         end)
--     end
-- end)

-- local AutoResetToggle = RightGroupBoxMainEvents:AddToggle("AutoResetToggle", {
--     Text = "Auto Reset",
--     Default = false
-- })

-- AutoResetToggle:OnChanged(function(Value)
-- 	local CardUpdateEvent = ReplicatedStorage.Remotes.CardUpdateEvent

-- 	if Value then
-- 		task.spawn(function()
-- 			while AutoResetToggle.Value do
--                 task.wait(7)
-- 				CardUpdateEvent:FireServer("purchaseReplay")
--                 if not FoundBrainrot then
--                     local FloorTomade = workspace.ScriptedMap.Event.TomadeFloor
--                     local promptPath = workspace.ScriptedMap.Event.EventRewards.TalkPart:FindFirstChildOfClass("ProximityPrompt")
--                     local hrp = Char.HumanoidRootPart

--                     hrp.CFrame = FloorTomade.CFrame + Vector3.new(0, 5, 0)
--                     fireproximityprompt(promptPath)
--                 end
-- 			end
-- 		end)
-- 	end
-- end)

local RightGroupBoxMainMisc = Tabs.Main:AddRightGroupbox("Misc", "blend")

local AutoEquipBestVar = false
local DelayEquipBest = 2.5

-- function AutoEquipBest()
function AutoEquipBest()
    local EquipBest = ReplicatedStorage.Remotes.EquipBest

    task.spawn(function()
        while AutoEquipBestVar do
            EquipBest:Fire()
            task.wait(DelayEquipBest)
        end
    end)
end

local AutoEquipBestToggle = RightGroupBoxMainMisc:AddToggle("AutoEquipbest", {
    Text = "Auto Equip Best",
    Default = false
})

AutoEquipBestToggle:OnChanged(function(Value)
    AutoEquipBestVar = Value

    if AutoEquipBestVar then
        task.spawn(AutoEquipBest)
    end
end)

local DelayEquip = RightGroupBoxMainMisc:AddSlider("DelayEquip", {
    Text = "Delay (s)",
    Default = 2.5,
    Min = 0.1,
    Max = 20,
    Rounding = 1,
})

DelayEquip:OnChanged(function(Value)
    DelayEquipBest = Value
end)

-- local LeftGroupBoxExploitCard = Tabs.Exploits:AddLeftGroupbox("Infinite Tier 3 Card", "puzzle")

-- LeftGroupBoxExploitCard:AddLabel("Convert all of your unequipped cards to tier 3,III without need 3 card", true)

-- local MergeCardToggle = LeftGroupBoxExploitCard:AddToggle("MergeCardToggle", {
--     Text = "Auto Merge Card",
--     Default = false
-- })

-- MergeCardToggle:OnChanged(function(Value)
--     if Value then
--         task.spawn(function()
--             while MergeCardToggle.Value do
--                 local PlayerData = require(game:GetService("ReplicatedStorage").PlayerData)
--                 local data = PlayerData:GetData()

--                 for i, card in pairs(data.Data.Cards.Inventory) do
--                     local MergeCards = ReplicatedStorage.Remotes.MergeCards 

--                     MergeCards:InvokeServer(
--                     {
--                         i,
--                         i,
--                         i
--                     }
--                     )
--                 end
--                 task.wait(1)
--             end
--         end)
--     end
-- end)


-- UI Settings
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = false,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
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
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/Plant_vs_Brainrot")
SaveManager:SetSubFolder("Plant_vs_Brainrot")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
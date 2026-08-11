-- local Replion = require(game:GetService("ReplicatedStorage").Packages.Replion)
-- local Client = Replion.Client
-- local Data = Client:WaitReplion("Data")

-- local ItemUtility = require(game:GetService("ReplicatedStorage").Shared.ItemUtility)
-- local ItemStringUtility = require(game:GetService("ReplicatedStorage").Modules.ItemStringUtility)
-- local items = Data:GetExpect({ "Inventory", "Items" })

-- for i, item in ipairs(items) do
--     local info = ItemUtility:GetItemData(item.Id)
--     if info then
--         local name = ItemStringUtility.GetItemName(item, info)
--         print(i, name)
--     else
--         print(i, "(Unknown)", item.Id)
--     end
-- end

-- hrp.CFrame = CFrame.new(-3600.04541, -266.57373, -1571.57239)

local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow{
    Title = "Fish It ",
    SubTitle = "by zzyyeez",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = false,
    Theme = "Viow Mars",
    MinimizeKey = Enum.KeyCode.RightShift
}
local Tabs = {
    Main = Window:CreateTab{
        Title = "Main",
        Icon = "chevrons-right"
    },
    Settings = Window:CreateTab{
        Title = "Settings",
        Icon = "settings"
    }
}
local Options = Library.Options

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
if not Player then
    Player = Players.PlayerAdded:Wait()
end

local Char = Player.Character
local hrp = Char:WaitForChild("HumanoidRootPart")
local humanoid = Char:WaitForChild("Humanoid")

game:service("Players").LocalPlayer.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    wait(2)
end)

Tabs.Main:AddSection("Fishing")

local AutoCastFishToggle = Tabs.Main:AddToggle("AutoCastFishToggle", { Title = "Auto Cast",Description = "automatically casts fishing rod", Default = false })
AutoCastFishToggle:OnChanged(function(Value)
    local REEquipToolFromHotbar = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]
    local RFChargeFishingRod = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
    local RFRequestFishingMinigameStarted = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/RequestFishingMinigameStarted"]
    local REFishingCompleted = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingCompleted"]
    local RFCancelFishingInputs = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"]
    local REUnequipToolFromHotbar = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/UnequipToolFromHotbar"]

    if Value then
        task.spawn(function()
            while AutoCastFishToggle.Value do
                if Char and Char:FindFirstChild("HumanoidRootPart") then
                    Char.HumanoidRootPart.Anchored = true
                end

                REEquipToolFromHotbar:FireServer(1)
                task.wait(0.1)
                RFChargeFishingRod:InvokeServer(workspace:GetServerTimeNow())
                task.wait(0.1)
                RFRequestFishingMinigameStarted:InvokeServer(-1.0084729, 0.9999999999999999, workspace:GetServerTimeNow())
                task.wait(0.1)
                REFishingCompleted:FireServer()
                task.wait(0.1)
            end
        end)
    else
        if Char and Char:FindFirstChild("HumanoidRootPart") then
            Char.HumanoidRootPart.Anchored = false
        end
        RFCancelFishingInputs:InvokeServer()
    end
end)

-- AutoCastFishToggle:OnChanged(function(Value)
--     local REEquipToolFromHotbar = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]
--     local RFChargeFishingRod = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/ChargeFishingRod"]
--     local RFRequestFishingMinigameStarted = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/RequestFishingMinigameStarted"]
--     local REFishingCompleted = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingCompleted"]
--     local RFCancelFishingInputs = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"]
--     local REUnequipToolFromHotbar = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/UnequipToolFromHotbar"]

--     if Value then
--         task.spawn(function()
--             while AutoCastFishToggle.Value do
--                 if Char and Char:FindFirstChild("HumanoidRootPart") then
--                     Char.HumanoidRootPart.Anchored = true
--                 end

--                 REEquipToolFromHotbar:FireServer(1)
--                 task.wait(0.1)
--                 RFChargeFishingRod:InvokeServer(workspace:GetServerTimeNow())
--                 task.wait(1)
--                 RFRequestFishingMinigameStarted:InvokeServer(-1.0084729, 0.9219299896929919, workspace:GetServerTimeNow())
--                 task.wait(3.5)
--                 REFishingCompleted:FireServer()
--                 task.wait(1)

--             end
--         end)
--     else
--         if Char and Char:FindFirstChild("HumanoidRootPart") then
--             Char.HumanoidRootPart.Anchored = false
--         end
--         RFCancelFishingInputs:InvokeServer()
--     end
-- end)



Tabs.Main:AddSection("Sell")

local DelaysAutosell = 10 * 60

Tabs.Main:CreateButton{
    Title = "Sell all",
    Description = "sell all fish in inventory",
    Callback = function()
        Window:Dialog{
            Title = "WARNING!",
            Content = "this will sell all fish in inventory, press confirm to continue",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        local RFSellAllItems = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]
                        RFSellAllItems:InvokeServer()
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                    end
                }
            }
        }
    end
}

local AutoSellToggle = Tabs.Main:AddToggle("AutoSellToggle", { Title = "Auto Sell", Description = "automatically sell all fish in inventory", Default = false })
AutoSellToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoSellToggle.Value do
                task.wait(DelaysAutosell)
                local RFSellAllItems = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]
                RFSellAllItems:InvokeServer()
            end
        end)
    end
end)

local DelaySellAllSlider = Tabs.Main:CreateSlider("DelaySellAllSlider", {
    Title = "Delays (minutes)",
    Description = "change delays auto sell",
    Default = 10,
    Min = 1,
    Max = 60,
    Rounding = 0,
    Callback = function(Value)
        DelaysAutosell = Value * 60
    end
})

Tabs.Main:AddSection("Misc")
local EquipDrivingGearToggle = Tabs.Main:AddToggle("EquipDrivingGearToggle", { Title = "Equip Driving Gear", Description = "", Default = false })
EquipDrivingGearToggle:OnChanged(function(Value)
    if Value then
        local RFEquipOxygenTank = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/EquipOxygenTank"]
        RFEquipOxygenTank:InvokeServer(105)
    else
        local RFUnequipOxygenTank = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/UnequipOxygenTank"]
        RFUnequipOxygenTank:InvokeServer()
    end
end)


SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes{}
InterfaceManager:SetFolder("fzlmm_xz")
SaveManager:SetFolder("fzlmm_xz/Fish it")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
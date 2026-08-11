local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow{
    Title = " ",
    SubTitle = "by zzyyeez",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = false,
    Theme = "Yaru Dark",
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

-- Anti Idle / Anti AFK
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    task.wait(2)
end)

local PlotFolder = workspace:WaitForChild("Plots")
local MyPlot = nil

repeat
    MyPlot = PlotFolder:FindFirstChild(Player.Name)
    if not MyPlot then
        task.wait(0.5)
    end
until MyPlot ~= nil

--------------------------------------------------------------------------------

-- local Stats = require(ReplicatedStorage.Paper.Client.Stats)
-- Stats.LoadedAsync()
-- local cash = Stats.GetValue("Cash")
-- local chickens = Stats.GetValue("TotalChickens")

local event = game:GetService("ReplicatedStorage").Paper.Remotes.__remotefunction
local event2 = game:GetService("ReplicatedStorage").Paper.Remotes.__remoteevent

Tabs.Main:AddSection("Eggs")

local ToggleDeposit = Tabs.Main:CreateToggle("ToggleDeposit", {Title = "Auto Deposit Eggs", Default = false })

ToggleDeposit:OnChanged(function(Value)
    if ToggleDeposit.Value then
        task.spawn(function()
            while ToggleDeposit.Value do
                event:InvokeServer("Deposit Eggs")
                task.wait(0.5)
            end
        end)
    end
end)

local ToggleCollect = Tabs.Main:CreateToggle("ToggleCollect", {Title = "Auto Collect Eggs", Default = false })
local eggpath = workspace:WaitForChild("Eggs")

ToggleCollect:OnChanged(function(Value)
    if ToggleCollect.Value then
        task.spawn(function()
            while ToggleCollect.Value do
                for _, egg in ipairs(eggpath:GetChildren()) do
                    if not ToggleCollect.Value then break end

                    local Part = egg:FindFirstChild("Part")
                    if Part then
                        firetouchinterest(hrp, Part, 0)
                        firetouchinterest(hrp, Part, 1)
                    end
                end
                task.wait(0.01)
            end
        end)
    end
end)

Tabs.Main:AddSection("Chickens")

local amount = 0
local ChickenDropdown = Tabs.Main:CreateDropdown("ChickenDropdown", {
    Title = "Select Amount",
    Values = { "1", "5", "25", "100" },
    Multi = false,
    Default = {"1"},
})

ChickenDropdown:OnChanged(function(Value)
    amount = tonumber(Value)
end)

local ToggleBuy = Tabs.Main:CreateToggle("ToggleBuy", {Title = "Auto Buy", Default = false })

ToggleBuy:OnChanged(function(Value)
    if ToggleBuy.Value then
        task.spawn(function()
            while ToggleBuy.Value do
                if not ToggleBuy.Value then return end
                event:InvokeServer("Buy Chickens", amount)
                task.wait(0.1)
            end
        end)
    end
end)

local ToggleUpgradeTier = Tabs.Main:CreateToggle("ToggleUpgradeTier", {Title = "Auto Upgrade Tier", Default = false })

ToggleUpgradeTier:OnChanged(function(Value)
    if ToggleUpgradeTier.Value then
        task.spawn(function()
            while ToggleUpgradeTier.Value do
                if not ToggleUpgradeTier.Value then return end
                event:InvokeServer("Upgrade Buy Tier Level")
                task.wait(0.1)
            end
        end)
    end
end)

local ToggleMerge = Tabs.Main:CreateToggle("ToggleMerge", {Title = "Auto Merge", Default = false })

ToggleMerge:OnChanged(function(Value)
    if ToggleMerge.Value then
        task.spawn(function()
            while ToggleMerge.Value do
                local merge = MyPlot.Buttons:FindFirstChild("MergeChickens")
                if merge then
                    local Part = merge:FindFirstChild("Button")
                    if Part and Part:FindFirstChild("UI") then
                        local mergecheck = Part.UI.Enabled
                        if mergecheck then
                            -- print("ready merge")
                            firetouchinterest(hrp, Part, 0)
                            firetouchinterest(hrp, Part, 1)
                        else
                            -- print("not ready merge")
                        end
                    end
                end
                task.wait(2)
            end
        end)
    end
end)

Tabs.Main:AddSection("Money")

local ToggleCollectMoney = Tabs.Main:CreateToggle("ToggleCollectMoney", {Title = "Auto Collect Money", Default = false })

ToggleCollectMoney:OnChanged(function(Value)
    if ToggleCollectMoney.Value then
        task.spawn(function()
            while ToggleCollectMoney.Value do
                if not ToggleCollectMoney.Value then return end

                local Collect = MyPlot.Buttons:FindFirstChild("CollectMoney")
                if Collect then
                    local Part = Collect:FindFirstChild("Button")
                    if Part then
                        firetouchinterest(hrp, Part, 0)
                        firetouchinterest(hrp, Part, 1)
                    end
                end
                task.wait(2)
            end
        end)
    end
end)

Tabs.Main:AddSection("Player")

local ToggleRebirth = Tabs.Main:CreateToggle("ToggleRebirth", {Title = "Auto Rebirth", Default = false })

ToggleRebirth:OnChanged(function(Value)
    if ToggleRebirth.Value then
        task.spawn(function()
            while ToggleRebirth.Value do
                if not ToggleRebirth.Value then return end
                event:InvokeServer("Rebirth")
                task.wait(10)
            end
        end)
    end
end)

SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
-- SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes{}
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
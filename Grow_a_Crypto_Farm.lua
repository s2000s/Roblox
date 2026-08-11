local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow{
    Title = "Grow a Crypto Farm ",
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
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
if not Player then
    Player = Players.PlayerAdded:Wait()
end

local Char = Player.Character
local hrp = Char.HumanoidRootPart
local humanoid = Char.Humanoid

Tabs.Main:AddSection("Collect")

local AutoCollect = false
local DelaysCollect = 10

local DelaysAutoCollectSlider = Tabs.Main:CreateSlider("DelaysAutoCollectSlider", {
    Title = "Delays (s)",
    Description = "",
    Default = DelaysCollect,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        DelaysCollect = Value
    end
})

local AutoCollectToggle = Tabs.Main:CreateToggle("AutoCollectToggle", {Title = "Auto Collect", Default = false })
AutoCollectToggle:OnChanged(function(Value)
    AutoCollect = Value

    local BasePlayer = Player:GetAttribute("Base")

    if AutoCollect then
        task.spawn(function()
            while AutoCollect do
                if BasePlayer then
                    local FolderBase = workspace.Bases:FindFirstChild(BasePlayer)
                    local Machine = FolderBase.Machines.Server
                    local ClaimCrypto = ReplicatedStorage.Remotes.Events.ClaimCrypto

                    for _, i in ipairs(Machine:GetChildren()) do
                        ClaimCrypto:FireServer(i.Name)
                    end
                end
                task.wait(DelaysCollect)
            end
        end)
    end
end)

Tabs.Main:AddSection("Sell")

local AutoSellAll = false
local DelaysAutoSellAll = 10

local DelaysAutoSellSlider = Tabs.Main:CreateSlider("DelaysAutoSellSlider", {
    Title = "Delays (s)",
    Description = "",
    Default = DelaysAutoSellAll,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        DelaysAutoSellAll = Value
    end
})

local AutoSellToggle = Tabs.Main:CreateToggle("AutoSellToggle", {Title = "Auto Sell", Description = "automatically sell all crypto in inventory", Default = false })
AutoSellToggle:OnChanged(function(Value)
    AutoSellAll = Value
    local SellCrypto = ReplicatedStorage.Remotes.Events.SellCrypto
    
    if AutoSellAll then
        task.spawn(function()
            while AutoSellAll do
                task.wait(DelaysAutoSellAll)
                SellCrypto:FireServer("All")
            end
        end)
    end
end)







SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes{}
InterfaceManager:SetFolder("fzlmm_xz")
SaveManager:SetFolder("fzlmm_xz/Grow A Crypto Farm")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
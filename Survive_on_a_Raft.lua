local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow{
    Title = "Survive on a Raft ",
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

local Action = ReplicatedStorage.Action
local Box = workspace.World.Items

-- for _, i in ipairs(Box:GetChildren()) do
-- 	Action:InvokeServer(
-- 		"Collect",
-- 		i
-- 	)
-- end

local SelectItems = {}
local SelectItemsDropdown = Tabs.Main:CreateDropdown("SelectItemsDropdown", {
    Title = "Select Items",
    Description = "",
    Values = { "Wooden Box", "Regular Chest", "Bottle" },
    Multi = true,
    Default = {},
})
SelectItemsDropdown:OnChanged(function(Value)
    SelectItems = {}

    for i in pairs(Options.SelectItemsDropdown.Value) do
        table.insert(SelectItems, i)
    end
end)

local AutoFarmItems = false
local Plank = workspace.World.Maps.Buildings:WaitForChild("Plank")
local AutoFarmItemsToggle = Tabs.Main:CreateToggle("AutoFarmItemsToggle", { Title = "Auto Farm Items", Default = false })
AutoFarmItemsToggle:OnChanged(function(Value)
    AutoFarmItems = Value

    if AutoFarmItems then
        task.spawn(function()
            while AutoFarmItems do
                for _, item in ipairs(Box:GetChildren()) do
                    if table.find(SelectItems, item.Name) then
                        hrp.CFrame = item.CFrame * CFrame.new(0, 3, 0)
                        task.wait(0.3)
                        Action:InvokeServer("Collect", item)
                        task.wait(0.2)
                        hrp.CFrame = Plank.PrimaryPart.CFrame * CFrame.new(0, 10, 0)
                    end
                end
                task.wait(1)
            end
        end)
    else
        hrp.CFrame = Plank.PrimaryPart.CFrame * CFrame.new(0, 10, 0)
    end
end)

SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes{}
InterfaceManager:SetFolder("fzlmm_xz")
SaveManager:SetFolder("fzlmm_xz/Survive on a Raft")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
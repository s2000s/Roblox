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
    wait(2)
end)

local plotpath = workspace:WaitForChild("PlayerPens")
local event_collectcash = ReplicatedStorage.Remotes:WaitForChild("collectPetCash")

local ownerplot
if not ownerplot then
    for _, plot in ipairs(plotpath:GetChildren()) do
        if plot:GetAttribute("Owner") == Players.LocalPlayer.Name then
            ownerplot = plot
            break
        end
    end
end

local delaycollectcash = 0.1
local DelayCollectCashSlider = Tabs.Main:CreateSlider("DelayCollectCashSlider", {
    Title = "Delays (s)",
    Description = "",
    Default = delaycollectcash,
    Min = 0.1,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        delaycollectcash = Value
    end
})

local AutoCollectToggle = Tabs.Main:CreateToggle("AutoCollectToggle", {Title = "Auto Collect Cash", Default = false })
AutoCollectToggle:OnChanged(function(Value)
    if Value then
        while Value do
            for _, pet in ipairs(ownerplot.Pets:GetChildren()) do
                if not Value then return end
                event_collectcash:FireServer(pet.Name)

                task.wait(delaycollectcash)
            end
            task.wait(0.1)
        end
    end
end)

-- local RoamingPets = workspace.RoamingPets.Pets

-- for _, i in ipairs(RoamingPets:GetChildren()) do
-- 	local namepet = i:GetAttribute("Name")
-- 	local rarity = i:GetAttribute("Rarity")

-- 	if rarity == "Legendary" then
-- 		print("Name:", namepet, "Rarity:", rarity)
-- 	end
-- end






SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes{}
InterfaceManager:SetFolder("fzlmm_xz")
SaveManager:SetFolder("fzlmm_xz/Catch and Tame")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
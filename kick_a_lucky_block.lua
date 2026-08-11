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

-- Rs
local rev_KickEvent = ReplicatedStorage.Shared.Packages.Network.rev_KickEvent
local rev_Collected = ReplicatedStorage.Shared.Packages.Network.rev_Collected
local rev_RebirthRequest = ReplicatedStorage.Shared.Packages.Network.rev_RebirthRequest

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

local plot = workspace.Plots
local ownerplot = nil

for _, p in ipairs(plot:GetChildren()) do
    local owner = p:GetAttribute("Owner")
    if owner == Player.Name then
        ownerplot = p
        break
    end
end

Tabs.Main:AddSection("Collect")

local delaycollectvar = 1
local delaycollect = Tabs.Main:AddSlider("delaycollect", {
    Title = "Delays (s)",
    Description = "",
    Default = delaycollectvar,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value)
        delaycollectvar = Value
    end
})

local AutoCollect = Tabs.Main:AddToggle("AutoCollect", { Title = "Auto Collect", Default = false })
local AutoCollectState = false
AutoCollect:OnChanged(function(Value)
    AutoCollectState = Value
    if AutoCollectState then
        task.spawn(function()
            while AutoCollectState do
                if ownerplot and hrp then
                    local buttons = ownerplot:FindFirstChild("Buttons")
                    if buttons then
                        for _, obj in ipairs(buttons:GetDescendants()) do
                            if not AutoCollectState then return end
                            if obj:IsA("BasePart") then
                                firetouchinterest(hrp, obj, 0)
                                task.wait()
                                firetouchinterest(hrp, obj, 1)
                            end
                        end
                    end
                end
                task.wait(delaycollectvar)
            end
        end)
    end
end)



Tabs.Main:AddSection("Kick Power")

local AutoKickPower = Tabs.Main:AddToggle("AutoKickPower", { Title = "Auto Farm Kick Power", Default = false })
local AutoKickPowerEnabled = false 

AutoKickPower:OnChanged(function(Value)
    AutoKickPowerEnabled = Value
    
    if AutoKickPowerEnabled then
        task.spawn(function()
            while AutoKickPowerEnabled do
                local tool = Player.Backpack:FindFirstChildOfClass("Tool")
                if tool and not char:FindFirstChildOfClass("Tool") then
                    humanoid:EquipTool(tool)
                end
                task.wait(5)
            end
        end)
        task.spawn(function()
            local kickUpgrades = Player.PlayerGui:WaitForChild("KickUpgrades", 5)
            while AutoKickPowerEnabled do
                if kickUpgrades then
                    for _, v in ipairs(kickUpgrades:GetDescendants()) do
                        if not AutoKickPowerEnabled then return end
                        if v.Name == "Bonus" and v:IsA("GuiButton") and v.Visible == true then
                            local signals = {"MouseButton1Click", "MouseButton1Down", "Activated"}
                            for _, signalName in ipairs(signals) do
                                for _, connection in pairs(getconnections(v[signalName])) do
                                    connection:Fire()
                                end
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    else
        humanoid:UnequipTools()
    end
end)




Tabs.Main:AddSection("Misc")

local walkspeed = 16
local oldWalkSpeed = nil

local walkspeedslider = Tabs.Main:AddSlider("walkspeedslider", {
    Title = "Speed",
    Default = walkspeed,
    Min = 16,
    Max = 350,
    Rounding = 0,
    Callback = function(Value)
        walkspeed = Value
    end
})

local WalkSpeedToggle = Tabs.Main:AddToggle("WalkSpeedToggle", { Title = "Enable Speed", Default = false })

WalkSpeedToggle:OnChanged(function(Value)

    if Value then
        oldWalkSpeed = humanoid.WalkSpeed
        for _, i in ipairs(getconnections(humanoid:GetPropertyChangedSignal("WalkSpeed"))) do
            i:Disconnect()
        end

        task.spawn(function()
            while WalkSpeedToggle.Value do
                if humanoid then
                    humanoid.WalkSpeed = walkspeed
                end
                task.wait()
            end
        end)

    else
        if humanoid and oldWalkSpeed then
            humanoid.WalkSpeed = oldWalkSpeed
        end
    end
end)



SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes{}
InterfaceManager:SetFolder("fzlmm_xz")
SaveManager:SetFolder("fzlmm_xz/Kick a Lucky Block")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
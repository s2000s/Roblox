local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow{
    Title = "Anime Eternal ",
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

-- To_Server:FireServer({
-- 	Action = "_Gacha_Activate",
-- 	Name = "Swords",
-- 	Open_Amount = 3
-- 	}
-- )

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

local Player = Players.LocalPlayer
if not Player then
    Player = Players.PlayerAdded:Wait()
end

local Char = Player.Character or Player.CharacterAdded:Wait()
local hrp = Char:WaitForChild("HumanoidRootPart")
local humanoid = Char:WaitForChild("Humanoid")

game:service("Players").LocalPlayer.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    wait(2)
end)

-- Games
local To_Server = ReplicatedStorage.Events.To_Server

-- Tabs.Main

-- local SelectMobDropdown = Tabs.Main:CreateDropdown("SelectMobDropdown", {
--     Title = "Select Enemies",
--     Description = "",
--     Values = { "", "", "", "", "", "", "", "", "", "", "", "", "", "" },
--     Multi = true,
--     Default = {},
-- })

-- SelectMobDropdown:OnChanged(function(Value)

-- end)

local AutoFarmToggle = Tabs.Main:CreateToggle("AutoFarmToggle", {Title = "Auto Farm", Description = "automatically attack nearest enemy", Default = false })
AutoFarmToggle:OnChanged(function(Value)
	if Value then
		task.spawn(function()
			while AutoFarmToggle.Value do
				if not AutoFarmToggle.Value then break end

				local Player = Players.LocalPlayer
				if not Player then
					Player = Players.PlayerAdded:Wait()
				end

				local Char = Player.Character or Player.CharacterAdded:Wait()
				local hrp = Char:WaitForChild("HumanoidRootPart")

				local MobPath = workspace.Debris.Monsters
				local closestMob = nil
				local shortestDistance = math.huge

				for _, mob in ipairs(MobPath:GetChildren()) do
					local title = mob:GetAttribute("Title")
					local health = mob:GetAttribute("Health")

					if title and health and mob.PrimaryPart and health > "0" then
						local distance = (mob.PrimaryPart.Position - hrp.Position).Magnitude
						if distance < shortestDistance and distance <= 300 then
							shortestDistance = distance
							closestMob = mob
						end
					end
				end

				if closestMob and closestMob.PrimaryPart then
					local id = closestMob:GetAttribute("Id")
					local mobPos = closestMob.PrimaryPart.Position
					local hrpPos = hrp.Position

					local direction = (mobPos - hrpPos).Unit
					local targetPos = mobPos - (direction * 5) + Vector3.new(0, 0, 0)

					local distance = (hrpPos - targetPos).Magnitude
					local speed = 150
					local tweenTime = math.clamp(distance / speed, 0.1, 2)

					local tween = TweenService:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear),{ CFrame = CFrame.new(targetPos, mobPos) })

					tween:Play()
					tween.Completed:Wait()

					repeat
						if not closestMob.Parent or not closestMob.PrimaryPart then
							break
						end

						To_Server:FireServer({ Id = id, Action = "_Mouse_Click" })

						task.wait(0.1)
					until not closestMob or closestMob:GetAttribute("Health") or "0" <= "0"
				end

				task.wait(0.1)
			end
		end)
	end
end)

Tabs.Main:AddSection("[⚔️] Kill Aura")

local KillAuraToggle = Tabs.Main:CreateToggle("KillAuraToggle", {Title = "Kill Aura", Description = "attack nearest enemies", Default = false })
KillAuraToggle:OnChanged(function(Value)
    local To_Server = ReplicatedStorage.Events.To_Server 

    if Value then
        task.spawn(function()
            while KillAuraToggle.Value do
                if not KillAuraToggle.Value then break end
                local MobPath = workspace.Debris.Monsters
                local closestMob = nil
                local shortestDistance = math.huge

                for _, mob in ipairs(MobPath:GetChildren()) do
                    -- Players
                    local Player = Players.LocalPlayer
                    if not Player then
                        Player = Players.PlayerAdded:Wait()
                    end

                    local Char = Player.Character or Player.CharacterAdded:Wait()
                    local hrp = Char:WaitForChild("HumanoidRootPart")
                    --
                    local title = mob:GetAttribute("Title")
                    local health = mob:GetAttribute("Health")

                    if title and health and mob.PrimaryPart then
                        local distance = (mob.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestMob = mob
                        end
                    end
                end

                if closestMob then
                    local id = closestMob:GetAttribute("Id")
                    local title = closestMob:GetAttribute("Title")

                    To_Server:FireServer({ Id = id, Action = "_Mouse_Click" })
                end
                task.wait(0.1)
            end
        end)
    end
end)

Tabs.Main:AddSection("[✨] Rank Up")

-- local Information = Tabs.Main:CreateParagraph("Information", {
--     Title = "Information",
--     Content = "status: waiting."
-- })

-- task.spawn(function()
--     while true do
--         local Rank = Player.leaderstats.Rank.Value
--         local Energy = Player.leaderstats.Energy.Value

--         if Rank and Energy then
--             -- Information:SetValue("Current Rank: " .. Rank .. "\nEnergy: " .. Energy)
--             Information:SetValue("Current Rank: " .. Rank)
--         end
--         task.wait(3)
--     end
-- end)

local AutoRankUpToggle = Tabs.Main:CreateToggle("AutoRankUpToggle", {Title = "Auto Rank Up", Description = "Automatically Rank Up", Default = false })
AutoRankUpToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoRankUpToggle.Value do
                To_Server:FireServer({Upgrading_Name = "Rank",Action = "_Upgrades",Upgrade_Name = "Rank_Up"})
                task.wait(10)
            end
        end)
    end
end)

Tabs.Main:AddSection("[🏅] Stats")

local SelectStats = {}
local SelectStatsDropdown = Tabs.Main:CreateDropdown("SelectStatsDropdown", {
    Title = "Select Stats",
    Description = "",
    Values = { "Damage", "Energy", "Coins", "Luck" },
    Multi = true,
    Default = {},
})
SelectStatsDropdown:OnChanged(function(Value)
    SelectStats = {}

    for i in pairs(Options.SelectStatsDropdown.Value) do
        table.insert(SelectStats, i)
    end
end)

local AmountStats = 10
local AmountAddStatsSlider = Tabs.Main:CreateSlider("AmountAddStatsSlider", {
    Title = "Amount",
    Description = "amount of stats to add",
    Default = AmountStats,
    Min = 1,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        AmountStats = Value
    end
})

local AutoAddStatsToggle = Tabs.Main:CreateToggle("AutoAddStatsToggle", {Title = "Auto Add Stats", Description = "Automatically add selected stats", Default = false })
AutoAddStatsToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoAddStatsToggle.Value do
                for _, stat in ipairs(SelectStats) do
                    local Primary = "Primary_" .. stat
                    To_Server:FireServer({
                        Name = Primary,
                        Action = "Assign_Level_Stats",
                        Amount = AmountStats
                    })
                    task.wait(1)
                end
                task.wait(1)
            end
        end)
    end
end)

Tabs.Main:CreateButton{
    Title = "Reset Stats",
    Description = "reset all stats",
    Callback = function()
        Window:Dialog{
            Title = "WARNING!",
            Content = "This will reset all of your stats, confirm to continue",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        To_Server:FireServer({ Action = "Reset_Primary_Stats" })
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

Tabs.Main:AddSection("[⭐] Stars")

local SelectStar = "1"
local SelectStarDropdown = Tabs.Main:CreateDropdown("SelectStarDropdown", {
    Title = "Select Star",
    Values = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" },
    Multi = false,
    Default = nil,
})
SelectStarDropdown:OnChanged(function(Value)
    SelectStar = Value
end)

local AmountStar = 1
local SelectAmountStar = Tabs.Main:CreateSlider("SelectAmountStar", {
    Title = "Amount",
    Description = "",
    Default = AmountStar,
    Min = 1,
    Max = 10,
    Rounding = 0
})
SelectAmountStar:OnChanged(function(Value)
    AmountStar = Value
end)

local AutoOpenStarToggle = Tabs.Main:CreateToggle("AutoOpenStarToggle", {
    Title = "Auto Open Star",
    Description = "Automatically open star",
    Default = false
})

AutoOpenStarToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoOpenStarToggle.Value do
                local StarName = "Star_" .. tostring(SelectStar)
                To_Server:FireServer({
                    Open_Amount = AmountStar,
                    Action = "_Stars",
                    Name = StarName
                })
                task.wait(5)
            end
        end)
    end
end)


Tabs.Main:AddSection("[🎁] Rewards")

local AutoClaimTimeRewardsToggle = Tabs.Main:CreateToggle("AutoClaimRewardsToggle", {Title = "Auto Claim Time Rewards", Description = "Automatically collect time rewards", Default = false })
AutoClaimTimeRewardsToggle:OnChanged(function(Value)
    -- Time Rewards
    if Value then
        task.spawn(function()
            while AutoClaimTimeRewardsToggle.Value do
                To_Server:FireServer({Action = "_Hourly_Rewards",Id = "All"})
                task.wait(5)
            end
        end)
    end
end)

local AutoClaimDailyRewardsToggle = Tabs.Main:CreateToggle("AutoClaimDailyRewardsToggle", {Title = "Auto Claim Daily Rewards", Description = "Automatically collect daily rewards", Default = false })
AutoClaimDailyRewardsToggle:OnChanged(function(Value)
    -- Daily Rewards
    if Value then
        task.spawn(function()
            while AutoClaimDailyRewardsToggle.Value do
                To_Server:FireServer({Action = "_Daily_Rewards"})
                task.wait(5)
            end
        end)
    end
end)

Tabs.Main:AddSection("[👑] Gamepass")

local _gamepassHooked = false
Tabs.Main:CreateButton{
    Title = "FastClick, RemoteAccess",
    Description = "access gamepass without buying\nrequire high level executor",
    Callback = function()
        Window:Dialog{
            Title = "WARNING!",
            Content = "This will access gamepass FastClick, RemoteAccess, confirm to continue",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        if _gamepassHooked then return end
                        _gamepassHooked = true

                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local ok, Modules = pcall(function()
                            return require(ReplicatedStorage.Common.Shared_Data)
                        end)

                        if not ok or not Modules or type(Modules.Check_Gamepass) ~= "function" then
                            warn("Shared_Data.Check_Gamepass not available")
                            return
                        end

                        local original = Modules.Check_Gamepass
                        Modules.Check_Gamepass = function(data, passName, ...)
                            if tostring(passName) == "Fast_Clicker" or tostring(passName) == "Remote_Access" then
                                return true
                            end

                            local success, result = pcall(original, data, passName, ...)
                            if success then
                                return result
                            else
                                warn("Original Check_Gamepass error:", result)
                                return false
                            end
                        end
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Cancelled the dialog.")
                    end
                }
            }
        }
    end
}




SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes{}
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
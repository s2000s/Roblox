local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow{
    Title = "Arise Crossover ",
    SubTitle = "by zzyyeez",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
}

local Tabs = {
    Main = Window:CreateTab{
        Title = "Main",
        Icon = "chevrons-right"
    },
    Dungeon = Window:CreateTab{
        Title = "Dungeon",
        Icon = "swords"
    },
    Teleport = Window:CreateTab{
        Title = "Teleport",
        Icon = "map-pin"
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
local TeleportService = game:GetService("TeleportService")
local dataRemoteEvent = ReplicatedStorage.BridgeNet2:WaitForChild("dataRemoteEvent")

local Player = Players.LocalPlayer
if not Player then
    Player = Players.PlayerAdded:Wait()
end

local Char = Player.Character or Player.CharacterAdded:Wait()
local hrp = Char:WaitForChild("HumanoidRootPart")
local humanoid = Char:WaitForChild("Humanoid")

local Island = {
    "SoloWorld",
    "NarutoWorld",
    "OPWorld",
    "BleachWorld",
    "BCWorld",
    "ChainsawWorld",
    "JojoWorld",
    "DBWorld",
    "OPMWorld",
    "DanWorld",
    "Solo2World",
    "HxHWorld",
    "SlimeWorld",
    "JJKWorld",
    "DSWorld",
    "KaijuWorld",
    "AoTWorld"
}

local MobToCode = {
    -- 1
    Soondoo = "SL1",
    Gonshee = "SL2",
    Daek = "SL3",
    LongIn = "SL4",
    Anders = "SL5",
    Largalgan = "SL6",
    -- 2
    SnakeMan = "NR1",
    Blossom = "NR2",
    BlackCrow = "NR3",
    --3
    SharksMan = "OP1",
    Eminel = "OP2",
    LightAdmiral = "OP3",
    --4
    Luryu = "BL1",
    Fyakuya = "BL2",
    Genji = "BL3",
    --5
    Sortudo = "BC1",
    Michille = "BC2",
    Wind = "BC3",
    --6
    Heaven = "CH1",
    Zere = "CH2",
    Ika = "CH3",
    --7
    Diablo = "JB1",
    Gosuke = "JB2",
    Golyne = "JB3",
    --8
    Turtle = "DB1",
    Green = "DB2",
    Sky = "DB3",
    --9
    Rider = "OPM1",
    Cyborg = "OPM2",
    Hurricane = "OPM3",
    --10
    Mantis = "DAM1",
    Aira = "DAM2",
    Lomo = "DAM3",
    --11
    Wuiri = "NSL1",
    Gernnart = "NSL2",
    Chris = "NSL3",
    --12
    Gatou = "HxH1",
    Joker = "HxH2",
    Zeruem = "HxH3",
    --13
    OniPrincess = "Slime1",
    OniChef = "Slime2",
    OniKing = "Slime3",
    --14
    BigSister = "JK1",
    Megamem = "JK2",
    Banami = "JK3",
    --15
    Blosuke = "DS1",
    Benitsu = "DS2",
    Tangerina = "DS3",
    --16
    Remo = "Kaiju1",
    Coshiri = "Kaiju2",
    Kiboru = "Kaiju3",
    --17
    Arzin = "Aot1",
    Commander = "Aot2",
    Tukasa = "Aot3",
    --18
}

local SelectIslandsDropdown = Tabs.Main:CreateDropdown("SelectIslandsDropdown", {
    Title = "Select Island",
    Values = Island,
    Multi = false,
    Default = nil,
})

local IslandID
local EnemiesIsland = {}
local SelectMobs = {}
local SelectMobsDropdown = Tabs.Main:CreateDropdown("SelectMobsDropdown", {
    Title = "Select Mobs",
    Values = {},
    Multi = true,
    Default = {},
})

SelectIslandsDropdown:OnChanged(function(Value)
    if Value == "SoloWorld" then
        EnemiesIsland = { "Soondoo", "Gonshee", "Daek", "LongIn", "Anders", "Largalgan" }
        IslandID = 1

    elseif Value == "NarutoWorld" then
        EnemiesIsland = { "SnakeMan", "Blossom", "BlackCrow" }
        IslandID = 2

    elseif Value == "OPWorld" then
        EnemiesIsland = { "SharksMan", "Eminel", "LightAdmiral" }
        IslandID = 3

    elseif Value == "BleachWorld" then
        EnemiesIsland = { "Luryu", "Fyakuya", "Genji" }
        IslandID = 4

    elseif Value == "BCWorld" then
        EnemiesIsland = { "Sortudo", "Michille", "Wind" }
        IslandID = 5

    elseif Value == "ChainsawWorld" then
        EnemiesIsland = { "Heaven", "Zere", "Ika" }
        IslandID = 6

    elseif Value == "JojoWorld" then
        EnemiesIsland = { "Diablo", "Gosuke", "Golyne" }
        IslandID = 7

    elseif Value == "DBWorld" then
        EnemiesIsland = { "Turtle", "Green", "Sky" }
        IslandID = 8

    elseif Value == "OPMWorld" then
        EnemiesIsland = { "Rider", "Cyborg", "Hurricane" }
        IslandID = 9

    elseif Value == "DanWorld" then
        EnemiesIsland = { "Mantis", "Aira", "Lomo" }
        IslandID = 10

    elseif Value == "Solo2World" then
        EnemiesIsland = { "Wuiri", "Gernnart", "Chris" }
        IslandID = 11

    elseif Value == "HxHWorld" then
        EnemiesIsland = { "Gatou", "Joker", "Zeruem" }
        IslandID = 12

    elseif Value == "SlimeWorld" then
        EnemiesIsland = { "Oni Princess", "Oni Chef", "Oni King" }
        IslandID = 13

    elseif Value == "JJKWorld" then
        EnemiesIsland = { "Big Sister", "Megamem", "Banami" }
        IslandID = 14

    elseif Value == "DSWorld" then
        EnemiesIsland = { "Blosuke", "Benitsu", "Tangerina" }
        IslandID = 15

    elseif Value == "KaijuWorld" then
        EnemiesIsland = { "Remo", "Coshiri", "Kiboru" }
        IslandID = 16

    elseif Value == "AoTWorld" then
        EnemiesIsland = { "Arzin", "Commander", "Tukasa" }
        IslandID = 17
    end

    -- elseif Value == "" then
    --     EnemiesIsland = {  }

    SelectMobsDropdown:SetValues(EnemiesIsland)
    SelectMobs = {}
end)

SelectMobsDropdown:OnChanged(function(Value)
    local enemy = Value

    SelectMobs = {}
    for enemyName, isSelected in pairs(enemy) do
        if isSelected then
            local baseID = MobToCode[enemyName]
            
            if baseID then
                table.insert(SelectMobs, baseID)
            end
        end
    end
end)

local SelectSize = "Small"
local SelectSizeDropdown = Tabs.Main:CreateDropdown("SelectSizeDropdown", {
    Title = "Select Type",
    Values = { "Small", "Big" },
    Multi = false,
    Default = { "Small" },
})
SelectSizeDropdown:OnChanged(function(Value)
    SelectSize = Value
end)

local AutofarmToggle = Tabs.Main:CreateToggle("AutofarmToggle", {Title = "Auto Farm", Default = false })

local AutoFarm = false
local speed = 150
AutofarmToggle:OnChanged(function(Value)
    AutoFarm = Value

    if Value then
        task.spawn(function()
            while AutofarmToggle.Value do
                local ServerFolder = workspace.__Main.__Enemies.Server[tostring(IslandID)]
                if not ServerFolder then return end

                for _, mob in pairs(ServerFolder:GetChildren()) do
                    if not AutofarmToggle.Value then return end

                    local Model = mob:GetAttribute("Model")
                    local Type = mob:GetAttribute("Type")
                    local HP = mob:GetAttribute("HP")
                    local Scale = mob:GetAttribute("Scale")

                    local requiredScale = (SelectSize == "Small" and 1) or (SelectSize == "Big" and 2)

                    if Model and table.find(SelectMobs, Model) and HP and HP > 0 and Scale == requiredScale then
                        --print("กำลังไปหา:", Model)
                        local targetPos = mob.Position
                        local distance = (hrp.Position - targetPos).Magnitude
                        local travelTime = distance / speed


                        local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear)
                        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(mob.Position)})
                        tween:Play()
                        tween.Completed:Wait()

                        while mob and mob.Parent and mob:GetAttribute("HP") > 0 do
                            task.wait(0.01)
                        end

                        --print(Model .. " ตายแล้ว ไปตัวต่อไป")
                    else
                        --warn("Not Found Mob Model!")
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- Dungeon Tab
local FindDungeon = Tabs.Dungeon:CreateParagraph("FindDungeon", {
    Title = "Dungeon Information",
    Content = "STATUS: FINDING"
})

task.spawn(function()
    while true do
        local DungeonPathh = workspace.__Main.__Dungeon
        local text = ""

        for _, i in ipairs(DungeonPathh:GetChildren()) do
            local World = i:GetAttribute("World")
            local Dungeon = i:GetAttribute("Dungeon")
            local DungeonMap = i:GetAttribute("DungeonMap")
            local DungeonRank = i:GetAttribute("DungeonRank")
            local IsRedDungeon = i:GetAttribute("IsRedDungeon")

            text ..= string.format(
                "World: %s\nDungeon: %s\nMap: %s\nRank: %s\nRed: %s",
                tostring(World),
                tostring(Dungeon),
                tostring(DungeonMap),
                tostring(DungeonRank),
                tostring(IsRedDungeon)
            )
        end

        if text == "" then
            text = "STATUS: NOT FOUND"
        end

        FindDungeon:SetValue(text)
        task.wait(2)
    end
end)

local SelectIslandDungeon = {}
local SelectIslandDungeonDropdown = Tabs.Dungeon:CreateDropdown("SelectIslandDungeonDropdown", {
    Title = "Select Island",
    Values = Island,
    Multi = true,
    Default = {},
})
SelectIslandDungeonDropdown:OnChanged(function(Value)
    local Values = {}
    for Value, State in next, Value do
        Values[#Values + 1] = Value
    end

    SelectIslandDungeon = Values
end)

function leaveDungeon()
    local mainWorldPlaceId = 87039211657390
    local currentPlaceId = game.PlaceId

	if currentPlaceId ~= mainWorldPlaceId then
		TeleportService:Teleport(mainWorldPlaceId, LocalPlayer)
	else
		--warn("คุณอยู่ในโลกปกติอยู่แล้ว")
	end
end

function resetdungeon()
    dataRemoteEvent:FireServer({{ Type = "Gems", Event = "DungeonAction", Action = "BuyTicket" }, "\14" })
end

local FoundDungeon = false
local AutoDungeonToggle = Tabs.Dungeon:CreateToggle("AutoDungeonToggle", {Title = "Auto Dungeon", Default = false })
AutoDungeonToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoDungeonToggle.Value do
                local DungeonFolder = workspace.__Main.__Dungeon

                for _, Dungeonn in ipairs(DungeonFolder:GetChildren()) do
                    local Dungeon = Dungeonn:GetAttribute("Dungeon")
                    local Id = Dungeonn:GetAttribute("ID")

                    if Dungeon and SelectIslandDungeon and #SelectIslandDungeon > 0 then
                        for _, SelectIsland in ipairs(SelectIslandDungeon) do
                            if Dungeon == SelectIsland then
                                FoundDungeon = true
                                task.wait(1)
                                resetdungeon()
                                task.wait(1)
                                dataRemoteEvent:FireServer({{ Event = "DungeonAction", Action = "Create" }, "\14" })
                                dataRemoteEvent:FireServer({{ Dungeon = Player.UserId, Event = "DungeonAction", Action = "Start" }, "\14" })
                            end
                        end
                    end
                end
                task.wait(2)
            end
        end)
    end
end)

local DungeonAutofarm = Tabs.Dungeon:AddToggle("DungeonAutofarm", { Title = "Auto Farm", Default = false })
DungeonAutofarm:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while DungeonAutofarm.Value do
                local Char = Player.Character or Player.CharacterAdded:Wait()
                local hrp = Char:WaitForChild("HumanoidRootPart")

                local MobFolder = workspace.__Main.__Enemies.Server
                local closestMob = nil
                local shortestDistance = math.huge

                for _, mob in pairs(MobFolder:GetChildren()) do
                    local Model = mob:GetAttribute("Model")
                    local HP = mob:GetAttribute("HP")

                    if Model and HP > 0 then
                        local distance = (hrp.Position - mob.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestMob = mob
                        end
                    end
                end

                if closestMob then
                    local direction = (closestMob.Position - hrp.Position).Unit
                    local stopPos = closestMob.Position - (direction * 5)

                    hrp.CFrame = CFrame.new(stopPos)

                    repeat
                        local distance = (hrp.Position - stopPos).Magnitude
                        task.wait(0.05)
                    until distance <= 6 or not closestMob or closestMob:GetAttribute("HP") <= 0

                    while closestMob and closestMob:GetAttribute("HP") and closestMob:GetAttribute("HP") > 0 do
                        hrp.CFrame = CFrame.new(stopPos)
                        task.wait(0.01)
                    end

                    task.wait(0.7) -- หลังมอนตาย
                end

                task.wait(0.01)
            end
        end)
    end
end)








-- Teleport
Tabs.Teleport:CreateButton{
    Title = "Teleport To Guild Hall",
    Description = "",
    Callback = function()
        local MainPart = workspace.__Extra.GuildTPs:FindFirstChild("Main")
        if MainPart and MainPart:IsA("BasePart") then
            hrp.CFrame = MainPart.CFrame
        end
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
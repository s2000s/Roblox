local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow{
    Title = "The Forge 1.0.0",
    SubTitle = "",
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

-- In Game
local Camera = workspace.CurrentCamera
local ToolActivated = ReplicatedStorage.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated
local RunCommand = ReplicatedStorage.Shared.Packages.Knit.Services.DialogueService.RF.RunCommand
local Knit = require(game:GetService("ReplicatedStorage").Shared.Packages.Knit)
local PlayerController = Knit.GetController("PlayerController")
local rockpath = workspace.Rocks
local mobpath = workspace.Living

game:service("Players").LocalPlayer.Idled:connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    wait(2)
end)

Tabs.Main:CreateSection("Configs")

local TweenMode = "Normal"
local TweenModeDropdown = Tabs.Main:CreateDropdown("TweenModeDropdown", {
    Title = "Tween Mode",
    Values = { "Up", "Normal", "Down" },
    Multi = false,
    Default = "Normal",
})
TweenModeDropdown:OnChanged(function(Value)
    TweenMode = Value
end)

local TweenDistance = "5"
local TweenDistanceDropdown = Tabs.Main:CreateDropdown("TweenDistanceDropdown", {
    Title = "Tween Distance",
    Values = { "0.5", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11" },
    Multi = false,
    Default = "5",
})
TweenDistanceDropdown:OnChanged(function(Value)
    TweenDistance = Value
end)

local TweenSpeed = 30
local TweenSpeedSlider = Tabs.Main:CreateSlider("TweenSpeedSlider", {
    Title = "Tween Speed",
    Description = "",
    Default = TweenSpeed,
    Min = 10,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        TweenSpeed = Value
    end
})

Tabs.Main:CreateSection("Automation Mobs")
local Mobs = {
    "Zombie",
    "Elite Zombie",
    "Delver Zombie",
    "Brute Zombie",
    "Bomber",
    "Skeleton Rogue",
    "Axe Skeleton",
    "Deathaxe Skeleton",
    "Elite Rogue Skeleton",
    "Elite Deathaxe Skeleton",
    "Blight Pyromancer",
    "Reaper",
    "Slime",
    "Blazing Slime"
}

local SelectMobs = {}
local SelectMobsDropdown = Tabs.Main:CreateDropdown("SelectMobsDropdown", {
    Title = "Select Mobs",
    Values = Mobs,
    Multi = true,
    Default = {}
})
SelectMobsDropdown:OnChanged(function(Value)
    SelectMobs = {}

    for i in pairs(Options.SelectMobsDropdown.Value) do
        table.insert(SelectMobs, i)
    end
end)

local AutoAttackMobToggle = Tabs.Main:CreateToggle("AutoAttackMobToggle", {Title = "Auto Attack", Default = false })
local mobTween
local bvAttackMob = nil
AutoAttackMobToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoAttackMobToggle.Value do
                if not hrp or not humanoid or not hrp.Parent then 
                    task.wait(1) 
                    continue 
                end
                
                local targetMob = nil
                local minDistance = math.huge
                
                for _, i in ipairs(mobpath:GetChildren()) do
                    local isNpc = i:GetAttribute("IsNpc")
                    local mHrp = i:FindFirstChild("HumanoidRootPart")
                    local mHum = i:FindFirstChild("Humanoid")

                    if mHrp and mHum and mHum.Health > 0 and isNpc == true then
                        local info = mHrp:FindFirstChild("infoFrame")
                        local frame = info and info:FindFirstChild("Frame")
                        local nameLabel = frame and frame:FindFirstChild("rockName")

                        if nameLabel and table.find(SelectMobs, nameLabel.Text) then
                            local dist = (hrp.Position - mHrp.Position).Magnitude
                            if dist < minDistance then
                                minDistance = dist
                                targetMob = i
                            end
                        end
                    end
                end

                if targetMob then
                    local mHrp = targetMob.HumanoidRootPart
                    local mHum = targetMob.Humanoid
                    
                    repeat
                        if not AutoAttackMobToggle.Value or not hrp or not targetMob.Parent or mHum.Health <= 0 then break end

                        humanoid.PlatformStand = true

                        if not bvAttackMob then
                            bvAttackMob = Instance.new("BodyVelocity")
                            bvAttackMob.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            bvAttackMob.Velocity = Vector3.new(0, 0, 0)
                            bvAttackMob.Parent = hrp
                        end
                        local targetCF = GetTweenCFrame(mHrp)
                        local dist = (hrp.Position - targetCF.Position).Magnitude

                        mobTween = TweenService:Create(hrp, TweenInfo.new(dist / TweenSpeed, Enum.EasingStyle.Linear), {CFrame = targetCF})
                        mobTween:Play()

                        ToolActivated:InvokeServer("Weapon")
                        task.wait(0.1)
                    until not targetMob.Parent or mHum.Health <= 0 or not AutoAttackMobToggle.Value

                    if mobTween then mobTween:Cancel() end
                    if bvAttackMob then bvAttackMob:Destroy() bvAttackMob = nil end
                    humanoid.PlatformStand = false
                else
                    task.wait(0.5)
                end
                task.wait(0.1)
            end
        end)
    else
        if mobTween then mobTween:Cancel() end
        if bvAttackMob then bvAttackMob:Destroy() bvAttackMob = nil end
        if humanoid then humanoid.PlatformStand = false end
    end
end)

Tabs.Main:CreateSection("Automation Rocks")

local Rocks = {
    "Pebble",
    "Rock",
    "Boulder",
    "Basalt Rock",
    "Basalt Core",
    "Basalt Vein",
    "Volcanic Rock",
    "Earth Crystal",
    "Cyan Crystal",
    "Crimson Crystal",
    "Violet Crystal",
    "Light Crystal",
}

local Ores = {
    "Arcane Crystal","Blue Crystal","Crimson Crystal","Green Crystal","Magenta Crystal","Orange Crystal","Rainbow Crystal","Copper","Fichillium","Fichilliumorite","Galaxite",
    "Gold","Iron","Platinum","Sand Stone","Silver","Starite","Stone","Tin","Aite","Bananite","Cardboardite","Grass","Mushroomite","Poopite","Amethyst","Boneite","Cobalt","Cuprite",
    "Dark Boneite","Darkryte","Demonite","Diamond","Emerald","Eye Ore","Fireite","Lapis Lazuli","Lightite","Magmaite","Mythril","Obsidian","Quartz","Rivalite","Ruby","Sapphire",
    "Slimite", "Titanium", "Topaz", "Uranium", "Volcanic Rock"
}

local SelectRocks = {}
local SelectRocksDropdown = Tabs.Main:CreateDropdown("SelectRocksDropdown", {
    Title = "Select Rocks",
    Values = Rocks,
    Multi = true,
    Default = {},
})
SelectRocksDropdown:OnChanged(function(Value)
    SelectRocks = {}

    for i in pairs(Options.SelectRocksDropdown.Value) do
        table.insert(SelectRocks, i)
    end
end)

local SelectOres = {}
local SelectOresDropdown = Tabs.Main:CreateDropdown("SelectOresDropdown", {
    Title = "Select Ores",
    Values = Ores,
    Multi = true,
    Default = {},
})
SelectOresDropdown:OnChanged(function(Value)
    SelectOres = {}

    for i in pairs(Options.SelectOresDropdown.Value) do
        table.insert(SelectOres, i)
    end
end)

local AutoPickaxeRockToggle = Tabs.Main:CreateToggle("AutoPickaxeRockToggle", {Title = "Auto Pickaxe Rock", Default = false })
local tweenrock

function GetTweenCFrame(targetPart)
    if not hrp or not targetPart then return nil end
    
    local distance = tonumber(TweenDistance) or 5
    local targett = targetPart.Position

    local offset = Vector3.zero

    if TweenMode == "Up" then
        local Height = targetPart.Size.Y / 2
        offset = Vector3.new(0, Height + distance, 0)
    elseif TweenMode == "Down" then
        offset = Vector3.new(0, -distance, 0)
    elseif TweenMode == "Normal" then
        local dir = (hrp.Position - targett).Unit
        offset = dir * distance
    end

    local finalPos = targett + offset

    return CFrame.lookAt(finalPos, targett)
end

local function GetClosestRock(char)
    local closestRock = nil
    local minDistance = math.huge

    for _, rockpathh in ipairs(rockpath:GetChildren()) do
        for _, spawnlocation in ipairs(rockpathh:GetChildren()) do
            for _, rock in ipairs(spawnlocation:GetChildren()) do
                if rock and rock:IsA("Model") and rock:FindFirstChild("Hitbox") then
                    
                    if table.find(SelectRocks, rock.Name) then

                        local LastHit = rock:GetAttribute("LastHitPlayer")
                        local Hp = rock:GetAttribute("Health")
                        local MaxHp = rock:GetAttribute("MaxHealth")

                        local isOwnerValid = (LastHit == Player.Name or LastHit == nil)
                        local isFullHealth = (Hp and MaxHp and Hp == MaxHp)

                        if isOwnerValid and isFullHealth then
                            local dist = (hrp.Position - rock.Hitbox.Position).Magnitude
                            if dist < minDistance then
                                minDistance = dist
                                closestRock = rock
                            end
                        end
                    end
                end
            end
        end
    end
    return closestRock
end

local bvpickaxe = nil
AutoPickaxeRockToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoPickaxeRockToggle.Value do
                if not hrp or not humanoid then 
                    task.wait(1) 
                    continue 
                end
                local rock = GetClosestRock(char)
                if rock then
                    repeat
                        if not AutoPickaxeRockToggle.Value or not hrp or not humanoid then break end

                        local Hp = rock:GetAttribute("Health")
                        if not Hp or Hp <= 0 then break end

                        humanoid.PlatformStand = true

                        if not bvpickaxe and hrp then
                            bvpickaxe = Instance.new("BodyVelocity")
                            bvpickaxe.MaxForce = Vector3.new(0, math.huge, 0)
                            bvpickaxe.Velocity = Vector3.new(0, 0, 0)
                            bvpickaxe.Parent = hrp
                        end

                        local target = rock.Hitbox
                        local targetCF = GetTweenCFrame(target)
                        
                        local distance = (hrp.Position - targetCF.Position).Magnitude

                        tweenrock = TweenService:Create(hrp, TweenInfo.new(distance / TweenSpeed, Enum.EasingStyle.Linear), { CFrame = targetCF })
                        tweenrock:Play()

                        ToolActivated:InvokeServer("Pickaxe")

                        local hasAnyOre = false
                        local foundAllowedOre = false
                        if #SelectOres > 0 then
                            for _, ore in ipairs(rock:GetChildren()) do
                                if ore:IsA("Model") then
                                    local oreName = ore:GetAttribute("Ore")
                                    if oreName then
                                        hasAnyOre = true
                                        if table.find(SelectOres, oreName) then
                                            foundAllowedOre = true
                                            break
                                        end
                                    end
                                end
                            end
                            if hasAnyOre and not foundAllowedOre then
                                break
                            end
                        end
                        task.wait(0.1)
                    until not rock or not rock.Parent or rock:GetAttribute("Health") <= 0
                    if tweenrock then tweenrock:Cancel() end
                    if bvpickaxe then bvpickaxe:Destroy() bvpickaxe = nil end
                    if humanoid then humanoid.PlatformStand = false end
                else
                    task.wait(0.5)
                end
                task.wait(0.1)
            end
        end)
    else
        if tweenrock then tweenrock:Cancel() end
        if bvpickaxe then bvpickaxe:Destroy() bvpickaxe = nil end
        if humanoid then humanoid.PlatformStand = false end
    end
end)

local collisionHistory = {}
RunService.Stepped:Connect(function()
    if AutoPickaxeRockToggle.Value or AutoAttackMobToggle.Value then
        if humanoid.Health <= 0 then
            if tweenrock then tweenrock:Cancel() end
            if bvpickaxe then bvpickaxe:Destroy() bvpickaxe = nil end
            if humanoid then humanoid.PlatformStand = false end

            if mobTween then mobTween:Cancel() end
            if bvAttackMob then bvAttackMob:Destroy() bvAttackMob = nil end
            if humanoid then humanoid.PlatformStand = false end
        end

        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if collisionHistory[part] == nil then
                    collisionHistory[part] = part.CanCollide
                end

                part.CanCollide = false
            end
        end
    else
        if next(collisionHistory) ~= nil then
            for part, originalValue in pairs(collisionHistory) do
                if part and part.Parent then
                    part.CanCollide = originalValue
                end
            end
            collisionHistory = {}
        end
    end
end)

Tabs.Main:CreateSection("Inventory")

local SelectRocksSell = {}
local SelectOresSellDropdown = Tabs.Main:CreateDropdown("SelectOresSellDropdown", {
    Title = "Select Ores",
    Values = Ores,
    Multi = true,
    Default = {},
})
SelectOresSellDropdown:OnChanged(function()
    SelectRocksSell = {}
    local selected = Options.SelectOresSellDropdown.Value
    for name, state in pairs(selected) do
        if state then
            table.insert(SelectRocksSell, name)
        end
    end
    -- print("Selected to sell:", table.concat(SelectRocksSell, ", "))
end)

local AutoSellToggle = Tabs.Main:CreateToggle("AutoSellToggle", {Title = "Auto Sell", Description = "only sell if stash max", Default = false })
AutoSellToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoSellToggle.Value do
                local Replica = PlayerController.Replica
                local Data = Replica and Replica.Data
                
                if Data and Data.Inventory then
                    local Inventory = Data.Inventory
                    
                    local currentTotal = 0
                    for key, val in pairs(Inventory) do
                        if key == "Misc" and type(val) == "table" then
                            -- นับพวก Rune/Potion ใน Misc
                            for _, item in pairs(val) do
                                currentTotal = currentTotal + (item.Quantity or 1)
                            end
                        elseif type(val) == "number" then
                            currentTotal = currentTotal + val
                        end
                    end

                    local maxCap = 100 + ((Data.Level or 0) * 2)
                    if Data.Gamepasses and Data.Gamepasses.DoubleStorage then 
                        maxCap = maxCap * 2 
                    end

                    -- Debug ดูค่า (เช็คใน F9 ว่าตรงกับหน้าจอไหม)
                    -- print(string.format("[Stash Check] %d/%d", currentTotal, maxCap))

                    -- 3. ถ้าของเต็ม ให้เริ่มกระบวนการขาย
                    if currentTotal >= maxCap then
                        local basket = {}
                        local foundToSell = false

                        -- วนลูปเฉพาะแร่ที่เราเลือกไว้ใน SelectRocksSell
                        for _, oreName in pairs(SelectRocksSell) do
                            local amount = Inventory[oreName]
                            if amount and type(amount) == "number" and amount > 0 then
                                basket[oreName] = amount
                                foundToSell = true
                            end
                        end

                        -- ส่งขายเฉพาะถ้ามีแร่ที่เราเลือกอยู่ในกระเป๋า
                        if foundToSell then
                            RunCommand:InvokeServer("SellConfirm", { 
                                Basket = basket 
                            })
                            -- print("Inventory full! Sold selected ores.")
                        else
                            -- print("Inventory full, but no selected ores to sell.")
                        end
                    end
                end
                
                task.wait(5)
            end
        end)
    end
end)

-- Potion
-- 1.LuckPotion1 2.MovementSpeedPotion1 3.AttackDamagePotion1 4.HealthPotion2 5.MinerPotion1

Tabs.Main:CreateSection("Visuals")

local SelectRocksEspDropdown = Tabs.Main:CreateDropdown("SelectRocksEspDropdown", {
    Title = "Select Rocks",
    Values = Rocks,
    Multi = true,
    Default = {},
})
SelectRocksEspDropdown:OnChanged(function(Value)
    SelectRocksEsp = {}

    for i in pairs(Options.SelectRocksEspDropdown.Value) do
        table.insert(SelectRocksEsp, i)
    end
end)

local EspObjects = {}
local EspRock = Tabs.Main:CreateToggle("EspRock", {Title = "Esp Rock", Default = false })
EspRock:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while EspRock.Value do
                for _, rockpathh in ipairs(rockpath:GetChildren()) do
                    for _, spawnlocation in ipairs(rockpathh:GetChildren()) do
                        for _, rock in ipairs(spawnlocation:GetChildren()) do
                            local hprock = rock:GetAttribute("Health")

                            if hprock and table.find(SelectRocksEsp, rock.Name) and not EspObjects[rock] then
                                local billboard = Instance.new("BillboardGui")
                                billboard.Size = UDim2.new(0, 100, 0, 50)
                                billboard.Adornee = rock
                                billboard.AlwaysOnTop = true
                                billboard.StudsOffset = Vector3.new(0, 4, 0)

                                local highlight = Instance.new("Highlight")
                                highlight.Adornee = rock

                                highlight.FillColor = Color3.fromRGB(255, 215, 0)
                                highlight.FillTransparency = 0.8
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                                highlight.OutlineTransparency = 0.5
                                highlight.Parent = rock

                                EspObjects[rock] = {Billboard = billboard, Highlight = highlight}
                            end
                        end
                    end
                end
                task.wait(3)
            end
        end)
    else
        for rock, objects in pairs(EspObjects) do
            if objects.Billboard and objects.Billboard.Parent then
                objects.Billboard:Destroy()
            end
            if objects.Highlight and objects.Highlight.Parent then
                objects.Highlight:Destroy()
            end
        end
        EspObjects = {}
    end
end)


local EspOre = Tabs.Main:CreateToggle("EspOre", {Title = "Esp Ores", Default = false })
EspOre:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while EspOre.Value do
                for _, rockpathh in ipairs(rockpath:GetChildren()) do
                    for _, spawnlocation in ipairs(rockpathh:GetChildren()) do
                        for _, rock in ipairs(spawnlocation:GetChildren()) do
                            local hprock = rock:GetAttribute("Health")
                            if not hprock or hprock == 0 then
                                for _, Ore in ipairs(rock:GetChildren()) do
                                    if Ore:IsA("Model") then
                                        local bb = Ore:FindFirstChild("OreBillboard")
                                        if bb then bb:Destroy() end

                                        local hl = Ore:FindFirstChild("OreHighlight")
                                        if hl then hl:Destroy() end
                                    end
                                end
                            else
                                for _, Ore in ipairs(rock:GetChildren()) do
                                    if Ore:IsA("Model") and Ore:GetAttribute("Ore") then
                                        if not Ore:FindFirstChild("OreBillboard") then
                                            local oreName = Ore:GetAttribute("Ore")
                                            local part = Ore.PrimaryPart or Ore:FindFirstChildWhichIsA("BasePart")
                                            if part then
                                                local hl = Instance.new("Highlight")
                                                hl.Name = "OreHighlight"
                                                hl.Adornee = Ore

                                                hl.FillColor = Color3.fromRGB(108, 39, 245)
                                                hl.FillTransparency = 0.4

                                                hl.OutlineColor = Color3.fromRGB(108, 39, 245)
                                                hl.Parent = Ore

                                                local gui = Instance.new("BillboardGui")
                                                gui.Name = "OreBillboard"
                                                gui.Adornee = part
                                                gui.Size = UDim2.fromScale(4, 1)
                                                gui.StudsOffset = Vector3.new(0, 2.5, 0)
                                                gui.AlwaysOnTop = true
                                                gui.Parent = Ore

                                                local txt = Instance.new("TextLabel")
                                                txt.Size = UDim2.fromScale(1, 1)
                                                txt.BackgroundTransparency = 1
                                                txt.Text = tostring(oreName)
                                                txt.TextColor3 = Color3.fromRGB(73, 39, 245)
                                                txt.Font = Enum.Font.GothamMedium
                                                txt.TextSize = 20
                                                txt.TextXAlignment = Enum.TextXAlignment.Center
                                                txt.TextYAlignment = Enum.TextYAlignment.Center
                                                txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                                txt.TextStrokeTransparency = 0.4
                                                txt.Parent = gui
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    else
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BillboardGui") and v.Name == "OreBillboard" then
                v:Destroy()
            elseif v:IsA("Highlight") and v.Name == "OreHighlight" then
                v:Destroy()
            end
        end
    end
end)

SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes{}
InterfaceManager:SetFolder("fzlmm_xz")
SaveManager:SetFolder("fzlmm_xz/The Forge")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
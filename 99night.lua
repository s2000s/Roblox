local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://pastebin.com/raw/P8e3Cs0p"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "",
	Footer = "99 Night in the Forest - 1.0.0",
    Icon = 81226751496660,
    IconSize = UDim2.fromOffset(51, 46),
    Size = UDim2.fromOffset(600, 600), -- กว้าง,ยาว
	NotifySide = "Right",
	ShowCustomCursor = false,
    DisableSearch = false,
    Center = true,
    MobileButtonSide = "Left",
})

Window:SetSidebarWidth(0)

local Tabs = { 
    Main = Window:AddTab("Main", "chevrons-left-right", "" ),
    Visual = Window:AddTab("Visual", "fullscreen", ""),
    Player = Window:AddTab("Player", "user", ""),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
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

local old; old = hookfunction(Player.Kick, newcclosure(function(Self, ...)
if Self == Player then
    return
end
return old(Self, ...)
end))

-- local LeftGroupboxMainStronghold = Tabs.Main:AddLeftGroupbox("Stronghold", "axe")
-- local StrongholdTimer = LeftGroupboxMainStronghold:AddLabel("Starting in: N/A", true)

-- coroutine.wrap(function()
--     local lastTimerText = nil
    
--     while true do
--         local label = getStrongholdTimerLabel()
--         local timerValue = label and label.ContentText or "N/A"

--         local newText = "Starting in: " .. tostring(timerValue)

--         if newText ~= lastTimerText then
--             StrongholdTimer:SetText(newText)
--             lastTimerText = newText
--         end

--         task.wait(0.5)
--     end
-- end)()

local LeftGroupboxMainAutomation = Tabs.Main:AddLeftGroupbox("Automation", "repeat")

local TreeAuraToggle = false
local radiustreeaura = 100

local SelectedFood = {}
local AutoConsumeVar = false
local AutoConsumeThreshold = 50

local BurnFuel = false
local BurnThreshold = 50 -- %

-- function

local ChopTreeDamageIDs = {
    ["Old Axe"] = "28_1207046869",
    ["Good Axe"] = "72_1207046869",
    ["Strong Axe"] = "116_1207046869",
    ["Chainsaw"] = "647_1207046869"
}

function ChopTreeGetDamageID()
    for toolName, damageID in pairs(ChopTreeDamageIDs) do
        local tool = Player.Inventory:FindFirstChild(toolName)
        if tool then
            return tool, damageID
        end
    end
    return nil,
    nil
end

function getAllSmallTrees()
    local trees = {}

    local function scan(folder)
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") and (
                obj.Name == "Small Tree" or
                obj.Name == "Small Webbed Tree"
            ) then
                table.insert(trees, obj)
            end
        end
    end

    local map = workspace:FindFirstChild("Map")
    if map then
        if map:FindFirstChild("Foliage") then scan(map.Foliage) end
        if map:FindFirstChild("Landmarks") then scan(map.Landmarks) end
    end

    return trees
end



function ChopTreesfunc()
    task.spawn(function()
        while TreeAuraToggle do
            local Char = Player.Character
            local hrp = Char and Char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local tool, damageID = ChopTreeGetDamageID()
                if tool and damageID then
                    for _, tree in ipairs(getAllSmallTrees()) do
                        if not TreeAuraToggle then break end
                        local mainPart = tree.PrimaryPart or tree:FindFirstChildWhichIsA("BasePart")
                        if mainPart then
                            local distance = (mainPart.Position - hrp.Position).Magnitude
                            if distance <= radiustreeaura then
                                RemoteEvents.ToolDamageObject:InvokeServer(tree, tool, damageID, hrp.CFrame)
                            end
                        end
                    end
                else
                    task.wait(1)
                end
            end
            task.wait(0.1)
        end
    end)
end


local AutoRescueKids = LeftGroupboxMainAutomation:AddToggle("AutoRescueKids", {
    Text = "Auto Rescue",
    Default = false,
})

AutoRescueKids:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            local RequestBagStoreItem = ReplicatedStorage.RemoteEvents:WaitForChild("RequestBagStoreItem")

            local kids = {"Lost Child", "Lost Child2", "Lost Child3", "Lost Child4"}
            local Sacks = {"Giant Sack", "Good Sack", "Old Sack"}

            while AutoRescueKids.Value do
                local Inventory = Player.Inventory:GetChildren()
                local PathCharacters = workspace:WaitForChild("Characters")

                for _, kidName in ipairs(kids) do
                    if not AutoRescueKids.Value then break end

                    local child = PathCharacters:FindFirstChild(kidName)
                    if child and child:FindFirstChild("HumanoidRootPart") then
                        local Lost = child:GetAttribute("Lost")
                        if Lost then
                            local SackToUse = nil

                            for _, sackName in ipairs(Sacks) do
                                for _, item in ipairs(Inventory) do
                                    if item.Name == sackName then
                                        SackToUse = item
                                        break
                                    end
                                end
                                if SackToUse then break end
                            end

                            if SackToUse then
                                hrp.CFrame = child.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)

                                Library:Notify({
                                    Title = "Teleport",
                                    Description = "Found and Teleported to: " .. kidName,
                                    Time = 3
                                })

                                task.wait(0.5)
                                RequestBagStoreItem:InvokeServer(SackToUse, child)
                                task.wait(0.5)

                                hrp.CFrame = CFrame.new(Vector3.new(0, 10, 0))

                                repeat
                                    task.wait(2)
                                until not AutoRescueKids.Value or child:GetAttribute("Lost") == false
                            else
                                Library:Notify({
                                    Title = "Warning",
                                    Description = "No Sack found in inventory!",
                                    Time = 3
                                })
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end)



local TreeAura = LeftGroupboxMainAutomation:AddToggle("TreeAura", {
    Text = "Auto Chop",
    Default = false,
    Disabled = false,
    Visible = true,
    Callback = function(Value)
        TreeAuraToggle = Value
        if Value then
            task.spawn(ChopTreesfunc)
        end
    end,
})

-- local RadiusTree = LeftGroupboxMainAutomation:AddSlider("RadiusTree", {
--     Text = "Radius",
--     Default = 200,
--     Min = 1,
--     Max = 1000,
--     Rounding = 0,
--     Compact = false,
--     Visible = false,
--     Callback = function(Value)
--         radiustreeaura = Value
--     end,
-- })

-- TreeAura:OnChanged(function(Value)
--     RadiusTree:SetVisible(Value)
-- end)

local AutoBurnFuel = LeftGroupboxMainAutomation:AddToggle("AutoBurnFuel", {
    Text = "Auto Burn Fuel",
    Default = false,
})

local NotificationProgress6 = false

AutoBurnFuel:OnChanged(function(Value)
    BurnFuel = Value

    local campfire = workspace.Map.Campground.MainFire:FindFirstChild("Center")
    local offset = CFrame.new(0, 15, 0)
    local targetNames = { "Coal", "Fuel Canister", "Oil Barrel" }

    if Value then
        task.spawn(function()
            while BurnFuel do
                local Items = workspace.Items:GetChildren()
                
                for _, item in ipairs(Items) do
                    for _, name in ipairs(targetNames) do
                        if not BurnFuel then return end

                        if item.Name == name and item:IsA("Model") and item.PrimaryPart then
                            local Progress = workspace:GetAttribute("Progress")

                            if Progress == 6 and not NotificationProgress6 then
                                NotificationProgress6 = true
                                Library:Notify("Your Campfire Already Max Now!", 4)
                                BurnFuel = false
                            else
                                RemoteEvents.RequestStartDraggingItem:FireServer(item)
                                task.wait(0.05)
                                item:SetPrimaryPartCFrame(campfire.CFrame * offset)
                                RemoteEvents.StopDraggingItem:FireServer(item)
                                task.wait(0.5)
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

local AutoOpenChest = LeftGroupboxMainAutomation:AddToggle("AutoOpenChest", {
    Text = "Auto Open Chest",
    Default = false
})

AutoOpenChest:OnChanged(function(Value)
    local RequestOpenItemChest = ReplicatedStorage.RemoteEvents:WaitForChild("RequestOpenItemChest")
    local ListChest = { "Item Chest", "Item Chest2", "Item Chest3", "Item Chest4", "Item Chest5", "Item Chest6" }

    if Value then
        task.spawn(function()
            while AutoOpenChest.Value do
                for _, Chest in ipairs(workspace.Items:GetChildren()) do
                    if not AutoOpenChest.Value then break end

                    if table.find(ListChest, Chest.Name) then
                        local opened = Chest:GetAttribute("LocalOpened")
                        if opened == nil or opened == false then

                            if Chest.PrimaryPart then
                                hrp.CFrame = Chest.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
                                task.wait(0.2)
                                RequestOpenItemChest:FireServer(Chest)
                                task.wait(0.5)
                                
                                local targetPos = Vector3.new(0, 10, 0)
                                hrp.CFrame = CFrame.new(targetPos)
                                task.wait(0.2)
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)


local LeftGroupBoxMainConsume = Tabs.Main:AddLeftGroupbox("Consume", "beef")

local SelectFoodsDropdown = LeftGroupBoxMainConsume:AddDropdown("SelectFoodsDropdown", {
    Text = "<font color='#FF0000'>*</font> Select Foods",
    Values = { "Carrot", "Cake", "Pumpkin", "Cooked Morsel", "Cooked Steak", "Stew" },
    Default = {},
    Multi = true,
    Visible = true,
})

SelectFoodsDropdown:OnChanged(function(Value)
    SelectedFood = {}

    for i in pairs(Options.SelectFoodsDropdown.Value) do
        table.insert(SelectedFood, i)
    end
end)

local AutoConsumeToggle = LeftGroupBoxMainConsume:AddToggle("AutoConsumeToggle", {
    Text = "Auto Consume",
    Default = false,
})

AutoConsumeToggle:OnChanged(function(Value)
    AutoConsumeVar = Value

    local hungerBar = Player:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("StatBars"):WaitForChild("HungerBar"):WaitForChild("Bar")
    local RequestConsumeItem = ReplicatedStorage.RemoteEvents.RequestConsumeItem 
    task.spawn(function()
        while AutoConsumeVar do
            if AutoConsumeVar then
                if hungerBar.Size.X.Scale <= 0.5 then
                    repeat
                        local currentHunger = hungerBar.Size.X.Scale

                        local available = {}
                        for _, item in ipairs(workspace.Items:GetChildren()) do
                            if item.Name and table.find(SelectedFood, item.Name) then
                                table.insert(available, item)
                            end
                        end

                        if #available > 0 then
                            local food = available[math.random(1, #available)]
                            if food then
                                pcall(function()
                                    RequestConsumeItem:InvokeServer(food)
                                end)
                            end
                        else
                            --Library:Notify("not found any food!", 2)
                            break
                        end

                        task.wait(1)

                    until hungerBar.Size.X.Scale >= 0.99 or not AutoConsumeVar
                end
            end
            task.wait(1)
        end
    end)
end)


local LeftGroupBoxMainKillAura = Tabs.Main:AddLeftGroupbox("Kill Aura", "swords")

local KillAuraToggle = false
local radiuskillaura = 100
-- Function Main
local toolsDamageIDs = {
    ["Old Axe"] = "1_1207046869",
    ["Good Axe"] = "2_1207046869",
    ["Strong Axe"] = "3_1207046869",
    ["Chainsaw"] = "4_1207046869",
    ["Spear"] = "5_1207046869",
    ["Morningstar"] = "6_1207046869",
    ["Obsidiron Hammer"] = "121_1207046869",
    ["Laser Sword"] = "123_1207046869",
    ["Scythe"] = "13_1207046869",
}

function getToolAuraDamageID()
    local success, result1, result2 = pcall(function()
        local char = workspace:FindFirstChild(Player.Name)
        if not char then return nil, nil end

        local handle = char:FindFirstChild("ToolHandle")
        if not handle then return nil, nil end

        local original = handle:FindFirstChild("OriginalItem")
        if not original or not original.Value then return nil, nil end

        local toolInstance = original.Value
        local toolName = toolInstance.Name
        local damageID = toolsDamageIDs[toolName]

        if damageID then
            return toolInstance, damageID
        end
        return nil, nil
    end)

    if success then
        return result1, result2
    end
    return nil, nil
end

function killAuraLoop()
    task.spawn(function()
        while KillAuraToggle do
            local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local tool, damageID = getToolAuraDamageID()
                if tool and damageID then
                    for _, mob in ipairs(workspace.Characters:GetChildren()) do
                        if not KillAuraToggle then break end

                        local part = mob:FindFirstChildWhichIsA("BasePart")
                        if part and (part.Position - hrp.Position).Magnitude <= radiuskillaura then
                            pcall(function()
                                RemoteEvents.ToolDamageObject:InvokeServer(mob, tool, damageID, hrp.CFrame)
                            end)
                        end
                    end
                else
                    task.wait(1) -- not found weapon
                end
            else
                task.wait(0.5) -- not found hrp
            end
            task.wait(0.1)
        end
    end)
end


local KillAura = LeftGroupBoxMainKillAura:AddToggle("KillAura", {
     Text = "Kill Aura",
     Default = false,
     Disabled = false,
     Visible = true,
     Callback = function(Value)
        KillAuraToggle = Value
        if Value then
            task.spawn(killAuraLoop)
        end
    end,
})

LeftGroupBoxMainKillAura:AddDivider()

local SelectMobHitbox = {}

local SelectMobHitboxDropdown = LeftGroupBoxMainKillAura:AddDropdown("SelectMobHitboxDropdown", {
    Text = "<font color='#FF0000'>*</font> Select Mobs",
    Values = { "Bunny", "Wolf", "Bear", "Cultist", "Crossbow Cultist" },
    Multi = true,
    Default = {},
})

SelectMobHitboxDropdown:OnChanged(function(Value)
    SelectMobHitbox = {}

    for i in pairs(Options.SelectMobHitboxDropdown.Value) do 
        table.insert(SelectMobHitbox, i) 
    end
end)

local ExtendedHitbox = LeftGroupBoxMainKillAura:AddToggle("ExtendedHitbox", { Text = "Extended Hitbox",Default = false })

local HitboxSize = 10

function createHitbox(mob)
    local root = mob:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if mob:FindFirstChild("Hitbox") then return end

    local hitbox = Instance.new("Part")
    hitbox.Name = "Hitbox"
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
    hitbox.Color = Color3.fromRGB(255, 0, 0)
    hitbox.Transparency = 0.5
    hitbox.Anchored = false
    hitbox.CanCollide = false
    hitbox.Massless = true
    hitbox.Material = Enum.Material.SmoothPlastic
    hitbox.Parent = mob
    hitbox.CFrame = root.CFrame

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = hitbox
    weld.Parent = hitbox
end

ExtendedHitbox:OnChanged(function(Value)
    if Value then
        for _, mob in ipairs(workspace.Characters:GetChildren()) do
            if table.find(SelectMobHitbox, mob.Name) then
                createHitbox(mob)
            end
        end
    else
        for _, mob in ipairs(workspace.Characters:GetChildren()) do
            local hitbox = mob:FindFirstChild("Hitbox")
            if hitbox then
                hitbox:Destroy()
            end
        end

        for _, mobs in ipairs(workspace.Items:GetChildren()) do
            local hitboxx = mobs:FindFirstChild("Hitbox")
            if hitboxx then
                hitboxx:Destroy()
            end
        end
    end
end)

local HitboxSizeSlider = LeftGroupBoxMainKillAura:AddSlider("HitboxSizeSlider", {
    Text = "Size",
    Default = HitboxSize,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Compact = false,
    Visible = true,

    Callback = function(Value)
        HitboxSize = Value

        for _, mob in ipairs(workspace.Characters:GetChildren()) do
            local hitbox = mob:FindFirstChild("Hitbox")
            if hitbox then
                hitbox.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
            end
        end
    end,
})

-- local RadiusKillAura = LeftGroupBoxMainKillAura:AddSlider("RadiusKillAura", {
--      Text = "Radius (studs)",
--      Default = 200,
--      Min = 100,
--      Max = 500,
--      Rounding = 0,
--      Compact = false,
--      Visible = false,

--      Callback = function(Value)
--         radiuskillaura = Value
--     end,
-- })

-- KillAura:OnChanged(function(Value)
--     RadiusKillAura:SetVisible(Value)
-- end)

local LeftGroupBoxMainCraftingBench = Tabs.Main:AddLeftGroupbox("Crafting Bench", "anvil")

local InputLogVar = false
local InputScrapVar = false

local AutoInputLogToggle = LeftGroupBoxMainCraftingBench:AddToggle("AutoInputLogToggle", {
    Text = "Auto Input Log",
    Default = false,
})

AutoInputLogToggle:OnChanged(function(Value)
    InputLogVar = Value

    local CraftingBench = workspace.Map.Campground.Scrapper:FindFirstChild("DashedLine")
    local offset = CFrame.new(0, 15, 0)

    local targetNames = { "Log" }
    task.spawn(function()
        while InputLogVar do
            local Items = workspace.Items:GetChildren()
            for _, item in ipairs(Items) do
                if not InputLogVar then return end
                for _, name in ipairs(targetNames) do
                    if item.Name == name then
                        if item:IsA("Model") and item.PrimaryPart then
                            RemoteEvents.RequestStartDraggingItem:FireServer(item)
                            item:SetPrimaryPartCFrame(CraftingBench.CFrame * offset)
                            RemoteEvents.StopDraggingItem:FireServer(item)
                            task.wait(0.1)
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end)

local AutoInputScrapToggle = LeftGroupBoxMainCraftingBench:AddToggle("AutoInputScrapToggle", {
    Text = "Auto Input Scrap",
    Default = false,
})

AutoInputScrapToggle:OnChanged(function(Value)
    InputScrapVar = Value

    local CraftingBench = workspace.Map.Campground.Scrapper:FindFirstChild("DashedLine")
    local offset = CFrame.new(0, 15, 0)

    local targetNames = { "Sheet Metal", "Broken Fan", "Bolt", "Broken Microwave", "Tyre", "Old Radio", "Washing Machine", "Old Car Engine" }
    task.spawn(function()
        while InputScrapVar do
            local Items = workspace.Items:GetChildren()
            for _, item in ipairs(Items) do
                if not InputScrapVar then return end
                for _, name in ipairs(targetNames) do
                    if item.Name == name then
                        if item:IsA("Model") and item.PrimaryPart then
                            RemoteEvents.RequestStartDraggingItem:FireServer(item)
                            item:SetPrimaryPartCFrame(CraftingBench.CFrame * offset)
                            RemoteEvents.StopDraggingItem:FireServer(item)
                            task.wait(0.1)
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end)

local LeftGroupboxMainCollect = Tabs.Main:AddLeftGroupbox("Collect", "")

local SelectObject = {}
local AutoCollect = false

local SelectCollectDropdown = LeftGroupboxMainCollect:AddDropdown("SelectCollectDropdown", {
    Text = "<font color='#FF0000'>*</font> Select Object",
    Values = { "Coin Stack", "Flower"},
    Default = {},
    Multi = true,
    Visible = true,
})
SelectCollectDropdown:OnChanged(function(Value)
    SelectObject = {}

    for i in pairs(Options.SelectCollectDropdown.Value) do 
        table.insert(SelectObject, i) 
    end
end)

local AutoCollectToggle = LeftGroupboxMainCollect:AddToggle("AutoCollectToggle", {
    Text = "Auto Collect",
    Default = false,
})

AutoCollectToggle:OnChanged(function(Value)
    AutoCollect = Value

    if AutoCollect then
        task.spawn(function()
            while AutoCollect do
                local RequestPickFlower = ReplicatedStorage.RemoteEvents.RequestPickFlower
                local Path = workspace.Map.Landmarks

                for _, Object in ipairs(Path:GetChildren()) do
                    if not AutoCollect then
                        local targetPos = Vector3.new(0, 10, 0)
                        hrp.CFrame = CFrame.new(targetPos)
                        return
                    end
                    if table.find(SelectObject, Object.Name) and Object.PrimaryPart then
                        hrp.CFrame = CFrame.new(Object.PrimaryPart.Position + Vector3.new(0, 1, 0))
                        task.wait(0.2)
                        RequestPickFlower:InvokeServer( Object )
                        task.wait(0.2)
                    end
                end
                hrp.CFrame = CFrame.new(Vector3.new(0, 10, 0))
                task.wait(0.5)
            end
        end)
    end
end)

local RightGroupboxMainItems = Tabs.Main:AddRightGroupbox("Items", "package")

local SelectedItems = {}

-- Bring Model func
function BringModel()
    local hrp = Player.Character.HumanoidRootPart
    local originalCFrame = hrp.CFrame
    local count = 0
    for _, item in ipairs(workspace.Items:GetChildren()) do
        if item:IsA("Model") and table.find(SelectedItems, item.Name) then
            if not item:IsDescendantOf(workspace) then return end
            local targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
            if not targetPart then return end

            RemoteEvents.RequestStartDraggingItem:FireServer(item)
            task.wait(0.05)
            if targetPart then
                item:SetPrimaryPartCFrame(originalCFrame)
            end

            RemoteEvents.StopDraggingItem:FireServer(item)
            count += 1
            task.wait(0.05)
        end
    end
    if count > 0 then
        Library:Notify({ 
            Title = "Notification",
            Description = "Bring " .. count .. " item(s) success",
            Time = 2,
        })
    else 
        Library:Notify({
            Title = "Notification",
            Description = "Item not found, Try again later",
            Time = 2,
        })
    end
end

-- Bring Specific Model func
function BringSpecificModels(modelList)
    local hrp = Player.Character.HumanoidRootPart
    local originalCFrame = hrp.CFrame
    local count = 0
    
    for _, item in ipairs(workspace.Items:GetChildren()) do
        if item:IsA("Model") and table.find(modelList, item.Name) then
            if not item:IsDescendantOf(workspace) then return end
            local targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
            if not targetPart then return end

            RemoteEvents.RequestStartDraggingItem:FireServer(item)
            task.wait(0.05)
            
            if targetPart then
                item:SetPrimaryPartCFrame(originalCFrame)
            end
            
            RemoteEvents.StopDraggingItem:FireServer(item)
            count += 1
            task.wait(0.05)
        end
    end
    if count > 0 then
        Library:Notify({
            Title = "Notification",
            Description = "Bring " .. count .. " item(s) success",
            Time = 1, 
        })
    else
        Library:Notify({
            Title = "Notification",
            Description = "Item not found, Try again later",
            Time = 1, 
        })
    end
end

-- Scan Items func
function ScanModeltools()
    local ToolPath = workspace.Items:GetChildren()
    local CountTable = {}

    for _, Tool in ipairs(ToolPath) do
        local name = Tool.Name CountTable[name] = (CountTable[name] or 0) + 1
    end

    local result = {}

    for name in pairs(CountTable) do
        table.insert(result, name)
    end

    table.sort(result, function(a, b)
        return a:lower() < b:lower()
    end)

    return result
end 

local SelectItemsDropdown = RightGroupboxMainItems:AddDropdown("SelectItemsDropdown", {
    Text = "<font color='#FF0000'>*</font> Select Items",
    Values = {},
    Default = {},
    Multi = true,
    Searchable = true,
})

SelectItemsDropdown:OnChanged(function(Value)
    SelectedItems = {}

    for i in pairs(Options.SelectItemsDropdown.Value) do 
        table.insert(SelectedItems, i) 
    end
end)

local BringModelButton = RightGroupboxMainItems:AddButton({ 
    Text = "Bring Item(s)", 
    Func = function() 
        BringModel() 
    end, 
    
    DoubleClick = false, 
    Disabled = false, 
    Visible = true, 
    Risky = false, 
})

BringModelButton:AddButton({
    Text = "Refresh List",
    Func = function()
        local result = ScanModeltools()

        SelectItemsDropdown:SetValues(result)
        SelectItemsDropdown:SetValue(nil)
        SelectedItems = {}
    end
})

local DestroyModelButton = RightGroupboxMainItems:AddButton({ 
    Text = "Destroy Item(s)", 
    Func = function() 
        local count = 0

        for _, item in ipairs(workspace.Items:GetChildren()) do
            if item:IsA("Model") and table.find(SelectedItems, item.Name) then

                local targetPart = item.PrimaryPart 
                    or item:FindFirstChildWhichIsA("BasePart") 
                    or item:FindFirstChild("Handle")

                if targetPart then
                    item:Destroy()
                    count += 1
                    task.wait(0.03)
                end
            end
        end

        if count > 0 then
            Library:Notify({
                Title = "Notification",
                Description = "Destroyed " .. count .. " item(s) successfully",
                Time = 1,
            })
        else
            Library:Notify({
                Title = "Notification",
                Description = "Item not found, Try again later",
                Time = 1,
            })
        end
    end, 
    
    DoubleClick = false, 
    Disabled = false, 
    Visible = true, 
    Risky = true, 
})


RightGroupboxMainItems:AddDivider()

local RightGroupBoxMainTeleport = Tabs.Main:AddRightGroupbox("Teleport", "map-pin")

local TeleportButton = RightGroupBoxMainTeleport:AddButton({
    Text = "Teleport To Campfire",
    Func = function()
        local targetPos = Vector3.new(0, 10, 0)
        hrp.CFrame = CFrame.new(targetPos)
    end,

    Disabled = false,
})

local TeleportStronghold = RightGroupBoxMainTeleport:AddButton({
    Text = "Teleport To Stronghold",
    Func = function()
        local target = workspace:FindFirstChild("Map")
            and workspace.Map.Landmarks
            and workspace.Map.Landmarks.Stronghold
            and workspace.Map.Landmarks.Stronghold.Building
            and workspace.Map.Landmarks.Stronghold.Building.Exterior

        if target then
            local e = target:GetChildren()[12]
            if e and e:FindFirstChild("Model") then
                local m = e.Model:GetChildren()[5]
                if m and hrp then
                    hrp.CFrame = m.CFrame + Vector3.new(0, 5, 0)
                    return
                end
            end
        else
        Library:Notify({
            Title = "Teleport",
            Description = "Not Found: Stronghold, try again later",
            Time = 2,
        })
        end
    end,
    Disabled = false,
})




local TeleportFairyButton = RightGroupBoxMainTeleport:AddButton({
    Text = "Teleport To Fairy House",
    Func = function()
        local fairyHouse = workspace.Map.Landmarks:FindFirstChild("Fairy House")
        if fairyHouse and fairyHouse.PrimaryPart then
            hrp.CFrame = fairyHouse.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
        else
            Library:Notify({
                Title = "Teleport",
                Description = "Not Found: Fairy House, try again later",
                Time = 2, 
            })
        end
    end,
    Disabled = false,
})

local TeleportFishingHutButton = RightGroupBoxMainTeleport:AddButton({
    Text = "Teleport To Fishing Hut",
    Func = function()
        local FishingHut = workspace.Map.Landmarks:FindFirstChild("Fishing Hut")
        if FishingHut and FishingHut.PrimaryPart then
            hrp.CFrame = FishingHut.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
        else
            Library:Notify({
                Title = "Teleport",
                Description = "Not Found: Fishing Hut, try again later",
                Time = 2, 
            })
        end
    end,
    Disabled = false,
})


local RightGroupboxMainMonster = Tabs.Main:AddRightGroupbox("Monster", "ghost")

local AutoStunDeer = RightGroupboxMainMonster:AddToggle("AutoStunDeer", {
    Text = "Auto Stun Deer",
    Default = false
})

AutoStunDeer:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoStunDeer.Value do
                local MonsterHitByTorch = ReplicatedStorage.RemoteEvents:WaitForChild("MonsterHitByTorch")
                local Deer = workspace.Characters:WaitForChild("Deer")
                if MonsterHitByTorch then
                    if Deer then
                        MonsterHitByTorch:InvokeServer(Deer)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

local AutoStunOwl = RightGroupboxMainMonster:AddToggle("AutoStunOwl", {
    Text = "Auto Stun Owl",
    Default = false
})

AutoStunOwl:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoStunOwl.Value do
                local MonsterHitByTorch = ReplicatedStorage.RemoteEvents:WaitForChild("MonsterHitByTorch")
                local Owl = workspace.Characters:WaitForChild("Owl")
                if MonsterHitByTorch then
                    if Owl then
                        MonsterHitByTorch:InvokeServer(Owl)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

local AutoStunRam = RightGroupboxMainMonster:AddToggle("AutoStunRam", {
    Text = "Auto Stun Ram",
    Default = false
})

AutoStunRam:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoStunRam.Value do
                local MonsterHitByTorch = ReplicatedStorage.RemoteEvents:WaitForChild("MonsterHitByTorch")
                local Ram = workspace.Characters:WaitForChild("Ram")
                if MonsterHitByTorch then
                    if Ram then
                        MonsterHitByTorch:InvokeServer(Ram)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

local RightGroupboxMainTree = Tabs.Main:AddRightGroupbox("Tree", "tree-pine")

local RadiusTree = 50
local SpacingTree = 1
local heightTree = 1

local RadiuesPlantTree = RightGroupboxMainTree:AddSlider("Sensitivity", {
    Text = "Radius (studs)",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 0,
})

RadiuesPlantTree:OnChanged(function(Value)
    RadiusTree = Value
end)

local SpacingPlantTree = RightGroupboxMainTree:AddSlider("SpacingPlantTree", {
    Text = "Spacing (studs)",
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 0,
})

SpacingPlantTree:OnChanged(function(Value)
    SpacingTree = Value
end)

local HeightPlantTree = RightGroupboxMainTree:AddSlider("HeightPlantTree", {
    Text = "Height",
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 0,
})

HeightPlantTree:OnChanged(function(Value)
    heightTree = Value
end)

RightGroupboxMainTree:AddDivider()

RightGroupboxMainTree:AddButton({
    Text = "Plant Tree",
    Func = function()
        local Sapling = workspace.Items:FindFirstChild("Sapling")
        local count = math.floor(2 * math.pi * RadiusTree / SpacingTree)

        for i = 0, count-1 do
        local theta = (i / count) * 2 * math.pi
        local x = math.cos(theta) * RadiusTree
        local z = math.sin(theta) * RadiusTree
        local position = Vector3.new(x, heightTree, z)
        RemoteEvents:WaitForChild("RequestPlantItem"):InvokeServer(Sapling, position)
        end
    end
})

local LeftGroupBoxVisualChest = Tabs.Visual:AddLeftGroupbox("Chest", "package")

local EspChestDropdownVar = { "Item Chest", "Item Chest2", "Item Chest3", "Item Chest4", "Item Chest5", "Item Chest6" }
local EspChestToggleVar = false

function MonitorChest(chest)
    if not chest:IsDescendantOf(workspace) then return end

    if chest:GetAttribute("LocalOpened") == true then
        RemoveGlow(chest)
        return
    end

    chest:GetAttributeChangedSignal("LocalOpened"):Connect(function()
        if chest:GetAttribute("LocalOpened") == true then
            RemoveGlow(chest)
        end
    end)
end

function CreateFullGlow(part)
    if part:IsA("Model") and part.PrimaryPart then
        if not part:FindFirstChild("Glow") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "Glow"
            highlight.Adornee = part
            highlight.FillTransparency = 0.7
            highlight.OutlineTransparency = 0.5
            highlight.FillColor = Color3.fromRGB(255, 100, 50)
            highlight.OutlineColor = Color3.fromRGB(255, 50, 0)
            highlight.Parent = part

            -- Tween ให้ glow กระพริบ
            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
            local tweenGoal = {FillTransparency = 0.4, OutlineTransparency = 0} -- ทำให้สว่างขึ้น
            local tween = TweenService:Create(highlight, tweenInfo, tweenGoal)
            tween:Play()

        end
    end
end

function RemoveGlow(part)
    if part:FindFirstChild("Glow") then
        part.Glow:Destroy()
    end
end

function UpdateChestESP()
    task.spawn(function()
        while EspChestToggleVar do
            if EspChestToggleVar then
                for _, item in ipairs(workspace.Items:GetChildren()) do
                    if table.find(EspChestDropdownVar, item.Name) then
                        if item:GetAttribute("LocalOpened") ~= true then
                            CreateFullGlow(item)
                            MonitorChest(item)
                        else
                            RemoveGlow(item)
                        end
                    else
                        RemoveGlow(item)
                    end
                end
            else
                for _, item in ipairs(workspace.Items:GetChildren()) do
                    RemoveGlow(item)
                end
            end
            task.wait(1)
        end
    end)
end

workspace.Items.ChildAdded:Connect(function(child)
    task.wait(1)
    if table.find(EspChestDropdownVar, child.Name) and EspChestToggleVar then
        CreateFullGlow(child)
    end
end)

workspace.Items.ChildRemoved:Connect(function(child)
    RemoveGlow(child)
end)

local EspChestToggle = LeftGroupBoxVisualChest:AddToggle("EspChestToggle", {
    Text = "Esp Chest",
    Default = false
})

EspChestToggle:OnChanged(function(Value)
    EspChestToggleVar = Value
    if Value then
        UpdateChestESP()
    else
        for _, item in ipairs(workspace.Items:GetChildren()) do
            RemoveGlow(item)
        end
    end
end)


local LeftGroupboxPlayer = Tabs.Player:AddLeftGroupbox("Player", "user")

local WalkSpeed = false
local Speed = 16
local Noclip = false

local WalkSpeedToggle = LeftGroupboxPlayer:AddToggle("WalkSpeedToggle", {
    Text = "WalkSpeed",
    Default = false,
})

local SpeedSlider = LeftGroupboxPlayer:AddSlider("SpeedSlider", {
    Text = "Speed",
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Visible = false,
})

local NoclipToggle = LeftGroupboxPlayer:AddToggle("NoclipToggle", {
    Text = "Noclip",
    Default = false,
})

WalkSpeedToggle:OnChanged(function(Value)
    WalkSpeedEnabled = Value
    SpeedSlider:SetVisible(Value)

    if not WalkSpeedEnabled then
        humanoid.WalkSpeed = 16
    else
        humanoid.WalkSpeed = Speed
    end
end)

SpeedSlider:OnChanged(function(Value)
    Speed = Value
    if WalkSpeedEnabled then
        humanoid.WalkSpeed = Speed
    end
end)

NoclipToggle:OnChanged(function(Value)
    Noclip = Value

    if not Noclip and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)

game:GetService("RunService").Stepped:Connect(function()
    -- WalkSpeed
    if WalkSpeedEnabled and humanoid.WalkSpeed ~= Speed then
        humanoid.WalkSpeed = Speed
    end

    -- Noclip
    if Noclip and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

local LeftGroupboxPlayerMisc = Tabs.Player:AddRightGroupbox("Misc", "bug")

local GodmodeToggle = LeftGroupboxPlayerMisc:AddToggle("GodmodeToggle", {
    Text = "God Mode",
    Default = false
})
GodmodeToggle:OnChanged(function(Value)
    local rs = game:GetService("ReplicatedStorage")
    local re = rs:WaitForChild("RemoteEvents")
    local dmg = re:WaitForChild("DamagePlayer")
    if Value then
        task.spawn(function()
            while GodmodeToggle.Value do
                dmg:FireServer(-(1/0))
                task.wait(0.1)
            end
        end)
    end
end)

local AntiAfkVar
local InstantPromtToggle = LeftGroupboxPlayerMisc:AddToggle("InstantPromt", {
    Text = "Instant Promt",
    Default = false,
})

InstantPromtToggle:OnChanged(function(Value)
    if Value then
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                prompt.HoldDuration = 0 end
            end
            workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("ProximityPrompt") then
                obj.HoldDuration = 0
            end
        end)
    end
end)

local AntiAfkToggle = LeftGroupboxPlayerMisc:AddToggle("AntiAfkToggle", {
    Text = "Anti Afk",
    Default = true
})

AntiAfkToggle:OnChanged(function(Value)
    if Value then
        AntiAfkVar = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    else
        if AntiAfkVar then
            AntiAfkVar:Disconnect()
            AntiAfkVar = nil
        end
    end
end)


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
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = false, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("99night")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
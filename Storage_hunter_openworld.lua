local repo = "https://raw.githubusercontent.com/s2000s/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

print("111111111111111111")

local Window = Library:CreateWindow({
    Title = "Storage Hunters",
    Footer = "",
    NotifySide = "Right",
    SidebarCompacted = true,
    CollapsibleSearch = true,
    GlobalSearch = true,
    Resizable = false,
    DisableSearch = false,
    ShowCustomCursor = true,
    CornerRadius = 5,
})

Window:SetAnimations({
    ToggleWindow = true,
    TabSwitch = true,
    Groupbox = true,
    Dropdown = true,
    KeyPicker = true,
}, 0.22, 26, "bottom")

local Tabs = {
    Main = Window:AddTab("Main", "house"),
    ["UI Settings"] = Window:AddTab("Settings", "settings"),
}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local UIController = require(ReplicatedStorage.Modules.UIController)

-- Modules
local Items = require(ReplicatedStorage.Modules.Items)
local MutatorModule = pcall(function() return require(ReplicatedStorage.Modules.MutatorModule) end) and require(ReplicatedStorage.Modules.MutatorModule) or nil
local GameConfig = pcall(function() return require(ReplicatedStorage.Modules.GameConfig) end) and require(ReplicatedStorage.Modules.GameConfig) or nil
local GradingModule = GameConfig and GameConfig.Grading or nil

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

-- Anti-AFK
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local plotpath = workspace:WaitForChild("_Plots", 10)

-- Events
local InventoryEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Inventory")
local PlotEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Plot")
local VehicleEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Vehicles")
local Bid = game:GetService("ReplicatedStorage").Events.Auction.Bid

-- Grading Events
local GradingEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Grading")
local GetSlotStateRemote = GradingEvents:WaitForChild("GetSlotState")
local GetGradableItemsRemote = GradingEvents:WaitForChild("GetGradableItems")
local StartGradingRemote = GradingEvents:WaitForChild("StartGrading")
local CollectGradeRemote = GradingEvents:WaitForChild("CollectGrade")
local ClaimGradedItemRemote = GradingEvents:WaitForChild("ClaimGradedItem")

local carryables = workspace:WaitForChild("_Carryables")
local NPCShopper = ReplicatedStorage:WaitForChild("Events"):WaitForChild("NPCShopper")
local ShowOffer = NPCShopper:WaitForChild("ShowOffer")
local RespondOffer = NPCShopper:WaitForChild("RespondOffer")
local PoliceChase = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Misc"):WaitForChild("PoliceChase")

local Rarity = {
    "Junk",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythical"
}

-- Rank ของ Rarity (ยิ่งสูงยิ่งหายาก)
local RarityRank = {
    ["Mythical"] = 6,
    ["Legendary"] = 5,
    ["Epic"] = 4,
    ["Rare"] = 3,
    ["Uncommon"] = 2,
    ["Junk"] = 1
}

-- ฟังก์ชันคำนวณมูลค่าของไอเทม
local function calculateItemValue(itemData)
    if type(itemData) ~= "table" then return 0 end

    local itemId = itemData.ItemId
    local itemDef = itemId and (Items[tostring(itemId)] or Items[itemId])
    local basePrice = itemDef and (itemDef.BasePrice or itemDef.Price or 0) or 0
    local finalPrice = basePrice

    if MutatorModule and type(MutatorModule.CalculatePriceForEntry) == "function" then
        local ok, calculated = pcall(function()
            return MutatorModule:CalculatePriceForEntry(basePrice, itemData)
        end)
        if ok and tonumber(calculated) then
            finalPrice = calculated
        end
    end

    if GradingModule and type(GradingModule.GradeCashMultForEntry) == "function" then
        local ok, gradeMult = pcall(function()
            return GradingModule.GradeCashMultForEntry(itemData)
        end)
        if ok and tonumber(gradeMult) and gradeMult ~= 1 then
            finalPrice = math.floor(finalPrice * gradeMult * 100 + 0.5) / 100
        end
    end

    return finalPrice
end

---------------------------------------------------------------------
-- Shop Groupbox
---------------------------------------------------------------------
local ShopMainLeftGroupbox = Tabs.Main:AddLeftGroupbox("Shop")

local IgnoreRarityStockDd = ShopMainLeftGroupbox:AddDropdown("IgnoreRarityStockDd", {
    Text = "Ignore Rarity",
    Values = Rarity,
    Default = {},
    Multi = true,
    AllowNull = true,
})

local IgnoreTrophyT = ShopMainLeftGroupbox:AddToggle("IgnoreTrophyT", {
    Text = "Ignore Trophy",
    Default = true,
})

local AutoStockT = ShopMainLeftGroupbox:AddToggle("AutoStockT", {
    Text = "Auto Stock Items",
    Default = false,
})

AutoStockT:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoStockT.Value do
                local previewSuccess, previewResult = pcall(function()
                    return PlotEvents.ShelfAutoStock:InvokeServer("preview")
                end)
                
                if previewSuccess and type(previewResult) == "table" and previewResult.Ok == true then
                    local freeSlots = tonumber(previewResult.FreeSlots) or 0
                    local spaceLeft = tonumber(previewResult.SpaceLeft) or 0
                    local availableSpace = math.max(0, math.min(freeSlots, spaceLeft))
                    
                    if availableSpace > 0 then
                        local invSuccess, inventoryItems = pcall(function()
                            return InventoryEvents.GetPlayerInventory:InvokeServer()
                        end)
                        
                        if invSuccess and type(inventoryItems) == "table" then
                            local itemGuids = {}
                            
                            for guid, itemData in pairs(inventoryItems) do
                                if #itemGuids >= availableSpace then break end
                                
                                local itemDef = Items[tostring(itemData.ItemId)] or Items[itemData.ItemId]
                                local itemRarity = itemDef and itemDef.Rarity or "Junk"
                                local isIgnoredRarity = IgnoreRarityStockDd.Value[itemRarity] == true

                                -- *** ตรวจสอบว่าเป็น Trophy หรือไม่ (อ้างอิงจาก IsTrophy หรือ ItemId ของถ้วย) ***
                                local isTrophyItem = false
                                if IgnoreTrophyT and IgnoreTrophyT.Value then
                                    if itemData.IsTrophy == true or itemData.Name == "Gavel Trophy" then
                                        isTrophyItem = true
                                    elseif TrophyConfig and TrophyConfig.TrophyItemId and itemData.ItemId then
                                        if tostring(itemData.ItemId) == tostring(TrophyConfig.TrophyItemId) then
                                            isTrophyItem = true
                                        end
                                    end
                                end

                                -- *** ตรวจสอบการมีอยู่ของ Buffs / RolledAttributes อย่างละเอียด ***
                                local hasBuffs = false
                                if itemData.RolledAttributes ~= nil then
                                    if type(itemData.RolledAttributes) == "table" then
                                        -- เช็คตาราง Buffs ว่ามีบัฟอยู่หรือไม่
                                        if type(itemData.RolledAttributes.Buffs) == "table" and #itemData.RolledAttributes.Buffs > 0 then
                                            hasBuffs = true
                                        -- เช็คคุณสมบัติพิเศษอื่น ๆ เช่น Multiplier หรือ Nerfs
                                        elseif itemData.RolledAttributes.Multiplier or (type(itemData.RolledAttributes.Nerfs) == "table" and #itemData.RolledAttributes.Nerfs > 0) then
                                            hasBuffs = true
                                        end
                                    else
                                        hasBuffs = true
                                    end
                                end

                                local isFavorited = itemData.Favorited == true
                                local fitsOnShelf = previewResult.Fits and previewResult.Fits[guid] == true
                                
                                -- *** ตรวจสอบการกั้นเกรดดาวจากข้อมูลไอเทมโดยตรง ***
                                local isReservedForGrading = false
                                if AutoGradingT and AutoGradingT.Value then
                                    local isUnGraded = (itemData.Grade == nil) -- ยังไม่เคยเกรดดาว
                                    local isGoodCondition = (not itemData.Condition or itemData.Condition >= 50) -- สภาพ >= 50%
                                    
                                    if isUnGraded and isGoodCondition then
                                        isReservedForGrading = true
                                    end
                                end
                                
                                -- กรองไอเทม: ต้องไม่ใช่ Trophy, ต้องไม่มี Buff, ไม่ติดรอเกรด, ไม่ได้ติดดาว Favorite, ไม่อยู่ใน Rarity ที่ยกเว้น
                                if not isTrophyItem and not hasBuffs and not isReservedForGrading and not isFavorited and not isIgnoredRarity and fitsOnShelf then
                                    table.insert(itemGuids, guid)
                                end
                            end
                            
                            if #itemGuids > 0 then
                                pcall(function()
                                    PlotEvents.ShelfAutoStock:InvokeServer("apply", itemGuids)
                                end)
                            end
                        end
                    end
                end
                
                task.wait(3)
            end
        end)
    end
end)

local AutoAcceptNPCT = ShopMainLeftGroupbox:AddToggle("AutoAcceptNPCT", {
    Text = "Auto Accept Offer",
    Default = false,
})

local OfferConfigS = ShopMainLeftGroupbox:AddSlider("OfferConfigS", {
    Text = "Min Offer (%)",
    Default = 10,
    Min = -10,
    Max = 100,
    Rounding = 0,
    Compact = false,
})

ShowOffer.OnClientEvent:Connect(function(offerId, npcModel, itemText, offerPrice, basePrice)
    if not AutoAcceptNPCT.Value then return end
    
    local offerPercent = 0
    if basePrice and basePrice > 0 then
        offerPercent = ((offerPrice - basePrice) / basePrice) * 100
    end

    if offerPercent >= OfferConfigS.Value then
        RespondOffer:FireServer(offerId, true)
    else
        RespondOffer:FireServer(offerId, false)
    end
end)

local AuctionMainLeftGroupbox = Tabs.Main:AddLeftGroupbox("Auction")

local AutoBidT = AuctionMainLeftGroupbox:AddToggle("AutoBidT", {
    Text = "Auto Bid",
    Default = false,
})

AutoBidT:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoBidT.Value do
                if Player:GetAttribute("InAuction") == true or UIController:IsOpen("AuctionBidding") then
                    Bid:FireServer()
                    task.wait(0.5)
                else
                    task.wait(1)
                end
            end
        end)
    end
end)

local MiscMainLeftGroupbox = Tabs.Main:AddLeftGroupbox("Misc")

local function getMyVehicle()
    local char = Player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart.Name == "DriveSeat" then
        return hum.SeatPart.Parent
    end

    local equippedGuid = Player:GetAttribute("EquippedVehicle")
    local searchFolders = { workspace, workspace:FindFirstChild("_Vehicles"), workspace:FindFirstChild("Vehicles") }
    
    for _, folder in ipairs(searchFolders) do
        if folder then
            for _, car in ipairs(folder:GetChildren()) do
                if car:IsA("Model") then
                    local carGuid = car:GetAttribute("VehicleGUID") or car:GetAttribute("GUID")
                    local ownerId = car:GetAttribute("OwnerUserId") or car:GetAttribute("Owner") or car:GetAttribute("OwnerId")
                    
                    if (equippedGuid and equippedGuid ~= "" and carGuid == equippedGuid) or 
                       (ownerId and (ownerId == Player.UserId or ownerId == tostring(Player.UserId) or ownerId == Player.Name)) then
                        return car
                    end
                end
            end
        end
    end
    return nil
end

local loadItemT = MiscMainLeftGroupbox:AddToggle("loadItemT", {
    Text = "Auto Unload",
    Default = false,
})

loadItemT:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while loadItemT.Value do
                local equippedVehicle = Player:GetAttribute("EquippedVehicle")
                
                if equippedVehicle and equippedVehicle ~= "" then
                    local success, items = pcall(function()
                        return VehicleEvents.GetVehicleItems:InvokeServer(equippedVehicle)
                    end)
                    
                    if success and type(items) == "table" then
                        local itemGuids = {}
                        
                        for guid, _ in pairs(items) do
                            table.insert(itemGuids, guid)
                        end

                        if #itemGuids > 0 then
                            VehicleEvents.TransferVehicleItemsToInventory:FireServer(itemGuids)
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

local PickUpT = MiscMainLeftGroupbox:AddToggle("PickUpT", {
    Text = "Auto Pick Up",
    Default = false,
})

PickUpT:OnChanged(function(state)
    if state then
        task.spawn(function()
            while PickUpT.Value do
                local myCar = getMyVehicle()
                local isOverweight = false

                if myCar then
                    local currentWeight = tonumber(myCar:GetAttribute("CargoWeight")) or 0
                    local weightLimit = tonumber(myCar:GetAttribute("CargoWeightLimit")) or 0

                    if weightLimit > 0 and currentWeight >= (weightLimit - 0.01) then
                        isOverweight = true
                    end
                end

                if isOverweight then
                    if loadItemT.Value and myCar then
                        local driveSeat = myCar:FindFirstChild("DriveSeat")
                        local promptLocation = driveSeat and driveSeat:FindFirstChild("PromptLocation")
                        local vehiclePrompt = promptLocation and promptLocation:FindFirstChild("VehiclePrompt")

                        if not vehiclePrompt then
                            vehiclePrompt = myCar:FindFirstChildWhichIsA("ProximityPrompt", true)
                            promptLocation = vehiclePrompt and vehiclePrompt.Parent
                        end

                        if vehiclePrompt and promptLocation then
                            local targetCFrame = nil
                            if promptLocation:IsA("BasePart") then
                                targetCFrame = promptLocation.CFrame
                            elseif promptLocation:IsA("Attachment") then
                                targetCFrame = promptLocation.WorldCFrame
                            elseif promptLocation:IsA("Model") then
                                targetCFrame = promptLocation:GetPivot()
                            else
                                targetCFrame = myCar:GetPivot()
                            end

                            if hrp and targetCFrame then
                                hrp.CFrame = targetCFrame * CFrame.new(0, 2, 0)
                                task.wait(0.1)
                            end

                            vehiclePrompt.MaxActivationDistance = 9999
                            vehiclePrompt.RequiresLineOfSight = false
                            vehiclePrompt.HoldDuration = 0

                            if fireproximityprompt then
                                fireproximityprompt(vehiclePrompt)
                            end

                            task.wait(0.5)
                        end
                    end
                else
                    if carryables then
                        for _, item in ipairs(carryables:GetChildren()) do
                            if not PickUpT.Value then break end

                            if item:IsA("Model") and item.PrimaryPart then
                                local owner = item:GetAttribute("Owner")
                                
                                if owner and (owner == Player.UserId or owner == tostring(Player.UserId) or owner == Player.Name) then
                                    local prompt = item.PrimaryPart:FindFirstChildWhichIsA("ProximityPrompt")
                                    
                                    if prompt then
                                        if hrp then
                                            hrp.CFrame = item.PrimaryPart.CFrame * CFrame.new(0, 2, 0)
                                            task.wait(0.05)
                                        end

                                        if prompt.HoldDuration ~= 0 then
                                            prompt.MaxActivationDistance = 9999
                                            prompt.RequiresLineOfSight = false
                                            prompt.HoldDuration = 0
                                        end
                                        
                                        if fireproximityprompt then
                                            fireproximityprompt(prompt)
                                        end

                                        task.wait(0.15)
                                    end
                                end
                            end
                        end
                    end
                end
                
                task.wait(0.5)
            end
        end)
    end
end)

local policeConnections = {}
local hudAddedConnection = nil

local AntiPoliceT = MiscMainLeftGroupbox:AddToggle("AntiPoliceT", {
    Text = "Disable Police",
    Default = false,
})

AntiPoliceT:OnChanged(function(state)
    if state then
        local conns = (getconnections and getconnections(PoliceChase.OnClientEvent)) or {}
        policeConnections = conns
        
        for _, conn in ipairs(policeConnections) do
            if conn and conn.Disable then
                pcall(function() conn:Disable() end)
            end
        end

        pcall(function()
            if PlayerGui then
                local hud = PlayerGui:FindFirstChild("PoliceChaseHUD")
                if hud then hud:Destroy() end
            end
        end)

        if hudAddedConnection then
            pcall(function() hudAddedConnection:Disconnect() end)
            hudAddedConnection = nil
        end

        pcall(function()
            if PlayerGui then
                hudAddedConnection = PlayerGui.ChildAdded:Connect(function(child)
                    if child and child.Name == "PoliceChaseHUD" then
                        task.defer(function()
                            pcall(function()
                                if child and child.Parent then child:Destroy() end
                            end)
                        end)
                    end
                end)
            end
        end)
    else
        if policeConnections and type(policeConnections) == "table" then
            for _, conn in ipairs(policeConnections) do
                if conn and conn.Enable then
                    pcall(function() conn:Enable() end)
                end
            end
            policeConnections = {}
        end
        
        if hudAddedConnection then
            pcall(function() hudAddedConnection:Disconnect() end)
            hudAddedConnection = nil
        end
    end
end)

---------------------------------------------------------------------
-- Grading Groupbox
---------------------------------------------------------------------
local GradingRightGroupbox = Tabs.Main:AddRightGroupbox("Grading")

local GradingPriorityDd = GradingRightGroupbox:AddDropdown("GradingPriorityDd", {
    Text = "Grading Priority",
    Values = { "Rarity", "Most Value", "Both" },
    Default = "Both",
    Multi = false,
    AllowNull = false,
})

local AutoGradingT = GradingRightGroupbox:AddToggle("AutoGradingT", {
    Text = "Auto Grading",
    Default = false,
})

AutoGradingT:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoGradingT.Value do
                local stateOk, slotStateData = pcall(function()
                    return GetSlotStateRemote:InvokeServer()
                end)

                if stateOk and type(slotStateData) == "table" then
                    local unlockedCount = slotStateData.unlockedCount or 1
                    local slots = slotStateData.slots or {}
                    local serverNow = workspace:GetServerTimeNow()

                    -- 1. Claim/Clear slots that are already finished
                    for slotIndex = 1, unlockedCount do
                        if not AutoGradingT.Value then break end

                        local slotData = slots[tostring(slotIndex)]

                        if slotData then
                            if slotData.Grade then
                                -- Already graded, just claim quietly without notification
                                pcall(function()
                                    ClaimGradedItemRemote:InvokeServer(slotIndex)
                                end)

                                task.wait(1.2)
                            else
                                local startTime = slotData.StartTime or 0
                                local duration = slotData.Duration or 0
                                local timeLeft = (startTime + duration) - serverNow

                                if timeLeft <= 0 then
                                    local slotItemData = slotData.ItemData or slotData.Data or {}
                                    local itemDef = Items[tostring(slotItemData.ItemId)] or Items[slotItemData.ItemId]
                                    local itemName = (slotItemData and slotItemData.Name) or (itemDef and (itemDef.Name or itemDef.DisplayName)) or "Unknown Item"

                                    local collectOk, collectRes = pcall(function()
                                        return CollectGradeRemote:InvokeServer(slotIndex)
                                    end)

                                    if collectOk and type(collectRes) == "table" and collectRes.success then
                                        local rawGrade = collectRes.grade or collectRes.Grade or (collectRes.slotData and (collectRes.slotData.grade or collectRes.slotData.Grade)) or "Completed"
                                        
                                        -- แปลงชื่อ Grade เป็นไอคอนดาวหรือข้อความที่อ่านง่าย
                                        local formattedGrade = rawGrade
                                        if rawGrade == "Replica" then
                                            formattedGrade = "❌ Replica"
                                        elseif rawGrade == "OneStar" then
                                            formattedGrade = "⭐"
                                        elseif rawGrade == "TwoStar" then
                                            formattedGrade = "⭐⭐"
                                        elseif rawGrade == "ThreeStar" then
                                            formattedGrade = "⭐⭐⭐"
                                        end

                                        -- Notify when grade result is collected
                                        Library:Notify({
                                            Title = "🎉 Grade Collected",
                                            Description = string.format("📦 Item: %s\n🏆 Result: %s\n📌 Slot: %d", itemName, formattedGrade, slotIndex),
                                            Time = 10
                                        })

                                        task.wait(1.2)
                                        -- Claim quietly after collecting
                                        pcall(function()
                                            ClaimGradedItemRemote:InvokeServer(slotIndex)
                                        end)
                                        task.wait(1.2)
                                    end
                                end
                            end
                        end
                    end

                    -- 2. Fetch gradable items list
                    local gradableOk, gradableData = pcall(function()
                        return GetGradableItemsRemote:InvokeServer()
                    end)

                    local rawItems = (gradableOk and type(gradableData) == "table" and gradableData.items) or {}
                    local gradableList = {}

                    -- Filter un-graded items with Condition >= 50%
                    for _, itemInfo in ipairs(rawItems) do
                        local data = itemInfo.data
                        if data and (not data.Grade) and (not data.Condition or data.Condition >= 50) then
                            local itemDef = Items[tostring(data.ItemId)] or Items[data.ItemId]
                            local rarityStr = itemDef and itemDef.Rarity or "Junk"
                            local rarityRank = RarityRank[rarityStr] or 1
                            local itemValue = calculateItemValue(data)

                            table.insert(gradableList, {
                                info = itemInfo,
                                rarityRank = rarityRank,
                                value = itemValue
                            })
                        end
                    end

                    -- 3. Sort by priority
                    local priorityMode = GradingPriorityDd.Value or "Both"

                    table.sort(gradableList, function(a, b)
                        if priorityMode == "Rarity" then
                            return a.rarityRank > b.rarityRank
                        elseif priorityMode == "Most Value" then
                            return a.value > b.value
                        elseif priorityMode == "Both" then
                            if a.rarityRank ~= b.rarityRank then
                                return a.rarityRank > b.rarityRank
                            else
                                return a.value > b.value
                            end
                        end
                        return false
                    end)

                    -- 4. Send items to empty slots
                    for slotIndex = 1, unlockedCount do
                        if not AutoGradingT.Value then break end

                        local slotData = slots[tostring(slotIndex)]

                        if not slotData then
                            for _, sortedItem in ipairs(gradableList) do
                                local itemInfo = sortedItem.info
                                local data = itemInfo.data
                                
                                local itemDef = Items[tostring(data.ItemId)] or Items[data.ItemId]
                                local itemName = (data and data.Name) or (itemDef and (itemDef.Name or itemDef.DisplayName)) or ("Item ID: " .. tostring(data.ItemId))

                                local startOk, startRes = pcall(function()
                                    return StartGradingRemote:InvokeServer(slotIndex, itemInfo.guid, itemInfo.source, itemInfo.vehicleGUID)
                                end)

                                if startOk and type(startRes) == "table" and startRes.success then
                                    slots[tostring(slotIndex)] = startRes.slotData or { StartTime = serverNow, Duration = 5 }
                                    
                                    -- Format duration text
                                    local slotDuration = (startRes.slotData and startRes.slotData.Duration) or 5
                                    local durationText = slotDuration .. "s"
                                    if slotDuration >= 60 then
                                        durationText = math.floor(slotDuration / 60) .. "m"
                                    end

                                    -- Notify when starting to grade an item
                                    Library:Notify({
                                        Title = "⏳ Grading Started",
                                        Description = string.format("📦 Item: %s\n⏱️ Time: %s\n📌 Slot: %d", itemName, durationText, slotIndex),
                                        Time = 10
                                    })

                                    table.remove(gradableList, table.find(gradableList, sortedItem))
                                    task.wait(1.5)
                                    break
                                end
                            end
                        end
                    end
                end

                task.wait(3)
            end
        end)
    end
end)

---------------------------------------------------------------------
-- UI Settings Tab
---------------------------------------------------------------------
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = Library.ShowCustomCursor,
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
        Library:SetDPIScale(tonumber(Value:gsub("%%", "")))
    end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind",
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("fzlmm_xz")
SaveManager:SetFolder("fzlmm_xz/config")
SaveManager:SetSubFolder("Storage Hunters")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
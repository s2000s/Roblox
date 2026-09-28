local repo = "https://raw.githubusercontent.com/s2000s/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local function isNotificationSelected(name)
    local selected = Options.SelectNotifyD and Options.SelectNotifyD.Value
    local notifyToggle = Toggles.ToggleNotify
    return notifyToggle ~= nil
        and notifyToggle.Value == true
        and type(selected) == "table"
        and selected[name] == true
end

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "Storage Hunters",
    Footer = "",
    NotifySide = "Right",
    SidebarCompacted = true,
    CollapsibleSearch = true,
    GlobalSearch = true,
    Resizable = false,
    DisableSearch = false,
    ShowCustomCursor = false,
    CornerRadius = 5,
})

Window:SetAnimations({
    ToggleWindow = false,
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

local function isTrophyItemData(itemData)
    if type(itemData) ~= "table" then return false end
    if itemData.IsTrophy == true then return true end

    local itemId = itemData.ItemId
    local itemDef = itemId and (Items[tostring(itemId)] or Items[itemId])
    if itemDef and (itemDef.IsTrophy == true or itemDef.Trophy == true) then return true end

    local names = {
        itemData.Name,
        itemData.DisplayName,
        itemDef and itemDef.Name,
        itemDef and itemDef.DisplayName,
    }
    for _, name in pairs(names) do
        if type(name) == "string" and string.find(string.lower(name), "trophy", 1, true) then
            return true
        end
    end
    return false
end

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

-- Pawn Events (Quick Sell)
local PawnEvents = ReplicatedStorage:WaitForChild("Events"):FindFirstChild("Pawn")
local GetPawnStateRemote = PawnEvents and PawnEvents:FindFirstChild("GetPawnState")
local SellItemsRemote = PawnEvents and PawnEvents:FindFirstChild("SellItems")

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

local Garage = workspace:WaitForChild("_Debris"):WaitForChild("Garages")
local SeizedGarageRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Misc"):WaitForChild("SeizedGarage")
local seizedGarageGuids = {}
local notifiedPoliceGarageGuids = {}

local function notifyPoliceGarage(guid)
    if type(guid) ~= "string" then return false end
    if notifiedPoliceGarageGuids[guid] then return true end

    for _, garage in ipairs(Garage:GetChildren()) do
        if garage:IsA("Model") and garage:GetAttribute("GUID") == guid then
            if not isNotificationSelected("Police Container") then return false end

            notifiedPoliceGarageGuids[guid] = true
            local areaName = garage:GetAttribute("AreaName") or "Unknown Area"
            local inAuction = garage:GetAttribute("InAuction") == true
            Library:Notify({
                Title = "POLICE CONTAINER",
                Description = string.format("Area: %s\nContainer: %s\nStatus: %s", areaName, garage.Name, inAuction and "Already In Auction" or "Ready"),
                Time = 10,
            })
            return true
        end
    end
    return false
end

SeizedGarageRemote.OnClientEvent:Connect(function(action, guid)
    if action == "Set" and type(guid) == "string" then
        table.clear(seizedGarageGuids)
        seizedGarageGuids[guid] = true
        task.spawn(function()
            for _ = 1, 50 do
                if notifyPoliceGarage(guid) then return end
                task.wait(0.2)
            end
        end)
    elseif action == "Clear" then
        if type(guid) == "string" then
            seizedGarageGuids[guid] = nil
            notifiedPoliceGarageGuids[guid] = nil
        else
            table.clear(seizedGarageGuids)
            table.clear(notifiedPoliceGarageGuids)
        end
    end
end)

task.defer(function()
    pcall(function()
        SeizedGarageRemote:FireServer()
    end)
end)

local function isPoliceGarage(garage)
    if garage:FindFirstChild("SeizedDressing") then return true end
    local guid = garage:GetAttribute("GUID")
    return type(guid) == "string" and seizedGarageGuids[guid] == true
end

local Area = {
    "Junk Yard",
    "Back Alley",
    "Farmyard",
    "Shipyard",
    "Jurassic",
    "Cargo Ship",
}

local Rarity = {
    "Junk",
    "Uncommon",
    "Rare",
    "Epic",
    "Legendary",
    "Mythical"
}

local RarityRank = {
    ["Mythical"] = 6,
    ["Legendary"] = 5,
    ["Epic"] = 4,
    ["Rare"] = 3,
    ["Uncommon"] = 2,
    ["Junk"] = 1
}

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

local function AuctionStartingBid()
    local success, AuctionBidding = pcall(function()
        return require(ReplicatedStorage.Modules.Screens.AuctionBidding)
    end)
    
    if success and AuctionBidding then
        return AuctionBidding._startingBidPrice or 0
    end
    
    -- warn("ไม่สามารถโหลดโมดูล AuctionBidding ได้")
    return 0
end

local AuctionMainLeftGroupbox = Tabs.Main:AddLeftGroupbox("Auction")

local SelectAreaD = AuctionMainLeftGroupbox:AddDropdown("SelectAreaD", {
    Text = "Select Area",
    Values = Area,
    Default = {},
    Multi = false,
    AllowNull = true
})

SelectAreaD:OnChanged(function(Value)

end)

local OnlyPoliceContainerT = AuctionMainLeftGroupbox:AddToggle("OnlyPoliceContainerT", {
    Text = "Only Police",
    Default = false
})

local MinStartPrice = AuctionMainLeftGroupbox:AddInput("MinStartPrice", {
	Default = "1000",
	Numeric = true,
	Finished = false,
	ClearTextOnFocus = false,

	Text = "Min",

	Callback = function(Value)
	end,
})

AuctionMainLeftGroupbox:AddDivider("Automation")

local AutoAuctionT = AuctionMainLeftGroupbox:AddToggle("AutoAuctionT", {
    Text = "Auto Auction",
    Default = false
})

local autoAuctionRunId = 0
AutoAuctionT:OnChanged(function(Value)
    autoAuctionRunId = autoAuctionRunId + 1
    local runId = autoAuctionRunId
    if not Value then return end

    task.spawn(function()
        local function isRunning()
            return AutoAuctionT.Value and autoAuctionRunId == runId
        end

        local function readNumberText(value)
            if type(value) == "number" then return value end
            if type(value) ~= "string" then return nil end
            local cleanText = value:gsub(",", ""):gsub("[^%d%.%-]", "")
            return tonumber(cleanText)
        end

        local function getGarageMinNetWorth(garageItem)
            local entry = garageItem:FindFirstChild("EntrySquare")
            local promptPart = entry and entry:FindFirstChild("PromptPart")
            local billboard = promptPart and promptPart:FindFirstChild("BillboardGui", true)
            local container = billboard and billboard:FindFirstChild("Container", true)
            local valueObj = container and container:FindFirstChild("MinNetWorth", true)
            if not valueObj then return nil end

            if valueObj:IsA("TextLabel") or valueObj:IsA("TextButton") or valueObj:IsA("TextBox") then
                return readNumberText(valueObj.Text)
            elseif valueObj:IsA("NumberValue") or valueObj:IsA("IntValue") then
                return valueObj.Value
            elseif valueObj:IsA("StringValue") then
                return readNumberText(valueObj.Value)
            end
            return nil
        end

        local function getPlayerNetWorth()
            local leaderstats = Player:FindFirstChild("leaderstats")
            local nwStat = leaderstats and leaderstats:FindFirstChild("Net Worth")
            if not nwStat then return nil end
            return readNumberText(nwStat:GetAttribute("RawValue"))
        end

        local function stopIfInventoryFull()
            local inventoryCount = tonumber(Player:GetAttribute("InventoryCount"))
            local inventoryCap = tonumber(Player:GetAttribute("InventoryCap"))
            if inventoryCount and inventoryCap and inventoryCap > 0 and inventoryCount >= inventoryCap then
                print(string.format("[AutoAuction] Inventory full (%s/%s); stopping Auto Auction", tostring(inventoryCount), tostring(inventoryCap)))
                return true
            end
            return false
        end

        local function waitForGarageState(garage, expected, timeoutSeconds)
            local deadline = os.clock() + timeoutSeconds
            repeat
                if not isRunning() or not garage.Parent then return false end
                if garage:GetAttribute("InAuction") == expected then return true end
                task.wait(0.1)
            until os.clock() >= deadline
            return garage.Parent ~= nil and garage:GetAttribute("InAuction") == expected
        end

        local function getAuctionZoneCFrame(zone)
            if not zone then return nil end
            if zone:IsA("BasePart") then return zone.CFrame end
            if zone:IsA("Model") then
                local ok, pivot = pcall(function() return zone:GetPivot() end)
                if ok then return pivot end
            end
            return nil
        end

        local function moveAwayFromAuctionZone(zone)
            local zoneCFrame = getAuctionZoneCFrame(zone)
            local root = hrp
            if not zoneCFrame or not root or not root.Parent then return false end

            local offset = root.Position - zoneCFrame.Position
            if offset.Magnitude >= 30 then return false end
            local horizontalOffset = Vector3.new(offset.X, 0, offset.Z)
            local direction = horizontalOffset.Magnitude > 0.01 and horizontalOffset.Unit or Vector3.new(-zoneCFrame.LookVector.X, 0, -zoneCFrame.LookVector.Z)
            if direction.Magnitude <= 0.01 then direction = Vector3.new(1, 0, 0) end
            direction = direction.Unit
            local destination = zoneCFrame.Position + direction * 35 + Vector3.new(0, 3, 0)
            root.CFrame = CFrame.new(destination)

            local events = ReplicatedStorage:FindFirstChild("Events")
            local auctionEvents = events and events:FindFirstChild("Auction")
            local leaveAuction = auctionEvents and auctionEvents:FindFirstChild("LeaveAuction")
            if leaveAuction and leaveAuction:IsA("RemoteFunction") then
                local ok, err = pcall(function()
                    leaveAuction:InvokeServer()
                end)
                if not ok then
                    warn(string.format("[AutoAuction] LeaveAuction failed: %s", tostring(err)))
                end
            else
                warn("[AutoAuction] LeaveAuction RemoteFunction not found")
            end
            return true
        end

        local function runAutoAuctionBids(garage)
            while isRunning() and garage.Parent and garage:GetAttribute("InAuction") == true do
                if stopIfInventoryFull() then break end
                local uiOk, biddingUiOpen = pcall(function()
                    return UIController:IsOpen("AuctionBidding")
                end)
                if Player:GetAttribute("InAuction") == true or (uiOk and biddingUiOpen) then
                    pcall(function() Bid:FireServer() end)
                    task.wait(0.01)
                else
                    task.wait(0.25)
                end
            end
        end

        while isRunning() do
            if stopIfInventoryFull() then break end

            local dynamicAreas, areaSet = {}, {}
            local function addArea(name)
                if type(name) == "string" and name ~= "" and not areaSet[name] then
                    areaSet[name] = true
                    table.insert(dynamicAreas, name)
                end
            end
            for _, name in ipairs(Area) do addArea(name) end

            local selectedArea = Options.SelectAreaD and Options.SelectAreaD.Value
            if type(selectedArea) ~= "string" or selectedArea == "" then
                selectedArea = nil
            end
            local myNetWorth = getPlayerNetWorth()
            local garages = Garage:GetChildren()
            for _, garage in ipairs(garages) do
                local areaName = garage:GetAttribute("AreaName")
                addArea(areaName)
            end
            if Options.SelectAreaD then
                pcall(function() Options.SelectAreaD:SetValues(dynamicAreas) end)
            end

            local candidates, policeCandidates = {}, {}
            for _, garage in ipairs(garages) do
                local areaName = garage:GetAttribute("AreaName")
                local areaMatches = selectedArea == nil or areaName == selectedArea
                if areaMatches and garage:GetAttribute("InAuction") ~= true then
                    table.insert(candidates, garage)
                    if isPoliceGarage(garage) then
                        table.insert(policeCandidates, garage)
                    end
                end
            end

            if OnlyPoliceContainerT and OnlyPoliceContainerT.Value then
                if #policeCandidates > 0 then
                    candidates = policeCandidates
                elseif selectedArea == nil then
                    -- With no area selected, Only Police remains a strict filter.
                    candidates = {}
                end
                -- With an area selected and no police garage available, keep all area candidates as fallback.
            end

            local foundTarget = false
            if isRunning() and #candidates > 0 then
                local garage = candidates[math.random(1, #candidates)]
                local minWorth = getGarageMinNetWorth(garage)
                local zone = garage:FindFirstChild("AuctionZone")

                if minWorth == nil or (minWorth > 0 and (myNetWorth == nil or myNetWorth < minWorth)) then
                    moveAwayFromAuctionZone(zone)
                    print(string.format("[AutoAuction] Skip %s | player Net Worth: %s | garage minimum: %s | requirement not met or unreadable", garage.Name, tostring(myNetWorth), tostring(minWorth)))
                    foundTarget = true
                else
                    local entry = garage:FindFirstChild("EntrySquare")
                    local promptPart = entry and entry:FindFirstChild("PromptPart")
                    local prompt = promptPart and promptPart:FindFirstChild("EnterAuction")
                    local zoneCFrame = getAuctionZoneCFrame(zone)

                    if prompt and prompt:IsA("ProximityPrompt") and hrp then
                        if stopIfInventoryFull() then break end
                        print(string.format("[AutoAuction] Target %s | player Net Worth: %s | garage minimum: %s", garage.Name, tostring(myNetWorth), tostring(minWorth)))
                        if zoneCFrame then
                            hrp.CFrame = zoneCFrame + Vector3.new(0, 3, 0)
                            task.wait(0.2)
                        end
                        if not isRunning() then break end

                        if fireproximityprompt then
                            pcall(function() fireproximityprompt(prompt) end)
                        else
                            pcall(function() prompt:InputHoldBegin(); task.wait(prompt.HoldDuration); prompt:InputHoldEnd() end)
                        end

                        if not waitForGarageState(garage, true, 3) then
                            task.wait(0.25)
                            continue
                        end

                        -- Wait for the bidding screen and read its current opening bid.
                        local bidReady = false
                        local startBid
                        local priceDeadline = os.clock() + 10
                        repeat
                            if not isRunning() or not garage.Parent or garage:GetAttribute("InAuction") ~= true then break end
                            local playerInAuction = Player:GetAttribute("InAuction") == true
                            local numericPrice = tonumber(AuctionStartingBid())
                            if playerInAuction and numericPrice and numericPrice > 0 then
                                startBid = numericPrice
                                bidReady = true
                                break
                            end
                            task.wait(1)
                        until os.clock() >= priceDeadline

                        if not isRunning() then break end
                        if not bidReady then
                            print(string.format("[AutoAuction] %s | Could not read opening bid (player/garage auction state or bid price not ready); auto bid skipped", garage.Name))
                            waitForGarageState(garage, false, 300)
                            moveAwayFromAuctionZone(zone)
                            foundTarget = true
                        else
                            local minPrice = tonumber(Options.MinStartPrice and Options.MinStartPrice.Value) or 0
                            if startBid < minPrice then
                                print(string.format("[AutoAuction] %s | Opening bid %s < Min %s | below minimum; auto bid skipped", garage.Name, tostring(startBid), tostring(minPrice)))
                                moveAwayFromAuctionZone(zone)
                            else
                                print(string.format("[AutoAuction] %s | Opening bid %s >= Min %s | meets minimum; AutoAuction bidding started", garage.Name, tostring(startBid), tostring(minPrice)))
                                runAutoAuctionBids(garage)
                            end

                            waitForGarageState(garage, false, 300)
                            moveAwayFromAuctionZone(zone)
                            foundTarget = true
                        end
                    else
                        foundTarget = true
                        task.wait(0.5)
                    end
                end
            end
            if foundTarget and isRunning() then task.wait(0.5) else task.wait(1) end
        end
    end)
end)

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
                    task.wait(0.01)
                else
                    task.wait(1)
                end
            end
        end)
    end
end)

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

local loadItemT = AuctionMainLeftGroupbox:AddToggle("loadItemT", {
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

local PickUpT = AuctionMainLeftGroupbox:AddToggle("PickUpT", {
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

                            if item:IsA("Model") then
                                local owner = item:GetAttribute("Owner")
                                
                                if owner and (owner == Player.UserId or owner == tostring(Player.UserId) or owner == Player.Name) then
                                    
                                    -- ระบบค้นหา ProximityPrompt แบบครอบคลุมทุกกรณี
                                    local prompt = nil
                                    
                                    -- วิธีที่ 1: หา ProximityPrompt ตัวแรกที่เจอใน Model นี้แบบลึกสุดใจ (Deep Search)
                                    prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                    
                                    -- วิธีที่ 2 (สำรอง): ถ้าวิธีแรกไม่เจอ ให้ลองหาตามชื่อยอดฮิต เช่น "PickupPrompt" หรือ "Prompt"
                                    if not prompt then
                                        for _, descendant in ipairs(item:GetDescendants()) do
                                            if descendant:IsA("ProximityPrompt") then
                                                prompt = descendant
                                                break
                                            end
                                        end
                                    end
                                    
                                    if prompt then
                                        -- หาพาร์ทสำหรับให้ตัวละครวาร์ปไปเกาะ (เอาตัว Prompt เป็นหลัก ถ้าไม่มีค่อยใช้ PrimaryPart)
                                        local targetPart = prompt.Parent
                                        if hrp then
                                            if targetPart and targetPart:IsA("BasePart") then
                                                hrp.CFrame = targetPart.CFrame * CFrame.new(0, 2, 0)
                                            elseif item.PrimaryPart then
                                                hrp.CFrame = item.PrimaryPart.CFrame * CFrame.new(0, 2, 0)
                                            end
                                            task.wait(0.05)
                                        end

                                        -- ตั้งค่า Prompt ให้กดได้ทันที
                                        if prompt.HoldDuration ~= 0 or prompt.MaxActivationDistance < 9999 then
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

                                local hasBuffs = false
                                if itemData.RolledAttributes ~= nil then
                                    if type(itemData.RolledAttributes) == "table" then
                                        if type(itemData.RolledAttributes.Buffs) == "table" and #itemData.RolledAttributes.Buffs > 0 then
                                            hasBuffs = true
                                        elseif itemData.RolledAttributes.Multiplier or (type(itemData.RolledAttributes.Nerfs) == "table" and #itemData.RolledAttributes.Nerfs > 0) then
                                            hasBuffs = true
                                        end
                                    else
                                        hasBuffs = true
                                    end
                                end

                                local isFavorited = itemData.Favorited == true
                                local fitsOnShelf = previewResult.Fits and previewResult.Fits[guid] == true
                                
                                -- ป้องกันไม่ให้นำไอเทมที่เข้าเกณฑ์ Auto Grading ไปขึ้นชั้นขาย
                                local isReservedForGrading = false
                                if AutoGradingT and AutoGradingT.Value then
                                    local isUnGraded = (itemData.Grade == nil)
                                    local isGoodCondition = (not itemData.Condition or itemData.Condition >= 50)
                                    if isUnGraded and isGoodCondition and not isTrophyItem then
                                        isReservedForGrading = true
                                    end
                                end
                                
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

---------------------------------------------------------------------
-- Quick Sell Groupbox
---------------------------------------------------------------------
local QuickSellLeftGroupbox = Tabs.Main:AddLeftGroupbox("Quick Sell")

local QuickSellT = QuickSellLeftGroupbox:AddToggle("QuickSellT", {
    Text = "Auto Quick Sell",
    Default = false,
})

local SellAtMaxInventoryT = QuickSellLeftGroupbox:AddToggle("SellAtMaxInventoryT", {
    Text = "Sell At Max Inventory",
    Default = false,
})

local QuickSellMinRateS = QuickSellLeftGroupbox:AddSlider("QuickSellMinRateS", {
    Text = "Min Rate (%)",
    Default = 0,
    Min = -50,
    Max = 50,
    Rounding = 0,
    Compact = false,
})

local IgnoreRarityQuickSellDd = QuickSellLeftGroupbox:AddDropdown("IgnoreRarityQuickSellDd", {
    Text = "Ignore Rarity",
    Values = Rarity,
    Default = {},
    Multi = true,
    AllowNull = true,
})

local IgnoreFavoriteQuickSellT = QuickSellLeftGroupbox:AddToggle("IgnoreFavoriteQuickSellT", {
    Text = "Ignore Favorite",
    Default = true,
})

local IgnoreTrophyQuickSellT = QuickSellLeftGroupbox:AddToggle("IgnoreTrophyQuickSellT", {
    Text = "Ignore Trophy",
    Default = true,
})

QuickSellT:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while QuickSellT.Value do
                if GetPawnStateRemote and SellItemsRemote then
                    local shouldSell = not (SellAtMaxInventoryT and SellAtMaxInventoryT.Value)
                    if SellAtMaxInventoryT and SellAtMaxInventoryT.Value then
                        local invCount = tonumber(Player:GetAttribute("InventoryCount"))
                        local invCap = tonumber(Player:GetAttribute("InventoryCap"))
                        shouldSell = invCount ~= nil and invCap ~= nil and invCap > 0 and invCount >= invCap
                    end

                    if shouldSell then
                        local ok, stateRes = pcall(function()
                            return GetPawnStateRemote:InvokeServer()
                        end)

                        if ok and type(stateRes) == "table" then
                            local rawRate = tonumber(stateRes.rate) or 1
                            local currentDisplayRate = math.floor((rawRate - 1) * 100 + 0.5)
                            local minAllowedRate = QuickSellMinRateS.Value

                            if currentDisplayRate >= minAllowedRate then
                                local invOk, invItems = pcall(function()
                                    return InventoryEvents.GetPlayerInventory:InvokeServer()
                                end)

                                if invOk and type(invItems) == "table" then
                                    local guidsToSell = {}
                                    for guid, itemData in pairs(invItems) do
                                        local itemDef = Items[tostring(itemData.ItemId)] or Items[itemData.ItemId]
                                        local itemRarity = itemDef and itemDef.Rarity or "Junk"
                                        local isIgnoredRarity = IgnoreRarityQuickSellDd.Value[itemRarity] == true

                                        local isTrophyItem = false
                                        if IgnoreTrophyQuickSellT and IgnoreTrophyQuickSellT.Value then
                                            if itemData.IsTrophy == true or itemData.Name == "Gavel Trophy" then
                                                isTrophyItem = true
                                            elseif TrophyConfig and TrophyConfig.TrophyItemId and itemData.ItemId then
                                                if tostring(itemData.ItemId) == tostring(TrophyConfig.TrophyItemId) then
                                                    isTrophyItem = true
                                                end
                                            end
                                        end

                                        local isFavorited = false
                                        if IgnoreFavoriteQuickSellT and IgnoreFavoriteQuickSellT.Value then
                                            isFavorited = itemData.Favorited == true
                                        end

                                        local hasBuffs = false
                                        if itemData.RolledAttributes ~= nil then
                                            if type(itemData.RolledAttributes) == "table" then
                                                if type(itemData.RolledAttributes.Buffs) == "table" and #itemData.RolledAttributes.Buffs > 0 then
                                                    hasBuffs = true
                                                elseif itemData.RolledAttributes.Multiplier or (type(itemData.RolledAttributes.Nerfs) == "table" and #itemData.RolledAttributes.Nerfs > 0) then
                                                    hasBuffs = true
                                                end
                                            else
                                                hasBuffs = true
                                            end
                                        end

                                        -- ป้องกันไม่ให้ Quick Sell กวาดไอเทมที่เตรียมส่งเกรดดาวขายทิ้ง
                                        local isReservedForGrading = false
                                        if AutoGradingT and AutoGradingT.Value then
                                            local isUnGraded = (itemData.Grade == nil)
                                            local isGoodCondition = (not itemData.Condition or itemData.Condition >= 50)
                                            if isUnGraded and isGoodCondition and not isTrophyItem then
                                                isReservedForGrading = true
                                            end
                                        end

                                        if not isTrophyItem and not isFavorited and not hasBuffs and not isReservedForGrading and not isIgnoredRarity then
                                            table.insert(guidsToSell, guid)
                                            if #guidsToSell >= 15 then break end
                                        end
                                    end

                                    if #guidsToSell > 0 then
                                        pcall(function()
                                            SellItemsRemote:InvokeServer(guidsToSell)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(5)
            end
        end)
    end
end)

local MiscMainLeftGroupbox = Tabs.Main:AddLeftGroupbox("Misc")

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
-- Grading Groupbox (อัปเดตระบบจัดลำดับและดึงรอบละหลายชิ้น)
---------------------------------------------------------------------
local GradingRightGroupbox = Tabs.Main:AddRightGroupbox("Grading")

local GradingPriorityDd = GradingRightGroupbox:AddDropdown("GradingPriorityDd", {
    Text = "Priority",
    Values = { "Rarity", "Most Value", "Both" },
    Default = "Both",
    Multi = false,
    AllowNull = false,
})

local IgnoreGradingTrophyT = GradingRightGroupbox:AddToggle("IgnoreGradingTrophyT", {
    Text = "Ignore Trophy",
    Default = true,
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

                    -- 1. เคลมและเก็บไอเทมที่ตรวจเกรดเสร็จแล้ว
                    for slotIndex = 1, unlockedCount do
                        if not AutoGradingT.Value then break end

                        local slotData = slots[tostring(slotIndex)]

                        if slotData then
                            if slotData.Grade then
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
                                        
                                        local formattedGrade = rawGrade
                                        if rawGrade == "Replica" then
                                            formattedGrade = "❌"
                                        elseif rawGrade == "OneStar" then
                                            formattedGrade = "⭐"
                                        elseif rawGrade == "TwoStar" then
                                            formattedGrade = "⭐⭐"
                                        elseif rawGrade == "ThreeStar" then
                                            formattedGrade = "⭐⭐⭐"
                                        end

                                        if isNotificationSelected("Grade Item") then
                                            Library:Notify({
                                                Title = "SUCCESS • COLLECTED",
                                                Description = string.format("[%d] %s -> %s", slotIndex, itemName, formattedGrade),
                                                Time = 10
                                            })
                                        end

                                        task.wait(1.2)
                                        pcall(function()
                                            ClaimGradedItemRemote:InvokeServer(slotIndex)
                                        end)
                                        task.wait(1.2)
                                    end
                                end
                            end
                        end
                    end

                    -- 2. ดึงรายการไอเทมที่สามารถส่งเกรดได้ทั้งหมด
                    local gradableOk, gradableData = pcall(function()
                        return GetGradableItemsRemote:InvokeServer()
                    end)

                    local rawItems = (gradableOk and type(gradableData) == "table" and gradableData.items) or {}
                    local gradableList = {}

                    for _, itemInfo in ipairs(rawItems) do
                        local data = itemInfo.data
                        if data and (not data.Grade) and (not data.Condition or data.Condition >= 50) then
                            
                            local isTrophyItem = IgnoreGradingTrophyT.Value and isTrophyItemData(data)

                            if not isTrophyItem then
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
                    end

                    -- 3. จัดเรียงลำดับจากมากไปน้อย (ตาม Dropdown ที่เลือก: Rarity, Most Value หรือ Both)
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

                    -- 4. ส่งไอเทมที่ดีที่สุด (ตามลำดับที่จัดไว้) เข้าสู่ช่องว่างที่ว่างอยู่
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
                                    
                                    local slotDuration = (startRes.slotData and startRes.slotData.Duration) or 5
                                    local durationText = slotDuration .. "s"
                                    if slotDuration >= 60 then
                                        durationText = math.floor(slotDuration / 60) .. "m"
                                    end

                                    if isNotificationSelected("Grade Item") then
                                        Library:Notify({
                                            Title = "START • GRADING",
                                            Description = string.format("[%d] %s (%s)", slotIndex, itemName, durationText),
                                            Time = 10
                                        })
                                    end

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

local LostItemMainLeftGroupbox = Tabs.Main:AddRightGroupbox("Lost Item")

local AutoCollectLostItemsT = LostItemMainLeftGroupbox:AddToggle("AutoCollectLostItemsT", {
    Text = "Auto Collect Lost Items",
    Default = false,
})

local autoCollectLostRunId = 0
AutoCollectLostItemsT:OnChanged(function(Value)
    autoCollectLostRunId = autoCollectLostRunId + 1
    local runId = autoCollectLostRunId
    if not Value then return end

    task.spawn(function()
        local function isRunning()
            return AutoCollectLostItemsT.Value and autoCollectLostRunId == runId
        end

        local uiEvents = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UI")
        local getLostItems = uiEvents:WaitForChild("GetLostItems")
        local claimLostItem = uiEvents:WaitForChild("ClaimLostItem")

        while isRunning() do
            for _, areaName in ipairs(Area) do
                if not isRunning() then break end

                local getOk, result = pcall(function()
                    return getLostItems:InvokeServer(areaName)
                end)

                local items = getOk and type(result) == "table" and result.items
                if type(items) == "table" then
                    for guid in pairs(items) do
                        if not isRunning() then break end
                        if type(guid) == "string" then
                            local claimOk, claimResult = pcall(function()
                                return claimLostItem:InvokeServer(areaName, guid)
                            end)
                            if not claimOk then
                                -- warn(string.format("[AutoCollectLostItems] Claim failed for %s in %s: %s", guid, areaName, tostring(claimResult)))
                            end
                            task.wait(0.15)
                        end
                    end
                end
            end

            task.wait(2)
        end
    end)
end)

local NotificationMainRightGroupbox = Tabs.Main:AddRightGroupbox("Notification")

local SelectNotifyD = NotificationMainRightGroupbox:AddDropdown("SelectNotifyD", {
    Text = "Select",
    Values = { "Grade Item", "Police Container" },
    Default = {},
    Multi = true,
    AllowNull = true
})

local ToggleNotify = NotificationMainRightGroupbox:AddToggle("ToggleNotify", {
    Text = "Enable Notification",
    Default = false
})
ToggleNotify:OnChanged(function(Value)
    
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

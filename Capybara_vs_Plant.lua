local repo = "https://raw.githubusercontent.com/s2000s/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "",
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
    Main = Window:AddTab("", "house"),
    ["UI Settings"] = Window:AddTab("", "settings"),
}

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
end)
---
local buyevent = ReplicatedStorage.Remotes.BuyItem
local collectevent = ReplicatedStorage.Remotes.CollectionMachine
local mutationsponge = ReplicatedStorage.Remotes.MutationSponge
local buymerchant = ReplicatedStorage.Remotes.BuyMerchantItem
local Summon = ReplicatedStorage.Remotes.SummonBoss

-- Event Carrot
local Scrap = ReplicatedStorage.Remotes.RequestScrap

local Plot = workspace.World.Map.Plots
local PottedPlants = workspace.World.Map.PottedPlants.Server
local PlacedItems = workspace.World.Map.PlacedItems.Server
local myplot

repeat
    myplot = nil

    for _, plot in ipairs(Plot:GetChildren()) do
        if plot:GetAttribute("Owner") == Player.UserId then
            myplot = plot.Name
            break
        end
    end

    if not myplot then
        task.wait(1)
    end
until myplot

local ShopLeftMain = Tabs.Main:AddLeftGroupbox("Shop", "")

local Eggs = {
    "Capybara Egg", "Alpha Capybara Egg", "Archer Capybara Egg",
    "Magic Capybara Egg", "Ghost Capybara Egg", "Golem Capybara Egg",
    "Robot Capybara Egg", "Disco Capybara Egg", "Angel Capybara Egg",
}

local Gears = {
    "Hatch Hammer", "Nametag", "Mutation Sponge", "Boombox", "Bizarre Stopwatch",
}

local Merchant = {
    "Raygun",
    "Alien Tesla",
    "Totem Of Stars",
    "Totem Of Might",
    "Totem Of Marrow",
    "Rainbow Scroll",
    "Gilded Hatch Hammer",
    "Gold Scroll",
    "Totem Of Status",
    "Moonlit Scroll",
    "Chilly Scroll",
    "Toasty Scroll",
    "Tranquil Scroll",
    "Shocked Scroll",
    "Glitched Scroll"
}

ShopLeftMain:AddDivider("Eggs")

local SelectEggsDropdown = ShopLeftMain:AddDropdown("SelectEggsDropdown", {
    Text = "Select Eggs",
    Values = Eggs,
    Default = "",
    Multi = true,
    AllowNull = true,
    Searchable = true,
})

local SelectEggs = {}
SelectEggsDropdown:OnChanged(function(Value)
    SelectEggs = {}
    for egg, selected in pairs(Value) do
        if selected then
            table.insert(SelectEggs, egg)
        end
    end
end)

local AutoBuyToggle = ShopLeftMain:AddToggle("AutoBuyToggle", {
    Text = "Auto Buy Eggs",
    Default = false,
})

AutoBuyToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoBuyToggle.Value do
                if #SelectEggs > 0 then
                    for _, egg in ipairs(SelectEggs) do
                        if not AutoBuyToggle.Value then
                            return
                        end

                        buyevent:FireServer(egg)
                        task.wait(0.1)
                    end
                else
                    task.wait(0.5)
                end
            end
        end)
    end
end)

ShopLeftMain:AddDivider("Gears")

local SelectGearsDropdown = ShopLeftMain:AddDropdown("SelectGearsDropdown", {
    Text = "Select Gears",
    Values = Gears,
    Default = "",
    Multi = true,
    AllowNull = true,
    Searchable = true,
})

local SelectGears = {}
SelectGearsDropdown:OnChanged(function(Value)
    SelectGears = {}
    for gear, selected in pairs(Value) do
        if selected then
            table.insert(SelectGears, gear)
        end
    end
end)

local AutoBuyGearsToggle = ShopLeftMain:AddToggle("AutoBuyGearsToggle", {
    Text = "Auto Buy Gears",
    Default = false,
})

AutoBuyGearsToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoBuyGearsToggle.Value do
                if #SelectGears > 0 then
                    for _, gear in ipairs(SelectGears) do
                        if not AutoBuyGearsToggle.Value then return end

                        buyevent:FireServer(gear)
                        task.wait(0.1)
                    end
                else
                    task.wait(0.5)
                end
            end
        end)
    end
end)

ShopLeftMain:AddDivider("Traveling Merchant")

local SelectMerchantDropdown = ShopLeftMain:AddDropdown("SelectMerchantDropdown", {
    Text = "Merchant Items",
    Values = Merchant,
    Default = "",
    Multi = true,
    AllowNull = true,
    Searchable = true,
})

local SelectMerchant = {}
SelectMerchantDropdown:OnChanged(function(Value)
    SelectMerchant = {}
    for item, selected in pairs(Value) do
        if selected then
            table.insert(SelectMerchant, item)
        end
    end
end)

local AutoBuyMerToggle = ShopLeftMain:AddToggle("AutoBuyMerToggle", {
    Text = "Auto Buy Items",
    Default = false,
})

AutoBuyMerToggle:OnChanged(function(Value)
    if not Value then
        return
    end

    task.spawn(function()
        while AutoBuyMerToggle.Value do
            if #SelectMerchant > 0 then
                for _, item in ipairs(SelectMerchant) do
                    if not AutoBuyMerToggle.Value then
                        return
                    end

                    buymerchant:FireServer(item)
                    task.wait(0.1)
                end
            else
                task.wait(0.5)
            end
        end
    end)
end)

local MoneyLeftMain = Tabs.Main:AddLeftGroupbox("Money", "")

local AutoCollectMoney = MoneyLeftMain:AddToggle("AutoCollectMoney", {
    Text = "Auto Collect Money",
    Default = false,
})

AutoCollectMoney:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoCollectMoney.Value do
                collectevent:FireServer()
                task.wait(1)
            end
        end)
    end
end)

local EventRightMain = Tabs.Main:AddRightGroupbox("Event", "")

local BossEvent = {
    "Dr Carrot", "Dr Carbot MkI", "Dr Carbot MkII", "Dr Carbot MkIII"
}

local SelectBossEventDropdown = EventRightMain:AddDropdown("SelectBossEvent", {
    Text = "Select Boss",
    Values = BossEvent,
    Default = "",
    Multi = true,
    AllowNull = true,
    Searchable = true,
})

local SelectBossEvent = {}
SelectBossEventDropdown:OnChanged(function(Value)
    SelectBossEvent = {}
    for boss, selected in pairs(Value) do
        if selected then
            table.insert(SelectBossEvent, boss)
        end
    end
end)

local AutoSummonToggle = EventRightMain:AddToggle("AutoSummonToggle", {
    Text = "Auto Summon",
    Default = false,
})

AutoSummonToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while AutoSummonToggle.Value do
                if #SelectBossEvent > 0 then
                    for _, boss in ipairs(SelectBossEvent) do
                        if not AutoSummonToggle.Value then return end

                        Summon:InvokeServer("Summon", boss)
                        task.wait(10)
                    end
                else
                    task.wait(0.5)
                end
            end
        end)
    end
end)

EventRightMain:AddDivider("Scrap")

local ScrapToggle = EventRightMain:AddToggle("ScrapToggle", {
    Text = "Auto Scrap",
    Default = false,
})

ScrapToggle:OnChanged(function(Value)
    if Value then
        task.spawn(function()
            while ScrapToggle.Value do
                local backpack = Player:FindFirstChildOfClass("Backpack")

                if backpack then
                    for _, item in ipairs(backpack:GetChildren()) do
                        if not ScrapToggle.Value then break end

                        if item:IsA("Tool") then
                            for _, bossName in ipairs(BossEvent) do
                                if not ScrapToggle.Value then return end
                                if string.find(item.Name, bossName, 1, true) then
                                    humanoid:EquipTool(item)
                                    task.wait(0.1)

                                    Scrap:InvokeServer({ Request = "Scrap" })
                                    task.wait(0.1)
                                    break
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

local PlotRightMain = Tabs.Main:AddRightGroupbox("Plot", "")

local Mutation = {
    "Radiant", "Moonlit", "Chilly", "Toasty", "Tranquil", "Shocked",
    "Celestial", "Permafrost", "Scorched", "Glitched", "Flipped", "Taco", "Mega",
}

local selectedmutation = {}
local SelectMutationDropdown = PlotRightMain:AddDropdown("SelectMutationDropdown", {
    Text = "Select Mutations",
    Values = Mutation,
    Default = "",
    Multi = true,
    AllowNull = true,
    Searchable = true,
})

SelectMutationDropdown:OnChanged(function(Value)
    selectedmutation = {}

    for mutation, selected in pairs(Value) do
        if selected then
            selectedmutation[mutation] = true
        end
    end
end)

local RemoveMutationToggle = PlotRightMain:AddToggle("RemoveMutationToggle", {
    Text = "Auto Remove Mutations",
    Default = false,
})

RemoveMutationToggle:OnChanged(function(Value)
    if not Value then
        local equippedTool = char and char:FindFirstChildOfClass("Tool")

        if humanoid and equippedTool and equippedTool.Name:match("^Mutation Sponge") then
            humanoid:UnequipTools()
        end
        return
    end

    task.spawn(function()
        while RemoveMutationToggle.Value do
            local equippedTool = char and char:FindFirstChildOfClass("Tool")
            local isHoldingSponge = equippedTool and equippedTool.Name:match("^Mutation Sponge")

            if not isHoldingSponge then
                task.wait(0.2)
                continue
            end

            local actions = {}

            if next(selectedmutation) ~= nil then
                for _, container in ipairs({ PottedPlants, PlacedItems }) do
                    for _, target in ipairs(container:GetChildren()) do
                        if tostring(target:GetAttribute("Plot")) == tostring(myplot) then
                            local config = target:FindFirstChild("ServerConfiguration", true)

                            if config then
                                if container == PottedPlants then
                                    local potNumber = config:FindFirstChild("PotNumber")

                                    if not potNumber then continue end

                                    if tonumber(potNumber.Value) and tonumber(potNumber.Value) < 0 then
                                        continue
                                    end
                                end

                                local mutationsValue = config:FindFirstChild("Mutations")

                                if mutationsValue then
                                    for mutation in string.gmatch(tostring(mutationsValue.Value), "([^,]+)") do
                                        mutation = mutation:match("^%s*(.-)%s*$")

                                        if selectedmutation[mutation] then
                                            table.insert(actions, { Target = target, Mutation = mutation, })
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            for _, action in ipairs(actions) do
                equippedTool = char and char:FindFirstChildOfClass("Tool")

                if not (equippedTool and equippedTool.Name:match("^Mutation Sponge")) then break end

                mutationsponge:FireServer(action.Target, action.Mutation)

                task.wait(0.2)
            end

            task.wait(0.5)
        end
    end)
end)

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
SaveManager:SetSubFolder("Capybara vs Plants")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = false

local Window = Library:CreateWindow({
	Title = "BYTE X",
	Footer = "Build a Zoo - 1.00.11.1",
    Size = UDim2.fromOffset(650, 620), -- กว้าง,ยาว
	NotifySide = "Right",
	ShowCustomCursor = false,
    DisableSearch = true,
    Center = true,
})

local Tabs = {
	Main = Window:AddTab("Main", "user"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local hrp = player.Character.HumanoidRootPart
local humanoid = player.Character.Humanoid

local LeftGroupBoxMainAutomation = Tabs.Main:AddLeftGroupbox("Automation", "")

local EggsList = {
    "BasicEgg",
    "RareEgg",
    "SuperRareEgg",
    "SeaweedEgg",
    "EpicEgg",
    "LegendEgg",
    "ClownfishEgg",
    "SnowbunnyEgg",
    "PrismaticEgg",
    "LionfishEgg",
    "HyperEgg",
    "DarkGoatyEgg",
    "VoidEgg",
    "BowserEgg",
    "SharkEgg",
    "DemonEgg",
    "RhinoRockEgg",
    "CornEgg",
    "AnglerfishEgg",
    "BoneDragonEgg",
    "UltraEgg",
    "DinoEgg",
    "FlyEgg",
    "SaberCubEgg",
    "UnicornEgg",
    "OctopusEgg",
    "AncientEgg",
    "SeaDragonEgg",
    "UnicornProEgg",
    "GeneralKongEgg",
    "PegasusEgg"
}

local MutationList = {
    "Golden",
    "Diamond",
    "Electric",
    "Fire",
    "Jurassic",
    "Snow"
}

local FoodsList = {
    "Strawberry",
    "Blueberry",
    "Watermelon",
    "Apple",
    "Orange",
    "Corn",
    "Banana",
    "Grape",
    "Pear",
    "Pineapple",
    "DragonFruit",
    "GoldMango",
    "BloodstoneCycad",
    "ColossalPinecone",
    "VoltGinkgo",
    "DeepseaPearlFruit",
    "Durian"
}

local SelectEggs = {}
local AutoBuyEggsVar = false

local SelectMutations = {}

local SelectFoods = {}
local AutoBuyFoodsVar = false
local DelayAutoBuyFoods = 1

local AutoCollectVar = false
local DelayAutoCollectVar = 1

-- GetLocalPlayerIsland func
function GetLocalPlayerIsland()
    for _, island in ipairs(workspace.Art:GetChildren()) do
        if island:IsA("Model") and island:GetAttribute("OccupyingPlayerId") == player.UserId then
            return island
        end
    end
    return nil
end

-- AutoBuyEgg func
-- function AutoBuyEggfunc()
--     task.spawn(function()
--         while AutoBuyEggsVar do
--             local CharacterRE = ReplicatedStorage.Remote.CharacterRE
--             local LocalPlayerIsland = GetLocalPlayerIsland()

--             if LocalPlayerIsland then
--                 local ConveyorFolder = LocalPlayerIsland:WaitForChild("ENV"):WaitForChild("Conveyor")

--                 for _, conveyor in ipairs(ConveyorFolder:GetChildren()) do
--                     if conveyor:IsA("Model") then
--                         local Belt = conveyor:FindFirstChild("Belt")
--                         if Belt then
--                             for _, obj in ipairs(Belt:GetChildren()) do
--                                 if obj:IsA("Model") then
--                                     local Type = obj:GetAttribute("Type")
                                    
--                                     if Type and table.find(SelectEggs, Type) then
--                                         CharacterRE:FireServer("BuyEgg", obj.Name)
--                                         -- print("ซื้อไข่:", Type, "จาก", obj.Name)
--                                     end
--                                 end
--                             end
--                         end
--                     end
--                 end
--             end
--             task.wait(1)
--         end
--     end)
-- end

function AutoBuyEggfunc()
    task.spawn(function()
        while AutoBuyEggsVar do
            local CharacterRE = ReplicatedStorage.Remote.CharacterRE
            local LocalPlayerIsland = GetLocalPlayerIsland()

            if LocalPlayerIsland then
                local ConveyorFolder = LocalPlayerIsland:WaitForChild("ENV"):WaitForChild("Conveyor")

                for _, conveyor in ipairs(ConveyorFolder:GetChildren()) do
                    if conveyor:IsA("Model") then
                        local Belt = conveyor:FindFirstChild("Belt")
                        if Belt then
                            for _, obj in ipairs(Belt:GetChildren()) do
                                if obj:IsA("Model") then
                                    local Type = obj:GetAttribute("Type")
                                    
                                    if Type and table.find(SelectEggs, Type) then
                                        local canBuy = true
                                        local mutateText = "None" -- ค่า default

                                        -- Debug: ตรวจสอบ Mutate.Text
                                        if obj:FindFirstChild("RootPart") then
                                            local guiEgg = obj.RootPart:FindFirstChild("GUI/EggGUI")
                                            if guiEgg then
                                                local mutate = guiEgg:FindFirstChild("Mutate")
                                                if mutate and mutate:IsA("TextLabel") then
                                                    mutateText = mutate.Text
                                                    --print("✅ เจอ Mutate.Text ของ", obj.Name, "=", mutateText)
                                                else
                                                    --warn("❌ ไม่มี Mutate หรือไม่ใช่ TextLabel ของ", obj.Name)
                                                end
                                            else
                                                --warn("❌ ไม่มี GUI/EggGUI ของ", obj.Name)
                                            end
                                        else
                                            --warn("❌ ไม่มี RootPart ของ", obj.Name)
                                        end

                                        -- เช็ค SelectMutations
                                        if SelectMutations and #SelectMutations > 0 then
                                            if not table.find(SelectMutations, mutateText) then
                                                canBuy = false
                                            end
                                        end

                                        if canBuy then
                                            CharacterRE:FireServer("BuyEgg", obj.Name)
                                            --print("ซื้อไข่:", Type, "Mutation:", mutateText, "จาก", obj.Name)
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
end


function AutoBuyFoodsfunc()
    task.spawn(function()
        while AutoBuyFoodsVar do
            local FoodStoreRE = ReplicatedStorage.Remote.FoodStoreRE

            for _, food in ipairs(SelectFoods) do
                FoodStoreRE:FireServer(food)
            end

            task.wait(DelayAutoBuyFoods)
        end
    end)
end


-- AutoCollect func
function AutoCollectfunc()
    task.spawn(function()
        while AutoCollectVar do
            local PetsFolder = workspace:WaitForChild("Pets")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Time = ReplicatedStorage:WaitForChild("Time")

            local s = Time:GetAttribute("s")
            local t = Time.Value
            local userId = player.UserId

            for _, pet in ipairs(PetsFolder:GetChildren()) do
                if not AutoCollectVar then return end
                
                if pet:GetAttribute("UserId") == userId then
                    local RE = pet:FindFirstChild("RE")
                    if RE then
                        RE:FireServer(
                            "Claim",
                            bit32.bxor(userId, s, t)
                        )
                    end
                end
            end

            task.wait(DelayAutoCollectVar)
        end
    end)
end


local SelectEggsDropdown = LeftGroupBoxMainAutomation:AddDropdown("SelectEggsDropdown", {
	Values = EggsList,
	Default = {},
	Multi = true,
    Disabled = false,
	Visible = true,
    Searchable = true,

	Text = "Select Eggs",

	Callback = function(Value)
        SelectEggs = {}

        for i in pairs(Options.SelectEggsDropdown.Value) do 
            table.insert(SelectEggs, i) 
        end
	end,
})

local SelectMutationDropdown = LeftGroupBoxMainAutomation:AddDropdown("SelectMutationDropdown", {
	Values = MutationList,
	Default = {},
	Multi = true,
    Disabled = false,
	Visible = true,
    Searchable = true,

	Text = "Select Mutations",

	Callback = function(Value)
        SelectMutations = {}

        for i in pairs(Options.SelectMutationDropdown.Value) do 
            table.insert(SelectMutations, i) 
        end
	end,
})

local AutoBuyEggsToggle = LeftGroupBoxMainAutomation:AddToggle("AutoBuyEggs", {
    Text = "Auto Buy Eggs",
    Default = false,
})

AutoBuyEggsToggle:OnChanged(function(Value)
    AutoBuyEggsVar = Value

    if AutoBuyEggsVar then
        GetLocalPlayerIsland()
        AutoBuyEggfunc()
    end
end)

local SelectFoodDropdown = LeftGroupBoxMainAutomation:AddDropdown("SelectFoodDropdown", {
	Values = FoodsList,
	Default = {},
	Multi = true,
    Searchable = true,

	Text = "Select Foods",

    Callback = function(Value)
        SelectFoods = {}
        for i in pairs(Options.SelectFoodDropdown.Value) do
            table.insert(SelectFoods, i)
        end
    end,
})

local AutoBuyFoodsToggle = LeftGroupBoxMainAutomation:AddToggle("AutoBuyFoodsToggle", {
    Text = "Auto Buy Foods",
    Default = false,
})

local DelayAutoBuyFoodsSlider = LeftGroupBoxMainAutomation:AddSlider("DelayAutoBuyFoodsSlider", {
    Text = "Delays (second)",
    Default = 1,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Visible = false,
})

AutoBuyFoodsToggle:OnChanged(function(Value)
    AutoBuyFoodsVar = Value

    DelayAutoBuyFoodsSlider:SetVisible(AutoBuyFoodsVar)

    if AutoBuyFoodsVar then
        AutoBuyFoodsfunc()
    end
end)

DelayAutoBuyFoodsSlider:OnChanged(function(Value)
    DelayAutoBuyFoods = Value
end)

LeftGroupBoxMainAutomation:AddDivider()

local RightGroupBoxMainCollect = Tabs.Main:AddRightGroupbox("Collect Pets", "")

local AutoCollectToggle = RightGroupBoxMainCollect:AddToggle("", {
    Text = "Auto Collect (Pets)",
    Default = false,
})

local DelayAutoCollectSlider = RightGroupBoxMainCollect:AddSlider("DelayAutoCollect", {
    Text = "Delays (second)",
    Default = 1,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Visible = false,
})

AutoCollectToggle:OnChanged(function(Value)
    AutoCollectVar = Value

    DelayAutoCollectSlider:SetVisible(AutoCollectVar)

    if AutoCollectVar then
        AutoCollectfunc()
    end
end)

DelayAutoCollectSlider:OnChanged(function(Value)
    DelayAutoCollectVar = Value
end)

LeftGroupBoxMainAutomation:AddDivider()

local AddLeftGroupboxMainConveyor = Tabs.Main:AddLeftGroupbox("Conyevor", "")

local AutoUpgradeConveyorVar = false

local AutoUpgradeConveyorToggle = AddLeftGroupboxMainConveyor:AddToggle("",{
    Text = "Auto Upgrade",
    Default = false,
})

AutoUpgradeConveyorToggle:OnChanged(function(Value)
    AutoUpgradeConveyorVar = Value

    if AutoUpgradeConveyorVar then
        task.spawn(function()
            while AutoUpgradeConveyorVar do
                local ConveyorRE = ReplicatedStorage.Remote.ConveyorRE

                for i = 1, 9 do
                    ConveyorRE:FireServer("Upgrade", i)
                    task.wait(0.1)
                end

                task.wait(10)
            end
        end)
    end
end)

local RightGroupboxMainMisc = Tabs.Main:AddRightGroupbox("Misc", "")

local InstantPromptEnabled = false
local AntiAfkVar

function UpdatePrompts()
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            prompt.HoldDuration = InstantPromptEnabled and 0 or 0.1
        end
    end
end

local AntiAfkToggle = RightGroupboxMainMisc:AddToggle("AntiAfkToggle", {
    Text = "Anti Afk",
    Default = true
})

AntiAfkToggle:OnChanged(function(Value)
    if Value then
        AntiAfkVar = player.Idled:Connect(function()
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

local InstantPromtToggle = RightGroupboxMainMisc:AddToggle("InstantPromt", {
    Text = "Instant Prompt",
    Default = false,
})

InstantPromtToggle:OnChanged(function(Value)
    InstantPromptEnabled = Value
    UpdatePrompts()
end)

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") then
        obj.HoldDuration = InstantPromptEnabled and 0 or 0.1
    end
end)

UpdatePrompts()

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
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("MyScriptHub")
SaveManager:SetFolder("MyScriptHub/specific-game")
SaveManager:SetSubFolder("specific-place")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
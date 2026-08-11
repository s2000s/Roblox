
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Redeem = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.CodeService.RF.Redeem
local code = {
    "ThankYou30M","ThankYouFor150k","UnrivaledIsAlive","SixSeven!","ThankYou100k",
    "HereyougoEA!","ThousandsOfCodes!","MaxedOut!","75kLikes!","NumberOne!",
    "Universal!","Mainstream!","ThankYouUTD!","RELEASE!","UNRIVALED!"
}

for _, i in ipairs(code) do
    print(i)
end


local BuyBanner = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.BannerService.RF.BuyBanner
BuyBanner:InvokeServer(
    "SingleSummon",
    "Special"
)


local BuyBanner = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.BannerService.RF.BuyBanner
BuyBanner:InvokeServer(
    "TenSummon",
    "Special"
)


local SetSetting = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.DataService.RE.SetSetting
SetSetting:FireServer(
    "AutoSkipSummon",
    true
)

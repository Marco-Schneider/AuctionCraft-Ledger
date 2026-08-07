local totalBuyoutFrame = CreateFrame("Frame", "MyAHBuyoutFrame", UIParent)
totalBuyoutFrame:SetSize(350, 30)
totalBuyoutFrame:Hide()

local buyoutText = totalBuyoutFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
buyoutText:SetAllPoints(totalBuyoutFrame)
buyoutText:SetJustifyH("CENTER")

local function AnchorToAuctionHouse()
    if AuctionHouseFrame then
        totalBuyoutFrame:SetPoint("BOTTOM", AuctionHouseFrame, "BOTTOM", 0, 0)
        totalBuyoutFrame:SetParent(AuctionHouseFrame)
    end
end

local function UpdateVisibility()
    if AuctionHouseFrame and AuctionHouseFrame.displayMode == AuctionHouseFrameDisplayMode.Auctions then
        totalBuyoutFrame:Show()
    else
        totalBuyoutFrame:Hide()
    end
end

local function UpdateTotalBuyout()
    local auctions = C_AuctionHouse.GetOwnedAuctions()

    if not auctions then
        return end

    local totalBuyout = 0
    for _, auction in ipairs(auctions) do
        local buyout
        if auction.status == 1 then -- Sold: buyoutAmount is already the total
            buyout = auction.buyoutAmount
        else -- Active: buyoutAmount is per-unit price
            buyout = auction.buyoutAmount * auction.quantity
        end
        totalBuyout = totalBuyout + buyout
    end

    buyoutText:SetText("Total buyout: " .. C_CurrencyInfo.GetCoinTextureString(totalBuyout))
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("OWNED_AUCTIONS_UPDATED")
eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")

local hasHookedTabs = false

eventFrame:SetScript("OnEvent", function(self, event)
    if event == "AUCTION_HOUSE_SHOW" then
        AnchorToAuctionHouse()
        if not hasHookedTabs then
            hooksecurefunc(AuctionHouseFrame, "SetDisplayMode", function()
                UpdateVisibility()
            end)
            hasHookedTabs = true
        end
        C_AuctionHouse.QueryOwnedAuctions({})
    elseif event == "OWNED_AUCTIONS_UPDATED" then
        UpdateTotalBuyout()
        UpdateVisibility()
    elseif event == "AUCTION_HOUSE_CLOSED" then
        totalBuyoutFrame:Hide()
    end
end)
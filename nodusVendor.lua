local CreateFrame, GetMoney, GetContainerNumSlots, GetContainerNumFreeSlots, GetContainerItemID, GetItemInfo, GetCoinTextureString, ITEM_SOULBOUND =
	CreateFrame, GetMoney, GetContainerNumSlots, GetContainerNumFreeSlots, GetContainerItemID, GetItemInfo, GetCoinTextureString, ITEM_SOULBOUND

local soulboundStrings = {}
local soulboundTooltip = CreateFrame("GameTooltip")
soulboundTooltip:SetOwner(UIParent, "ANCHOR_NONE")
for i = 1, 5 do
	local left, right = soulboundTooltip:CreateFontString(), soulboundTooltip:CreateFontString()
	soulboundTooltip:AddFontStrings(left, right)
	soulboundStrings[i] = left
end

local profitStart

local eventFrame = CreateFrame("FRAME")
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "MERCHANT_SHOW" then
		profitStart = GetMoney()
		for i = 1, 4 do
			local bagSize = GetContainerNumSlots(i)
			if bagSize ~= GetContainerNumFreeSlots(i) then
				for n = 1, bagSize do
					local itemID = GetContainerItemID(i, n)
					if itemID then
						local itemQuality, _, _, _, _, _, _, _, vendorValue =  select(3, GetItemInfo(itemID))
						if vendorValue and vendorValue > 0 then
							if itemQuality == 0 then
								UseContainerItem(i,n)
							else
								soulboundTooltip:SetBagItem(i, n)
								for k, v in ipairs(soulboundStrings) do
									if v:GetText() == ITEM_SOULBOUND then
										UseContainerItem(i,n)
										break
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if event == "MERCHANT_CLOSED" then
		local profitEnd = GetMoney()
		if profitStart < profitEnd then 
			print("|cffffff00Profit:|r", GetCoinTextureString(profitEnd - profitStart))
			profitStart = profitEnd -- in place to prevent spamming due to multiple MERCHANT_CLOSED
		end
	end
end)

eventFrame:RegisterEvent("MERCHANT_SHOW")
eventFrame:RegisterEvent("MERCHANT_CLOSED")
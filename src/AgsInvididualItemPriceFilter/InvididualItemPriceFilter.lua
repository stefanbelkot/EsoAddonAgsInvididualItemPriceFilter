function AgsInvididualItemPriceFilter.InitInvididualItemPriceFilterClass()

	local AGS = AwesomeGuildStore

	local FilterBase = AGS.class.FilterBase
	local ValueRangeFilterBase = AGS.class.ValueRangeFilterBase

	local FILTER_ID = AGS:GetFilterIds()

	local InvididualItemPriceFilter = ValueRangeFilterBase:Subclass()
	AgsInvididualItemPriceFilter.InvididualItemPriceFilter = InvididualItemPriceFilter

	function InvididualItemPriceFilter:New(...)
		return ValueRangeFilterBase.New(self, ...)
	end

	function InvididualItemPriceFilter:Initialize()
		ValueRangeFilterBase.Initialize(self, 
			AgsInvididualItemPriceFilter.internal.FILTER_ID.INDIVIDUAL_ITEM_PRICE_FILTER, 
			FilterBase.GROUP_SERVER, 
			{
				-- TRANSLATORS: label of the deal filter
				label = "Individual Item Price Filter",
				min = 1,
				max = 2,
				steps = {
					{
						id = 1,
						label = "Inactive",
						icon = "AwesomeGuildStore/images/qualitybuttons/normal_%s.dds",
					},
					{
						id = 2,
						label = "Active",
						icon = "AwesomeGuildStore/images/qualitybuttons/magic_%s.dds",
					}
				}
			})

		function InvididualItemPriceFilter:CanFilter(subcategory)
			return true
        end
        
	end

    function InvididualItemPriceFilter:FilterLocalResult(result)
        if (self.localMin == self.localMax and self.localMin == 2) then
            local index = result.itemUniqueId
            local itemLink = GetTradingHouseSearchResultItemLink(index)
			local itemId = GetItemLinkItemId(itemLink)
			local maxPrice = tonumber(AgsInvididualItemPriceFilter.savedVariables[AgsInvididualItemPriceFilter.loggedInWorldName][itemId])
			local minCount = tonumber(AgsInvididualItemPriceFilter.savedVariables[AgsInvididualItemPriceFilter.loggedInWorldName]["mincount"][itemId])
			
			if ((maxPrice == nil or maxPrice <= 0) and (minCount == nil or minCount <= 0)) then
				return true
			end
			
			local deal = true
			if (maxPrice) then
				local unitPrice = result.purchasePrice / result.stackCount
			   	if unitPrice > maxPrice then -- dreugh wax
				   deal = false
			   	end
			end
			
			if (minCount) then
			   	if minCount > result.stackCount then -- dreugh wax
				   deal = false
			   	end
			end

            return deal
		end
		
        return true
	end

	function InvididualItemPriceFilter:GetTooltipText(min, max)
		return ""
	end

	return InvididualItemPriceFilter
end



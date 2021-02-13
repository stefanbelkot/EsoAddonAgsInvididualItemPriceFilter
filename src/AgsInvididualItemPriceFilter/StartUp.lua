
local ADDON_NAME = "AgsInvididualItemPriceFilter"

AgsInvididualItemPriceFilter = {
    internal = {
        chat = LibChatMessage(ADDON_NAME, "InFi"),
        FILTER_ID = {
            INDIVIDUAL_ITEM_PRICE_FILTER = 105
        } -- later the value from AwesomeGuildStore/data/FilterIds.lua should be used
        --gettext = LibGetText(ADDON_NAME).gettext
    },
}
local chat = AgsInvididualItemPriceFilter.internal.chat
local gettext = AgsInvididualItemPriceFilter.internal.gettext

_G[ADDON_NAME] = AgsInvididualItemPriceFilter

function AgsInvididualItemPriceFilter.Initialize()
    local acctDefaults = {
    }

    AgsInvididualItemPriceFilter.savedVariables = ZO_SavedVars:NewAccountWide("AgsInvididualItemPriceFilterVars", 1, nil, acctDefaults, nil, 'AgsInvididualItemPriceFilter')
    AgsInvididualItemPriceFilter.loggedInWorldName = GetWorldName()
    if AgsInvididualItemPriceFilter.savedVariables[AgsInvididualItemPriceFilter.loggedInWorldName] == nil then
        AgsInvididualItemPriceFilter.savedVariables[AgsInvididualItemPriceFilter.loggedInWorldName] = {}
    end

    if AwesomeGuildStore.GetAPIVersion == nil then return end
    if AwesomeGuildStore.GetAPIVersion() ~= 4 then return end
  
    local FILTER_ID = AwesomeGuildStore:GetFilterIds()
  
    local InvididualItemPriceFilter = AgsInvididualItemPriceFilter.InitInvididualItemPriceFilterClass()
    local InvididualItemPriceFilterFragment = AgsInvididualItemPriceFilter.InitInvididualItemPriceFilterFragmentClass()
  
    AwesomeGuildStore:RegisterCallback(AwesomeGuildStore.callback.AFTER_FILTER_SETUP,
      function(...)
        AwesomeGuildStore:RegisterFilter(InvididualItemPriceFilter:New())
        AwesomeGuildStore:RegisterFilterFragment(InvididualItemPriceFilterFragment:New(
            AgsInvididualItemPriceFilter.internal.FILTER_ID.INDIVIDUAL_ITEM_PRICE_FILTER))
      end
    )

    SLASH_COMMANDS["/agsinfi"] = function(args)
        if args == nil or args == "" then
            local text = "format: {itemId} {itemMaxPrice}"
            AgsInvididualItemPriceFilter.internal.chat:Print(text)
        else
            local argtable={}
            
            for match in args:gmatch("%S+") do
                 table.insert(argtable, match);
            end

            local itemId = tonumber(argtable[1])
            if itemId == nil then
                local text = "format wrong: {itemId} {itemMaxPrice} - itemId must be a number!"
                AgsInvididualItemPriceFilter.internal.chat:Print(text)
                return
            end

            local itemMaxPrice = tonumber(argtable[2])
            if itemMaxPrice == nil then
                local text = "format wrong: {itemId} {itemMaxPrice} - itemMaxPrice must be a number!"
                AgsInvididualItemPriceFilter.internal.chat:Print(text)
                return
            end

            AgsInvididualItemPriceFilter.savedVariables[AgsInvididualItemPriceFilter.loggedInWorldName][itemId] = itemMaxPrice
        
            local resultText = "Now the maxprice is set to " .. itemMaxPrice .. "  for item with Id " .. itemId
            AgsInvididualItemPriceFilter.internal.chat:Print(resultText)
        
        end
	end

    ZO_PreHook('ZO_InventorySlot_ShowContextMenu', function(_inventorySlot)
        AgsInvididualItemPriceFilter.ZO_InventorySlot_ShowContextMenu(_inventorySlot)
    end)
end

function AgsInvididualItemPriceFilter.ZO_InventorySlot_ShowContextMenu(inventorySlot)
    local st = ZO_InventorySlot_GetType(inventorySlot)
    link = nil
    if st == SLOT_TYPE_ITEM or st == SLOT_TYPE_EQUIPMENT or st == SLOT_TYPE_BANK_ITEM or st == SLOT_TYPE_GUILD_BANK_ITEM or
    st == SLOT_TYPE_TRADING_HOUSE_POST_ITEM or st == SLOT_TYPE_REPAIR or st == SLOT_TYPE_CRAFTING_COMPONENT or st == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or
    st == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or st == SLOT_TYPE_PENDING_CRAFTING_COMPONENT or st == SLOT_TYPE_CRAFT_BAG_ITEM then
        local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)
        link = GetItemLink(bag, index)
    end

    if st == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
        link = GetTradingHouseSearchResultItemLink(ZO_Inventory_GetSlotIndex(inventorySlot))
    end

    if st == SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING then
        link = GetTradingHouseListingItemLink(ZO_Inventory_GetSlotIndex(inventorySlot), linkStyle)
    end

    if (link and string.match(link, '|H.-:item:(.-):')) then
        zo_callLater(function()
            AgsInvididualItemPriceFilter.zo_callLater(link)
        end, 50)
    end
end

function AgsInvididualItemPriceFilter.zo_callLater(itemLink)
    local itemId = GetItemLinkItemId(itemLink)
    local maxPrice = 0
    if (not (tonumber(AgsInvididualItemPriceFilter.savedVariables[AgsInvididualItemPriceFilter.loggedInWorldName][itemId])  == nil)) then
        maxPrice = AgsInvididualItemPriceFilter.savedVariables[AgsInvididualItemPriceFilter.loggedInWorldName][itemId]
    end

    AddMenuItem("AGS indiv. item price (" .. maxPrice .. ")", function()
        AgsInvididualItemPriceFilter.IndividualItemPriceConfigToChat(itemId)
    end, MENU_ADD_OPTION_LABEL)

    ShowMenu(self)
end

function AgsInvididualItemPriceFilter.IndividualItemPriceConfigToChat(itemId)
    local ChatEditControl = CHAT_SYSTEM.textEntry.editControl
    if (not ChatEditControl:HasFocus()) then 
        StartChatInput() 
    end

    local maxPrice = tonumber(AgsInvididualItemPriceFilter.savedVariables[AgsInvididualItemPriceFilter.loggedInWorldName][itemId])
    if (maxPrice == nil or maxPrice <= 0) then
        ChatEditControl:InsertText("/agsinfi " .. itemId .. " 0")
    else
        ChatEditControl:InsertText("/agsinfi " .. itemId .. " " .. maxPrice)
    end
end

local function OnAddonLoaded()
    AgsInvididualItemPriceFilter.Initialize()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)






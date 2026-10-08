-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Loot
-- Author: Mikord
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {}
local moduleName = "Loot"
MikSBT[moduleName] = module


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various modules for faster access.
local MSBTProfiles = MikSBT.Profiles
local MSBTParser = MikSBT.Parser

-- Get local references to various functions for faster access.
local string_gsub = string.gsub
local string_format = string.format
local math_ceil = math.ceil
local GetItemInfo = GetItemInfo
local GetItemCount = GetItemCount
local DisplayEvent = MikSBT.Animations.DisplayEvent


-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------

-- Money strings.
local GOLD = string_gsub(GOLD_AMOUNT, "%%d ", "")
local SILVER = string_gsub(SILVER_AMOUNT, "%%d ", "")
local COPPER = string_gsub(COPPER_AMOUNT, "%%d ", "")

-- Localized name for item types.
local ITEM_TYPE_QUEST = select(12, GetAuctionItemClasses())


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Color patterns for item qualities.
local qualityPatterns = {}

-- Loot messages waiting for the bags to update (see HandleItems).
local pendingLoot = {}
local LOOT_DELAY = 0.3
local lootDelayFrame = CreateFrame("Frame")
lootDelayFrame:Hide()

local function ShowLootEvent(item)
 local numTotal = GetItemCount(item.link) or 0
 if (numTotal < item.amount) then numTotal = item.amount end
 local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_LOOT
 if (eventSettings and not eventSettings.disabled) then
  local message = eventSettings.message
  message = string_gsub(message, "%%e", item.name)
  message = string_gsub(message, "%%a", item.amount)
  message = string_gsub(message, "%%t", numTotal)
  DisplayEvent(eventSettings, message, item.texture)
 end
end

lootDelayFrame:SetScript("OnUpdate", function(self, elapsed)
 for i = #pendingLoot, 1, -1 do
  local item = pendingLoot[i]
  item.wait = item.wait - elapsed
  if (item.wait <= 0) then
   table.remove(pendingLoot, i)
   ShowLootEvent(item)
  end
 end
 if (#pendingLoot == 0) then self:Hide() end
end)

local function QueueLootDisplay(link, name, texture, amount)
 pendingLoot[#pendingLoot + 1] = { link = link, name = name, texture = texture, amount = amount, wait = LOOT_DELAY }
 lootDelayFrame:Show()
end


-------------------------------------------------------------------------------
-- Event handlers.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Handles looted money.
-- ****************************************************************************
local function HandleMoney(parserEvent)
 -- Money gain.
 local moneyString = parserEvent.moneyString
 moneyString = string_gsub(moneyString, GOLD, "|cffffd700%1|r")
 moneyString = string_gsub(moneyString, SILVER, "|cff808080%1|r")
 moneyString = string_gsub(moneyString, COPPER, "|cffeda55f%1|r")
  
 -- Format the event and display it.
 local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_MONEY
 if (eventSettings and not eventSettings.disabled) then
  local message = eventSettings.message
  message = string_gsub(message, "%%e", moneyString)
  DisplayEvent(eventSettings, message)
 end
end


-- ****************************************************************************
-- Handles looted items.
-- ****************************************************************************
local function HandleItems(parserEvent)
 -- Created items are buggy.  Ignore them.
 if (parserEvent.isCreate) then return end

 -- Get information about the looted item.
 local itemLink = parserEvent.itemLink
 local itemName, _, itemQuality, _, _, itemType, _, _, _, itemTexture = GetItemInfo(itemLink)

 -- Determine whether to show the event and ignore it if necessary.
 local currentProfile = MSBTProfiles.currentProfile
 local showEvent = true
 if (currentProfile.qualityExclusions[itemQuality]) then showEvent = false end
 if ((itemType == ITEM_TYPE_QUEST) and currentProfile.alwaysShowQuestItems) then showEvent = true end
 if (currentProfile.itemExclusions[itemName]) then showEvent = false end
 if (currentProfile.itemsAllowed[itemName]) then showEvent = true end
 if (not showEvent) then return end

 -- Format the item name according to its quality.
 local qualityColor = ITEM_QUALITY_COLORS[itemQuality]
 if (qualityPatterns[itemQuality]) then itemName = string_format(qualityPatterns[itemQuality], itemName) end

 local numLooted = parserEvent.amount or 1

 -- Fix: on this server the item is often already in the bags when the
 -- "You receive loot" message arrives, so "bag count + amount looted" showed
 -- one too many. Wait a moment for the bags to update, then use the bag
 -- count as the total (never less than the amount just looted).
 QueueLootDisplay(itemLink, itemName, itemTexture, numLooted)
end


-- ****************************************************************************
-- Parser events handler.
-- ****************************************************************************
local function ParserEventsHandler(parserEvent)
 -- Ignore the event if it isn't for the player or not a loot event.
 if (parserEvent.recipientUnit ~= "player" or parserEvent.eventType ~= "loot") then return end

 -- Call the correct handler for the loot type.
 if (parserEvent.isMoney) then HandleMoney(parserEvent) elseif (parserEvent.itemLink) then HandleItems(parserEvent) end
end


-------------------------------------------------------------------------------
-- Initialization.
-------------------------------------------------------------------------------

-- Setup the item quality color patterns.
for k, v in pairs(ITEM_QUALITY_COLORS) do
 qualityPatterns[k] = string_format("|cFF%02x%02x%02x[%%s]|r", math_ceil(v.r * 255), math_ceil(v.g * 255), math_ceil(v.b * 255))
end

-- Register the parser events handler.
MSBTParser.RegisterHandler(ParserEventsHandler)
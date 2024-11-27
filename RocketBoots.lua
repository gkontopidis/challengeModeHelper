-- RocketBoots.lua

local f = CreateFrame("Frame")
local bootItemID = 35581 -- The item ID for Rocket Boots Xtreme

local function EquipRocketBoots()
    print("prin")
    -- Check if AutoEquipXtremeBoots is enabled
    if not AutoEquipXtremeBoots then return end
    print("meta")
    if IsInInstance() then
        local scenarioName, _, _, difficultyName = GetInstanceInfo()
            if difficultyName == "Challenge Mode" then
            for bag = 0, NUM_BAG_SLOTS do
                for slot = 1, GetContainerNumSlots(bag) do
                    local itemID = GetContainerItemID(bag, slot)
                    if itemID == bootItemID then
                        UseContainerItem(bag, slot)
                        print("Rocket Boots Xtreme equipped!")
                        return
                    end
                end
            end
        end
    end
end

f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", EquipRocketBoots)

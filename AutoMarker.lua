-- AutoMarker.lua

-- Initialize the addon namespace
local _, AutoMarker = ...

-- Initialize the target database
AutoMarker.targetDB = {}

-- Function to mark the target
local function MarkTarget(unitID)
    if UnitExists(unitID) then
        local targetName = UnitName(unitID)
        if targetName then
            -- Check if the target is already marked
            if not GetRaidTargetIndex(unitID) then
                -- If not marked, apply the mark
                if AutoMarker.targetDB[targetName] then
                    local mark = AutoMarker.targetDB[targetName]
                    SetRaidTarget(unitID, mark)
                end
            end
        end
    end
end

-- Load the target database from saved variables
local function LoadTargetDB()
    if CmHelperDB and CmHelperDB.targetDB then
        AutoMarker.targetDB = CmHelperDB.targetDB
    else
        -- If no saved variables found, initialize an empty target database
        AutoMarker.targetDB = {}
    end
    print("Target database loaded.")
end

-- Save the target database to saved variables
local function SaveTargetDB()
    print("Saving target database to CmHelperDB...")
    CmHelperDB.targetDB = AutoMarker.targetDB
    print("Target database saved.")
end

-- Event handler function
local function OnEvent(self, event, ...)
    if event == "PLAYER_TARGET_CHANGED" then
        MarkTarget("target")
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        MarkTarget("mouseover")
    elseif event == "PLAYER_LOGIN" then
        -- Load the target database when the player logs in
        LoadTargetDB()
    end
end

-- Create frame and register events
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", OnEvent)

-- Slash command to manage targets
SLASH_AUTOMARKER1 = "/am"
SlashCmdList["AUTOMARKER"] = function(msg)
    local cmd, targetName, mark = msg:match('^%s*(%S+)%s*(.-)%s+(%d+)%s*$')
    if cmd == "add" and targetName and mark then
        AutoMarker.targetDB[targetName] = tonumber(mark)
        print("Added " .. targetName .. " with mark " .. mark)
        SaveTargetDB()
    elseif cmd == "remove" and targetName then
        AutoMarker.targetDB[targetName] = nil
        print("Removed " .. targetName)
        SaveTargetDB()
    else
        print("Usage: /am add <targetName> <markId>")
        print("Usage: /am remove <targetName>")
    end
end

-- Function to print the current target database
local function PrintTargetDB()
    print("Current target database:")
    for targetName, mark in pairs(AutoMarker.targetDB) do
        print(targetName .. ": Mark " .. mark)
    end
end

-- Slash command to print the current target database
SLASH_AUTOMARKERDB1 = "/amdb"
SlashCmdList["AUTOMARKERDB"] = PrintTargetDB

print("AutoMarker loaded. Use /automarker to manage target marks.")

-- Global variables to hold frame references and timer data
local labelFrame = nil
local label = nil
local startTime = nil
local inChallengeMode = false

-- Function to create the addon frame
local function CreateAddonFrame()
    -- Create a frame for the label
    labelFrame = CreateFrame("Frame", "MyAddonLabelFrame", UIParent)
    labelFrame:SetSize(200, 50) -- Set the size of the label frame
    labelFrame:SetPoint("CENTER", 0, 0) -- Position the label frame at the center of the screen

    -- Create a font string to display the timer
    label = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText("00:00") -- Initialize with 00:00
    label:SetPoint("CENTER") -- Position the label at the center of the label frame

    -- Enable dragging functionality
    labelFrame:SetMovable(true)
    labelFrame:EnableMouse(true)
    labelFrame:RegisterForDrag("LeftButton")
    labelFrame:SetScript("OnDragStart", function(self)
        if not self.isLocked then
            self:StartMoving()
        end
    end)
    labelFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self:SavePosition() -- Save frame position when dragging stops
    end)

    -- Set the frame to be locked by default
    labelFrame.isLocked = true

    -- Create a dropdown menu
    local dropdownMenu = CreateFrame("Frame", "MyAddonDropdownMenu", UIParent, "UIDropDownMenuTemplate")
    dropdownMenu.displayMode = "MENU"
    local menuItems = {
        {
            text = "Lock",
            func = function()
                labelFrame.isLocked = true
                labelFrame:StopMovingOrSizing()
            end,
        },
        {
            text = "Unlock",
            func = function()
                labelFrame.isLocked = false
            end,
        },
    }
    dropdownMenu.initialize = function(self, level)
        for _, item in ipairs(menuItems) do
            if (labelFrame.isLocked and item.text == "Unlock") or (not labelFrame.isLocked and item.text == "Lock") then
                local info = UIDropDownMenu_CreateInfo()
                info.text = item.text
                info.func = item.func
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end

    -- Show the dropdown menu on right-click
    labelFrame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            ToggleDropDownMenu(1, nil, dropdownMenu, self:GetName(), 0, 0)
        end
    end)

    -- Function to save frame position
    function labelFrame:SavePosition()
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        CmHelperDB.framePosition = {
            point = point,
            relativePoint = relativePoint,
            xOfs = xOfs,
            yOfs = yOfs,
        }
    end
end

-- Function to update the timer
local function UpdateTimer()
    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime

    local minutes = math.floor(elapsedTime / 60)
    local seconds = math.floor(elapsedTime % 60)

    label:SetText(string.format("%02d:%02d", minutes, seconds)) -- Update the label text with the elapsed time
end

-- Event handler for WORLD_STATE_TIMER_START
local function OnWorldStateTimerStart()
    if not inChallengeMode then
        inChallengeMode = true
        startTime = GetTime() -- Record the start time when the timer starts
        labelFrame:SetScript("OnUpdate", UpdateTimer) -- Start updating the timer
    end
end

-- Event handler for WORLD_STATE_TIMER_STOP
local function OnWorldStateTimerStop()
    if inChallengeMode then
        inChallengeMode = false
        startTime = nil -- Reset the start time
        labelFrame:SetScript("OnUpdate", nil) -- Stop updating the timer
        labelFrame:Hide() -- Hide the label frame when the timer stops
    end
end

-- Event handler for CHALLENGE_MODE_COMPLETED
local function OnChallengeModeCompleted()
    if inChallengeMode then
        inChallengeMode = false
        startTime = nil -- Reset the start time
        labelFrame:SetScript("OnUpdate", nil) -- Stop updating the timer
        labelFrame:Hide() -- Hide the label frame when challenge mode is completed
    end
end

-- Register events
local frame = CreateFrame("Frame")
frame:RegisterEvent("WORLD_STATE_TIMER_START")
frame:RegisterEvent("WORLD_STATE_TIMER_STOP")
frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
frame:RegisterEvent("START_TIMER")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "WORLD_STATE_TIMER_START" then
        OnWorldStateTimerStart()
    elseif event == "WORLD_STATE_TIMER_STOP" then
        OnWorldStateTimerStop()
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        OnChallengeModeCompleted()
    elseif event == "START_TIMER" then
        -- Handle any custom logic for starting the timer
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        -- Handle any logic when the player changes zones
    elseif event == "PLAYER_LOGIN" then
        -- Handle any logic when the player logs in
        if CmHelperDB and CmHelperDB.framePosition then
            if not labelFrame then
                CreateAddonFrame()
            end
            labelFrame:SetPoint(CmHelperDB.framePosition.point, UIParent, CmHelperDB.framePosition.relativePoint, CmHelperDB.framePosition.xOfs, CmHelperDB.framePosition.yOfs)
        else
            CreateAddonFrame() -- Create addon frame if position data not found
        end
    end
end)

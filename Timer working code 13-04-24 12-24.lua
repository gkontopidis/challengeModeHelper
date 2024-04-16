-- Global variables to hold frame references and timer data
local labelFrame = nil
local startTime = nil
local inChallengeMode = false
local resetButton = nil -- Variable to hold the reset button's reference
local isTimerActive = false
local realmBestLabel = nil -- Variable to hold the realm best time label reference
local bestClearLabel = nil -- Variable to hold the best clear time label reference

-- Function to create the addon frame
local function CreateAddonFrame()
    -- Create a frame for the label
    labelFrame = CreateFrame("Frame", "MyAddonLabelFrame", UIParent)
    labelFrame:SetSize(200, 100) -- Set the size of the label frame

    -- Create font strings to display the timer parts
    local minutesLabel = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local secondsLabel = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local millisecondsLabel = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")

    -- Set the initial text for each part of the timer
    minutesLabel:SetText("00:")
    secondsLabel:SetText("00:")
    millisecondsLabel:SetText("000")

    -- Set the font sizes for each font string
    local fontSize = 24
    minutesLabel:SetFont("Fonts\\FRIZQT__.TTF", fontSize)
    secondsLabel:SetFont("Fonts\\FRIZQT__.TTF", fontSize)
    millisecondsLabel:SetFont("Fonts\\FRIZQT__.TTF", 18)

    -- Position the font strings within the label frame
    minutesLabel:SetPoint("LEFT", 10, 0)
    secondsLabel:SetPoint("LEFT", minutesLabel, "RIGHT", 0, 0)
    millisecondsLabel:SetPoint("LEFT", secondsLabel, "RIGHT", 0, -1) -- Adjusted the Y offset here

    -- Update the text color for minutes and seconds
    minutesLabel:SetTextColor(1, 0.84, 0) -- Gold color
    secondsLabel:SetTextColor(1, 0.84, 0) -- Gold color
    millisecondsLabel:SetTextColor(1, 1, 1) -- White color

    -- Create a new font string for the realm best time label
    realmBestLabel = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local realmBestTime = GetChallengeModeRealmBestTime()
    realmBestLabel:SetText("Realm Best Time: " .. realmBestTime)

    -- Position the realm best time label
    realmBestLabel:SetPoint("LEFT", minutesLabel, "TOP", -20, 15) -- Adjust the offset as needed

    -- Create a new font string for the best clear time label
    bestClearLabel = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local remainingTime = GetRemainingTimeToBeatRealmBest()

    -- Set up a timer to call UpdateTime every second
    labelFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 1 then
            UpdateTimer(minutesLabel, secondsLabel, millisecondsLabel)
            self.elapsed = 0
        end
    end)

    -- Position the best clear time label below the realm best time label
    bestClearLabel:SetPoint("LEFT", minutesLabel, "BOTTOM", -20, -15) -- Adjust the offset as needed

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
    dropdownMenu.initialize = function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        if labelFrame.isLocked then
            info.text = "Unlock"
            info.func = function()
                labelFrame.isLocked = false
                UIDropDownMenu_Refresh(self)
            end
        else
            info.text = "Lock"
            info.func = function()
                labelFrame.isLocked = true
                labelFrame:StopMovingOrSizing()
                UIDropDownMenu_Refresh(self)
            end
        end
        UIDropDownMenu_AddButton(info, level)

        -- Define resetInfo outside the condition
        local resetInfo = UIDropDownMenu_CreateInfo()
        resetInfo.text = "Reset Timer"
        resetInfo.func = function()
            minutesLabel:SetText("|cFFFFD70000|r:")
            secondsLabel:SetText("|cFFFFD70000|r:")
            millisecondsLabel:SetText("|cFFFFFFFF000|r")
        end

        -- Add the reset button conditionally
        if not isTimerActive then
            UIDropDownMenu_AddButton(resetInfo, level)
            resetButton = resetInfo -- Store the reference to the reset button
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

    -- Function to update the timer periodically
    labelFrame:SetScript("OnUpdate", function()
        UpdateTimer(minutesLabel, secondsLabel, millisecondsLabel)
		 SubtractTimer(bestClearLabel)
    end)

    return labelFrame, minutesLabel, secondsLabel, millisecondsLabel, bestClearLabel

end

-- Function to convert formatted time string to numerical representation
function StringToTime(timeString)
    local minutes, seconds = string.match(timeString, "(%d+):(%d+)")
    if minutes and seconds then
        return tonumber(minutes) * 60 + tonumber(seconds)
    else
        return 0
    end
end

function SubtractTimer(labelToUse)
    if not startTime then return end -- Check if the timer has started
    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime

    local realmBestTime = StringToTime(GetChallengeModeRealmBestTime())
    local timeSpent = elapsedTime
    local remainingTime = realmBestTime - timeSpent

    local minutesLeft = math.floor(remainingTime / 60)
    local secondsLeft = math.floor(remainingTime % 60)
    local millisecondsLeft = math.floor((remainingTime * 1000) % 1000)

    local minutesTogo = string.format("|cFFFFD700%02d|r:", minutesLeft)
    local secondToGo = string.format("|cFFFFD700%02d|r", secondsLeft)
    local millisecondToGo = string.format("|cFFFFD700%02d|r", millisecondsLeft)
    
    -- Update the text for minutes, seconds, and milliseconds
    labelToUse:SetText("Best clear: " .. minutesTogo .. secondToGo)
end

-- Function to update the timer
function UpdateTimer(minutesLabel, secondsLabel, millisecondsLabel)
    if not startTime then return end -- Check if the timer has started

    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime

    local minutes = math.floor(elapsedTime / 60)
    local seconds = math.floor(elapsedTime % 60)
    local milliseconds = math.floor((elapsedTime * 1000) % 1000)

    -- Update the text and font size for minutes
    minutesLabel:SetText(string.format("|cFFFFD700%02d|r:", minutes))

    -- Update the text and font size for seconds
    secondsLabel:SetText(string.format("|cFFFFD700%02d|r:", seconds))

    -- Update the text and font size for milliseconds
    millisecondsLabel:SetText(string.format("|cFFFFFFFF%03d|r", milliseconds))
end

function GetChallengeRealmBestTime()
    local realmBest = 0
    local maps = {}
    GetChallengeModeMapTable(maps)
    local numMaps = #maps

    for i = 1, numMaps do
        local _, mapID = GetChallengeModeMapInfo(maps[i])
        local _, _, _, _, _, _, _, currentMapID = GetInstanceInfo()

        if currentMapID == mapID then
            realmBest = GetChallengeBestTime(mapID)
            break
        end
    end

    return realmBest
end

function formatSecondsToMinutes(timeToFormat)
    local formattedTime = "00:00" -- Default formatted time if realm best is not available

    if timeToFormat ~= 0 then
        timeToFormat = timeToFormat / 1000

        -- Calculate hours, minutes, and seconds
        local minutes = math.floor((timeToFormat % 3600) / 60)
        local seconds = timeToFormat % 60

        -- Format the time string
        formattedTime = string.format("%02d:%02d", minutes, seconds)
    end

    return formattedTime
end

function GetChallengeModeRealmBestTime()
    local realmBest = GetChallengeRealmBestTime()
    local realmBestFormattedTime = formatSecondsToMinutes(realmBest)
    return realmBestFormattedTime
end

function GetRemainingTimeToBeatRealmBest()
    local realmBest = GetChallengeRealmBestTime()
    local currentTime = GetElapsedTime()

    -- Check if any required value is nil
    if not realmBest or not currentTime then
        return "N/A" -- Return a default value or handle the nil case appropriately
    end

    -- Calculate remaining time only if both values are available
    local remainingTimeToBeatRealmBest = realmBest - currentTime
    local formattedRemainingTime = formatSecondsToMinutes(remainingTimeToBeatRealmBest)
    return formattedRemainingTime
end

function GetElapsedTime()
    if not startTime then return 0 end -- Return 0 if the timer has not started
    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime
    return elapsedTime
end

-- Event handler for WORLD_STATE_TIMER_START
function OnWorldStateTimerStart()
    startTime = GetTime() -- Record the start time
    isTimerActive = true
    if resetButton then
        resetButton.disabled = 1 -- Disable the reset button
    end
end

-- Event handler for WORLD_STATE_TIMER_STOP
function OnWorldStateTimerStop()
    startTime = nil -- Reset the start time
    isTimerActive = false
    if resetButton then
        resetButton.disabled = nil -- Enable the reset button
    end
end

-- Event handler for CHALLENGE_MODE_COMPLETED
local function OnChallengeModeCompleted()
    if inChallengeMode then
        inChallengeMode = false
        startTime = nil -- Reset the start time
        labelFrame:SetScript("OnUpdate", nil) -- Stop updating the timer
    end
end

-- Event handler for ZONE_CHANGED_NEW_AREA
local function OnZoneChangedNewArea()
    local _, _, _, difficultyName = GetInstanceInfo()
    if difficultyName == "Challenge Mode" then
        if not labelFrame then
            labelFrame, minutesLabel, secondsLabel, millisecondsLabel = CreateAddonFrame()
        end
        labelFrame:Show()
    else
        if inChallengeMode then
            OnWorldStateTimerStop() -- Reset the timer if leaving challenge mode
        end
        labelFrame:Hide()
    end

    -- Update the realm best time when the zone changes
    local realmBestTime = GetChallengeModeRealmBestTime()
    realmBestLabel:SetText("Realm Best Time: " .. realmBestTime)

    -- Update the best clear time when the zone changes
    bestClearLabel:SetText("Best clear: " .. GetRemainingTimeToBeatRealmBest())
end

-- Event handler for PLAYER_LOGIN
local function OnPlayerLogin()
    if CmHelperDB and CmHelperDB.framePosition then
        if not labelFrame then
            labelFrame, minutesLabel, secondsLabel, millisecondsLabel = CreateAddonFrame()
        end
        labelFrame:SetPoint(CmHelperDB.framePosition.point, UIParent, CmHelperDB.framePosition.relativePoint, CmHelperDB.framePosition.xOfs, CmHelperDB.framePosition.yOfs)
    else
        labelFrame, minutesLabel, secondsLabel, millisecondsLabel = CreateAddonFrame()
    end
end

-- Register events
local frame = CreateFrame("Frame")
frame:RegisterEvent("WORLD_STATE_TIMER_START")
frame:RegisterEvent("WORLD_STATE_TIMER_STOP")
frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "WORLD_STATE_TIMER_START" then
        OnWorldStateTimerStart()
    elseif event == "WORLD_STATE_TIMER_STOP" then
        OnWorldStateTimerStop()
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        OnChallengeModeCompleted()
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        OnZoneChangedNewArea()
    elseif event == "PLAYER_LOGIN" then
        OnPlayerLogin()
    end
end)

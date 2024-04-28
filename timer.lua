-- Global variables to hold frame references and timer data
local labelFrame = nil
local hoverFrame = nil
local startTime = nil
local inChallengeMode = false
local resetButton = nil -- Variable to hold the reset button's reference
local isTimerActive = false
local realmBestLabel = nil -- Variable to hold the realm best time label reference
local bestClearLabel = nil -- Variable to hold the best clear time label reference
local line = nil
local lastTenSecondsTimer = nil
local C_Timer = C_Timer or nil
local soundPlayed = {}
local isFirstLoad = true -- Global variable to track whether it's the first time the addon loads
local yOfs = -21.22220802307129
local xOfs = 7.110173225402832
local point = "TOP"
local relativePoint = "TOP"
local colorPicked2 = "0" -- Variable to store the selected color option
local selectedCountDown = "realmBest"
local challengeName
local PortalButtonState = "NotPressed"

timeElapsed = 0

-- Function to create the addon frame
local function CreateAddonFrame()
    -- Create a frame for the label
    labelFrame = CreateFrame("Frame", "MyAddonLabelFrame", UIParent)
    labelFrame:SetSize(270, 90) -- Set the size of the label frame

    -- Set up backdrop for the frame
    labelFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4
        }
    })

    -- Create the hover frame
    hoverFrame = CreateFrame("Frame", "MyAddonHoverFrame", UIParent)
    frameHeight = getAvailableTeleportButtons()
    hoverFrame:SetSize(55, #frameHeight * 44)
    hoverFrame:SetPoint("TOP", labelFrame, "RIGHT", 22, 44) -- Adjust position as needed
    hoverFrame:SetBackdrop({
        -- bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        -- edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4
        }
    })
    hoverFrame:Hide() -- Hide the hover frame initially

    local function CreateButton(parent, index, portalName, iconPath, spellID)
        local button = CreateFrame("Button", "MyAddonHoverButton" .. index, parent, "SecureActionButtonTemplate")
        button:SetSize(40, 40) -- Set the size of each button
        button:SetPoint("TOP", parent, "TOP", 0, -((index - 1) * 40)) -- Position each button vertically

        -- Set the button's attributes for spell casting
        button:SetAttribute("type", "spell")
        button:SetAttribute("spell", GetSpellInfo(spellID))

        -- Set the button's icon
        local iconTexture = button:CreateTexture(nil, "ARTWORK")
        iconTexture:SetAllPoints()
        iconTexture:SetTexture(iconPath)

        -- Add tooltip functionality
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(portalName) -- Set tooltip text
            GameTooltip:Show()
        end)

        button:SetScript("OnLeave", function(self)
            GameTooltip:Hide() -- Hide tooltip when mouse leaves the button
        end)

        -- Function to update cooldown text
        local function UpdateCooldownText()
            local start, duration, enable = GetSpellCooldown(portalName)
            local remainingTime = start + duration - GetTime()

            if remainingTime > 0 then
                -- If the remaining time is greater than 0, the spell is on cooldown
                iconTexture:SetDesaturated(true)
                button:Disable()
            else
                -- If the remaining time is 0 or less, the spell is off cooldown
                iconTexture:SetDesaturated(false) -- Enable the button by restoring saturation
                button:Enable()
            end
        end

        -- Register for events to update the cooldown text
        button:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        button:SetScript("OnEvent", function(self, event, ...)
            UpdateCooldownText()
        end)

        -- Update cooldown text initially
        UpdateCooldownText()

        return button
    end

    local availablePortals = getAvailableTeleportButtons()
    for index, portalInfo in ipairs(availablePortals) do
        CreateButton(hoverFrame, index, portalInfo.name, portalInfo.iconPath, portalInfo.id) -- Create and store each button
    end

    -- Create a button
    local button = CreateFrame("Button", nil, labelFrame, "UIPanelButtonTemplate")
    button:SetText("RESET")
    button:SetSize(60, 60)
    button:SetPoint("LEFT", 10, 0) -- Adjust the position as needed

    -- Set the button's icon texture
    button:SetNormalTexture("Interface\\Icons\\SPELL_HOLY_BORROWEDTIME")

    -- Set the text label's position
    button:GetFontString():SetPoint("BOTTOM", 0, 5) -- Adjust the position as needed

    -- Set the text label's font properties
    button:GetFontString():SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE") -- Adjust font, size, and style
    button:GetFontString():SetTextColor(1, 1, 1) -- Set text color to white

    -- Function to create the glow effect
    local function CreateGlow()
        -- Create a glow texture
        button.glow = button:CreateTexture(nil, "BACKGROUND")
        button.glow:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        button.glow:SetBlendMode("ADD")
        button.glow:SetAllPoints(button)
        button.glow:SetAlpha(0.7) -- Adjust the alpha to make the glow more visible
        button.glow:Hide() -- Initially hide the glow
    end

    -- Set the button's OnEnter handler to show the glow effect
    button:SetScript("OnEnter", function()
        if not button.glow then
            CreateGlow()
        end
        button.glow:Show()
    end)

    -- Set the button's OnLeave handler to hide the glow effect
    button:SetScript("OnLeave", function()
        if button.glow then
            button.glow:Hide()
        end
    end)

    -- Set the button's OnClick handler to run the script
    button:SetScript("OnClick", function()
        RunScript("ResetChallengeMode()")
    end)

    -- Function to update the button state
    local function UpdateButtonState()
        if IsInGroup() and UnitIsGroupLeader("player") then
            button:Show() -- Show the button if the player is the group leader
        elseif not IsInGroup() then
            button:Show() -- Show the button if the player is alone
        else
            button:Hide() -- Hide the button if the player is in a group but not the leader
        end
    end

    -- Register an event to update the button state
    button:RegisterEvent("GROUP_ROSTER_UPDATE")
    button:SetScript("OnEvent", UpdateButtonState)

    -- Initial update of the button state
    UpdateButtonState()

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
    minutesLabel:SetPoint("LEFT", 80, -20)
    secondsLabel:SetPoint("LEFT", minutesLabel, "RIGHT", 0, 0)
    millisecondsLabel:SetPoint("LEFT", secondsLabel, "RIGHT", 0, -1) -- Adjusted the Y offset here

    -- Update the text color for minutes and seconds
    minutesLabel:SetTextColor(1, 0.84, 0) -- Gold color
    secondsLabel:SetTextColor(1, 0.84, 0) -- Gold color
    millisecondsLabel:SetTextColor(1, 1, 1) -- White color

    -- Create a new font string for the realm best time label
    realmBestLabel = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local realmBestTime = GetChallengeModeRealmOrGuildBestTime()
    local textToDisplay = ""
    if (selectedCountDown == "realmBest") then
        textToDisplay = "Realm Best:"
    elseif (selectedCountDown == "guildBest") then
        textToDisplay = "Guild Best:"
    end

    realmBestLabel:SetText(textToDisplay .. realmBestTime)

    -- Position the realm best time label
    realmBestLabel:SetPoint("LEFT", labelFrame, "LEFT", 80, 20) -- Adjust the offset as needed

    -- Create a new font string for the best clear time label
    bestClearLabel = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local remainingTime = GetRemainingTimeToBeatCounter()
    bestClearLabel:SetText("Time remaining: " .. remainingTime)
    -- Set up a timer to call UpdateTime every second
    labelFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 1 then
            UpdateTimer(minutesLabel, secondsLabel, millisecondsLabel)
            self.elapsed = 0
        end
    end)

    PortalButton = CreateFrame("Button", nil, labelFrame, "UIPanelButtonTemplate")
    PortalButton:SetSize(20, 20)
    PortalButton:SetPoint("LEFT", minutesLabel, "RIGHT", 120, -1) -- Adjust the position as needed
    PortalButton:SetNormalTexture("Interface\\Icons\\misc_arrowright")

    -- Position the best clear time label below the realm best time label
    bestClearLabel:SetPoint("LEFT", labelFrame, "LEFT", 80, 0) -- Adjust the offset as needed

    -- Create icon and text
    local goldicon = labelFrame:CreateTexture(nil, "OVERLAY")
    goldicon:SetTexture("Interface\\Icons\\achievement_challengemode_gold")
    goldicon:SetSize(16, 16)
    goldicon:SetPoint("LEFT", labelFrame, "BOTTOM", -135, -12)

    local goldText = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    goldText:SetPoint("LEFT", goldicon, "RIGHT", 10, 0)

    local silverIcon = labelFrame:CreateTexture(nil, "OVERLAY")
    silverIcon:SetTexture("Interface\\Icons\\achievement_challengemode_silver")
    silverIcon:SetSize(16, 16)
    silverIcon:SetPoint("LEFT", goldText, "RIGHT", 20, 0)

    local silverText = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    silverText:SetPoint("LEFT", silverIcon, "RIGHT", 10, 0)

    local bronzeIcon = labelFrame:CreateTexture(nil, "OVERLAY")
    bronzeIcon:SetTexture("Interface\\Icons\\achievement_challengemode_bronze")
    bronzeIcon:SetSize(16, 16)
    bronzeIcon:SetPoint("LEFT", silverText, "RIGHT", 20, 0)

    local bronzeText = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bronzeText:SetPoint("LEFT", bronzeIcon, "RIGHT", 10, 0)

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

        if level == 1 then
            local info = UIDropDownMenu_CreateInfo()
            -- Add the Lock/Unlock option based on labelFrame.isLocked state
            if labelFrame.isLocked then
                info.text = "Unlock"
                info.notCheckable = true
                info.func = function()
                    labelFrame.isLocked = false
                    UIDropDownMenu_Refresh(self)
                end
            else
                info.text = "Lock"
                info.notCheckable = true
                info.func = function()
                    labelFrame.isLocked = true
                    labelFrame:StopMovingOrSizing()
                    UIDropDownMenu_Refresh(self)
                end
            end

            UIDropDownMenu_AddButton(info, level)

            local resetInfo = UIDropDownMenu_CreateInfo()
            resetInfo.text = "Reset Timer"
            resetInfo.notCheckable = true -- Sub-options won't have checkboxes
            resetInfo.func = function()
                -- Reset timer labels
                minutesLabel:SetText("|cFFFFD70000|r:")
                secondsLabel:SetText("|cFFFFD70000|r:")
                millisecondsLabel:SetText("|cFFFFFFFF000|r")
            end

            -- Add the Reset Timer option if the timer is not active
            if not isTimerActive then
                UIDropDownMenu_AddButton(resetInfo, level)
                resetButton = resetInfo
            end

            local backgroundFrame = UIDropDownMenu_CreateInfo()
            backgroundFrame.text = "Background"
            backgroundFrame.notCheckable = true
            backgroundFrame.hasArrow = true
            backgroundFrame.value = "background"
            UIDropDownMenu_AddButton(backgroundFrame, level)

            local timeToBeatMenu = UIDropDownMenu_CreateInfo()
            timeToBeatMenu.text = "Time to beat"
            timeToBeatMenu.notCheckable = true -- Sub-options won't have checkboxes
            timeToBeatMenu.hasArrow = true
            timeToBeatMenu.value = "timeToBeat"
            UIDropDownMenu_AddButton(info, level)

        elseif level == 2 then
            if UIDROPDOWNMENU_MENU_VALUE == "background" then
                local info = UIDropDownMenu_CreateInfo()
                info.text = "0%"
                info.func = function()
                    labelFrame:SetBackdropColor(0, 0, 0, 0)
                    UIDropDownMenu_SetSelectedValue(dropdownMenu, 0)
                    colorPicked2 = 0 -- Update colorPicked2 variable
                    -- UpdateObjectivesLabel() -- Update label after changing background
                    labelFrame:SavePosition()
                end
                info.checked = colorPicked2 == 0 and 1 or nil
                UIDropDownMenu_AddButton(info, level)

                info = UIDropDownMenu_CreateInfo()
                info.text = "25%"
                info.func = function()
                    labelFrame:SetBackdropColor(0, 0, 0, 0.25)
                    UIDropDownMenu_SetSelectedValue(dropdownMenu, 0.25)
                    colorPicked2 = 0.25 -- Update colorPicked2 variable
                    -- UpdateObjectivesLabel() -- Update label after changing background
                    labelFrame:SavePosition()
                end
                info.checked = colorPicked2 == 0.25 and 1 or nil
                UIDropDownMenu_AddButton(info, level)

                info = UIDropDownMenu_CreateInfo()
                info.text = "50%"
                info.func = function()
                    labelFrame:SetBackdropColor(0, 0, 0, 0.50)
                    UIDropDownMenu_SetSelectedValue(dropdownMenu, 0.50)
                    colorPicked2 = 0.50 -- Update colorPicked2 variable
                    -- UpdateObjectivesLabel() -- Update label after changing background
                    labelFrame:SavePosition()
                end
                info.checked = colorPicked2 == 0.50 and 1 or nil
                UIDropDownMenu_AddButton(info, level)

                info = UIDropDownMenu_CreateInfo()
                info.text = "75%"
                info.func = function()
                    labelFrame:SetBackdropColor(0, 0, 0, 0.75)
                    UIDropDownMenu_SetSelectedValue(dropdownMenu, 0.75)
                    colorPicked2 = 0.75 -- Update colorPicked2 variable
                    -- UpdateObjectivesLabel() -- Update label after changing background
                    labelFrame:SavePosition()
                end
                info.checked = colorPicked2 == 0.75 and 1 or nil
                UIDropDownMenu_AddButton(info, level)

                info = UIDropDownMenu_CreateInfo()
                info.text = "100%"
                info.func = function()
                    labelFrame:SetBackdropColor(0, 0, 0, 1)
                    UIDropDownMenu_SetSelectedValue(dropdownMenu, 1)
                    colorPicked2 = 1 -- Update colorPicked2 variable
                    -- UpdateObjectivesLabel() -- Update label after changing background
                    labelFrame:SavePosition()
                end
                info.checked = colorPicked2 == 1 and 1 or nil
                UIDropDownMenu_AddButton(info, level)

            elseif UIDROPDOWNMENU_MENU_VALUE == "timeToBeat" then
                local timeToBeatFrame = UIDropDownMenu_CreateInfo()
                timeToBeatFrame.text = "Realm best"
                timeToBeatFrame.func = function()
                    UIDropDownMenu_SetSelectedValue(dropdownMenu, "realmBest")
                    selectedCountDown = "realmBest"
                    updateFrame()
                end
                timeToBeatFrame.checked = selectedCountDown == "realmBest" and 1 or nil
                UIDropDownMenu_AddButton(timeToBeatFrame, level)

                timeToBeatFrame = UIDropDownMenu_CreateInfo()
                timeToBeatFrame.text = "Guild best"
                timeToBeatFrame.func = function()
                    UIDropDownMenu_SetSelectedValue(dropdownMenu, "guildBest")
                    selectedCountDown = "guildBest"
                    updateFrame()
                end
                timeToBeatFrame.checked = selectedCountDown == "guildBest" and 1 or nil
                UIDropDownMenu_AddButton(timeToBeatFrame, level)
            end
        end
    end

    function updateFrame()
        local realmBestTime = GetChallengeModeRealmOrGuildBestTime()
        local textToDisplay = ""
        if selectedCountDown == "realmBest" then
            textToDisplay = "Realm Best: "
        elseif selectedCountDown == "guildBest" then
            textToDisplay = "Guild Best: "
        end
        realmBestLabel:SetText(textToDisplay .. realmBestTime)
        bestClearLabel:SetText("Time remaining: " .. realmBestTime)

        goldTime = getChallengeRequirementTime("Gold")
        silverTime = getChallengeRequirementTime("Silver")
        bronzeTime = getChallengeRequirementTime("Bronze")

        goldText:SetText(goldTime)
        silverText:SetText(silverTime)
        bronzeText:SetText(bronzeTime)
    end

    -- Show the dropdown menu on right-click
    labelFrame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            UIDropDownMenu_SetSelectedValue(dropdownMenu, colorPicked2)
            ToggleDropDownMenu(1, nil, dropdownMenu, self:GetName(), 0, 0)
        end
    end)

    -- Function to save frame position
    function labelFrame:SavePosition()
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        local r, g, b, a = self:GetBackdropColor()
        CmHelperDB.framePosition = {
            point = point,
            relativePoint = relativePoint,
            xOfs = xOfs,
            yOfs = yOfs,
            colorPicked2 = colorPicked2, -- Save the selected color option
            alpha = a
        }
    end

    -- Set up button click handler to show the panel
    PortalButton:SetScript("OnClick", function()
        if PortalButtonState == "NotPressed" then
            PortalButtonState = "Pressed"
            PortalButton:SetNormalTexture("Interface\\Icons\\misc_arrowleft")
            hoverFrame:Show()
        else
            PortalButtonState = "NotPressed"
            PortalButton:SetNormalTexture("Interface\\Icons\\misc_arrowright")
            hoverFrame:Hide()
        end
    end)

    -- Function to update the timer periodically
    labelFrame:SetScript("OnUpdate", function()
        UpdateTimer(minutesLabel, secondsLabel, millisecondsLabel)
        SubtractTimer(bestClearLabel)
    end)

    return labelFrame, minutesLabel, secondsLabel, millisecondsLabel, bestClearLabel

end

function areAnyChallengePortalsKnown()
    for _, portal in pairs(challengePortals) do
        if IsSpellKnown(portal.id) then
            return true -- Return true as soon as a known spell is found
        end
    end
    return false -- Return false if none of the spells are known
end

function getAvailableTeleportButtons()
    local availablePortals = {}
    if areAnyChallengePortalsKnown() then
        for portalName, portalInfo in pairs(challengePortals) do
            if IsSpellKnown(portalInfo.id) then
                local buttonInfo = {
                    name = portalName,
                    iconPath = portalInfo.iconPath,
                    id = portalInfo.id
                }
                table.insert(availablePortals, buttonInfo)
            end
        end
    end
    return availablePortals
end

function getChallengeRequirementTime(medal)
    local dungeon, _, _, difficultyName = GetInstanceInfo()
    challengeName = dungeon
    if (challengeName and difficultyName == "Challenge Mode") then
        if (medal == "Gold") then
            return cmCompletionTimes[challengeName]["Gold"]
        elseif (medal == "Silver") then
            return cmCompletionTimes[challengeName]["Silver"]
        elseif (medal == "Bronze") then
            return cmCompletionTimes[challengeName]["Bronze"]
        end
    end
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

-- Function to reset the soundPlayed table
local function ResetSoundPlayed()
    for i = 1, 10 do
        soundPlayed[i] = false
    end
end

-- Call ResetSoundPlayed at the beginning of the script
ResetSoundPlayed()

function SubtractTimer(labelToUse)
    if not startTime then
        return
    end -- Check if the timer has started

    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime

    local realmBestTime = StringToTime(GetChallengeModeRealmOrGuildBestTime())
    local timeSpent = elapsedTime
    local remainingTime = realmBestTime - timeSpent

    if remainingTime > 0 and elapsedTime >= 0 then
        local minutesLeft = math.floor(remainingTime / 60)
        local secondsLeft = math.floor(remainingTime % 60)
        local millisecondsLeft = math.floor((remainingTime * 1000) % 1000)

        local minutesTogo = string.format("|cFFFFD700%02d|r:", minutesLeft)
        local secondToGo = string.format("|cFFFFD700%02d|r", secondsLeft)
        local millisecondToGo = string.format("|cFFFFD700%02d|r", millisecondsLeft)

        -- Update the text for minutes, seconds, and milliseconds
        labelToUse:SetText("Time remaining: " .. minutesTogo .. secondToGo)

        -- Inside the condition for the last 10 seconds, check if the sound has already been played
        if secondsLeft <= 10 and secondsLeft > 0 and minutesLeft == 0 then
            if not soundPlayed[secondsLeft] then
                PlaySoundFile("Interface\\AddOns\\Challenge-Mode_Helper\\Sounds\\" .. secondsLeft .. ".ogg")
                soundPlayed[secondsLeft] = true
            end
        end
    end
end

-- Function to update the timer
function UpdateTimer(minutesLabel, secondsLabel, millisecondsLabel)
    if not startTime then
        return
    end -- Check if the timer has started

    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime
    timeElapsed = elapsedTime
    local minutes = math.floor(elapsedTime / 60)
    local seconds = math.floor(elapsedTime % 60)
    local milliseconds = math.floor((elapsedTime * 1000) % 1000)

    if (elapsedTime >= 0) then
        -- Update the text and font size for minutes
        minutesLabel:SetText(string.format("|cFFFFD700%02d|r:", minutes))

        -- Update the text and font size for seconds
        secondsLabel:SetText(string.format("|cFFFFD700%02d|r:", seconds))

        -- Update the text and font size for milliseconds
        millisecondsLabel:SetText(string.format("|cFFFFFFFF%03d|r", milliseconds))
    end
end

function GetChallengeRealmOrGuildBestTime()
    local realmBest = 0
    local guildBest = 0
    local dungeon, _, _, difficultyName = GetInstanceInfo()

    if difficultyName == "Challenge Mode" then
        challengeName = dungeon
        local _, _, _, _, _, _, _, currentMapID = GetInstanceInfo()

        guildBest, realmBest = GetChallengeBestTime(currentMapID)

        if (selectedCountDown == "realmBest") then
            return realmBest
        elseif (selectedCountDown == "guildBest") then
            return guildBest
        end
    end
end

function formatSecondsToMinutes(timeToFormat)
    local formattedTime = "00:00" -- Default formatted time if realm best is not available

    if timeToFormat and timeToFormat ~= 0 then
        timeToFormat = timeToFormat / 1000

        -- Calculate hours, minutes, and seconds
        local minutes = math.floor((timeToFormat % 3600) / 60)
        local seconds = timeToFormat % 60

        -- Format the time string
        formattedTime = string.format("%02d:%02d", minutes, seconds)
    end

    return formattedTime
end

function GetChallengeModeRealmOrGuildBestTime()
    local timeToBeat = GetChallengeRealmOrGuildBestTime()
    local realmBestFormattedTime = formatSecondsToMinutes(timeToBeat)
    return realmBestFormattedTime
end

function GetRemainingTimeToBeatCounter()
    local timeToBeat = GetChallengeRealmOrGuildBestTime()
    local currentTime = GetElapsedTime()

    -- Check if any required value is nil
    if not timeToBeat or not currentTime then
        return "N/A" -- Return a default value or handle the nil case appropriately
    end

    -- Calculate remaining time only if both values are available
    local remainingTimeToBeatRealmBest = timeToBeat - currentTime
    local formattedRemainingTime = formatSecondsToMinutes(remainingTimeToBeatRealmBest)
    return formattedRemainingTime
end

function GetElapsedTime()
    if not startTime then
        return 0
    end -- Return 0 if the timer has not started
    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime
    timeElapsed = elapsedTime
    return elapsedTime
end

local function LoadCompletionTimes()
    -- Load the database from the separate file
    dofile("CompletionTimes.lua")

    -- Optional: Print a message to confirm that the database is loaded
    print("Completion times database loaded.")
end

local function checkPortalExistance(portalId)
    return C_Spell.DoesSpellExist(portalId)
end

-- Register events
local frame = CreateFrame("Frame")
frame:RegisterEvent("WORLD_STATE_TIMER_START")
frame:RegisterEvent("WORLD_STATE_TIMER_STOP")
frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("START_TIMER")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("WORLD_MAP_UPDATE")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        -- If it's the first load, center the labelFrame on the screen
        if isFirstLoad and not CmHelperDB then
            isFirstLoad = false
            if labelFrame then
                labelFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            end
        end
        local _, _, _, difficultyName = GetInstanceInfo()
        if difficultyName == "Challenge Mode" then
            -- Reset the timer labels to "00:00:000"
            minutesLabel:SetText("00:")
            secondsLabel:SetText("00:")
            millisecondsLabel:SetText("000")
            if not labelFrame then
                labelFrame, minutesLabel, secondsLabel, millisecondsLabel, bestClearLabel = CreateAddonFrame()
            end
            local timeRemaining = GetChallengeModeRealmOrGuildBestTime()
            updateFrame()
            labelFrame:Show()
        else
            if inChallengeMode then
                OnWorldStateTimerStop() -- Reset the timer if leaving challenge mode
            end
            labelFrame:Hide()
            hoverFrame:Hide()
            PortalButtonState = "NotPressed"
            PortalButton:SetNormalTexture("Interface\\Icons\\misc_arrowright")
        end
    elseif event == "WORLD_STATE_TIMER_START" then
        -- OnWorldStateTimerStart()
    elseif event == "WORLD_STATE_TIMER_STOP" then
        startTime = nil -- Reset the start time
        isTimerActive = false
        if resetButton then
            resetButton.disabled = nil -- Enable the reset button
        end
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        if inChallengeMode then
            inChallengeMode = false
            startTime = nil -- Reset the start time
            labelFrame:SetScript("OnUpdate", nil) -- Stop updating the timer
        end
    elseif event == "ZONE_CHANGED_NEW_AREA" then

    elseif event == "PLAYER_LOGIN" then
        -- Check if CmHelperDB exists and if it has the framePosition table
        if CmHelperDB and CmHelperDB.framePosition then
            -- Check if the labelFrame hasn't been created yet
            if not labelFrame then
                -- Create the addon frame
                labelFrame, minutesLabel, secondsLabel, millisecondsLabel = CreateAddonFrame()
            end
            -- Set the frame position based on the values stored in CmHelperDB
            labelFrame:SetPoint(CmHelperDB.framePosition.point, UIParent, CmHelperDB.framePosition.relativePoint,
                CmHelperDB.framePosition.xOfs, CmHelperDB.framePosition.yOfs)

            -- Set the transparency of the label frame based on the stored value
            labelFrame:SetBackdropColor(0, 0, 0, CmHelperDB.framePosition.colorPicked2)
        else
            -- Initialize CmHelperDB with the default frame position values
            CmHelperDB = {
                framePosition = {
                    yOfs = -21.22220802307129,
                    xOfs = 7.110173225402832,
                    point = "TOP",
                    relativePoint = "TOP",
                    colorPicked2 = colorPicked2, -- Set default transparency value
                    alpha = a
                }
            }
            -- Create the addon frame
            labelFrame, minutesLabel, secondsLabel, millisecondsLabel = CreateAddonFrame()

            -- Set the default transparency of the label frame
            labelFrame:SetBackdropColor(0, 0, 0, CmHelperDB.framePosition.colorPicked2)
        end

        -- Update the frame to display the correct realm best time
        updateFrame()
    elseif event == "START_TIMER" then
        startTime = GetTime() + 5 -- Record the start time
        isTimerActive = true
        if resetButton then
            resetButton.disabled = 1 -- Disable the reset button
        end
        ResetSoundPlayed() -- Reset the soundPlayed table when the timer starts
    elseif event == "WORLD_MAP_UPDATE" then
        updateFrame()
    end
end)

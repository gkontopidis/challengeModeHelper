local Objectives_frame
local Objectives_label
local completionTimes = {} -- Define a table to store completion times for objectives
local colorPicked = 0 -- Variable to store the selected color option
local TotalEnemies = "" -- Initialize TotalEnemies variable

localDB = {
    BestBossKillTime = {}
}

-- Function to create and show the opacity slider frame
local function ShowOpacitySliderFrame()
    -- Check if the frame is already shown
    if opacitySliderFrame and opacitySliderFrame:IsShown() then
        opacitySliderFrame:Hide() -- Hide the existing frame
    else
        -- Create the frame if it doesn't exist
        opacitySliderFrame = CreateFrame("Frame", "MoPCMHelper_OpacitySliderFrame", UIParent)
        opacitySliderFrame:SetSize(200, 90) -- Increased height to accommodate the label
        opacitySliderFrame:SetPoint("CENTER", 0, 0)
        opacitySliderFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
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
        opacitySliderFrame:SetBackdropColor(0, 0, 0, 1)

        -- Create slider and label
        local sliderLabel = opacitySliderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        sliderLabel:SetPoint("TOPLEFT", 10, -10)
        sliderLabel:SetText("Opacity:")

        local sliderValueLabel = opacitySliderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        sliderValueLabel:SetPoint("LEFT", sliderLabel, "RIGHT", 5, 0) -- Position below the slider label

        local slider = CreateFrame("Slider", "MoPCMHelper_OpacitySlider", opacitySliderFrame, "OptionsSliderTemplate")
        slider:SetWidth(180)
        slider:SetHeight(20)
        slider:SetPoint("TOPLEFT", 10, -30)
        slider:SetMinMaxValues(0, 100)
        slider:SetOrientation("HORIZONTAL")

        -- Load colorPicked value from CmHelperDB if available, otherwise use default value
        local initialColorPicked = (CmHelperDB and CmHelperDB.Objectives_frame and
                                       CmHelperDB.Objectives_frame.colorPicked) or 1
        slider:SetValue(initialColorPicked * 100)
        sliderValueLabel:SetText(math.floor(initialColorPicked * 100))

        -- Update the OnValueChanged callback function to correctly update colorPicked
        slider:SetScript("OnValueChanged", function(self, value)
            colorPicked = value / 100 -- Normalize value to range 0-1
            Objectives_Frame_Opacity(colorPicked)
            ObjectivesSliderValue(value)
            -- Objectives_frame:SetBackdropColor(0, 0, 0, colorPicked)
            sliderValueLabel:SetText(math.floor(colorPicked * 100)) -- Update the value label
        end)

        -- Create close button
        local closeButton = CreateFrame("Button", nil, slider, "UIPanelButtonTemplate")
        closeButton:SetText("Save")
        closeButton:SetSize(80, 20)
        closeButton:SetPoint("BOTTOM", 0, -30)
        closeButton:SetScript("OnClick", function()

            -- Save the slider value when closing the frame
            Objectives_frame:SavePosition()
            opacitySliderFrame:Hide() -- Hide the frame
        end)

        opacitySliderFrame:Show()
    end
end

-- Function to update the size of the frame based on the text size
local function UpdateFrameSize()
    local textWidth = Objectives_label:GetStringWidth() + 20 -- Add some padding
    local textHeight = Objectives_label:GetStringHeight() + 20 -- Add some padding
    Objectives_frame:SetSize(textWidth, textHeight)
end

function TotalDungeonEnemies(indexNumber)
    local _, _, _, _, totalQuantity = C_Scenario.GetCriteriaInfo(indexNumber)
    TotalEnemies = totalQuantity
    return TotalEnemies
end

-- Function to update the objectives label text
local function UpdateObjectivesLabel()

    local objectives = GetScenarioObjectives()
    local dungeon = C_Scenario.GetStepInfo()
    -- Check if there are any objectives available
    if #objectives > 0 then
        local text = ""
        for i, objective in ipairs(objectives) do
            TotalDungeonEnemies(i)

            if (dungeon ~= "Shado-Pan Monastery") then
                if i < #objectives then
                    text = text ..
                               ("%s \n" .. objective.bestcolored .. "%s - %s\n\n"):format(objective.name,
                            objective.bossTimeToKill, objective.timePassed)
                else
                    text = text .. ("%s : %d/%d\n"):format(objective.name, objective.progress, TotalEnemies)

                end
            else
                if i < #objectives - 1 then
                    text = text ..
                               ("%s \n" .. objective.bestcolored .. "%s - Current: %s\n\n"):format(objective.name,
                            objective.bossTimeToKill, objective.timePassed)

                else
                    text = text .. ("%s : %d/%d\n"):format(objective.name, objective.progress, TotalEnemies)

                end
            end
        end
        Objectives_label:SetText(text)
    else
        -- If there are no objectives available, display a message
        -- Objectives_label:SetText("No objectives available")
    end

    -- After updating the text, call the function to update the frame size
    UpdateFrameSize()

end

-- Create a frame for the label
Objectives_frame = CreateFrame("Frame", "MoPCMHelperObjectivesFrame", UIParent)
Objectives_frame:SetPoint("CENTER", UIParent, "CENTER")

-- Set up backdrop for the frame
Objectives_frame:SetBackdrop({
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

function ResetObjectivesFramePosition()
    if Objectives_frame then
        Objectives_frame.isLocked = false
        Objectives_frame:ClearAllPoints() -- Clear previous position
        Objectives_frame:SetPoint("CENTER", UIParent, "CENTER") -- Move to the center of the screen
    end
end

-- Create a font string to display the objectives inside the objectives frame
Objectives_label = Objectives_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
Objectives_label:SetPoint("TOPLEFT", Objectives_frame, "TOPLEFT", 10, -10) -- Adjust position for the label
Objectives_label:SetJustifyH("LEFT") -- Align text to the left

-- Enable dragging functionality
Objectives_frame:SetMovable(true)
Objectives_frame:EnableMouse(true)
Objectives_frame:RegisterForDrag("LeftButton")
Objectives_frame:SetScript("OnDragStart", function(self)
    if not self.isLocked then
        self:StartMoving()
    end
end)
Objectives_frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    self:SavePosition() -- Save frame position when dragging stops
end)

-- Set the frame to be locked by default
Objectives_frame.isLocked = true

-- Function to create the dropdown menu
local function CreateDropdownMenu()
    local dropdownMenu = CreateFrame("Frame", "MoPCMHelperDropdownMenu", UIParent, "UIDropDownMenuTemplate")
    dropdownMenu.displayMode = "MENU"
    dropdownMenu.initialize = function(self, level)
        if level == 1 then
            local info = UIDropDownMenu_CreateInfo()
            if Objectives_frame.isLocked then
                info.text = "Unlock"
                info.notCheckable = true
                info.func = function()
                    Objectives_frame.isLocked = false
                    UIDropDownMenu_Refresh(self)
                    UpdateObjectivesLabel() -- Update label after changing lock state
                end
            else
                info.text = "Lock"
                info.notCheckable = true
                info.func = function()
                    Objectives_frame.isLocked = true
                    Objectives_frame:StopMovingOrSizing()
                    UIDropDownMenu_Refresh(self)
                    UpdateObjectivesLabel() -- Update label after changing lock state
                end
            end
            UIDropDownMenu_AddButton(info, level)

            local transparencyButton = UIDropDownMenu_CreateInfo()
            transparencyButton.text = "Opacity"
            transparencyButton.notCheckable = true
            transparencyButton.func = function()
                ShowOpacitySliderFrame()
            end
            UIDropDownMenu_AddButton(transparencyButton, level)

            info = UIDropDownMenu_CreateInfo()
            info.text = "Font Size"
            info.hasArrow = true
            info.notCheckable = true
            info.value = "fontsize"
            UIDropDownMenu_AddButton(info, level)
        elseif level == 2 then
            if UIDROPDOWNMENU_MENU_VALUE == "fontsize" then
                local info = UIDropDownMenu_CreateInfo()
                info.text = "Small"
                info.notCheckable = true
                info.func = function()
                    -- Set small font size
                    Objectives_label:SetFontObject("GameFontNormalSmall")
                    Objectives_frame:SavePosition()
                    UpdateFrameSize()
                    Set_ComboBox_Text("Small Size")
                end
                UIDropDownMenu_AddButton(info, level)

                info = UIDropDownMenu_CreateInfo()
                info.text = "Normal"
                info.notCheckable = true
                info.func = function()
                    -- Set normal font size
                    Objectives_label:SetFontObject("GameFontNormal")
                    Objectives_frame:SavePosition()
                    UpdateFrameSize()
                    Set_ComboBox_Text("Normal Size")
                end
                UIDropDownMenu_AddButton(info, level)

                info = UIDropDownMenu_CreateInfo()
                info.text = "Large"
                info.notCheckable = true
                info.func = function()
                    -- Set large font size
                    Objectives_label:SetFontObject("GameFontNormalLarge")
                    Objectives_frame:SavePosition()
                    UpdateFrameSize()
                    Set_ComboBox_Text("Large Size")
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end
    return dropdownMenu -- Return dropdownMenu
end

local dropdownMenu = CreateDropdownMenu() -- Define dropdownMenu as a global variable

-- Show the dropdown menu on right-click
Objectives_frame:SetScript("OnMouseDown", function(self, button)
    if button == "RightButton" then
        -- Set the colorPicked variable before showing the dropdown menu
        UIDropDownMenu_SetSelectedValue(dropdownMenu, colorPicked) -- Use dropdownMenu here
        ToggleDropDownMenu(1, nil, dropdownMenu, self:GetName(), 0, 0)
    end
end)

-- Function to save frame position
function Objectives_frame:SavePosition()
    -- local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    -- local r, g, b, a = self:GetBackdropColor()
    CmHelperDB.Objectives_frame = {
        -- point = point,
        -- relativePoint = relativePoint,
        -- xOfs = xOfs,
        -- yOfs = yOfs,
        -- alpha = a, -- Save the alpha value of the backdrop color
        colorPicked = colorPicked, -- Save the selected color option
        fontSize = Objectives_label:GetFontObject():GetName() -- Save the selected font size
    }
end

function secondsToString(secondsToChange)
    local minutes = math.floor((secondsToChange % 3600) / 60)
    local seconds = secondsToChange % 60
    secondsToChange = string.format("%02d:%02d", minutes, seconds)
    return secondsToChange
end

function timeStringToSeconds(timeString)
    if not timeString then
        return 0 -- Return 0 or any default value if timeString is nil
    end

    local minutes, seconds = timeString:match("(%d+):(%d+)")
    if not minutes or not seconds then
        return 0 -- Return 0 or any default value if timeString is in an invalid format
    end

    return tonumber(minutes) * 60 + tonumber(seconds)
end

-- Function to get scenario objectives
function GetScenarioObjectives()

    local dungeon, _, steps = C_Scenario.GetStepInfo()
    local objectives = {}
    local bossTimeToKill

    -- Check if there are any objectives available
    for i = 1, steps do
        local objectiveName, _, completed, progress = C_Scenario.GetCriteriaInfo(i)
        local timePassed = ""
        local formattedObjectiveName = objectiveName
        local bestcolored = "Best: "
        bossTimeToKill = localDB.BestBossKillTime[objectiveName] -- Set bossTimeToKill from db

        if bossTimeToKill == nil or bossTimeToKill == "" or bossTimeToKill == "00:00" then -- if there is no time stored in db 
            localDB.BestBossKillTime[objectiveName] = "N/A"
            bossTimeToKill = "N/A"
        end

        -- Check if objective is completed and the completion time has not been recorded yet
        if completed and not completionTimes[i] then
            -- Record the completion time for this objective

            timePassed = secondsToString(timeElapsed)
            if (timePassed ~= "00:00") then
                completionTimes[i] = timePassed
            end
            -- print(objectiveName .. timePassed) -- Print to chat
        elseif completionTimes[i] then
            -- If completion time has already been recorded, use it

            if localDB.BestBossKillTime[objectiveName] then
                bossTimeToKill = localDB.BestBossKillTime[objectiveName]
            end

            timePassed = completionTimes[i] -- secondsToString(completionTimes[i])

            if localDB.BestBossKillTime[objectiveName] == "N/A" or localDB.BestBossKillTime[objectiveName] == "" or
                timeStringToSeconds(localDB.BestBossKillTime[objectiveName]) > timeStringToSeconds(completionTimes[i]) then
                localDB.BestBossKillTime[objectiveName] = completionTimes[i]
                bossTimeToKill = completionTimes[i]
            end
        end
        if completed and localDB.BestBossKillTime[objectiveName] == "N/A" then
            localDB.BestBossKillTime[objectiveName] = completionTimes[i]
        end
        -- print("bossneme: ",objectiveName, "time:", localDB.BestBossKillTime[objectiveName])
        -- print("completionTimes:",i,": ", completionTimes[i])
        -- Check if objective is completed and format the name with color for display
        if completed then
            formattedObjectiveName = "|cFF00FF00" .. formattedObjectiveName .. "|r" -- Green color for completion
            if timePassed == bossTimeToKill then
                bestcolored = "|cFF00FF00Best: |r"
            else
                bestcolored = "|cFFFF0000Best: |r"
            end

        end

        table.insert(objectives, {
            name = formattedObjectiveName, -- Store the formatted name with colors
            bestcolored = bestcolored,
            progress = progress,
            timePassed = timePassed,
            bossTimeToKill = bossTimeToKill
        })
    end

    return objectives
end

function OnWorldStateTimerStop()
    Objectives_frame:SetScript("OnUpdate", nil)
end

function Objectives_Frame_Opacity(value)
    Objectives_frame:SetBackdropColor(0, 0, 0, value)
    colorPicked = value
    Objectives_frame:SavePosition()
end

function ShowObjectivesFrame()
    Objectives_frame:Show()
end

function HideObjectivesFrame()
    local _, _, _, difficultyName = GetInstanceInfo()
    if difficultyName == "Challenge Mode" then
    else
        Objectives_frame:Hide()
    end
end

function Change_Font_Size(value)
    if value == "Small Size" then
        Objectives_label:SetFontObject("GameFontNormalSmall")
        Objectives_frame:SavePosition()
        UpdateFrameSize()
    elseif value == "Normal Size" then
        Objectives_label:SetFontObject("GameFontNormal")
        Objectives_frame:SavePosition()
        UpdateFrameSize()
    elseif value == "Large Size" then
        Objectives_label:SetFontObject("GameFontNormalLarge")
        Objectives_frame:SavePosition()
        UpdateFrameSize()
    end
end

-- Register events
Objectives_frame:RegisterEvent("START_TIMER")
Objectives_frame:RegisterEvent("WORLD_STATE_TIMER_STOP")
Objectives_frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
Objectives_frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
Objectives_frame:RegisterEvent("PLAYER_LOGIN")
Objectives_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Objectives_frame:RegisterEvent("INSTANCE_RESET")
Objectives_frame:RegisterEvent("ENCOUNTER_START")
Objectives_frame:RegisterEvent("ENCOUNTER_END")
Objectives_frame:RegisterEvent("PLAYER_LOGOUT")
Objectives_frame:RegisterEvent("ADDON_LOADED")
Objectives_frame:RegisterEvent("CRITERIA_COMPLETE")
Objectives_frame:RegisterEvent("SCENARIO_UPDATE")
Objectives_frame:RegisterEvent("CRITERIA_UPDATE")

Objectives_frame:SetScript("OnEvent", function(self, event, ...)
    if event == "START_TIMER" then
        completionTimes = {}
        UpdateObjectivesLabel()
    elseif event == "WORLD_STATE_TIMER_STOP" then
        OnWorldStateTimerStop()
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- completionTimes = {}
        -- Check if the player is in a challenge mode instance
        local _, _, _, difficultyName = GetInstanceInfo()
        if difficultyName == "Challenge Mode" then
            -- If in a challenge mode instance, hide the WatchFrame UI
            --     WatchFrame:SetScript("OnEvent", nil)
            WatchFrame:Hide()  --ANOIXE TO, TO EKLEISA GIA TO SHADO PAN
            Objectives_frame:Show()
        else
            Objectives_frame:Hide()
            --     WatchFrame:SetScript("OnEvent", nil)
            WatchFrame:Show()
        end
        UpdateObjectivesLabel()
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        -- UpdateObjectivesLabel()
    elseif event == "CRITERIA_COMPLETE" then
        -- Record the completion time for the last boss if it hasn't been recorded already
        local objectives = GetScenarioObjectives()
        local lastObjective = objectives[#objectives - 1] -- Get the last objective
        if lastObjective and lastObjective.progress == lastObjective.totalQuantity and
            not completionTimes[#objectives - 1] then
            -- Record completion time for the last boss
            completionTimes[#objectives - 1] = secondsToString(timeElapsed)
            -- Save the completion time to the database
            timesDB.BestBossKillTime[lastObjective.name] = completionTimes[#objectives - 1]
        end
        -- Update the objectives label
        UpdateObjectivesLabel()
    elseif event == "ZONE_CHANGED_NEW_AREA" then

    elseif event == "PLAYER_LOGIN" then
        -- Load saved position, transparency, and colorPicked
        local savedPosition = CmHelperDB.Objectives_frame
        if savedPosition then
            -- Objectives_frame:SetPoint(savedPosition.point, UIParent, savedPosition.relativePoint, savedPosition.xOfs,
            --     savedPosition.yOfs)
            -- Objectives_frame:SetBackdropColor(0, 0, 0, savedPosition.alpha)
            Objectives_frame:SetBackdropColor(0, 0, 0, CmHelperDB.Objectives_frame.colorPicked)
            colorPicked = savedPosition.colorPicked or 0
            -- Load the selected font size
            local fontName = savedPosition.fontSize
            if fontName then
                local fontObject = _G[fontName]
                if fontObject then
                    Objectives_label:SetFontObject(fontObject)
                end
            end
        end
    elseif event == "INSTANCE_RESET" then

    elseif event == "ENCOUNTER_START" then

    elseif event == "ENCOUNTER_END" then

    elseif event == "ADDON_LOADED" then
        if not CmHelperDB then
            CmHelperDB = {}
        end
        if not timesDB then
            timesDB = {
                BestBossKillTime = {}
            }
        end

        -- Ensure scenarios table exists
        if not timesDB.BestBossKillTime then
            timesDB.BestBossKillTime = {}
        end

        -- Copy values from timesDB.BestBossKillTime to localDB.BestBossKillTime

        if timesDB then
            if timesDB.BestBossKillTime then
                if next(timesDB.BestBossKillTime) ~= nil then
                    for bossName, bestTime in pairs(timesDB.BestBossKillTime) do
                        localDB.BestBossKillTime[bossName] = bestTime
                    end
                end
            end
        end
    elseif event == "PLAYER_LOGOUT" then
        print("Logging out. Copying data from localDB.objectives to timesDB.objectives...")

        -- Ensure CmHelperDB is initialized
        if not timesDB then
            print("CmHelperDB is not initialized. Initializing...")
            timesDB = {}
        end

        -- Ensure CmHelperDB.objectives is initialized
        if not timesDB.BestBossKillTime then
            print("timesDB.objectives is not initialized. Initializing...")
            timesDB.BestBossKillTime = {}
        end

        -- Copy values from localDB.objectives to CmHelperDB.objectives
        for key, value in pairs(localDB.BestBossKillTime) do
            timesDB.BestBossKillTime[key] = value
        end

        print("Data copied successfully.")
    elseif event == "SCENARIO_UPDATE" then
        UpdateObjectivesLabel()
    elseif event == "CRITERIA_UPDATE" then
        UpdateObjectivesLabel()
    end
end)

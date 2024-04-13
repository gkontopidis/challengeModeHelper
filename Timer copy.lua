local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Initialize saved variables
        Challenge_Mode_HelperDB = Challenge_Mode_HelperDB or {} -- Initialize if not already present

        -- Your initialization logic here
    end
end)
-- Global variables to hold frame references and timer data
local labelFrame = nil
local startTime = nil
local inChallengeMode = false
local resetButton = nil -- Variable to hold the reset button's reference
local isTimerActive = false

local savedVariables = Challenge_Mode_HelperDB or {}
Challenge_Mode_HelperDB = savedVariables -- Ensure Challenge_Mode_HelperDB is available globally

-- Function to load saved variables
local function LoadSavedVariables()
    -- Initialize saved variables if they don't exist
    if Challenge_Mode_HelperDB == nil then
        Challenge_Mode_HelperDB = {}
    end
    if Challenge_Mode_HelperDB.scenarios == nil then
        Challenge_Mode_HelperDB.scenarios = {}
    end
end

-- Function to create the addon frame
local function CreateAddonFrame()
    -- Create a frame for the label
    local labelFrame = CreateFrame("Frame", "MyAddonLabelFrame", UIParent)
    labelFrame:SetSize(200, 50) -- Set the size of the label frame

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
    millisecondsLabel:SetPoint("LEFT", secondsLabel, "RIGHT", 0, -4) -- Adjusted the Y offset here

    -- Update the text color for minutes and seconds
    minutesLabel:SetTextColor(1, 0.84, 0) -- Gold color
    secondsLabel:SetTextColor(1, 0.84, 0) -- Gold color
    millisecondsLabel:SetTextColor(1, 1, 1) -- White color

    -- Create a new font string for the realm best time
    local realmBestLabel = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    realmBestLabel:SetText(GetChallengeModeRealmBestTime().. "\n")

    -- Position the realm best time label below the timer label
    realmBestLabel:SetPoint("TOP", millisecondsLabel, "BOTTOM", 0, -10) -- Adjust the offset as needed

    print("objectives:",GetObjectivesWithProgressElapsedAndRecordTimes())
    
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
			print("Timer Reseted")
			--print(isTimerActive)
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
    end)

    return labelFrame, minutesLabel, secondsLabel, millisecondsLabel
end

function SubtractTimer(labelToUse)
    if not startTime then return end -- Check if the timer has started
    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime
    local newTime = GetChallengeRealmBestTime() - elapsedTime

    local minutesLeft = math.floor(elapsedTime / 60)
    local secondsLeft = math.floor(elapsedTime % 60)
    
    local minutesTogo= string.format("|cFFFFD700%02d|r:", minutesLeft)
    local secondToGo = string.format("|cFFFFD700%02d|r:", secondsLeft)
    -- Update the text and font size for minutes
    labelToUse:SetText(minutesTogo .. ":" .. secondToGo)
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
    if (currentTime ~= 0)then
        local remainingTimeToBeatRealmBest = realmBest - currentTime
        return formatSecondsToMinutes(remainingTimeToBeatRealmBest)
    end
end

function GetElapsedTime()
    if not startTime then return end -- Check if the timer has started
    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime
    return elapsedTime
end

function GetObjectivesWithProgressElapsedAndRecordTimes()
    local text = ""
    local objectives = GetScenarioObjectives()
    local dungeon, _, steps = C_Scenario.GetStepInfo()

    -- Check if objectives table is empty or not properly populated
    if #objectives == 0 then
        return
    end

    for i, objective in ipairs(objectives) do
        local objectiveName = objective.name
        local objectiveProgress = objective.progress
        local recordKillTime = formatSecondsToMinutes(GetRecordKillTime(dungeon, objectiveName)) -- Retrieve record kill time
print("objective:", i, objectiveName,objectiveProgress,recordKillTime)
        if i < #objectives then 
            if (objectiveProgress ~= objectiveStatus) then
                local timeString = formatSecondsToMinutes(GetElapsedTime())
                if(timeString < recordKillTime) then
                    Challenge_Mode_HelperDB.scenarios[scenarioName][objectiveName] = GetElapsedTime(startTime)
                end
            end
            text = ("%s %s %s"):format(objectiveName, timeString, recordKillTime)
        else
            -- Last objective is number of enemies
            text = ("%s : %d"):format(objectiveName, objectiveProgress)
        end
    end
    return text
end


function GetRecordKillTime(scenarioName, objectiveName)
    LoadSavedVariables()

    local tempCompletionTime = nil
    if Challenge_Mode_HelperDB and Challenge_Mode_HelperDB.scenarios then
        for savedScenarioName, scenarioData in pairs(Challenge_Mode_HelperDB.scenarios) do
            if savedScenarioName == scenarioName then
                for savedObjectiveName, completionTime in pairs(scenarioData) do
                    if savedObjectiveName == objectiveName then
                        tempCompletionTime = completionTime
                    end
                end
            end
        end
    else
        print("Challenge_Mode_HelperDB or scenarios table is nil")
    end

    return tempCompletionTime
end

function GetScenarioObjectives()
    local dungeon, _, steps = C_Scenario.GetStepInfo()
    local objectives = {}

    for i = 1, steps do
        local objectiveName, _, completed, progress = C_Scenario.GetCriteriaInfo(i)
        
        -- If the objective is completed, mark it as completed
        local status = completed and "|cFF00FF00Completed|r" or "|cFFFF0000Incomplete|r"
        
        -- Build the objective table with name, status, and progress
        table.insert(objectives, {name = objectiveName, status = status, progress = progress})
    end
    
    return objectives
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
        LoadSavedVariables()
    end
end)


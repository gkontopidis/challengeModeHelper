-- Initialize saved variables
if not CmHelperDB then
    CmHelperDB = {}
end

-- Define a table to store completion times for objectives
local completionTimes = {}

local Objectives_frame
local Objectives_label
local TotalEnemies = "" -- Initialize TotalEnemies variable

-- Function to update the objectives label
function UpdateObjectivesLabel()
	
    local text = ""
    local objectives = GetScenarioObjectives()

    -- Check if objectives table is empty or not properly populated
    if #objectives == 0 then
        Objectives_frame:Hide()
        return
    else
        Objectives_frame:Show()
    end

    for i, objective in ipairs(objectives) do
		TotalDungeonEnemies(i)
        if i < #objectives then
            text = text .. ("%s %s %s %d %s %s\n"):format(objective.name, objective.progress,"/", TotalEnemies, objective.status, objective.timePassed)
        else
            text = text .. ("%s : %d/%d%s\n"):format(objective.name, objective.progress, TotalEnemies, objective.timePassed)
        end
    end
	--print(secondsToString(timeElapsed))
    Objectives_label:SetText(text)
end

function secondsToString (secondsToChange)
	
	local minutes = math.floor((secondsToChange % 3600) / 60)
			local seconds = secondsToChange % 60
	
	secondsToChange = string.format("%02d:%02d", minutes, seconds)
	return secondsToChange
end


-- Function to get scenario objectives
function GetScenarioObjectives()
    local dungeon, _, steps = C_Scenario.GetStepInfo()
    local objectives = {}

    for i = 1, steps do
        local objectiveName, _, completed, progress = C_Scenario.GetCriteriaInfo(i)
        local status = completed and "|cFF00FF00Completed|r" or "|cFFFF0000Incomplete|r"
        local timePassed = ""

        -- Check if objective is completed and the completion time has not been recorded yet
        if completed and not completionTimes[i] then
            -- Record the completion time for this objective
            timePassed = secondsToString(timeElapsed)
			completionTimes[i] = timePassed
            
            print(objectiveName .. timePassed) -- Print to chat
        elseif completionTimes[i] then
            -- If completion time has already been recorded, use it
            timePassed = secondsToString(completionTimes[i])
        end

        table.insert(objectives, {name = objectiveName, status = status, progress = progress, timePassed = timePassed})
    end

    return objectives
end

function printTable(tbl)
		for key, value in pairs(tbl) do
        print(key, value)
    end
end

function TotalDungeonEnemies(indexNumber)
	--local dungeonName, _, _ = C_Scenario.GetStepInfo()
	--print("Dungeon Name:", dungeonName)
	
	
	
	local _, _, _, _, totalQuantity = C_Scenario.GetCriteriaInfo(indexNumber)
	--if dungeonName == "Gate of the Setting Sun" then
	--	TotalEnemies = "25" -- Assign the value to TotalEnemies directly
	--end 
	TotalEnemies = totalQuantity
	return TotalEnemies
end

-- Create a frame for the label
Objectives_frame = CreateFrame("Frame", "MyAddonObjectivesFrame", UIParent)
Objectives_frame:SetSize(300, 100) -- Set the size of the label frame
Objectives_frame:SetPoint("CENTER", UIParent, "CENTER")

-- Create a font string to display the objectives inside the objectives frame
Objectives_label = Objectives_frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
Objectives_label:SetPoint("TOPLEFT", Objectives_frame, "TOPLEFT", 10, -10) -- Adjust position for the label
Objectives_label:SetJustifyH("LEFT") -- Align text to the left

-- Function to update objectives label continuously while timer is active
local function UpdateLabelOnTimer()
    UpdateObjectivesLabel()
end

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

-- Create a dropdown menu
local dropdownMenu = CreateFrame("Frame", "MyAddonDropdownMenu", UIParent, "UIDropDownMenuTemplate")
dropdownMenu.displayMode = "MENU"
dropdownMenu.initialize = function(self, level)
    local info = UIDropDownMenu_CreateInfo()
    if Objectives_frame.isLocked then
        info.text = "Unlock"
        info.func = function()
            Objectives_frame.isLocked = false
            UIDropDownMenu_Refresh(self)
        end
    else
        info.text = "Lock"
        info.func = function()
            Objectives_frame.isLocked = true
            Objectives_frame:StopMovingOrSizing()
            UIDropDownMenu_Refresh(self)
        end
    end
    UIDropDownMenu_AddButton(info, level)
end

-- Show the dropdown menu on right-click
Objectives_frame:SetScript("OnMouseDown", function(self, button)
    if button == "RightButton" then
        ToggleDropDownMenu(1, nil, dropdownMenu, self:GetName(), 0, 0)
    end
end)

-- Function to save frame position
function Objectives_frame:SavePosition()
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    CmHelperDB.Objectives_frame = {
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs,
    }
end

-- Function to handle timer start event
local function OnStartTimer()
    -- Show the label when timer starts
    Objectives_frame:Show()
    -- Start updating the label continuously
    Objectives_frame:SetScript("OnUpdate", UpdateLabelOnTimer)
    --local dungeonName, _, _ = C_Scenario.GetStepInfo()
    
end

-- Function to handle timer stop event
local function OnStopTimer()
    -- Refresh the objectives label one more time
    --UpdateObjectivesLabel()
    -- Stop updating the label continuously
    Objectives_frame:SetScript("OnUpdate", nil)
end

-- Function to handle instance reset event
local function OnInstanceReset()
    local _, _, _, difficultyName = GetInstanceInfo()
    if difficultyName == "Challenge Mode" then
        -- Show the objectives frame if the player is in a challenge mode instance
        Objectives_frame:Show()
		--TotalDungeonEnemies()
    end
end

-- Function to handle PLAYER_LOGIN
local function OnPlayerLogin()
    local _, _, _, difficultyName = GetInstanceInfo()
    if difficultyName == "Challenge Mode" then
        -- Always update the objectives label
        UpdateObjectivesLabel()
        --TotalDungeonEnemies()
        -- Show the objectives frame if the player is in a challenge mode
        Objectives_frame:Show()
    else
        -- Check if the player is in a scenario
        if C_Scenario.IsInScenario() then
            UpdateObjectivesLabel()
            Objectives_frame:Show()
			--TotalDungeonEnemies()
        else
            Objectives_frame:Hide()
        end
    end
    
    -- Load saved position if available
    if CmHelperDB and CmHelperDB.Objectives_frame then
        local position = CmHelperDB.Objectives_frame
        Objectives_frame:SetPoint(position.point, UIParent, position.relativePoint, position.xOfs, position.yOfs)
    end
end

-- Function to handle encounter start event
local function OnEncounterStart()
   print("START")
end

-- Function to handle encounter end event
local function OnEncounterEnd()
   print("FINISH")
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

Objectives_frame:SetScript("OnEvent", function(self, event, ...)
    if event == "START_TIMER" then
        OnStartTimer()
    elseif event == "WORLD_STATE_TIMER_STOP" then
        OnStopTimer()
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        -- OnChallengeModeCompleted()
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        OnPlayerLogin()  -- Call OnPlayerLogin whenever the player changes zone
    elseif event == "PLAYER_LOGIN" then
        OnPlayerLogin()  -- Call OnPlayerLogin when the player logs in
    elseif event == "INSTANCE_RESET" then
        OnInstanceReset()
    elseif event == "ENCOUNTER_START" then
        OnEncounterStart()
    elseif event == "ENCOUNTER_END" then
        OnEncounterEnd()
    end
end)

if not CmHelperDB then
    CmHelperDB = {
        BestBossKillTime = {}
    }
end

-- Ensure scenarios table exists
if not CmHelperDB.BestBossKillTime then
    CmHelperDB.BestBossKillTime = {}
end

-- Copy values from CmHelperDB.BestBossKillTime to localDB.BestBossKillTime
local localDB = {
    BestBossKillTime = {}
}
if CmHelperDB then
	for key, value in pairs(CmHelperDB.BestBossKillTime) do
		localDB.BestBossKillTime[key] = value
	end
end

local localDB = {
    BestBossKillTime = {}
}
localDB.BestBossKillTime["Wise Mari"] = ""
localDB.BestBossKillTime["Lorewalker Stonestep"] = ""
localDB.BestBossKillTime["Liu Flameheart"] = ""
localDB.BestBossKillTime["Sha of Doubt"] = ""
localDB.BestBossKillTime["Ook-Ook"] = ""
localDB.BestBossKillTime["Hoptallus"] = ""
localDB.BestBossKillTime["Yan-Zhu the Uncasked"] = ""
localDB.BestBossKillTime["Saboteur Kip'tilak"] = "05:50"
localDB.BestBossKillTime["Striker Ga'dok"] = "10:15"
localDB.BestBossKillTime["Commander Ri'mok"] = ""
localDB.BestBossKillTime["Raigonn"] = ""
localDB.BestBossKillTime["Gu Cloudstrike"] = ""
localDB.BestBossKillTime["Master Snowdrift"] = ""
localDB.BestBossKillTime["Sha of Violence"] = ""
localDB.BestBossKillTime["Taran Zhu"] = ""
localDB.BestBossKillTime["Trial of the King"] = ""
localDB.BestBossKillTime["Gekkan"] = ""
localDB.BestBossKillTime["Xin the Weaponmaster"] = ""

for key, value in pairs(CmHelperDB.BestBossKillTime) do
    localDB.BestBossKillTime[key] = value
end

-- Define a mock version of C_Scenario.GetCriteriaInfo(i) for testing
local function Mock_GetCriteriaInfo(i)
    -- Simulate completed objectives
    if i == 1 then
        -- criteriaString, criteriaType, completed, quantity, totalQuantity
        return "Saboteur Kip'tilak", "", true, 1, 1
    elseif i == 2 then
        return "Striker Ga'dok", "", false, 0, 1
    elseif i == 3 then
        return "Commander Ri'mok", "", false, 0, 1
    elseif i == 4 then
        return "Raigonn", "", false, 0, 1
    elseif i == 5 then
        return "Enemies", "", true, 25, 25
    end
end

local function Mock_GetCriteriaInfo2(i)
    -- Simulate completed objectives
    if i == 1 then
        return "Saboteur Kip'tilak", "", true, 1, 1
    elseif i == 2 then
        return "Striker Ga'dok", "", true, 1, 1
    elseif i == 3 then
        return "Commander Ri'mok", "", false, 0, 1
    elseif i == 4 then
        return "Raigonn", "", false, 0, 1
    elseif i == 5 then
        return "Enemies", "", true, 25, 25
    end
end

-- Initialize saved variables
if not CmHelperDB then
    CmHelperDB = {}
end

-- Define a table to store completion times for objectives
local completionTimes = {}

local Objectives_frame
local Objectives_label
local TotalEnemies = "" -- Initialize TotalEnemies variable

-- Variable to store the selected color option
local colorPicked = 0

-- Function to update the size of the frame based on the text size
local function UpdateFrameSize()
    local textWidth = Objectives_label:GetStringWidth() + 20 -- Add some padding
    local textHeight = Objectives_label:GetStringHeight() + 20 -- Add some padding
    Objectives_frame:SetSize(textWidth, textHeight)
end

-- Function to update the objectives label text
local function UpdateObjectivesLabel()

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
	if localDB.BestBossKillTime[objective.name]== nil then
		localDB.BestBossKillTime[objective.name]="N/A"
	end
		if objective.bossTimeToKill== nil then
		objective.bossTimeToKill="N/A"
	end
        TotalDungeonEnemies(i)
        if i < #objectives then
            text = text .. ("%s %s %s\n"):format(objective.name, objective.bossTimeToKill, objective.timePassed)
        else
            text = text .. ("%s : %d/%d\n"):format(objective.name, objective.progress, TotalEnemies)
        end
    end
    
    Objectives_label:SetText(text)
    -- After updating the text, call the function to update the frame size
    UpdateFrameSize()
end

function secondsToString(secondsToChange)
    local minutes = math.floor((secondsToChange % 3600) / 60)
    local seconds = secondsToChange % 60
    secondsToChange = string.format("%02d:%02d", minutes, seconds)
    return secondsToChange
end

-- Function to get scenario objectives
function GetScenarioObjectives()

-- TESTING ---

    if timeElapsed > 7 and timeElapsed < 9 then
        -- Replace the original C_Scenario.GetCriteriaInfo() function with the mock version
        C_Scenario.GetCriteriaInfo = Mock_GetCriteriaInfo
    elseif timeElapsed > 9 then
        C_Scenario.GetCriteriaInfo = Mock_GetCriteriaInfo2
    end
    -- /END TESTING ---

    local dungeon, _, steps = C_Scenario.GetStepInfo()
    local objectives = {}
	local bossTimeToKill
	
    for i = 1, steps do
        local objectiveName, _, completed, progress = C_Scenario.GetCriteriaInfo(i)
		local formattedObjectiveName = objectiveName
        --local status = completed and "|cFF00FF00Completed|r" or "|cFFFF0000Incomplete|r"
		if completed then
			formattedObjectiveName = "|cFF00FF00" .. objectiveName .. "|r"
		end
        local timePassed = ""
		bossTimeToKill = localDB.BestBossKillTime[objectiveName]

        -- Check if objective is completed and the completion time has not been recorded yet
        if completed and not completionTimes[i] then
            -- Record the completion time for this objective
			
            timePassed = secondsToString(timeElapsed)
            completionTimes[i] = timePassed
            
            print(objectiveName .. timePassed) -- Print to chat
        elseif completionTimes[i] then
            -- If completion time has already been recorded, use it

		if localDB.BestBossKillTime == objectiveName then
			bossTimeToKill= localDB.BestBossKillTime[objectiveName]
		end

            timePassed = completionTimes[i] --secondsToString(completionTimes[i])
			-- if localDB.BestBossKillTime[objectiveName] == "" or timeStringToSeconds(localDB.BestBossKillTime[objectiveName]) > timeStringToSeconds(completionTimes[i]) then
           --    localDB.BestBossKillTime[objectiveName] = completionTimes[i]
           --end
        end

        table.insert(objectives, {name = formattedObjectiveName, progress = progress, timePassed = timePassed, bossTimeToKill=bossTimeToKill})
    end

    return objectives
end

function timeStringToSeconds(timeString)
    if not timeString then
        return 0  -- Return 0 or any default value if timeString is nil
    end

    local minutes, seconds = timeString:match("(%d+):(%d+)")
    if not minutes or not seconds then
        return 0  -- Return 0 or any default value if timeString is in an invalid format
    end

    return tonumber(minutes) * 60 + tonumber(seconds)
end

function printTable(tbl)
    for key, value in pairs(tbl) do
        print(key, value)
    end
end

function TotalDungeonEnemies(indexNumber)
    local _, _, _, _, totalQuantity = C_Scenario.GetCriteriaInfo(indexNumber)
    TotalEnemies = totalQuantity
    return TotalEnemies
end

-- Create a frame for the label
Objectives_frame = CreateFrame("Frame", "MyAddonObjectivesFrame", UIParent)
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
        bottom = 4,
    },
})

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

-- Function to create the dropdown menu
local function CreateDropdownMenu()
    local dropdownMenu = CreateFrame("Frame", "MyAddonDropdownMenu", UIParent, "UIDropDownMenuTemplate")
    dropdownMenu.displayMode = "MENU"
    dropdownMenu.initialize = function(self, level)
        if level == 1 then
            local info = UIDropDownMenu_CreateInfo()
            if Objectives_frame.isLocked then
                info.text = "Unlock"
                info.func = function()
                    Objectives_frame.isLocked = false
                    UIDropDownMenu_Refresh(self)
                    UpdateObjectivesLabel() -- Update label after changing lock state
                end
            else
                info.text = "Lock"
                info.func = function()
                    Objectives_frame.isLocked = true
                    Objectives_frame:StopMovingOrSizing()
                    UIDropDownMenu_Refresh(self)
                    UpdateObjectivesLabel() -- Update label after changing lock state
                end
            end
            UIDropDownMenu_AddButton(info, level)

            info = UIDropDownMenu_CreateInfo()
            info.text = "Background"
            info.hasArrow = true
            info.value = "background"
            UIDropDownMenu_AddButton(info, level)
        elseif level == 2 then
            if UIDROPDOWNMENU_MENU_VALUE == "background" then
                local info = UIDropDownMenu_CreateInfo()
                info.text = "0%"
                info.func = function()
                    Objectives_frame:SetBackdropColor(0, 0, 0, 0)
                    UIDropDownMenu_SetSelectedValue(dropdownMenu, 0)
                    colorPicked = 0 -- Update colorPicked variable
                    UpdateObjectivesLabel() -- Update label after changing background
                end
                info.checked = colorPicked == 0 and 1 or nil
                UIDropDownMenu_AddButton(info, level)

                info = UIDropDownMenu_CreateInfo()
                info.text = "25%"
                info.func = function()
                    Objectives_frame:SetBackdropColor(0, 0, 0, 0.25)
                    UIDropDownMenu_SetSelectedValue(dropdownMenu, 0.25)
                    colorPicked = 0.25 -- Update colorPicked variable
                    UpdateObjectivesLabel() -- Update label after changing background
                end
                info.checked = colorPicked == 0.25 and 1 or nil
                UIDropDownMenu_AddButton(info, level)

                info = UIDropDownMenu_CreateInfo()
                info.text = "50%"
                info.func = function()
                    Objectives_frame:SetBackdropColor(0, 0, 0, 0.50)
                    UIDropDownMenu_SetSelectedValue(dropdownMenu, 0.50)
                    colorPicked = 0.50 -- Update colorPicked variable
                    UpdateObjectivesLabel() -- Update label after changing background
                end
                info.checked = colorPicked == 0.50 and 1 or nil
                UIDropDownMenu_AddButton(info, level)

                info = UIDropDownMenu_CreateInfo()
                info.text = "75%"
                info.func = function()
                    Objectives_frame:SetBackdropColor(0, 0, 0, 0.75)
                    UIDropDownMenu_SetSelectedValue(dropdownMenu, 0.75)
                    colorPicked = 0.75 -- Update colorPicked variable
                    UpdateObjectivesLabel() -- Update label after changing background
                end
                info.checked = colorPicked == 0.75 and 1 or nil
                UIDropDownMenu_AddButton(info, level)

                info = UIDropDownMenu_CreateInfo()
                info.text = "100%"
                info.func = function()
                    Objectives_frame:SetBackdropColor(0, 0, 0, 1)
                    UIDropDownMenu_SetSelectedValue(dropdownMenu, 1)
                    colorPicked = 1 -- Update colorPicked variable
                    UpdateObjectivesLabel() -- Update label after changing background
                end
                info.checked = colorPicked == 1 and 1 or nil
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end
    return dropdownMenu
end

-- Create a dropdown menu and store it in a variable
local dropdownMenu = CreateDropdownMenu()

-- Show the dropdown menu on right-click
Objectives_frame:SetScript("OnMouseDown", function(self, button)
    if button == "RightButton" then
        -- Set the colorPicked variable before showing the dropdown menu
        UIDropDownMenu_SetSelectedValue(dropdownMenu, colorPicked)
        ToggleDropDownMenu(1, nil, dropdownMenu, self:GetName(), 0, 0)
    end
end)

-- Function to save frame position
function Objectives_frame:SavePosition()
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    local r, g, b, a = self:GetBackdropColor()
    CmHelperDB.Objectives_frame = {
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs,
        alpha = a, -- Save the alpha value of the backdrop color
        colorPicked = colorPicked, -- Save the selected color option
    }
end

-- Function to handle timer start event
local function OnStartTimer()
    -- Show the label when timer starts
    Objectives_frame:Show()
    -- Start updating the label continuously
    Objectives_frame:SetScript("OnUpdate", UpdateLabelOnTimer)
end

-- Function to handle timer stop event
local function OnStopTimer()
    -- Refresh the objectives label one more time
    UpdateObjectivesLabel()
    -- Stop updating the label continuously
    Objectives_frame:SetScript("OnUpdate", nil)
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
	elseif event == "PLAYER_ENTERING_WORLD" then
WatchFrame:SetScript("OnEvent", nil)
        WatchFrame:Hide()
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        -- OnChallengeModeCompleted()
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        -- Call UpdateObjectivesLabel whenever the player changes zone
        UpdateObjectivesLabel()
    elseif event == "PLAYER_LOGIN" then
        -- Call UpdateObjectivesLabel when the player logs in
        UpdateObjectivesLabel()
        
        -- Load saved position, transparency, and colorPicked
        local savedPosition = CmHelperDB.Objectives_frame
        if savedPosition then
            Objectives_frame:SetPoint(savedPosition.point, UIParent, savedPosition.relativePoint, savedPosition.xOfs, savedPosition.yOfs)
            Objectives_frame:SetBackdropColor(0, 0, 0, savedPosition.alpha)
            colorPicked = savedPosition.colorPicked or 0
        end
    elseif event == "INSTANCE_RESET" then
        -- Call UpdateObjectivesLabel when instance resets
        UpdateObjectivesLabel()
    elseif event == "ENCOUNTER_START" then
        -- Call UpdateObjectivesLabel when encounter starts
        UpdateObjectivesLabel()
    elseif event == "ENCOUNTER_END" then
        -- Call UpdateObjectivesLabel when encounter ends
        UpdateObjectivesLabel()
    end
end)

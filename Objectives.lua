local Objectives_frame
local Objectives_label
local colorPicked = 0 -- Variable to store the selected color option

-- Function to update the size of the frame based on the text size
local function UpdateFrameSize()
    local textWidth = Objectives_label:GetStringWidth() + 20 -- Add some padding
    local textHeight = Objectives_label:GetStringHeight() + 20 -- Add some padding
    Objectives_frame:SetSize(textWidth, textHeight)
end

-- Function to update the objectives label text
local function UpdateObjectivesLabel()
    local objectives = GetScenarioObjectives()

    -- Check if there are any objectives available
    if #objectives > 0 then
        local text = ""
        for i, objective in ipairs(objectives) do
            TotalDungeonEnemies(i)
            if i < #objectives then
                text = text .. ("%s\n"):format(objective.name)
            else
                text = text .. ("%s : %d/%d\n"):format(objective.name, objective.progress, TotalEnemies)
            end
        end
        Objectives_label:SetText(text)
    else
        -- If there are no objectives available, display a message
        --Objectives_label:SetText("No objectives available")
    end

    -- After updating the text, call the function to update the frame size
    UpdateFrameSize()
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
        bottom = 4
    }
})

-- Create a font string to display the objectives inside the objectives frame
Objectives_label = Objectives_frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
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
    local dropdownMenu = CreateFrame("Frame", "MyAddonDropdownMenu", UIParent, "UIDropDownMenuTemplate")
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

            info = UIDropDownMenu_CreateInfo()
            info.text = "Background"
            info.hasArrow = true
            info.notCheckable = true
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
                    Objectives_frame:SavePosition()
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
                    Objectives_frame:SavePosition()
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
                    Objectives_frame:SavePosition()
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
                    Objectives_frame:SavePosition()
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
                    Objectives_frame:SavePosition()
                end
                info.checked = colorPicked == 1 and 1 or nil
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
    local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
    local r, g, b, a = self:GetBackdropColor()
    CmHelperDB.Objectives_frame = {
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs,
        alpha = a, -- Save the alpha value of the backdrop color
        colorPicked = colorPicked -- Save the selected color option
    }
end

-- Function to get scenario objectives
function GetScenarioObjectives()
    local dungeon, _, steps = C_Scenario.GetStepInfo()
    local objectives = {}

    for i = 1, steps do
        local objectiveName, _, completed, progress = C_Scenario.GetCriteriaInfo(i)
        local formattedObjectiveName = objectiveName

        -- Check if objective is completed and format the name with color for display
        if completed then
            formattedObjectiveName = "|cFF00FF00" .. formattedObjectiveName .. "|r" -- Green color for completion
        end
		
        table.insert(objectives, {
            name = formattedObjectiveName,
            status = status,
            progress = progress
        })
    end

    return objectives
end

function TotalDungeonEnemies(indexNumber)
    local _, _, _, _, totalQuantity = C_Scenario.GetCriteriaInfo(indexNumber)
    TotalEnemies = totalQuantity
    return TotalEnemies
end

-- Function to check if all objectives are complete
local function AreObjectivesComplete()
    local objectives = GetScenarioObjectives()
    for _, objective in ipairs(objectives) do
        if not objective.completed then
            return false  -- Return false if any objective is incomplete
        end
    end
    return true  -- Return true if all objectives are complete
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
		
    elseif event == "WORLD_STATE_TIMER_STOP" then
		Objectives_frame:SetScript("OnUpdate", nil)
	elseif event == "PLAYER_ENTERING_WORLD" then
	-- Check if the player is in a challenge mode instance
        local _, _, _, difficultyName = GetInstanceInfo()
        if difficultyName == "Challenge Mode" then
            -- If in a challenge mode instance, hide the WatchFrame UI
            WatchFrame:SetScript("OnEvent", nil)
            WatchFrame:Hide()
            Objectives_frame:Show()
        else
            Objectives_frame:Hide()
        end
		UpdateObjectivesLabel()
    elseif event == "CHALLENGE_MODE_COMPLETED" then

    elseif event == "CRITERIA_COMPLETE" then

    elseif event == "ZONE_CHANGED_NEW_AREA" then

    elseif event == "PLAYER_LOGIN" then
		-- Load saved position, transparency, and colorPicked
		local savedPosition = CmHelperDB.Objectives_frame
        if savedPosition then
            Objectives_frame:SetPoint(savedPosition.point, UIParent, savedPosition.relativePoint, savedPosition.xOfs, savedPosition.yOfs)
            Objectives_frame:SetBackdropColor(0, 0, 0, savedPosition.alpha)
            colorPicked = savedPosition.colorPicked or 0
        end
    elseif event == "INSTANCE_RESET" then

    elseif event == "ENCOUNTER_START" then

    elseif event == "ENCOUNTER_END" then

    elseif event == "ADDON_LOADED" then

    elseif event == "PLAYER_LOGOUT" then

    elseif event == "SCENARIO_UPDATE" then
		UpdateObjectivesLabel()
	elseif event == "CRITERIA_UPDATE" then
		UpdateObjectivesLabel()
    end
end)

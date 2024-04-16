local objectivesFrame 
	
	-- Function to update a label with objectives, progress, elapsed time, and record completion times
function UpdateLabelWithObjectives(labelFrame)
    local text = ""
    local objectives = GetScenarioObjectives()
    local dungeon, _, steps = C_Scenario.GetStepInfo()

    -- Check if objectives table is empty or not properly populated
    if #objectives == 0 then
        labelFrame:SetText("No objectives found.")
        return
    end

    for i, objective in ipairs(objectives) do
        local objectiveName = objective.name
        local objectiveProgress = objective.progress
        local recordKillTime = formatSecondsToMinutes(GetRecordKillTime(dungeon, objectiveName)) -- Retrieve record kill time
        
        -- Get elapsed time string inside the loop
        local timeString = formatSecondsToMinutes(GetElapsedTime())

        -- Append each objective's information to text
        if i < #objectives then
            text = text .. ("%s %s %s\n"):format(objectiveName, timeString, recordKillTime)
        else
            -- Last objective is number of enemies
            text = text .. ("%s : %d\n"):format(objectiveName, objectiveProgress)
        end
    end

    labelFrame:SetText(text)
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



local function MyAddonObjectivesFrame()
		-- Create a frame for the label
		objectivesFrame = CreateFrame("Frame", "MyAddonObjectivesFrame", UIParent)
		objectivesFrame:SetSize(200, 100) -- Set the size of the label frame
		

		-- Create a font string to display the hello text inside the objectives frame
local helloLabel = objectivesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
helloLabel:SetPoint("LEFT", objectivesFrame, "LEFT", 0, 0) -- Adjust the offset as needed
helloLabel:SetText("Hello")
		
end

	local function OnPlayerLogin()

			objectivesFrame = MyAddonObjectivesFrame()
	
	end


	-- Event handler for PLAYER_ENTERING_WORLD
	local function OnPlayerEnteringWorld()
		objectivesFrame = MyAddonObjectivesFrame()
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

	frame:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_ENTERING_WORLD" then
			OnPlayerEnteringWorld()
		elseif event == "WORLD_STATE_TIMER_START" then
			-- OnWorldStateTimerStart()
		elseif event == "WORLD_STATE_TIMER_STOP" then
			OnWorldStateTimerStop()
		elseif event == "CHALLENGE_MODE_COMPLETED" then
			OnChallengeModeCompleted()
		elseif event == "ZONE_CHANGED_NEW_AREA" then
			OnZoneChangedNewArea()
		elseif event == "PLAYER_LOGIN" then
			OnPlayerLogin()
		elseif event == "START_TIMER" then
			OnStartTimer()
		end
	end)

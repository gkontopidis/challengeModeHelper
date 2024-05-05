-- MyChallengeAddon.lua

-- Saved variable to store positions
local SavedPositions = {}

-- Define the GetSavedPosition function
local function GetSavedPosition(frame)
    return SavedPositions[frame:GetName()] or {"CENTER", UIParent, "CENTER", 0, 0}
end

-- Define the SavePosition function
local function SavePosition(frame)
    SavedPositions[frame:GetName()] = {frame:GetPoint()}
end

-- Create the frame
local frame = CreateFrame("Frame", "StrategyFrame", UIParent)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LOGOUT") -- Register logout event
frame:RegisterEvent("ADDON_LOADED")

-- Define a flag to track the visibility of the frame
local frameVisible = false

-- Set up frame event handling
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local scenarioName, _, _, difficultyName = GetInstanceInfo()
        if difficultyName == "Challenge Mode" then
            local strategies = StrategyData[scenarioName]
            if strategies then
                frame:SetSize(100, #strategies * 50) -- Adjust size based on the number of strategies
                frame:SetPoint(unpack(GetSavedPosition(frame))) -- Set position based on saved position
                
                -- Enable frame for movement
                frame:RegisterForDrag("LeftButton")
                frame:SetMovable(true)
                frame:EnableMouse(true)
                frame:SetScript("OnDragStart", function(self)
                    self:StartMoving()
                end)
                frame:SetScript("OnDragStop", function(self)
                    self:StopMovingOrSizing()
                    SavePosition(self) -- Save position when dragging stops
                end)

                -- Create buttons for each strategy
                for i, strategy in ipairs(strategies) do
                    CreateButton(frame, scenarioName, i, i)
                end
            end
            frame:Hide()
        else
            frame:Hide()
        end
    elseif event == "PLAYER_LOGOUT" then
        -- Save positions on logout
        SavePosition(frame)
        frame:Hide() 
        CmHelperDB.SavedPositions = SavedPositions
    elseif event == "PLAYER_LOGIN" then
        -- Function to load frame position
        if CmHelperDB and CmHelperDB.SavedPositions then
            SavedPositions = CmHelperDB.SavedPositions
        end
        frame:setPoint(SavedPositions.StrategyFrame)
    end
end)

-- Define a template for the button labels
local BUTTON_LABEL_TEMPLATE = "Strategy %d"

function CreateButton(parent, scenarioName, strategyIndex, buttonIndex)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetText(BUTTON_LABEL_TEMPLATE:format(buttonIndex))
    button:SetSize(80, 25)
    button:SetPoint("TOP", 0, -buttonIndex * 30)
    
    -- OnClick handler
    button:SetScript("OnClick", function()
        local strategy = StrategyData[scenarioName][strategyIndex]
        if strategy then
            SendChatMessage(strategy, "SAY")
        end
    end)
    
    -- OnEnter handler
    button:SetScript("OnEnter", function(self)
        local strategy = StrategyData[scenarioName][strategyIndex]
        if strategy then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(strategy, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end
    end)
    
    -- OnLeave handler
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

-- Load saved positions on addon load
frame:SetScript("OnLoad", function(self)
    self:SetPoint(unpack(GetSavedPosition(self)))
end)

-- Create the toggle button
local toggleButton = CreateFrame("Button", "MyToggleAddonButton", UIParent, "UIPanelButtonTemplate")
toggleButton:RegisterEvent("PLAYER_ENTERING_WORLD")
toggleButton:RegisterEvent("PLAYER_LOGOUT") -- Register logout event

toggleButton:SetText("Strategies")
toggleButton:SetSize(100, 25)

toggleButton:RegisterForDrag("LeftButton")
toggleButton:SetMovable(true)
toggleButton:EnableMouse(true)
toggleButton:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 10) -- Set default position

toggleButton:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

toggleButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SavePosition(self) -- Save position when dragging stops
end)

toggleButton:SetScript("OnClick", function()
    if frameVisible then
        frame:Hide()
        frameVisible = false
    else
        frame:Show()
        frameVisible = true
    end
end)
toggleButton:Hide()
toggleButton:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local scenarioName, _, _, difficultyName = GetInstanceInfo()
        if difficultyName == "Challenge Mode" then
            toggleButton:Show()
        else
            toggleButton:Hide()
        end
    elseif event == "PLAYER_LOGOUT" then
        SavePosition(toggleButton)
    end
end)
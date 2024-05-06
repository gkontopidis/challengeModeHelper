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

-- Function to create the "Add New" strategy frame
local function CreateNewStrategyFrame()
    local newStrategyFrame = CreateFrame("Frame", "NewStrategyFrame", UIParent, "BasicFrameTemplate")
    newStrategyFrame:SetSize(300, 200)
    newStrategyFrame:SetPoint("CENTER")
    newStrategyFrame.title = newStrategyFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    newStrategyFrame.title:SetPoint("TOP", 0, -5)
    newStrategyFrame.title:SetText("Add New Strategy")
    newStrategyFrame:SetMovable(true)
    newStrategyFrame:RegisterForDrag("LeftButton")
    newStrategyFrame:EnableMouse(true)
    newStrategyFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    newStrategyFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition(self) -- Save position when dragging stops
    end)

    -- Create ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", "NewStrategyScrollFrame", newStrategyFrame,
        "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    -- Create EditBox inside ScrollFrame
    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetSize(250, 100)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(true)
    editBox:SetFontObject(GameFontHighlight)
    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    scrollFrame:SetScrollChild(editBox)

    local confirmButton = CreateFrame("Button", nil, newStrategyFrame, "UIPanelButtonTemplate")
    confirmButton:SetText("Confirm")
    confirmButton:SetSize(80, 25)
    confirmButton:SetPoint("BOTTOMLEFT", 20, 20)
    confirmButton:SetScript("OnClick", function()
        local newStrategy = editBox:GetText()
        AddNewStrategyConfirmation(newStrategy)
        newStrategyFrame:Hide()
    end)

    local cancelButton = CreateFrame("Button", nil, newStrategyFrame, "UIPanelButtonTemplate")
    cancelButton:SetText("Cancel")
    cancelButton:SetSize(80, 25)
    cancelButton:SetPoint("BOTTOMRIGHT", -20, 20)
    cancelButton:SetScript("OnClick", function()
        newStrategyFrame:Hide()
    end)

    newStrategyFrame:Show()
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

-- Function to create the "Add New" button
local function CreateAddNewButton(parent)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetText("Add New")
    button:SetSize(80, 25)
    button:SetPoint("BOTTOM", 0, 10)

    button:SetScript("OnClick", function()
        CreateNewStrategyFrame()
    end)

    return button
end

-- Function to handle adding a new strategy
local function AddNewStrategy(scenarioName, newStrategy)
    if StrategyData[scenarioName] == nil then
        StrategyData[scenarioName] = {}
    end
    table.insert(StrategyData[scenarioName], newStrategy)
end

-- Function to handle the confirmation of adding a new strategy
function AddNewStrategyConfirmation(text)
    local scenarioName, _, _, difficultyName = GetInstanceInfo()
    if difficultyName == "Challenge Mode" then
        AddNewStrategy(scenarioName, text)
        UpdateButtons() -- Update the UI to reflect the new strategy
    end
end

-- Function to create the add new strategy popup dialog
local function CreateAddNewStrategyPopup()
    StaticPopupDialogs["ADD_NEW_STRATEGY"] = {
        text = "Enter the new strategy:",
        button1 = "Confirm",
        button2 = "Cancel",
        OnAccept = function(self)
            local editBox = self.editBox
            local text = editBox:GetText()
            if text ~= "" then
                AddNewStrategyConfirmation(text)
            end
            editBox:SetText("")
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        hasEditBox = true,
        preferredIndex = 3,
        OnShow = function(self)
            self.editBox:SetFocus()
        end,
        OnHide = function(self)
            self.editBox:SetText("")
        end
    }
end

-- Call the function to create the add new strategy popup dialog
CreateAddNewStrategyPopup()

-- Create the "Add New" button and attach it to the frame
local addButton = CreateAddNewButton(frame)

-- Function to update buttons after adding a new strategy
function UpdateButtons()
    frame:Hide() -- Hide the frame temporarily to clear existing buttons
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
    end
    frame:Show() -- Show the frame again after updating buttons
end

-- Saved variable to store strategies
local SavedStrategies = {}
local SavedPositions = {}
local RemoveStrategyIcon="Interface\\Buttons\\UI-GroupLoot-Pass-Down"

-- Function to get saved position for a frame
local function GetSavedPosition(frame)
    return SavedPositions[frame:GetName()] or {"CENTER", UIParent, "CENTER", 0, 0}
end

-- Function to set position for a frame
local function SetSavedPosition(frame)
    local position = GetSavedPosition(frame)
    frame:SetPoint(unpack(position))
end

-- Function to save position for a frame
local function SavePosition(frame)
    SavedPositions[frame:GetName()] = {frame:GetPoint()}
end

-- Function to save strategies
local function SaveStrategies()
    CmHelperDB.Strategies = SavedStrategies
end

-- Function to load strategies
local function LoadStrategies()
    SavedStrategies = CmHelperDB.Strategies or {}
end

-- Function to destroy all child frames of a parent frame
local function ClearAllChildFrames(parentFrame)
    local children = {parentFrame:GetChildren()}
    for _, child in ipairs(children) do
        child:Hide() -- Hide the child frame
        child:SetParent(nil) -- Remove its parent reference
    end
end

-- Function to handle removing a strategy
local function RemoveStrategy(scenarioName, strategyIndex)
    if SavedStrategies[scenarioName] then
        table.remove(SavedStrategies[scenarioName], strategyIndex)
        -- After removing the strategy, update the buttons
        UpdateButtons()
    end
end

-- Function to create the "Remove Strategy" button
local function CreateRemoveButton(parent, scenarioName, strategyIndex)
    local removeButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    removeButton:SetSize(15, 15)
    removeButton:SetPoint("RIGHT", 15, 0)
    removeButton:SetNormalTexture(RemoveStrategyIcon)
    
    removeButton:SetScript("OnClick", function()
        StaticPopupDialogs["CONFIRM_REMOVE_STRATEGY"] = {
            text = "Are you sure you want to remove this strategy?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                RemoveStrategy(scenarioName, strategyIndex)
                UpdateButtons()
                _G["MyChallengeAddonFrame"]:Show()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            showAlert = true,
        }
        StaticPopup_Show("CONFIRM_REMOVE_STRATEGY")
    end)

    return removeButton
end

-- Function to create a button
local function CreateButton(parent, scenarioName, strategyIndex, buttonIndex)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetText("Strategy " .. buttonIndex)
    button:SetSize(80, 25)
    button:SetPoint("TOP", 0, -buttonIndex * 30)

    -- OnClick handler
    button:SetScript("OnClick", function()
        local strategy = SavedStrategies[scenarioName][strategyIndex]
        if strategy then
            SendChatMessage(strategy, "SAY")
        end
    end)

    -- OnEnter handler
    button:SetScript("OnEnter", function(self)
        local strategy = SavedStrategies[scenarioName][strategyIndex]
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

    -- Create remove button
    local removeButton = CreateRemoveButton(button, scenarioName, strategyIndex)
end


-- Function to update buttons after adding a new strategy
function UpdateButtons()
    local frame = MyChallengeAddonFrame
    local strategies
    frame:Hide()
    local scenarioName, _, _, difficultyName = GetInstanceInfo()
    if difficultyName == "Challenge Mode" then
        strategies = SavedStrategies[scenarioName]
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

            -- Clear existing buttons
            ClearAllChildFrames(frame)

            -- Create buttons for each strategy
            for i, strategy in ipairs(strategies) do
                CreateButton(frame, scenarioName, i, i)
            end
        else
            ClearAllChildFrames(frame)
        end
        frame:Hide() -- Show the frame again after updating buttons
    else
        frame:Hide()
    end
end

-- Function to handle adding a new strategy
local function AddNewStrategy(scenarioName, newStrategy)
    if SavedStrategies[scenarioName] == nil then
        SavedStrategies[scenarioName] = {}
    end
    table.insert(SavedStrategies[scenarioName], newStrategy)
    -- After adding the new strategy, update the buttons
    UpdateButtons()
end

-- Function to handle adding a new strategy
local function AddNewStrategyConfirmation(text)
    local scenarioName, _, _, difficultyName = GetInstanceInfo()
    if difficultyName == "Challenge Mode" then
        AddNewStrategy(scenarioName, text)
        UpdateButtons() -- Update the UI to reflect the new strategy
        MyChallengeAddonFrame:Show()
    end
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

    -- Create Confirm Button
    local confirmButton = CreateFrame("Button", nil, newStrategyFrame, "UIPanelButtonTemplate")
    confirmButton:SetText("Confirm")
    confirmButton:SetSize(80, 25)
    confirmButton:SetPoint("BOTTOMLEFT", 20, 20)
    confirmButton:SetScript("OnClick", function()
        local newStrategy = editBox:GetText()
        AddNewStrategyConfirmation(newStrategy)
        newStrategyFrame:Hide()
    end)

    -- Create Cancel Button
    local cancelButton = CreateFrame("Button", nil, newStrategyFrame, "UIPanelButtonTemplate")
    cancelButton:SetText("Cancel")
    cancelButton:SetSize(80, 25)
    cancelButton:SetPoint("BOTTOMRIGHT", -20, 20)
    cancelButton:SetScript("OnClick", function()
        newStrategyFrame:Hide()
    end)

    newStrategyFrame:Show()
end

-- Function to create the toggle button
local function CreateToggleButton()
    local button = CreateFrame("Button", "ToggleStrategiesButton", UIParent, "UIPanelButtonTemplate")
    button:SetText("Strategies")
    button:SetSize(120, 25)
    button:SetPoint("TOPLEFT", 20, -20)
    button:RegisterForDrag("LeftButton")
    button:SetMovable(true)
    button:EnableMouse(true)
    button:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition(self) -- Save position when dragging stops
    end)

    -- Create "Add New" button
    local addButton = CreateFrame("Button", "AddStrategyButton", UIParent, "UIPanelButtonTemplate")
    addButton:SetText("Add New")
    addButton:SetSize(80, 25)
    addButton:SetPoint("LEFT", button, "RIGHT", 10, 0)
    addButton:SetScript("OnClick", function()
        CreateNewStrategyFrame()
    end)

    -- Initially hide the "Add New" button
    addButton:Hide()

    button:SetScript("OnClick", function()
        if MyChallengeAddonFrame:IsShown() then
            MyChallengeAddonFrame:Hide()
            addButton:Hide()
        else
            MyChallengeAddonFrame:Show()
            --if IsAddNewButtonVisible then
                addButton:Show() -- Show the "Add New" button only if it's set to be visible
           -- end
        end
    end)

    return button
end

-- Initialize the addon
local function Init()
    -- Create the main frame
    local frame = CreateFrame("Frame", "MyChallengeAddonFrame", UIParent)
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("PLAYER_LOGOUT") -- Register logout event
    frame:RegisterEvent("ADDON_LOADED")
    frame:RegisterEvent("PLAYER_LOGIN") -- Register login event

    -- Create the toggle button
    local toggleButton = CreateToggleButton()

    -- Set up frame event handling
    frame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            local scenarioName, _, _, difficultyName = GetInstanceInfo()
            if difficultyName == "Challenge Mode" then
                LoadStrategies()
                if not _G["ToggleStrategiesButton"] then
                    CreateToggleButton()
                else
                    _G["ToggleStrategiesButton"]:Show()
                end
            else
                if _G["ToggleStrategiesButton"] then
                    _G["ToggleStrategiesButton"]:Hide()
                    _G["AddStrategyButton"]:Hide()
                end
            end
            UpdateButtons()
        elseif event == "PLAYER_LOGOUT" then
            -- Save positions on logout
            SaveStrategies()
            SavePosition(self)
            SavePosition(toggleButton) -- Save toggle button's position
            self:Hide()
            CmHelperDB.SavedPositions = SavedPositions
        elseif event == "PLAYER_LOGIN" then
            -- Load saved strategies on login
            LoadStrategies()
            -- Update UI to reflect loaded strategies
            UpdateButtons()
            -- Load saved positions on login
            if CmHelperDB and CmHelperDB.SavedPositions then
                SavedPositions = CmHelperDB.SavedPositions
            end
            SetSavedPosition(self)
            SetSavedPosition(toggleButton) -- Set toggle button's position
            self:SetPoint(unpack(GetSavedPosition(self)))
        elseif event == "ADDON_LOADED" then
            local addonName = ...
            if addonName == "Challenge-Mode_Helper" then
                -- Call the UpdateButtons function once after ADDON_LOADED event
                UpdateButtons()
            end
        end
    end)

    -- Call the UpdateButtons function once after ADDON_LOADED event
    frame:SetScript("OnLoad", function()
        UpdateButtons()
    end)
end

-- Call the initialization function
Init()

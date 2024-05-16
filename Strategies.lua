-- Saved variable to store strategies
local SavedStrategies = {}
local RemoveStrategyIcon = "Interface\\Buttons\\UI-GroupLoot-Pass-Down"
local EditButtonIcon = "Interface\\Buttons\\UI-LinkProfession-Up"

-- Function to save strategies
local function SaveStrategies()
    CmHelperDB.Strategies = SavedStrategies
end

-- Function to load strategies
local function LoadStrategies()
    SavedStrategies = CmHelperDB.Strategies or {}
    -- Ensure SavedStrategies is initialized as an empty table if it's nil
    if not next(SavedStrategies) then
        SavedStrategies = {}
    end
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
            showAlert = true
        }
        StaticPopup_Show("CONFIRM_REMOVE_STRATEGY")
    end)

    return removeButton
end

-- Function to create the "Edit Strategy" button
local function CreateEditButton(parent, scenarioName, strategyIndex)
    local editButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    editButton:SetNormalTexture(EditButtonIcon)
    editButton:SetSize(15, 15)
    editButton:SetPoint("RIGHT", 30, 0)

    editButton:SetScript("OnClick", function()
        -- Open a frame for editing the strategy
        OpenEditStrategyFrame(scenarioName, strategyIndex)
    end)

    return editButton
end

-- Function to open the frame for editing a strategy
function OpenEditStrategyFrame(scenarioName, strategyIndex)
    local editStrategyFrame = CreateFrame("Frame", "EditStrategyFrame", UIParent)
    editStrategyFrame:SetSize(400, 300) -- Set an initial size for the frame
    editStrategyFrame:SetPoint("CENTER")
    editStrategyFrame:SetBackdrop({
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
    editStrategyFrame:SetBackdropColor(0, 0, 0, 1) -- Set background color
    editStrategyFrame:SetMovable(true)
    editStrategyFrame:RegisterForDrag("LeftButton")
    editStrategyFrame:EnableMouse(true)
    editStrategyFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    editStrategyFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    -- Enable resizing
    editStrategyFrame:SetResizable(true)
    editStrategyFrame:SetMinResize(400, 200) -- Set minimum size for the frame
    editStrategyFrame:SetMaxResize(400, 800) -- Set minimum size for the frame

    -- Create ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", "EditStrategyScrollFrame", editStrategyFrame,
        "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

    -- Create EditBox to edit the strategy
    local editBox = CreateFrame("EditBox", "EditStrategyEditBox", scrollFrame)
    editBox:SetSize(380, 260) -- Set an initial size for the edit box
    editBox:SetPoint("TOPLEFT", 10, -30)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(true) -- Set auto-focus to true
    editBox:SetFontObject(GameFontHighlight)
    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    scrollFrame:SetScrollChild(editBox)

    -- Resize handle (unchanged from previous code)
    local resizeButton = CreateFrame("Button", nil, editStrategyFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", -6, 6)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            editStrategyFrame:StartSizing("BOTTOMRIGHT")
            self:GetHighlightTexture():Hide()
        end
    end)
    resizeButton:SetScript("OnMouseUp", function(self, button)
        editStrategyFrame:StopMovingOrSizing()
        self:GetHighlightTexture():Show()
    end)

    -- Confirm Button (unchanged from previous code)
    local confirmButton = CreateFrame("Button", nil, editStrategyFrame, "UIPanelButtonTemplate")
    confirmButton:SetText("Confirm")
    confirmButton:SetSize(80, 25)
    confirmButton:SetPoint("BOTTOMLEFT", 20, 20)
    confirmButton:SetScript("OnClick", function()
        local editedStrategy = editBox:GetText()
        SavedStrategies[scenarioName][strategyIndex] = editedStrategy
        editStrategyFrame:Hide()
    end)

    -- Cancel Button (unchanged from previous code)
    local cancelButton = CreateFrame("Button", nil, editStrategyFrame, "UIPanelButtonTemplate")
    cancelButton:SetText("Cancel")
    cancelButton:SetSize(80, 25)
    cancelButton:SetPoint("BOTTOMRIGHT", -20, 20)
    cancelButton:SetScript("OnClick", function()
        editStrategyFrame:Hide()
    end)

    -- Populate the edit box with the current strategy text
    editBox:SetText(SavedStrategies[scenarioName][strategyIndex])

    -- Show the frame
    editStrategyFrame:Show()
end

local function CreateButton(scenarioName, strategyIndex, buttonIndex)
    local button = CreateFrame("Button", nil, MyChallengeAddonFrame, "UIPanelButtonTemplate")
    button:SetText("Strategy " .. buttonIndex)
    button:SetSize(80, 25)
    button:SetPoint("TOPLEFT", 20, -buttonIndex * 30) -- Adjust the position as per your requirement

    -- OnClick handler
    button:SetScript("OnClick", function()
        local strategy = SavedStrategies[scenarioName][strategyIndex]
        if strategy then
            -- Split the multiline strategy into separate lines
            local lines = {strsplit("\n", strategy)}
            -- Send each line separately
            for _, line in ipairs(lines) do
                -- Split the line into chunks of 255 characters or less
                local chunks = {}
                local chunkStart = 1
                while chunkStart <= #line do
                    local chunkEnd = math.min(chunkStart + 254, #line) -- Ensure chunk doesn't exceed 255 characters
                    local chunk = string.sub(line, chunkStart, chunkEnd)
                    table.insert(chunks, chunk)
                    chunkStart = chunkEnd + 1
                end

                -- Send each chunk separately
                for _, chunk in ipairs(chunks) do
                    SendChatMessage(chunk, "SAY")
                end
            end
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
    local editButton = CreateEditButton(button, scenarioName, strategyIndex)
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

            -- Enable frame for movement
            frame:RegisterForDrag("LeftButton")
            frame:SetMovable(true)
            frame:EnableMouse(true)
            frame:SetScript("OnDragStart", function(self)
                self:StartMoving()
            end)
            frame:SetScript("OnDragStop", function(self)
                self:StopMovingOrSizing()
            end)

            -- Clear existing buttons
            ClearAllChildFrames(frame)

            -- Create buttons for each strategy
            for i, strategy in ipairs(strategies) do
                CreateButton(scenarioName, i, i)
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
    local newStrategyFrame = CreateFrame("Frame", "NewStrategyFrame", UIParent)
    newStrategyFrame:SetSize(400, 300) -- Set an initial size for the frame
    newStrategyFrame:SetPoint("CENTER")
    newStrategyFrame:SetBackdrop({
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
    newStrategyFrame:SetBackdropColor(0, 0, 0, 1) -- Set background color
    newStrategyFrame:SetMovable(true)
    newStrategyFrame:RegisterForDrag("LeftButton")
    newStrategyFrame:EnableMouse(true)
    newStrategyFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    newStrategyFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    newStrategyFrame:SetResizable(true)
    newStrategyFrame:SetMinResize(400, 200) -- Set minimum size for the frame
    newStrategyFrame:SetMaxResize(400, 800) -- Set minimum size for the frame

    -- Create ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", "NewStrategyScrollFrame", newStrategyFrame,
        "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

    -- Create EditBox inside ScrollFrame
    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetSize(380, 260) -- Set an initial size for the edit box
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(true) -- Set auto-focus to true
    editBox:SetFontObject(GameFontHighlight)
    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    scrollFrame:SetScrollChild(editBox)

    -- Resize handle (unchanged from previous code)
    local resizeButton = CreateFrame("Button", nil, newStrategyFrame)
    resizeButton:SetSize(16, 16)
    resizeButton:SetPoint("BOTTOMRIGHT", -6, 6)
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeButton:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            newStrategyFrame:StartSizing("BOTTOMRIGHT")
            self:GetHighlightTexture():Hide()
        end
    end)
    resizeButton:SetScript("OnMouseUp", function(self, button)
        newStrategyFrame:StopMovingOrSizing()
        self:GetHighlightTexture():Show()
    end)

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
            -- if IsAddNewButtonVisible then
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
    frame:SetPoint("CENTER")  -- Set initial position to the center of the screen
    frame:SetSize(200, 200)   -- Set initial size for the frame
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("PLAYER_LOGOUT") -- Register logout event
    frame:RegisterEvent("ADDON_LOADED")
    frame:RegisterEvent("PLAYER_LOGIN") -- Register login event
    -- Make the frame movable
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
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
            self:Hide()
        elseif event == "PLAYER_LOGIN" then
            -- Load saved strategies on login
            LoadStrategies()
            -- Update UI to reflect loaded strategies
            UpdateButtons()
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

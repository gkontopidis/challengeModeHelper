-- Saved variable to store strategies
local SavedStrategies = {}
local RemoveStrategyIcon = "Interface\\Buttons\\UI-GroupLoot-Pass-Down"
local EditButtonIcon = "Interface\\Buttons\\UI-LinkProfession-Up"

-- Function to load strategies
local function LoadStrategies()
    SavedStrategies = CmHelperDB.Strategies or {}
    -- Ensure SavedStrategies is initialized as an empty table if it's nil
    if not next(SavedStrategies) then
        SavedStrategies = {}
    end
end

-- Function to save strategies
local function SaveStrategies()
    CmHelperDB.Strategies = SavedStrategies
end

-- Function to destroy all child frames of a parent frame
local function ClearAllChildFrames(parentFrame)
    local children = {parentFrame:GetChildren()}
    for _, child in ipairs(children) do
        child:Hide() -- Hide the child frame
        child:SetParent(nil) -- Remove its parent reference
    end
end

-- Function to handle removing a strategy and its associated button
local function RemoveStrategy(scenarioName, buttonName)
    if SavedStrategies[scenarioName] then
        SavedStrategies[scenarioName][buttonName] = nil
        -- After removing the strategy, update the buttons
        UpdateButtons()
    end
end

-- Function to create the "Remove Strategy" button
local function CreateRemoveButton(parent, scenarioName, buttonName)
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
                RemoveStrategy(scenarioName, buttonName)
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

-- Function to get the number of strategies for a scenario
local function GetNumStrategies(scenarioName)
    local numStrategies = 0
    if SavedStrategies[scenarioName] then
        for _ in pairs(SavedStrategies[scenarioName]) do
            numStrategies = numStrategies + 1
        end
    end
    return numStrategies
end

-- Function to create the strategy button
local function CreateButton(scenarioName, buttonName, index)
    local button = CreateFrame("Button", nil, MyChallengeAddonFrame, "UIPanelButtonTemplate")
    button:SetText(buttonName)
    button:SetSize(120, 25)
    button:SetPoint("TOPLEFT", 10, -index * 30)
    -- OnClick handler
    button:SetScript("OnMouseDown", function(self, clickType)
        if clickType == "RightButton" then
            CreateNewStrategyFrame(buttonName, scenarioName)
        else
            local strategy = SavedStrategies[scenarioName][buttonName]
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
                        SendChatMessage(chunk, "PARTY")
                    end
                end
            end
        end
    end)

    -- OnEnter handler
    button:SetScript("OnEnter", function(self)
        local strategy = SavedStrategies[scenarioName][buttonName]
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
    local removeButton = CreateRemoveButton(button, scenarioName, buttonName)
    local editButton = CreateEditButton(button, scenarioName, buttonName)
end

-- Function to update frame size dynamically based on the number of strategies
local function UpdateFrameSize(numButtons)
    local buttonHeight = 30 -- Height of each button
    local verticalSpacing = 5 -- Vertical spacing between buttons
    local frameHeight = (buttonHeight + verticalSpacing) * numButtons -- Calculate total height needed
    MyChallengeAddonFrame:SetHeight(frameHeight) -- Set the frame height
end

-- Function to update buttons after adding a new strategy
function UpdateButtons()
    local frame = MyChallengeAddonFrame
    local buttonHeight = 30 -- Height of each button
    local verticalSpacing = 5 -- Vertical spacing between buttons
    local strategies
    frame:Hide()
    local scenarioName, _, _, difficultyName = GetInstanceInfo()
    if difficultyName == "Challenge Mode" then
        strategies = SavedStrategies[scenarioName]
        if strategies then
            -- Clear existing buttons
            ClearAllChildFrames(frame)

            local index = 1
            for buttonName, strategy in pairs(strategies) do
                CreateButton(scenarioName, buttonName, index)
                index = index + 1
            end
            -- Update frame size based on the number of strategies

            local frameHeight = ((index - 1) * (buttonHeight + verticalSpacing)) + 20 -- Add 20 for additional space
            frame:SetSize(180, frameHeight) -- Adjust size based on the number of strategies
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
            frame:Show() -- Show the frame again after updating buttons
        else
            ClearAllChildFrames(frame)
        end

        frame:Hide()
    else
        frame:Hide()
    end
end

-- Function to handle adding a new strategy
local function AddNewStrategy(scenarioName, buttonName, newStrategy)
    if SavedStrategies[scenarioName] == nil then
        SavedStrategies[scenarioName] = {}
    end
    -- Check if the button name already exists and increment a counter if it does
    local counter = 1
    local formattedButtonName = buttonName
    while SavedStrategies[scenarioName][formattedButtonName] do
        counter = counter + 1
        formattedButtonName = buttonName .. counter
    end
    -- Store the strategy with the formatted button name
    SavedStrategies[scenarioName][formattedButtonName] = newStrategy
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

function CreateNewStrategyFrame(defaultButtonName, scenarioName)
    local newStrategyFrame = CreateFrame("Frame", "NewStrategyFrame", UIParent)
    newStrategyFrame:SetSize(200, 100) -- Set an initial size for the frame
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

    -- Create instruction label
    local instructionLabel = newStrategyFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    instructionLabel:SetPoint("TOP", 0, -10)
    instructionLabel:SetText("Please enter button name:")

    -- Create EditBox for entering button name
    local buttonNameEditBox = CreateFrame("EditBox", nil, newStrategyFrame, "InputBoxTemplate")
    buttonNameEditBox:SetSize(160, 30)
    buttonNameEditBox:SetPoint("TOP", 0, -25)
    buttonNameEditBox:SetAutoFocus(true)
    buttonNameEditBox:SetMaxLetters(30) -- Set maximum characters for button name
    buttonNameEditBox:SetFontObject(GameFontHighlight)
    buttonNameEditBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        newStrategyFrame:Hide()
    end)

    -- If a default button name is provided, populate the edit box with it
    if defaultButtonName then
        buttonNameEditBox:SetText(defaultButtonName)
    end

    -- Create Confirm Button for button name
    local confirmButton = CreateFrame("Button", nil, newStrategyFrame, "UIPanelButtonTemplate")
    confirmButton:SetText("Confirm")
    confirmButton:SetSize(60, 30)
    confirmButton:SetPoint("TOPLEFT", 30, -60)
    confirmButton:SetScript("OnClick", function()
        local newButtonName = buttonNameEditBox:GetText()
        if newButtonName ~= "" then
            -- Once button name is confirmed, proceed to enter strategy
            newStrategyFrame:Hide()
            if defaultButtonName then
                if SavedStrategies[scenarioName] and SavedStrategies[scenarioName][defaultButtonName] then
                    SavedStrategies[scenarioName][newButtonName] = SavedStrategies[scenarioName][defaultButtonName]
                    SavedStrategies[scenarioName][defaultButtonName] = nil
                end
                UpdateButtons()
                MyChallengeAddonFrame:Show()
            else
                CreateStrategyInputFrame(newButtonName)
            end
        else
            print("Please enter a button name.")
        end
    end)

    -- Create Cancel Button for strategy
    local cancelButton = CreateFrame("Button", nil, newStrategyFrame, "UIPanelButtonTemplate")
    cancelButton:SetText("Cancel")
    cancelButton:SetSize(60, 30)
    cancelButton:SetPoint("TOPRIGHT", -30, -60)
    cancelButton:SetScript("OnClick", function()
        newStrategyFrame:Hide()
    end)

    newStrategyFrame:Show()
end

-- Function to handle adding a new strategy
local function AddNewStrategyConfirmation(buttonName, text)
    local scenarioName, _, _, difficultyName = GetInstanceInfo()
    if difficultyName == "Challenge Mode" then
        AddNewStrategy(scenarioName, buttonName, text)
        UpdateButtons() -- Update the UI to reflect the new strategy
        MyChallengeAddonFrame:Show()
    end
end

-- Function to create the multiline input frame for entering strategy
function CreateStrategyInputFrame(buttonName)
    local strategyInputFrame = CreateFrame("Frame", "StrategyInputFrame", UIParent)
    strategyInputFrame:SetSize(400, 300) -- Set an initial size for the frame
    strategyInputFrame:SetPoint("CENTER")
    strategyInputFrame:SetBackdrop({
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
    strategyInputFrame:SetBackdropColor(0, 0, 0, 1) -- Set background color
    strategyInputFrame:SetMovable(true)
    strategyInputFrame:RegisterForDrag("LeftButton")
    strategyInputFrame:EnableMouse(true)
    strategyInputFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    strategyInputFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    strategyInputFrame:SetResizable(true)
    strategyInputFrame:SetMinResize(400, 200) -- Set minimum size for the frame
    strategyInputFrame:SetMaxResize(400, 800) -- Set minimum size for the frame

    -- Create ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", "StrategyInputScrollFrame", strategyInputFrame,
        "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

    -- Create EditBox inside ScrollFrame for entering strategy
    local strategyEditBox = CreateFrame("EditBox", "StrategyEditBox", scrollFrame)
    strategyEditBox:SetSize(380, 260) -- Set an initial size for the edit box
    strategyEditBox:SetPoint("TOPLEFT", 10, -30)
    strategyEditBox:SetMultiLine(true)
    strategyEditBox:SetAutoFocus(true) -- Set auto-focus to true
    strategyEditBox:SetFontObject(GameFontHighlight)
    strategyEditBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    scrollFrame:SetScrollChild(strategyEditBox)

    -- Create Confirm Button for strategy
    local confirmButton = CreateFrame("Button", nil, strategyInputFrame, "UIPanelButtonTemplate")
    confirmButton:SetText("Confirm Strategy")
    confirmButton:SetSize(150, 30)
    confirmButton:SetPoint("BOTTOMLEFT", 30, 20)
    confirmButton:SetScript("OnClick", function()
        local newStrategy = strategyEditBox:GetText()
        if newStrategy ~= "" then
            AddNewStrategyConfirmation(buttonName, newStrategy)
            strategyInputFrame:Hide()
        else
            print("Please enter a strategy.")
        end
    end)

    -- Create Cancel Button for strategy
    local cancelButton = CreateFrame("Button", nil, strategyInputFrame, "UIPanelButtonTemplate")
    cancelButton:SetText("Cancel")
    cancelButton:SetSize(150, 30)
    cancelButton:SetPoint("BOTTOMRIGHT", -30, 20)
    cancelButton:SetScript("OnClick", function()
        strategyInputFrame:Hide()
    end)

    strategyInputFrame:Show()
end

-- Function to handle adding a new strategy
local function AddNewStrategyConfirmation(buttonName, text)
    local scenarioName, _, _, difficultyName = GetInstanceInfo()
    if difficultyName == "Challenge Mode" then
        AddNewStrategy(scenarioName, buttonName, text)
        UpdateButtons() -- Update the UI to reflect the new strategy
        MyChallengeAddonFrame:Show()
    end
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
    -- Set up backdrop for the frame
    -- frame:SetBackdrop({
    --     bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    --     edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    --     tile = true,
    --     tileSize = 16,
    --     edgeSize = 16,
    --     insets = {
    --         left = 4,
    --         right = 4,
    --         top = 4,
    --         bottom = 4
    --     }
    -- })

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    frame:SetPoint("CENTER") -- Set initial position to the center of the screen
    frame:SetSize(200, 200) -- Set initial size for the frame
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
                    UpdateButtons() -- Update the buttons when entering the world
                end
            else
                if _G["ToggleStrategiesButton"] then
                    _G["ToggleStrategiesButton"]:Hide()
                    _G["AddStrategyButton"]:Hide()
                end
                MyChallengeAddonFrame:Hide() -- Hide the frame when not in Challenge Mode
            end
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

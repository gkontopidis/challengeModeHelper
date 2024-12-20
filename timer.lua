-- Global variables to hold frame references and timer data
local labelFrame = nil
local hoverFrame = nil
local startTime = nil
local inChallengeMode = false
local resetButton = nil -- Variable to hold the reset button's reference
local isTimerActive = false
local realmBestLabel = nil -- Variable to hold the realm best time label reference
local bestClearLabel = nil -- Variable to hold the best clear time label reference
local line = nil
local lastTenSecondsTimer = nil
local C_Timer = C_Timer or nil
local soundPlayed = {}
local isFirstLoad = true -- Global variable to track whether it's the first time the addon loads
local yOfs -- = 0
local xOfs -- = 0
local point -- = "CENTER"
local relativePoint -- = "CENTER"
local colorPicked2 = "1" -- Variable to store the selected color option
local selectedCountDown = "realmBest"
local challengeName
local PortalButtonState = "NotPressed"
local opacitySliderFrame = nil -- Variable to keep track of the opacity slider frame
local legendToggleButton -- Define legendToggleButton before dropdown menu initialization
local ShowLegend -- = "False"
local Timer_frame_Scale
local AutoEquipXtremeBoots = false
local Swap_Trinkets = false
local bootItemID_cloth = 35581 -- Rocket Boots Item ID cloth version
local bootItemID_leather = 23824 -- Rocket Boots Item ID leather version
local ShowPortalsButton
local ShowReadyCheckVariable
local ShowMarkTankHealerVariable
local EnableCountdown

timeElapsed = 0

-- Function to create and show the opacity slider frame
local function ShowOpacitySliderFrame()
    -- Check if the frame is already shown
    if opacitySliderFrame and opacitySliderFrame:IsShown() then
        opacitySliderFrame:Hide() -- Hide the existing frame
    else
        -- Create the frame if it doesn't exist
        opacitySliderFrame = CreateFrame("Frame", "MoPCMHelper_OpacitySliderFrame", UIParent)
        opacitySliderFrame:SetSize(200, 90) -- Increased height to accommodate the label
        opacitySliderFrame:SetPoint("CENTER", 0, 0)
        opacitySliderFrame:SetBackdrop({
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
        opacitySliderFrame:SetBackdropColor(0, 0, 0, 1)

        -- Create slider and label
        local sliderLabel = opacitySliderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        sliderLabel:SetPoint("TOPLEFT", 10, -10)
        sliderLabel:SetText("Opacity:")

        local sliderValueLabel = opacitySliderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        sliderValueLabel:SetPoint("LEFT", sliderLabel, "RIGHT", 5, 0) -- Position below the slider label

        local slider = CreateFrame("Slider", "MoPCMHelper_OpacitySlider", opacitySliderFrame, "OptionsSliderTemplate")
        slider:SetWidth(180)
        slider:SetHeight(20)
        slider:SetPoint("TOPLEFT", 10, -30)
        slider:SetMinMaxValues(0, 100)
        slider:SetOrientation("HORIZONTAL")

        -- Load colorPicked2 value from CmHelperDB if available, otherwise use default value
        local initialColorPicked2 =
            (CmHelperDB and CmHelperDB.framePosition and CmHelperDB.framePosition.colorPicked2) or 1
        slider:SetValue(initialColorPicked2 * 100)
        sliderValueLabel:SetText(math.floor(initialColorPicked2 * 100))

        -- Update the OnValueChanged callback function to correctly update colorPicked2
        slider:SetScript("OnValueChanged", function(self, value)
            colorPicked2 = value / 100 -- Normalize value to range 0-1

            LabelFrame_Opacity(colorPicked2)
            SliderValue(value)
            -- labelFrame:SetBackdropColor(0, 0, 0, colorPicked2)
            sliderValueLabel:SetText(math.floor(colorPicked2 * 100)) -- Update the value label
        end)

        -- Create close button
        local closeButton = CreateFrame("Button", nil, slider, "UIPanelButtonTemplate")
        closeButton:SetText("Save")
        closeButton:SetSize(80, 20)
        closeButton:SetPoint("BOTTOM", 0, -30)
        closeButton:SetScript("OnClick", function()

            -- Save the slider value when closing the frame
            labelFrame:SavePosition()
            opacitySliderFrame:Hide() -- Hide the frame
        end)

        opacitySliderFrame:Show()
    end
end

local function AddSeparator(dropdownMenu, level)
    local info = UIDropDownMenu_CreateInfo()
    info.isTitle = true
    info.notCheckable = true
    info.text = "--------------------------"
    UIDropDownMenu_AddButton(info, level)
end

-- Function to create the addon frame
function CreateAddonFrame()
    -- Create a frame for the label
    labelFrame = CreateFrame("Frame", "MoPCMHelperLabelFrame", UIParent)
    labelFrame:SetSize(270, 100) -- Set the size of the label frame

    -- Set up backdrop for the frame
    labelFrame:SetBackdrop({
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

    function ResetLabelFramePosition()
        if labelFrame then
            labelFrame.isLocked = false
            labelFrame:ClearAllPoints() -- Clear previous position
            labelFrame:SetPoint("CENTER", UIParent, "CENTER") -- Move to the center of the screen
        end
    end

    -- Create the hover frame
    hoverFrame = CreateFrame("Frame", "MoPCMHelperHoverFrame", UIParent)
    frameHeight = getAvailableTeleportButtons()
    hoverFrame:SetSize(55, #frameHeight * 44)
    hoverFrame:SetPoint("TOP", labelFrame, "RIGHT", 22, 44) -- Adjust position as needed
    hoverFrame:SetBackdrop({
        -- bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        -- edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
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
    hoverFrame:Hide() -- Hide the hover frame initially

    local function CreateButton(parent, index, portalName, iconPath, spellID)
        button = CreateFrame("Button", "MoPCMHelperHoverButton" .. index, parent, "SecureActionButtonTemplate")
        button:SetSize(40, 40) -- Set the size of each button
        button:SetPoint("TOP", parent, "TOP", 0, -((index - 1) * 40)) -- Position each button vertically

        -- Set the button's attributes for spell casting
        button:SetAttribute("type", "spell")
        button:SetAttribute("spell", GetSpellInfo(spellID))

        -- Set the button's icon
        local iconTexture = button:CreateTexture(nil, "ARTWORK")
        iconTexture:SetAllPoints()
        iconTexture:SetTexture(iconPath)

        -- Add tooltip functionality
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(portalName) -- Set tooltip text
            GameTooltip:Show()
        end)

        button:SetScript("OnLeave", function(self)
            GameTooltip:Hide() -- Hide tooltip when mouse leaves the button
        end)

        -- Function to update cooldown text
        local function UpdateCooldownText()
            local start, duration, enable = GetSpellCooldown(portalName)
            local remainingTime = start + duration - GetTime()

            if remainingTime > 0 then
                -- If the remaining time is greater than 0, the spell is on cooldown
                iconTexture:SetDesaturated(true)
                button:Disable()
            else
                -- If the remaining time is 0 or less, the spell is off cooldown
                iconTexture:SetDesaturated(false) -- Enable the button by restoring saturation
                button:Enable()
            end
        end

        -- Register for events to update the cooldown text
        button:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        button:SetScript("OnEvent", function(self, event, ...)
            UpdateCooldownText()
        end)

        -- Update cooldown text initially
        UpdateCooldownText()

        return button
    end

    local availablePortals = getAvailableTeleportButtons()
    for index, portalInfo in ipairs(availablePortals) do
        CreateButton(hoverFrame, index, portalInfo.name, portalInfo.iconPath, portalInfo.id) -- Create and store each button
    end

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
    minutesLabel:SetPoint("LEFT", 80, -10)
    secondsLabel:SetPoint("LEFT", minutesLabel, "RIGHT", 0, 0)
    millisecondsLabel:SetPoint("LEFT", secondsLabel, "RIGHT", 0, -1) -- Adjusted the Y offset here

    -- Update the text color for minutes and seconds
    minutesLabel:SetTextColor(1, 0.84, 0) -- Gold color
    secondsLabel:SetTextColor(1, 0.84, 0) -- Gold color
    millisecondsLabel:SetTextColor(1, 1, 1) -- White color

    -- Create a new font string for the realm best time label
    realmBestLabel = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local realmBestTime = GetChallengeModeRealmOrGuildBestTime()
    local textToDisplay = ""
    if (selectedCountDown == "realmBest") then
        textToDisplay = "Realm Best:"
    elseif (selectedCountDown == "guildBest") then
        textToDisplay = "Guild Best:"
    end

    realmBestLabel:SetText(textToDisplay .. realmBestTime)

    -- Position the realm best time label
    realmBestLabel:SetPoint("LEFT", labelFrame, "LEFT", 80, 30) -- Adjust the offset as needed

    -- Create a new font string for the best clear time label
    bestClearLabel = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    local remainingTime = GetRemainingTimeToBeatCounter()
    bestClearLabel:SetText("Time remaining: " .. remainingTime)
    -- Set up a timer to call UpdateTime every second
    labelFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 1 then
            UpdateTimer(minutesLabel, secondsLabel, millisecondsLabel)
            self.elapsed = 0
        end
    end)

    PortalButton = CreateFrame("Button", nil, labelFrame, "UIPanelButtonTemplate")
    PortalButton:SetSize(20, 20)
    PortalButton:SetPoint("LEFT", minutesLabel, "RIGHT", 120, -1) -- Adjust the position as needed
    PortalButton:SetNormalTexture("Interface\\Icons\\misc_arrowright")

    PortalButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Dungeon Portals")
        GameTooltip:Show()
    end)

    PortalButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Position the best clear time label below the realm best time label
    bestClearLabel:SetPoint("LEFT", labelFrame, "LEFT", 80, 10) -- Adjust the offset as needed

    -- Create icon and text
    local goldicon = labelFrame:CreateTexture(nil, "OVERLAY")
    goldicon:SetTexture("Interface\\Icons\\achievement_challengemode_gold")
    goldicon:SetSize(16, 16)
    goldicon:SetPoint("LEFT", labelFrame, "BOTTOM", -135, -12)

    local goldText = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    goldText:SetPoint("LEFT", goldicon, "RIGHT", 10, 0)

    local silverIcon = labelFrame:CreateTexture(nil, "OVERLAY")
    silverIcon:SetTexture("Interface\\Icons\\achievement_challengemode_silver")
    silverIcon:SetSize(16, 16)
    silverIcon:SetPoint("LEFT", goldText, "RIGHT", 20, 0)

    local silverText = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    silverText:SetPoint("LEFT", silverIcon, "RIGHT", 10, 0)

    local bronzeIcon = labelFrame:CreateTexture(nil, "OVERLAY")
    bronzeIcon:SetTexture("Interface\\Icons\\achievement_challengemode_bronze")
    bronzeIcon:SetSize(16, 16)
    bronzeIcon:SetPoint("LEFT", silverText, "RIGHT", 20, 0)

    local bronzeText = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bronzeText:SetPoint("LEFT", bronzeIcon, "RIGHT", 10, 0)

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

    -- Create a button
    local button = CreateFrame("Button", nil, labelFrame, "UIPanelButtonTemplate")
    button:SetText("RESET")
    button:SetSize(60, 60)
    button:SetPoint("LEFT", 10, 10) -- Adjust the position as needed

    -- Set the button's icon texture
    button:SetNormalTexture("Interface\\Icons\\SPELL_HOLY_BORROWEDTIME")

    -- Set the text label's position
    button:GetFontString():SetPoint("BOTTOM", 0, 5) -- Adjust the position as needed

    -- Set the text label's font properties
    button:GetFontString():SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE") -- Adjust font, size, and style
    button:GetFontString():SetTextColor(1, 1, 1) -- Set text color to white

    -- Function to create the glow effect
    local function CreateGlow()
        -- Create a glow texture
        button.glow = button:CreateTexture(nil, "BACKGROUND")
        button.glow:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        button.glow:SetBlendMode("ADD")
        button.glow:SetAllPoints(button)
        button.glow:SetAlpha(0.7) -- Adjust the alpha to make the glow more visible
        button.glow:Hide() -- Initially hide the glow
    end

    -- Set the button's OnEnter handler to show the glow effect
    button:SetScript("OnEnter", function()
        if not button.glow then
            CreateGlow()
        end
        button.glow:Show()
    end)

    -- Set the button's OnLeave handler to hide the glow effect
    button:SetScript("OnLeave", function()
        if button.glow then
            button.glow:Hide()
        end
    end)

    -- Set the button's OnClick handler to run the script
    button:SetScript("OnClick", function()
        RunScript("ResetChallengeMode()")
        -- DoReadyCheck()
    end)

    -- Create a new font string for the realm best time label
    Boots_Info_Label = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    Boots_Info_Label:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE") -- Set font path, size, and outline (optional)
    Boots_Info_Label:SetText("Xtreme Boots")

    -- Function to update label color based on AutoEquipXtremeBoots state
    local function UpdateBootsInfoLabelColor()
        if AutoEquipXtremeBoots then
            Boots_Info_Label:SetTextColor(0, 1, 0) -- Green color (RGB: 0, 1, 0)
        else
            Boots_Info_Label:SetTextColor(1, 0, 0) -- Red color (RGB: 1, 0, 0)
        end
    end

    -- Call the function initially to set the color on load
    UpdateBootsInfoLabelColor()

    -- Position the realm best time label
    Boots_Info_Label:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -5) -- Adjust the offset as needed

    function ToggleXtremeBootsState_Color()
        AutoEquipXtremeBoots = not AutoEquipXtremeBoots
        UpdateBootsInfoLabelColor() -- Update label color
    end

    Slash_Label = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    Slash_Label:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE") -- Set font path, size, and outline (optional)
    Slash_Label:SetText("/")
    Slash_Label:SetPoint("LEFT", Boots_Info_Label, "RIGHT", 0, 0) -- Position Slash_Label to the right with a small offset

    -- Create the "Trinket" label and position it to the right of Slash_Label
    Trinket_Label = labelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    Trinket_Label:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE") -- Set font path, size, and outline (optional)
    Trinket_Label:SetText("Trinket")
    Trinket_Label:SetPoint("LEFT", Slash_Label, "RIGHT", 0, 0) -- Position Trinket_Label to the right of Slash_Label with a small offset

    Ready_Check_Button = CreateFrame("Button", "MyWowButton", labelFrame, "UIPanelButtonTemplate")
    Ready_Check_Button:SetSize(20, 20)
    Ready_Check_Button:SetPoint("LEFT", minutesLabel, "RIGHT", 120, -1)
    Ready_Check_Button:SetNormalTexture("Interface\\CURSOR\\thumbsup")

    Ready_Check_Button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Ready Check")
        GameTooltip:Show()
    end)

    Ready_Check_Button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Function to perform a ready check when the button is clicked
    Ready_Check_Button:SetScript("OnClick", function()
        DoReadyCheck()
    end)

    -- Create a frame for the button
    Role_Marks_Button = CreateFrame("Button", "MyMarkButton", labelFrame, "UIPanelButtonTemplate")
    Role_Marks_Button:SetSize(20, 20)
    Role_Marks_Button:SetPoint("LEFT", Ready_Check_Button, "RIGHT", -60, 0)
    Role_Marks_Button:SetNormalTexture("Interface\\CURSOR\\Crosshairs")

    Role_Marks_Button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Mark Tank/Healer")
        GameTooltip:Show()
    end)

    Role_Marks_Button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    function ClearAllRaidMarks()
        for raidIndex = 1, GetNumGroupMembers() do
            local name, _, _, _, _, _, _, online, isDead, role, _, _ = GetRaidRosterInfo(raidIndex)
            if name then
                SetRaidTarget(name, 0) -- Clear raid mark
            end
        end
    end

    -- Function to mark players with raid marks based on their combat role
    function MarkPlayersWithRaidMarks()
        ClearAllRaidMarks() -- Clear existing raid marks
        for raidIndex = 1, GetNumGroupMembers() do
            local name, _, _, _, _, _, _, online, isDead, role, _, combatRole = GetRaidRosterInfo(raidIndex)
            if combatRole then
                if combatRole == "TANK" then
                    SetRaidTarget(name, 2) -- Apply nipple mark
                elseif combatRole == "HEALER" then
                    SetRaidTarget(name, 4) -- Apply triangle mark
                end
            end
        end
    end

    -- Variable to track the state of marks (true: marks shown, false: marks hidden)
    local marksShown = false

    -- Function to toggle between showing and hiding marks
    function ToggleMarkState()
        if marksShown then
            ClearAllRaidMarks() -- Clear marks
            marksShown = false
            Role_Marks_Button:SetNormalTexture("Interface\\CURSOR\\Crosshairs")
        else
            MarkPlayersWithRaidMarks() -- Mark players
            marksShown = true
            Role_Marks_Button:SetNormalTexture("Interface\\CURSOR\\UnableCrosshairs")
        end
    end

    -- Register the click event for the button
    Role_Marks_Button:SetScript("OnClick", ToggleMarkState)

    swapButton = CreateFrame("Button", "MyMarkButton", labelFrame, "UIPanelButtonTemplate")
    swapButton:SetSize(24, 24)
    swapButton:SetPoint("CENTER")
    swapButton:SetPoint("LEFT", Ready_Check_Button, "RIGHT", -20, -22)

    swapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Auto Swap Trinkets at 2 seconds")
        GameTooltip:Show()
    end)

    swapButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Variables to track trinket IDs and equip state
    local trinket1ID, trinket2ID
    local trinketsInBags = false

    -- Function to handle swapping the trinkets
    function swapTrinkets()
        local trinket1Slot = 13 -- Trinket 1 slot
        local trinket2Slot = 14 -- Trinket 2 slot

        -- Get the item IDs for the current trinkets
        trinket1ID = GetInventoryItemID("player", trinket1Slot)
        trinket2ID = GetInventoryItemID("player", trinket2Slot)

        -- Check if both trinkets are equipped
        if trinket1ID and trinket2ID then

            -- Step 1: Remove Trinket 1 and place it into the backpack
            PickupInventoryItem(trinket1Slot)
            PutItemInBackpack()

            -- Step 2: Remove Trinket 2 and place it into the backpack
            PickupInventoryItem(trinket2Slot)
            PutItemInBackpack()

            -- Set flag to indicate trinkets should be equipped in swapped slots
            trinketsInBags = true
        else
            print("|cffff0000One or both trinkets are not equipped!")
        end
    end

    -- Event handler for BAG_UPDATE_DELAYED
    local function OnBagUpdateDelayed()
        if trinketsInBags then
            -- Track whether each trinket has been successfully equipped
            local trinket1Equipped = false
            local trinket2Equipped = false

            -- Attempt to equip Trinket 1 into Trinket 1's slot
            for bag = 0, NUM_BAG_SLOTS do
                for slot = 1, GetContainerNumSlots(bag) do
                    local itemID = GetContainerItemID(bag, slot)
                    if itemID == trinket1ID then
                        UseContainerItem(bag, slot) -- Equip Trinket 2
                        trinket1Equipped = true
                        break
                    end
                end
                if trinket1Equipped then
                    break
                end
            end

            -- Attempt to equip Trinket 2 into Trinket 2's slot
            for bag = 0, NUM_BAG_SLOTS do
                for slot = 1, GetContainerNumSlots(bag) do
                    local itemID = GetContainerItemID(bag, slot)
                    if itemID == trinket2ID then
                        UseContainerItem(bag, slot) -- Equip Trinket 1
                        trinket2Equipped = true
                        break
                    end
                end
                if trinket2Equipped then
                    break
                end
            end

            -- Check if both trinkets have been equipped
            if trinket1Equipped and trinket2Equipped then
                trinketsInBags = false -- Stop further checks
                print("|cff00ff00Trinkets have been successfully swapped and equipped!") -- Green color for success
            else
                -- If either trinket is still in the bag, the function will try again on the next BAG_UPDATE_DELAYED event
                print("|cffff0000Retrying trinket equip on next BAG_UPDATE_DELAYED event.") -- Red color for retry message
            end
        end
    end

    -- Register the BAG_UPDATE_DELAYED event
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
    eventFrame:SetScript("OnEvent", OnBagUpdateDelayed)

    -- Function to update the label color based on Swap_Trinkets value
    local function updateLabelColor()
        if Swap_Trinkets then
            Trinket_Label:SetTextColor(0, 1, 0) -- Green color
            swapButton:SetNormalTexture("Interface\\Scenarios\\ScenarioIcon-Check")
        else
            Trinket_Label:SetTextColor(1, 0, 0) -- Red color
            swapButton:SetNormalTexture("Interface\\Scenarios\\ScenarioIcon-Fail")
        end

    end

    -- Set up the button's OnClick script
    swapButton:SetScript("OnClick", function()
        Swap_Trinkets = not Swap_Trinkets -- Toggle the variable
        -- print("Swap_Trinkets is now:", Swap_Trinkets) -- Print the new value for debugging
        updateLabelColor() -- Update the label color based on the new value
    end)

    -- Initial label color setup
    updateLabelColor() -- Set initial color based on the initial value of Swap_Trinkets

    Xtreme_Boots_Button = CreateFrame("Button", "MyMarkButton", labelFrame, "UIPanelButtonTemplate")
    Xtreme_Boots_Button:SetSize(20, 20)
    Xtreme_Boots_Button:SetPoint("LEFT", Ready_Check_Button, "RIGHT", -60, -22)
    -- Xtreme_Boots_Button:SetNormalTexture("Interface\\Icons\\INV_Gizmo_RocketBoot_01")
    if AutoEquipXtremeBoots == false then
        Xtreme_Boots_Button:SetNormalTexture("Interface\\Icons\\INV_Gizmo_RocketBoot_Destroyed_02")
    else
        Xtreme_Boots_Button:SetNormalTexture("Interface\\Icons\\INV_Gizmo_RocketBoot_01")
    end

    Xtreme_Boots_Button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Auto equip Xtreme Boots")
        GameTooltip:Show()
    end)

    Xtreme_Boots_Button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Function to Equip Rocket Boots if in Challenge Mode and auto-equip is enabled
    local function EquipRocketBoots()
        if not AutoEquipXtremeBoots then
            Boots_Info_Label:SetTextColor(1, 0, 0) -- Red color (RGB: 1, 0, 0)
            return
        end
        if IsInInstance() then
            local scenarioName, _, _, difficultyName = GetInstanceInfo()
            if difficultyName == "Challenge Mode" then
                Boots_Info_Label:SetTextColor(0, 1, 0) -- Green color (RGB: 0, 1, 0)
                for bag = 0, NUM_BAG_SLOTS do
                    for slot = 1, GetContainerNumSlots(bag) do
                        local itemID = GetContainerItemID(bag, slot)
                        if itemID == bootItemID_cloth or itemID == bootItemID_leather then
                            UseContainerItem(bag, slot)
                            print("|cff00ccffRocket Boots Xtreme equipped!!!")
                            return
                        end
                    end
                end
            end
        end
    end

    -- Function to Enable_EquipRocketBoots
    function Enable_EquipRocketBoots_Function()
        -- print("|cff00ff00Rocket Boots Xtreme autoequip ENABLED!")
        EquipRocketBoots()
    end

    -- Function to Disable_EquipRocketBoots
    function Disable_EquipRocketBoots_Function()
        -- print("|cffff0000Rocket Boots Xtreme autoequip DISABLED!")
        EquipRocketBoots()
    end

    -- Toggle function for auto-equip state
    local function ToggleXtremeBootsState()
        if AutoEquipXtremeBoots then
            AutoEquipXtremeBoots = false
            Disable_EquipRocketBoots_Function()
            Xtreme_Boots_Button:SetNormalTexture("Interface\\Icons\\INV_Gizmo_RocketBoot_Destroyed_02")
            -- labelFrame:SavePosition()
        else
            AutoEquipXtremeBoots = true
            Enable_EquipRocketBoots_Function()
            Xtreme_Boots_Button:SetNormalTexture("Interface\\Icons\\INV_Gizmo_RocketBoot_01")
            -- labelFrame:SavePosition()
        end
    end

    -- Register the click event for the button
    Xtreme_Boots_Button:SetScript("OnClick", ToggleXtremeBootsState)

    -- Function to update the button state
    function UpdateButtonState()
        if IsInGroup() and UnitIsGroupLeader("player") then

            labelFrame:SetSize(270, 100) -- Set the size of the label frame

            button:Show() -- Show the button if the player is the group leader

            -- Position the realm best time label
            realmBestLabel:SetPoint("LEFT", labelFrame, "LEFT", 80, 30) -- Adjust the offset as needed
            PortalButton:SetPoint("LEFT", minutesLabel, "RIGHT", 120, 41) -- Adjust the position as needed
            -- Position the font strings within the label frame
            minutesLabel:SetPoint("LEFT", 80, -10)
            secondsLabel:SetPoint("LEFT", minutesLabel, "RIGHT", 0, 0)
            millisecondsLabel:SetPoint("LEFT", secondsLabel, "RIGHT", 0, -1) -- Adjusted the Y offset here
            -- Position the best clear time label below the realm best time label
            bestClearLabel:SetPoint("LEFT", labelFrame, "LEFT", 80, 10) -- Adjust the offset as needed

            goldicon:SetPoint("LEFT", labelFrame, "BOTTOM", -135, -12)
            goldText:SetPoint("LEFT", goldicon, "RIGHT", 10, 0)
            silverIcon:SetPoint("LEFT", goldText, "RIGHT", 20, 0)
            silverText:SetPoint("LEFT", silverIcon, "RIGHT", 10, 0)
            bronzeIcon:SetPoint("LEFT", silverText, "RIGHT", 20, 0)
            bronzeText:SetPoint("LEFT", bronzeIcon, "RIGHT", 10, 0)

            goldText:SetFontObject("GameFontNormalLarge")
            silverText:SetFontObject("GameFontNormalLarge")
            bronzeText:SetFontObject("GameFontNormalLarge")

            swapButton:SetPoint("LEFT", Ready_Check_Button, "RIGHT", -20, -22)
            Xtreme_Boots_Button:SetPoint("LEFT", Ready_Check_Button, "RIGHT", -60, -22)
        elseif not IsInGroup() then

            labelFrame:SetSize(270, 100) -- Set the size of the label frame

            button:Show() -- Show the button if the player is alone
            Ready_Check_Button:Hide()
            Role_Marks_Button:Hide()

            -- Position the realm best time label
            realmBestLabel:SetPoint("LEFT", labelFrame, "LEFT", 80, 30) -- Adjust the offset as needed
            PortalButton:SetPoint("LEFT", minutesLabel, "RIGHT", 120, 41) -- Adjust the position as needed
            -- Position the font strings within the label frame
            minutesLabel:SetPoint("LEFT", 80, -10)
            secondsLabel:SetPoint("LEFT", minutesLabel, "RIGHT", 0, 0)
            millisecondsLabel:SetPoint("LEFT", secondsLabel, "RIGHT", 0, -1) -- Adjusted the Y offset here
            -- Position the best clear time label below the realm best time label
            bestClearLabel:SetPoint("LEFT", labelFrame, "LEFT", 80, 10) -- Adjust the offset as needed

            goldicon:SetPoint("LEFT", labelFrame, "BOTTOM", -135, -12)
            goldText:SetPoint("LEFT", goldicon, "RIGHT", 10, 0)
            silverIcon:SetPoint("LEFT", goldText, "RIGHT", 20, 0)
            silverText:SetPoint("LEFT", silverIcon, "RIGHT", 10, 0)
            bronzeIcon:SetPoint("LEFT", silverText, "RIGHT", 20, 0)
            bronzeText:SetPoint("LEFT", bronzeIcon, "RIGHT", 10, 0)

            goldText:SetFontObject("GameFontNormalLarge")
            silverText:SetFontObject("GameFontNormalLarge")
            bronzeText:SetFontObject("GameFontNormalLarge")

            swapButton:SetPoint("LEFT", Ready_Check_Button, "RIGHT", -20, -22)
            Xtreme_Boots_Button:SetPoint("LEFT", Ready_Check_Button, "RIGHT", -60, -22)
        else

            button:Hide() -- Hide the button if the player is in a group but not the leader
            Ready_Check_Button:Hide()
            Role_Marks_Button:Hide()

            labelFrame:SetSize(200, 100) -- Set the size of the label frame
            -- Position the realm best time label
            realmBestLabel:SetPoint("LEFT", labelFrame, "LEFT", 10, 30) -- Adjust the offset as needed
            PortalButton:SetPoint("LEFT", minutesLabel, "RIGHT", 120, 41) -- Adjust the position as needed
            -- Position the font strings within the label frame
            minutesLabel:SetPoint("LEFT", 10, -10)
            secondsLabel:SetPoint("LEFT", minutesLabel, "RIGHT", 0, 0)
            millisecondsLabel:SetPoint("LEFT", secondsLabel, "RIGHT", 0, -1) -- Adjusted the Y offset here
            -- Position the best clear time label below the realm best time label
            bestClearLabel:SetPoint("LEFT", labelFrame, "LEFT", 10, 10) -- Adjust the offset as needed

            goldicon:SetPoint("LEFT", labelFrame, "BOTTOM", -95, -12)
            goldText:SetPoint("LEFT", goldicon, "RIGHT", 0, 0)
            silverIcon:SetPoint("LEFT", goldText, "RIGHT", 17, 0)
            silverText:SetPoint("LEFT", silverIcon, "RIGHT", 0, 0)
            bronzeIcon:SetPoint("LEFT", silverText, "RIGHT", 17, 0)
            bronzeText:SetPoint("LEFT", bronzeIcon, "RIGHT", 0, 0)

            goldText:SetFontObject("GameFontNormal")
            silverText:SetFontObject("GameFontNormal")
            bronzeText:SetFontObject("GameFontNormal")

            swapButton:SetPoint("LEFT", Ready_Check_Button, "RIGHT", -20, 0)
            Xtreme_Boots_Button:SetPoint("LEFT", Ready_Check_Button, "RIGHT", -60, 0)
        end
    end

    -- Register an event to update the button state
    button:RegisterEvent("GROUP_ROSTER_UPDATE")
    button:SetScript("OnEvent", UpdateButtonState)

    -- Initial update of the button state
    UpdateButtonState()

    -- Function to show the legend
    function ShowLegend_Function()
        -- Show gold icon and text
        if goldicon then
            goldicon:Show()
        end
        if goldText then
            goldText:Show()
        end

        -- Show silver icon and text
        if silverIcon then
            silverIcon:Show()
        end
        if silverText then
            silverText:Show()
        end

        -- Show bronze icon and text
        if bronzeIcon then
            bronzeIcon:Show()
        end
        if bronzeText then
            bronzeText:Show()
        end
    end

    -- Function to hide the legend
    function HideLegend_Function()
        -- Hide gold icon and text
        if goldicon then
            goldicon:Hide()
        end
        if goldText then
            goldText:Hide()
        end

        -- Hide silver icon and text
        if silverIcon then
            silverIcon:Hide()
        end
        if silverText then
            silverText:Hide()
        end

        -- Hide bronze icon and text
        if bronzeIcon then
            bronzeIcon:Hide()
        end
        if bronzeText then
            bronzeText:Hide()
        end
    end

    -- Function to show the ReadyCheck
    function ShowReadyCheck_Function()

        if Ready_Check_Button then
            Ready_Check_Button:Show()
        end

    end

    -- Function to hide the ReadyCheck
    function HideReadyCheck_Function()

        if Ready_Check_Button then
            Ready_Check_Button:Hide()
        end

    end

    -- Function to show the MarkTankHealer
    function ShowMarkTankHealer_Function()

        if Role_Marks_Button then
            Role_Marks_Button:Show()
        end

    end

    -- Function to hide the MarkTankHealer
    function HideMarkTankHealer_Function()

        if Role_Marks_Button then
            Role_Marks_Button:Hide()
        end

    end

    -- Function to show the portals button
    function Show_Portals_Function()
        -- Show PortalButton
        if PortalButton then
            PortalButton:Show()
        end
    end

    -- Function to hide the the portals button
    function Hide_Portals_Function()
        -- Hide PortalButton
        if PortalButton then
            PortalButton:Hide()
        end
    end

    -- Create a dropdown menu
    local dropdownMenu = CreateFrame("Frame", "MoPCMHelperDropdownMenu", UIParent, "UIDropDownMenuTemplate")
    dropdownMenu.displayMode = "MENU"
    dropdownMenu.initialize = function(self, level)

        if level == 1 then

            local resetInfo = UIDropDownMenu_CreateInfo()
            resetInfo.text = "Reset Timer"
            resetInfo.notCheckable = true -- Sub-options won't have checkboxes
            resetInfo.func = function()
                -- Reset timer labels
                minutesLabel:SetText("|cFFFFD70000|r:")
                secondsLabel:SetText("|cFFFFD70000|r:")
                millisecondsLabel:SetText("|cFFFFFFFF000|r")
            end

            -- Add the Reset Timer option if the timer is not active
            if not isTimerActive then
                UIDropDownMenu_AddButton(resetInfo, level)
                resetButton = resetInfo
            end

            -- Define a new variable for the timeToBeatMenu
            local timeToBeatInfo = UIDropDownMenu_CreateInfo()
            timeToBeatInfo.text = "Time to beat"
            timeToBeatInfo.notCheckable = true -- Sub-options won't have checkboxes
            timeToBeatInfo.hasArrow = true
            timeToBeatInfo.value = "timeToBeat"
            UIDropDownMenu_AddButton(timeToBeatInfo, level)

            -- Add a separator
            AddSeparator(self, level)

            local lockUnlockInfo = UIDropDownMenu_CreateInfo() -- Changed variable name to avoid conflict
            -- Add the Lock/Unlock option based on labelFrame.isLocked state
            if labelFrame.isLocked then
                lockUnlockInfo.text = "Unlock"
                lockUnlockInfo.notCheckable = true
                lockUnlockInfo.func = function()
                    labelFrame.isLocked = false
                    UIDropDownMenu_Refresh(self)
                end
            else
                lockUnlockInfo.text = "Lock"
                lockUnlockInfo.notCheckable = true
                lockUnlockInfo.func = function()
                    labelFrame.isLocked = true
                    labelFrame:StopMovingOrSizing()
                    UIDropDownMenu_Refresh(self)
                end
            end

            UIDropDownMenu_AddButton(lockUnlockInfo, level)

            local scale_frame_Button = UIDropDownMenu_CreateInfo()

            if Timer_frame_Scale == "1" then
                scale_frame_Button.text = "Scale to 0.75x"
                scale_frame_Button.notCheckable = true
                scale_frame_Button.func = function()
                    ToggleFrameScale075()
                    Timer_frame_Scale = "0.75"
                    labelFrame:SavePosition()
                end
            else
                scale_frame_Button.text = "Scale to 1x"
                scale_frame_Button.notCheckable = true
                scale_frame_Button.func = function()
                    ToggleFrameScale1()
                    Timer_frame_Scale = "1"
                    labelFrame:SavePosition()
                end
            end

            UIDropDownMenu_AddButton(scale_frame_Button, level)

            local transparencyButton = UIDropDownMenu_CreateInfo()
            transparencyButton.text = "Opacity"
            transparencyButton.notCheckable = true
            transparencyButton.func = function()
                ShowOpacitySliderFrame()
            end
            UIDropDownMenu_AddButton(transparencyButton, level)

            -- Define legendToggleButton inside dropdown menu initialization
            legendToggleButton = UIDropDownMenu_CreateInfo()

            if ShowLegend == "True" then
                legendToggleButton.text = "Hide Legend"
                legendToggleButton.notCheckable = true

                legendToggleButton.func = function()
                    HideLegend_Function() -- Hide the legend
                    ShowLegend = "False"
                    UIDropDownMenu_Refresh(self)
                    updateFrame()
                    labelFrame:SavePosition()
                end
            else
                legendToggleButton.text = "Show Legend" -- Change button text
                legendToggleButton.notCheckable = true

                legendToggleButton.func = function()
                    ShowLegend_Function() -- Show the legend
                    ShowLegend = "True"
                    UIDropDownMenu_Refresh(self)
                    updateFrame()
                    labelFrame:SavePosition()
                end
            end
            UIDropDownMenu_AddButton(legendToggleButton, level)

        elseif level == 2 then
            if UIDROPDOWNMENU_MENU_VALUE == "timeToBeat" then

                local timeToBeatFrame = UIDropDownMenu_CreateInfo()
                timeToBeatFrame.text = "Realm best"
                timeToBeatFrame.notCheckable = true
                timeToBeatFrame.func = function()
                    UIDropDownMenu_SetSelectedValue(dropdownMenu, "realmBest")
                    selectedCountDown = "realmBest"
                    updateFrame()
                end
                timeToBeatFrame.checked = selectedCountDown == "realmBest" and 1 or nil
                UIDropDownMenu_AddButton(timeToBeatFrame, level)

                timeToBeatFrame = UIDropDownMenu_CreateInfo()
                timeToBeatFrame.text = "Guild best"
                timeToBeatFrame.notCheckable = true
                timeToBeatFrame.func = function()
                    UIDropDownMenu_SetSelectedValue(dropdownMenu, "guildBest")
                    selectedCountDown = "guildBest"
                    updateFrame()
                end
                timeToBeatFrame.checked = selectedCountDown == "guildBest" and 1 or nil
                UIDropDownMenu_AddButton(timeToBeatFrame, level)
            end
        end
    end

    function updateFrame()
        local realmBestTime = GetChallengeModeRealmOrGuildBestTime()
        local textToDisplay = ""
        if selectedCountDown == "realmBest" then
            textToDisplay = "Realm Best: "
        elseif selectedCountDown == "guildBest" then
            textToDisplay = "Guild Best: "
        end
        realmBestLabel:SetText(textToDisplay .. realmBestTime)
        bestClearLabel:SetText("Time remaining: " .. realmBestTime)

        goldTime = getChallengeRequirementTime("Gold")
        silverTime = getChallengeRequirementTime("Silver")
        bronzeTime = getChallengeRequirementTime("Bronze")

        goldText:SetText(goldTime)
        silverText:SetText(silverTime)
        bronzeText:SetText(bronzeTime)
    end

    -- Show the dropdown menu on right-click
    labelFrame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            UIDropDownMenu_SetSelectedValue(dropdownMenu, colorPicked2)
            ToggleDropDownMenu(1, nil, dropdownMenu, self:GetName(), 0, 0)
        end
    end)

    -- Function to save frame position and legend visibility state
    function labelFrame:SavePosition()

        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        -- local r, g, b, a = self:GetBackdropColor()

        CmHelperDB.framePosition = {
            point = point,
            relativePoint = relativePoint,
            xOfs = xOfs,
            yOfs = yOfs,
            colorPicked2 = colorPicked2, -- Save the selected color option
            -- alpha = a,
            ShowLegend = ShowLegend, -- Save the legend visibility state
            Timer_frame_Scale = Timer_frame_Scale
        }

    end

    -- Set up button click handler to show the panel
    PortalButton:SetScript("OnClick", function()
        if PortalButtonState == "NotPressed" then
            PortalButtonState = "Pressed"
            PortalButton:SetNormalTexture("Interface\\Icons\\misc_arrowleft")
            hoverFrame:Show()
        else
            PortalButtonState = "NotPressed"
            PortalButton:SetNormalTexture("Interface\\Icons\\misc_arrowright")
            hoverFrame:Hide()
        end
    end)

    -- Function to update the timer periodically
    labelFrame:SetScript("OnUpdate", function()
        UpdateTimer(minutesLabel, secondsLabel, millisecondsLabel)
        SubtractTimer(bestClearLabel)
    end)

    return labelFrame, minutesLabel, secondsLabel, millisecondsLabel, bestClearLabel

end

function areAnyChallengePortalsKnown()
    for _, portal in pairs(challengePortals) do
        if IsSpellKnown(portal.id) then
            return true -- Return true as soon as a known spell is found
        end
    end
    return false -- Return false if none of the spells are known
end

function getAvailableTeleportButtons()
    local availablePortals = {}
    if areAnyChallengePortalsKnown() then
        for portalName, portalInfo in pairs(challengePortals) do
            if IsSpellKnown(portalInfo.id) then
                local buttonInfo = {
                    name = portalName,
                    iconPath = portalInfo.iconPath,
                    id = portalInfo.id
                }
                table.insert(availablePortals, buttonInfo)
            end
        end
    end
    return availablePortals
end

function getChallengeRequirementTime(medal)
    local dungeon, _, _, difficultyName = GetInstanceInfo()
    challengeName = dungeon
    if (challengeName and difficultyName == "Challenge Mode") then
        if (medal == "Gold") then
            return cmCompletionTimes[challengeName]["Gold"]
        elseif (medal == "Silver") then
            return cmCompletionTimes[challengeName]["Silver"]
        elseif (medal == "Bronze") then
            return cmCompletionTimes[challengeName]["Bronze"]
        end
    end
end

-- Function to convert formatted time string to numerical representation
function StringToTime(timeString)
    local minutes, seconds = string.match(timeString, "(%d+):(%d+)")
    if minutes and seconds then
        return tonumber(minutes) * 60 + tonumber(seconds)
    else
        return 0
    end
end

-- Function to reset the soundPlayed table
local function ResetSoundPlayed()
    for i = 1, 10 do
        soundPlayed[i] = false
    end
end

-- Call ResetSoundPlayed at the beginning of the script
ResetSoundPlayed()

function SubtractTimer(labelToUse)
    if not startTime then
        return
    end -- Check if the timer has started

    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime

    local realmBestTime = StringToTime(GetChallengeModeRealmOrGuildBestTime())
    local timeSpent = elapsedTime
    local remainingTime = realmBestTime - timeSpent

    if remainingTime > 0 and elapsedTime >= 0 then
        local minutesLeft = math.floor(remainingTime / 60)
        local secondsLeft = math.floor(remainingTime % 60)
        local millisecondsLeft = math.floor((remainingTime * 1000) % 1000)

        local minutesTogo = string.format("|cFFFFD700%02d|r:", minutesLeft)
        local secondToGo = string.format("|cFFFFD700%02d|r", secondsLeft)
        local millisecondToGo = string.format("|cFFFFD700%02d|r", millisecondsLeft)

        -- Update the text for minutes, seconds, and milliseconds
        labelToUse:SetText("Time remaining: " .. minutesTogo .. secondToGo)

        -- Inside the condition for the last 10 seconds, check if the sound has already been played
        if secondsLeft <= 10 and secondsLeft > 0 and minutesLeft == 0 then
            if not soundPlayed[secondsLeft] then

                EnableCountdown = CmHelperDB.framePosition.EnableCountdown or "True"

                if EnableCountdown == "True" then
                    PlaySoundFile("Interface\\AddOns\\Challenge-Mode_Helper\\Sounds\\" .. secondsLeft .. ".ogg",
                        "Master")
                end

                soundPlayed[secondsLeft] = true
            end
        end
    end
end

-- Function to update the timer
function UpdateTimer(minutesLabel, secondsLabel, millisecondsLabel)
    if not startTime then
        return
    end -- Check if the timer has started

    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime
    timeElapsed = elapsedTime

    local minutes = math.floor(elapsedTime / 60)
    local seconds = math.floor(elapsedTime % 60)
    local milliseconds = math.floor((elapsedTime * 1000) % 1000)

    if (elapsedTime >= 0) then
        -- Update the text and font size for minutes
        minutesLabel:SetText(string.format("|cFFFFD700%02d|r:", minutes))

        -- Update the text and font size for seconds
        secondsLabel:SetText(string.format("|cFFFFD700%02d|r:", seconds))

        -- Update the text and font size for milliseconds
        millisecondsLabel:SetText(string.format("|cFFFFFFFF%03d|r", milliseconds))
    end
end

function GetChallengeRealmOrGuildBestTime()
    local realmBest = 0
    local guildBest = 0
    local dungeon, _, _, difficultyName = GetInstanceInfo()

    if difficultyName == "Challenge Mode" then
        challengeName = dungeon
        local _, _, _, _, _, _, _, currentMapID = GetInstanceInfo()

        guildBest, realmBest = GetChallengeBestTime(currentMapID)

        if (selectedCountDown == "realmBest") then
            return realmBest
        elseif (selectedCountDown == "guildBest") then
            return guildBest
        end
    end
end

function formatSecondsToMinutes(timeToFormat)
    local formattedTime = "00:00" -- Default formatted time if realm best is not available

    if timeToFormat and timeToFormat ~= 0 then
        timeToFormat = timeToFormat / 1000

        -- Calculate hours, minutes, and seconds
        local minutes = math.floor((timeToFormat % 3600) / 60)
        local seconds = timeToFormat % 60

        -- Format the time string
        formattedTime = string.format("%02d:%02d", minutes, seconds)
    end

    return formattedTime
end

function GetChallengeModeRealmOrGuildBestTime()
    local timeToBeat = GetChallengeRealmOrGuildBestTime()
    local realmBestFormattedTime = formatSecondsToMinutes(timeToBeat)
    return realmBestFormattedTime
end

function GetRemainingTimeToBeatCounter()
    local timeToBeat = GetChallengeRealmOrGuildBestTime()
    local currentTime = GetElapsedTime()

    -- Check if any required value is nil
    if not timeToBeat or not currentTime then
        return "N/A" -- Return a default value or handle the nil case appropriately
    end

    -- Calculate remaining time only if both values are available
    local remainingTimeToBeatRealmBest = timeToBeat - currentTime
    local formattedRemainingTime = formatSecondsToMinutes(remainingTimeToBeatRealmBest)
    return formattedRemainingTime
end

function GetElapsedTime()
    if not startTime then
        return 0
    end -- Return 0 if the timer has not started
    local currentTime = GetTime()
    local elapsedTime = currentTime - startTime
    timeElapsed = elapsedTime
    return elapsedTime
end

local function LoadCompletionTimes()
    -- Load the database from the separate file
    dofile("CompletionTimes.lua")

    -- Optional: Print a message to confirm that the database is loaded
    print("Completion times database loaded.")
end

local function checkPortalExistance(portalId)
    return C_Spell.DoesSpellExist(portalId)
end

function LabelFrame_Opacity(value)
    labelFrame:SetBackdropColor(0, 0, 0, value)
    colorPicked2 = value
    labelFrame:SavePosition()
end

function Check_Group_State_For_Button_State()
    if IsInGroup() and UnitIsGroupLeader("player") then
        labelFrame:SetSize(270, 100) -- Set the size of the label frame
        button:Show() -- Show the button if the player is the group leader

        ShowReadyCheckVariable = CmHelperDB.framePosition.ShowReadyCheck

        if ShowReadyCheckVariable == "False" then
            HideReadyCheck_Function()
        else
            ShowReadyCheck_Function()
        end

        ShowMarkTankHealerVariable = CmHelperDB.framePosition.ShowMarkTankHealer

        if ShowMarkTankHealerVariable == "False" then
            HideMarkTankHealer_Function()
        else
            ShowMarkTankHealer_Function()
        end
    elseif not IsInGroup() then
        labelFrame:SetSize(270, 100) -- Set the size of the label frame

        button:Show() -- Show the button if the player is alone
        Ready_Check_Button:Hide()
        Role_Marks_Button:Hide()
    else
        button:Hide() -- Hide the button if the player is in a group but not the leader
        Ready_Check_Button:Hide()
        Role_Marks_Button:Hide()
    end
end

function ShowTimerFrame()
    labelFrame:Show()
end

function HideTimerFrame()
    local _, _, _, difficultyName = GetInstanceInfo()
    if difficultyName == "Challenge Mode" then
    else
        labelFrame:Hide()
    end
end

-- Create a function to simulate a delayed action
local function DelayedAction(delay, func)
    local start = GetTime()
    local frame = CreateFrame("Frame")
    frame:SetScript("OnUpdate", function(self, elapsed)
        if GetTime() - start >= delay then
            func() -- Execute the delayed function
            self:SetScript("OnUpdate", nil) -- Stop the OnUpdate loop
        end
    end)
end

-- Function to toggle the scale of the frame and its children
function ToggleFrameScale1()
    labelFrame:SetScale(1) -- Set to normal size
    Timer_frame_Scale = "1"
end

-- Function to toggle the scale of the frame and its children
function ToggleFrameScale075()
    labelFrame:SetScale(0.75) -- Set to 75% scale
    Timer_frame_Scale = "0.75"
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
frame:RegisterEvent("WORLD_MAP_UPDATE")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("PLAYER_ROLES_ASSIGNED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then

        -- -- If it's the first load, center the labelFrame on the screen
        -- if isFirstLoad and not CmHelperDB then
        --     isFirstLoad = false
        --     if labelFrame then
        --         labelFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        --     end
        --     -- CmHelperDB.framePosition.colorPicked2 = "1"
        --     -- CmHelperDB.framePosition.ShowLegend = "True"
        -- end
        local _, _, _, difficultyName = GetInstanceInfo()
        if difficultyName == "Challenge Mode" then
            -- Reset the timer labels to "00:00:000"
            minutesLabel:SetText("00:")
            secondsLabel:SetText("00:")
            millisecondsLabel:SetText("000")
            if not labelFrame then
                labelFrame, minutesLabel, secondsLabel, millisecondsLabel, bestClearLabel = CreateAddonFrame()
            end
            local timeRemaining = GetChallengeModeRealmOrGuildBestTime()
            updateFrame()
            labelFrame:Show()
        else
            if inChallengeMode then
                OnWorldStateTimerStop() -- Reset the timer if leaving challenge mode
            end
            labelFrame:Hide()
            hoverFrame:Hide()
            PortalButtonState = "NotPressed"
            PortalButton:SetNormalTexture("Interface\\Icons\\misc_arrowright")
        end

        if AutoEquipXtremeBoots == false then
            Disable_EquipRocketBoots_Function()
            Xtreme_Boots_Button:SetNormalTexture("Interface\\Icons\\INV_Gizmo_RocketBoot_Destroyed_02")
        else
            Enable_EquipRocketBoots_Function()
            Xtreme_Boots_Button:SetNormalTexture("Interface\\Icons\\INV_Gizmo_RocketBoot_01")
        end
    elseif event == "PLAYER_ROLES_ASSIGNED" then
        Check_Group_State_For_Button_State()
    elseif event == "PLAYER_LOGOUT" then
        if not CmHelperDB.framePosition.colorPicked2 then
            CmHelperDB.framePosition.colorPicked2 = "1" -- Variable to store the selected color option
        end
        if not CmHelperDB.framePosition.Timer_frame_Scale then
            CmHelperDB.framePosition.Timer_frame_Scale = "1" -- Variable to store the selected color option
        end
        if not CmHelperDB.framePosition.ShowLegend then
            CmHelperDB.framePosition.ShowLegend = "True" -- Variable to store the selected color option
        end
        if not CmHelperDB.framePosition.ShowPortalsButton then
            CmHelperDB.framePosition.ShowPortalsButton = "True" -- Variable to store the selected color option
        end
    elseif event == "WORLD_STATE_TIMER_START" then
        -- OnWorldStateTimerStart()
    elseif event == "WORLD_STATE_TIMER_STOP" then
        startTime = nil -- Reset the start time
        isTimerActive = false
        if resetButton then
            resetButton.disabled = nil -- Enable the reset button
        end
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        if inChallengeMode then
            inChallengeMode = false
            startTime = nil -- Reset the start time
            labelFrame:SetScript("OnUpdate", nil) -- Stop updating the timer
        end
    elseif event == "ZONE_CHANGED_NEW_AREA" then

    elseif event == "PLAYER_LOGIN" then

        -- Function to load frame position and legend visibility state
        if CmHelperDB and CmHelperDB.framePosition then -- 

            if not labelFrame then
                labelFrame, minutesLabel, secondsLabel, millisecondsLabel = CreateAddonFrame()
            end
            labelFrame:SetPoint(CmHelperDB.framePosition.point, UIParent, CmHelperDB.framePosition.relativePoint,
                CmHelperDB.framePosition.xOfs, CmHelperDB.framePosition.yOfs)

            labelFrame:SetBackdropColor(0, 0, 0, CmHelperDB.framePosition.colorPicked2)

            ShowLegend = CmHelperDB.framePosition.ShowLegend

            if ShowLegend == "False" then
                HideLegend_Function()
            else
                ShowLegend_Function()
            end

            Timer_frame_Scale = CmHelperDB.framePosition.Timer_frame_Scale

            if Timer_frame_Scale == "1" then
                ToggleFrameScale1()
            else
                ToggleFrameScale075()
            end

            ShowPortalsButton = CmHelperDB.framePosition.ShowPortalsButton

            if ShowPortalsButton == "False" then
                Hide_Portals_Function()
            else
                Show_Portals_Function()
            end

            ShowReadyCheckVariable = CmHelperDB.framePosition.ShowReadyCheck

            if ShowReadyCheckVariable == "False" then
                HideReadyCheck_Function()
            else
                ShowReadyCheck_Function()
            end

            ShowMarkTankHealerVariable = CmHelperDB.framePosition.ShowMarkTankHealer

            if ShowMarkTankHealerVariable == "False" then
                HideMarkTankHealer_Function()
            else
                ShowMarkTankHealer_Function()
            end

            Check_Group_State_For_Button_State()

        else
            -- Initialize CmHelperDB with the default values
            -- *********************************************
            -- *********************************************
            -- *********************************************
            -- *********************************************
            -- auto den ekteleitai
            -- auto den ekteleitai
            -- auto den ekteleitai
            -- auto den ekteleitai

            CmHelperDB = {
                framePosition = {
                    yOfs = -21.22220802307129,
                    xOfs = 7.110173225402832,
                    point = "TOP",
                    relativePoint = "TOP",
                    colorPicked2 = "1",
                    alpha = "1",
                    ShowLegend = "True", -- Default legend visibility state
                    EnableCountdown = "True"
                }
            }
            labelFrame, minutesLabel, secondsLabel, millisecondsLabel = CreateAddonFrame()
            labelFrame:SetBackdropColor(0, 0, 0, CmHelperDB.framePosition.colorPicked2)

            -- Since it's the first load, we assume legend is hidden by default
            HideLegend_Function()
        end
        updateFrame()

    elseif event == "START_TIMER" then

        if Swap_Trinkets then
            DelayedAction(3, swapTrinkets) -- Calls swapTrinkets after 3 seconds only if Swap_Trinkets is true
        end

        startTime = GetTime() + 5 -- Record the start time
        isTimerActive = true
        if resetButton then
            resetButton.disabled = 1 -- Disable the reset button
        end
        ResetSoundPlayed() -- Reset the soundPlayed table when the timer starts
    elseif event == "WORLD_MAP_UPDATE" then
        updateFrame()
    end
end)

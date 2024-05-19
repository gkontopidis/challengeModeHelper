local Main_Options_compositeFrame
local Timer_Frame_compositeFrame2
local Objectives_Frame_compositeFrame3
local Strategies_compositeFrame
local Automarker_compositeFrame
local About_Panel_compositeFrame4
local Add_New_Strategy_Button
local editStrategyFrame
local Strategies_Frame_comboBox
local editBox
local f = CreateFrame("Frame") -- Addon Initialization

function f:OnEvent(event, addOnName)
    if event == "ADDON_LOADED" then
        if addOnName == "Challenge-Mode_Helper" then
            CmHelperDB = CmHelperDB or CopyTable(defaults)
            self.db = CmHelperDB
            self:InitializeOptions()
            -- Inform the player about the addon's purpose
            print(
                "|cff00ccffChallenge-Mode Helper loaded. An essential addon for Mist of Pandaria Challenge Modes! Enhance your performance with valuable insights and convenient functionalities.")
            print("|cff00ccffType /cm or /cmhelper to access options and reset boss kill times.")
            print("|cff00ccffAutoMarker usage /am add 'NPC Name'.")
        end
    elseif event == "WORLD_STATE_TIMER_STOP" then
        OnWorldStateTimerStop() -- This calls the globally shared function
    end
end

local function Main_Options_Panel_Elements()

    -- Create medal_image
    local Main_Options_medal_image = Main_Options_compositeFrame:CreateTexture(nil, "OVERLAY")
    Main_Options_medal_image:SetTexture("Interface\\Challenges\\challenges-gold.blp")
    -- medal_image:SetTexture("Interface\\Timer\\Challenges-Logo.blp") 
    Main_Options_medal_image:SetSize(300, 300)
    Main_Options_medal_image:SetPoint("TOPLEFT", Main_Options_compositeFrame, "TOPLEFT", 0, 0)

    -- Create pattern_image
    local Main_Options_pattern_image = Main_Options_compositeFrame:CreateTexture(nil, "BORDER")
    Main_Options_pattern_image:SetTexture("Interface\\Challenges\\challenges-background.blp")
    Main_Options_pattern_image:SetSize(955, 800)
    Main_Options_pattern_image:SetPoint("TOPLEFT", Main_Options_compositeFrame, "TOPLEFT", 0, 0)

    -- Create banner_image
    local Main_Options_banner_image = Main_Options_compositeFrame:CreateTexture(nil, "ARTWORK")
    Main_Options_banner_image:SetTexture("Interface\\Challenges\\challenges-besttime-bg.blp")
    Main_Options_banner_image:SetSize(952, 170)
    Main_Options_banner_image:SetPoint("TOPLEFT", Main_Options_compositeFrame, "TOPLEFT", -166, -70)

    -- Create textFrame
    local Main_Options_textFrame = CreateFrame("Frame", nil, Main_Options_compositeFrame)
    Main_Options_textFrame:SetAllPoints(Main_Options_compositeFrame) -- Make the text frame cover the entire composite frame

    -- Create base_background_image
    local Main_Options_base_background_image = Main_Options_compositeFrame:CreateTexture(nil, "BACKGROUND")
    Main_Options_base_background_image:SetTexture("Interface\\FriendsFrame\\PlusManz-BattleNetBG.blp")
    Main_Options_base_background_image:SetSize(843, 830)
    Main_Options_base_background_image:SetPoint("TOPLEFT", Main_Options_compositeFrame, "TOPLEFT", -112, 130)
    Main_Options_base_background_image:SetAlpha(0.3)

    local Main_Options_text1 = Main_Options_textFrame:CreateFontString(nil, Main_Options_compositeFrame,
        "GameFontNormalLarge") -- Set text to OVERLAY layer
    Main_Options_text1:SetPoint("CENTER", -160, 100)
    -- text1:SetText("|cffffd700Authors:\n\n|r |cffffffffClopy, Snapshot")
    Main_Options_text1:SetText("|cffffd700Authors\n\n|r|cff00ff98Clopy|r, |cffaad372Snapshot")
    Main_Options_text1:SetTextColor(1, 0.82, 0) -- Set text color to yellow
    Main_Options_text1:SetShadowColor(0, 0, 0) -- Set shadow color to black
    Main_Options_text1:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    local Main_Options_text2 = Main_Options_textFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    Main_Options_text2:SetPoint("CENTER", Main_Options_text1, "BOTTOMLEFT", 0, -40)
    Main_Options_text2:SetText("|cffffd700Version\n\n|r |cffffffff4.03")
    Main_Options_text2:SetTextColor(1, 0.82, 0) -- Set text color to yellow
    Main_Options_text2:SetShadowColor(0, 0, 0) -- Set shadow color to black
    Main_Options_text2:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    local Main_Options_text3 = Main_Options_textFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    Main_Options_text3:SetPoint("CENTER", Main_Options_text1, "BOTTOMRIGHT", 0, -40)
    Main_Options_text3:SetText("|cffffd700Contact\n\n|r |cff7289daClopy#0540")
    Main_Options_text3:SetTextColor(1, 0.82, 0) -- Set text color to yellow
    Main_Options_text3:SetShadowColor(0, 0, 0) -- Set shadow color to black
    Main_Options_text3:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    local Main_Options_text4 = Main_Options_textFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    Main_Options_text4:SetPoint("CENTER", Main_Options_text1, "BOTTOM", 0, -160)
    Main_Options_text4:SetJustifyH("CENTER")
    Main_Options_text4:SetText(
        "|cffffd700Thanks to|r |cffffffff\n\nPrasinos\nPlaquetas\nDeadmouse\nLocative\nChristina\n\nand the guy who created the Weak Aura for Challenge modes,\nthis WA was our inspiration")
    Main_Options_text4:SetTextColor(1, 0.82, 0) -- Set text color to yellow
    Main_Options_text4:SetShadowColor(0, 0, 0) -- Set shadow color to black
    Main_Options_text4:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    local Main_Options_text5 = Main_Options_textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    Main_Options_text5:SetPoint("CENTER", Main_Options_textFrame, "CENTER", -50, 230)
    Main_Options_text5:SetText("|cffffffffMists of Pandaria\n\n|r|cffffd700Challenge Mode|r|cffffffff\n\nHelper") -- Use |r to reset color
    Main_Options_text5:SetFont("Fonts\\MORPHEUS.TTF", 72) -- Set the font to Morpheus and adjust the font size here
    -- text5:SetFont("Fonts\\FRIZQT__.TTF", 72) -- Adjust the font size here
    Main_Options_text5:SetShadowColor(0, 0, 0) -- Set shadow color to black
    Main_Options_text5:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect
end

local function Timer_Frame_Elements()

    -- Create pattern_image
    local Timer_Frame_compositeFrame2pattern_image2 = Timer_Frame_compositeFrame2:CreateTexture(nil, "BORDER")
    Timer_Frame_compositeFrame2pattern_image2:SetTexture("Interface\\Challenges\\challenges-background.blp")
    Timer_Frame_compositeFrame2pattern_image2:SetSize(955, 800)
    Timer_Frame_compositeFrame2pattern_image2:SetPoint("TOPLEFT", Timer_Frame_compositeFrame2, "TOPLEFT", 0, 0)

    -- Create banner_image
    local Timer_Frame_compositeFrame2banner_image2 = Timer_Frame_compositeFrame2:CreateTexture(nil, "ARTWORK")
    Timer_Frame_compositeFrame2banner_image2:SetTexture("Interface\\Challenges\\challenges-besttime-bg.blp")
    Timer_Frame_compositeFrame2banner_image2:SetSize(952, 50)
    Timer_Frame_compositeFrame2banner_image2:SetPoint("TOPLEFT", Timer_Frame_compositeFrame2, "TOPLEFT", -166, -30)

    -- Create timer_options_panel_left
    local Timer_Frame_compositeFrame2timer_options_panel_left =
        Timer_Frame_compositeFrame2:CreateTexture(nil, "ARTWORK")
    Timer_Frame_compositeFrame2timer_options_panel_left:SetTexture("Interface\\HELPFRAME\\HelpFrame-TopLeft.blp")
    Timer_Frame_compositeFrame2timer_options_panel_left:SetSize(190, 186)
    Timer_Frame_compositeFrame2timer_options_panel_left:SetPoint("TOPLEFT", Timer_Frame_compositeFrame2, "TOPLEFT", 45,
        -130)

    -- Create timer_options_panel_right
    local Timer_Frame_compositeFrame2timer_options_panel_right =
        Timer_Frame_compositeFrame2:CreateTexture(nil, "ARTWORK")
    Timer_Frame_compositeFrame2timer_options_panel_right:SetTexture("Interface\\HELPFRAME\\HelpFrame-TopRight.blp")
    Timer_Frame_compositeFrame2timer_options_panel_right:SetSize(98, 186)
    Timer_Frame_compositeFrame2timer_options_panel_right:SetPoint("LEFT",
        Timer_Frame_compositeFrame2timer_options_panel_left, "RIGHT", 0, 0)

    -- Create timer_options_panel_bottom_left
    local Timer_Frame_compositeFrame2timer_options_panel_bottom_left =
        Timer_Frame_compositeFrame2:CreateTexture(nil, "ARTWORK")
    Timer_Frame_compositeFrame2timer_options_panel_bottom_left:SetTexture("Interface\\HELPFRAME\\HELPFRAME-BOTLEFT.blp")
    Timer_Frame_compositeFrame2timer_options_panel_bottom_left:SetSize(190, 186)
    Timer_Frame_compositeFrame2timer_options_panel_bottom_left:SetPoint("TOPLEFT",
        Timer_Frame_compositeFrame2timer_options_panel_left, "BOTTOMLEFT", 0, 0) -- Adjusted point

    -- Create timer_options_panel_bottom_right
    local Timer_Frame_compositeFrame2timer_options_panel_bottom_right =
        Timer_Frame_compositeFrame2:CreateTexture(nil, "ARTWORK")
    Timer_Frame_compositeFrame2timer_options_panel_bottom_right:SetTexture(
        "Interface\\HELPFRAME\\HELPFRAME-BOTRIGHT.blp")
    Timer_Frame_compositeFrame2timer_options_panel_bottom_right:SetSize(98, 186)
    Timer_Frame_compositeFrame2timer_options_panel_bottom_right:SetPoint("LEFT",
        Timer_Frame_compositeFrame2timer_options_panel_bottom_left, "RIGHT", 0, 0)

    -- Create timer_options_icon
    local Timer_Frame_compositeFrame2timer_options_icon = Timer_Frame_compositeFrame2:CreateTexture(nil, "OVERLAY")
    Timer_Frame_compositeFrame2timer_options_icon:SetTexture("Interface\\HELPFRAME\\HelpIcon-CharacterStuck.blp")
    Timer_Frame_compositeFrame2timer_options_icon:SetSize(16, 16)
    Timer_Frame_compositeFrame2timer_options_icon:SetPoint("LEFT", Timer_Frame_compositeFrame2timer_options_panel_right,
        "TOPRIGHT", -53, -14) -- Adjusted point

    -- Create timer_options_panel_left_right_side
    local Timer_Frame_compositeFrame2timer_options_panel_left_right_side =
        Timer_Frame_compositeFrame2:CreateTexture(nil, "ARTWORK")
    Timer_Frame_compositeFrame2timer_options_panel_left_right_side:SetTexture(
        "Interface\\HELPFRAME\\HelpFrame-TopLeft.blp")
    Timer_Frame_compositeFrame2timer_options_panel_left_right_side:SetSize(190, 186)
    Timer_Frame_compositeFrame2timer_options_panel_left_right_side:SetPoint("TOPLEFT", Timer_Frame_compositeFrame2,
        "TOPLEFT", 320, -130)

    -- Create timer_options_panel_right_right_side
    local Timer_Frame_compositeFrame2timer_options_panel_right_right_side =
        Timer_Frame_compositeFrame2:CreateTexture(nil, "ARTWORK")
    Timer_Frame_compositeFrame2timer_options_panel_right_right_side:SetTexture(
        "Interface\\HELPFRAME\\HelpFrame-TopRight.blp")
    Timer_Frame_compositeFrame2timer_options_panel_right_right_side:SetSize(98, 186)
    Timer_Frame_compositeFrame2timer_options_panel_right_right_side:SetPoint("LEFT",
        Timer_Frame_compositeFrame2timer_options_panel_left_right_side, "RIGHT", 0, 0)

    -- Create timer_options_panel_bottom_right_side
    local Timer_Frame_compositeFrame2timer_options_panel_bottom_right_side =
        Timer_Frame_compositeFrame2:CreateTexture(nil, "ARTWORK")
    Timer_Frame_compositeFrame2timer_options_panel_bottom_right_side:SetTexture(
        "Interface\\HELPFRAME\\HELPFRAME-BOTLEFT.blp")
    Timer_Frame_compositeFrame2timer_options_panel_bottom_right_side:SetSize(190, 186)
    Timer_Frame_compositeFrame2timer_options_panel_bottom_right_side:SetPoint("TOPLEFT",
        Timer_Frame_compositeFrame2timer_options_panel_left_right_side, "BOTTOMLEFT", 0, 0) -- Adjusted point

    -- Create timer_options_panel_bottom_right_right_side
    local Timer_Frame_compositeFrame2timer_options_panel_bottom_right_right_side =
        Timer_Frame_compositeFrame2:CreateTexture(nil, "ARTWORK")
    Timer_Frame_compositeFrame2timer_options_panel_bottom_right_right_side:SetTexture(
        "Interface\\HELPFRAME\\HELPFRAME-BOTRIGHT.blp")
    Timer_Frame_compositeFrame2timer_options_panel_bottom_right_right_side:SetSize(98, 186)
    Timer_Frame_compositeFrame2timer_options_panel_bottom_right_right_side:SetPoint("LEFT",
        Timer_Frame_compositeFrame2timer_options_panel_bottom_right_side, "RIGHT", 0, 0)

    -- Create objectives_options_icon
    local Timer_Frame_compositeFrame2timer_options_icon = Timer_Frame_compositeFrame2:CreateTexture(nil, "OVERLAY")
    Timer_Frame_compositeFrame2timer_options_icon:SetTexture("Interface\\HELPFRAME\\HelpIcon-CharacterStuck.blp")
    Timer_Frame_compositeFrame2timer_options_icon:SetSize(16, 16)
    Timer_Frame_compositeFrame2timer_options_icon:SetPoint("LEFT",
        Timer_Frame_compositeFrame2timer_options_panel_right_right_side, "TOPRIGHT", -53, -14) -- Adjusted point

    -- Create textFrame
    local Timer_Frame_compositeFrame2textFrame2 = CreateFrame("Frame", nil, Timer_Frame_compositeFrame2)
    Timer_Frame_compositeFrame2textFrame2:SetAllPoints(Timer_Frame_compositeFrame2) -- Make the text frame cover the entire composite frame

    -- Create base_background_image
    local Timer_Frame_compositeFrame2base_background_image2 =
        Timer_Frame_compositeFrame2:CreateTexture(nil, "BACKGROUND")
    Timer_Frame_compositeFrame2base_background_image2:SetTexture("Interface\\FriendsFrame\\PlusManz-BattleNetBG.blp")
    Timer_Frame_compositeFrame2base_background_image2:SetSize(843, 830)
    Timer_Frame_compositeFrame2base_background_image2:SetPoint("TOPLEFT", Timer_Frame_compositeFrame2, "TOPLEFT", -112,
        130)
    Timer_Frame_compositeFrame2base_background_image2:SetAlpha(0.3)

    local Timer_Frame_compositeFrame2option_text = Timer_Frame_compositeFrame2textFrame2:CreateFontString(nil,
        "ARTWORK", "GameFontNormalHuge")
    Timer_Frame_compositeFrame2option_text:SetPoint("CENTER", Timer_Frame_compositeFrame2banner_image2, "CENTER", 0, 0)
    Timer_Frame_compositeFrame2option_text:SetText("|cffffd700Timer Frame Options") -- Use |r to reset color
    Timer_Frame_compositeFrame2option_text:SetFont("Fonts\\MORPHEUS.TTF", 72) -- Set the font to Morpheus and adjust the font size here
    Timer_Frame_compositeFrame2option_text:SetShadowColor(0, 0, 0) -- Set shadow color to black
    Timer_Frame_compositeFrame2option_text:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    local Timer_Frame_compositeFrame2timer_options_title = Timer_Frame_compositeFrame2textFrame2:CreateFontString(nil,
        "ARTWORK", "GameFontNormalHuge")
    Timer_Frame_compositeFrame2timer_options_title:SetPoint("CENTER",
        Timer_Frame_compositeFrame2timer_options_panel_left, "CENTER", 30, 70)
    Timer_Frame_compositeFrame2timer_options_title:SetText("|cffffd700Appearance") -- Use |r to reset color
    Timer_Frame_compositeFrame2timer_options_title:SetFont("Fonts\\FRIZQT__.TTF", 14) -- Set the font to Morpheus and adjust the font size here
    Timer_Frame_compositeFrame2timer_options_title:SetShadowColor(0, 0, 0) -- Set shadow color to black
    Timer_Frame_compositeFrame2timer_options_title:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    local Timer_Frame_compositeFrame2objectives_options_title =
        Timer_Frame_compositeFrame2textFrame2:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    Timer_Frame_compositeFrame2objectives_options_title:SetPoint("CENTER",
        Timer_Frame_compositeFrame2timer_options_panel_left_right_side, "CENTER", 30, 70)
    Timer_Frame_compositeFrame2objectives_options_title:SetText("|cffffd700Settings") -- Use |r to reset color
    Timer_Frame_compositeFrame2objectives_options_title:SetFont("Fonts\\FRIZQT__.TTF", 14) -- Set the font to Morpheus and adjust the font size here
    Timer_Frame_compositeFrame2objectives_options_title:SetShadowColor(0, 0, 0) -- Set shadow color to black
    Timer_Frame_compositeFrame2objectives_options_title:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    -- Define the checkbox variable outside any function to make it accessible globally
    local Countdown_Checkbox

    -- Function to initialize the checkbox
    local function InitializeCheckbox()
        local isChecked = CmHelperDB.framePosition.EnableCountdown == "False" -- Check the value from the database
        Countdown_Checkbox:SetChecked(isChecked)
    end

    -- Create Countdown_Checkbox
    Countdown_Checkbox = CreateFrame("CheckButton", nil, Timer_Frame_compositeFrame2, "UICheckButtonTemplate")
    Countdown_Checkbox:SetPoint("TOP", Timer_Frame_compositeFrame2objectives_options_title, "CENTER", -90, -50)
    Countdown_Checkbox.text:SetText(
        "Disable the audio countdown for\nthe last 10 seconds of either the\nGuild Best Time or Realm Best Time,\nbased on your selection.")
    Countdown_Checkbox:SetScript("OnShow", InitializeCheckbox) -- Call initialization function when the checkbox is shown

    -- Function to handle Hide Legend checkbox state change
    local function OnCountdownCheckboxStateChanged(self)
        local isChecked = self:GetChecked()
        CmHelperDB.framePosition.EnableCountdown = isChecked and "True" or "False" -- Update the value in the database

        -- Call the corresponding function based on the checkbox state
        if isChecked then
            CmHelperDB.framePosition.EnableCountdown = "False"
        else
            CmHelperDB.framePosition.EnableCountdown = "True"
        end
    end

    Countdown_Checkbox:SetScript("OnClick", OnCountdownCheckboxStateChanged) -- Set script to handle checkbox state change

    -- Button to Restore Timer_Frame_Position_Reset_Button
    local Timer_Frame_compositeFrame2Timer_Frame_Position_Reset_Button = CreateFrame("Button", nil,
        Timer_Frame_compositeFrame2, "UIPanelButtonTemplate")
    Timer_Frame_compositeFrame2Timer_Frame_Position_Reset_Button:SetFrameLevel(3) -- This ensures that the button is at the correct level within the OVERLAY strata
    Timer_Frame_compositeFrame2Timer_Frame_Position_Reset_Button:SetPoint("CENTER",
        Timer_Frame_compositeFrame2objectives_options_title, "CENTER", 5, -280)
    Timer_Frame_compositeFrame2Timer_Frame_Position_Reset_Button:SetText("Reset Timer Position")
    Timer_Frame_compositeFrame2Timer_Frame_Position_Reset_Button:SetWidth(200)
    Timer_Frame_compositeFrame2Timer_Frame_Position_Reset_Button:SetHeight(40)

    Timer_Frame_compositeFrame2Timer_Frame_Position_Reset_Button:SetScript("OnClick", function()
        ResetLabelFramePosition()
    end)

    -- Create Opacity_Label Timer
    local Timer_Frame_compositeFrame2Timer_Opacity_Label = Timer_Frame_compositeFrame2textFrame2:CreateFontString(nil,
        "OVERLAY", "GameFontHighlight")
    Timer_Frame_compositeFrame2Timer_Opacity_Label:SetPoint("CENTER", Timer_Frame_compositeFrame2timer_options_title,
        "CENTER", 5, -35)
    Timer_Frame_compositeFrame2Timer_Opacity_Label:SetText("Opacity")

    -- Create Slider Timer
    local Timer_Frame_compositeFrame2Timer_slider = CreateFrame("Slider", nil, Timer_Frame_compositeFrame2,
        "OptionsSliderTemplate")
    Timer_Frame_compositeFrame2Timer_slider:SetPoint("TOP", Timer_Frame_compositeFrame2Timer_Opacity_Label, "BOTTOM", 0,
        -10)
    Timer_Frame_compositeFrame2Timer_slider:SetWidth(200)
    Timer_Frame_compositeFrame2Timer_slider:SetHeight(20)
    Timer_Frame_compositeFrame2Timer_slider:SetMinMaxValues(0, 100)
    Timer_Frame_compositeFrame2Timer_slider:SetValueStep(1)

    -- Slider Label Timer
    local Timer_Frame_compositeFrame2sliderLabel2 = Timer_Frame_compositeFrame2Timer_slider:CreateFontString(nil,
        "OVERLAY", "GameFontHighlight")
    Timer_Frame_compositeFrame2sliderLabel2:SetPoint("TOP", Timer_Frame_compositeFrame2Timer_slider, "BOTTOM", 0, -5)
    -- Timer_Frame_compositeFrame2sliderLabel2:SetText("Value: " .. colorPicked2Value) --Timer_Frame_compositeFrame2Timer_slider:GetValue())

    -- Load colorPicked2 value from CmHelperDB if available, otherwise use default value
    local initialColorPicked2 = (CmHelperDB and CmHelperDB.framePosition and CmHelperDB.framePosition.colorPicked2) or 1
    Timer_Frame_compositeFrame2Timer_slider:SetValue(initialColorPicked2 * 100)
    Timer_Frame_compositeFrame2sliderLabel2:SetText(math.floor(initialColorPicked2 * 100))

    -- Update the OnValueChanged callback function to correctly update colorPicked2
    Timer_Frame_compositeFrame2Timer_slider:SetScript("OnValueChanged", function(self, value)
        local colorPicked2 = value / 100 -- Normalize value to range 0-1
        LabelFrame_Opacity(colorPicked2)
        Timer_Frame_compositeFrame2sliderLabel2:SetText(math.floor(colorPicked2 * 100)) -- Update the value label
    end)

    function SliderValue(SliderValue)
        Timer_Frame_compositeFrame2Timer_slider:SetValue(SliderValue)
        Timer_Frame_compositeFrame2sliderLabel2:SetText(math.floor(SliderValue))
    end

    -- Define the checkbox variable outside any function to make it accessible globally
    local Timer_Frame_compositeFrame2Show_Legend_Checkbox

    -- Function to initialize the checkbox
    local function InitializeCheckbox()
        local isChecked = CmHelperDB.framePosition.ShowLegend == "False" -- Check the value from the database
        Timer_Frame_compositeFrame2Show_Legend_Checkbox:SetChecked(isChecked)
    end

    -- Create Show_Legend_Checkbox
    Timer_Frame_compositeFrame2Show_Legend_Checkbox = CreateFrame("CheckButton", nil, Timer_Frame_compositeFrame2,
        "UICheckButtonTemplate")
    Timer_Frame_compositeFrame2Show_Legend_Checkbox:SetPoint("TOP", Timer_Frame_compositeFrame2Timer_slider, "CENTER",
        -90, -50)
    Timer_Frame_compositeFrame2Show_Legend_Checkbox.text:SetText("Hide Legend")
    Timer_Frame_compositeFrame2Show_Legend_Checkbox:SetScript("OnShow", InitializeCheckbox) -- Call initialization function when the checkbox is shown

    -- Function to handle Hide Legend checkbox state change
    local function OnHideLegendCheckboxStateChanged(self)
        local isChecked = self:GetChecked()
        CmHelperDB.framePosition.ShowLegend = isChecked and "True" or "False" -- Update the value in the database

        -- Call the corresponding function based on the checkbox state
        if isChecked then
            HideLegend_Function()

            CmHelperDB.framePosition.ShowLegend = "False"
        else
            ShowLegend_Function()

            CmHelperDB.framePosition.ShowLegend = "True"
        end

    end

    Timer_Frame_compositeFrame2Show_Legend_Checkbox:SetScript("OnClick", OnHideLegendCheckboxStateChanged) -- Set script to handle checkbox state change

    -- Define the checkbox variable outside any function to make it accessible globally
    local Timer_Frame_compositeFrame2Show_Teleports_Checkbox

    -- Function to initialize the checkbox
    local function InitializeCheckbox_Portals()
        local isChecked2 = CmHelperDB.framePosition.ShowPortalsButton == "False" -- Check the value from the database
        Timer_Frame_compositeFrame2Show_Teleports_Checkbox:SetChecked(isChecked2)
    end

    -- Create Show_Teleports_Checkbox
    Timer_Frame_compositeFrame2Show_Teleports_Checkbox = CreateFrame("CheckButton", nil, Timer_Frame_compositeFrame2,
        "UICheckButtonTemplate")
    Timer_Frame_compositeFrame2Show_Teleports_Checkbox:SetPoint("TOP", Timer_Frame_compositeFrame2Show_Legend_Checkbox,
        "CENTER", 0, -35)
    Timer_Frame_compositeFrame2Show_Teleports_Checkbox.text:SetText("Hide Teleporters Button")
    Timer_Frame_compositeFrame2Show_Teleports_Checkbox:SetScript("OnShow", InitializeCheckbox_Portals) -- Call initialization function when the checkbox is shown

    -- Function to handle Hide Legend checkbox state change
    local function OnHidePortalButtonCheckboxStateChanged(self)
        local isChecked2 = self:GetChecked()
        CmHelperDB.framePosition.ShowPortalsButton = isChecked2 and "True" or "False" -- Update the value in the database

        -- Call the corresponding function based on the checkbox state
        if isChecked2 then
            Hide_Portals_Function()

            CmHelperDB.framePosition.ShowPortalsButton = "False"
        else
            Show_Portals_Function()

            CmHelperDB.framePosition.ShowPortalsButton = "True"
        end

    end

    Timer_Frame_compositeFrame2Show_Teleports_Checkbox:SetScript("OnClick", OnHidePortalButtonCheckboxStateChanged) -- Set script to handle checkbox state change

    -- Define the checkbox variable outside any function to make it accessible globally
    local Timer_Frame_compositeFrame2Ready_Check

    -- Function to initialize the checkbox
    local function InitializeCheckbox_Ready_Check()
        local ReadyCheckisChecked = CmHelperDB.framePosition.ShowReadyCheck == "False" -- Check the value from the database
        Timer_Frame_compositeFrame2Ready_Check:SetChecked(ReadyCheckisChecked)
    end

    -- Create Show_Legend_Checkbox
    Timer_Frame_compositeFrame2Ready_Check = CreateFrame("CheckButton", nil, Timer_Frame_compositeFrame2,
        "UICheckButtonTemplate")
    Timer_Frame_compositeFrame2Ready_Check:SetPoint("TOP", Timer_Frame_compositeFrame2Show_Teleports_Checkbox, "CENTER",
        0, -35)
    Timer_Frame_compositeFrame2Ready_Check.text:SetText("Hide Ready Check Button (*Leader)")
    Timer_Frame_compositeFrame2Ready_Check:SetScript("OnShow", InitializeCheckbox_Ready_Check) -- Call initialization function when the checkbox is shown

    -- Function to handle Hide Legend checkbox state change
    local function OnReadyCheckCheckboxStateChanged(self)
        local ReadyCheckisChecked = self:GetChecked()
        CmHelperDB.framePosition.ShowReadyCheck = ReadyCheckisChecked and "True" or "False" -- Update the value in the database

        -- Call the corresponding function based on the checkbox state
        if ReadyCheckisChecked then
            HideReadyCheck_Function()

            CmHelperDB.framePosition.ShowReadyCheck = "False"
        else
            ShowReadyCheck_Function()

            CmHelperDB.framePosition.ShowReadyCheck = "True"
        end

        Check_Group_State_For_Button_State()
    end

    Timer_Frame_compositeFrame2Ready_Check:SetScript("OnClick", OnReadyCheckCheckboxStateChanged) -- Set script to handle checkbox state change

    -- Define the checkbox variable outside any function to make it accessible globally
    local Timer_Frame_compositeFrame2Mark_Tank_Healer

    -- Function to initialize the checkbox
    local function InitializeCheckbox_Mark_Tank_Healer()
        local Mark_Tank_Healer_isChecked = CmHelperDB.framePosition.ShowMarkTankHealer == "False" -- Check the value from the database
        Timer_Frame_compositeFrame2Mark_Tank_Healer:SetChecked(Mark_Tank_Healer_isChecked)
    end

    -- Create Show_Legend_Checkbox
    Timer_Frame_compositeFrame2Mark_Tank_Healer = CreateFrame("CheckButton", nil, Timer_Frame_compositeFrame2,
        "UICheckButtonTemplate")
    Timer_Frame_compositeFrame2Mark_Tank_Healer:SetPoint("TOP", Timer_Frame_compositeFrame2Ready_Check, "CENTER", 0, -35)
    Timer_Frame_compositeFrame2Mark_Tank_Healer.text:SetText("Hide Mark the Tank and the Healer\nButton (*Leader)")
    Timer_Frame_compositeFrame2Mark_Tank_Healer:SetScript("OnShow", InitializeCheckbox_Mark_Tank_Healer) -- Call initialization function when the checkbox is shown

    -- Function to handle Hide Legend checkbox state change
    local function OnMark_Tank_HealerCheckboxStateChanged(self)
        local Mark_Tank_Healer_isChecked = self:GetChecked()
        CmHelperDB.framePosition.ShowMarkTankHealer = Mark_Tank_Healer_isChecked and "True" or "False" -- Update the value in the database

        -- Call the corresponding function based on the checkbox state
        if Mark_Tank_Healer_isChecked then
            HideMarkTankHealer_Function()

            CmHelperDB.framePosition.ShowMarkTankHealer = "False"
        else
            ShowMarkTankHealer_Function()

            CmHelperDB.framePosition.ShowMarkTankHealer = "True"
        end

        Check_Group_State_For_Button_State()
    end

    Timer_Frame_compositeFrame2Mark_Tank_Healer:SetScript("OnClick", OnMark_Tank_HealerCheckboxStateChanged) -- Set script to handle checkbox state change

end

local function Objectives_Frame_Elements()
    -- Create pattern_image
    local Objectives_Frame_pattern_image2 = Objectives_Frame_compositeFrame3:CreateTexture(nil, "BORDER")
    Objectives_Frame_pattern_image2:SetTexture("Interface\\Challenges\\challenges-background.blp")
    Objectives_Frame_pattern_image2:SetSize(955, 800)
    Objectives_Frame_pattern_image2:SetPoint("TOPLEFT", Objectives_Frame_compositeFrame3, "TOPLEFT", 0, 0)

    -- Create banner_image
    local Objectives_Frame_banner_image2 = Objectives_Frame_compositeFrame3:CreateTexture(nil, "ARTWORK")
    Objectives_Frame_banner_image2:SetTexture("Interface\\Challenges\\challenges-besttime-bg.blp")
    Objectives_Frame_banner_image2:SetSize(952, 50)
    Objectives_Frame_banner_image2:SetPoint("TOPLEFT", Objectives_Frame_compositeFrame3, "TOPLEFT", -166, -30)

    -- Create textFrame
    local Objectives_Frame_textFrame2 = CreateFrame("Frame", nil, Objectives_Frame_compositeFrame3)
    Objectives_Frame_textFrame2:SetAllPoints(Objectives_Frame_compositeFrame3) -- Make the text frame cover the entire composite frame

    local Objectives_Frame_option_text = Objectives_Frame_textFrame2:CreateFontString(nil, "ARTWORK",
        "GameFontNormalHuge")
    Objectives_Frame_option_text:SetPoint("CENTER", Objectives_Frame_banner_image2, "CENTER", 0, 0)
    Objectives_Frame_option_text:SetText("|cffffd700Objectives Frame Options") -- Use |r to reset color
    Objectives_Frame_option_text:SetFont("Fonts\\MORPHEUS.TTF", 72) -- Set the font to Morpheus and adjust the font size here
    Objectives_Frame_option_text:SetShadowColor(0, 0, 0) -- Set shadow color to black
    Objectives_Frame_option_text:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    -- Create objectives_options_panel_left
    local Objectives_Frame_objectives_options_panel_left =
        Objectives_Frame_compositeFrame3:CreateTexture(nil, "ARTWORK")
    Objectives_Frame_objectives_options_panel_left:SetTexture("Interface\\HELPFRAME\\HelpFrame-TopLeft.blp")
    Objectives_Frame_objectives_options_panel_left:SetSize(190, 186)
    Objectives_Frame_objectives_options_panel_left:SetPoint("TOPLEFT", Objectives_Frame_compositeFrame3, "TOP", -288,
        -130)

    -- Create objectives_options_panel_right
    local Objectives_Frame_objectives_options_panel_right = Objectives_Frame_compositeFrame3:CreateTexture(nil,
        "ARTWORK")
    Objectives_Frame_objectives_options_panel_right:SetTexture("Interface\\HELPFRAME\\HelpFrame-TopRight.blp")
    Objectives_Frame_objectives_options_panel_right:SetSize(98, 186)
    Objectives_Frame_objectives_options_panel_right:SetPoint("LEFT", Objectives_Frame_objectives_options_panel_left,
        "RIGHT", 0, 0)

    -- Create objectives_options_panel_bottom_left
    local Objectives_Frame_objectives_options_panel_bottom_left =
        Objectives_Frame_compositeFrame3:CreateTexture(nil, "ARTWORK")
    Objectives_Frame_objectives_options_panel_bottom_left:SetTexture("Interface\\HELPFRAME\\HELPFRAME-BOTLEFT.blp")
    Objectives_Frame_objectives_options_panel_bottom_left:SetSize(190, 186)
    Objectives_Frame_objectives_options_panel_bottom_left:SetPoint("TOPLEFT",
        Objectives_Frame_objectives_options_panel_left, "BOTTOMLEFT", 0, 0) -- Adjusted point

    -- Create objectives_options_panel_bottom_right
    local Objectives_Frame_objectives_options_panel_bottom_right =
        Objectives_Frame_compositeFrame3:CreateTexture(nil, "ARTWORK")
    Objectives_Frame_objectives_options_panel_bottom_right:SetTexture("Interface\\HELPFRAME\\HELPFRAME-BOTRIGHT.blp")
    Objectives_Frame_objectives_options_panel_bottom_right:SetSize(98, 186)
    Objectives_Frame_objectives_options_panel_bottom_right:SetPoint("LEFT",
        Objectives_Frame_objectives_options_panel_bottom_left, "RIGHT", 0, 0)

    -- Create objectives_options_icon
    local Objectives_Frame_timer_options_icon = Objectives_Frame_compositeFrame3:CreateTexture(nil, "OVERLAY")
    Objectives_Frame_timer_options_icon:SetTexture("Interface\\HELPFRAME\\HelpIcon-CharacterStuck.blp")
    Objectives_Frame_timer_options_icon:SetSize(16, 16)
    Objectives_Frame_timer_options_icon:SetPoint("LEFT", Objectives_Frame_objectives_options_panel_right, "TOPRIGHT",
        -53, -14) -- Adjusted point

    -- Create base_background_image
    local Objectives_Frame_base_background_image2 = Objectives_Frame_compositeFrame3:CreateTexture(nil, "BACKGROUND")
    Objectives_Frame_base_background_image2:SetTexture("Interface\\FriendsFrame\\PlusManz-BattleNetBG.blp")
    Objectives_Frame_base_background_image2:SetSize(843, 830)
    Objectives_Frame_base_background_image2:SetPoint("TOPLEFT", Objectives_Frame_compositeFrame3, "TOPLEFT", -112, 130)
    Objectives_Frame_base_background_image2:SetAlpha(0.3)

    local Objectives_Frame_objectives_options_title = Objectives_Frame_textFrame2:CreateFontString(nil, "ARTWORK",
        "GameFontNormalHuge")
    Objectives_Frame_objectives_options_title:SetPoint("CENTER", Objectives_Frame_objectives_options_panel_left,
        "CENTER", 30, 70)
    Objectives_Frame_objectives_options_title:SetText("|cffffd700Settings") -- Use |r to reset color
    Objectives_Frame_objectives_options_title:SetFont("Fonts\\FRIZQT__.TTF", 14) -- Set the font to Morpheus and adjust the font size here
    Objectives_Frame_objectives_options_title:SetShadowColor(0, 0, 0) -- Set shadow color to black
    Objectives_Frame_objectives_options_title:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    -- Button to Restore Objectives_Frame_Position_Reset_Button
    local Objectives_Frame_Objectives_Frame_Position_Reset_Button = CreateFrame("Button", nil,
        Objectives_Frame_compositeFrame3, "UIPanelButtonTemplate")
    Objectives_Frame_Objectives_Frame_Position_Reset_Button:SetFrameLevel(3) -- This ensures that the button is at the correct level within the OVERLAY strata
    Objectives_Frame_Objectives_Frame_Position_Reset_Button:SetPoint("CENTER",
        Objectives_Frame_objectives_options_title, "CENTER", 5, -50)
    Objectives_Frame_Objectives_Frame_Position_Reset_Button:SetText("Reset Objectives Position")
    Objectives_Frame_Objectives_Frame_Position_Reset_Button:SetWidth(200)
    Objectives_Frame_Objectives_Frame_Position_Reset_Button:SetHeight(40)
    Objectives_Frame_Objectives_Frame_Position_Reset_Button:SetScript("OnClick", function()
        ResetObjectivesFramePosition()
    end)

    -- Button to Delete_Boss_Data_Button
    local Objectives_Frame_Delete_Boss_Data_Button = CreateFrame("Button", nil, Objectives_Frame_compositeFrame3,
        "UIPanelButtonTemplate")
    Objectives_Frame_Delete_Boss_Data_Button:SetFrameLevel(3) -- This ensures that the button is at the correct level within the OVERLAY strata
    Objectives_Frame_Delete_Boss_Data_Button:SetPoint("CENTER", Objectives_Frame_Objectives_Frame_Position_Reset_Button,
        "CENTER", 0, -50)
    Objectives_Frame_Delete_Boss_Data_Button:SetText("Clear Saved Boss Kill Times")
    Objectives_Frame_Delete_Boss_Data_Button:SetWidth(200)
    Objectives_Frame_Delete_Boss_Data_Button:SetHeight(40)
    Objectives_Frame_Delete_Boss_Data_Button:SetScript("OnClick", function()
        StaticPopupDialogs["CONFIRM_DELETE_TIMES"] = {
            text = "Are you sure you want to delete saved data for boss kill times?",
            button1 = "Yes - Will Relog",
            button2 = "No",
            OnAccept = function()
                -- Clear the contents of localDB.BestBossKillTime
                wipe(localDB.BestBossKillTime)
                wipe(timesDB.BestBossKillTime)
                print("Saved boss kill times cleared.")

                -- Logout from the game
                Logout()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3
        }
        StaticPopup_Show("CONFIRM_DELETE_TIMES")
    end)

    -- Create Opacity_Label Objectives
    local Objectives_Frame_Opacity_Label = Objectives_Frame_textFrame2:CreateFontString(nil, "OVERLAY",
        "GameFontHighlight")
    Objectives_Frame_Opacity_Label:SetPoint("TOP", Objectives_Frame_Delete_Boss_Data_Button, "BOTTOM", 0, -30)
    Objectives_Frame_Opacity_Label:SetText("Opacity")

    -- Create Slider Objectives
    local Objectives_Frame_slider =
        CreateFrame("Slider", nil, Objectives_Frame_compositeFrame3, "OptionsSliderTemplate")
    Objectives_Frame_slider:SetPoint("TOP", Objectives_Frame_Opacity_Label, "BOTTOM", 0, -10)
    Objectives_Frame_slider:SetWidth(200)
    Objectives_Frame_slider:SetHeight(20)
    Objectives_Frame_slider:SetMinMaxValues(0, 100)
    Objectives_Frame_slider:SetValueStep(1)

    -- Slider Label Objectives
    local Objectives_Frame_sliderLabel = Objectives_Frame_slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    Objectives_Frame_sliderLabel:SetPoint("TOP", Objectives_Frame_slider, "BOTTOM", 0, -5)
    -- Objectives_Frame_sliderLabel:SetText("Value: " .. Objectives_Frame_slider:GetValue())

    -- Load colorPicked2 value from CmHelperDB if available, otherwise use default value
    local initialColorPicked =
        (CmHelperDB and CmHelperDB.Objectives_frame and CmHelperDB.Objectives_frame.colorPicked) or 1
    Objectives_Frame_slider:SetValue(initialColorPicked * 100)
    Objectives_Frame_sliderLabel:SetText(math.floor(initialColorPicked * 100))

    -- Update the OnValueChanged callback function to correctly update colorPicked2
    Objectives_Frame_slider:SetScript("OnValueChanged", function(self, value)
        local colorPicked = value / 100 -- Normalize value to range 0-1
        Objectives_Frame_Opacity(colorPicked)
        Objectives_Frame_sliderLabel:SetText(math.floor(colorPicked * 100)) -- Update the value label
    end)

    function ObjectivesSliderValue(ObjectivesSliderValue)
        Objectives_Frame_slider:SetValue(ObjectivesSliderValue)
        Objectives_Frame_sliderLabel:SetText(math.floor(ObjectivesSliderValue))
    end

    -- Label Combobox_Objectives_Size_Label
    local Objectives_Frame_Combobox_Objectives_Size_Label = Objectives_Frame_textFrame2:CreateFontString(nil, "OVERLAY",
        "GameFontHighlight")
    Objectives_Frame_Combobox_Objectives_Size_Label:SetPoint("TOP", Objectives_Frame_slider, "BOTTOM", 0, -55)
    Objectives_Frame_Combobox_Objectives_Size_Label:SetText("Objectives Frame Size")

    -- Create the combobox frame within compositeFrame3
    local Objectives_Frame_comboBox = CreateFrame("Frame", "MyComboBoxFrame", Objectives_Frame_compositeFrame3,
        "UIDropDownMenuTemplate")
    Objectives_Frame_comboBox:SetPoint("TOP", Objectives_Frame_Combobox_Objectives_Size_Label, "BOTTOM", 0, -10)
    Objectives_Frame_comboBox:SetSize(200, 30)

    -- Determine the default font size
    local Objectives_Font_Size =
        (CmHelperDB and CmHelperDB.Objectives_frame and CmHelperDB.Objectives_frame.fontSize) or "GameFontNormal"

    if Objectives_Font_Size == "GameFontNormalSmall" then
        Objectives_Font_Size = "Small Size"
    elseif Objectives_Font_Size == "GameFontNormal" then
        Objectives_Font_Size = "Normal Size"
    elseif Objectives_Font_Size == "GameFontNormalLarge" then
        Objectives_Font_Size = "Large Size"
    else
        Objectives_Font_Size = "Normal Size" -- Ensure a valid default value
    end

    -- Function to initialize the combobox
    local function InitializeComboBox(self, level)
        local info = UIDropDownMenu_CreateInfo()

        -- Define the options for the combobox
        local options = {"Small Size", "Normal Size", "Large Size"}

        -- Add each option to the combobox
        for _, option in ipairs(options) do
            info.text = option
            info.value = option
            info.notCheckable = true
            info.func = function(self)

                UIDropDownMenu_SetText(Objectives_Frame_comboBox, self.value)
                Change_Font_Size(self.value)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    function Set_ComboBox_Text(value)
        UIDropDownMenu_SetText(Objectives_Frame_comboBox, value)
    end

    -- Initialize the combobox
    UIDropDownMenu_Initialize(Objectives_Frame_comboBox, InitializeComboBox)
    UIDropDownMenu_SetWidth(Objectives_Frame_comboBox, 200) -- Set the width of the dropdown menu
    UIDropDownMenu_SetButtonWidth(Objectives_Frame_comboBox, 124) -- Set the width of the button

    -- Use UIDropDownMenu_SetSelectedName to set the default selected value
    UIDropDownMenu_SetSelectedName(Objectives_Frame_comboBox, Objectives_Font_Size) -- Set the default selected value
    UIDropDownMenu_SetText(Objectives_Frame_comboBox, Objectives_Font_Size)

end

local function Strategies_Frame_Elements()

    -- Create pattern_image
    local Strategies_pattern_image3 = Strategies_compositeFrame:CreateTexture(nil, "BORDER")
    Strategies_pattern_image3:SetTexture("Interface\\Challenges\\challenges-background.blp")
    Strategies_pattern_image3:SetSize(955, 800)
    Strategies_pattern_image3:SetPoint("TOPLEFT", Strategies_compositeFrame, "TOPLEFT", 0, 0)

    -- Create banner_image
    local Strategies_banner_image3 = Strategies_compositeFrame:CreateTexture(nil, "ARTWORK")
    Strategies_banner_image3:SetTexture("Interface\\Challenges\\challenges-besttime-bg.blp")
    Strategies_banner_image3:SetSize(952, 50)
    Strategies_banner_image3:SetPoint("TOPLEFT", Strategies_compositeFrame, "TOPLEFT", -166, -30)

    -- Create textFrame
    local Strategies_textFrame3 = CreateFrame("Frame", nil, Strategies_compositeFrame)
    Strategies_textFrame3:SetAllPoints(Strategies_compositeFrame) -- Make the text frame cover the entire composite frame

    -- Create base_background_image
    local Strategies_base_background_image3 = Strategies_compositeFrame:CreateTexture(nil, "BACKGROUND")
    Strategies_base_background_image3:SetTexture("Interface\\FriendsFrame\\PlusManz-BattleNetBG.blp")
    Strategies_base_background_image3:SetSize(843, 830)
    Strategies_base_background_image3:SetPoint("TOPLEFT", Strategies_compositeFrame, "TOPLEFT", -112, 130)
    Strategies_base_background_image3:SetAlpha(0.3)

    local Strategies_about_text = Strategies_textFrame3:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    Strategies_about_text:SetPoint("CENTER", Strategies_banner_image3, "CENTER", 0, 0)
    Strategies_about_text:SetText("|cffffd700Strategies") -- Use |r to reset color
    Strategies_about_text:SetFont("Fonts\\MORPHEUS.TTF", 72) -- Set the font to Morpheus and adjust the font size here
    Strategies_about_text:SetShadowColor(0, 0, 0) -- Set shadow color to black
    Strategies_about_text:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    -- Create the combobox frame 
    Strategies_Frame_comboBox = CreateFrame("Frame", "MyComboBoxFrame2", Strategies_compositeFrame,
        "UIDropDownMenuTemplate")
    Strategies_Frame_comboBox:SetPoint("TOP", Strategies_about_text, "BOTTOM", 0, -30)
    Strategies_Frame_comboBox:SetSize(200, 30)

    -- Function to initialize the combobox
    local function InitializeComboBox2(self, level)
        local info = UIDropDownMenu_CreateInfo()

        -- Define the options for the combobox
        local selected_dungeon = {"Temple of the Jade Serpent", "Stormstout Brewery", "Gate of the Setting Sun",
                                  "Shado-Pan Monastery", "Siege of Niuzao Temple", "Mogu'shan Palace", "Scholomance",
                                  "Scarlet Halls", "Scarlet Monastery"}

        -- Add each option to the combobox
        for _, option in ipairs(selected_dungeon) do
            info.text = option
            info.value = option
            info.notCheckable = true
            info.func = function(self)

                UIDropDownMenu_SetText(Strategies_Frame_comboBox, self.value)
                Add_New_Strategy_Button:Show()
                --editStrategyFrame:Clear()
                editStrategyFrame:Show()
                editBox:Disable()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    -- Initialize the combobox
    UIDropDownMenu_Initialize(Strategies_Frame_comboBox, InitializeComboBox2)
    UIDropDownMenu_SetWidth(Strategies_Frame_comboBox, 200) -- Set the width of the dropdown menu
    UIDropDownMenu_SetButtonWidth(Strategies_Frame_comboBox, 124) -- Set the width of the button

    -- Use UIDropDownMenu_SetSelectedName to set the default selected value
    UIDropDownMenu_SetText(Strategies_Frame_comboBox, "Select dungeon")

-- Button to Add new strategy
Add_New_Strategy_Button = CreateFrame("Button", nil, Strategies_compositeFrame, "UIPanelButtonTemplate")
Add_New_Strategy_Button:SetFrameLevel(3) -- This ensures that the button is at the correct level within the OVERLAY strata
Add_New_Strategy_Button:SetPoint("LEFT", Strategies_about_text, "BOTTOM", -300, -75)
Add_New_Strategy_Button:SetText("Add New Strategy")
Add_New_Strategy_Button:SetWidth(150)
Add_New_Strategy_Button:SetHeight(30)
Add_New_Strategy_Button:Hide()

Add_New_Strategy_Button:SetScript("OnClick", function()
---inputbox bale onoma gia to koumpi
end)









editStrategyFrame = CreateFrame("Frame", "EditStrategyFrame", Strategies_compositeFrame)
editStrategyFrame:SetSize(340, 300) -- Set an initial size for the frame
editStrategyFrame:SetPoint("LEFT", Strategies_about_text, "BOTTOM", -50, -250)
editStrategyFrame:SetFrameLevel(3)
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


-- Create ScrollFrame
local scrollFrame = CreateFrame("ScrollFrame", "EditStrategyScrollFrame", editStrategyFrame,
    "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -10)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)


    -- Create EditBox to edit the strategy
    editBox = CreateFrame("EditBox", "EditStrategyEditBox", scrollFrame)
    editBox:SetSize(305, 260) -- Set an initial size for the edit box
    editBox:SetPoint("TOPLEFT", 10, -10)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(true) -- Set auto-focus to true
    editBox:SetFontObject(GameFontHighlight)
    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    scrollFrame:SetScrollChild(editBox)
    editStrategyFrame:Hide()
    





























end

local function Automarker_Frame_Elements()

    -- Create pattern_image
    local Automarker_image3 = Automarker_compositeFrame:CreateTexture(nil, "BORDER")
    Automarker_image3:SetTexture("Interface\\Challenges\\challenges-background.blp")
    Automarker_image3:SetSize(955, 800)
    Automarker_image3:SetPoint("TOPLEFT", Automarker_compositeFrame, "TOPLEFT", 0, 0)

    -- Create banner_image
    local Automarker_banner_image3 = Automarker_compositeFrame:CreateTexture(nil, "ARTWORK")
    Automarker_banner_image3:SetTexture("Interface\\Challenges\\challenges-besttime-bg.blp")
    Automarker_banner_image3:SetSize(952, 50)
    Automarker_banner_image3:SetPoint("TOPLEFT", Automarker_compositeFrame, "TOPLEFT", -166, -30)

    -- Create textFrame
    local Automarker_textFrame3 = CreateFrame("Frame", nil, Automarker_compositeFrame)
    Automarker_textFrame3:SetAllPoints(Automarker_compositeFrame) -- Make the text frame cover the entire composite frame

    -- Create base_background_image
    local Automarker_base_background_image3 = Automarker_compositeFrame:CreateTexture(nil, "BACKGROUND")
    Automarker_base_background_image3:SetTexture("Interface\\FriendsFrame\\PlusManz-BattleNetBG.blp")
    Automarker_base_background_image3:SetSize(843, 830)
    Automarker_base_background_image3:SetPoint("TOPLEFT", Automarker_compositeFrame, "TOPLEFT", -112, 130)
    Automarker_base_background_image3:SetAlpha(0.3)

    local Automarker_about_text = Automarker_textFrame3:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    Automarker_about_text:SetPoint("CENTER", Automarker_banner_image3, "CENTER", 0, 0)
    Automarker_about_text:SetText("|cffffd700Automarker") -- Use |r to reset color
    Automarker_about_text:SetFont("Fonts\\MORPHEUS.TTF", 72) -- Set the font to Morpheus and adjust the font size here
    Automarker_about_text:SetShadowColor(0, 0, 0) -- Set shadow color to black
    Automarker_about_text:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

end

local function About_Panel_Elements()

    -- Create pattern_image
    local About_Panel_pattern_image3 = About_Panel_compositeFrame4:CreateTexture(nil, "BORDER")
    About_Panel_pattern_image3:SetTexture("Interface\\Challenges\\challenges-background.blp")
    About_Panel_pattern_image3:SetSize(955, 800)
    About_Panel_pattern_image3:SetPoint("TOPLEFT", About_Panel_compositeFrame4, "TOPLEFT", 0, 0)

    -- Create banner_image
    local About_Panel_banner_image3 = About_Panel_compositeFrame4:CreateTexture(nil, "ARTWORK")
    About_Panel_banner_image3:SetTexture("Interface\\Challenges\\challenges-besttime-bg.blp")
    About_Panel_banner_image3:SetSize(952, 50)
    About_Panel_banner_image3:SetPoint("TOPLEFT", About_Panel_compositeFrame4, "TOPLEFT", -166, -30)

    -- Create textFrame
    local About_Panel_textFrame3 = CreateFrame("Frame", nil, About_Panel_compositeFrame4)
    About_Panel_textFrame3:SetAllPoints(About_Panel_compositeFrame4) -- Make the text frame cover the entire composite frame

    -- Create base_background_image
    local About_Panel_base_background_image3 = About_Panel_compositeFrame4:CreateTexture(nil, "BACKGROUND")
    About_Panel_base_background_image3:SetTexture("Interface\\FriendsFrame\\PlusManz-BattleNetBG.blp")
    About_Panel_base_background_image3:SetSize(843, 830)
    About_Panel_base_background_image3:SetPoint("TOPLEFT", About_Panel_compositeFrame4, "TOPLEFT", -112, 130)
    About_Panel_base_background_image3:SetAlpha(0.3)

    local About_Panel_about_text = About_Panel_textFrame3:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    About_Panel_about_text:SetPoint("CENTER", About_Panel_banner_image3, "CENTER", 0, 0)
    About_Panel_about_text:SetText("|cffffd700About") -- Use |r to reset color
    About_Panel_about_text:SetFont("Fonts\\MORPHEUS.TTF", 72) -- Set the font to Morpheus and adjust the font size here
    About_Panel_about_text:SetShadowColor(0, 0, 0) -- Set shadow color to black
    About_Panel_about_text:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    -- panel elements here
    local About_Panel_addon_info1 = About_Panel_textFrame3:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    About_Panel_addon_info1:SetPoint("TOPLEFT", 7, -150)
    About_Panel_addon_info1:SetJustifyH("LEFT")
    About_Panel_addon_info1:SetText(
        "|cffffd700Mop CM Helper |r |cffffffffis an essential addon tailored to competitive groups \nstriving to enhance their performance in Mist of Pandaria Challenge Modes. \nBoasting two distinct panels, this tool offers comprehensive insights \ncrucial for refining strategies and achieving optimal times and ranks.")

    local About_Panel_addon_info2 = About_Panel_textFrame3:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    About_Panel_addon_info2:SetPoint("TOPLEFT", About_Panel_addon_info1, "BOTTOMLEFT", 0, -10)
    About_Panel_addon_info2:SetJustifyH("LEFT")
    About_Panel_addon_info2:SetText(
        "|cffffffffThe primary panel displays essential metrics such as elapsed and remaining \ntime, along with valuable data on the best server and guild times. \nAdditionally, it provides convenient functionalities like effortless leader \nresets and accessible dungeon portals for all party members.")

    local About_Panel_addon_info3 = About_Panel_textFrame3:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    About_Panel_addon_info3:SetPoint("TOPLEFT", About_Panel_addon_info2, "BOTTOMLEFT", 0, -10)
    About_Panel_addon_info3:SetJustifyH("LEFT")
    About_Panel_addon_info3:SetText(
        "|cffffffffMeanwhile, the secondary panel serves as a treasure trove of information, \nfeaturing the best kill times and real-time updates on current run times for \neach dungeon boss. Armed with these insights, teams can meticulously \nanalyze their performance, identify areas for improvement, and \nrecalibrate their strategies for greater success.")

    local About_Panel_addon_info4 = About_Panel_textFrame3:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    About_Panel_addon_info4:SetPoint("TOPLEFT", About_Panel_addon_info3, "BOTTOMLEFT", 0, -10)
    About_Panel_addon_info4:SetJustifyH("LEFT")
    About_Panel_addon_info4:SetText(
        "|cffffd700Mop CM Helper |r |cffffffffisn't just an addon; it's a strategic ally for those \ncommitted to mastering Mist of Pandaria Challenge Modes \nand dominating the leaderboards.")

end

function f:InitializeOptions()

    -- "BACKGROUND" -- Drawn behind other textures
    -- "BORDER"     -- Drawn on top of other textures but beneath any artwork
    -- "ARTWORK"    -- Drawn on top of any other textures or artwork
    -- "OVERLAY"    -- Drawn on top of all other textures and artwork

    -- Options Panel Frame
    self.panel = CreateFrame("Frame", nil, UIParent, "OptionsBoxTemplate")
    self.panel:Hide()
    self.panel.name = "MoP CM Helper"

    -- Create a base frame to contain all layers
    Main_Options_compositeFrame = CreateFrame("Frame", nil, self.panel)
    Main_Options_compositeFrame:SetPoint("TOPLEFT", 2, -2)
    Main_Options_compositeFrame:SetSize(950, 764) -- Adjust the size as needed

    Main_Options_Panel_Elements()

    InterfaceOptions_AddCategory(self.panel)

    -- Timer Frame Panel
    self.panel.BL = CreateFrame("Frame", nil, UIParent, "OptionsBoxTemplate")
    self.panel.BL:Hide()
    self.panel.BL.name = "Timer Frame"
    self.panel.BL.parent = "MoP CM Helper"

    -- Create a base frame to contain all layers
    Timer_Frame_compositeFrame2 = CreateFrame("Frame", nil, self.panel.BL)
    Timer_Frame_compositeFrame2:SetPoint("TOPLEFT", 2, -2)
    Timer_Frame_compositeFrame2:SetSize(950, 764) -- Adjust the size as needed

    Timer_Frame_Elements()

    InterfaceOptions_AddCategory(self.panel.BL)

    -- Objectives Frame Panel
    self.panel.BL = CreateFrame("Frame", nil, UIParent, "OptionsBoxTemplate")
    self.panel.BL:Hide()
    self.panel.BL.name = "Objectives Frame"
    self.panel.BL.parent = "MoP CM Helper"

    -- Create a base frame to contain all layers
    Objectives_Frame_compositeFrame3 = CreateFrame("Frame", nil, self.panel.BL)
    Objectives_Frame_compositeFrame3:SetPoint("TOPLEFT", 2, -2)
    Objectives_Frame_compositeFrame3:SetSize(950, 764) -- Adjust the size as needed

    Objectives_Frame_Elements()

    InterfaceOptions_AddCategory(self.panel.BL)

    -- Strategies Frame Panel
    self.panel.BL = CreateFrame("Frame", nil, UIParent, "OptionsBoxTemplate")
    self.panel.BL:Hide()
    self.panel.BL.name = "Strategies"
    self.panel.BL.parent = "MoP CM Helper"

    -- Create a base frame to contain all layers
    Strategies_compositeFrame = CreateFrame("Frame", nil, self.panel.BL)
    Strategies_compositeFrame:SetPoint("TOPLEFT", 2, -2)
    Strategies_compositeFrame:SetSize(950, 764) -- Adjust the size as needed

    Strategies_Frame_Elements()

    InterfaceOptions_AddCategory(self.panel.BL)

    -- Automarker Frame Panel
    self.panel.BL = CreateFrame("Frame", nil, UIParent, "OptionsBoxTemplate")
    self.panel.BL:Hide()
    self.panel.BL.name = "Automarker"
    self.panel.BL.parent = "MoP CM Helper"

    -- Create a base frame to contain all layers
    Automarker_compositeFrame = CreateFrame("Frame", nil, self.panel.BL)
    Automarker_compositeFrame:SetPoint("TOPLEFT", 2, -2)
    Automarker_compositeFrame:SetSize(950, 764) -- Adjust the size as needed

    Automarker_Frame_Elements()

    InterfaceOptions_AddCategory(self.panel.BL)

    -- About Panel
    self.panel.BL = CreateFrame("Frame", nil, UIParent, "OptionsBoxTemplate")
    self.panel.BL:Hide()
    self.panel.BL.name = "About"
    self.panel.BL.parent = "MoP CM Helper"

    -- Create a base frame to contain all layers
    About_Panel_compositeFrame4 = CreateFrame("Frame", nil, self.panel.BL)
    About_Panel_compositeFrame4:SetPoint("TOPLEFT", 2, -2)
    About_Panel_compositeFrame4:SetSize(950, 764) -- Adjust the size as needed

    About_Panel_Elements()

    InterfaceOptions_AddCategory(self.panel.BL)

end

-- Function to set default frame position
local function SetDefaultFramePosition()
    if not CmHelperDB then
        CmHelperDB = {}
    end
    if not CmHelperDB.framePosition then
        CmHelperDB.framePosition = {
            yOfs = 0, -- Adjust these values to set the default position
            xOfs = 0,
            point = "CENTER",
            relativePoint = "CENTER"
        }
    end
end

-- Handle Blizzard's Interface Options Frame
local function OnInterfaceOptionsFrameHide()
    -- When the Blizzard interface options frame is hidden, call CloseOptions
    HideTimerFrame()
    HideObjectivesFrame()
    Add_New_Strategy_Button:Hide()
    editStrategyFrame:Hide()
    UIDropDownMenu_SetText(Strategies_Frame_comboBox, "Select dungeon")
    editBox:SetText("")
end

-- Attach the script to the Blizzard Interface Options Frame
InterfaceOptionsFrame:HookScript("OnHide", OnInterfaceOptionsFrameHide)

-- Call the function to set default frame position
SetDefaultFramePosition()

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("WORLD_STATE_TIMER_STOP")
f:SetScript("OnEvent", f.OnEvent)

SLASH_CMHELPER1 = "/cm"
SLASH_CMHELPER2 = "/cmhelper"

SlashCmdList["CMHELPER"] = function(msg, editBox)
    InterfaceOptionsFrame_OpenToCategory("MoP CM Helper")
    InterfaceOptionsFrame_OpenToCategory("MoP CM Helper")
    ShowTimerFrame()
    ShowObjectivesFrame()
end

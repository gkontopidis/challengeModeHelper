-- Addon Initialization
local f = CreateFrame("Frame")

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
        end
    elseif event == "WORLD_STATE_TIMER_STOP" then
        OnWorldStateTimerStop() -- This calls the globally shared function
    end
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
    local compositeFrame = CreateFrame("Frame", nil, self.panel)
    compositeFrame:SetPoint("TOPLEFT", 2, -2)
    compositeFrame:SetSize(950, 764) -- Adjust the size as needed

    -- Create medal_image
    local medal_image = compositeFrame:CreateTexture(nil, "OVERLAY")
    medal_image:SetTexture("Interface\\Challenges\\challenges-gold.blp")
    -- medal_image:SetTexture("Interface\\Timer\\Challenges-Logo.blp") 
    medal_image:SetSize(300, 300)
    medal_image:SetPoint("TOPLEFT", compositeFrame, "TOPLEFT", 0, 0)

    -- Create pattern_image
    local pattern_image = compositeFrame:CreateTexture(nil, "BORDER")
    pattern_image:SetTexture("Interface\\Challenges\\challenges-background.blp")
    pattern_image:SetSize(955, 800)
    pattern_image:SetPoint("TOPLEFT", compositeFrame, "TOPLEFT", 0, 0)

    -- Create banner_image
    local banner_image = compositeFrame:CreateTexture(nil, "ARTWORK")
    banner_image:SetTexture("Interface\\Challenges\\challenges-besttime-bg.blp")
    banner_image:SetSize(952, 170)
    banner_image:SetPoint("TOPLEFT", compositeFrame, "TOPLEFT", -166, -70)

    -- Create textFrame
    local textFrame = CreateFrame("Frame", nil, compositeFrame)
    textFrame:SetAllPoints(compositeFrame) -- Make the text frame cover the entire composite frame

    -- Create base_background_image
    local base_background_image = compositeFrame:CreateTexture(nil, "BACKGROUND")
    base_background_image:SetTexture("Interface\\FriendsFrame\\PlusManz-BattleNetBG.blp")
    base_background_image:SetSize(843, 830)
    base_background_image:SetPoint("TOPLEFT", compositeFrame, "TOPLEFT", -112, 130)
    base_background_image:SetAlpha(0.3)

    local text1 = textFrame:CreateFontString(nil, compositeFrame, "GameFontNormalLarge") -- Set text to OVERLAY layer
    text1:SetPoint("CENTER", -160, 100)
    -- text1:SetText("|cffffd700Authors:\n\n|r |cffffffffClopy, Snapshot")
    text1:SetText("|cffffd700Authors\n\n|r|cff00ff98Clopy|r, |cffaad372Snapshot")
    text1:SetTextColor(1, 0.82, 0) -- Set text color to yellow
    text1:SetShadowColor(0, 0, 0) -- Set shadow color to black
    text1:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    local text2 = textFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    text2:SetPoint("CENTER", text1, "BOTTOMLEFT", 0, -40)
    text2:SetText("|cffffd700Version\n\n|r |cffffffff4.03")
    text2:SetTextColor(1, 0.82, 0) -- Set text color to yellow
    text2:SetShadowColor(0, 0, 0) -- Set shadow color to black
    text2:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    local text3 = textFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    text3:SetPoint("CENTER", text1, "BOTTOMRIGHT", 0, -40)
    text3:SetText("|cffffd700Contact\n\n|r |cff7289daClopy#0540")
    text3:SetTextColor(1, 0.82, 0) -- Set text color to yellow
    text3:SetShadowColor(0, 0, 0) -- Set shadow color to black
    text3:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    local text4 = textFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    text4:SetPoint("CENTER", text1, "BOTTOM", 0, -160)
    text4:SetJustifyH("CENTER")
    text4:SetText(
        "|cffffd700Thanks to|r |cffffffff\n\nPrasinos\nPlaquetas\nDeadmouse\nLocative\nChristina\n\nand the guy who created the Weak Aura for Challenge modes,\nthis WA was our inspiration")
    text4:SetTextColor(1, 0.82, 0) -- Set text color to yellow
    text4:SetShadowColor(0, 0, 0) -- Set shadow color to black
    text4:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    local text5 = textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    text5:SetPoint("CENTER", textFrame, "CENTER", -50, 230)
    text5:SetText("|cffffffffMists of Pandaria\n\n|r|cffffd700Challenge Mode|r|cffffffff\n\nHelper") -- Use |r to reset color
    text5:SetFont("Fonts\\MORPHEUS.TTF", 72) -- Set the font to Morpheus and adjust the font size here
    -- text5:SetFont("Fonts\\FRIZQT__.TTF", 72) -- Adjust the font size here
    text5:SetShadowColor(0, 0, 0) -- Set shadow color to black
    text5:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    InterfaceOptions_AddCategory(self.panel)

    -- Options Panel
    self.panel.BL = CreateFrame("Frame", nil, UIParent, "OptionsBoxTemplate")
    self.panel.BL:Hide()
    self.panel.BL.name = "Options"
    self.panel.BL.parent = "MoP CM Helper"

    -- panel elements here

    -- Create a base frame to contain all layers
    local compositeFrame2 = CreateFrame("Frame", nil, self.panel.BL)
    compositeFrame2:SetPoint("TOPLEFT", 2, -2)
    compositeFrame2:SetSize(950, 764) -- Adjust the size as needed

    -- Create pattern_image
    local pattern_image2 = compositeFrame2:CreateTexture(nil, "BORDER")
    pattern_image2:SetTexture("Interface\\Challenges\\challenges-background.blp")
    pattern_image2:SetSize(955, 800)
    pattern_image2:SetPoint("TOPLEFT", compositeFrame2, "TOPLEFT", 0, 0)

    -- Create banner_image
    local banner_image2 = compositeFrame2:CreateTexture(nil, "ARTWORK")
    banner_image2:SetTexture("Interface\\Challenges\\challenges-besttime-bg.blp")
    banner_image2:SetSize(952, 50)
    banner_image2:SetPoint("TOPLEFT", compositeFrame2, "TOPLEFT", -166, -30)

    -- Create timer_options_panel_left
    local timer_options_panel_left = compositeFrame2:CreateTexture(nil, "ARTWORK")
    timer_options_panel_left:SetTexture("Interface\\HELPFRAME\\HelpFrame-TopLeft.blp")
    timer_options_panel_left:SetSize(190, 186)
    timer_options_panel_left:SetPoint("TOPLEFT", compositeFrame2, "TOPLEFT", 45, -130)

    -- Create timer_options_panel_right
    local timer_options_panel_right = compositeFrame2:CreateTexture(nil, "ARTWORK")
    timer_options_panel_right:SetTexture("Interface\\HELPFRAME\\HelpFrame-TopRight.blp")
    timer_options_panel_right:SetSize(98, 186)
    timer_options_panel_right:SetPoint("LEFT", timer_options_panel_left, "RIGHT", 0, 0)

    -- Create timer_options_panel_bottom_left
    local timer_options_panel_bottom_left = compositeFrame2:CreateTexture(nil, "ARTWORK")
    timer_options_panel_bottom_left:SetTexture("Interface\\HELPFRAME\\HELPFRAME-BOTLEFT.blp")
    timer_options_panel_bottom_left:SetSize(190, 186)
    timer_options_panel_bottom_left:SetPoint("TOPLEFT", timer_options_panel_left, "BOTTOMLEFT", 0, 0) -- Adjusted point

    -- Create timer_options_panel_bottom_right
    local timer_options_panel_bottom_right = compositeFrame2:CreateTexture(nil, "ARTWORK")
    timer_options_panel_bottom_right:SetTexture("Interface\\HELPFRAME\\HELPFRAME-BOTRIGHT.blp")
    timer_options_panel_bottom_right:SetSize(98, 186)
    timer_options_panel_bottom_right:SetPoint("LEFT", timer_options_panel_bottom_left, "RIGHT", 0, 0)

    -- Create timer_options_icon
    local timer_options_icon = compositeFrame2:CreateTexture(nil, "OVERLAY")
    timer_options_icon:SetTexture("Interface\\HELPFRAME\\HelpIcon-CharacterStuck.blp")
    timer_options_icon:SetSize(16, 16)
    timer_options_icon:SetPoint("LEFT", timer_options_panel_right, "TOPRIGHT", -53, -14) -- Adjusted point

    -- Create objectives_options_panel_left
    local objectives_options_panel_left = compositeFrame2:CreateTexture(nil, "ARTWORK")
    objectives_options_panel_left:SetTexture("Interface\\HELPFRAME\\HelpFrame-TopLeft.blp")
    objectives_options_panel_left:SetSize(190, 186)
    objectives_options_panel_left:SetPoint("TOPLEFT", compositeFrame2, "TOPLEFT", 320, -130)

    -- Create objectives_options_panel_right
    local objectives_options_panel_right = compositeFrame2:CreateTexture(nil, "ARTWORK")
    objectives_options_panel_right:SetTexture("Interface\\HELPFRAME\\HelpFrame-TopRight.blp")
    objectives_options_panel_right:SetSize(98, 186)
    objectives_options_panel_right:SetPoint("LEFT", objectives_options_panel_left, "RIGHT", 0, 0)

    -- Create objectives_options_panel_bottom_left
    local objectives_options_panel_bottom_left = compositeFrame2:CreateTexture(nil, "ARTWORK")
    objectives_options_panel_bottom_left:SetTexture("Interface\\HELPFRAME\\HELPFRAME-BOTLEFT.blp")
    objectives_options_panel_bottom_left:SetSize(190, 186)
    objectives_options_panel_bottom_left:SetPoint("TOPLEFT", objectives_options_panel_left, "BOTTOMLEFT", 0, 0) -- Adjusted point

    -- Create objectives_options_panel_bottom_right
    local objectives_options_panel_bottom_right = compositeFrame2:CreateTexture(nil, "ARTWORK")
    objectives_options_panel_bottom_right:SetTexture("Interface\\HELPFRAME\\HELPFRAME-BOTRIGHT.blp")
    objectives_options_panel_bottom_right:SetSize(98, 186)
    objectives_options_panel_bottom_right:SetPoint("LEFT", objectives_options_panel_bottom_left, "RIGHT", 0, 0)

    -- Create objectives_options_icon
    local timer_options_icon = compositeFrame2:CreateTexture(nil, "OVERLAY")
    timer_options_icon:SetTexture("Interface\\HELPFRAME\\HelpIcon-CharacterStuck.blp")
    timer_options_icon:SetSize(16, 16)
    timer_options_icon:SetPoint("LEFT", objectives_options_panel_right, "TOPRIGHT", -53, -14) -- Adjusted point

    -- Create textFrame
    local textFrame2 = CreateFrame("Frame", nil, compositeFrame2)
    textFrame2:SetAllPoints(compositeFrame2) -- Make the text frame cover the entire composite frame

    -- Create base_background_image
    local base_background_image2 = compositeFrame2:CreateTexture(nil, "BACKGROUND")
    base_background_image2:SetTexture("Interface\\FriendsFrame\\PlusManz-BattleNetBG.blp")
    base_background_image2:SetSize(843, 830)
    base_background_image2:SetPoint("TOPLEFT", compositeFrame2, "TOPLEFT", -112, 130)
    base_background_image2:SetAlpha(0.3)

    local option_text = textFrame2:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    option_text:SetPoint("CENTER", banner_image2, "CENTER", 0, 0)
    option_text:SetText("|cffffd700Options") -- Use |r to reset color
    option_text:SetFont("Fonts\\MORPHEUS.TTF", 72) -- Set the font to Morpheus and adjust the font size here
    option_text:SetShadowColor(0, 0, 0) -- Set shadow color to black
    option_text:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    local timer_options_title = textFrame2:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    timer_options_title:SetPoint("CENTER", timer_options_panel_left, "CENTER", 30, 70)
    timer_options_title:SetText("|cffffd700Timer Frame") -- Use |r to reset color
    timer_options_title:SetFont("Fonts\\FRIZQT__.TTF", 14) -- Set the font to Morpheus and adjust the font size here
    timer_options_title:SetShadowColor(0, 0, 0) -- Set shadow color to black
    timer_options_title:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    local objectives_options_title = textFrame2:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    objectives_options_title:SetPoint("CENTER", objectives_options_panel_left, "CENTER", 30, 70)
    objectives_options_title:SetText("|cffffd700Objectives Frame") -- Use |r to reset color
    objectives_options_title:SetFont("Fonts\\FRIZQT__.TTF", 14) -- Set the font to Morpheus and adjust the font size here
    objectives_options_title:SetShadowColor(0, 0, 0) -- Set shadow color to black
    objectives_options_title:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    -- -- Button to Delete Saved Data
    -- local btn = CreateFrame("Button", nil, self.panel.BL, "UIPanelButtonTemplate")
    -- btn:SetFrameLevel(3) -- This ensures that the button is at the correct level within the OVERLAY strata
    -- btn:SetPoint("RIGHT", -50, -80)
    -- btn:SetText("Clear Saved Boss Kill Times")
    -- btn:SetWidth(250)
    -- btn:SetHeight(50)
    -- btn:SetScript("OnClick", function()
    --     StaticPopupDialogs["CONFIRM_DELETE_TIMES"] = {
    --         text = "Are you sure you want to delete saved data for boss kill times?",
    --         button1 = "Yes - Will Relog",
    --         button2 = "No",
    --         OnAccept = function()
    --             -- Clear the contents of localDB.BestBossKillTime
    --             wipe(localDB.BestBossKillTime)
    --             wipe(timesDB.BestBossKillTime)
    --             print("Saved boss kill times cleared.")

    --             -- Logout from the game
    --             Logout()
    --         end,
    --         timeout = 0,
    --         whileDead = true,
    --         hideOnEscape = true,
    --         preferredIndex = 3
    --     }
    --     StaticPopup_Show("CONFIRM_DELETE_TIMES")
    -- end)

    -- -- Button to Restore Frames Positions
    -- local btn2 = CreateFrame("Button", nil, self.panel.BL, "UIPanelButtonTemplate")
    -- btn2:SetFrameLevel(3) -- This ensures that the button is at the correct level within the OVERLAY strata
    -- btn2:SetPoint("LEFT", 50, -80)
    -- btn2:SetText("Reset Frames Positions")
    -- btn2:SetWidth(250)
    -- btn2:SetHeight(50)
    -- btn2:SetScript("OnClick", function()
    --     ResetLabelFramePosition()
    --     ResetObjectivesFramePosition()
    -- end)

    InterfaceOptions_AddCategory(self.panel.BL)

    -- About Panel
    self.panel.BL = CreateFrame("Frame", nil, UIParent, "OptionsBoxTemplate")
    self.panel.BL:Hide()
    self.panel.BL.name = "About"
    self.panel.BL.parent = "MoP CM Helper"

    -- Create a base frame to contain all layers
    local compositeFrame3 = CreateFrame("Frame", nil, self.panel.BL)
    compositeFrame3:SetPoint("TOPLEFT", 2, -2)
    compositeFrame3:SetSize(950, 764) -- Adjust the size as needed

    -- Create pattern_image
    local pattern_image3 = compositeFrame3:CreateTexture(nil, "BORDER")
    pattern_image3:SetTexture("Interface\\Challenges\\challenges-background.blp")
    pattern_image3:SetSize(955, 800)
    pattern_image3:SetPoint("TOPLEFT", compositeFrame3, "TOPLEFT", 0, 0)

    -- Create banner_image
    local banner_image3 = compositeFrame3:CreateTexture(nil, "ARTWORK")
    banner_image3:SetTexture("Interface\\Challenges\\challenges-besttime-bg.blp")
    banner_image3:SetSize(952, 50)
    banner_image3:SetPoint("TOPLEFT", compositeFrame3, "TOPLEFT", -166, -30)

    -- Create textFrame
    local textFrame3 = CreateFrame("Frame", nil, compositeFrame3)
    textFrame3:SetAllPoints(compositeFrame3) -- Make the text frame cover the entire composite frame

    -- Create base_background_image
    local base_background_image3 = compositeFrame3:CreateTexture(nil, "BACKGROUND")
    base_background_image3:SetTexture("Interface\\FriendsFrame\\PlusManz-BattleNetBG.blp")
    base_background_image3:SetSize(843, 830)
    base_background_image3:SetPoint("TOPLEFT", compositeFrame3, "TOPLEFT", -112, 130)
    base_background_image3:SetAlpha(0.3)

    local about_text = textFrame3:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    about_text:SetPoint("CENTER", banner_image3, "CENTER", 0, 0)
    about_text:SetText("|cffffd700About") -- Use |r to reset color
    about_text:SetFont("Fonts\\MORPHEUS.TTF", 72) -- Set the font to Morpheus and adjust the font size here
    about_text:SetShadowColor(0, 0, 0) -- Set shadow color to black
    about_text:SetShadowOffset(2, -2) -- Set shadow offset to create a shadow effect

    -- panel elements here
    local addon_info1 = textFrame3:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    addon_info1:SetPoint("TOPLEFT", 7, -150)
    addon_info1:SetJustifyH("LEFT")
    addon_info1:SetText(
        "|cffffd700Mop CM Helper |r |cffffffffis an essential addon tailored to competitive groups \nstriving to enhance their performance in Mist of Pandaria Challenge Modes. \nBoasting two distinct panels, this tool offers comprehensive insights \ncrucial for refining strategies and achieving optimal times and ranks.")

    local addon_info2 = textFrame3:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    addon_info2:SetPoint("TOPLEFT", addon_info1, "BOTTOMLEFT", 0, -10)
    addon_info2:SetJustifyH("LEFT")
    addon_info2:SetText(
        "|cffffffffThe primary panel displays essential metrics such as elapsed and remaining \ntime, along with valuable data on the best server and guild times. \nAdditionally, it provides convenient functionalities like effortless leader \nresets and accessible dungeon portals for all party members.")

    local addon_info3 = textFrame3:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    addon_info3:SetPoint("TOPLEFT", addon_info2, "BOTTOMLEFT", 0, -10)
    addon_info3:SetJustifyH("LEFT")
    addon_info3:SetText(
        "|cffffffffMeanwhile, the secondary panel serves as a treasure trove of information, \nfeaturing the best kill times and real-time updates on current run times for \neach dungeon boss. Armed with these insights, teams can meticulously \nanalyze their performance, identify areas for improvement, and \nrecalibrate their strategies for greater success.")

    local addon_info4 = textFrame3:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    addon_info4:SetPoint("TOPLEFT", addon_info3, "BOTTOMLEFT", 0, -10)
    addon_info4:SetJustifyH("LEFT")
    addon_info4:SetText(
        "|cffffd700Mop CM Helper |r |cffffffffisn't just an addon; it's a strategic ally for those \ncommitted to mastering Mist of Pandaria Challenge Modes \nand dominating the leaderboards.")

    InterfaceOptions_AddCategory(self.panel.BL)

end

-- Function to set default frame position
local function SetDefaultFramePosition()
    if not CmHelperDB then
        CmHelperDB = {}
    end
    if not CmHelperDB.framePosition then
        CmHelperDB.framePosition = {
            yOfs = -100, -- Adjust these values to set the default position
            xOfs = 100,
            point = "CENTER",
            relativePoint = "CENTER"
        }
    end
end

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
end

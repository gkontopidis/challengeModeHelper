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
    self.panel = CreateFrame("Frame")
    self.panel.name = "MoP CM Helper"

    local addon_info1 = self.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    addon_info1:SetPoint("TOPLEFT", 7, -20)
    addon_info1:SetJustifyH("LEFT")
    addon_info1:SetText(
        "|cffffd700Mop CM Helper |r |cffffffffis an essential addon tailored to competitive groups \nstriving to enhance their performance in Mist of Pandaria Challenge Modes. \nBoasting two distinct panels, this tool offers comprehensive insights \ncrucial for refining strategies and achieving optimal times and ranks.")

    local addon_info2 = self.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    addon_info2:SetPoint("TOPLEFT", addon_info1, "BOTTOMLEFT", 0, -10)
    addon_info2:SetJustifyH("LEFT")
    addon_info2:SetText(
        "|cffffffffThe primary panel displays essential metrics such as elapsed and remaining \ntime, along with valuable data on the best server and guild times. \nAdditionally, it provides convenient functionalities like effortless leader \nresets and accessible dungeon portals for all party members.")

    local addon_info3 = self.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    addon_info3:SetPoint("TOPLEFT", addon_info2, "BOTTOMLEFT", 0, -10)
    addon_info3:SetJustifyH("LEFT")
    addon_info3:SetText(
        "|cffffffffMeanwhile, the secondary panel serves as a treasure trove of information, \nfeaturing the best kill times and real-time updates on current run times for \neach dungeon boss. Armed with these insights, teams can meticulously \nanalyze their performance, identify areas for improvement, and \nrecalibrate their strategies for greater success.")

    local addon_info4 = self.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    addon_info4:SetPoint("TOPLEFT", addon_info3, "BOTTOMLEFT", 0, -10)
    addon_info4:SetJustifyH("LEFT")
    addon_info4:SetText(
        "|cffffd700Mop CM Helper |r |cffffffffisn't just an addon; it's a strategic ally for those \ncommitted to mastering Mist of Pandaria Challenge Modes \nand dominating the leaderboards.")

    local text1 = self.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    text1:SetPoint("TOPLEFT", 7, -420)
    text1:SetText("|cffffd700Authors:|r |cffffffffClopy, Snapshot")

    local text2 = self.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    text2:SetPoint("TOPLEFT", text1, "BOTTOMLEFT", 0, -10)
    text2:SetText("|cffffd700Version:|r |cffffffff4.03")

    local text3 = self.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    text3:SetPoint("TOPLEFT", text2, "BOTTOMLEFT", 0, -10)
    text3:SetText("|cffffd700Contact:|r |cffffffffClopy#0540 (Discord)")

    local text4 = self.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    text4:SetPoint("TOPLEFT", text3, "BOTTOMLEFT", 0, -10)
    text4:SetJustifyH("LEFT")
    text4:SetText(
        "|cffffd700Thanks:|r |cffffffffPrasinos, Plaquetas, Deadmouse, Locative, Christina\nand the guy who created the Weak Aura for Challenge modes,\nit was our inspiration")

    -- Create a frame for the image
    local imageFrame = CreateFrame("Frame", nil, self.panel)
    imageFrame:SetPoint("TOPLEFT", 5, 0)
    imageFrame:SetSize(615, 565)

    -- Button to Delete Saved Data
    local btn = CreateFrame("Button", nil, self.panel, "UIPanelButtonTemplate")
    btn:SetPoint("RIGHT", -50, -80)
    btn:SetText("Clear Saved Boss Kill Times")
    btn:SetWidth(250)
    btn:SetHeight(50)
    btn:SetScript("OnClick", function()
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

    -- Button to Restore Frames Positions
    local btn2 = CreateFrame("Button", nil, self.panel, "UIPanelButtonTemplate")
    btn2:SetPoint("LEFT", 50, -80)
    btn2:SetText("Reset Frames Positions")
    btn2:SetWidth(250)
    btn2:SetHeight(50)
    btn2:SetScript("OnClick", function()
        ResetLabelFramePosition()
        ResetObjectivesFramePosition()
    end)

    InterfaceOptions_AddCategory(self.panel)
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

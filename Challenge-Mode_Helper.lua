-- Addon Initialization
local f = CreateFrame("Frame")

function f:OnEvent(event, addOnName)
    if event == "ADDON_LOADED" then
        if addOnName == "Challenge-Mode_Helper" then
            CmHelperDB = CmHelperDB or CopyTable(defaults)
            self.db = CmHelperDB
            self:InitializeOptions()
            -- Rest of your code
        end
    elseif event == "WORLD_STATE_TIMER_STOP" then
        OnWorldStateTimerStop() -- This calls the globally shared function
    end
end

function f:InitializeOptions()
    self.panel = CreateFrame("Frame")
    self.panel.name = "MoP CM Helper"

    -- Create FontString for text
    local text1 = self.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    text1:SetPoint("TOPLEFT", 20, -400)
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

-- Create a texture for the image
local imageTexture = imageFrame:CreateTexture(nil, "OVERLAY")
imageTexture:SetTexture("Interface\\AddOns\\Challenge-Mode_Helper\\logo")
imageTexture:SetAllPoints()  -- Fill the entire frame with the texture
-- Set the opacity (alpha) of the texture
imageTexture:SetAlpha(0.1) -- 10% opacity

    -- local title = self.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    -- title:SetPoint("TOPLEFT", 5, 0)
    -- title:SetFormattedText("|T%s:%d|t %s", "Interface\\AddOns\\Challenge-Mode_Helper\\logo", 470, "Macro Toolkit")

    -- local version = self.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    -- version:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    -- version:SetText("Version: 1.0")

    -- local author = self.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    -- author:SetPoint("TOPLEFT", version, "BOTTOMLEFT", 0, -10)
    -- author:SetText("Author: Your Name")

    -- local frame = CreateFrame("Frame", "MacroToolkitOptionsMain")
    -- version:SetFormattedText("%s %s", _G.GAME_VERSION_LABEL, GetAddOnMetadata("MacroToolkit", "Version"))
    -- version:SetPoint("CENTER", frame, "CENTER", 0, 130)
    -- author:SetFormattedText("%s: Deepac", L["Author"])
    -- author:SetPoint("CENTER", frame, "CENTER", 0, 100)
    -- return frame
    -- 	-- Debugging output
    --     print("Image path:", "Interface\\AddOns\\Challenge-Mode_Helper\\logo.tga")

    -- -- Create a texture for the image
    -- local texture = self.panel:CreateTexture(nil, "ARTWORK")
    -- texture:SetTexture("Interface\\AddOns\\Challenge-Mode_Helper\\logo.tga") -- Set your image path here
    -- texture:SetSize(128, 128) -- Set the size of the image
    -- texture:SetPoint("TOPLEFT", 20, 0) -- Adjust position as needed

    --     -- Check if texture is loaded
    --     if not texture:GetTexture() then
    --         print("Texture not loaded!")
    --     else
    --         print("Texture loaded successfully!")
    --     end

    --     -- Check texture dimensions
        -- local width, height = text4:GetSize()
        -- print("Texture dimensions:", width, "x", height)

    -- Button to reload UI
    local btn = CreateFrame("Button", nil, self.panel, "UIPanelButtonTemplate")
    btn:SetPoint("TOPLEFT", 20, -50)
    btn:SetText("RELOAD UI")
    btn:SetWidth(230)
    btn:SetScript("OnClick", function()
        ReloadUI()
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

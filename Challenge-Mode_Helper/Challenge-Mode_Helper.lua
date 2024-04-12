-- Challenge-Mode_Helper Addon
local f = CreateFrame("Frame")

local defaults = {
    someOption = true,
}

function f:OnEvent(event, addOnName)
    if event == "ADDON_LOADED" then
        print("Addon loaded:", addOnName)
        if addOnName == "Challenge-Mode_Helper" then
            CmHelperDB = CmHelperDB or CopyTable(defaults)
            self.db = CmHelperDB
            self:InitializeOptions()
            hooksecurefunc("JumpOrAscendStart", function()
                if self.db.someOption then
                    print("Your character jumped.")
                end
            end)
        end
    end
end

function f:InitializeOptions()
    self.panel = CreateFrame("Frame")
    self.panel.name = "MoP CM Helper"

    local cb = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 20, -20)
    cb.Text:SetText("Print when you jump")
    -- Hook the OnClick script to update the option value
    cb:HookScript("OnClick", function(_, btn, down)
        self.db.someOption = cb:GetChecked()
    end)
    cb:SetChecked(self.db.someOption)

    local btn = CreateFrame("Button", nil, self.panel, "UIPanelButtonTemplate")
    btn:SetPoint("TOPLEFT", cb, 0, -40)
    btn:SetText("Reload UI")
    btn:SetWidth(130)
    btn:SetScript("OnClick", function()
        ReloadUI()
    end)

    local btn2 = CreateFrame("Button", nil, self.panel, "UIPanelButtonTemplate")
    btn2:SetPoint("TOPLEFT", btn, 0, -40)
    btn2:SetText("Reverse timer")
    btn2:SetWidth(130)
    btn2:SetScript("OnClick", function()
        -- Add your logic for reversing the timer here
    end)

    local btn3 = CreateFrame("Button", nil, self.panel, "UIPanelButtonTemplate")
    btn3:SetPoint("TOPLEFT", btn2, 0, -40)
    btn3:SetText("Hide Objectives")
    btn3:SetWidth(130)
    btn3:SetScript("OnClick", function()
        -- Call function to hide objectives
    end)

    InterfaceOptions_AddCategory(self.panel)
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)

SLASH_CMHELPER1 = "/cm"
SLASH_CMHELPER2 = "/cmhelper"

SlashCmdList["CMHELPER"] = function(msg, editBox)
    InterfaceOptionsFrame_OpenToCategory("MoP CM Helper")
	InterfaceOptionsFrame_OpenToCategory("MoP CM Helper")
end

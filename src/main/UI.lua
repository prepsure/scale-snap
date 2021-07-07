local CoreGui = game:GetService("CoreGui")

local root = script.Parent.Parent
local Maid = require(root.Util.Maid)


local NOTIFY_GUI = root.Assets.ScaleSnapNotify
local SELECT_GUI = root.Assets.ScaleSnapSelect

local NON_PRECISE_COLOR = Color3.fromRGB(170, 170, 255)
local PRECISE_COLOR = Color3.fromRGB(240, 177, 126)

local PURPLE_IMAGE = "rbxassetid://7038356904"
local ORANGE_IMAGE = "rbxassetid://7053183216"


local UI = {}
UI._maid = Maid.new()


UI.Notify = NOTIFY_GUI:Clone()
UI.Notify.Parent = CoreGui
UI._maid:GiveTask(UI.Notify)

UI.Selects = {}
UI._maid:GiveTask(function()
    table.clear(UI.Selects)
end)


local function modifySelectionGuis(prop, value)
    for _, gui in pairs(UI.Selects) do
        gui.Highlight[prop] = value
    end
end


function UI:ToggleVisibility(state)
    UI.Notify.Enabled = state
    modifySelectionGuis("Visible", state)
end


function UI:TogglePrecise(state)
    UI.Notify.Icon.Image = state and ORANGE_IMAGE or PURPLE_IMAGE
    modifySelectionGuis("BackgroundColor3", state and PRECISE_COLOR or NON_PRECISE_COLOR)
end


function UI:AddSelect(part, face, enabled, precise)
    local new = SELECT_GUI:Clone()
    table.insert(UI.Selects, new)

    new.Adornee = part
    new.Face = face
    new.Highlight.Visible = enabled
    new.Highlight.BackgroundColor3 = precise and PRECISE_COLOR or NON_PRECISE_COLOR

    new.Parent = CoreGui
    UI._maid:GiveTask(new)
end


function UI:RemoveSelect(position)
    local defunct = table.remove(UI.Selects, position)
    defunct:Destroy()
end


function UI:ResetSelects()
    for _, v in pairs(UI.Selects) do
        v:Destroy()
    end
    table.clear(UI.Selects)
end


function UI:Destroy()
    UI._maid:DoCleaning()
end


return UI
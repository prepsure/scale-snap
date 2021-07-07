-- cleanup prep
local root = script.Parent
local myMaid = require(root.Util.Maid).new()

plugin.Unloading:Connect(function()
    myMaid:DoCleaning()
end)

--uis
local UI = require(root.main.UI)
myMaid:GiveTask(UI)


-- preview
local UIPreview = require(root.main.UIPreview)
myMaid:GiveTask(UIPreview)


-- toggle plugin
local toggle = false

local ssToggle = plugin:CreatePluginAction(
    "sstoggle",
    "Scale Snap Toggle",
    "Toggles Scale Snap on and off",
    "rbxassetid://7038208699",
    true
)

myMaid:GiveTask(
    ssToggle.Triggered:Connect(function()
        toggle = not toggle
        UI:ToggleVisibility(toggle)
        UIPreview:Toggle(toggle)
    end)
)


-- toggle precision mode
local precisionToggle = false
local precisionScale = 1/10

local ssPrecise = plugin:CreatePluginAction(
    "ssprecise",
    "Scale Snap Precision Mode",
    "Toggles precision mode. The increment is reduced to 1/10th of the grid size.",
    "rbxassetid://7053183322",
    true
)

myMaid:GiveTask(
    ssPrecise.Triggered:Connect(function()
        precisionToggle = not precisionToggle
        UI:TogglePrecise(precisionToggle)
    end)
)


-- control selection of parts and faces on those parts
local Selection = require(script.Selection)
myMaid:GiveTask(Selection)

Selection.Changed:Connect(function(action, position)
    if action == 'remove' then
        UI:RemoveSelect(position)
    elseif action == 'add' then
        local pf = Selection.List[position]
        UI:AddSelect(pf.Part, pf.Face, toggle, precisionToggle)
    elseif action == 'reset' then
        UI:ResetSelects()
    end
end)


-- extend and retract functionality
local Scaler = require(script.Scaler)
myMaid:GiveTask(Scaler)

local ssExtend = plugin:CreatePluginAction(
    "ssextend",
    "Scale Snap Extend",
    "Extends a surface outward by the grid size",
    "rbxassetid://7038208539",
    true
)
local ssRetract = plugin:CreatePluginAction(
    "ssretract",
    "Scale Snap Retract",
    "Retracts a surface inward by the grid size",
    "rbxassetid://7038373396",
    true
)

local function scale(dir)
    if not toggle then
        return
    end

    local increment = precisionToggle and plugin.GridSize * precisionScale or plugin.GridSize

    for _, pf in pairs(Selection.List) do
        Scaler.ScaleFace(pf.Part, pf.Face, increment, dir)
    end
end

myMaid:GiveTask(
    ssExtend.Triggered:Connect(function()
        scale(1)
    end)
)
myMaid:GiveTask(
    ssRetract.Triggered:Connect(function()
        scale(-1)
    end)
)
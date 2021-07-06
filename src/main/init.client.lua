-- cleanup prep
local root = script.Parent
local myMaid = require(root.Util.Maid).new()

plugin.Unloading:Connect(function()
    myMaid:DoCleaning()
end)


-- uis
local CoreGui = game:GetService("CoreGui")

local faceSelectGui = root.Assets.ScaleSnapSelect
local selectGuis = {}

local notifyGui = root.Assets.ScaleSnapNotify:Clone()
notifyGui.Parent = CoreGui
myMaid:GiveTask(notifyGui)


-- toggle plugin
local toggle = false
local ssToggle = plugin:CreatePluginAction(
    "sstoggle",
    "Scale Snap Toggle",
    "Toggles Scale Snap on and off",
    "rbxassetid://7038208699",
    true
)
ssToggle.Triggered:Connect(function()
    toggle = not toggle

    notifyGui.Enabled = toggle
    for _, v in pairs(selectGuis) do
        v.Enabled = toggle
    end
end)


-- toggle precision mode
local precision = false
local ssPrecise = plugin:CreatePluginAction(
    "ssprecise",
    "Scale Snap Precision Mode",
    "Toggles precision mode. The increment is reduced to 1/10th of the grid size.",
    "rbxassetid://7053183322",
    true
)
ssPrecise.Triggered:Connect(function()
    precision = not precision
    notifyGui.Icon.Image = precision and "rbxassetid://7053183216" or "rbxassetid://7038356904"
end)


-- control selection of parts and faces on those parts
local Selection = require(script.Selection)(myMaid)

myMaid:GiveTask(
    Selection.Changed:Connect(function(action, position)
        if action == 'reset' then

            for _, v in pairs(selectGuis) do
                v:Destroy()
            end
            table.clear(selectGuis)

        elseif action == 'add' then

            local new = faceSelectGui:Clone()
            table.insert(selectGuis, new)

            new.Adornee = Selection.List[position].Part
            new.Face = Selection.List[position].Face
            new.Enabled = toggle

            new.Parent = CoreGui
            myMaid:GiveTask(new)

        elseif action == 'remove' then

            local defunct = table.remove(selectGuis, position)
            defunct:Destroy()

        end
    end)
)


-- extend and retract functionality
local Scaler = require(script.Scaler)(myMaid)

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

    local increment = precision and plugin.GridSize/10 or plugin.GridSize

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
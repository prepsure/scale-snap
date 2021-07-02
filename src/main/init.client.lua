-- cleanup prep
local root = script.Parent
local myMaid = require(root.Util.Maid).new()

plugin.Unloading:Connect(function()
    myMaid:DoCleaning()
end)


-- uis
local CoreGui = game:GetService("CoreGui")

local faceSelectGui = root.Assets.ScaleSnapSelect:Clone()
faceSelectGui.Parent = CoreGui
myMaid:GiveTask(faceSelectGui)

local notifyGui = root.Assets.ScaleSnapNotify:Clone()
notifyGui.Parent = CoreGui
myMaid:GiveTask(notifyGui)


-- toggle plugin
local toggle = false
local ssToggle = plugin:CreatePluginAction(
    "sstoggle",
    "Scale Snap Toggle",
    "Toggles Scale Snap on and off",
    "rbxassetid://7034457110",
    true
)
ssToggle.Triggered:Connect(function()
    toggle = not toggle

    notifyGui.Enabled = toggle
    faceSelectGui.Enabled = toggle
end)


-- control selection of parts and faces on those parts
local Selection = require(script.Selection)
-- i could pass the maid to selection, but that's too much work for 1 event and a function
myMaid:GiveTask(Selection.Changed)
myMaid:GiveTask(function()
    Selection.Part = nil
    Selection.Face = nil
end)

Selection.Changed:Connect(function()
    faceSelectGui.Adornee = Selection.Part
    faceSelectGui.Face = Selection.Face
end)


-- extend and retract functionality
local Scaler = require(script.Scaler)

local ssExtend = plugin:CreatePluginAction(
    "ssextend",
    "Scale Snap Extend",
    "Extends a surface outward by the grid size",
    "rbxassetid://7034452730",
    true
)
local ssRetract = plugin:CreatePluginAction(
    "ssretract",
    "Scale Snap Retract",
    "Retracts a surface inward by the grid size",
    "rbxassetid://7034452781",
    true
)

myMaid:GiveTask(
    ssExtend.Triggered:Connect(function()
        if not toggle then
            return
        end

        Scaler.ScaleFace(Selection.Part, Selection.Face, plugin.GridSize, 1)
    end)
)
myMaid:GiveTask(
    ssRetract.Triggered:Connect(function()
        if not toggle then
            return
        end

        Scaler.ScaleFace(Selection.Part, Selection.Face, plugin.GridSize, -1)
    end)
)
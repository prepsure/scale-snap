-- index gui stuff
local faceSelectGui = script.ScaleSnapSelect
local notifyGui = script.ScaleSnapNotify

faceSelectGui.Parent = game:GetService("CoreGui")
notifyGui.Parent = game:GetService("CoreGui")


-- toggle the plugin on and off
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
local Selection = game.Selection
local UserInputService = game:GetService("UserInputService")

local selectedPart = nil
local selectedFace = nil

local function setSelectedPartAndFace(part, face)
    selectedPart = part
    selectedFace = face

    faceSelectGui.Adornee = part
    faceSelectGui.Face = face
end


local function getFaceFromNormal(part, norm)
	local cf = part.CFrame

	if norm == cf.UpVector then
		return Enum.NormalId.Top
	elseif norm == -cf.UpVector then
		return Enum.NormalId.Bottom
	elseif norm == cf.RightVector then
		return Enum.NormalId.Right
	elseif norm == -cf.RightVector then
		return Enum.NormalId.Left
	elseif norm == cf.LookVector then
		return Enum.NormalId.Front
	elseif norm == -cf.LookVector then
		return Enum.NormalId.Back
	end
end


UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    -- raycast from the cursor
    local camera = workspace.CurrentCamera
    local screenRay = camera:ViewportPointToRay(input.Position.X, input.Position.Y)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Whitelist
    params.FilterDescendantsInstances = Selection:Get() -- only use the selection

    local result = workspace:Raycast(
        screenRay.Origin, screenRay.Direction * 1000, params
    )

    -- check if raycast was successful
    if not result then
        return
    end

    -- cache new part and face
    local normalId = getFaceFromNormal(result.Instance, result.Normal)
    setSelectedPartAndFace(result.Instance, normalId)
end)



-- extend and retract functionality
local abs = math.abs

function scaleFace(part, face, increment, direction)
    local partCf = part.CFrame

    -- math that i'm too lazy to describe, you can probably figure it out
    local moveVect = Vector3.FromNormalId(face)
    local move = increment * direction * (moveVect.X + moveVect.Y + moveVect.Z)

    part.Size += moveVect * move
    part.CFrame = partCf * CFrame.new(move/2 * Vector3.new(abs(moveVect.X), abs(moveVect.Y), abs(moveVect.Z)))
end

local function tryToScale(dir)
    if not (toggle and selectedPart and selectedFace) then
        return
    end

    scaleFace(selectedPart, selectedFace, plugin.GridSize, dir)
end


-- connect everything up to bindings
local ssExtend = plugin:CreatePluginAction(
    "ssextend",
    "Scale Snap Extend",
    "Extends a surface outward by the grid size",
    "rbxassetid://7034452730",
    true
)
ssExtend.Triggered:Connect(function()
    tryToScale(1)
end)

local ssRetract = plugin:CreatePluginAction(
    "ssretract",
    "Scale Snap Retract",
    "Retracts a surface inward by the grid size",
    "rbxassetid://7034452781",
    true
)
ssRetract.Triggered:Connect(function()
    tryToScale(-1)
end)
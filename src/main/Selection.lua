local UserInputService = game:GetService("UserInputService")
local studioSelection = game.Selection

local root = script.Parent.Parent
local Signal = require(root.Util.Signal)


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


local function raycastFromMouse(mousePos, whitelist)
    local camera = workspace.CurrentCamera
    local screenRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Whitelist
    params.FilterDescendantsInstances = whitelist

    local result = workspace:Raycast(
        screenRay.Origin, screenRay.Direction * 1000, params
    )

    return result
end



local Selection = {}

Selection.Part = nil
Selection.Face = nil
Selection.Changed = Signal.new()


function Selection.SetSelection(part, face)
    Selection.Part = part
    Selection.Face = face

    Selection.Changed:Fire()
end


-- bind mouse click to selection change
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    local result = raycastFromMouse(input.Position, studioSelection:Get())

    -- check if raycast was successful
    if not result then
        return
    end

    -- cache new part and face
    Selection.SetSelection(
        result.Instance,
        getFaceFromNormal(result.Instance, result.Normal)
    )
end)


return Selection
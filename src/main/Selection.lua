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


local function raycastFromScreenPoint(mousePos, whitelist)
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
local inputCxn = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    local result = raycastFromScreenPoint(input.Position, studioSelection:Get())

    -- check if raycast was successful
    if not result then
        return
    end

    -- because the part might not be a rectangular prism,
    -- we need to do a second raycast to get the face of the instance
    local targetInstance = result.Instance

    local cube = Instance.new("Part")
    cube.Size = targetInstance.Size
    cube.CFrame = targetInstance.CFrame
    cube.Transparency = 1
    cube.Parent = workspace

    local cubecast = raycastFromScreenPoint(input.Position, {cube})
    cube:Destroy()

    -- cache new part and face
    Selection.SetSelection(
        targetInstance,
        getFaceFromNormal(targetInstance, cubecast.Normal)
    )
end)


return function(maid)
    maid:GiveTask(inputCxn)
    maid:GiveTask(Selection.Changed)
    maid:GiveTask(function()
        Selection.Part = nil
        Selection.Face = nil
    end)

    return Selection
end
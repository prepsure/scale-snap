local UserInputService = game:GetService("UserInputService")
local studioSelection = game.Selection

local root = script.Parent.Parent
local Maid = require(root.Util.Maid)
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
    params.CollisionGroup = "Default"
    if whitelist then
        params.FilterType = Enum.RaycastFilterType.Whitelist
        params.FilterDescendantsInstances = whitelist
    end

    local result = workspace:Raycast(
        screenRay.Origin, screenRay.Direction * 1000, params
    )

    return result
end



local Selection = {}
Selection._maid = Maid.new()

Selection.List = {}
Selection._maid:GiveTask(function()
    table.clear(Selection.List)
end)

Selection.Changed = Signal.new()
Selection._maid:GiveTask(Selection.Changed)

function Selection.Select(part, face)

    table.insert(Selection.List, {
        Part = part,
        Face = face,
    })

    Selection.Changed:Fire('add', #Selection.List)
end


function Selection.Deselect(part, face)
    local deselectedPos = nil

    for i, pf in pairs(Selection.List) do
        if pf.Part == part and pf.Face == face then
            table.remove(Selection.List, i)
            deselectedPos = i
            break
        end
    end

    if deselectedPos then
        Selection.Changed:Fire('remove', deselectedPos)
    end

    return deselectedPos
end


function Selection.ResetSelection()
    table.clear(Selection.List)
    Selection.Changed:Fire('reset')
end


function Selection:GetPartAndFaceFromScreenPoint(pos)
    local result = raycastFromScreenPoint(pos, studioSelection:Get())

    -- check if raycast was successful
    if not result or result.Instance.Locked then
        result = raycastFromScreenPoint(pos)

        if not result or result.Instance.Locked then
            return nil, nil
        end
    end

    -- because the part might not be a rectangular prism,
    -- we need to do a second raycast to get the face of the instance
    local targetInstance = result.Instance

    local cube = Instance.new("Part")
    cube.Size = targetInstance.Size
    cube.CFrame = targetInstance.CFrame
    cube.Transparency = 1
    cube.Parent = workspace

    local cubecast = raycastFromScreenPoint(pos, {cube})
    cube:Destroy()

    if not cubecast then
        -- this happens sometimes for some reason?? best to ignore it
        return nil, nil
    end

    -- get part and face for selection
    local part = targetInstance
    local face = getFaceFromNormal(targetInstance, cubecast.Normal)

    return part, face
end


-- bind mouse click to selection change
Selection._maid:GiveTask(
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        if not (
            input:IsModifierKeyDown(Enum.ModifierKey.Ctrl) or
            input:IsModifierKeyDown(Enum.ModifierKey.Shift)
        ) then
            Selection.ResetSelection()
        end

        local part, face = Selection:GetPartAndFaceFromScreenPoint(input.Position)

        if not (part and face) then
            return
        end

        -- check if it was already selected, an if so, deselect it
        if Selection.Deselect(part, face) then
            return
        end

        -- select the new part and face pair!
        Selection.Select(part, face)
    end)
)


function Selection:Destroy()
    Selection._maid:DoCleaning()
end


return Selection
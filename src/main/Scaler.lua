local ChangeHistoryService = game:GetService("ChangeHistoryService")
local abs = math.abs


local Scaler = {}

Scaler.Cooldown = 0.5
Scaler.LastScaled = os.clock()

local waypointName = "SnapScale Scale"


function Scaler.ScaleFace(part, face, increment, direction)
    if not (part and face and increment and direction) then
        return false
    end

    -- add an undo point if this is the first time the thing was pressed
    local currentTime = os.clock()
    local waypointMade = false

    if currentTime - Scaler.LastScaled > Scaler.Cooldown then
        ChangeHistoryService:SetWaypoint(waypointName)
        waypointMade = true
    end
    Scaler.LastScaled = currentTime

    -- math that i'm too lazy to describe, you can probably figure it out
    local partCf = part.CFrame

    local moveVect = Vector3.FromNormalId(face)
    local move = increment * direction * (moveVect.X + moveVect.Y + moveVect.Z)

    part.Size += moveVect * move
    part.CFrame = partCf * CFrame.new(move/2 * Vector3.new(abs(moveVect.X), abs(moveVect.Y), abs(moveVect.Z)))

    -- finish the undo
    if waypointMade then
        ChangeHistoryService:SetWaypoint(waypointName)
    end

    return true
end


local RunService = game:GetService("RunService")

local runCxn = RunService.Heartbeat:Connect(function()
    if not Scaler.ScaledThisFrame then
        Scaler.IsFirstScale = true
    end

    Scaler.ScaledThisFrame = false
end)


return function(maid)
    maid:GiveTask(runCxn)
    return Scaler
end
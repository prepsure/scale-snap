local abs = math.abs

local Scaler = {}


function Scaler.ScaleFace(part, face, increment, direction)
    if not (part and face and increment and direction) then
        return
    end

    local partCf = part.CFrame

    -- math that i'm too lazy to describe, you can probably figure it out
    local moveVect = Vector3.FromNormalId(face)
    local move = increment * direction * (moveVect.X + moveVect.Y + moveVect.Z)

    part.Size += moveVect * move
    part.CFrame = partCf * CFrame.new(move/2 * Vector3.new(abs(moveVect.X), abs(moveVect.Y), abs(moveVect.Z)))

    return true
end


return Scaler
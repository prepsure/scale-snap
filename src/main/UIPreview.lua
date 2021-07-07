local plugin = script:FindFirstAncestorWhichIsA("Plugin")

local CoreGui = game:GetService("CoreGui")

local root = script.Parent.Parent
local Maid = require(root.Util.Maid)

local Selection = require(root.main.Selection)


local UIPreview = {}
UIPreview._maid = Maid.new()

UIPreview.Enabled = false

UIPreview.Gui = root.Assets.ScaleSnapSelect:Clone()
UIPreview.Gui.Name = "ScaleSnapPreview"
UIPreview.Gui.Highlight.BackgroundTransparency = 0.75
UIPreview.Gui.Parent = CoreGui
UIPreview._maid:GiveTask(UIPreview.Gui)


local UserInputService = game:GetService("UserInputService")

UIPreview._maid:GiveTask(
    UserInputService.InputChanged:Connect(function(input)
        if not input.UserInputType == Enum.UserInputType.MouseMovement then
            return
        end

        if not UIPreview.Enabled then
            return
        end

        local part, face = Selection:GetPartAndFaceFromScreenPoint(input.Position)

        UIPreview.Gui.Adornee = part
        if face then
            UIPreview.Gui.Face = face
        end
    end)
)


function UIPreview:Toggle(state)
    UIPreview.Enabled = state
    UIPreview.Gui.Enabled = state
end


function UIPreview:Destroy()
    UIPreview._maid:DoCleaning()
end


return UIPreview
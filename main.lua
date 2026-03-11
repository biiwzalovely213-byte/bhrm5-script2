local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local MAX_DISTANCE = 250

local function createBox(part)

    if part:FindFirstChild("arbbox") then
        return part.arbbox
    end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "arbbox"
    box.Adornee = part
    box.Size = Vector3.new(0.5,0.5,0.5)
    box.AlwaysOnTop = true
    box.Transparency = 0.2
    box.Parent = part

    return box
end


local function visible(part)

    local origin = Camera.CFrame.Position
    local direction = part.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}

    local result = workspace:Raycast(origin, direction, params)

    return result == nil
end


RunService.RenderStepped:Connect(function()

    local char = LocalPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end


    for _,v in pairs(workspace:GetDescendants()) do

        if v:IsA("HumanoidRootPart") and v.Parent and v.Parent.Name:match("ARB") then

            local dist = (v.Position - root.Position).Magnitude
            local box = createBox(v)

            if dist <= MAX_DISTANCE then

                box.Visible = true

                if visible(v) then
                    box.Color3 = Color3.fromRGB(0,255,0)
                else
                    box.Color3 = Color3.fromRGB(255,0,0)
                end

            else
                box.Visible = false
            end

        end

    end

end)

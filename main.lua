local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local MAX_DISTANCE = 250

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function createBox(part)

    if part:FindFirstChild("npc_box") then
        return part.npc_box
    end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "npc_box"
    box.Adornee = part
    box.Size = Vector3.new(0.45,0.45,0.45)
    box.AlwaysOnTop = true
    box.Transparency = 0.2
    box.Parent = part

    return box
end


local function canSee(part)

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


    for _,model in pairs(workspace:GetDescendants()) do

        if model:IsA("Model") then

            if not isPlayerCharacter(model) then

                local hum = model:FindFirstChildOfClass("Humanoid")

                if hum then

                    local part = model:FindFirstChild("HumanoidRootPart", true)

                    if part then

                        local dist = (part.Position - root.Position).Magnitude
                        local box = createBox(part)

                        if dist <= MAX_DISTANCE then

                            box.Visible = true

                            if canSee(part) then
                                box.Color3 = Color3.fromRGB(0,255,0)
                            else
                                box.Color3 = Color3.fromRGB(255,0,0)
                            end

                        else
                            box.Visible = false
                        end

                    end

                end

            end

        end

    end

end)

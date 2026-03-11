local folder = workspace:FindFirstChild("Folder")
if not folder then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local MAX_DISTANCE = 250

local function createBox(part)

    if part:FindFirstChild("npcbox") then
        return part.npcbox
    end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "npcbox"
    box.Adornee = part
    box.Size = Vector3.new(0.6,0.6,0.6)
    box.AlwaysOnTop = true
    box.Transparency = 0.2
    box.Parent = part

    return box
end


local function visibleCheck(part)

    local origin = camera.CFrame.Position
    local direction = part.Position - origin

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {player.Character, part.Parent}
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin,direction,params)

    return result == nil
end


RunService.RenderStepped:Connect(function()

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _,npc in pairs(folder:GetChildren()) do

        local part = npc:FindFirstChild("HumanoidRootPart")

        if part then

            local dist = (part.Position - root.Position).Magnitude
            local box = createBox(part)

            if dist <= MAX_DISTANCE then

                box.Visible = true

                if visibleCheck(part) then
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

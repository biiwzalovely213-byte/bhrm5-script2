local folder = workspace:WaitForChild("Folder")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local MAX_DISTANCE = 250

local function canSee(part)

    local origin = camera.CFrame.Position
    local direction = part.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {localPlayer.Character, part.Parent}

    local result = workspace:Raycast(origin,direction,params)

    return result == nil
end


local function createBox(head)

    if head:FindFirstChild("npc_box") then
        return head.npc_box
    end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "npc_box"
    box.Adornee = head
    box.Size = Vector3.new(0.3,0.3,0.3)
    box.AlwaysOnTop = true
    box.Transparency = 0.2
    box.Parent = head

    return box
end


RunService.Heartbeat:Connect(function()

    local char = localPlayer.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end


    for _,npc in pairs(folder:GetChildren()) do

        local head = npc:FindFirstChild("Head") or npc:FindFirstChild("HumanoidRootPart")

        if head then

            local dist = (head.Position - root.Position).Magnitude
            local box = createBox(head)

            if dist <= MAX_DISTANCE then

                box.Visible = true

                if canSee(head) then
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

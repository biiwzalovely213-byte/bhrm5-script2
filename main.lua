local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local MAX_DISTANCE = 250
local trackedHeads = {}

local function isNPC(model)
    if not model:IsA("Model") then
        return false
    end

    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then
        return false
    end

    if Players:GetPlayerFromCharacter(model) then
        return false
    end

    return true
end

local function getHead(model)
    return model:FindFirstChild("Head")
end

local function createBox(head)
    if not head then return end
    if head:FindFirstChild("NPC_BOX") then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "NPC_BOX"
    box.Adornee = head
    box.Size = Vector3.new(1.3,1.3,1.3)
    box.AlwaysOnTop = true
    box.Transparency = 0.25
    box.ZIndex = 5
    box.Color3 = Color3.new(1,0,0)
    box.Parent = head
end

local function expandHitbox(npc)
    local root = npc:FindFirstChild("HumanoidRootPart")

    if root then
        root.Size = Vector3.new(12,12,12)
        root.Transparency = 0.7
        root.CanCollide = false
    end
end

local function canSee(target)
    local origin = camera.CFrame.Position
    local direction = (target.Position - origin)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {player.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin,direction,params)

    if result and result.Instance then
        if result.Instance:IsDescendantOf(target.Parent) then
            return true
        end
        return false
    end

    return true
end

local function addNPC(v)
    if isNPC(v) then
        local head = getHead(v)
        if not head then return end

        trackedHeads[v] = head
        createBox(head)
        expandHitbox(v)
    end
end

for _,v in pairs(workspace:GetDescendants()) do
    addNPC(v)
end

workspace.DescendantAdded:Connect(function(v)
    addNPC(v)
end)

RunService.RenderStepped:Connect(function()
    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for npc,head in pairs(trackedHeads) do
        if npc and npc.Parent and head then
            local box = head:FindFirstChild("NPC_BOX")

            if box then
                local distance = (head.Position - root.Position).Magnitude

                if distance <= MAX_DISTANCE then
                    box.Visible = true

                    if canSee(head) then
                        box.Color3 = Color3.new(0,1,0)
                    else
                        box.Color3 = Color3.new(1,0,0)
                    end
                else
                    box.Visible = false
                end
            end
        end
    end
end)

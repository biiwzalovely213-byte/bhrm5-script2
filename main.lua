local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local MAX_DISTANCE = 250

local npcCache = {}
local trackedParts = {}

local function isNPC(model)

    if not model:IsA("Model") then return false end

    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    if Players:GetPlayerFromCharacter(model) ~= nil then
        return false
    end

    return true

end


local function getHead(model)

    return model:FindFirstChild("Head")

end


local function createBox(part)

    if not part then return end
    if part:FindFirstChild("NPC_BOX") then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "NPC_BOX"
    box.Adornee = part
    box.Size = Vector3.new(1.2,1.2,1.2)
    box.AlwaysOnTop = true
    box.Transparency = 0.25
    box.ZIndex = 5
    box.Parent = part

    trackedParts[part] = true

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


local function registerNPC(model)

    if npcCache[model] then return end

    npcCache[model] = true

    local head = getHead(model)

    if head then
        createBox(head)
    end

end


local function scanNPC(obj)

    if isNPC(obj) then
        registerNPC(obj)
    end

end


for _,v in pairs(workspace:GetDescendants()) do
    scanNPC(v)
end


workspace.DescendantAdded:Connect(function(v)

    task.wait(0.2)
    scanNPC(v)

end)


RunService.RenderStepped:Connect(function()

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for npc in pairs(npcCache) do

        if npc and npc.Parent then

            local head = getHead(npc)
            local box = head and head:FindFirstChild("NPC_BOX")

            if head and box then

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

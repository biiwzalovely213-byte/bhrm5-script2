local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local MAX_DISTANCE = 250
local NPCs = {}

local function isNPC(model)

    if not model:IsA("Model") then return false end
    if not model:FindFirstChildOfClass("Humanoid") then return false end
    if Players:GetPlayerFromCharacter(model) then return false end

    return true
end

local function getHead(model)
    return model:FindFirstChild("Head")
end

local function createBox(npc)

    local head = getHead(npc)
    if not head then return end

    if head:FindFirstChild("NPC_BOX") then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "NPC_BOX"
    box.Adornee = head
    box.Size = Vector3.new(1.8,1.8,1.8)
    box.AlwaysOnTop = true
    box.Transparency = 0.25
    box.ZIndex = 5
    box.Parent = head

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
        table.insert(NPCs,v)
        createBox(v)
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

    for _,npc in pairs(NPCs) do

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

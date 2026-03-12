local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local MAX_DISTANCE = 250

local NPCs = {}

local function getHead(model)
    return model:FindFirstChild("Head")
end

local function isPlayer(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function isNPC(model)
    if not model:IsA("Model") then return false end
    if isPlayer(model) then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    return true
end

for _,v in pairs(workspace:GetDescendants()) do
    if v:IsA("BoxHandleAdornment") and v.Name == "NPC_BOX" then
        v:Destroy()
    end
end

local function createBox(npc)
    local head = getHead(npc)
    if not head then return end
    if head:FindFirstChild("NPC_BOX") then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "NPC_BOX"
    box.Adornee = head
    box.Size = Vector3.new(1.2,1.2,1.2)
    box.AlwaysOnTop = true
    box.Transparency = 0.25
    box.ZIndex = 5
    box.Color3 = Color3.fromRGB(255,0,0)
    box.Parent = head
end

local function addNPC(model)
    if isNPC(model) then
        table.insert(NPCs,model)
        createBox(model)
    end
end

for _,v in pairs(workspace:GetDescendants()) do
    addNPC(v)
end

workspace.DescendantAdded:Connect(addNPC)

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
                else
                    box.Visible = false
                end
            end
        end
    end
end)

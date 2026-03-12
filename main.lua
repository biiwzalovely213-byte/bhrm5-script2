local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local MAX_DISTANCE = 250
local Targets = {}

local function getHead(model)
    return model:FindFirstChild("Head")
end

local function createBox(target,color)
    local head = getHead(target)
    if not head then return end
    if head:FindFirstChild("ESP_BOX") then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESP_BOX"
    box.Adornee = head
    box.Size = Vector3.new(1.2,1.2,1.2)
    box.AlwaysOnTop = true
    box.Transparency = 0.25
    box.ZIndex = 5
    box.Color3 = color
    box.Parent = head
end

local function addPlayer(char)
    if char == player.Character then return end
    table.insert(Targets,{model = char,type = "PLAYER"})
    createBox(char,Color3.fromRGB(0,170,255))
end

local function isNPC(model)
    if not model:IsA("Model") then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    return true
end

local function addNPC(model)
    if isNPC(model) then
        table.insert(Targets,{model = model,type = "NPC"})
        createBox(model,Color3.fromRGB(255,0,0))
    end
end

for _,p in pairs(Players:GetPlayers()) do
    if p.Character then
        addPlayer(p.Character)
    end
    p.CharacterAdded:Connect(addPlayer)
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

    for _,data in pairs(Targets) do
        local model = data.model
        if model and model.Parent then
            local head = getHead(model)
            local box = head and head:FindFirstChild("ESP_BOX")
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

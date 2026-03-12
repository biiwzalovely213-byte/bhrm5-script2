local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local MAX_DISTANCE = 250
local NPCs = {}
local hitboxEnabled = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,200,0,120)
Frame.Position = UDim2.new(0,20,0.5,-60)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,30)
Title.Text = "NPC Tools"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Parent = Frame

local HitboxButton = Instance.new("TextButton")
HitboxButton.Size = UDim2.new(1,-20,0,40)
HitboxButton.Position = UDim2.new(0,10,0,40)
HitboxButton.Text = "Hitbox OFF"
HitboxButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
HitboxButton.TextColor3 = Color3.new(1,1,1)
HitboxButton.Parent = Frame

local function isNPC(model)

    if not model:IsA("Model") then return false end

    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    if Players:GetPlayerFromCharacter(model) ~= nil then
        return false
    end

    return true
end

local function getRoot(model)

    return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso")

end

local function createBox(npc)

    local root = getRoot(npc)
    if not root then return end

    if root:FindFirstChild("NPC_BOX") then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "NPC_BOX"
    box.Adornee = root
    box.Size = Vector3.new(4,6,2)
    box.AlwaysOnTop = true
    box.Transparency = 0.5
    box.Color3 = Color3.new(1,0,0)
    box.ZIndex = 5
    box.Parent = root

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

HitboxButton.MouseButton1Click:Connect(function()

    hitboxEnabled = not hitboxEnabled

    if hitboxEnabled then
        HitboxButton.Text = "Hitbox ON"
    else
        HitboxButton.Text = "Hitbox OFF"
    end

end)

RunService.RenderStepped:Connect(function()

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _,npc in pairs(NPCs) do

        if npc and npc.Parent then

            local npcRoot = getRoot(npc)
            local box = npcRoot and npcRoot:FindFirstChild("NPC_BOX")

            if npcRoot and box then

                local distance = (npcRoot.Position - root.Position).Magnitude

                if distance <= MAX_DISTANCE then

                    box.Visible = true

                    if hitboxEnabled then
                        npcRoot.Size = Vector3.new(10,10,10)
                        npcRoot.Transparency = 0.6
                    end

                else

                    box.Visible = false

                end

            end

        end

    end

end)

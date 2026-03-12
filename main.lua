local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local MAX_DISTANCE = 250

local Targets = {}

local function getHead(model)
    return model:FindFirstChild("Head")
end

local function isPlayer(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function createBox(model,color,name)
    local head = getHead(model)
    if not head then return end
    if head:FindFirstChild(name) then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = name
    box.Adornee = head
    box.Size = Vector3.new(1.2,1.2,1.2)
    box.AlwaysOnTop = true
    box.Transparency = 0.25
    box.ZIndex = 5
    box.Color3 = color
    box.Parent = head
end

for _,v in pairs(workspace:GetDescendants()) do
    if v:IsA("BoxHandleAdornment") and (v.Name == "PLAYER_BOX" or v.Name == "NPC_BOX") then
        v:Destroy()
    end
end

local function addTarget(model)

    if not model:IsA("Model") then return end

    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if isPlayer(model) then
        if model ~= player.Character then
            table.insert(Targets,{model=model,type="PLAYER"})
            createBox(model,Color3.fromRGB(0,170,255),"PLAYER_BOX")
        end
    else
        table.insert(Targets,{model=model,type="NPC"})
        createBox(model,Color3.fromRGB(255,0,0),"NPC_BOX")
    end

end

for _,v in pairs(workspace:GetDescendants()) do
    addTarget(v)
end

workspace.DescendantAdded:Connect(addTarget)

RunService.RenderStepped:Connect(function()

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _,data in pairs(Targets) do

        local model = data.model

        if model and model.Parent then

            local head = getHead(model)

            if head then

                local box

                if data.type == "PLAYER" then
                    box = head:FindFirstChild("PLAYER_BOX")
                else
                    box = head:FindFirstChild("NPC_BOX")
                end

                if box then

                    local distance = (head.Position - root.Position).Magnitude

                    if distance <= MAX_DISTANCE then
                        box.Visible = true
                    else
                        box.Visible = false
                    end

                end

            end

        end

    end

end)
